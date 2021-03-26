import Move::*;
import EV_types::*;


module Move_tb;

execution_ev_union test;
execution_ev_union result;

logic clk;

initial begin
test = 0;

for(int i=0;i<20;i++)
	test.u32[i] = i;

result = move_f(test,move_o(.address1(10),.address2(15)));#10;

end

always begin
	clk<=0;#5;
	clk<=1;#5;
end

endmodule; 
