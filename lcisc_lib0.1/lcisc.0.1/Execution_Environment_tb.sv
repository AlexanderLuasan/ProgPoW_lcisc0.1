`timescale 1ns/1ns 
import EV_types::*;


module Execution_Environment_tb;

	logic clk;
	EV_types::execution_ev_union DUT;

	initial begin
		DUT.all <= 'd0;#5;//zero the system

		DUT.word[0] <= 32'd10;//set the first two words to 10 and 14
		DUT.word[1] <= 32'd14;#5

		DUT.dword[0] <= 64'd1780;#5;//set the first dword to 1780 should over write the first word

		DUT.execution_ev.shared.word[0] <= 32'd65; #5;//set the first global value to 65

	end;

	always begin
		clk <= 0; #5;
		clk <= 1; #5;
	end;


endmodule;
