import rv32i_types::*;

module reservation_station #(parameter size = 8, parameter rob_size = 8) // specify number of RS here
	(
		input logic clk,
		input logic rst,
		input logic flush,

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
		output logic[size-1:0] ready, // if both values are not tags, flip this ready bit to 1
		output logic[3:0] num_available // do something if the number of available reservation stations are 0
	);

logic valid[size];
int result_rs;
int index = -1;
int idx = 0;
// 0 if empty, 1 if full
task find_valid_rs();
	result_rs <= -1;
	for (idx = 0; idx < size; idx++)
	begin
		if (~data[idx].valid)
		begin
			result_rs <= idx;
		end
	end
endtask : find_valid_rs

task set_default(int i);
	data[idx] <= '{default: 0};
endtask : set_default

always_ff @(posedge clk)
begin
	if (flush || rst)
	begin
		// erase the data object (set to defaults)
		for (int idx = 0; idx < size; idx++) 
		begin 
			// clear..
			// set_default(idx);
			// data[idx].operation <= 7'b0;
			// data[idx].tag <= 3'b0;
			// data[idx].busy_r1 <= 1'b0;
			// data[idx].busy_r2 <= 1'b0;
			// data[idx].r1 <= 32'b0;
			// data[idx].r2 <= 32'b0;
			// data[idx].sent_to_alu <= 1'b0;
			data[idx] <= '{default: 0};
		end
	end

	if (load)
	begin
		// find an empty place for the new operation
		find_valid_rs();
		// set all the fields for the new struct
		if (index != -1) 
		begin
			// load..
			// data[index].operation = operation;
			// data[index].tag = tag;
			// data[index].busy_r1 = tag_r1;
			// data[index].busy_r2 = tag_r2;
			// data[index].r1 = r1;
			// data[index].r2 = r2;
			// // data[index].pc = pc;
			// data[index].sent_to_alu = 1'b0;
			// valid[index] = 1'b0;
			data[index] <= input_r;
			data[index].valid <= 1'b1;
			data[index].opcode <= pci.opcode;
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
		if (broadcast_bus[idx].rdy)
		begin
			// set_default(idx);
			// data[idx].operation = 7'b0;
			// data[idx].tag = 3'b0;
			// data[idx].busy_r1 = 1'b0;
			// data[idx].busy_r2 = 1'b0;
			// data[idx].r1 = 32'b0;
			// data[idx].r2 = 32'b0;
			// data[idx].pc = 32'b0;
			// data[idx].sent_to_alu = 1'b0;
			// valid[idx] = 1'b0;
			data[idx] <= '{default: 0};
		end
	end
end

always_comb
begin
	num_available = 0;
	for (int z = 0; z < size; z++)
	begin
		// count the number of empty rs
		if (~data[z].valid)
			num_available++;

		// check if there are any rs with tags that have no dependencies
		// set their ready bit to 1
		ready[z] <= (~data[z].busy_r1 && ~data[z].busy_r2);
	end
end

endmodule : reservation_station