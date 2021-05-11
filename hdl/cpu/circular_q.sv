import rv32i_types::*;


module circular_q #(parameter width = 32,
					parameter size 	= 8,
					parameter mask 	= 32'd7)
(
	input 	logic 		clk,
	input 	logic 		rst,
	input 	logic 		enq,
	input 	logic 		deq,
	input	pci_t		in,
	input 	flush_t 	flush,
	output	logic 		empty,
	output 	logic 		full,
	output 	logic 		ready,
	output	pci_t		out
);

	pci_t	arr		[size];
	int 	front, rear;
	logic 	wtf;

	assign 	full 	= (front == 0 && rear == size - 1) || front == ((rear + 1) & mask);
	assign 	empty 	= front == -1;
	assign	out = enq && deq && front == -1 ? in : arr[front];

	task enqueue(pci_t data_in);
		ready 				<= 0;
		// full
		if((front == 0 && rear == size - 1) || front == ((rear + 1) & mask)) begin 
			return;
		end 
		// first element
		else if(front == -1) begin 
			front 			<= 0;
			rear 			<= 0;
			arr[0]			<= data_in;
		end
		// otherwise
		else begin 
			rear 					<= (rear + 1) & mask;
			arr[(rear + 1) & mask] 	<= data_in; 
		end 
	endtask : enqueue

	task dequeue();
		// empty
		if(front == -1) begin
			ready 				<= 0;
			return;
		end 
		else begin 
			// out 				<= arr[front];
			arr[front] 			<= '{ default: 0, opcode: op_imm};
			ready 				<= 1;
			// dequeued the last one
			if(front == rear) begin 
				front 			<= -1;
				rear 			<= -1;
			end
			else begin 
				front 			<= (front + 1) & mask;
			end
		end 
	endtask : dequeue

	task endequeue(pci_t data_in);
		// if empty
		if(front == -1) begin 
			wtf 					<= 1;
			// out 					<= data_in;
			ready 					<= 0;
			// $display("%t", $time);
		end 
		else begin 
			// out 					<= arr[front];
			front 					<= (front + 1) & mask;
			rear 					<= (rear + 1) & mask;
			ready 					<= 1;
			if (~full) begin
				arr[front] 				<= '{ default: 0, opcode: op_imm};
				arr[(rear + 1) & mask] 	<= data_in; 
			end else begin
				arr[front]			<= data_in;
			end
		end 
	endtask

	always_ff @(posedge clk) begin
		if(rst || flush.valid) begin
			front 	<= -1;
			rear 	<= -1;
			ready 	<= 	0;
			for(int i = 0; i < size; i++) begin 
				arr[i] <= '{ default: 0, opcode: op_imm};
			end 
		end
		else if(enq && ~deq) begin
			enqueue(in);
			// $display("enqueue!");
		end 
		else if(~enq && deq) begin 
			dequeue();
			// $display("dequeue!");
		end 
		else if(enq && deq) begin 
			endequeue(in);
			// $display("endeque!");
		end 
	end

endmodule : circular_q


