import rv32i_types::*;

`define width		32
`define size		8
`define br_rs_size	3
`define alu_rs_size	8
`define lsq_size	5

module regfile_tb();

	// timeunit 1ns;
	// timeprecision 1ns;
	logic clk;
	always #5 clk = clk === 1'b0;
	default clocking tb_clk @(posedge clk); endclocking

	class RandomInst;
		rv32i_reg reg_range[$];
		logic [3:0] tag_range[$];

		/** Constructor **/
		function new();
			for (int i = 0; i < 32; ++i)
				reg_range.push_back(i);
			for (int i = 0; i < 8; ++i)
				tag_range.push_back(i);
		endfunction

		function rv32i_reg random_reg(
			const ref rv32i_reg range[$] = reg_range
		);

			rv32i_reg rand_reg = '0;

			// Set rand register
			do begin
				rand_reg = $urandom();
			end while (!(rand_reg inside {range}));

			return rand_reg;
		endfunction

		function logic [3:0] random_tag(
			const ref logic [3:0] range[$] = tag_range
		);

			logic [3:0] rand_tag = '0;

			// Set rand tag
			do begin
				rand_tag = $urandom();
			end while (!(rand_tag inside {range}));

			return rand_tag;
		endfunction
	endclass

	// inputs
	logic			rst;
	sal_t			rdest;
	logic			reg_ld_instr;
	logic	[3:0]	rd_tag;
	logic	[4:0]	rs1, rs2, rd;
	// outputs
	rs_t			rs_out;

	RandomInst generator = new();

	// tag queue
	logic	[3:0] 	tag_queue[$];

	regfile #(32) dut(
		.clk(clk),
		.rst(rst),
		.reg_ld_instr(reg_ld_instr),
		.rd_tag(rd_tag),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.rs_out(rs_out)
	);

	task reset();
		##1;
		rst				<= 1'b1;
		##1;
		rst				<= 1'b0;
		rdest			<= { default: 0 };
		reg_ld_instr	<= 1'b0;
		rd_tag			<= 4'h0;
		rs1				<= 3'b0;
		rs2				<= 3'b0;
		rd				<= 3'b0;
		##1;
	endtask : reset

	task test_regfile_new_instr();
		rs1				<= generator.random_reg();
		rs2				<= generator.random_reg();
		rd				<= generator.random_reg();
		rd_tag			<= generator.random_tag();
		reg_ld_instr	<= 1'b1;
		##1;
		reg_ld_instr	<= 1'b0;
		tag_queue.push_back(rd_tag);
		##1;
	endtask

	task test_regfile_commit();
		rdest			<= '{ tag: tag_queue.pop_front(), rdy: 1'b1, data: $urandom%256 };
		##1;
	endtask

	initial begin : TEST_VECTORS
		reset();
		for (int i = 0; i < 5; i++) begin
			test_regfile_new_instr();
		end

		for (int i = 0; i < 5; i++) begin
			test_regfile_commit();
		end
		$finish;
	end
endmodule

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
		rs_out.busy_r1 = data[rs1].busy;
		rs_out.busy_r2 = data[rs2].busy;
		
		unique case (rs_out.busy_r1)
			1'b0: rs_out.r1 = data[rs1].data;
			1'b1: rs_out.r1 = data[rs1].tag;
		endcase

		unique case (rs_out.busy_r2)
			1'b0: rs_out.r2 = data[rs2].data;
			1'b1: rs_out.r2 = data[rs2].tag;
		endcase
	end

	always_ff @(posedge clk)
	begin
		if (rst) begin
			for (int i = 0; i < 32; i = i + 1) begin
				data[i] <= '{ default: 0 };
			end
		end
		else begin
			if (rdest.rdy) begin
				for (int i = 0; i < 32; i++) begin
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
endmodule : regfile
