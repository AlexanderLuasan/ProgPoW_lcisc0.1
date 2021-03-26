
module ExampleFSM(	input logic clk,
			input logic reset,
			input logic X,
			output logic Y);

typedef enum logic [2:0] {A,B,C,D,E} State;

State CurrentState, NextState;
always_ff @(posedge clk)
	if(reset) CurrentState <= A;
	else CurrentState <= NextState;

always_comb

	case(CurrentState)
		A: if(X) NextState = C;
		   else	 NextState = B;
		B: if(X) NextState = D;
		   else	 NextState = B;
		C: if(X) NextState = E;
		   else	 NextState = C;
		D: if(X) NextState = C;
		   else	 NextState = E;
		E: if(X) NextState = D;
		   else	 NextState = B;
		default: NextState = A;
	endcase
	
	assign Y = (CurrentState == D | CurrentState == E);

endmodule