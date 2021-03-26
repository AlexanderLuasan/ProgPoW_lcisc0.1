
import PopCount::*;
import EV_types::*;
import EV_enums::*;

module popCount_tb;

exe_env_u state;
popCount_a args;

initial begin
    
    state = 0;
    args = popCount_o(0,1);

    state.u32[0] = 45;#5

    state = popCount_f(state,args);#5;

    state = popCount_f(state,args);#5;

    state = popCount_f(state,args);#5;

    state = popCount_f(state,args);#5;
    state.u32[0] = 1412432;
    state = popCount_f(state,args);#5;
    

    $display("clz complete");

end



endmodule