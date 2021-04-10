import rv32i_types::*;

module load_store_q #(
	parameter width 		= 32,
	parameter lsq_size 		= 8
)
(
	input 	sal_t 				rob_bus[size],
	input 	rs_t 				reg_entry,
	input 	pci_t 				instruction,
	input 	logic 	[3:0]	 	rob_tag,			
			
	output 	logic 				lsq_stall,
	output 	sal_t 				lsq_out

	// to cache
	input 	logic 				mem_resp,
	input 	logic 	[31:0] 		mem_rdata,
	output 	logic 				mem_read,
	output 	logic 				mem_write,
	output 	logic 	[3:0] 		mem_byte_enable,
	output 	logic 	[31:0]		mem_address,
	output 	logic 	[31:0] 		mem_wdata
);

	// internals
	logic 			ld_valid, st_valid, ld_or_st;									// load is 1, store is 0 for ld_or_st
	logic 	[1:0] 	remainder;
	logic 	[31:0] 	shift_amt, mem_address_raw, mem_rdata_shifted;

	// load queue logic
	logic 			ld_enq, ld_deq, ld_empty, ld_full, ld_ready, is_load_instr;
	lsq_t 			ld_in, ld_out, ld_front;
	logic 	[31:0]	ld_byte_en;

	// store queue logic
	logic 			st_enq, st_deq, st_empty, st_full, st_ready, is_store_instr;
	lsq_t 			st_in, st_out, st_front;

	assign 			ld_front 			= ldq.arr[ldq.front];
	assign 			st_front 			= stq.arr[stq.front];
	assign 			is_load_instr 		= instruction.opcode == op_load;
	assign 			is_store_instr 		= instruction.opcode == op_store;
	assign 			ld_valid 			= ~ld_empty && ~ld_front.addr_is_tag;		// can be improved, doesn't need to be head
	assign 			st_valid 			= ~st_empty && ~st_front.addr_is_tag;

	assign 			remainder 			= mem_address_raw[1:0];
	assign 			shift_amt 			= remainder << 3;
	assign 			mem_rdata_shifted 	= mem_rdata >> shift_amt;
	assign 			mem_address 		= mem_address_raw & 32'hFFFFFFFC;
	
	circular_lsq #(32, lsq_size) ldq(
		.enq(ld_enq),
		.deq(ld_deq),
		.in(ld_in),
		.empty(ld_empty),
		.full(ld_full),
		.ready(ld_ready),
		.out(ld_out),
		.*
	);

	circular_lsq #(32, lsq_size) stq(
		.enq(st_enq),
		.deq(st_deq),
		.in(st_in),
		.empty(st_empty),
		.full(st_full),
		.ready(st_ready),
		.out(st_out),
		.*
	);

	function set_default();
		ld_enq 		= 0;
		ld_deq 		= 0;
		ld_in 		= '{default: 0};

		st_enq 		= 0;
		st_deq 		= 0;
		st_in 		= '{default: 0};
	endfunction : set_default

	task update_q_reg(lsq_t item);
		if(item.addr_is_tag & rob_bus[addr[3:0]].rdy) begin
			item.addr 			<= rob_bus[addr[3:0]].data + item.pc_info.i_imm;
			item.addr_is_tag	<= 1'b0;
		end 
	endtask

	always_comb begin 
		set_default();
		if(is_load_instr) begin 
			ld_enq 	= 1;
			ld_in 	= '{pc_info		: 	instruction, 
						rd_tag		: 	rob_tag, 
						data 		: 	32'dx,
						addr 		: 	reg_entry.busy_r1 ? reg_entry.r1 : reg_entry.r1 + instruction.i_imm,
						addr_is_tag	:	reg_entry.busy_r1
						};
		end


		unique case({ld_valid, st_valid})
			2'b00: 	ld_or_st = 1'bx;

			2'b01:	ld_or_st = 0;

			2'b10:	ld_or_st = 1;

			2'b11: 	ld_or_st = ld_front.pc_info.pc > st_front.pc_info.pc;
		endcase 

		unique case(ld_front.pc_info.funct3)
			load_funct3_t::lb	: ld_byte_en = {{25{mem_rdata_shifted[7]}}, mem_rdata_shifted[6:0]};
			load_funct3_t::lh	: ld_byte_en = {{17{mem_rdata_shifted[15]}}, mem_rdata_shifted[14:0]};
			load_funct3_t::lw	: ld_byte_en = mem_rdata_shifted;
			load_funct3_t::lbu	: ld_byte_en = {24'd0, mem_rdata_shifted[7:0]};
			load_funct3_t::lhu	: ld_byte_en = {16'd0, mem_rdata_shifted[15:0]};
		endcase 
	end 

	always_ff @(posedge clk) begin 
		if(rst) begin 
			mem_read 		<= 0;
			mem_write 		<= 0;
		end 
		else begin 
			// see if anything new was posted on rob bus
			for(int i = 0; i < lsq_size; i++) begin 
				if(ldq.arr[i].addr_is_tag)
					update_q_reg(ldq.arr[i]);

				if(stq.arr[i].addr_is_tag)
					update_q_reg(stq.arr[i]);
			end 

			if(mem_resp) begin
				ld_deq 			<= mem_read;
				st_deq 			<= mem_write;

				mem_address_raw <= ld_or_st ? ld_front.addr : st_front.addr;

				// read case
				if(mem_read) begin
					ld_front.data 	<= ld_byte_en;
					lsq_out	 		<= '{tag: ld.front.rd_tag, rdy: 1'b1, data: ld_byte_en};	// broadcast on read
				end
				mem_read 		<= (ld_valid || st_valid) && ld_or_st;

				// write case
				mem_write 		<= (ld_valid || st_valid) && ~ld_or_st;
			end 
			else if(~mem_read && ~mem_write && (ld_valid || st_valid)) begin 					// we can now operate
				mem_address_raw <= ld_or_st ? ld_front.addr : st_front.addr;

				// read
				mem_read 		<= ld_or_st;

				// write
				mem_write 		<= ~ld_or_st;
			end 
	end 

endmodule : load_store_q


module circular_lsq #(parameter width = 32,
					parameter size 	= 8)
