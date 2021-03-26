import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package ArraySwap;
import Operation_pkg::*;

// x1,x2,x3,x4,x5,x6... in x
// y1,y2,y3,y4,y5,y6... in y
//
//swap(x,0,y,2,3)
//
// y3,y4,y5,x4,x5,x6... in x
// y1,y2,x1,x2,x3,y6... in y



//

//`define max(a,b) = (a > b) ? a : b
`define max3(a,b,c) (a>b) ? ((a > c) ? a : c ):((c > b) ? c : b)
parameter longest_register = `max3(EV_types::threadLength_u32,EV_types::dataLength_u32,EV_types::sharedLength_u32);
parameter address_longset = $clog2(longest_register);

parameter address_u32 = $clog2(EV_types::EV_Length_u32);

typedef struct packed{
	address_u32_t  arr_1;
	address_u32_t  arr_2;
	address_u32_t length;
	SimpleConditional::singleFlagConditional_a conditionalFlag;
} arraySwap_a;


function arraySwap_a arraySwap_o(
input address_u32_t arr_1, input address_u32_t arr_2,
input address_u32_t length,
input integer conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );
	if(arr_1<0)
		$warning("negative arr_1");
	if(arr_2<0)
		$warning("negative arr_2");
	if(length < 0)
		$warning("negative length");
	arraySwap_o.arr_1 = arr_1;
	arraySwap_o.arr_2 = arr_2;
	arraySwap_o.length = length;
	arraySwap_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);
endfunction;

function EV_types::exe_env_u arraySwap_f(input EV_types::exe_env_u state, input arraySwap_a arguments);
integer A;
logic [longest_register:0] [32:0] temp;

arraySwap_f=state;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	for(int i = 0;i< arguments.length;i++) begin//copy first to temp register
		A = 	state.u32[arguments.arr_1 + i];
		arraySwap_f.u32[arguments.arr_2+i] = A;
		temp[i] = A;
	end;

	for(int i = 0;i< arguments.length;i++) begin//copy second to first register
		A = 	state.u32[arguments.arr_2 + i];
		arraySwap_f.u32[arguments.arr_1+i] = A;
	end;

	
end;


endfunction;


endpackage;