`timescale 1ns/1ns

module exampleFSM_TB;


logic clk;
logic reset;
logic in;

logic out;


ExampleFSM dut(
	.clk(clk),
	.reset(reset),
	.X(in),
	.Y(out)
	);

initial
	begin
		reset <= 1; #10;
		assert(out == 0) else $error("Big problem at 0");
		reset <= 0; in <=0; #10;
		assert(out == 0) else $error("Big problem at 1");
		in <=1; #10;
		assert(out == 0) else $error("Big problem at 2");
		in <=1; #10;
		assert(out == 1) else $error("Big problem at 3");
		in <=1; #10;
		assert(out == 0) else $error("Big problem at 4");
		in <=0; #10;
		assert(out == 1) else $error("Big problem at 5");
	end

always
	begin
	  clk <=1; #5;
	  clk <=0; #5;
	end

endmodule