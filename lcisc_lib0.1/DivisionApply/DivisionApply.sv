import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package DivisionApply;
import Operation_pkg::*;


// x1,x2,x3,x4,x5... in 
//
// m
//(x1/m)(x2/m)(x3/m)(x4/m)(x5/m)
//



//


typedef struct packed{
	address_u32_t origin;
	ia_u32_t modifier;
	ia_u32_t length; 
	SimpleConditional::singleFlagConditional_a conditionalFlag;
} divisionApply_a;


function divisionApply_a divisionApply_o(
input address_u32_t origin, input ia_u32_t modifier,input ia_u32_t length,
input SimpleConditional::conditionalFlagSelect_t conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );
	if(origin<0)
		$warning("negative origin");
	if(modifier<0)
		$warning("negative modifier");
	if(length < 0)
		$warning("negative length");

	divisionApply_o.origin = origin;
	divisionApply_o.modifier = modifier;
	divisionApply_o.length = length;
	divisionApply_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);

endfunction;

function EV_types::exe_env_u divisionApply_f(input EV_types::exe_env_u state, input divisionApply_a arguments);
integer A; 
integer B;
divisionApply_f=state;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	B = 	ia_u32_value(arguments.modifier,state);
	B = (B==0)?1:B;
	for (int i = 0; i < ia_u32_value(arguments.length,state); i++ ) begin
		A = 	state.u32[arguments.origin +i];
		
		divisionApply_f.u32[arguments.origin +i] = A/B;
	end;
end;

endfunction;


endpackage;
