import rv32i_types::*;

module regfile #(parameter width = 32)
(
	input logic clk,
	input logic rst,
	input sal_t rdest,
	input logic reg_ld_instr,
	input logic [3:0] rd_tag,
	input logic [4:0] rs1, rs2, rd,
	output rs_t rs_out
);

	reg_entry_t data[32];

	always_comb begin
		rs_out.busy_r1 = rdest.rdy && rdest.tag == data[rs1].tag ? 0 : data[rs1].busy;
		rs_out.busy_r2 = rdest.rdy && rdest.tag == data[rs2].tag ? 0 : data[rs2].busy;
		
		unique case (rs_out.busy_r1)
			1'b0: rs_out.r1 = rdest.rdy && data[rs1].busy && rdest.tag == data[rs1].tag ? rdest.data : data[rs1].data;
			1'b1: rs_out.r1 = data[rs1].tag;
			default:;
		endcase

		unique case (rs_out.busy_r2)
			1'b0: rs_out.r2 = rdest.rdy && data[rs1].busy && rdest.tag == data[rs2].tag ? rdest.data : data[rs2].data;
			1'b1: rs_out.r2 = data[rs2].tag;
			default:;
		endcase
	end

	always_ff @(posedge clk)
	begin
		if (rst) begin
			for (int i = 0; i < 32; i = i + 1) begin
				data[i] <= '{default: 0 };
			end
		end
		else begin
			if (rdest.rdy) begin
				for (int i = 0; i < 32; i++) begin
					if (rdest.tag == data[i].tag && data[i].busy == 1'b1 && i != 0) begin
						/* 
						* Only update if tag in the regfile is tag from the ROB
						* If tag from the ROB doesn't match the regfile, then that means
						* there is a dependenecy and the regfile does not need to be committed
						*/
						data[i].data <= rdest.data;
						data[i].busy <= 1'b0;
					end
				end
			end
			if (reg_ld_instr && rd != 0) begin
				data[rd].busy <= 1'b1;
				data[rd].tag <= rd_tag;
			end
		end
	end
endmodule : regfile
