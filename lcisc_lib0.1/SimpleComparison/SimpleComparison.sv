import EV_types::*;
import SimpleConditional::*;

package SimpleComparison;



import Operation_pkg::*;






typedef struct packed{
	SimpleConditional::singleFlagConditional_a conditionalFlag;
	SimpleConditional::singleFlagConditional_a setFlag;
	ia_u32_t addressA;
	ia_u32_t addressB;
	compareOperation_t compareOperation; 
}simpleComparison_a;

function simpleComparison_a simpleComparison_o(
input ia_u32_t  addressA,input compareOperation_t comparisonOperation,
input ia_u32_t  addressB, input integer flag = SimpleConditional::defaultConditionalFlagSelectValue,
input integer conditional_flag = SimpleConditional::defaultConditionalFlagSelectValue );

simpleComparison_o.setFlag = SimpleConditional::checkSingleCondition_o(flag);
simpleComparison_o.addressA = addressA;
simpleComparison_o.addressB = addressB;
simpleComparison_o.compareOperation = comparisonOperation;
simpleComparison_o.conditionalFlag=SimpleConditional::checkSingleCondition_o(conditional_flag);

endfunction;

function logic solve_comparison(input integer unsigned A,input integer unsigned B,input compareOperation_t compareOperation);
logic R;
case (compareOperation)
	AgtB:   R = A>B ?1:0;
	AltB:   R = A<B ?1:0;
	AeqB:   R = A==B?1:0;
	AneqB:  R = A!=B?1:0;
	AgteqB: R = A>=B?1:0;
	AlteqB: R = A<=B?1:0;
endcase;
solve_comparison = R;

endfunction;
function automatic EV_types::exe_env_u simpleComparison_f(input EV_types::exe_env_u state, input simpleComparison_a arguments);
EV_types::u32_t A; 
EV_types::u32_t B;
logic R = 0;

simpleComparison_f.all = state.all;



A=ia_u32_value(arguments.addressA,state);
B=ia_u32_value(arguments.addressB,state);

R = solve_comparison(A,B,arguments.compareOperation);
//$display("comparison flag = %d R = %b,A = %D,B=%D,addressA = %D,addressB = %D",arguments.setFlag,R,A,B,arguments.addressA,arguments.addressB);
if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin

    if(arguments.setFlag.condition==1) begin//must have a condition
    	if(arguments.setFlag.negate == 1) begin//flip if negate
	    R = (R==1)?-1:1;
        end
        simpleComparison_f.execution_ev.thread.flags[arguments.setFlag.flag]=R;//set the flag
    end
end

endfunction;

endpackage;
