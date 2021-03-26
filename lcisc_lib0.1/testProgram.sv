package my_pkg;

typedef enum logic[7:0]
{
	ADD,
	SUB,
	DIV,
	MUL
} opcode_type;


typedef logic[7:0] address_type;



typedef struct packed
{
	address_type operand1;
	address_type operand2;
	address_type dest;
	opcode_type opcode;
} program_type;


typedef union packed
{
  logic [0:15][31:0] data;
  program_type [15:0]  code;
} thread_type;

typedef struct packed
{
	opcode_type opcode;
	integer a;
	integer b;
} opcode_struct;



endpackage;