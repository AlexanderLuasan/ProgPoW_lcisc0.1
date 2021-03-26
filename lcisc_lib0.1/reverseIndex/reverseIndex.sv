import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package ReverseIndex;
import Operation_pkg::*;


typedef struct packed{
	address_u32_t  arr;
	ia_u32_t  index;
	address_u32_t dest;
	SimpleConditional::singleFlagConditional_a conditionalFlag;
} reverseIndex_a;


function reverseIndex_a reverseIndex_o(
input address_u32_t arr, input ia_u32_t index,
input address_u32_t dest,
input integer conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );
	reverseIndex_o.arr = arr;
    reverseIndex_o.index = index;
    reverseIndex_o.dest = dest;
	reverseIndex_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);
endfunction;

function EV_types::exe_env_u reverseIndex_f(input EV_types::exe_env_u state, input reverseIndex_a arguments);
integer unsigned A;
integer unsigned B;

reverseIndex_f=state;
A = ia_u32_value(arguments.index,state);
if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
    B = state.u32[arguments.dest];
	reverseIndex_f.u32[arguments.arr + A] = B;
	//$display("arridx = %d",state.u32[arguments.arr + A]);
end;


endfunction;


endpackage;