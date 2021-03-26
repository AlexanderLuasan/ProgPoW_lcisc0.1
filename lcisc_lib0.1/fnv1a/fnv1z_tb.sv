import fnv1a::*;
import EV_types::*;
import EV_enums::*;
import Operation_pkg::*;
module fnv1a_tb;


exe_env_u state;
fnv1a_a args;

initial begin
    
    state = 0;
    args = 0;

    for(int i = 0; i < 10; i++) begin
       state.u32[i] =  i*23;
    end

    for(int i=1;i<10;i++) begin
        args = fnv1a_o(i,a(i-1));#5;
        state = fnv1a_f(state,args);
    end

    $display("fnv1a complete");

end


    
endmodule

