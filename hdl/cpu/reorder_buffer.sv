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
	output sal_t rdest,
	output logic [3:0] rd_tag,
	output logic reg_ld_instr,
	output rob_t rob_front
);
	rob_t arr [size];
	rob_t temp_in;
	int front, rear;

	logic enq, deq, full, empty;
	assign instr_q_dequeue		= enq;
	assign rob_front 			= front == -1 ? arr[0] : arr[front];

	assign full 				= ((front == 0) && (rear == size - 1)) || (rear == ((front - 1) % (size - 1)));
	assign empty 				= (front == -1);
	assign rd_tag 				= empty ? 0 : (rear + 1) % size;

	assign temp_in.pc_info 		= pci;
	assign temp_in.data 		= 32'hxxxx;
	assign temp_in.rdy 			= 1'b0;
	assign temp_in.valid 		= 1'b1;
	
	task set_load_rs_default();
		load_acu_rs = 1'b0;
		load_br_rs 	= 1'b0;
		load_lsq 	= 1'b0;
		reg_ld_instr= 1'b0;
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
		arr[front] 	<= '{ default: 0, pc_info: '{ opcode: op_imm, default: 0 }};
		rob_broadcast_bus[front] <= '{ default: 0 };
		// dequeued the last one
		if(front == rear) begin 
			front 	<= -1;
			rear 	<= -1;
		end
		else begin 
			front 	<= (front + 1) % size;
		end
	endtask : dequeue

	// Necessary?
	task endequeue(rob_t data_in);
		// if empty, but this case should never occur be able to occur, because then it wouldn't attempt to dequeue
		/*
		if(front == -1)
			rdest 	<= '{4'd0, data_in.rdy, data_in.data};
		*/
		rob_broadcast_bus[front] 	<= '{ default: 0 };
		front 						<= (front + 1) % size;
		rear						<= (rear + 1) % size;
		if (~full) begin
			arr[front]				<= '{ default: 0, pc_info: '{ opcode: op_imm, default: 0 }};
			arr[(rear + 1) % size]	<= data_in;

		end else begin
			arr[front]				<= data_in;
		end
	endtask

	task broadcast(sal_t broadcast_data);
		rob_broadcast_bus[broadcast_data.tag] <= broadcast_data;
	endtask

	always_comb begin
		set_load_rs_default();
		if (~empty) begin
			rdest = '{ front[3:0], arr[front].rdy, arr[front].data };
		end else begin
			rdest = '{ 4'b0, 0, 32'b0 };
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
	end

	always_ff @(posedge clk) begin
		if(rst) begin
			front <= -1;
			rear <= -1;
			for(int i = 0; i < size; i = i + 1) begin 
				arr[i] <= '{ default: 0, pc_info: '{ opcode: op_imm, default: 0 }};
				rob_broadcast_bus[i] <= '{ default: 0 };
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

			for (int i = 0; i < acu_rs_size; i = i + 1) begin
				if (br_rs_o[i].rdy & arr[br_rs_o[i].tag].valid) begin
					arr[br_rs_o[i].tag].data <= br_rs_o[i].data;
					arr[br_rs_o[i].tag].rdy <= 1'b1;
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
