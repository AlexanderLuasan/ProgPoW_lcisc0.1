`timescale 1ns/1ns
import FnvMap::*;
import EV_types::*;
import EV_enums::*;

module FnvMap_tb;

exe_env_u state;
fnvMap_a args;


initial begin
	
    state = 0;
    for(int i = 0;i<5;i++) begin
        state.u32[i] = i+1;
    end
    args = fnvMap_o(0,0,5);#5;

    state = fnvMap_f(state,args);#5;

    assert (state.u32[0] == 16777618) else $error("error");
    assert (state.u32[1] == 33555236) else $error("error");
    assert (state.u32[2] == 50332858) else $error("error");
    assert (state.u32[3] == 67110472) else $error("error");
    assert (state.u32[4] == 83888090) else $error("error");
    
    

end;


endmodule;
