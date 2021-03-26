
import EV_types::*;

package SimpleConditional;

typedef logic [$clog2(EV_types::flagCount)-1:0] flagSelect_t;
typedef logic [$clog2(EV_types::flagCount):0] conditionalFlagSelect_t;

parameter defaultConditionalFlagSelectValue = 0;


//flag values
/*
1,2,3,... flag count check the given flag number 
-1,-2,-3 ... - flag count check the given flag number and negate

-flag count .... inf  : never
flag count ... inf    : always

*/

//let abs(a) = (a>-a) ? a:-a;

//`define abs(a) (a>-a) ? a:-a;

typedef struct packed{
	flagSelect_t flag;
	logic condition;
	logic negate;
}singleFlagConditional_a;


function singleFlagConditional_a checkSingleCondition_o(
input integer conditional_flag = defaultConditionalFlagSelectValue);

if(conditional_flag == defaultConditionalFlagSelectValue) begin // always
checkSingleCondition_o.flag = 0;
checkSingleCondition_o.condition = 0;
checkSingleCondition_o.negate = 0;
end else if(conditional_flag<=EV_types::flagCount && conditional_flag>=-EV_types::flagCount) begin//given a flag
    checkSingleCondition_o.flag = ((conditional_flag>-conditional_flag) ? conditional_flag: - conditional_flag) -1 ;
    checkSingleCondition_o.condition = 1;
    if(conditional_flag<0) begin
	checkSingleCondition_o.negate = 1;
    end else begin
	checkSingleCondition_o.negate = 0;
    end
end else begin
    checkSingleCondition_o.flag = 0;
    checkSingleCondition_o.condition = 0;
    if(conditional_flag<0) begin
	checkSingleCondition_o.negate = 1;
    end else begin
	checkSingleCondition_o.negate = 0;
    end
end
endfunction;

function automatic logic checkSingleCondition_f(input EV_types::exe_env_u state, input singleFlagConditional_a arguments);
logic R = 0;
if(arguments.condition==0) begin
    if(arguments.negate == 0) begin
	R = 1;
    end else begin
	R = 0;
    end
end else if(state.execution_ev.thread.flags[arguments.flag]==1) begin
   if(arguments.negate == 0) begin
	R = 1;
    end else begin
	R = 0;
    end
end else begin
    if(arguments.negate == 0) begin
	R = 0;
    end else begin
	R = 1;
    end
end
//$display("checking condition Flag =%D, neg = %b, conditino = %b,  R = %b",arguments.flag,arguments.negate,arguments.condition,R);
checkSingleCondition_f = R;
endfunction;


endpackage;