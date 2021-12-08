import rv32i_types::*;

module alu #(parameter size=15,
			parameter width=32)
(
	// this needs to be revised for ooo execution
	input clk,
	input rst,
	input rs_t data[size],
	input logic[size-1:0] ready,

	output sal_t out[size]
);

	// multiplier stuff
	logic 	[width - 1:0] 			mul_a[size - 1:0];
	logic 	[width - 1:0] 			mul_b[size - 1:0];
	logic 							mul_valid[size - 1:0];
	logic 	[(width << 1) - 1:0] 	mul_ans[size - 1:0];
	logic 							mul_rdy[size - 1:0];

	logic 	[width - 1:0] 			div_a[size - 1:0];
	logic 	[width - 1:0] 			div_b[size - 1:0];
	logic 							div_valid[size - 1:0];
	logic 	[width - 1:0] 			div_quo[size - 1:0];
	logic 	[width - 1:0] 			div_rem[size - 1:0];
	logic 							div_rdy[size - 1:0];

	always_comb begin
		for (int idx = 0; idx < size; idx++) begin
			mul_valid[idx] 	=  0;
			mul_a[idx] 		= '0;
			mul_b[idx] 		= '0;

			div_a[idx]		= '0;
			div_b[idx]		= '0;
			div_valid[idx]	= 0;

			out[idx].data 	= '0;
			out[idx].rdy 	= 0;
			out[idx].tag 	= data[idx].tag;
			if (ready[idx] & data[idx].valid) begin
				unique case (data[idx].funct7)
					7'b0000001: begin 
						mul_valid[idx] 	= 0;

						unique case (data[idx].alu_opcode)
							mul_mul		: begin 
								mul_valid[idx] 	= 1'b1;
								mul_a[idx] 		= data[idx].r1;
								mul_b[idx] 		= data[idx].r2;
								out[idx].data 	= get_lo(mul_ans[idx]);
								out[idx].rdy 	= mul_rdy[idx];
							end

							mul_mulh	: begin 
								mul_valid[idx] = 1'b1;
								mul_a[idx] 		= is_neg(data[idx].r1) ? negate(data[idx].r1) : data[idx].r1;
								mul_b[idx] 		= is_neg(data[idx].r2) ? negate(data[idx].r2) : data[idx].r2;
								out[idx].data 	= is_neg(data[idx].r1) ^ is_neg(data[idx].r2) ? get_hi(negate(mul_ans[idx])) : get_hi(mul_ans[idx]);
								out[idx].rdy 	= mul_rdy[idx];
							end

							mul_mulhsu	: begin 
								mul_valid[idx] = 1'b1;
								mul_a[idx] 		= is_neg(data[idx].r1) ? negate(data[idx].r1) : data[idx].r1;
								mul_b[idx] 		= data[idx].r2;
								out[idx].data 	= is_neg(data[idx].r1) ? get_hi(negate(mul_ans[idx])) : get_hi(mul_ans[idx]);
								out[idx].rdy 	= mul_rdy[idx];
							end

							mul_mulhu	: begin 
								mul_valid[idx] = 1'b1;
								mul_a[idx] 		= data[idx].r1;
								mul_b[idx] 		= data[idx].r2;
								out[idx].data 	= get_hi(mul_ans[idx]);
								out[idx].rdy 	= mul_rdy[idx];
							end

							mul_div		: begin 
								div_valid[idx] 	= 1'b1;
								div_a[idx] 		= is_neg(data[idx].r1) ? negate(data[idx].r1) : data[idx].r1;
								div_b[idx] 		= is_neg(data[idx].r2) ? negate(data[idx].r2) : data[idx].r2;
								out[idx].data 	= is_neg(data[idx].r1) ^ is_neg(data[idx].r2) ? negate(div_quo[idx]) : div_quo[idx];
								out[idx].rdy 	= div_rdy[idx];
								// out[idx].rdy 	= 1'b1;
								// out[idx].data 	= is_neg(data[idx].r1) ^ is_neg(data[idx].r2) ? negate(div_a[idx] / div_b[idx]) : div_a[idx] / div_b[idx];

								if(out[idx].rdy) begin 
									if (is_neg(data[idx].r1) ^ is_neg(data[idx].r2)) begin 
										if (out[idx].data != negate(div_a[idx] / div_b[idx]))
											$error("1 error: %t, %d / %d = %d", $time, data[idx].r1, data[idx].r2, out[idx].data);
									end else begin 
										if (out[idx].data != div_a[idx] / div_b[idx])
											$error("1 error: %t, %d / %d = %d", $time, data[idx].r1, data[idx].r2, out[idx].data);
									end 
								end 
							end 

							mul_divu	: begin 
								div_valid[idx] 	= 1'b1;
								div_a[idx] 		= data[idx].r1;
								div_b[idx] 		= data[idx].r2;
								out[idx].data 	= div_quo[idx];
								out[idx].rdy 	= div_rdy[idx];
								// out[idx].rdy 	= 1'b1;
								// out[idx].data 	= unsigned'(data[idx].r1) / unsigned'(data[idx].r2);

								if(out[idx].rdy) begin 
									if (out[idx].data != (div_a[idx] / div_b[idx]))
										$error("idx: %d, 2 error: %t, %d / %d = %d", idx, $time, data[idx].r1, data[idx].r2, out[idx].data);
								end 
							end 

							mul_rem		: begin 
								div_valid[idx] 	= 1'b1;
								div_a[idx] 		= is_neg(data[idx].r1) ? negate(data[idx].r1) : data[idx].r1;
								div_b[idx] 		= is_neg(data[idx].r2) ? negate(data[idx].r2) : data[idx].r2;
								out[idx].data 	= is_neg(data[idx].r1) ^ is_neg(data[idx].r2) ? negate(div_rem[idx]) : div_rem[idx];
								out[idx].rdy 	= div_rdy[idx];
								// out[idx].rdy 	= 1'b1;
								// out[idx].data 	= is_neg(data[idx].r1) ^ is_neg(data[idx].r2) ? negate(div_a[idx] % div_b[idx]) : div_a[idx] % div_b[idx];

								if(out[idx].rdy) begin 
									if (is_neg(data[idx].r1) ^ is_neg(data[idx].r2)) begin 
										if (out[idx].data != negate(div_a[idx] % div_b[idx]))
											$error("idx: %d, 3 error: %t, %d mod %d = %d", idx, $time, data[idx].r1, data[idx].r2, out[idx].data);
									end else begin 
										if (out[idx].data != (div_a[idx] % div_b[idx]))
											$error("idx: %d, 3 error: %t, %d mod %d = %d", idx, $time, data[idx].r1, data[idx].r2, out[idx].data);
									end 
								end 
							end 

							mul_remu	: begin 
								div_valid[idx] 	= 1'b1;
								div_a[idx] 		= data[idx].r1;
								div_b[idx] 		= data[idx].r2;
								out[idx].data 	= div_rem[idx];
								out[idx].rdy 	= div_rdy[idx];
								// out[idx].rdy 	= 1'b1;
								// out[idx].data 	= unsigned'(data[idx].r1) % unsigned'(data[idx].r2);
								if(out[idx].rdy) begin 
									if (out[idx].data != (div_a[idx] % div_b[idx]))
										$error("idx: %d, 4 error: %t, %d mod %d = %d", idx, $time, data[idx].r1, data[idx].r2, out[idx].data);
								end 
							end 

						endcase
					end 


					7'd0, 7'b0100000: begin 
						unique case (data[idx].alu_opcode)
							alu_add:  out[idx].data = ~data[idx].funct7[5] ? data[idx].r1 + data[idx].r2 : data[idx].r1 - data[idx].r2;
							alu_sll:  out[idx].data = data[idx].r1 << data[idx].r2[4:0];
							alu_sra:  out[idx].data = $signed(data[idx].r1) >>> data[idx].r2[4:0];
							alu_sub:  out[idx].data = data[idx].r1 - data[idx].r2;
							alu_xor:  out[idx].data = data[idx].r1 ^ data[idx].r2;
							alu_srl:  out[idx].data = ~data[idx].funct7[5] ? data[idx].r1 >> data[idx].r2[4:0] : $signed(data[idx].r1) >>> data[idx].r2[4:0];
							alu_or:   out[idx].data = data[idx].r1 | data[idx].r2;
							alu_and:  out[idx].data = data[idx].r1 & data[idx].r2;
						endcase
						out[idx].rdy = 1'b1;
						out[idx].tag = data[idx].tag;
					end 

					default:;
				endcase
			end else begin
				out[idx].rdy = 1'b0;
				out[idx].tag = 4'b0;
			end
		end
	end

	function logic is_neg(logic [width - 1:0] num);
		return num[width - 1];
	endfunction

	function logic [(width << 1) - 1:0] negate(logic [(width << 1) - 1:0] num);
		return (~num) + 1;
	endfunction

	function logic [width- 1:0] get_hi(logic [(width << 1) - 1:0] num);
		return num[(width << 1) - 1:width];
	endfunction

	function logic [width- 1:0] get_lo(logic [(width << 1) - 1:0] num);
		return num[width - 1:0];
	endfunction

	generate
		for(genvar i = 0; i < size; i++) begin 
			multiplier mul(clk, rst, mul_a[i], mul_b[i], mul_valid[i], mul_ans[i], mul_rdy[i]);
			divider div(clk, rst, div_valid[i], div_a[i], div_b[i], div_quo[i], div_rem[i], div_rdy[i]);
		end 
	endgenerate

endmodule : alu