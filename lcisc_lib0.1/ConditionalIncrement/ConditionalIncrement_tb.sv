

`timescale 1ns/1ns
import EV_types::*;
import ConditionalIncrement::*;
import SimpleComparison::*;
import Operation_pkg::*;
module ConditionalIncrement_tb;

EV_types::execution_ev_union test;
EV_types::execution_ev_union result;
conditionalIncrement_a operationComponents;
logic clk;



initial begin
	test.all<= 'd0;
	test.word[1] <= 35;
	test.word[2] <= 67;
	test.word[3] <= 10;
	test.word[4] <= 94;
	test.word[5] <= 154;

	//increment a1 by i1 if a1<a2 a1 = 35 a2 = 67 
	operationComponents = conditionalIncrement_o(a(1),AltB,a(2));
	test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8] <=operationComponents;#5;
	assert(result.u32[1] == 36) else $error("conditionalIncrement.1 failed");
	assert(result.execution_ev.thread.flags[0] == 0) else $error("conditionalIncrement.1 failed");
	test<=result;#5;

	//increment a2 by i15 if a2<a5 a2 = 67 a5 = 154 set flag 2
	operationComponents = conditionalIncrement_o(2,AltB,a(5),i(15),2);
	test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8] <=operationComponents;#5;
	assert(result.u32[2] == 67+15) else $error("conditionalIncrement.2 failed");
	assert(result.execution_ev.thread.flags[2-1] == 1) else $error("conditionalIncrement.2 failed");
	test<=result;#5;
	
	//if not flag 2 so should fail
	operationComponents = conditionalIncrement_o(2,AltB,a(5),i(15),1,-2);
	test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8] <=operationComponents;#5;
	assert(result.u32[2] == 67+15) else $error("conditionalIncrement.3 failed");//same number
	assert(result.execution_ev.thread.flags[2-1] == 1) else $error("conditionalIncrement.3 failed");//flag is the same
	assert(result.execution_ev.thread.flags[1-1] == 0) else $error("conditionalIncrement.3 failed");//flag is the same
	test<=result;#5;

	//increment test 
	operationComponents = conditionalIncrement_o(3,AgtB,i(0),i(-2),1);
	test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8] <=operationComponents;#5;
	assert(result.u32[3] == 8) else $error("conditionalIncrement.3 failed");//same number
	assert(result.execution_ev.thread.flags[1-1] == 1) else $error("conditionalIncrement.4 failed");//flag is the same
	test<=result;#5;

	operationComponents = conditionalIncrement_o(3,AgtB,i(0),i(-2),1);
	test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8] <=operationComponents;#5;
	assert(result.u32[3] == 6) else $error("conditionalIncrement.3 failed");//same number
	assert(result.execution_ev.thread.flags[1-1] == 1) else $error("conditionalIncrement.5 failed");//flag is the same
	test<=result;#5;

	operationComponents = conditionalIncrement_o(3,AgtB,i(0),i(-2),1);
	test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8] <=operationComponents;#5;
	assert(result.u32[3] == 4) else $error("conditionalIncrement.3 failed");//same number
	assert(result.execution_ev.thread.flags[1-1] == 1) else $error("conditionalIncrement.6 failed");//flag is the same
	test<=result;#5;

	operationComponents = conditionalIncrement_o(3,AgtB,i(0),i(-2),1);
	test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8] <=operationComponents;#5;
	assert(result.u32[3] == 2) else $error("conditionalIncrement.3 failed");//same number
	assert(result.execution_ev.thread.flags[1-1] == 1) else $error("conditionalIncrement.7 failed");//flag is the same
	test<=result;#5;

	operationComponents = conditionalIncrement_o(3,AgtB,i(0),i(-2),1);
	test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8] <=operationComponents;#5;
	assert(result.u32[3] == 0) else $error("conditionalIncrement.3 failed");//same number
	assert(result.execution_ev.thread.flags[1-1] == 1) else $error("conditionalIncrement.8 failed");//flag is the same
	test<=result;#5;

	operationComponents = conditionalIncrement_o(3,AgtB,i(0),i(-2),1);
	test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8] <=operationComponents;#5;
	assert(result.u32[3] == 0) else $error("conditionalIncrement.3 failed");//same number
	assert(result.execution_ev.thread.flags[1-1] == 0) else $error("conditionalIncrement.9 failed");//flag is the same
	test<=result;#5;

	$display("conditional increment testing done");
end;

always_comb begin
	conditionalIncrement_a args;
	args = test.execution_ev.thread.opcodes[8:$bits(conditionalIncrement_a)-1+8];
	result = conditionalIncrement_f(test,args);
end;

always begin
	clk <= 0; #5;
	clk <= 1; #5;
end;

endmodule;