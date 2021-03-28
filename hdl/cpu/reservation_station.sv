module reservation_station #(parameter size = 8) // specify number of RS here
		input logic clk,
		input logic rst,
		input logic flush,

		input logic load,

		// from instruction queue -> RS and instruction queue -> ROB -> RS, on issuing new instruction
		input logic[6:0] operation, // from ROB
		input logic[31:0] r1, // from regfile
		input logic[31:0] r2, // from regfile
		input logic tag_r1, // from regfile, tell if r1 is a tag or a value
		input logic tag_r2, // from regfile, tell if r2 is a tag or a value
		input logic[3:0] tag, // from ROB, what is the tag in ROB to replace once calculation is done

		input sal_t broadcast_bus, // after computation is done
		input sal_t rob_broadcast_bus, // after other rs is done, send data from ROB to rs

		output rs_t data[size], // all the reservation stations, to the alu
		output logic[size-1:0] ready, // if both values are not tags, flip this ready bit to 1
		output logic num_available, // do something if the number of available reservation stations are 0



	);

function integer find_valid_rs();
	for (int idx = 0; idx < size; idx++)
	begin
		if (~valid[idx])
		begin
			return result;
		end
	end
	return -1;
endfunction : find_valid_rs

function set_default(int i);
	data[i].operation = 7'b0;
	data[i].tag = 4'b0;
	data[i].busy_r1 = 1'b0;
	data[i].busy_r2 = 1'b0;
	data[i].r1 = 32'b0;
	data[i].r2 = 32'b0;
	data[i].pc = 32'b0;
	data[i].sent_to_alu = 1'b0;
	valid[i] = 1'b0;
endfunction : set_default

always_ff @(posedge clk)
begin
	if (flush || rst)
	begin
		// erase the data object (set to defaults)
		for (int idx = 0; idx < size; idx++) 
		begin 
			// clear..
			set_default(idx);
		end
	end

	if (load)
	begin
		// find an empty place for the new operation
		int index = find_valid_rs();
		// set all the fields for the new struct
		if (index != -1) 
		begin
			// load..
			data[index].operation = operation;
			data[index].tag = 4'b0;
			data[index].busy_r1 = 1'b0;
			data[index].busy_r2 = 1'b0;
			data[index].r1 = r1
			data[index].r2 = r2
			data[index].pc = 32'b0;
			data[index].sent_to_alu = 1'b0;
			valid[index] = 1'b0;
		end
	end

	// check if broadcast_bus tag is received, from the corresponding ALU or from the ROB
	for (int idx = 0; idx < size; idx++) 
	begin 
		// need to check for the corresponding things:
		// if the alu has finished rs[index], it will recieve broadcast from the (broadcast_bus or ROB)
		// loop through the rs and clear the rs
		
		// if tag_r1 is the tag in the broadcast_bus
		// loop through the rs and resolve the dependency
		
		// if tag_r2 is the tag in the broadcast_bus
		// loop through the rs and resolve the dependency
		
		// if tag_r1 is the tag in the rob_broadcast_bus
		// loop through the rs and resolve the dependency
		
		// if tag_r2 is the tag in the rob_broadcast_bus
		// loop through the rs and resolve the dependency
	end
end

always_comb
begin
	for (int z = 0; z < size; z++)
	begin
		if (~valid[z])
			num_available++;

		ready[z] <= (~data[z].busy_r1 && ~data[z].busy_r2);
	end
end

endmodule : reservation_station