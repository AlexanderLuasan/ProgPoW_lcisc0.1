
import Clz::*;
import EV_types::*;
import EV_enums::*;

module Clz_tb;

exe_env_u state;
clz_a args;

initial begin
    
    state = 0;
    args = clz_o(0,1);

    state.u32[0] = 45;#5

    state = clz_f(state,args);#5;

    state = clz_f(state,args);#5;

    state = clz_f(state,args);#5;

    state = clz_f(state,args);#5;
    state.u32[0] = 1412432;
    state = clz_f(state,args);#5;
    

    $display("clz complete");

end



endmodule