module circular_q #(parameter width = 32,
					parameter size 	= 8)
(
	input 	logic 				clk,
	input 	logic 				rst,
	input 	logic 				enq,
	input 	logic 				deq,
	input	pci_t				in,
	output	logic 				empty,
	output 	logic 				full,
	output 	logic 				ready,
	output	pci_t				out
);

	pci_t	arr		[size];
	int 	front, rear;

	assign 	full 	= (front == 0 && rear == size - 1) || (rear == (front - 1) % (size - 1));
	assign 	empty 	= front == -1;

	always_comb begin
		if (~empty) begin
			out = arr[front];
		end else begin
			out = '{ default: 0, pc_info: '{default: 0, opcode: op_imm }};
		end
	end

	task enqueue(pci_t data_in);
		ready 				<= 0;
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
			ready 				<= 0;
			return;
		end 
		else begin 
			out 				<= arr[front];
			arr[front] 			<= -1;
			ready 				<= 1;
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

	task endequeue(pci_t data_in);
		// if empty
		if(front == -1) begin 
			out 					<= data_in;
			ready 					<= 0;
		end 
		else begin 
			out 					<= arr[front];
			front 					<= (front + 1) % size;
			rear 					<= (rear + 1) % size;
			ready 					<= 1;
			if (~full) begin
				arr[front] 				<= -1;
				arr[(rear + 1) % size] 	<= data_in; 
			end else begin
				arr[front]			<= data_in;
			end
		end 
	endtask


	always_ff @(posedge clk) begin
		if(rst) begin
			front 	<= -1;
			rear 	<= -1;
			ready 	<= 	0;
			for(int i = 0; i < size; i++) begin 
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
