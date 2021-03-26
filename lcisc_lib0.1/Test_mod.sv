


module adder(
	input logic clk,
	input  integer a,
	input  integer b,
	output integer c);

always_ff @(posedge clk)
	c <= a+b;


endmodule;