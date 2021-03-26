`timescale 1ns/1ns


module CPU_tb;


my_pkg::opcode_struct todo;
integer result;
logic clk;

test_cpu dut(
	.instruction(todo),
	.c(result),
	.clk(clk)
	);

initial begin
	todo.a <= 'd20;
	todo.b <= 'd40;
	todo.opcode <= my_pkg::ADD; #10;

	todo.a <= 'd3;
	todo.b <= 'd15;
	todo.opcode <= my_pkg::MUL; #10;

	todo.a <= 'd54;
	todo.b <= 'd15;
	todo.opcode <= my_pkg::SUB; #10;

	todo.a <= 'd63;
	todo.b <= 'd3;
	todo.opcode <= my_pkg::DIV; #10;
end

always
	begin
	    clk <= 1; #5;
	    clk <= 0; #5;
	end

endmodule;
