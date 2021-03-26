
 
import EV_types::*;

package Adder;
import Operation_pkg::*;
import SimpleConditional::*;

typedef struct packed{
	ia_u32_t operand1;
	ia_u32_t operand2;
	address_u32_t destination;
	singleFlagConditional_a conditionalFlag;
} adder_a;

function adder_a adder_o(
input ia_u32_t operand1, input ia_u32_t operand2,
input address_u32_t dest, input integer conditional_flag = defaultConditionalFlagSelectValue );
	adder_o.operand1 = operand1;
	adder_o.operand2 = operand2;
	adder_o.destination = dest;
	adder_o.conditionalFlag = checkSingleCondition_o(conditional_flag);

endfunction;

function automatic EV_types::exe_env_u adder_f(input EV_types::exe_env_u state, input adder_a arguments);
integer unsigned A;
integer unsigned B;
integer unsigned C;
adder_f.all=state.all;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	A = ia_u32_value(arguments.operand1,state);
	B = ia_u32_value(arguments.operand2,state);
	C = A+B;
	adder_f.u32[arguments.destination] = C;
	$display("%d + %d = %d",A,B,C);
end;

endfunction;

endpackage;