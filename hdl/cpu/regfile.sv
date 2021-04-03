module regfile #(paramter width = 32)
(
	input clk,
	input rst,
	input sal_t rdest,
	input logic reg_ld_instr,
	input [3:0] rd_tag,
	input [4:0] rs1, rs2, rd,
	output rs_t rs1_out, rs2_out,
);

logic reg_entry_t data [32];
logic load_data = rdest.rdy;

always_ff @(posedge clk)
begin
	if (rst) begin
		for (int i = 0; i < 32; i = i + 1) begin
			data[i] <= '0;
		end
	end
	else begin
		if (load_data) begin
			for (int i = 0; i < 32; i = i + 1) begin
				if (rdest.tag == data[i].tag && data[i].busy == 1'b1) begin
					/* 
					 * Only update if tag in the regfile is tag from the ROB
					 * If tag from the ROB doesn't match the regfile, then that means
					 * there is a dependenecy and the regfile does not need to be committed
					 */
					data[i].data = rdest.data;
					data[i].busy = 1'b0;
				end
			end
		end
		if (reg_ld_instr) begin
			data[rd].busy = 1'b1;
			data[rd].tag = rd_tag;
		end
	end
end
