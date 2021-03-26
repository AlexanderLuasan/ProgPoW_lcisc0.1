`timescale 1ns/1ns


module testreading;


my_pkg::thread_type test_program;
logic clk;

initial begin
	test_program.data[0] <= 32'd105; #5;
	test_program.data[1] <= 32'd106; #5;
	test_program.data[2] <= 32'd107; #5;
end

always
	begin
	    clk <= 1; #5;
	    clk <= 0; #5;
	end

endmodule;
