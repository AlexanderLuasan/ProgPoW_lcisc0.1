import Kiss::*;
import EV_types::*;
import EV_enums::*;


module kiss_tb;
    

exe_env_u state;
kiss_a args;

initial begin
    
    state = 0;
    args = 0;


    args = kiss_o(0,4,2);#5;


    state = kiss_f(state,args);
    args = kiss_o(0,6,2);#5
    state = kiss_f(state,args);
    
    
    state = 0;
    //add some intail values
    for(int i=0;i<4;i++) begin
        state.u32[2+i] = i*13;
    end
    args = kiss_o(2,6,3);
    
    state = kiss_f(state,args);
    
    args = kiss_o(2,9,1);
    state = kiss_f(state,args);

    $display("kiss complete");


end

endmodule