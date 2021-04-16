import rv32i_types::*;

module load_store_q #(
	parameter width 		= 32,
	parameter lsq_size 		= 8,
	parameter size 			= 8
)
(
	input 	logic 				clk, 
	input 	logic 				rst,
	input 	sal_t 				rob_bus[size],
	input 	rs_t 				reg_entry,
	input 	pci_t 				instruction,
	input 	logic 	[3:0]	 	rob_tag,			
			
	output 	logic 				lsq_stall,
	output 	sal_t 				lsq_out,

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
	logic 			front_is_ld, front_is_valid, next_front_is_ld, next_front_is_valid;
	logic 	[1:0] 	remainder;
	logic 	[31:0] 	shift_amt, mem_address_raw, mem_rdata_shifted;

	// load queue logic
	logic 			lsq_enq, lsq_deq, lsq_empty, lsq_full, lsq_ready, is_lsq_instr, is_ld_instr, is_st_instr;
	lsq_t 			lsq_in, lsq_front, lsq_next_front;
	lsq_t 			arr[lsq_size];
	logic 	[31:0]	ld_byte_en;

	// circular queue signals
	logic 				enq;
	logic 				deq;
	lsq_t 				in;
	logic 				empty;
	logic 				full;
	logic 				ready;
	lsq_t 				out;
	int 				front, rear;
  	int					next_front, next_rear;
	  	
	assign 			enq 				= lsq_enq;
	assign 			deq 				= lsq_deq;
	assign 			in 					= lsq_in;
	assign 			lsq_empty 			= empty;
	assign 			lsq_full 			= full;
	assign 			lsq_ready 			= ready;
	assign 			lsq_front 			= out;
	assign 			lsq_next_front 		= arr[next_front];
	assign 			full 				= (front == 0 && rear == size - 1) || (rear == (front - 1) % (size - 1));
	assign 			empty 				= front == -1;
	assign			out 				= enq && deq && front == -1 ? in : arr[front];


	assign 			front_is_ld 		= lsq_front.pc_info.opcode == op_load;
	assign 			front_is_valid 		= ~lsq_empty && ~lsq_front.addr_is_tag;		// can be improved, doesn't need to be head
	assign 			next_front_is_ld 	= lsq_next_front.pc_info.opcode == op_load;
	assign 			next_front_is_valid = ~lsq_empty && ~lsq_next_front.addr_is_tag;		// can be improved, doesn't need to be head
	assign 			is_lsq_instr 		= instruction.opcode == op_load || instruction.opcode == op_store;
	assign 			is_ld_instr 		= instruction.opcode == op_load;
	assign 			is_st_instr 		= instruction.opcode == op_store;
	assign			lsq_stall			= lsq_full;

	assign 			remainder 			= mem_address_raw[1:0];
	assign 			shift_amt 			= remainder << 3;
	assign 			mem_rdata_shifted 	= mem_rdata >> shift_amt;
	assign 			mem_address 		= mem_address_raw & 32'hFFFFFFFC;
	
	function void set_default();
		lsq_enq 		= 0;
		lsq_deq 		= mem_resp;
		ld_byte_en 		= 0;
		mem_byte_enable = 0;
		lsq_in 			= '{pc_info: '{opcode: op_imm, default: 0}, default: 0};
		next_front 		= front;
		next_rear 		= rear;
	endfunction : set_default

	task update_q_reg(int i, sal_t rob_item);
		if(arr[i].addr_is_tag & rob_item.rdy) begin
			arr[i].addr 		<= rob_item.data + arr[i].pc_info.i_imm;
			arr[i].addr_is_tag	<= 1'b0;
		end 
	endtask

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
			// out 				<= arr[front];
			arr[front] 			<= '{pc_info: '{opcode: op_imm, default: 0}, default: 0};;
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
			// out 					<= data_in;
			ready 					<= 0;
		end 
		else begin 
			// out 					<= arr[front];
			front 					<= (front + 1) % size;
			rear 					<= (rear + 1) % size;
			ready 					<= 1;
			if (~full) begin
				arr[front] 				<= '{pc_info: '{opcode: op_imm, default: 0}, default: 0};;
				arr[(rear + 1) % size] 	<= data_in; 
			end else begin
				arr[front]			<= data_in;
			end
		end 
	endtask

	always_comb begin 
		set_default();
		if(is_ld_instr) begin 
			lsq_enq 	= 1;
			lsq_in 		= '{pc_info		: 	instruction, 
							rd_tag		: 	rob_tag, 
							data 		: 	32'dx,
							data_is_tag :  	0,
							addr 		: 	reg_entry.busy_r1 ? reg_entry.r1 : reg_entry.r1 + instruction.i_imm,
							addr_is_tag	:	reg_entry.busy_r1
							};
		end

		if(is_st_instr) begin 
			lsq_enq 	= 1;
			lsq_in		= '{pc_info		: 	instruction, 
							rd_tag		: 	rob_tag, 
							data 		: 	reg_entry.r2,
							data_is_tag : 	reg_entry.busy_r2,
							addr 		: 	reg_entry.busy_r1 ? reg_entry.r1 : reg_entry.r1 + instruction.s_imm,
							addr_is_tag	:	reg_entry.busy_r1
							};
		end 

		unique case(load_funct3_t'(lsq_front.pc_info.funct3))
			lb	: 	ld_byte_en = {{25{mem_rdata_shifted[7]}}, mem_rdata_shifted[6:0]};
			lh	: 	ld_byte_en = {{17{mem_rdata_shifted[15]}}, mem_rdata_shifted[14:0]};
			lw	: 	ld_byte_en = mem_rdata_shifted;
			lbu	: 	ld_byte_en = {24'd0, mem_rdata_shifted[7:0]};
			lhu	: 	ld_byte_en = {16'd0, mem_rdata_shifted[15:0]};
			default: ;
		endcase 

		unique case(store_funct3_t'(lsq_front.pc_info.funct3))
			sb	: 	mem_byte_enable = 4'b0001 << remainder;
			sh	: 	mem_byte_enable = 4'b0011 << remainder;
			sw	: 	mem_byte_enable = 4'b1111;
			default: ;
		endcase // store_funct3

		if(enq && ~deq) begin //enqueue
			if((front == 0 && rear == size - 1) || (rear == (front - 1) % (size - 1))) begin 
			end 
			// first element
			else if(front == -1) begin 
				next_front 		= 0;
				next_rear 		= 0;
			end
			// otherwise
			else begin 
				next_rear 		= (rear + 1) % size;
			end 
		end 
		else if(~enq && deq) begin //dequeue
			if(front == -1) begin
			end 
			else begin
				// dequeued the last one
				if(front == rear) begin 
					next_front 		= 0;
					next_rear 		= 0;
				end
				else begin 
					next_front 		= (front + 1) % size;
				end
			end 
		end 
		else if(enq && deq) begin  //endequeue
			// if empty
			if(front == -1) begin
			end 
			else begin 
				next_front 			= (front + 1) % size;
				next_rear 			= (rear + 1) % size;
			end 
		end 
	end 

	always_ff @(posedge clk) begin 
		if(rst) begin 
			mem_read 		<= 0;
			mem_write 		<= 0;
			front 			<= -1;
			rear 			<= -1;
			ready 			<= 	0;
			lsq_out 		<= '{default: 0};
			for(int i = 0; i < size; i++) begin 
				arr[i] 		<= '{pc_info: '{opcode: op_imm, default: 0}, default: 0};;
			end 
		end 
		else begin 
			if(enq && ~deq) begin
				enqueue(in);
			end 
			else if(~enq && deq) begin 
				dequeue();
			end 
			else if(enq && deq) begin 
				endequeue(in);
			end 

			if(lsq_out.rdy) begin 
				lsq_out 		<= '{default: 0};
			end 

			// see if anything new was posted on rob bus
			if (next_rear >= next_front) begin
				for (int i = 0; i <= (next_rear - next_front) && i < 8; i++)
					update_q_reg(i + next_front, rob_bus[arr[i + next_front].addr[3:0]]);
			end 
			else begin 
				for (int i = 0; i < (size - next_front + 1) && i < 8; i++)
					update_q_reg(i + next_front, rob_bus[arr[i + next_front].addr[3:0]]);
		  
				for (int i = 0; i <= next_rear && i < 8; i++)
					update_q_reg(i, rob_bus[arr[i].addr[3:0]]);
			end

			if(mem_resp) begin
				mem_address_raw 	<= lsq_next_front.addr; 
				// we are doing the dequeue of the old instruction, but the front is still the old instruction (only updated next cycle)
				// we should be looking at the addr of the next valid instruction

				// if (~arr[next_front].addr_is_tag) begin
				// 	mem_address_raw <= arr[next_front].addr;
				// end else begin
				// 	// what is the expected behavior here?
				// 	mem_address_raw <= 32'bx; // dont read anything?
				// end

				// read case
				if(mem_read) begin
					// arr[front].data 	<= ld_byte_en;
					lsq_out	 		<= '{tag: lsq_front.rd_tag, rdy: 1'b1, data: ld_byte_en};	// broadcast on read
				end
				mem_read 			<= next_front_is_ld && next_front_is_valid;

				// write case
				mem_write 			<= ~next_front_is_ld && next_front_is_valid;
				mem_wdata 			<= lsq_next_front.data;
				if(mem_write) begin 
					lsq_out 		<= '{tag: lsq_front.rd_tag, rdy: 1'b1, data: lsq_front.data};
				end 
				
			end 
			else if(~mem_read && ~mem_write && front_is_valid) begin 					// we can now operate
				mem_address_raw 	<= lsq_front.addr; 
	
				// read	
				mem_read 			<= front_is_ld; 
		
				// write	
				mem_write 			<= ~front_is_ld; 
				mem_wdata 			<= lsq_front.data;
			end 
		end 
	end 

endmodule : load_store_q
