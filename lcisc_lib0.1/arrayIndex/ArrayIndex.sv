import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package ArrayIndex;
import Operation_pkg::*;


typedef struct packed{
	address_u32_t  arr;
	integer length;
	ia_u32_t  index;
	address_u32_t dest;
	SimpleConditional::singleFlagConditional_a conditionalFlag;

} arrayIndex_a;


function arrayIndex_a arrayIndex_o(
input address_u32_t arr, input ia_u32_t index,
input address_u32_t dest,integer length = 100,
input integer conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue  );
	arrayIndex_o.arr = arr;
    arrayIndex_o.index = index;
    arrayIndex_o.dest = dest;
	arrayIndex_o.length = length;
	arrayIndex_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);
endfunction;

function EV_types::exe_env_u arrayIndex_f(input EV_types::exe_env_u state, input arrayIndex_a arguments);
integer A;
integer B;

arrayIndex_f=state;
A = ia_u32_value(arguments.index,state) % arguments.length;
if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
    B = state.u32[arguments.arr + A];
	arrayIndex_f.u32[arguments.dest] = B;
	$display("arridx[%d] = %d",A,state.u32[arguments.arr + A]);
end;


endfunction;


endpackage;