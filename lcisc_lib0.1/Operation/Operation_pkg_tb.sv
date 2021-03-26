
import Operation_pkg::*;
import EV_types::*;


module operation_pkg_tb;

ia_u32_t test;
execution_ev_union state;

initial begin

state.u32[1] = 100;
state.u32[5] =-5;
state.u32[10] = 42;


test = i(32);
assert(ia_u32_value(test,state) == 32) else $error("operation_pkg 1 failed"); 

test=a(1);
assert(ia_u32_value(test,state) == 100) else $error("operation_pkg 2 failed"); 
 
test=i(1);
assert(ia_u32_value(test,state) == 1) else $error("operation_pkg 3 failed"); 

test=1;
assert(ia_u32_value(test,state) == 100) else $error("operation_pkg 4 failed"); 

test=i(-15);
assert(ia_u32_value(test,state) == -15) else $error("operation_pkg 5 failed"); 


$display("operation_pkg done testing");
end

endmodule;




