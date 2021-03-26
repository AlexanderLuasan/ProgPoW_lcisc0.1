

 
import EV_types::*;
import SimpleConditional::*;
package Move;

import Operation_pkg::*;


typedef struct packed{
	address_u32_t data1;
	address_u32_t data2;
	logic data1_pointer;
	logic data2_pointer;
	SimpleConditional::singleFlagConditional_a conditionalFlag;
} move_a;

function move_a move_o(
input integer address1 = -1, input integer address2 = -1,
input integer pointer1 = -1, input integer pointer2 = -1,
input SimpleConditional::conditionalFlagSelect_t conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );
	
if(address1>-1) begin
	move_o.data1 = address1;
	move_o.data1_pointer = 0;
end else if(pointer1>-1) begin
	move_o.data1 = pointer1;
	move_o.data1_pointer = 1;
end else 
	$warning("error move first spot undefined");
if(address2>-1) begin
	move_o.data2 = address2;
	move_o.data2_pointer = 0;
end else if(pointer2>-1) begin
	move_o.data2 = pointer2;
	move_o.data2_pointer = 1;
end else 
	$warning("error move second spot undefined");

move_o.conditionalFlag = SimpleConditional::checkSingleCondition_o(conditional_flag);

endfunction;

function automatic EV_types::exe_env_u move_f(input EV_types::exe_env_u state, input move_a arguments);
integer location1;
integer location2;
move_f.all=state.all;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin
	location1 = (arguments.data1_pointer==0)?arguments.data1:state.u32[arguments.data1];
	location2 = (arguments.data2_pointer==0)?arguments.data2:state.u32[arguments.data2];

	move_f.u32[location1] = state.u32[location2];
	move_f.u32[location2] = state.u32[location1];
end;

endfunction;

endpackage;