`timescale 1ns/1ns
import EV_types::*;
import SimpleComparison::*;

module SimpleComparison_tb;


EV_types::ex_ev_t test;
EV_types::ex_ev_t result;
comparison_a operationComponents;
logic clk;
comparison_a args;

initial begin
test = 0;
test.data.u32[3] = 15;
test.data.u32[4] = 110;
test.data.u32[5] = 36;
test.data.u32[6] = 36;
test.data.u32[7] = 6;
test.data.u32[8] = 2000;
operationComponents = comparison_o(3,AltB,4,1);
test.thread.opcodes[0+flagCount:$bits(comparison_a)-1+flagCount] <= operationComponents; #5;

args = test.thread.opcodes[0+flagCount:$bits(comparison_a)-1+flagCount];
result = comparison_f(test,args);#5;
assert(result.thread.flags[0] == 1) else $error("15<110");

test=result;#5;
operationComponents = comparison_o(5,AeqB,6,2);
test.thread.opcodes[0+flagCount:$bits(comparison_a)-1+flagCount] <= operationComponents; #5;
args = test.thread.opcodes[0+flagCount:$bits(comparison_a)-1+flagCount];
result = comparison_f(test,args);#5;

assert(result.thread.flags[1] == 1) else $error("36=36");

$display("simple comparison testing done");

end;


always begin
	clk <= 0; #5;
	clk <= 1; #5;
end;



endmodule
