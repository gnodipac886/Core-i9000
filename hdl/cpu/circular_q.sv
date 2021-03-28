module circular_q #(parameter width = 32,
					parameter size 	= 8)
(
	input 	logic 				clk,
	input 	logic 				rst,
	input 	logic 				enq,
	input 	logic 				deq,
	input 	logic 	[width-1:0] in,
	output	logic 				empty,
	output 	logic 				full,
	output 	logic 				ready,
	output 	logic 	[width-1:0] out
);

	logic 	[width-1:0] 	arr 	[size];
	int 	front, rear;

	assign 	full 	= (front == 0 && rear == size - 1) || (rear == (front - 1) % (size - 1));
	assign 	empty 	= front == -1;

	task enqueue(logic [width-1:0] data_in);
		// full
		if((front == 0 && rear == size - 1) || (rear == (front - 1) % (size - 1))) begin 
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
			rear 					<= (rear + 1) % size;
			arr[(rear + 1) % size] 	<= data_in; 
		end 
	endtask : enqueue

	task dequeue();
		// empty
		if(front == -1) begin 
			return;
		end 
		else begin 
			out 				<= arr[front];
			arr[front] 			<= -1;
			// dequeued the last one
			if(front == rear) begin 
				front 			<= -1;
				rear 			<= -1;
			end
			else begin 
				front 			<= (front + 1) % size;
			end
		end 
	endtask : dequeue

	task endequeue(logic [width-1:0] data_in);
		// if empty
		if(front == -1) begin 
			out 					<= data_in;
		end 
		else begin 
			out 					<= arr[front];
			arr[front] 				<= -1;
			front 					<= (front + 1) % size;
			rear 					<= (rear + 1) % size;
			arr[(rear + 1) % size] 	<= data_in; 
		end 
	endtask


	always_ff @(posedge clk) begin
		if(rst) begin
			front 	<= -1;
			rear 	<= -1;
			for(int i = 0; i < width; i++) begin 
				arr[i] <= 0;
			end 
		end
		else if(enq && ~deq) begin
			enqueue(in);
		end 
		else if(~enq && deq) begin 
			dequeue();
		end 
		else if(enq && deq) begin 
			endequeue(in);
		end 
	end

endmodule : circular_q
