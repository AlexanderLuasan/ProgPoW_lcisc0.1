
 
import EV_types::*;

package Shift;
import Operation_pkg::*;
import SimpleConditional::*;

typedef struct packed{
	ia_u32_t operand1;
	ia_u32_t operand2;
	address_u32_t destination;
	singleFlagConditional_a conditionalFlag;
    logic left;
} shift_a;

function shift_a shift_o(
input ia_u32_t operand1, input ia_u32_t operand2,
input address_u32_t dest,logic left, input integer conditional_flag = defaultConditionalFlagSelectValue );
	shift_o.operand1 = operand1;
	shift_o.operand2 = operand2;
	shift_o.destination = dest;
    shift_o.left = left;
	shift_o.conditionalFlag = checkSingleCondition_o(conditional_flag);

endfunction;

function automatic EV_types::exe_env_u shift_f(input EV_types::exe_env_u state, input shift_a arguments);
integer unsigned A;
integer unsigned B;
shift_f.all=state.all;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	A = ia_u32_value(arguments.operand1,state);
	B = ia_u32_value(arguments.operand2,state) % 32;
    if(arguments.left == 1) begin
	    shift_f.u32[arguments.destination] = A<<B;
    end else begin
        shift_f.u32[arguments.destination] = A>>B;
    end
	//$display("%d + %d = %d",A,B,A+B);
end;

endfunction;

endpackage;