
import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package AdditionMap;
import Operation_pkg::*;

// y1,y2,y3,y4,y5... in 
// x1,x2,x3,x4,x5... in 
//
//(y1-x1)(y2-x2)(y3-x3)(y4-x4)(y5-x5)
//



//



typedef struct packed{
	address_u32_t origin;
	address_u32_t modifier;
	address_u32_t length; 
	SimpleConditional::singleFlagConditional_a conditionalFlag;
} additionMap_a;


function additionMap_a additionMap_o(
input address_u32_t origin, input address_u32_t modifier,input integer length,
input SimpleConditional::conditionalFlagSelect_t conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );
	if(origin<0)
		$warning("negative origin");
	if(modifier<0)
		$warning("negative modifier");
	if(length < 0)
		$warning("negative length");

	additionMap_o.origin = origin;
	additionMap_o.modifier = modifier;
	additionMap_o.length = length;
	additionMap_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);

endfunction;

function EV_types::exe_env_u additionMap_f(input EV_types::exe_env_u state, input additionMap_a arguments);
integer A; 
integer B;
additionMap_f=state;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	for (int i = 0; i < arguments.length; i++ ) begin
		A = 	state.u32[arguments.origin +i];
		B = 	state.u32[arguments.modifier +i];
		additionMap_f.u32[arguments.origin +i] = A+B;
	end;
end;

endfunction;


endpackage;