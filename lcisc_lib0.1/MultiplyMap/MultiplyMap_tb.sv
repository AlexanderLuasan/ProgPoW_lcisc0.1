
`timescale 1ns/1ns
import MultiplyMap::*;
import EV_types::*;
import EV_enums::*;

module multiplyMap_tb;

ex_ev_t test;
ex_ev_t result;
logic clk;
let min(a,b) = a<b?a:b;
integer maximum_location;
integer maximum_length;
integer corrupted_swap;
initial begin
	test = 0;
	test.data.u32[0] = 10;
	test.data.u32[1] = 11;
	test.data.u32[2] = 12;
	test.data.u32[3] = 13;
	test.thread.opcodes[0:$bits(multiplyMap_a)-1] = multiplyMap_o(dataAddress_u32,dataAddress_u32,2);#20;



    	assert (result.data.u32[0] == 100) else $error("multiplyMap_t1.1_failed");
	assert (result.data.u32[1] == 121) else $error("multiplyMap_t1.2_failed");
	assert (result.data.u32[2] == 12)else $error("multiplyMap_t1.3_failed");
	assert (result.data.u32[3] == 13)else $error("multiplyMap_t1.4_failed");//unmodified


	test = 0;
	test.data.u32[0] = -67;
	test.data.u32[1] = -15;
	test.data.u32[2] = -24;
	test.data.u32[3] = 47;
	test.data.u32[4] = 26;
	test.data.u32[5] = 186;
	test.data.u32[6] = -255;
	test.data.u32[7] = 53;
	test.data.u32[8] = 54;

	test.shared.u32[0] = -10;
	test.shared.u32[1] = -35;
	test.shared.u32[2] = 24;
	test.shared.u32[3] = -47;
	test.shared.u32[4] = 70;
	test.shared.u32[5] = 57;
	test.shared.u32[6] = -375;
	test.shared.u32[7] = 357;
	test.shared.u32[8] = 45;

	test.thread.opcodes[0:$bits(multiplyMap_a)-1] = multiplyMap_o(dataAddress_u32,sharedAddress_u32,8);#20;

	assert (result.data.u32[0] == 670) else $error("multiplyMap_t2.1_failed");
	assert (result.data.u32[1] == 525) else $error("multiplyMap_t2.2_failed");
	assert (result.data.u32[2] == -576)else $error("multiplyMap_t2.3_failed");
	assert (result.data.u32[3] == -2209)else $error("multiplyMap_t2.4_failed");
	assert (result.data.u32[4] == 1820) else $error("multiplyMap_t2.5_failed");
	assert (result.data.u32[5] == 10602) else $error("multiplyMap_t2.6_failed");
	assert (result.data.u32[6] == 95625)else $error("multiplyMap_t2.7_failed");
	assert (result.data.u32[7] == 18921)else $error("multiplyMap_t2.8_failed");
	assert (result.data.u32[8] == 54)else $error("multiplyMap_t2.9_failed");//unmodified value after length

	assert (result.thread.u32[0] == 0) else $error("multiplyMap_t2.10_failed");//unmodified value 

	assert (result.shared.u32[0] == -10) else $error("multiplyMap_t2.11_failed");
	assert (result.shared.u32[1] == -35) else $error("multiplyMap_t2.12_failed");
	assert (result.shared.u32[2] == 24)else $error("multiplyMap_t2.13_failed");
	assert (result.shared.u32[3] == -47)else $error("multiplyMap_t2.14_failed");
	assert (result.shared.u32[4] == 70) else $error("multiplyMap_t2.15_failed");
	assert (result.shared.u32[5] == 57) else $error("multiplyMap_t2.16_failed");
	assert (result.shared.u32[6] == -375)else $error("multiplyMap_t2.17_failed");
	assert (result.shared.u32[7] == 357)else $error("multiplyMap_t2.18_failed");
	assert (result.shared.u32[8] == 45)else $error("multiplyMap_t2.19_failed");


	//swap max sections
	
	//data and thread
	maximum_length= min(threadLength_u32,dataLength_u32);
	maximum_location =maximum_length-1;
	test = 0;
	test.data.u32[0] = 1;
	test.data.u32[maximum_location] = 2;
	test.thread.u32[0] = 3;
	test.thread.u32[maximum_location] = 4;//could be corrupt instruction ??????
	 
	test.thread.opcodes[0:$bits(multiplyMap_a)-1] = multiplyMap_o(dataAddress_u32,threadAddress_u32,maximum_length);
	corrupted_swap = test.thread.u32[maximum_location];#20;
	assert (result.data.u32[0] == 3) else $error("multiplyMap_t3.1_failed");
	assert (result.data.u32[maximum_location] == 8) else assert (result.data.u32[maximum_location] == 2*corrupted_swap) $warning("multiplyMap_t3.2_corrupted"); else $error("multiplyMap_t3.2_failed");
	assert (result.thread.u32[0] == 3)else $error("multiplyMap_t3.3_failed");
	assert (result.thread.u32[maximum_location] == 4)else assert (result.data.u32[maximum_location] == corrupted_swap) $warning("multiplyMap_t3.4_corrupted");  else $error("multiplyMap_t3.4_failed");
	
	//data and shared
	maximum_length= min(dataLength_u32,sharedLength_u32);
	maximum_location =maximum_length-1;
	test = 0;
	test.data.u32[0] = 1;
	test.data.u32[maximum_location] = 2;
	test.shared.u32[0] = 3;
	test.shared.u32[maximum_location] = 4;
	 
	test.thread.opcodes[0:$bits(multiplyMap_a)-1] = multiplyMap_o(sharedAddress_u32,dataAddress_u32,maximum_length);#20;
	assert (result.data.u32[0] == 1) else $error("multiplyMap_t4.1_failed");
	assert (result.data.u32[maximum_location] == 2) else $error("multiplyMap_t4.2_failed");
	assert (result.shared.u32[0] == 3)else $error("multiplyMap_t4.3_failed");
	assert (result.shared.u32[maximum_location] == 8)else $error("multiplyMap_t4.4_failed");

	//shared and thread
	maximum_length= min(threadLength_u32,sharedLength_u32);
	maximum_location =maximum_length-1;
	test = 0;
	test.shared.u32[0] = 1;
	test.shared.u32[maximum_location] = 2;
	test.thread.u32[0] = 3;
	test.thread.u32[maximum_location] = 4;//could be corrupt instruction ??????
	 
	test.thread.opcodes[0:$bits(multiplyMap_a)-1] = multiplyMap_o(threadAddress_u32,sharedAddress_u32,maximum_length);
	corrupted_swap = test.thread.u32[maximum_location];#20;
	assert (result.shared.u32[0] == 1) else $error("multiplyMap_t5.1_failed");
	assert (result.shared.u32[maximum_location] == 2) else $error("multiplyMap_t5.2_failed");
	assert (result.thread.u32[0] == 3)else $error("multiplyMap_t5.3_failed");
	assert (result.thread.u32[maximum_location] == 8) else assert (result.thread.u32[maximum_location] == corrupted_swap*2) $warning("multiplyMap_t4.4_corrupted"); else $error("multiplyMap_t5.4_failed");

	$display("MultiplyMap_tb tested complete");
end;

always_comb begin
	multiplyMap_a args; 
	args = test.thread.opcodes[0:$bits(multiplyMap_a)-1];
	result = multiplyMap_f(test,args);
end;

always begin
	clk <= 0; #5;
	clk <= 1; #5;
end;

endmodule;