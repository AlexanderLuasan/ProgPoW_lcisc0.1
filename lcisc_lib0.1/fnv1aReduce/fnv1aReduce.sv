
import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package fnv1aReduce;
import Operation_pkg::*;





typedef struct packed{
	address_u32_t arr;
	address_u32_t length;
	address_u32_t dest;
	address_u32_t inital;
	SimpleConditional::singleFlagConditional_a conditionalFlag;
} fnv1aReduce_a;


function fnv1aReduce_a fnv1aReduce_o(
input address_u32_t arr,input address_u32_t length, input address_u32_t dest,input address_u32_t inital,
input SimpleConditional::conditionalFlagSelect_t conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );
	if(arr<0)
		$warning("negative arr");
	if(dest<0)
		$warning("negative dest");
	if(length < 0)
		$warning("negative length");

	fnv1aReduce_o.arr = arr;
	fnv1aReduce_o.dest = dest;
	fnv1aReduce_o.inital = inital;
	fnv1aReduce_o.length = length;
	fnv1aReduce_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);
endfunction;

integer unsigned FNV_PRIME = 'h1000193;
function integer unsigned fnv1a(integer unsigned h,integer unsigned d);
    
    fnv1a = (h ^ d) * FNV_PRIME;
    
endfunction

function EV_types::exe_env_u fnv1aReduce_f(input EV_types::exe_env_u state, input fnv1aReduce_a arguments);
integer unsigned A;
integer unsigned B;
logic [48:0] [32:0] sum;

fnv1aReduce_f=state;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	A = 	state.u32[arguments.inital];
	sum[0] = A;
	for(int i = 0; i < arguments.length; i++ ) begin
		A = 	state.u32[arguments.arr + i];
		B = 	sum[i];
		sum[i+1] = fnv1a(B,A);
	end
	fnv1aReduce_f.u32[arguments.dest] = sum[arguments.length];
end;


endfunction;


endpackage;