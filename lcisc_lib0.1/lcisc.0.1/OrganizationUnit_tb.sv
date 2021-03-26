import EV_types::*;
import DataInterface_pkg::*;



module OrganizationUnit_tb;

logic clk;
logic rst;

logic active; 
thread_register_union_t thread;
read_return_t data_return;
thread_id_t thread_id;

pipeline_pass_structure out_execution_ev;

OrganizationUnit DUT(
.data_return(data_return),
.thread(thread),
.active(active),
.thread_id(thread_id),
.clk(clk),
.rst(rst),
.execution_ev(out_execution_ev)
);

initial begin
rst = 1;
active = 0;
thread = 0;
data_return = 0;
thread_id = 0;#10;

assert(out_execution_ev == 0) else $error("failed rst");
assert(out_execution_ev.system.active_thread == 0) else $error("failed rst");
rst = 0;


active = 1;
data_return.data.u32[10] = 6;//have some data
data_return.valid = 1;
thread.u32[10] = 35;//have some thread data
#10;

assert(out_execution_ev.data.u32[10] == 6) else $error("failed data recived");
assert(out_execution_ev.system.active_thread == 1) else $error("failed active tick");
assert(out_execution_ev.thread.u32[10] == 35) else $error("failed thread data");


active = 0;#10;
assert(out_execution_ev == 0) else $error("failed not active");
assert(out_execution_ev.system.active_thread == 0) else $error("failed not active");



active = 1;
thread_id = 15;
data_return.receive_id = 15;#10;
assert(out_execution_ev.data.u32[10] == 6) else $error("failed data recived");
assert(out_execution_ev.system.active_thread == 1) else $error("failed active tick");
assert(out_execution_ev.thread.u32[10] == 35) else $error("failed thread data");
assert(out_execution_ev.system.id == 15) else $error("failed thread_id");



end


always begin
	clk<=0;#5;
	clk<=1;#5;
end


endmodule;