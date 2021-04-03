module reorder_buffer #(
	parameter width = 32,
	parameter size = 8,
	parameter br_rs_size = 3,
	parameter alu_rs_size = 8,
	parameter lsq_size = 5)
(
	input logic	clk,
	input logic	rst,
	input logic	instr_q_empty,
	input pci_t instr_q_data,
	input logic stall_br,
	input sal_t	br_rs_o [br_rs_size],
	input logic stall_alu,
	input sal_t alu_rs_o [alu_rs_size],
	input logic stall_lsq,
	input sal_t lsq_o,


	output logic instr_q_dequeue,
	output sal_t bcast_br_rs [br_rs_size],
	output sal_t bcast_alu_rs [alu_rs_size],
	output sal_t bcast_lsq [lsq_size],
	output sal_t rdest,
	output [3:0] rd_tag,
	output logic reg_ld_instr
);

rob_t arr [size];
int front, rear;

logic enq, deq;

assign full = ((front == 0) && (rear == size - 1)) || (rear == ((front - 1) % (size - 1)));
// size - 1?
assign empty = (front == -1);

task enqueue(rob_t data_in):
	// Check if full before sending dequeue signal to instr_q
	// first element
	if(front == -1) begin 
		front <= 0;
		rear <= 0;
		arr[0] <= data_in;
	end
	// otherwise
	else begin 
		rear <= (rear + 1) % size;
		arr[(rear + 1) % size] <= data_in; 
	end 
endtask : enqueue

task dequeue():
	// Check if empty before dequeuing
	rdest <= sal_t'({ front, arr[front].rdy, arr[front].data });
	arr[front] <= 0;
	// dequeued the last one
	if(front == rear) begin 
		front <= size;
		rear <= size;
	end
	else begin 
		front <= (front + 1) % size;
	end
endtask : dequeue

// Necessary?
task endequeue(logic [width-1:0] data_in):
	// if empty, but this case should never occur be able to occur, because then it wouldn't attempt to dequeue
	if(front == -1) begin 
		out <= data_in;
	end 
	else begin 
		out <= arr[front];
		arr[front] <= 0;
		front <= (front + 1) % size;
		rear <= (rear + 1) % size;
		arr[(rear + 1) % size] <= data_in; 
	end 
endtask

always_comb begin
	// Enqueue if not full and instr_q is not empty
	enq = (full == 1'b0) && (instr_q_empty == 1'b0);
	// Dequeue if front is ready and valid
	deq = (arr[front].rdy == 1'b1 && arr[front].valid == 1'b1)
end

always_ff @(posedge clk) begin
	if(rst) begin
		front <= -1;
		rear <= -1;
		for(int i = 0; i < size; i++) begin 
			arr[i] <= 0;
		end 
	end
	else if(enq && ~deq) begin
		enqueue(rob_t'({ instr_q_data, 32'hxxxx, 1'b0, 1'b1 }));
	end 
	else if(~enq && deq) begin 
		dequeue();
	end 
	// Necessary?
	else if(enq && deq) begin 
		endequeue(rob_t'({ instr_q_data.pc, 32'hxxxx, 1'b0, 1'b1 }));
	end 
end

