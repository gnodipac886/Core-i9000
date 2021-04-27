import rv32i_types::*;

module reorder_buffer #(
	parameter width 		= 32,
	parameter size 			= 8,
	parameter br_rs_size 	= 8,
	parameter acu_rs_size 	= 8,
	parameter lsq_size 		= 8
)
(
	input logic	clk,
	input logic	rst,
	input logic	instr_q_empty,
	input logic instr_mem_resp,
	input pci_t pci,
	input logic stall_br,
	input logic stall_acu,
	input logic stall_lsq,
	input sal_t	br_rs_o [br_rs_size],
	input sal_t acu_rs_o [acu_rs_size],
	input sal_t lsq_o,
	

	output logic instr_q_dequeue,
	output logic load_br_rs,
	output logic load_acu_rs,
	output logic load_lsq,
	output sal_t rob_broadcast_bus [size],
	output sal2_t rdest[size],
	output logic [4:0] rd_bus[size],
	output logic [3:0] rd_tag,
	output logic reg_ld_instr,
	output rob_t rob_front,

	output logic br_result, // high if taking branch, low if not taking
	output logic [width-1:0] pc_result, // address of branch instruction at top of ROB 
	output logic pc_result_load, // high if dequeueing a branch 

	// output logic flush,
	output logic [width-1:0] flush_pc,
	output flush_t flush
);
	rob_t arr [size];
	rob_t temp_in;
	int front, rear;
	int num_deq, flush_tag;

	logic enq, deq, full, empty;
	assign instr_q_dequeue		= enq;
	assign rob_front 			= front == -1 ? arr[0] : arr[front];

	assign full 				= ((front == 0) && (rear == size - 1)) || (rear == ((front - 1) % (size - 1)));
	assign empty 				= (front == -1);
	assign rd_tag 				= empty ? 0 : (rear + 1) % size;

    assign flush.flush_tag      = flush_tag[3:0];
	assign flush.front_tag 		= front[3:0];
    assign flush.rear_tag       = rear[3:0];

	assign temp_in.pc_info 		= pci;
	assign temp_in.data 		= 32'hxxxx;
	assign temp_in.rdy 			= 1'b0;
	assign temp_in.valid 		= 1'b1;
	
	task set_load_rs_default();
		load_acu_rs 	= 1'b0;
		load_br_rs 		= 1'b0;
		load_lsq 		= 1'b0;
		reg_ld_instr	= 1'b0;
		flush.valid		= 1'b0;
		flush_pc		= 32'b0;
		br_result		= 1'b0;
		pc_result		= 32'b0;
		pc_result_load 	= 1'b0;
		num_deq			= 0;
		flush_tag 		= 0;  // index of start of flush to rear of rob
		for(int i = 0; i < size; i++) begin
			rdest[i] 	= '{ tag: 4'b0, rdy: 0, data: 32'b0, pc_info: '{ opcode: op_imm, default: 0 } };
			rd_bus[i] 	= arr[i].pc_info.rd;
		end
	endtask
	
	task enqueue(rob_t data_in);
		// Check if full before sending dequeue signal to instr_q
		// first element
		if (empty) begin 
			front 	<= 0;
			rear 	<= 0;
			arr[0]	<= data_in;
			// rd_tag	<= 0;
		end
		// otherwise
		else begin 
			rear 	<= (rear + 1) % size;
			// rd_tag	<= (rear + 1) % size;
			arr[(rear + 1) % size] <= data_in; 
		end
	endtask : enqueue

	task dequeue();
		// Check if empty before dequeuing
		for(int i = 0; i < num_deq && i < size; i++) begin 
			arr[(front + i) % size] 				<= '{ default: 0, pc_info: '{ opcode: op_imm, default: 0 }};
			rob_broadcast_bus[(front + i) % size] 	<= '{ default: 0 };
		end 
		// dequeued the last one
		if(front == rear || front + num_deq > rear) begin 
			front 	<= -1;
			rear 	<= -1;
		end
		else begin 
			front 	<=  (front + num_deq) % size;
		end
	endtask : dequeue

	// Necessary?
	task endequeue(rob_t data_in);
		// if empty, but this case should never occur be able to occur, because then it wouldn't attempt to dequeue
		/*
		if(front == -1)
			rdest 	<= '{4'd0, data_in.rdy, data_in.data};
		*/
		if(num_deq == 1 && full) begin 
			rob_broadcast_bus[front] 	<= '{ default: 0 };
			arr[front]					<= data_in;
		end 
		else begin 
			for(int i = 0; i < num_deq && i < size; i++) begin 
				rob_broadcast_bus[(i + front) % size] 	<= '{ default: 0 };
				arr[(i + front) % size]					<= '{ default: 0, pc_info: '{ opcode: op_imm, default: 0 }};
			end 
			arr[(rear + 1) % size]	<= data_in;
		end 
		front 						<= (front + num_deq) % size;
		rear						<= (rear + 1) % size;
	endtask

	task broadcast(sal_t broadcast_data);
		rob_broadcast_bus[broadcast_data.tag] <= broadcast_data;
	endtask

	task flush_rob();
		for(int i = 0; i < size; i++) begin 
			if(~check_valid_flush_tag((flush_tag + i) % size)) begin
				arr[(flush_tag + i) % size] <= '{ default: 0, pc_info: '{ opcode: op_imm, default: 0 }};
				rob_broadcast_bus[(flush_tag + i) % size] <= '{default: 0};
			end
		end
		rear 	<= (flush_tag == 0) ? 7 : (flush_tag - 1);
	endtask

	function logic check_valid_flush_tag(logic [3:0] i);
		if(front <= flush_tag) begin
			return front <= i && i < flush_tag ? 1'b1 : 1'b0;
		end 
		else begin 
			return front <= i || i < flush_tag ? 1'b1 : 1'b0;
		end 
	endfunction

	always_comb begin
		set_load_rs_default();
		if (rear >= front) begin
			for (int i = 0; i <= (rear - front) && i < size; i++) begin 
				if (~empty) begin 
					if(~arr[i + front].rdy | ~arr[i + front].valid)
						break;
					if(arr[i + front].pc_info.opcode == op_br || arr[i + front].pc_info.opcode == op_store) begin 
						num_deq++;
						continue;
					end 
					else if (arr[i + front].pc_info.opcode == op_jalr)
						rdest[i + front] = '{ (i[3:0] + front[3:0]), arr[i + front].rdy, arr[i + front].pc_info.pc + 4, arr[i+front].pc_info };
					else // FIX JALR RDEST[i + front] HERE
						rdest[i + front] = '{ (i[3:0] + front[3:0]), arr[i + front].rdy, arr[i + front].data, arr[i+front].pc_info };
				end else
					rdest[i + front] = '{ 4'b0, 0, 32'b0, '{ opcode: op_imm, default: 0 } };
				num_deq++;
			end 
		end 
		else begin 
			for (int i = 0; i < (size - front) && i < size; i++) begin 
				if (~empty) begin 
					if(~arr[i + front].rdy | ~arr[i + front].valid)
						break;
					if(arr[i + front].pc_info.opcode == op_br || arr[i + front].pc_info.opcode == op_store) begin 
						num_deq++;
						continue;
					end 
					else if (arr[i + front].pc_info.opcode == op_jalr)
						rdest[i + front] = '{ (i[3:0] + front[3:0]), arr[i + front].rdy, arr[i + front].pc_info.pc + 4, arr[i+front].pc_info };
					else // FIX JALR RDEST[i + front] HERE
						rdest[i + front] = '{ (i[3:0] + front[3:0]), arr[i + front].rdy, arr[i + front].data, arr[i+front].pc_info };
				end else
					rdest[i + front] = '{ 4'b0, 0, 32'b0, '{ opcode: op_imm, default: 0 } };
				num_deq++;
			end 
		 
		 	if(arr[(num_deq + front) % size].rdy & arr[(num_deq + front) % size].valid) begin 
		 		for (int i = 0; i <= rear && i < size; i++) begin 
		 			if (~empty) begin
		 				if(~arr[i].rdy | ~arr[i].valid)
							break;
		 				if(arr[i].pc_info.opcode == op_br || arr[i].pc_info.opcode == op_store) begin 
		 					num_deq++;
		 					continue;
		 				end 
						else if (arr[i].pc_info.opcode == op_jalr)
		 					rdest[i] = '{ (i[3:0] + front[3:0]), arr[i].rdy, arr[i].pc_info.pc + 4 , arr[i].pc_info};
		 				else // FIX JALR RDEST[i] HERE
		 					rdest[i] = '{ (i[3:0] + front[3:0]), arr[i].rdy, arr[i].data, arr[i].pc_info };
		 			end else
		 				rdest[i] = '{ 4'b0, 0, 32'b0, '{ opcode: op_imm, default: 0 }};
		 			num_deq++;
		 		end 
		 	end 
		end

		// Dequeue if front is ready and valid
		deq = (~empty && arr[front].rdy == 1'b1 && arr[front].valid == 1'b1);
		// Enqueue if not full and instr_q is not empty
		enq = 1'b0;
		if ((pci.opcode == op_br) || (pci.opcode == op_jal) || (pci.opcode == op_jalr)) begin
			if (~stall_br) begin
				enq = (~full | (full & deq)) && (~instr_q_empty) || (~full | (full & deq)) && instr_q_empty && instr_mem_resp;
			end
		end 
		else if ((pci.opcode == op_lui) || (pci.opcode == op_load) || (pci.opcode == op_store)) begin
			if (~stall_lsq) begin
				enq = (~full | (full & deq)) && (~instr_q_empty) || (~full | (full & deq)) && instr_q_empty && instr_mem_resp;
			end
		end 
		else if ((pci.opcode == op_auipc) || (pci.opcode == op_imm) || (pci.opcode == op_reg)) begin
			if (~stall_acu) begin
				enq = (~full | (full & deq)) && (~instr_q_empty) || (~full | (full & deq)) && instr_q_empty && instr_mem_resp;
			end
		end

		if (enq) begin
			unique case (pci.opcode)
				op_br	: load_br_rs= 1'b1;

				op_jal	: begin 
					load_br_rs 		= 1'b1;
					reg_ld_instr 	= 1'b1;
				end 

				op_jalr	: begin 
					load_br_rs 		= 1'b1;
					reg_ld_instr 	= 1'b1;
				end 

				op_lui	: begin 
					load_lsq 		= 1'b1;
					reg_ld_instr 	= 1'b1;
				end 

				op_load	: begin 
					load_lsq 		= 1'b1;
					reg_ld_instr 	= 1'b1;
				end 

				op_store: load_lsq 	= 1'b1;

				op_imm	: begin 
					load_acu_rs 	= 1'b1;
					reg_ld_instr 	= 1'b1;
				end 

				op_reg	: begin 
					load_acu_rs 	= 1'b1;
					reg_ld_instr 	= 1'b1;
				end 

				op_auipc: begin 
					load_acu_rs 	= 1'b1;
					reg_ld_instr 	= 1'b1;
				end 

				default :;
			endcase
		end

		// branch flushing logic
		// ADD LOGIC FOR JALR HERE!!!!!!!!!!!!!!!!!!!
		for (int i = 0; i < br_rs_size; i++) begin
			if (br_rs_o[i].rdy & arr[br_rs_o[i].tag].valid) begin
				if(arr[br_rs_o[i].tag].pc_info.is_br_instr) begin 
					br_result 		= br_rs_o[i].data[0];
					pc_result 		= arr[br_rs_o[i].tag].pc_info.pc;
					pc_result_load 	= 1'b1;
					if(br_rs_o[i].data[0] != arr[br_rs_o[i].tag].pc_info.br_pred) begin 
						flush.valid 	= 1'b1;
						flush_tag 		= (br_rs_o[i].tag + 1) % size;
						flush_pc		= br_rs_o[i].data[0] ? arr[br_rs_o[i].tag].pc_info.branch_pc : arr[br_rs_o[i].tag].pc_info.pc + 4;
					end 
				end 
				else if(arr[br_rs_o[i].tag].pc_info.opcode == op_jalr) begin 
					flush.valid 	= 1'b1;
					flush_tag 		= (br_rs_o[i].tag + 1) % size;
					flush_pc		= br_rs_o[i].data;
				end 
			end
		end
	end

	always_ff @(posedge clk) begin
		if(rst) begin
			front <= -1;
			rear <= -1;
			for(int i = 0; i < size; i = i + 1) begin 
				arr[i] <= '{ default: 0, pc_info: '{ opcode: op_imm, default: 0 }};
				rob_broadcast_bus[i] <= '{ default: 0 };
			end 
		end else if(flush.valid) begin
			flush_rob(); 
			if(deq)
				dequeue(); 

			// Update rob entry for incoming completed operation
			// alu
			for (int i = 0; i < acu_rs_size; i = i + 1) begin
				if (acu_rs_o[i].rdy & arr[acu_rs_o[i].tag].valid & check_valid_flush_tag(acu_rs_o[i].tag)) begin
					arr[acu_rs_o[i].tag].data <= acu_rs_o[i].data;
					arr[acu_rs_o[i].tag].rdy <= 1'b1;
					broadcast(acu_rs_o[i]);
				end
			end

			for (int i = 0; i < br_rs_size; i = i + 1) begin
				if (br_rs_o[i].rdy & arr[br_rs_o[i].tag].valid & check_valid_flush_tag(br_rs_o[i].tag)) begin
					arr[br_rs_o[i].tag].rdy <= 1'b1;
					if(arr[br_rs_o[i].tag].pc_info.opcode == op_jal) begin
						arr[br_rs_o[i].tag].data <= arr[br_rs_o[i].tag].pc_info.pc + 4;
						broadcast('{tag: br_rs_o[i].tag, rdy: 1'b1, data: arr[br_rs_o[i].tag].pc_info.pc + 4});
					end else begin
						arr[br_rs_o[i].tag].data <= br_rs_o[i].data;
					end
					if(arr[br_rs_o[i].tag].pc_info.opcode == op_jalr)
						broadcast(br_rs_o[i]);
				end
			end

			if(lsq_o.rdy & check_valid_flush_tag(lsq_o.tag)) begin 
				arr[lsq_o.tag].data <= lsq_o.data;
				arr[lsq_o.tag].rdy 	<= 1'b1;
				broadcast(lsq_o);
			end 
		end else begin
			if(enq && ~deq) begin
				enqueue(temp_in);
			end 
			else if(~enq && deq) begin 
				dequeue();
			end 
			else if(enq && deq) begin 
				endequeue(temp_in);
			end

			// Update rob entry for incoming completed operation
			// alu
			for (int i = 0; i < acu_rs_size; i = i + 1) begin
				if (acu_rs_o[i].rdy & arr[acu_rs_o[i].tag].valid) begin
					arr[acu_rs_o[i].tag].data <= acu_rs_o[i].data;
					arr[acu_rs_o[i].tag].rdy <= 1'b1;
					broadcast(acu_rs_o[i]);
				end
			end

			for (int i = 0; i < br_rs_size; i = i + 1) begin
				if (br_rs_o[i].rdy & arr[br_rs_o[i].tag].valid & check_valid_flush_tag(br_rs_o[i].tag)) begin
					arr[br_rs_o[i].tag].rdy <= 1'b1;
					if(arr[br_rs_o[i].tag].pc_info.opcode == op_jal) begin
						arr[br_rs_o[i].tag].data <= arr[br_rs_o[i].tag].pc_info.pc + 4;
						broadcast('{tag: br_rs_o[i].tag, rdy: 1'b1, data: arr[br_rs_o[i].tag].pc_info.pc + 4});
					end else begin
						arr[br_rs_o[i].tag].data <= br_rs_o[i].data;
					end
					if(arr[br_rs_o[i].tag].pc_info.opcode == op_jalr)
						broadcast(br_rs_o[i]);
				end
			end

			if(lsq_o.rdy) begin 
				arr[lsq_o.tag].data <= lsq_o.data;
				arr[lsq_o.tag].rdy 	<= 1'b1;
				broadcast(lsq_o);
			end 

			// turn off broadcast bus after a cycle
			// for(int i = 0; i < acu_rs_size; i++) begin 
			// 	if(rob_broadcast_bus[i].rdy) 
			// 		rob_broadcast_bus[i] <= '{ default: 0 };
			// end 
		end
	end
endmodule : reorder_buffer
