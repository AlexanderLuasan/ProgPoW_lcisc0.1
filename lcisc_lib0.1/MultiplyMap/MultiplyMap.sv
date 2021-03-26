
import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package MultiplyMap;
import Operation_pkg::*;
// y1,y2,y3,y4,y5... in 
// x1,x2,x3,x4,x5... in 
//
//(y1*x1)(y2*x2)(y3*x3)(y4*x4)(y5*x5)
//



//

//`define max3(a,b,c) (a>b) ? ((a > c) ? a : c ):((c > b) ? c : b)
//parameter longest_register = `max3(EV_types::threadLength_u32,EV_types::dataLength_u32,EV_types::sharedLength_u32);
//parameter address_longset = $clog2(longest_register);

//parameter address32 = $clog2(EV_types::EV_Length_word);

typedef struct packed{
	address_u32_t origin;
	address_u32_t  modifier;
	address_u32_t  length; 
	SimpleConditional::singleFlagConditional_a conditionalFlag;
} multiplyMap_a;


function multiplyMap_a multiplyMap_o(
input address_u32_t origin, input address_u32_t modifier,input integer length,
input SimpleConditional::conditionalFlagSelect_t conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );

	if(origin<0)
		$warning("negative origin");
	if(modifier<0)
		$warning("negative modifier");
	if(length < 0)
		$warning("negative length");
	multiplyMap_o.origin = origin;
	multiplyMap_o.modifier = modifier;
	multiplyMap_o.length = length;
	multiplyMap_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);

endfunction;

function EV_types::exe_env_u multiplyMap_f(input EV_types::exe_env_u state, input multiplyMap_a arguments);
integer unsigned A; 
integer unsigned B;
integer unsigned C;
multiplyMap_f=state;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	for (int i = 0; i < arguments.length; i++ ) begin
		A = 	state.u32[arguments.origin+i];
		B = 	state.u32[arguments.modifier+i];
		C = A*B;
		multiplyMap_f.u32[arguments.origin + i] = C;
	end;
end;

endfunction;


endpackage;