
`timescale 1ns/1ns
import AccumulateReduce::*;
import EV_types::*;
import EV_enums::*;

module AccumulateReduce_tb;

ex_ev_t test;
ex_ev_t result;
logic clk;
initial begin
	test = 0;
	test.data.u32[0] = 10;
	test.data.u32[1] = 11;
	test.data.u32[2] = 12;
	test.data.u32[3] = 13;
	test.thread.opcodes[0:$bits(accumulateReduce_a)-1] = accumulateReduce_o(dataAddress_u32,2,dataAddress_u32);#20;



    	assert (result.data.u32[0] == 21) else $error("AccumulateReduce_t1.1_failed");//dest = 0 is data[0]
	assert (result.data.u32[1] == 11) else $error("AccumulateReduce_t1.2_failed");
	assert (result.data.u32[2] == 12)else $error("AccumulateReduce_t1.3_failed");
	assert (result.data.u32[3] == 13)else $error("AccumulateReduce_t1.4_failed");//unmodified

	


	test = 0;
	test.data.u32[0] = -67;
	test.data.u32[1] = -15;
	test.data.u32[2] = -24;
	test.data.u32[3] = 47;
	test.data.u32[4] = 26;
	test.data.u32[5] = 186;
	test.data.u32[6] = 255;
	test.data.u32[7] = 53;
	test.data.u32[8] = 54;


	test.thread.opcodes[0:$bits(accumulateReduce_a)-1] = accumulateReduce_o(dataAddress_u32,8,sharedAddress_u32);#20;

	assert (result.data.u32[0] == -67) else $error("AccumulateReduce_t2.1_failed");//unmodified
	assert (result.data.u32[1] ==-15) else $error("AccumulateReduce_t2.2_failed");
	assert (result.data.u32[2] == -24)else $error("AccumulateReduce_t2.3_failed");
	assert (result.data.u32[3] == 47)else $error("AccumulateReduce_t2.4_failed");
	assert (result.data.u32[4] == 26) else $error("AccumulateReduce_t2.5_failed");
	assert (result.data.u32[5] == 186) else $error("AccumulateReduce_t2.6_failed");
	assert (result.data.u32[6] == 255)else $error("AccumulateReduce_t2.7_failed");
	assert (result.data.u32[7] == 53)else $error("AccumulateReduce_t2.8_failed");
	assert (result.data.u32[8] == 54)else $error("AccumulateReduce_t2.9_failed");
	assert (result.shared.u32[0] == 461) else $error("AccumulateReduce_t2.10_failed");//dest
	assert (result.thread.u32[0] == 0) else $error("AccumulateReduce_t2.11_failed");//unmodified value 

	test = 0;
	test.shared.u32[0] = -10;
	test.shared.u32[1] = -35;
	test.shared.u32[2] = 24;
	test.shared.u32[3] = -47;
	test.shared.u32[4] = 70;
	test.shared.u32[5] = 57;
	test.shared.u32[6] = -375;
	test.shared.u32[7] = 357;
	test.shared.u32[8] = 45;
	test.thread.opcodes[0:$bits(accumulateReduce_a)-1] = accumulateReduce_o(sharedAddress_u32,4,threadAddress_u32);#20;

	assert (result.shared.u32[0] == -10) else $error("AccumulateReduce_t3.1_failed");
	assert (result.shared.u32[1] == -35) else $error("AccumulateReduce_t3.2_failed");
	assert (result.shared.u32[2] == 24)else $error("AccumulateReduce_t3.3_failed");
	assert (result.shared.u32[3] == -47)else $error("AccumulateReduce_t3.4_failed");
	assert (result.shared.u32[4] == 70) else $error("AccumulateReduce_t3.5_failed");
	assert (result.shared.u32[5] == 57) else $error("AccumulateReduce_t3.6_failed");
	assert (result.shared.u32[6] == -375)else $error("AccumulateReduce_t3.7_failed");
	assert (result.shared.u32[7] == 357)else $error("AccumulateReduce_t3.8_failed");
	assert (result.shared.u32[8] == 45)else $error("AccumulateReduce_t3.9_failed");

	assert (result.thread.u32[0] == -68)else $error("AccumulateReduce_t3.10_failed");


	//check maximum

	test = 0;
	test.data.u32[0] = 1;
	test.data.u32[dataLength_u32-1] = 43;
	test.thread.opcodes[0:$bits(accumulateReduce_a)-1] = accumulateReduce_o(dataAddress_u32,dataLength_u32,threadAddress_u32);#20;
	
	assert (result.data.u32[0] == 1) else $error("AccumulateReduce_t4.1_failed");
	assert (result.data.u32[dataLength_u32-1] == 43) else $error("AccumulateReduce_t4.2_failed");
	assert (result.thread.u32[0] == 44)else $error("AccumulateReduce_t4.3_failed");
	
	$display("AccumulateReduce_tb tested completed");
end;

always_comb begin
	accumulateReduce_a args; 
	args = test.thread.opcodes[0:$bits(accumulateReduce_a)-1];
	result = accumulateReduce_f(test,args);
end;

always begin
	clk <= 0; #5;
	clk <= 1; #5;
end;

endmodule;