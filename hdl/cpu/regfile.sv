module regfile #(paramter width = 32)
(
	input clk,
	input rst,
	input sal_t rdest,
	input [4:0] rs1, rs2,
	output rs_t rs1_out, rs2_out,
);

logic reg_entry_t data [32];
logic load = rdest.rdy;

always_ff @(posedge clk)
begin
	if (rst)
	begin
		for (int i = 0; i < 32; i = i + 1) begin
			data[i] <= '0;
		end
	end
	else if (load && dest)
	begin
		if (rdest.tag != 4'b1000) begin // invalid tag is 4'b1000
			for (int i = 0; i < 32; i = i + 1) begin
				if (rdest.tag == data[i].tag && data[i].busy == 1'b1) begin
					data[i].data = rdest.data;
				end
			end
		end
	end
end
