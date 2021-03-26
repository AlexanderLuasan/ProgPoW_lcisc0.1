
 
import EV_types::*;

package Modulo;
import Operation_pkg::*;
import SimpleConditional::*;

typedef struct packed{
	ia_u32_t operand1;
	ia_u32_t operand2;
	address_u32_t destination;
	singleFlagConditional_a conditionalFlag;
} modulo_a;

function modulo_a modulo_o(
input ia_u32_t operand1, input ia_u32_t operand2,
input address_u32_t dest, input integer conditional_flag = defaultConditionalFlagSelectValue );
	modulo_o.operand1 = operand1;
	modulo_o.operand2 = operand2;
	modulo_o.destination = dest;
	modulo_o.conditionalFlag = checkSingleCondition_o(conditional_flag);

endfunction;

function EV_types::exe_env_u modulo_f(input EV_types::exe_env_u state, input modulo_a arguments);
integer unsigned A;
integer unsigned B;
modulo_f.all=state.all;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	A = ia_u32_value(arguments.operand1,state);
	B = ia_u32_value(arguments.operand2,state);
	modulo_f.u32[arguments.destination] = A%B;
	$display("%d mod %d = %d",A,B,A%B);
end;

endfunction;

endpackage;