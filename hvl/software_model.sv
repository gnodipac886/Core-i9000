import rv32i_types::*;

module software_model #(
	parameter width 		= 32,
	parameter size 			= 8,
	parameter br_rs_size 	= 8,
	parameter acu_rs_size 	= 8,
	parameter lsq_size 		= 8
)
(
	// input logic clk,
	input logic rst,
	
	input logic commit, // whenever any of the rdest.rdy bits are 1 (link them up in a big OR?)
	input sal2_t rdest[size], // from rob
	input logic [4:0] rd_bus[size], // probably not needed

	input reg_entry_t cpu_registers[32], // the whole regfile
	input logic halt
);
timeunit 1ns;
timeprecision 1ns;
logic clk;
always #5 clk = clk === 1'b0;
default clocking tb_clk @(posedge clk); endclocking

reg_entry_t data[32];
logic [31:0] r1_data;
logic [31:0] r2_data;
pci_t pci;
task reset();
	pci = '{ opcode: op_imm, default: 0 };
	r1_data = '0;
	r2_data = '0;
	for (int i = 0; i < 32; i++) begin
		data[i] <= '{default: 0 };
	end
endtask

task ingest_rd(int index);
// get the pci from each entry, and then do a big case statement of opcodes
	pci = rdest[index].pc_info;

	case (pci.opcode)
		op_imm:
		begin
			r1_data = data[pci.rs1].data;
			r2_data = pci.i_imm;
			case (pci.funct3)
				3'b000: //addi
				begin
					data[pci.rd].data = r1_data + r2_data;
				end
				3'b001: //slli
				begin
					data[pci.rd].data = r1_data << r2_data[4:0];
				end
				3'b010: //slti (need to do something special?)
				begin
					data[pci.rd].data = $signed(r1_data) >>> r2_data[4:0];
				end
				3'b011: //sltiu
				begin
					data[pci.rd].data = r1_data - r2_data;
				end
				3'b100: //xori
				begin
					data[pci.rd].data = r1_data ^ r2_data;
				end
				3'b101: //srli OR srai
				begin
					data[pci.rd].data = r1_data >> r2_data[4:0];
				end
				3'b110: //ori
				begin
					data[pci.rd].data = r1_data | r2_data;
				end
				3'b111: //andi
				begin
					data[pci.rd].data = r1_data & r2_data;
				end
				default: ;
			endcase // pci.funct3
		end
		op_reg:	
		begin
			r1_data = data[pci.rs1].data;
			r2_data = data[pci.rs2].data;
			case (pci.funct3)
				3'b000: //addi
				begin
					data[pci.rd].data = r1_data + r2_data;
				end
				3'b001: //slli
				begin
					data[pci.rd].data = r1_data << r2_data[4:0];
				end
				3'b010: //slti (need to do something special?)
				begin
					data[pci.rd].data = $signed(r1_data) >>> r2_data[4:0];
				end
				3'b011: //sltiu
				begin
					data[pci.rd].data = r1_data - r2_data;
				end
				3'b100: //xori
				begin
					data[pci.rd].data = r1_data ^ r2_data;
				end
				3'b101: //srli OR srai
				begin
					data[pci.rd].data = r1_data >> r2_data[4:0];
				end
				3'b110: //ori
				begin
					data[pci.rd].data = r1_data | r2_data;
				end
				3'b111: //andi
				begin
					data[pci.rd].data = r1_data & r2_data;
				end
				default: ;
			endcase // pci.funct3
		end
		default:;
	endcase // pci.opcode
endtask
logic flag = 1'b0;
task compare_registers();
	// $display("comparing registers at %0t", $time);
	flag = 1'b0;
	for (int i = 0; i < 32; i++) begin
		assert (cpu_registers[i].data == data[i].data) //$display("%0t: register %0d matches", $time, i);
		else begin 
			$error("%0t: register %0d should be %0d, but it is %0d", $time/1000, i, data[i].data, cpu_registers[i].data);
			flag = 1'b1;
		end
	end
	if (~flag) $display("all good at commit %4t", $time);
endtask

initial begin : TEST_VECTORS
	reset();


end

always @(posedge commit) begin
		for (int i = 0; i < size; i++) begin
			if (~rdest[i].rdy) begin
				continue;
			end else begin
				ingest_rd(i);
			end
		end
end

always @(negedge commit) begin
	// we want to compare the registers after the rdest has propogated (next cycle)	
	compare_registers();
end


endmodule : software_model
