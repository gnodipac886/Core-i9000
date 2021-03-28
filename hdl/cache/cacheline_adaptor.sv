module cacheline_adaptor
(
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);

    typedef enum bit [2:0] {IDLE, WAITR, WAITW, R, W, DONE} macro_t;
    struct packed {
        macro_t macro;
        logic [1:0] count;
    } state;
    localparam logic [1:0] maxcount = 2'b11;


    logic [255:0] linebuf;
    logic [31:0] addressbuf;
    assign line_o = linebuf;
    assign address_o = addressbuf;
    assign burst_o = linebuf[64 * state.count +: 64];
    assign read_o = ((state.macro == WAITR) || (state.macro == R));
    assign write_o = ((state.macro == WAITW) || (state.macro == W));
    assign resp_o = state.macro == DONE;
    enum bit [1:0] {READ_OP, WRITE_OP, NO_OP} op;
    assign op = read_i ? READ_OP : write_i ? WRITE_OP : NO_OP;

    always_ff @(posedge clk) begin
        if (~reset_n) begin
            state.macro <= IDLE;
        end
        else begin
            case (state.macro)
            IDLE: begin
                case (op)
                    NO_OP: ;
                    WRITE_OP: begin
                        state.macro <= WAITW;
                        linebuf <= line_i;
                        addressbuf <= address_i;
                        state.count <= 2'b00;
                    end
                    READ_OP: begin
                        state.macro <= WAITR;
                        addressbuf <= address_i;
                    end
                endcase
            end
            WAITR: begin
                if (resp_i) begin
                    state.macro <= R;
                    state.count <= 2'b01;
                    linebuf[63:0] <= burst_i;
                end
            end
            WAITW: begin
                if (resp_i) begin
                    state.macro <= W;
                    state.count <= 2'b01;
                end
            end
            R: begin
                if (state.count == maxcount) begin
                    state.macro <= DONE;
                end
                linebuf[64*state.count +: 64] <= burst_i;
                state.count <= state.count + 2'b01;
            end
            W: begin
                if (state.count == maxcount) begin
                    state.macro <= DONE;
                end
                state.count <= state.count + 2'b01;
            end
            DONE: begin
                state.macro <= IDLE;
            end
            endcase
        end
    end

endmodule : cacheline_adaptor
// module cacheline_adaptor
// (
// 	input logic clk,
// 	input logic reset_n,

// 	// Port to LLC (Lowest Level Cache)
// 	input logic [255:0] line_i,
// 	output logic [255:0] line_o,
// 	input logic [31:0] address_i,
// 	input logic read_i,
// 	input logic write_i,
// 	output logic resp_o,

// 	// Port to memory
// 	input logic [63:0] burst_i,
// 	output logic [63:0] burst_o,
// 	output logic [31:0] address_o,
// 	output logic read_o,
// 	output logic write_o,
// 	input logic resp_i
// );

// 	logic [63 : 0] data1, data2, data3, data4;
// 	logic r_w;		// 1 : r, 0 : w

// 	enum logic [4:0] {	start,
// 						r_1, 	w_1, 
// 						r_2, 	w_2, 
// 						r_3, 	w_3, 
// 						r_4, 	w_4,
// 						done
// 						} curr, next;

// 	//load, from memory to LLC - read
// 	always_comb begin
// 		next = curr;
// 		case(curr)
// 			start	: 	if(~read_i && ~write_i)
// 							next = start;
// 						else 
// 							next = read_i && ~write_i ? r_1 : w_1;
// 			r_1		: 	if(resp_i)
// 							next = r_2;
// 			r_2		: 	next = r_3;
// 			r_3		: 	next = r_4;
// 			r_4		: 	next = done;
	
// 			w_1		: 	if(resp_i)
// 							next = w_2;
// 			w_2		: 	next = w_3;
// 			w_3		: 	next = w_4;
// 			w_4		: 	next = done;
// 			done 	: 	next = start;
// 			default : 	next = start;
// 		endcase // curr
// 	end 

// 	always_latch begin
// 		address_o 	= address_i;
// 		read_o		= read_i;
// 		write_o 	= write_i;
// 		// r_w 		= 1'b0;
// 		// data1 		= data1 ? data1 : 0;
// 		// data2 		= data2 ? data2 : 0;
// 		// data3 		= data3 ? data3 : 0;
// 		// data4 		= data4 ? data4 : 0;
// 		// resp_o 		= 0;
// 		// line_o 		= 0;
// 		// burst_o 	= 0;
// 		case(curr)
// 			start	: 	begin 
// 				r_w 		= 1'b0;
// 				data1 		= 0;
// 				data2 		= 0;
// 				data3 		= 0;
// 				data4 		= 0;
// 				resp_o 		= 0;
// 				line_o 		= 0;
// 				burst_o 	= 0;
// 			end 

// 			r_1		: 	begin
// 				r_w 		= 	1'b1;
// 				data1 		= 	burst_i;
// 			end 

// 			r_2		: 	begin
// 				data2 		= 	burst_i;
// 			end 

// 			r_3		: 	begin
// 				data3 		= 	burst_i;
// 			end 

// 			r_4		: 	begin
// 				data4 		= 	burst_i;
// 			end 

// 			w_1		: 	begin
// 				r_w 		= 	1'b0;
// 				burst_o 	=	line_i[63 : 0];
// 			end 

// 			w_2		: 	begin
// 				burst_o 	=	line_i[127 : 64];
// 			end 

// 			w_3		: 	begin
// 				burst_o 	=	line_i[191 : 128];
// 			end 

// 			w_4		: 	begin
// 				burst_o 	=	line_i[255 : 192];
// 			end 

// 			done 	: 	begin
// 				resp_o 		= 	1'b1;
// 				read_o 		= 	1'b0;
// 				write_o 	= 	1'b0;
// 				if(r_w) begin
// 					line_o 	= 	{data4, data3, data2, data1};
// 				end
// 			end 

// 			default : 	;

// 		endcase
// 	end 

// 	always_ff @(posedge clk) begin
// 		if(~reset_n) begin
// 			curr <= start;
// 		end 
// 		else begin
// 			curr <= next;
// 		end 
// 	end 


// 	//store, from LLC to memory - write


// endmodule : cacheline_adaptor
