



module test_cpu_join
	(
	ref my_pkg::thread_type thread_in,
	ref my_pkg::thread_type thread_out,
	input logic [7:0] instruction,
	output logic [7:0] instruction_post,
	input logic clk
	);

	my_pkg::thread_type thread_edited;

always_comb begin
	thread_edited = thread_in;
	case (thread_in.code[instruction].opcode)
	    my_pkg::ADD: thread_edited.data[thread_in.code[instruction].dest] = thread_in.data[thread_in.code[instruction].operand1]+thread_in.data[thread_in.code[instruction].operand2];
	    my_pkg::SUB: thread_edited.data[thread_in.code[instruction].dest] = thread_in.data[thread_in.code[instruction].operand1]-thread_in.data[thread_in.code[instruction].operand2];
	    my_pkg::DIV: thread_edited.data[thread_in.code[instruction].dest] = thread_in.data[thread_in.code[instruction].operand1]/thread_in.data[thread_in.code[instruction].operand2];
	    my_pkg::MUL: thread_edited.data[thread_in.code[instruction].dest] = thread_in.data[thread_in.code[instruction].operand1]*thread_in.data[thread_in.code[instruction].operand2];
	endcase
end

always_ff @(posedge clk) begin
	thread_out <= thread_edited;
	instruction_post<= instruction+1;
end
endmodule;



