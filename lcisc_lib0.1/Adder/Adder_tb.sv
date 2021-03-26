
`timescale 1ns/1ns
import EV_types::*;
import Adder::*;
import Operation_pkg::*;
module AdderIntTwoComplement_tb;

EV_types::execution_ev_union test;
EV_types::execution_ev_union result;
adder_a operationComponents;
logic clk;



initial begin
	test.all<= 'd0;
	test.word[1] <= 35;
	test.word[2] <= 67;
	test.word[3] <= 10;
	test.word[4] <= 94;
	test.word[5] <= 154;
	operationComponents = adder_o(a(1),a(2),6);
	test.execution_ev.thread.opcodes[0:$bits(adder_a)-1] <=operationComponents;#5;
	assert(result.u32[6] == 35+67) else $error("add.1 failed");
	test<=result;#5;

	operationComponents = adder_o(i(15),a(2),8);
	test.execution_ev.thread.opcodes[0:$bits(adder_a)-1] <=operationComponents;#5;
	assert(result.u32[8] == 15+67) else $error("add.2 failed");
	test<=result;#5;
	
	
	operationComponents = adder_o(a(3),a(4),32);
	test.execution_ev.thread.opcodes[0:$bits(adder_a)-1] <=operationComponents;#5;
	assert(result.u32[32] == 10+94) else $error("add.3 failed");
	test<=result;#5;


	operationComponents = adder_o(a(5),a(2),48);
	test.execution_ev.thread.opcodes[0:$bits(adder_a)-1] <=operationComponents;#5;
	assert(result.u32[48] == 154+67) else $error("add.4 failed");
	test<=result;#5;

	operationComponents = adder_o(6,32,50);
	test.execution_ev.thread.opcodes[0:$bits(adder_a)-1] <=operationComponents;#5;
	assert(result.u32[50] == 35+67+10+94) else $error("add.5 failed");
	test<=result;#5;

	operationComponents = adder_o(48,50,1);
	test.execution_ev.thread.opcodes[0:$bits(adder_a)-1] <=operationComponents;#5;
	assert(result.u32[1] == 154+67+ 35+67+10+94) else $error("add.6 failed");
	test<=result;#5;

	operationComponents = adder_o(i(-15),a(8),10);
	test.execution_ev.thread.opcodes[0:$bits(adder_a)-1] <=operationComponents;#5;
	assert(result.u32[10] == -15+15+67) else $error("add.7 failed");
	test<=result;#5;

	$display("adder testing done");
end;

always_comb begin
	adder_a args; assign args = test.execution_ev.thread.opcodes[0:$bits(adder_a)-1];
	result = adder_f(test,args);
end;

always begin
	clk <= 0; #5;
	clk <= 1; #5;
end;

endmodule;