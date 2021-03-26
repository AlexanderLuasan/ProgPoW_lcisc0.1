
import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package AccumulateReduce;
import Operation_pkg::*;

// x1,x2,x3,x4,x5... in 
//
//dest = (x1)+(x2)+(x3)+(x4)+(x5)
//



//

`define max3(a,b,c) (a>b) ? ((a > c) ? a : c ):((c > b) ? c : b)
parameter longest_register = `max3(EV_types::threadLength_u32,EV_types::dataLength_u32,EV_types::sharedLength_u32);
parameter address_longset = $clog2(longest_register);

parameter addressSize = $clog2(EV_types::EV_Length_u32);

typedef struct packed{
	address_u32_t arr;
	address_u32_t length;
	address_u32_t dest;
	SimpleConditional::singleFlagConditional_a conditionalFlag;
} accumulateReduce_a;


function accumulateReduce_a accumulateReduce_o(
input address_u32_t arr,input address_u32_t length, input address_u32_t dest,
input SimpleConditional::conditionalFlagSelect_t conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );
	if(arr<0)
		$warning("negative arr");
	if(dest<0)
		$warning("negative dest");
	if(length < 0)
		$warning("negative length");

	accumulateReduce_o.arr = arr;
	accumulateReduce_o.dest = dest;
	accumulateReduce_o.length = length;
	accumulateReduce_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);
endfunction;

function EV_types::exe_env_u accumulateReduce_f(input EV_types::exe_env_u state, input accumulateReduce_a arguments);
integer A;
integer B;
logic [longest_register:0] [32:0] sum;

accumulateReduce_f=state;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	A = 	state.u32[arguments.arr+0];
	sum[0] = A;
	for(int i = 1; i < arguments.length; i++ ) begin
		A = 	state.u32[arguments.arr + i];
		B = 	sum[i-1];
		sum[i] = B + A;
	end
	accumulateReduce_f.u32[arguments.dest] = sum[arguments.length-1];
end;


endfunction;


endpackage;