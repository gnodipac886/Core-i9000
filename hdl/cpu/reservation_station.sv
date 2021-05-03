import rv32i_types::*;

module reservation_station #(parameter size = 15, parameter rob_size = 15)
(
		input logic clk,
		input logic rst,
		// input logic flush,
		input flush_t flush,

		input logic load, //from ROB, load_alu_rs signal

		// from instruction queue -> RS and instruction queue -> ROB -> RS, on issuing new instruction
		// need elaboration from eric what signals im getting from ROB and IQ
		// maybe can recieve a rs_t
		
		// input rv32i_opcode opcode, // from ROB
		// input logic[31:0] r1, // from regfile
		// input logic[31:0] r2, // from regfile
		// input logic tag_r1, // from regfile, tell if r1 is a tag or a value
		// input logic tag_r2, // from regfile, tell if r2 is a tag or a value
		// input logic[3:0] tag, // from ROB

		// inputs
		input rs_t input_r, //regfile
		input logic[3:0] tag, // from ROB
		input pci_t pci, // from ROB

		input sal_t broadcast_bus[size], // after computation is done, coming back from alu
		input sal_t rob_broadcast_bus[size], // after other rs is done, send data from ROB to rs

		output rs_t data[size], // all the reservation stations, to the alu
		output logic acu_operation[size],
		output logic[size-1:0] ready, // if both values are not tags, flip this ready bit to 1
		output logic[3:0] num_available // do something if the number of available reservation stations are 0
);

	logic[4:0] next_rs;
	int index = -1;

	// task set_default(int idx);
	// 	data[idx] <= '{default: 0};
	// 	acu_operation[idx] <= 1'b0;
	// endtask : set_default


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

	task flush_rs();
		// go through all the rs
		// if the rs is within check_valid_flush_tag, set to default

		for (int i = 0; i < size; i++) begin
			if (~check_valid_flush_tag(data[i].tag)) begin
				data[i] <= '{cmp_opcode :cmp_beq, alu_opcode:alu_add, valid: 0, default: '0};
			end
		end

		if(load) begin 
			data[next_rs] <= '{cmp_opcode :cmp_beq, alu_opcode:alu_add, valid: 0, default: '0};
		end 

	endtask
	
	always_ff @(posedge clk)
	begin
		if (rst)
		begin
			// erase the data object (set to defaults)
			for (int idx = 0; idx < size; idx++) 
			begin 
				// clear..
				// set_default(idx);
				data[idx] <= '{cmp_opcode :cmp_beq, alu_opcode:alu_add, valid: 0, default: '0};
				acu_operation[idx] <= 1'b0;
			end
		end

		else if (flush.valid) begin
			flush_rs();
		end

		else if (load)
		begin
			// set all the fields for the new struct
			if (num_available != 5'd0) 
			begin
				// load..
				data[next_rs].tag <= tag;
				data[next_rs].alu_opcode <= alu_ops'(pci.funct3);
				data[next_rs].cmp_opcode <= cmp_ops'(pci.funct3);
				data[next_rs].valid <= 1'b1;
				data[next_rs].funct7 <= pci.opcode == op_reg ? pci.funct7 : 0;
				unique case (pci.opcode) 
					op_jal: begin 
						data[next_rs].alu_opcode <= alu_add;
						data[next_rs].busy_r1 <= 1'b0;
						data[next_rs].busy_r2 <= 1'b0;
						data[next_rs].r1 <= pci.pc;
						data[next_rs].r2 <= pci.j_imm;
						acu_operation[next_rs] <= 1'b0;
						
					end 
					op_jalr: begin 
						data[next_rs].alu_opcode <= alu_add;
						data[next_rs].busy_r1 <= input_r.busy_r1;
						data[next_rs].busy_r2 <= 1'b0;
						data[next_rs].r1 <= input_r.r1;
						data[next_rs].r2 <= pci.i_imm;
						acu_operation[next_rs] <= 1'b0;
					end 
					op_br: begin 
						data[next_rs].busy_r1 <= input_r.busy_r1;
						data[next_rs].busy_r2 <= input_r.busy_r2;
						data[next_rs].r1 <= input_r.r1;
						data[next_rs].r2 <= input_r.r2;
						acu_operation[next_rs] <= 1'b1;
					end 
					op_lui: begin
						data[next_rs].alu_opcode <= alu_add;
						data[next_rs].busy_r1 <= 1'b0;
						data[next_rs].busy_r2 <= 1'b0;
						data[next_rs].r1 <= pci.u_imm;
						data[next_rs].r2 <= 32'b0;
						acu_operation[next_rs] <= 1'b0;
					end
					op_auipc: begin
						data[next_rs].alu_opcode <= alu_add;
						data[next_rs].busy_r1 <= 1'b0;
						data[next_rs].busy_r2 <= 1'b0;
						data[next_rs].r1 <= pci.pc;
						data[next_rs].r2 <= pci.u_imm;
						acu_operation[next_rs] <= 1'b0;
					end
					op_reg: begin
						data[next_rs].busy_r1 <= input_r.busy_r1;
						data[next_rs].busy_r2 <= input_r.busy_r2;
						data[next_rs].r1 <= input_r.r1;
						data[next_rs].r2 <= input_r.r2;
						if (arith_funct3_t'(pci.funct3) == slt) begin
							data[next_rs].cmp_opcode <= cmp_blt;
							acu_operation[next_rs] <= 1'b1;
						end else if (arith_funct3_t'(pci.funct3) == sltu) begin
							data[next_rs].cmp_opcode <= cmp_bltu;
							acu_operation[next_rs] <= 1'b1;
						end else begin
							data[next_rs].cmp_opcode <= cmp_ops'(pci.funct3);
							acu_operation[next_rs] <= 1'b0;
						end
					end
					op_imm: begin
						data[next_rs].busy_r1 <= input_r.busy_r1;
						data[next_rs].busy_r2 <= 1'b0;
						data[next_rs].r1 <= input_r.r1;
						data[next_rs].r2 <= pci.i_imm;
						if (arith_funct3_t'(pci.funct3) == slt) begin
							data[next_rs].cmp_opcode <= cmp_blt;
							acu_operation[next_rs] <= 1'b1;
						end else if (arith_funct3_t'(pci.funct3) == sltu) begin
							data[next_rs].cmp_opcode <= cmp_bltu;
							acu_operation[next_rs] <= 1'b1;
						end else begin
							if (arith_funct3_t'(pci.funct3) == sr) begin
								if (pci.funct7[5]) begin
									data[next_rs].alu_opcode <= alu_ops'(alu_sra);
									acu_operation[next_rs] <= 1'b0;
								end else begin
									data[next_rs].alu_opcode <= alu_ops'(alu_srl);
									acu_operation[next_rs] <= 1'b0;
								end
							end else begin
								data[next_rs].cmp_opcode <= cmp_ops'(pci.funct3);
								acu_operation[next_rs] <= 1'b0;
							end
						end
					end
					default: ;
				endcase
			end
		end

		// loop through all the tags (anywhere from 0 - 2 tags per rs), check if the tag has been resolved by alu broadcast or rob broadcast
		for (int idx = 0; idx < size; idx++) 
		begin 
			// need to check for the corresponding things:

			// if tag_r1 is the tag in the rob_broadcast_bus
			// loop through the rs and resolve the dependency
			if (data[idx].busy_r1 && rob_broadcast_bus[data[idx].r1].rdy) // need broadcast bus to be indexed by data[idx]?
			begin
				data[idx].r1 <= rob_broadcast_bus[data[idx].r1].data; //upadte this to a const
				data[idx].busy_r1 <= 1'b0;
			end
			// if tag_r2 is the tag in the rob_broadcast_bus
			// loop through the rs and resolve the dependency
			if (data[idx].busy_r2 && rob_broadcast_bus[data[idx].r2].rdy == 1) // need broadcast bus to be indexed by data[idx]?
			begin
				data[idx].r2 <= rob_broadcast_bus[data[idx].r2].data;
				data[idx].busy_r2 <= 1'b0;
			end
		end

		// if the alu has finished rs[index], it will recieve broadcast from the broadcast_bus
		// loop through the rs and clear the rs. set their valid bit to 0
		for (int idx = 0; idx < size; idx++) 
		begin
			if (broadcast_bus[idx].rdy && ~(load && next_rs == idx))
			begin
				// set_default(idx);
				data[idx] <= '{cmp_opcode :cmp_beq, alu_opcode:alu_add, valid: 0, default: '0};
				acu_operation[idx] <= 1'b0;
			end
		end
	end

	always_comb
	begin
		next_rs = 5'b10000;
		// find an empty place for the new operation
		for (int idx = 0; idx < size ; idx++)
		begin
			if (~data[idx].valid || (~data[idx].busy_r1 && ~data[idx].busy_r2))
			begin
				next_rs = idx;
				break;
			end
		end

		num_available = 0;
		for (int z = 0; z < size; z++)
		begin
			// count the number of empty rs
			if (~data[z].valid)
				num_available++;

			// check if there are any rs with tags that have no dependencies
			// set their ready bit to 1
			ready[z] = data[z].valid ? (~data[z].busy_r1 && ~data[z].busy_r2 && data[z].valid) : 0;
		end
	end

endmodule : reservation_station 