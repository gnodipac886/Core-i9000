import rv32i_types::*;


module circular_q #(parameter width = 32,
					parameter size 	= 128)
(
	input 	logic 		clk,
	input 	logic 		rst,
	input 	logic 		enq,
	input 	logic 		deq,
	input	pci_t		in,
	input 	pci_t 		in1,
	input 	flush_t 	flush,
	input 	logic 		num_enq,
	output	logic 		empty,
	output 	logic 		full,
	output 	logic 		ready,
	output	pci_t		out,
	output	pci_t		out1,
	output	int			num_items
);

	pci_t	arr		[size];
	int 	front, rear;
	int		num_items;
	logic 	wtf;

	// assign 	full 	= (front == 0 && rear == size - 1) || (rear == (front - 1) % (size - 1));
	assign 	full 	= (front == (rear + 1) % size) || (front == (rear + 2) % size);
	assign 	empty 	= front == -1;
	assign	out 	= enq && deq && front == -1 ? in : arr[front];
	assign	out1	= enq && deq && front == -1 && num_enq ? in1 : arr[(front + 1) % size];

	task enqueue(pci_t data_in, pci_t data_in1);
		ready 				<= 0;
		// full
		if(full) begin 
			return;
		end 
		// first element
		else if(front == -1) begin
			front 			<= 0;
			rear 			<= (~num_enq) ? 0 : 1;
			arr[0]			<= data_in;
			arr[1]			<= (num_enq) ? data_in1 : arr[1];
		end
		// otherwise
		else begin 
			rear 					<= (~num_enq) ? (rear + 1) % size : (rear + 2) % size;
			arr[(rear + 1) % size] 	<= data_in;
			arr[(rear + 2) % size]	<= (num_enq) ? data_in1 : arr[(rear + 2) % size];
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
				front 			<= (front + 1) % size;
			end
		end 
	endtask : dequeue

	task endequeue(pci_t data_in, pci_t data_in1);
		// if empty
		if(front == -1) begin 
			wtf 					<= 1;
			// out 					<= data_in;
			ready 					<= 0;
			// $display("%t", $time);
		end 
		else begin 
			// out 					<= arr[front];
			front 					<= (front + 1) % size;
			rear 					<= (~num_enq) ? (rear + 1) % size : (rear + 2) % size;
			ready 					<= 1;
			if (~full) begin
				arr[front] 				<= '{ default: 0, opcode: op_imm};
				arr[(rear + 1) % size] 	<= data_in;
				arr[(rear + 2) % size]	<= data_in1;
			end else begin	// Never can happen
				arr[front]			<= data_in;
			end
		end 
	endtask

	always_comb begin
		num_items = 0;
		if (full) begin
			num_items =	size;
		end else if (empty) begin
			num_items =	0;
		end else begin
			if (rear >= front) begin
				num_items = (rear - front) + 1;
			end else begin
				num_items = front - rear - 1;
			end
		end
	end

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
			enqueue(in, in1);
			// $display("enqueue!");
		end else if(~enq && deq && deq1) begin 
			dequeue();
			// $display("dequeue!");
		end 
		else if(~enq && deq) begin 
			dequeue();
			// $display("dequeue!");
		end 
		else if(enq && deq) begin 
			endequeue(in, in1);
			// $display("endeque!");
		end 
	end

endmodule : circular_q


