
`timescale 1ns/1ns


module adder_test_bench;


    integer in1;
    integer in2;
    integer out1;

    logic clk;

    adder dut(
	.clk(clk),
	.a(in1),
	.b(in2),
	.c(out1)
    );

    initial
	begin
	    in1 <= 'd15;
	    in2 <= 'd20;
	    #10;
            in1 <= 'd34;
            in2 <= 'd45;
	    #10;

	end
    always
	begin
	    clk <= 1; #5;
	    clk <= 0; #5;
	end
endmodule;
