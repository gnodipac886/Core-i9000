import rv32i_types::*;

module regfile #(	parameter width = 32, 
					parameter size 	= 15)
(
	input logic clk,
	input logic rst,
	input sal2_t rdest[size],
	input logic reg_ld_instr,
	input logic reg_ld_instr1,
	input logic [$clog2(size):0] rd_tag,
	input logic [$clog2(size):0] rd_tag1,
	input logic [4:0] rs1, rs2, rd,
	input logic [4:0] rs11, rs21, rd1,
	input pci_t pci, pci1,
	input logic [4:0] rd_bus[size],
	input flush_t flush,
	output rs_t rs_out,
	output rs_t rs_out1
);
	reg_entry_t data[32];
	int temp;

	function logic check_valid_flush_tag(logic [$clog2(size):0] i);
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

	/*
	front: 2
	rear: 6
	flush: 7

	0
	1
	2 x2
	3 br
	4 x2

	before flush
	x2 4 1

	after flush
	x2 4 1 <= instruction 2?
	*/

	task flush_regfile();
		// go through regfile
		// check if tag is within bounds of flush tags
		// if yes, set busy bit of that index to zero
		/*
		for (int i = 0; i < 32; i++) begin
			if (~check_valid_flush_tag(data[i].tag)) begin
				data[i].busy <= 1'b0;
			end
		end
		*/
		if(flush.flush_tag == (flush.rear_tag + 1) % size)
			return;

		for (int i = 0; i < size; i++) begin
			//start from flush, go to rear
			if ((i + flush.flush_tag) % size == flush.rear_tag) begin // case if flush tag is already > rear?
				data[rd_bus[(i+flush.flush_tag) % size]].busy <= 1'b0;  // edge case
				break;
			end
			data[rd_bus[(i+flush.flush_tag) % size]].busy <= 1'b0;  // set all the invalid ones to zero, go to next for loop

		end

		for (int i = 0; i < size; i++) begin
			if ((i + flush.front_tag) % size == flush.flush_tag) begin
				break;
			end
			if (~rdest[(i + flush.front_tag) % size].rdy && (rdest[(i + flush.front_tag) % size].pc_info.opcode != op_br) && 
			(rdest[(i + flush.front_tag) % size].pc_info.opcode != op_store) && rd_bus[(i + flush.front_tag) % size] != 0) begin
				data[rd_bus[(i + flush.front_tag) % size]].busy <= 1'b1;
				data[rd_bus[(i + flush.front_tag) % size]].tag 	<= (i + flush.front_tag) % size;
			end
		end
		
		/*
		for (int i = 0; i < size; i++) begin
			if ((i + flush.front_tag) % size == flush.flush_tag) begin
				break;
			end
			if (~rdest[(i + flush.front_tag) % size].rdy) begin
				data[rd_bus[(i + flush.front_tag) % size]].busy <= 1'b1;
			end
		end
		*/
		
	endtask 

	always_comb begin
		rs_out.busy_r1 = rdest[data[rs1].tag].rdy ? 0 : data[rs1].busy;
		rs_out.busy_r2 = rdest[data[rs2].tag].rdy ? 0 : data[rs2].busy;
		if(rd == 0 || pci.opcode == op_br || pci.opcode == op_store || (rd != 0 && rd != rs11 && rd != rs21)) begin 
			rs_out1.busy_r1 = rdest[data[rs11].tag].rdy ? 0 : data[rs11].busy;
			rs_out1.busy_r2 = rdest[data[rs21].tag].rdy ? 0 : data[rs21].busy;
		end 
		else begin 
			rs_out1.busy_r1 = rd != rs11 ? data[rs11].busy : 1;
			rs_out1.busy_r2 = rd != rs21 ? data[rs21].busy : 1;
		end 
		
		unique case (rs_out.busy_r1)
			1'b0: rs_out.r1 = rdest[data[rs1].tag].rdy && data[rs1].busy ? rdest[data[rs1].tag].data : data[rs1].data;
			1'b1: rs_out.r1 = data[rs1].tag;
			default:;
		endcase

		unique case (rs_out.busy_r2)
			1'b0: rs_out.r2 = rdest[data[rs2].tag].rdy && data[rs2].busy ? rdest[data[rs2].tag].data : data[rs2].data;
			1'b1: rs_out.r2 = data[rs2].tag;
			default:;
		endcase
		
		unique case (rs_out1.busy_r1)
			1'b0: rs_out1.r1 = rdest[data[rs11].tag].rdy && data[rs11].busy ? rdest[data[rs11].tag].data : data[rs11].data;
			1'b1: rs_out1.r1 = rd == rs11 ? rd_tag : data[rs11].tag;
			default:;
		endcase

		unique case (rs_out1.busy_r2)
			1'b0: rs_out1.r2 = rdest[data[rs21].tag].rdy && data[rs21].busy ? rdest[data[rs21].tag].data : data[rs21].data;
			1'b1: rs_out1.r2 = rd == rs21 ? rd_tag : data[rs21].tag;
			default:;
		endcase
	end
	
	always_ff @(posedge clk)
	begin
		if (rst) begin
			for (int i = 0; i < width; i = i + 1) begin
				data[i] <= '{default: 0 };
			end
		end
		else if (flush.valid) begin 
			flush_regfile();
			for (int i = 0; i < width; i++) begin
				if(rdest[data[i].tag].rdy && data[i].busy && i != 0 && check_valid_flush_tag(data[i].tag)) begin
					/* 
					* Only update if tag in the regfile is tag from the ROB
					* If tag from the ROB doesn't match the regfile, then that means
					* there is a dependenecy and the regfile does not need to be committed
					*/
					data[i].data <= rdest[data[i].tag].data;
					data[i].busy <= 1'b0;
				end
			end
			

			for (int i = 0; i < size; i++) begin
				if (rdest[(i + flush.front_tag) % size].rdy && rd_bus[(i + flush.front_tag) % size] != 0 && 
				data[rd_bus[(i + flush.front_tag) % size]].tag != rdest[(i + flush.front_tag) % size].tag && 
				~rdest[data[rd_bus[(i + flush.front_tag) % size]].tag].rdy && 
				check_valid_flush_tag((i + flush.front_tag) % size)) begin
					
					data[rd_bus[(i + flush.front_tag) % size]].data <= rdest[(i + flush.front_tag) % size].data;
				end
			end
		end 
		else begin
			for (int i = 0; i < width; i++) begin
				if(rdest[data[i].tag].rdy && data[i].busy && i != 0) begin
					/* 
					* Only update if tag in the regfile is tag from the ROB
					* If tag from the ROB doesn't match the regfile, then that means
					* there is a dependenecy and the regfile does not need to be committed
					*/
					data[i].data <= rdest[data[i].tag].data;
					data[i].busy <= 1'b0;
				end
			end

				// 0, rd: 1, not ready 


				// 5 br 


				// 7 rd: 1, not ready
				/*
			(~rdest[data[rd_bus[(i + flush.front_tag) % size]].tag].rdy ||
			(rdest[data[rd_bus[(i + flush.front_tag) % size]].tag].rdy  && 
			~data[rd_bus[(i + flush.front_tag) % size].busy] && 
			rd_bus[data[rd_bus[(i + flush.front_tag) % size]].tag] != rd_bus[(i + flush.front_tag) % size))
			*/

			
			for (int i = 0; i < size; i++) begin
				if (rdest[(i + flush.front_tag) % size].rdy && rd_bus[(i + flush.front_tag) % size] != 0 && 
				data[rd_bus[(i + flush.front_tag) % size]].tag != rdest[(i + flush.front_tag) % size].tag &&
				~rdest[data[rd_bus[(i + flush.front_tag) % size]].tag].rdy) begin

					data[rd_bus[(i + flush.front_tag) % size]].data <= rdest[(i + flush.front_tag) % size].data;
				end
			end

			/*
			for (int i = 0; i < size; i++) begin
				if (rdest[(i + flush.front_tag) % size].rdy && rd_bus[(i + flush.front_tag) % size] != 0 && 
				data[rd_bus[(i + flush.front_tag) % size]].tag != rdest[(i + flush.front_tag) % size].tag &&
				(~rdest[data[rd_bus[(i + flush.front_tag) % size]].tag].rdy ||
				(rdest[data[rd_bus[(i + flush.front_tag) % size]].tag].rdy  && 
				~data[rd_bus[(i + flush.front_tag) % size]].busy && 
				rd_bus[data[rd_bus[(i + flush.front_tag) % size]].tag] != rd_bus[(i + flush.front_tag) % size]))) begin

					data[rd_bus[(i + flush.front_tag) % size]].data <= rdest[(i + flush.front_tag) % size].data;
				end
			end
			*/

			if (reg_ld_instr && rd != 0) begin
				data[rd].busy <= 1'b1;
				data[rd].tag <= rd_tag;
			end
			if (reg_ld_instr1 && rd1 != 0) begin
				data[rd1].busy <= 1'b1;
				data[rd1].tag <= rd_tag1;
			end
		end
	end
endmodule : regfile
