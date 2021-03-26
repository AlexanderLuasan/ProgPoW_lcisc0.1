
 
import EV_types::*;

package Subtract;
import Operation_pkg::*;
import SimpleConditional::*;

typedef struct packed{
	ia_u32_t operand1;
	ia_u32_t operand2;
	address_u32_t destination;
	singleFlagConditional_a conditionalFlag;
} subtract_a;

function subtract_a subtract_o(
input ia_u32_t operand1, input ia_u32_t operand2,
input address_u32_t dest, input integer conditional_flag = defaultConditionalFlagSelectValue );
	subtract_o.operand1 = operand1;
	subtract_o.operand2 = operand2;
	subtract_o.destination = dest;
	subtract_o.conditionalFlag = checkSingleCondition_o(conditional_flag);

endfunction;

function EV_types::exe_env_u subtract_f(input EV_types::exe_env_u state, input subtract_a arguments);
integer A;
integer B;
subtract_f.all=state.all;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	A = ia_u32_value(arguments.operand1,state);
	B = ia_u32_value(arguments.operand2,state);
	subtract_f.u32[arguments.destination] = A-B;
end;

endfunction;

endpackage;