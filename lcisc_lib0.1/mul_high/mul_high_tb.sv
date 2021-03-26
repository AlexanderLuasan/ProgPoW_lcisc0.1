import Mul_hi::*;
import EV_types::*;
import EV_enums::*;

module mul_hi_tb;

exe_env_u state;
mul_hi_a args;

initial begin
    
    state = 0;
    args = mul_hi_o(0,1,2);
    state.u32[0] = 258744;
    state.u32[1] = 70707;#5;

    state = mul_hi_f(state,args); 
    

    state.u32[0] = 606060;
    state.u32[1] = 2286532;

    state = mul_hi_f(state,args); 
    

    $display("mul_hi_complete");


end


endmodule