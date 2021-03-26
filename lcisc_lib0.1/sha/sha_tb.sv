import Sha::*;
import EV_types::*;
import Operation_pkg::*;

module sha_tb (
);
exe_env_s state;
sha_a args;
initial begin
    
    state = 0;
    args = sha_o();#5;
    
    for(int i = 0; i < 20;i++)
        state.data.u32[i] = i*10;#5;
    $display("data: %h",state.data);
    state = sha_f(state,args);#5;
    $display("data: %h",state.data);
    
    assert(state.data == 'h000000960000008c00000082000000780000006e000000640000005a0000005070a4855d04d8fa7b3b2782ca53b600e5c003c7dcb27d7e923c23f7860146d2c5) else $display("error");
    
    args = sha_o(.sha_length(32));#5;
    $display("data: %h",state.data);
    state = sha_f(state,args);#5;
    $display("data: %h",state.data);
    
    assert(state.data == 'h000000960000008c00000082000000780000006e000000640000005a000000508f75a6c8e5550aea02e4f5217aac6db8eaaf6085c54f39d287eceb73ff3eca10) else $display("error");
    
    
    args = sha_o(.sha_version(1));#5;
    $display("data: %h",state.data);
    state = sha_f(state,args);#5;
    $display("data: %h",state.data);
    
    assert(state.data == 'h0e6870363db3da0c16fb6927ef91f035b41367e0cb9b46ba7679d8f9caa90fc004436af366c4674e0ec6b766c3a8299cb246e7ffac91fc3592eb3c4cde42ab0e) else $display("error");
    
    state = 0;
    

    args = sha_o(.sha_length(32),.sha_version(1));
    state = sha_f(state,args);#5;
    $display("data: %h",state.data);
    
    
    args = sha_o(.sha_length(64),.sha_version(1));
    state = sha_f(state,args);#5;
    $display("data: %h",state.data);

end


endmodule