(
	input 	logic 				clk,
	input 	logic 				rst,
	input 	logic 				enq,
	input 	logic 				deq,
	input 	lsq_t 				in,
	output	logic 				empty,
	output 	logic 				full,
	output 	logic 				ready,
	output 	lsq_t 				out
);

	lsq_t 	arr[size];
	int 	front, rear;

	assign 	full 	= (front == 0 && rear == size - 1) || (rear == (front - 1) % (size - 1));
	assign 	empty 	= front == -1;

	task enqueue(lsq_t data_in);
		ready 				<= 0;
		// full
		if((front == 0 && rear == size - 1) || (rear == (front - 1) % (size - 1))) begin 
			return;
		end 
		// first element
		else if(front == -1) begin 
			front 			<= 0;
			rear 			<= 0;
			arr[0]			<= data_in;
		end
		// otherwise
		else begin 
			rear 					<= (rear + 1) % size;
			arr[(rear + 1) % size] 	<= data_in; 
		end 
	endtask : enqueue

	task dequeue();
		// empty
		if(front == -1) begin
			ready 				<= 0;
			return;
		end 
		else begin 
			out 				<= arr[front];
			arr[front] 			<= '{default: 0};
			ready 				<= 1;
			// dequeued the last one
			if(front == rear) begin 
				front 			<= -1;
				rear 			<= -1;
			end
			else begin 
				front 			<= (front + 1) % size;
			end
		end 
	endtask : dequeue

	task endequeue(lsq_t data_in);
		// if empty
		if(front == -1) begin 
			out 					<= data_in;
			ready 					<= 0;
		end 
		else begin 
			out 					<= arr[front];
			front 					<= (front + 1) % size;
			rear 					<= (rear + 1) % size;
			ready 					<= 1;
			if (~full) begin
				arr[front] 				<= '{default: 0};
				arr[(rear + 1) % size] 	<= data_in; 
			end else begin
				arr[front]			<= data_in;
			end
		end 
	endtask


	always_ff @(posedge clk) begin
		if(rst) begin
			front 	<= -1;
			rear 	<= -1;
			ready 	<= 	0;
			for(int i = 0; i < size; i++) begin 
				arr[i] <= '{default: 0};
			end 
		end
		else if(enq && ~deq) begin
			enqueue(in);
		end 
		else if(~enq && deq) begin 
			dequeue();
		end 
		else if(enq && deq) begin 
			endequeue(in);
		end 
	end

endmodule : circular_q


// mem_resp		
// addr	
// deq
// valid	is there a next instruction	
// 00000000000000001111000000000000000000
// prev_addr 	       next_addr
// 

// read
// addr, read_signal

// write
// addr, data, write_enable, write (all 4 are valid)