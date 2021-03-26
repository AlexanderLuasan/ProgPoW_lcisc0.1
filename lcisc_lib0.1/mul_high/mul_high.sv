
import EV_types::*;

package Mul_hi;
import Operation_pkg::*;
import SimpleConditional::*;

typedef struct packed{
	ia_u32_t operand1;
	ia_u32_t operand2;
	address_u32_t destination;
	singleFlagConditional_a conditionalFlag;
} mul_hi_a;

function mul_hi_a mul_hi_o(
input ia_u32_t operand1, input ia_u32_t operand2,
input address_u32_t dest, input integer conditional_flag = defaultConditionalFlagSelectValue );
	mul_hi_o.operand1 = operand1;
	mul_hi_o.operand2 = operand2;
	mul_hi_o.destination = dest;
	mul_hi_o.conditionalFlag = checkSingleCondition_o(conditional_flag);

endfunction;

function automatic EV_types::exe_env_u mul_hi_f(input EV_types::exe_env_u state, input mul_hi_a arguments);
integer unsigned A;
integer unsigned B;
longint unsigned C;
integer unsigned D;
mul_hi_f.all=state.all;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	A = ia_u32_value(arguments.operand1,state);
	B = ia_u32_value(arguments.operand2,state);
	C = A*B;
    D = C >> 32;
	mul_hi_f.u32[arguments.destination] = D;
	//$display("%d + %d = %d",A,B,A+B);
end;

endfunction;

endpackage;