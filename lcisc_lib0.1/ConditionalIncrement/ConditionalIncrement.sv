
import EV_types::*;

package ConditionalIncrement;
import Operation_pkg::*;
import SimpleConditional::*;
import SimpleComparison::*;

typedef struct packed{
	address_u32_t target;
	compareOperation_t compareOperation;
	ia_u32_t comparison;
	
	ia_u32_t increment;
	singleFlagConditional_a setFlag;
	singleFlagConditional_a conditionalFlag;
} conditionalIncrement_a;

function conditionalIncrement_a conditionalIncrement_o(
input address_u32_t target, input compareOperation_t compareOperation, input ia_u32_t comparison,
input ia_u32_t increment = i(1), input integer setFlag = defaultConditionalFlagSelectValue ,input integer conditional_flag = defaultConditionalFlagSelectValue );
	conditionalIncrement_o.target = target;
	conditionalIncrement_o.comparison = comparison;
	conditionalIncrement_o.compareOperation = compareOperation;

	conditionalIncrement_o.increment = increment;
	conditionalIncrement_o.setFlag = checkSingleCondition_o(setFlag);
	conditionalIncrement_o.conditionalFlag = checkSingleCondition_o(conditional_flag);

endfunction;

function automatic EV_types::exe_env_u conditionalIncrement_f(input EV_types::exe_env_u state, input conditionalIncrement_a arguments);
integer A;
integer B;
simpleComparison_a comp_operation;
EV_types::exe_env_u intermediate;
conditionalIncrement_f = state;

if (SimpleConditional::checkSingleCondition_f(state,arguments.conditionalFlag)==1) begin

comp_operation.addressA = a(arguments.target);
comp_operation.addressB = arguments.comparison;
comp_operation.compareOperation = arguments.compareOperation;
comp_operation.setFlag = arguments.setFlag;
comp_operation.conditionalFlag = arguments.conditionalFlag;

intermediate = simpleComparison_f(state,comp_operation);
conditionalIncrement_f = intermediate;
// check if the condition was true
if(solve_comparison(ia_u32_value(a(arguments.target),intermediate),ia_u32_value(arguments.comparison,intermediate),arguments.compareOperation) == 1) begin


	A = ia_u32_value(a(arguments.target),intermediate);
	B = ia_u32_value(arguments.increment,intermediate);
	conditionalIncrement_f.u32[arguments.target] = A+B;
end;

end;
endfunction;

endpackage;
