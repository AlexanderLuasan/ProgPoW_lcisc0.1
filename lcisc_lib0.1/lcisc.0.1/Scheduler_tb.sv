import EV_types::*;
import DataInterface_pkg::*;


module Scheduler_tb;

logic clk;
logic rst;
logic halt;


read_return_t data_return;

read_return_t data_deliver;
logic operate;

thread_id_t count;
thread_id_t next_id;
thread_id_t next_id2;

logic requesting;
thread_id_t requested_thread_id;


Scheduler DUT(
.clk(clk),.rst(rst),.halt(halt),

.data_return(data_return),
.data_deliver(data_deliver),
.operate(operate),

.waiting_thread_count(count),.waiting_next_id(next_id),.waiting_next_id2(next_id2),

.requesting_thread(requesting),
.requested_thread_id(requested_thread_id)
);

initial begin
rst = 1;
halt = 1;
data_return = 0;

count = 0;
next_id = 0;next_id2=0;#10;
rst = 0;
assert(requesting == 0) else $error("rst failed");
assert(data_deliver == 0) else $error("rst failed");
assert(operate == 0) else $error("rst failed");

data_return.data.u32[1] =  32;
data_return.receive_id = 15;
data_return.valid = 1;
#10;//
assert(requesting == 0) else $error("wait failed");
assert(data_deliver == 0) else $error("wait failed");
assert(operate == 0) else $error("wait failed");
assert(DUT.buffered_data[2] == data_return) else $error("data return not recived");
data_return = 0;
#10;
assert(requesting == 0) else $error("wait failed");
assert(data_deliver == 0) else $error("wait failed");
assert(operate == 0) else $error("wait failed");
assert(DUT.buffered_data[2] == 0) else $error("data cleared in buffer not recived");
#10;
assert(requesting == 1) else $error("request next failed");
assert(data_deliver == 0) else $error("wait failed");
assert(operate == 0) else $error("wait failed");
assert(DUT.buffered_data[1] == 0) else $error("data cleared in buffer not recived");
#10;
assert(requesting == 0) else $error("wait failed");
assert(data_deliver.data.u32[1] == 32) else $error("data return failed");
assert(operate == 1) else $error("operate failed");
#10;

assert(requesting == 0) else $error("nothing failed");
assert(data_deliver == 0) else $error("nothing failed");
assert(operate == 0) else $error("nothing failed");

//do a not waiting thread
count = 1;
next_id = 15;#10;
//this is still halted so no change

assert(requesting == 0) else $error("do nothing with waiting failed");
assert(data_deliver == 0) else $error("do nothing with waiting failed");
assert(operate == 0) else $error("do nothing with waiting failed");

halt = 0;#10; // it will try to start now

assert(requesting == 1) else $error("non waiting trigger failed");
assert(requested_thread_id == 15) else $error("non waiting trigger failed");
assert(data_deliver == 0) else $error("non waiting trigger failed");
assert(operate == 0) else $error("non waiting trigger failed");
#10;
count = 0;
next_id = 0;
// now it will operate with no data and the 
assert(requesting == 0) else $error("non waiting exec failed");
assert(requested_thread_id == 0) else $error("non waiting exec failed");
assert(data_deliver == 0) else $error("non waiting exec failed");
assert(operate == 1) else $error("non waiting exec failed");

//double runs

count = 2;
next_id = 56;
next_id2 = 65;#10;
assert(requesting == 1) else $error("non double runs failed");
assert(requested_thread_id == 56) else $error("non double runs failed");
assert(data_deliver == 0) else $error("non double runs failed");
assert(operate == 0) else $error("non double runs failed");

#10;
count = 1;
next_id = 65;
next_id2 = 0;
assert(requesting == 1) else $error("non double runs failed");
assert(requested_thread_id == 65) else $error("non double runs failed");
assert(data_deliver == 0) else $error("non double runs failed");
assert(operate == 1) else $error("non double runs failed");
#10;
assert(requesting == 0) else $error("non double runs failed");
assert(requested_thread_id == 0) else $error("non double runs failed");
assert(data_deliver == 0) else $error("non double runs failed");
assert(operate == 1) else $error("non double runs failed");
count = 1;
next_id =0;#10;


$display("Scheduler_tb testing complete");
end


always begin
	clk<=0;#5;
	clk<=1;#5;
end


endmodule;