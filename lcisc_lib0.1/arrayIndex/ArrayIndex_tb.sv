import ArrayIndex::*;
import EV_types::*;
import EV_enums::*;
import Operation_pkg::*;

module ArrayIndex_tb;


exe_env_u state;
arrayIndex_a args;

initial begin
    
    state = 0;
    args = 0;

    for(int i = 0;i<10;i++) begin
        state.u32[i] = i+10;
    end

    //get the zeroth index
    args = arrayIndex_o(0,i(0),15);#5;

    state = arrayIndex_f(state,args);#5;

    assert (state.u32[15] == 10) else   $error("error");


    args = arrayIndex_o(0,i(4),15);#5;
    state = arrayIndex_f(state,args);#5;
    assert (state.u32[15] == 14) else   $error("error");

    state.u32[20] = 5;
    args = arrayIndex_o(0,a(20),15);#5;
    state = arrayIndex_f(state,args);#5;
    assert (state.u32[15] == 15) else   $error("error");





end
endmodule