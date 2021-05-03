import rv32i_types::*;

module acu #(parameter size = 15)
(
	input rs_t data[size],
	input logic[size-1:0] ready,
	input logic acu_operation [size],
	output sal_t out[size]
);

	sal_t out_alu[size];
	sal_t out_cmp[size];

	alu alu(
		.out(out_alu),
		.*
	);
	
	cmp cmp(
		.out(out_cmp),
		.*
	);

	always_comb begin
		for (int i = 0; i < size; i++) begin
			if (~acu_operation[i]) begin
				out[i] = out_alu[i];
			end else begin
				out[i] = out_cmp[i];
			end
		end
	end
endmodule : acu