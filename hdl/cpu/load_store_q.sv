import rv32i_types::*;

module load_store_q #(
	parameter width 		= 32,
	parameter lsq_size 		= 8,
	parameter size 			= 8
)
(
	input 	logic 				clk, 
	input 	logic 				rst,
	input	flush_t				flush,
	input 	sal_t 				rob_bus[size],
	input 	rs_t 				reg_entry,
	input 	pci_t 				instruction,
	input 	logic 	[3:0]	 	rob_tag,
	input	rob_t				rob_front,	
	input 	logic 				load_lsq,		
			
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
	logic 	[31:0] 	shift_amt, mem_address_raw, mem_rdata_shifted, mem_wdata_raw;

	// load queue logic
	logic 			lsq_enq, lsq_deq, lsq_empty, lsq_full, lsq_ready, is_lsq_instr, is_ld_instr, is_st_instr;
	lsq_t 			lsq_in, lsq_front, lsq_next_front;
	lsq_t 			arr[lsq_size];
	logic 	[31:0]	ld_byte_en;

	// circular queue signals
	logic 			enq;
	logic 			deq;
	lsq_t 			in;
	logic 			empty;
	logic 			full;
	logic 			ready;
	logic 			flush_stall;
	lsq_t 			out;
	int 			front, rear;
  	int				next_front, next_rear;
	  	
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
	assign 			front_is_valid 		= ~lsq_empty && ~lsq_front.addr_is_tag && ((~front_is_ld && ~lsq_front.data_is_tag) || front_is_ld);		// can be improved, doesn't need to be head
	assign 			next_front_is_ld 	= lsq_next_front.pc_info.opcode == op_load;
	assign 			next_front_is_valid = check_next_valid(next_front) && ~lsq_empty && ~lsq_next_front.addr_is_tag;		// can be improved, doesn't need to be head
	assign 			is_lsq_instr 		= instruction.opcode == op_load || instruction.opcode == op_store;
	assign 			is_ld_instr 		= instruction.opcode == op_load;
	assign 			is_st_instr 		= instruction.opcode == op_store;
	assign			lsq_stall			= lsq_full;

	assign 			remainder 			= mem_address_raw[1:0];
	assign 			shift_amt 			= remainder << 3;
	assign 			mem_rdata_shifted 	= mem_rdata >> shift_amt;
	assign 			mem_wdata 			= mem_wdata_raw << shift_amt;
	assign 			mem_address 		= mem_address_raw & 32'hFFFFFFFC;
	
	function void set_default();
		lsq_enq 		= 0;
		lsq_deq 		= mem_resp & ~flush_stall;
		ld_byte_en 		= 0;
		mem_byte_enable = 0;
		lsq_in 			= '{pc_info: '{opcode: op_imm, default: 0}, default: 0};
		next_front 		= front;
		next_rear 		= rear;
	endfunction : set_default

	function logic check_next_valid(int i);
		if(front <= rear) begin
			return front <= i && i < rear ? 1'b1 : 1'b0;
		end 
		else begin 
			return front <= i || i < rear ? 1'b1 : 1'b0;
		end 
	endfunction

	function logic check_valid_flush_tag(logic [3:0] i);
		if((flush.rear_tag + 1) % size == flush.flush_tag) begin 
			return 1'b1;
		end
		if(flush.front_tag <= flush.flush_tag) begin
			return flush.front_tag <= i && i < flush.flush_tag ? 1'b1 : 1'b0;
		end 
		else begin 
			return flush.front_tag <= i || i < flush.flush_tag ? 1'b1 : 1'b0;
		end 
	endfunction

	function logic [3:0] flush_get_next_rear();
		if(empty) begin 
			return rear;
		end 
		for(int i = 0; i < size; i++) begin 
			if(flush.valid && ~check_valid_flush_tag(arr[(front + i) % size].rd_tag)) begin 
				return (front + i) % size;
			end 
			if ((front + i) % size == rear) begin
				return rear;
			end
		end 
	endfunction

	task flush_lsq();
		// if the front needs to be flushed, flush the whole thing
		if(~check_valid_flush_tag(arr[front].rd_tag)) begin 
			flush_stall <= 1;
		end 
		if (~check_valid_flush_tag(arr[front].rd_tag)) begin
			// reset the whole table
			front 	<= -1;
			rear 	<= -1;
			// mem_read <= 0;
			// mem_write <= 0;
			ready 			<= 	0;
			lsq_out 		<= '{default: 0};
			for (int i = 0; i < size; i++) begin
				arr[i] <= '{pc_info: '{opcode: op_imm, default: 0}, default: 0};
			end
		end
		// else do a weird search
		else begin
			for(int i = 0; i < size; i++) begin 
				if(~check_valid_flush_tag(arr[(front + i) % size].rd_tag))
					arr[(front + i) % size] <= '{pc_info: '{opcode: op_imm, default: 0}, default: 0};
			end
			rear 	<= flush_get_next_rear();
		end
	endtask

	task update_q_reg(int i, sal_t rob_item);
		if(arr[i].addr_is_tag & rob_item.rdy & (rob_item.tag == arr[i].addr[3:0])) begin
			arr[i].addr 		<= arr[i].pc_info.opcode == op_load ? rob_item.data + arr[i].pc_info.i_imm : rob_item.data + arr[i].pc_info.s_imm;
			arr[i].addr_is_tag	<= 1'b0;
		end 
		if(arr[i].data_is_tag & rob_item.rdy && (rob_item.tag == arr[i].data[3:0])) begin
			arr[i].data 		<= rob_item.data;
			arr[i].data_is_tag	<= 1'b0;
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
			lsq_enq 	= load_lsq;
			lsq_in 		= '{pc_info		: 	instruction, 
							rd_tag		: 	rob_tag, 
							data 		: 	32'dx,
							data_is_tag :  	0,
							addr 		: 	reg_entry.busy_r1 ? reg_entry.r1 : reg_entry.r1 + instruction.i_imm,
							addr_is_tag	:	reg_entry.busy_r1
							};
		end

		if(is_st_instr) begin 
			lsq_enq 	= load_lsq;
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
			flush_stall     <=  0;
			for(int i = 0; i < size; i++) begin 
				arr[i] 		<= '{pc_info: '{opcode: op_imm, default: 0}, default: 0};;
			end 
		end 

		else if (flush.valid) begin
			// remove all bad entries in lsq
			flush_lsq();
			
			if(deq) begin 
				dequeue();
			end 
			// prevent memory from overwriting bad lsq entries
			if(lsq_out.rdy) begin 
				lsq_out 		<= '{default: 0};
			end 

			// see if anything new was posted on rob bus
			if (next_rear >= next_front) begin
				for (int i = 0; i <= (next_rear - next_front) && i < size; i++) begin 
					if(check_valid_flush_tag(arr[i + next_front].rd_tag)) begin 
						if(arr[i + next_front].addr_is_tag && check_valid_flush_tag(arr[i + next_front].addr[3:0]));
							update_q_reg(i + next_front, rob_bus[arr[i + next_front].addr[3:0]]);
						if(arr[i + next_front].data_is_tag && check_valid_flush_tag(arr[i + next_front].data[3:0]));
							update_q_reg(i + next_front, rob_bus[arr[i + next_front].data[3:0]]);
					end
				end
			end 
			else begin 
				for (int i = 0; i < (size - next_front + 1) && i < size; i++) begin 
					if(check_valid_flush_tag(arr[i + next_front].rd_tag)) begin 
						if(arr[i + next_front].addr_is_tag && check_valid_flush_tag(arr[i + next_front].addr[3:0]));
							update_q_reg(i + next_front, rob_bus[arr[i + next_front].addr[3:0]]);
						if(arr[i + next_front].data_is_tag && check_valid_flush_tag(arr[i + next_front].data[3:0]));
							update_q_reg(i + next_front, rob_bus[arr[i + next_front].data[3:0]]);
					end
				end
		  
				for (int i = 0; i <= next_rear && i < size; i++) begin
					if(check_valid_flush_tag(arr[i + next_front].rd_tag)) begin 
						if(arr[i + next_front].addr_is_tag && check_valid_flush_tag(arr[i + next_front].addr[3:0]));
							update_q_reg(i, rob_bus[arr[i].addr[3:0]]);
						if(arr[i + next_front].data_is_tag && check_valid_flush_tag(arr[i + next_front].data[3:0]));
							update_q_reg(i, rob_bus[arr[i].data[3:0]]);
					end
					
				end
			end

			if(mem_resp) begin
				mem_address_raw 	<= lsq_next_front.addr; 

				// read case
				if(mem_read && check_valid_flush_tag(lsq_front.rd_tag)) begin
					// arr[front].data 	<= ld_byte_en;
					lsq_out	 		<= '{tag: lsq_front.rd_tag, rdy: 1'b1, data: ld_byte_en};	// broadcast on read
				end
				// read case (next instruction)
				mem_read 			<= next_front_is_ld && next_front_is_valid && check_valid_flush_tag(lsq_next_front.rd_tag);

				// write case (next instruction)
				mem_write 			<= (~next_front_is_ld && next_front_is_valid) && (lsq_next_front.rd_tag == flush.front_tag && check_valid_flush_tag(lsq_next_front.rd_tag));
				mem_wdata_raw 		<= lsq_next_front.data;
				if(mem_write  && check_valid_flush_tag(lsq_front.rd_tag)) begin // the current instruction
					lsq_out 		<= '{tag: lsq_front.rd_tag, rdy: 1'b1, data: lsq_front.data}; // broadcast write done
				end 
			end 
			else if(~mem_read && ~mem_write && front_is_valid) begin 					// we can now operate
				mem_address_raw 	<= lsq_front.addr; 
	
				// read	
				mem_read 			<= front_is_ld && check_valid_flush_tag(lsq_front.rd_tag); 
		
				// write	
				mem_write 			<= ~front_is_ld && (lsq_front.rd_tag == flush.front_tag) && check_valid_flush_tag(lsq_front.rd_tag); 
				mem_wdata_raw 		<= lsq_front.data;
			end 

		end else begin 
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
				for (int i = 0; i <= (next_rear - next_front) && i < size; i++) begin 
					update_q_reg(i + next_front, rob_bus[arr[i + next_front].addr[3:0]]);
					update_q_reg(i + next_front, rob_bus[arr[i + next_front].data[3:0]]);
				end 
					
			end 
			else begin 
				for (int i = 0; i < (size - next_front + 1) && i < size; i++) begin 
					update_q_reg(i + next_front, rob_bus[arr[i + next_front].addr[3:0]]);
					update_q_reg(i + next_front, rob_bus[arr[i + next_front].data[3:0]]);
				end 
		  
				for (int i = 0; i <= next_rear && i < size; i++) begin 
					update_q_reg(i, rob_bus[arr[i].addr[3:0]]);
					update_q_reg(i, rob_bus[arr[i].data[3:0]]);
				end 
			end

			if(mem_resp) begin 
				if(flush_stall) begin 
					flush_stall <= 0;
					mem_read 	<= 0;
					mem_write 	<= 0;
				end 
				else begin
					mem_address_raw 	<= lsq_next_front.addr; 

					// read case
					if(mem_read) begin
						// arr[front].data 	<= ld_byte_en;
						lsq_out	 		<= '{tag: lsq_front.rd_tag, rdy: 1'b1, data: ld_byte_en};	// broadcast on read
					end
					mem_read 			<= next_front_is_ld && next_front_is_valid;

					// write case (next instruction)
					mem_write 			<= (~next_front_is_ld && next_front_is_valid) && (lsq_next_front.rd_tag == flush.front_tag);
					mem_wdata_raw 		<= lsq_next_front.data;
					if(mem_write) begin // the current instruction
						lsq_out 		<= '{tag: lsq_front.rd_tag, rdy: 1'b1, data: lsq_front.data};
					end 
				end 
			end 
			else if(~mem_read && ~mem_write && front_is_valid) begin 					// we can now operate
				mem_address_raw 	<= lsq_front.addr; 
	
				// read	
				mem_read 			<= front_is_ld;
		
				// write	
				mem_write 			<= ~front_is_ld && (lsq_front.rd_tag == flush.front_tag); 
				mem_wdata_raw 		<= lsq_front.data;
			end 
		end 
	end 

endmodule : load_store_q
