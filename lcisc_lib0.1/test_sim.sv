`timescale 1ns/1ns




module test_sim;

logic clk;


always begin
	clk <= 0; #5;
	clk <= 1; #5;	
end;

endmodule;
