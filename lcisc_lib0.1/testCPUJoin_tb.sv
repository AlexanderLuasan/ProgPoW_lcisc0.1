`timescale 1ns/1ns


module testCPUJoin_tb;



my_pkg::thread_type test_program;
logic clk;
logic [7:0] inst_count;
logic [7:0] inst_count_next;


test_cpu_join DUT(
	.thread_in(test_program),
	.thread_out(test_program),
	.instruction(inst_count),
	.instruction_post(inst_count_next),
	.clk(clk)
	);
	


initial begin
	inst_count<= 8'd0;
	test_program.data[0] <= 32'd0;
	test_program.data[1] <= 32'd0;
	test_program.data[2] <= 32'd0;
	test_program.data[3] <= 32'd0;
	test_program.data[4] <= 32'd0;
	test_program.data[5] <= 32'd0;
	test_program.data[6] <= 32'd0;
	test_program.data[7] <= 32'd0;
	test_program.data[8] <= 32'd0;
	test_program.data[9] <= 32'd0;
	test_program.data[10] <= 32'd0;
	test_program.data[11] <= 32'd0;
	test_program.data[12] <= 32'd0;
	test_program.data[13] <= 32'd0;
	test_program.data[14] <= 32'd0;
	test_program.data[15] <= 32'd0; #5;




	inst_count<= 8'd0;
	test_program.data[0] <= 32'd35; 
	test_program.data[1] <= 32'd6;
	test_program.data[2] <= 32'd0;
	test_program.data[3] <= 32'd0;

	test_program.code[0].opcode <= my_pkg::MUL;
	test_program.code[0].operand1 <= 8'd0;
	test_program.code[0].operand2 <= 8'd1;
	test_program.code[0].dest <= 8'd2;

	test_program.code[1].opcode <= my_pkg::SUB;
	test_program.code[1].operand1 <= 8'd2;
	test_program.code[1].operand2 <= 8'd1;
	test_program.code[1].dest <= 8'd3;

	test_program.code[2].opcode <= my_pkg::ADD;
	test_program.code[2].operand1 <= 8'd0;
	test_program.code[2].operand2 <= 8'd1;
	test_program.code[2].dest <= 8'd0;


	test_program.code[3].opcode <= my_pkg::DIV;
	test_program.code[3].operand1 <= 8'd2;
	test_program.code[3].operand2 <= 8'd0;
	test_program.code[3].dest <= 8'd1;

end

always
	begin
	    clk <= 1; #5;
	    clk <= 0; #5;
	    inst_count<=inst_count_next;
	end




endmodule;
