import my_pkg::*;






module test_cpu 
	(
	ref opcode_struct instruction,
	output integer c,
	input logic clk
	);

always_ff @(posedge clk) begin
	case (instruction.opcode)
	    ADD: c <= instruction.a+instruction.b;
	    SUB: c <= instruction.a-instruction.b;
	    DIV: c <= instruction.a/instruction.b;
	    MUL: c <= instruction.a*instruction.b;
	    default: c <= 0;
	endcase
    end
endmodule;
