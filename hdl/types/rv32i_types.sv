/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER. */

package rv32i_types;
// Mux types are in their own packages to prevent identiier collisions
// e.g. pcmux::pc_plus4 and regfilemux::pc_plus4 are seperate identifiers
// for seperate enumerated types
import pcmux::*;
import marmux::*;
import cmpmux::*;
import alumux::*;
import regfilemux::*;
// import arbitermux::*;

typedef logic [31:0] rv32i_word;
typedef logic [4:0] rv32i_reg;
typedef logic [3:0] rv32i_mem_wmask;

typedef enum bit [6:0] {
	op_lui   = 7'b0110111, //load upper immediate (U type)
	op_auipc = 7'b0010111, //add upper immediate PC (U type)
	op_jal   = 7'b1101111, //jump and link (J type)
	op_jalr  = 7'b1100111, //jump and link register (I type)
	op_br	 = 7'b1100011, //branch (B type)
	op_load  = 7'b0000011, //load (I type)
	op_store = 7'b0100011, //store (S type)
	op_imm   = 7'b0010011, //arith ops with register/immediate operands (I type)
	op_reg   = 7'b0110011, //arith ops with register operands (R type)
	op_csr   = 7'b1110011  //control and status register (I type)
} rv32i_opcode;

typedef enum bit [2:0] {
	beq  = 3'b000,
	bne  = 3'b001,
	blt  = 3'b100,
	bge  = 3'b101,
	bltu = 3'b110,
	bgeu = 3'b111
} branch_funct3_t;

typedef enum bit [2:0] {
	lb  = 3'b000,
	lh  = 3'b001,
	lw  = 3'b010,
	lbu = 3'b100,
	lhu = 3'b101
} load_funct3_t;

typedef enum bit [2:0] {
	sb = 3'b000,
	sh = 3'b001,
	sw = 3'b010
} store_funct3_t;

typedef enum bit [2:0] {
	add  = 3'b000, //check bit30 for sub if op_reg opcode
	sll  = 3'b001,
	slt  = 3'b010,
	sltu = 3'b011,
	axor = 3'b100,
	sr   = 3'b101, //check bit30 for logical/arithmetic
	aor  = 3'b110,
	aand = 3'b111
} arith_funct3_t;

typedef enum bit [2:0] {
	alu_add = 3'b000,
	alu_sll = 3'b001,
	alu_sra = 3'b010,
	alu_sub = 3'b011,
	alu_xor = 3'b100,
	alu_srl = 3'b101,
	alu_or  = 3'b110,
	alu_and = 3'b111
} alu_ops;

typedef enum bit [2:0] {
	cmp_beq  = 3'b000,
	cmp_bne  = 3'b001,
	cmp_blt  = 3'b100,
	cmp_bge  = 3'b101,
	cmp_bltu = 3'b110,
	cmp_bgeu = 3'b111
} cmp_ops;

typedef enum bit [1:0] {
	br_s_not_taken  = 2'b00,
	br_w_not_taken  = 2'b01,
	br_w_taken  	= 2'b10,
	br_s_taken  	= 2'b11
} br_counter;

/*OOO structs*/

typedef struct {
	logic 	[3:0] 	tag;
	logic 			rdy;
	logic 	[31:0] 	data;
} sal_t;

typedef struct {
	sal_t 			op1;
	sal_t 			op2;
	alu_ops 		operation;
	logic 	[3:0] 	tag;
} alu_t;

typedef struct {
	logic 	[31:0] 	pc;
	logic 	[31:0] 	instruction;
	logic 	[2:0] 	funct3;
	logic 	[6:0] 	funct7;
	rv32i_opcode 	opcode;
	logic 	[31:0] 	i_imm;
	logic 	[31:0] 	s_imm;
	logic 	[31:0] 	b_imm;
	logic 	[31:0] 	u_imm;
	logic 	[31:0] 	j_imm;
	logic 	[4:0] 	rs1;
	logic 	[4:0] 	rs2;
	logic 	[4:0] 	rd;
	logic 			is_br_instr;
	logic 			br_pred;
	logic	[31:0]	branch_pc;
} pci_t;

typedef struct {
	pci_t			pc_info;
	logic	[31:0]	data;
	logic			rdy;
	logic			valid;
} rob_t;

typedef struct {
	logic	[31:0]	data;
	logic	[3:0]	tag;
	logic	busy;
} reg_entry_t;
  
typedef struct{
	alu_ops 		alu_opcode; // set this to an actual struct like alu_ops;
	cmp_ops 		cmp_opcode;
	logic [3:0] 	tag;
	logic 			busy_r1; // 1 if the r1 value is a tag, 0 if a constant value
	logic 			busy_r2; // 1 if the r2 value is a tag, 0 if a constant value
	logic [31:0] 	r1;
	logic [31:0] 	r2;
	// logic [31:0] pc; // change this to a pci struct
	logic 			valid;
} rs_t;

typedef struct{
	pci_t 			pc_info;		// pc info
	logic [3:0] 	rd_tag;			// rob tag
	logic [31:0] 	data;			// data loaded in
	logic 			data_is_tag;
	logic [31:0] 	addr;			// addr for mem loc
	logic 			addr_is_tag;	// if addr field is tag or not
} lsq_t;

typedef struct{
	pci_t 			pc_info;		// pc info
	logic 	[1:0] 	counter; 		// counter
	logic 			valid;
} br_pred_t;

endpackage : rv32i_types
