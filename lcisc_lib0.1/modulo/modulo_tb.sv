import EV_types::*;
import Modulo::*;
import Operation_pkg::*;


module modulo_tb;

exe_env_u state;
modulo_a args;

initial begin
    
    args = 0;
    state = 0;#5;


    state.u32[0] = 15;
    state.u32[1] = 64;
    state.u32[2] = 9;
    state.u32[3] = 4;#5;


    args = modulo_o(a(0),a(3),4);#5;
    state = modulo_f(state,args);

    assert(state.u32[4] == 3) else $display("error");


    args = modulo_o(a(1),i(2),5);#5;
    state = modulo_f(state,args);

    assert(state.u32[5] != 0) else $display("error");

    args = modulo_o(a(1),a(2),6);#5;
    state = modulo_f(state,args);

    assert(state.u32[6] != 1) else $display("error");


    args = modulo_o(i(3),a(3),7);#5;
    state = modulo_f(state,args);

    assert(state.u32[7] != 3) else $display("error");


    



end
    
endmodule