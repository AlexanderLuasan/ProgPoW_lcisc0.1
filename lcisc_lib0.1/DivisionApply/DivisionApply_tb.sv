`timescale 1ns/1ns
import DivisionApply::*;
import EV_types::*;
import EV_enums::*;
import Operation_pkg::*;

module DivisionApply_tb;

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
	test.thread.opcodes[0:$bits(divisionApply_a)-1] = divisionApply_o(dataAddress_u32,dataAddress_u32,i(2));#20;



    	assert (result.data.u32[0] == 1) else $error("DifferenceMap_t1.1_failed");
	assert (result.data.u32[1] == 1) else $error("DifferenceMap_t1.2_failed");
	assert (result.data.u32[2] == 12)else $error("DivisionApply_t1.3_failed");
	assert (result.data.u32[3] == 13)else $error("DivisionApply_t1.4_failed");//unmodified


	test = 0;
	test.data.u32[0] = -67;
	test.data.u32[1] = -15;
	test.data.u32[2] = -24;
	test.data.u32[3] = 47;
	test.data.u32[4] = 26;
	test.data.u32[5] = 186;
	test.data.u32[6] = -255;
	test.data.u32[7] = 34567;
	test.data.u32[8] = 54;

	test.shared.u32[0] = 10;//-57
	test.shared.u32[1] = -35;//20
	test.shared.u32[2] = 24;//-48
	test.shared.u32[3] = -47;//94
	test.shared.u32[4] = 70;//-44
	test.shared.u32[5] = 57;//129
	test.shared.u32[6] = -375;
	test.shared.u32[7] = 357;
	test.shared.u32[8] = 45;

	test.thread.opcodes[0:$bits(divisionApply_a)-1] = divisionApply_o(dataAddress_u32,sharedAddress_u32,i(8));#20;

	assert (result.data.u32[0] == -6) else $error("DivisionApply_t2.1_failed");
	assert (result.data.u32[1] == -1) else $error("DivisionApply_t2.2_failed");
	assert (result.data.u32[2] == -2)else $error("DivisionApply_t2.3_failed");
	assert (result.data.u32[3] == 4)else $error("DivisionApply_t2.4_failed");
	assert (result.data.u32[4] == 2) else $error("DivisionApply_t2.5_failed");
	assert (result.data.u32[5] == 18) else $error("DivisionApply_t2.6_failed");
	assert (result.data.u32[6] == -25)else $error("DivisionApply_t2.7_failed");
	assert (result.data.u32[7] == 3456)else $error("DivisionApply_t2.8_failed");
	assert (result.data.u32[8] == 54)else $error("DivisionApply_t2.9_failed");//unmodified value after length

	assert (result.thread.u32[0] == 0) else $error("DivisionApply_t2.10_failed");//unmodified value 

	assert (result.shared.u32[0] == 10) else $error("DivisionApply_t2.11_failed");
	assert (result.shared.u32[1] == -35) else $error("DivisionApply_t2.12_failed");
	assert (result.shared.u32[2] == 24)else $error("DivisionApply_t2.13_failed");
	assert (result.shared.u32[3] == -47)else $error("DivisionApply_t2.14_failed");
	assert (result.shared.u32[4] == 70) else $error("DivisionApply_t2.15_failed");
	assert (result.shared.u32[5] == 57) else $error("DivisionApply_t2.16_failed");
	assert (result.shared.u32[6] == -375)else $error("DivisionApply_t2.17_failed");
	assert (result.shared.u32[7] == 357)else $error("DivisionApply_t2.18_failed");
	assert (result.shared.u32[8] == 45)else $error("DivisionApply_t2.19_failed");

	
	test = 0;
	test.data.u32[0] = -67;
	test.data.u32[1] = -15;
	test.data.u32[2] = -24;
	test.data.u32[3] = 47;
	test.data.u32[4] = 26;
	test.data.u32[5] = 186;
	test.data.u32[6] = -255;
	test.data.u32[7] = 34567;
	test.data.u32[8] = 54;

	test.shared.u32[0] = 10;
	test.shared.u32[1] = -35;
	test.shared.u32[2] = 24;
	test.shared.u32[3] = -47;
	test.shared.u32[4] = 70;
	test.shared.u32[5] = 57;
	test.shared.u32[6] = -375;
	test.shared.u32[7] = 357;
	test.shared.u32[8] = 45;

	test.thread.opcodes[0:$bits(divisionApply_a)-1] = divisionApply_o(dataAddress_u32,sharedAddress_u32+1,i(8));#20;

	assert (result.data.u32[0] == 1) else $error("DivisionApply_t3.1_failed");
	assert (result.data.u32[1] == 0) else $error("DivisionApply_t3.2_failed");
	assert (result.data.u32[2] == 0)else $error("DivisionApply_t3.3_failed");
	assert (result.data.u32[3] == -1)else $error("DivisionApply_t3.4_failed");
	assert (result.data.u32[4] == 0) else $error("DivisionApply_t3.5_failed");
	assert (result.data.u32[5] == -5) else $error("DivisionApply_t3.6_failed");
	assert (result.data.u32[6] == 7)else $error("DivisionApply_t3.7_failed");
	assert (result.data.u32[7] == -987)else $error("DivisionApply_t3.8_failed");
	assert (result.data.u32[8] == 54)else $error("DivisionApply_t3.9_failed");//unmodified value after length

	assert (result.thread.u32[0] == 0) else $error("DivisionApply_t3.10_failed");//unmodified value 

	assert (result.shared.u32[0] == 10) else $error("DivisionApply_t3.11_failed");
	assert (result.shared.u32[1] == -35) else $error("DivisionApply_t3.12_failed");
	assert (result.shared.u32[2] == 24)else $error("DivisionApply_t3.13_failed");
	assert (result.shared.u32[3] == -47)else $error("DivisionApply_t3.14_failed");
	assert (result.shared.u32[4] == 70) else $error("DivisionApply_t3.15_failed");
	assert (result.shared.u32[5] == 57) else $error("DivisionApply_t3.16_failed");
	assert (result.shared.u32[6] == -375)else $error("DivisionApply_t3.17_failed");
	assert (result.shared.u32[7] == 357)else $error("DivisionApply_t3.18_failed");
	assert (result.shared.u32[8] == 45)else $error("DivisionApply_t3.19_failed");

	$display("DivisionApply_tb tested complete");
end;

always_comb begin
	divisionApply_a args; 
	args = test.thread.opcodes[0:$bits(divisionApply_a)-1];
	result = divisionApply_f(test,args);
end;

always begin
	clk <= 0; #5;
	clk <= 1; #5;
end;

endmodule;
