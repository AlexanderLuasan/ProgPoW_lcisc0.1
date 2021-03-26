import keccak_f800::*;
import EV_types::*;
import EV_enums::*;


module keccak_f800_tb;

exe_env_u state;
keccak_f800_a args;

initial begin
    
    state = 0;
    args = keccak_f800_o(2,0,10);#5;

    state = keccak_f800_f(state,args);#5;
    state.u32[0] = 32;
    for(int i=0;i<8;i++) begin
        state.u32[10+i] = state.u32[2+i];
    end
    
    state = keccak_f800_f(state,args);#5;
    $display("complete");

    




end
    
endmodule