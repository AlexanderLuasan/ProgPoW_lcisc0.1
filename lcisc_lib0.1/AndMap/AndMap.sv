
import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package AndMap;
import Operation_pkg::*;

typedef struct packed{
	address_u32_t origin;
	address_u32_t  modifier;
	address_u32_t  length; 
	SimpleConditional::singleFlagConditional_a conditionalFlag;
} andMap_a;


function andMap_a andMap_o(
input address_u32_t origin, input address_u32_t modifier,input integer length,
input SimpleConditional::conditionalFlagSelect_t conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );

	if(origin<0)
		$warning("negative origin");
	if(modifier<0)
		$warning("negative modifier");
	if(length < 0)
		$warning("negative length");
	andMap_o.origin = origin;
	andMap_o.modifier = modifier;
	andMap_o.length = length;
	andMap_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);

endfunction;

function EV_types::exe_env_u andMap_f(input EV_types::exe_env_u state, input andMap_a arguments);
integer unsigned A; 
integer unsigned B;
integer unsigned C;
andMap_f=state;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	for (int i = 0; i < arguments.length; i++ ) begin
		A = 	state.u32[arguments.origin+i];
		B = 	state.u32[arguments.modifier+i];
        C = A&B;
		andMap_f.u32[arguments.origin + i] = C;		
	end;
end;

endfunction;


endpackage;