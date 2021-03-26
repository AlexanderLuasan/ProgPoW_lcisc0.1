`timescale 1ns/1ns
import EV_types::*;
import ContextCache_pkg::*;
import DataInterface_pkg::*;
import Disposition_pkg::*;

module Disposition_tb;


logic clk;
logic rst;
disposition_a disposition_args;
pipeline_pass_structure state;



thread_register_union_t incoming_thread;
ContextCache_Control incoming_control;

read_request_t	read1;
read_request_t	read2;
write_request_t	write;

Disposition#(.addressStart(8)) DUT(
	.clk(clk),
	.rst(rst),
	.inputState(state),
	
	//data to cache
	.incoming_thread(incoming_thread),
	.incoming_control(incoming_control),

	//data to memoroy
	.read1(read1),
	.read2(read2),
	.write(write)
);
/*
disposition_o(
input integer delete = -1000 ,
input integer sleep = -1000 ,
input integer exec_conditional = -1000,
input 	ContextCache_pkg::exec_enum_t exec_info = ContextCache_pkg::none,
integer exec_id = -1,
input integer fork_conditional = -1000,
input 	ContextCache_pkg::fork_enum_t fork_info = ContextCache_pkg::no_fork,
input logic fork_sleep = 0,
integer fork_id = -1,
input integer self_read = -1000,
integer self_read_address = -1,
input integer other_read = -1000,
integer read_other_who = -1,
integer read_other_where = -1,
input integer write = -1000,
integer write_address = -1
);
*/
initial begin

rst = 1;
disposition_args = 0;
state = 0;#10;
rst = 0;
assert(incoming_thread ==0) else $error("disposition failed rst");
assert(incoming_control ==0) else $error("disposition failed rst");
assert(read1==0) else $error("disposition failed rst");
assert(read2==0) else $error("disposition failed rst");
assert(write==0) else $error("disposition failed rst");

state.thread.opcodes[8:$bits(disposition_a)+8-1]=disposition_o();#10;
assert(incoming_thread ==0) else $error("disposition failed no_thread");
assert(incoming_control ==0) else $error("disposition failed no_thread");
assert(read1==0) else $error("disposition failed no_thread");
assert(read2==0) else $error("disposition failed no_thread");
assert(write==0) else $error("disposition failed no_thread");

state.system.id = 54;
state.system.active_thread = 1;
state.thread.opcodes[8:$bits(disposition_a)+8-1]=disposition_o();#10;

assert(incoming_thread ==state.thread) else $error("disposition failed no_action");
assert(incoming_control.incoming ==1) else $error("disposition failed no_action");
assert(incoming_control.incoming_id ==54) else $error("disposition failed no_action");
assert(read1.valid==0) else $error("disposition failed no_action");
assert(read2.valid==0) else $error("disposition failed no_action");
assert(write.valid==0) else $error("disposition failed no_action");


state.thread.opcodes[8:$bits(disposition_a)+8-1]=disposition_o(.delete(100));#10;//add unconditional delete
assert(incoming_thread ==state.thread) else $error("disposition failed unconditional delete");
assert(incoming_control.incoming ==1) else $error("disposition failed unconditional delete");
assert(incoming_control.incoming_id ==54) else $error("disposition failed unconditional delete");
assert(incoming_control.delete ==1) else $error("disposition failed unconditional delete");
assert(read1.valid==0) else $error("disposition failed unconditional delete");
assert(read2.valid==0) else $error("disposition failed unconditional delete");
assert(write.valid==0) else $error("disposition failed unconditional delete");

//conditional sleep/read
//add conditional sleep on first flag and and conditional self read on first flag
//no change
state.shared.u64[0] = 87;//data to be read
state.thread.opcodes[8:$bits(disposition_a)+8-1]=disposition_o(.delete(100),.sleep(1),.self_read(1),.self_read_address(sharedAddress_u64+0));#10;
assert(incoming_thread ==state.thread) else $error("disposition failed conditional sleep/read");
assert(incoming_control.incoming ==1) else $error("disposition failed conditional sleep/read");
assert(incoming_control.incoming_id ==54) else $error("disposition failed conditional sleep/read");
assert(incoming_control.sleep == 0) else $error("disposition failed conditional sleep/read");
assert(incoming_control.delete ==1) else $error("disposition failed conditional sleep/read");
assert(read1.valid==0) else $error("disposition failed conditional sleep/read");
assert(read2.valid==0) else $error("disposition failed conditional sleep/read");
assert(write.valid==0) else $error("disposition failed conditional sleep/read");


//conditional sleep/read true
//redo last test with the trun condition
state.thread.flags[1-1] = 1; 
state.thread.opcodes[8:$bits(disposition_a)+8-1]=disposition_o(.delete(100),.sleep(1),.self_read(1),.self_read_address(sharedAddress_u64+0));#10;
assert(incoming_thread ==state.thread) else $error("disposition failed conditional sleep/read");
assert(incoming_control.incoming ==1) else $error("disposition failed conditional sleep/read");
assert(incoming_control.incoming_id ==54) else $error("disposition failed conditional sleep/read");
assert(incoming_control.sleep == 1) else $error("disposition failed conditional sleep/read");
assert(incoming_control.delete ==1) else $error("disposition failed conditional sleep/read");
assert(read1.valid==1) else $error("disposition failed conditional sleep/read");
assert(read2.valid==0) else $error("disposition failed conditional sleep/read");
assert(write.valid==0) else $error("disposition failed conditional sleep/read");


//add a second condition that exec a new pass at new id location
//exec_false_condition
state.shared.u64[1] = 64;//thread to be exec
state.thread.opcodes[8:$bits(disposition_a)+8-1]=disposition_o(.delete(100),.sleep(1),.self_read(1),.self_read_address(sharedAddress_u64+0),
.exec_conditional(2),.exec_info(pass),.exec_id(sharedAddress_u64+1));#10;

assert(incoming_thread ==state.thread) else $error("disposition failed conditional exec");
assert(incoming_control.incoming ==1) else $error("disposition failed conditional exec");
assert(incoming_control.incoming_id ==54) else $error("disposition failed conditional exec");
assert(incoming_control.sleep == 1) else $error("disposition failed conditional exec");
assert(incoming_control.delete ==1) else $error("disposition failed conditional exec");
assert(incoming_control.execute_info ==none) else $error("disposition failed conditional exec");
assert(read1.valid==1) else $error("disposition failed conditional exec");
assert(read2.valid==0) else $error("disposition failed conditional exec");
assert(write.valid==0) else $error("disposition failed conditional exec");

state.thread.flags[2-1] = 1; //flip the flag bit to two
state.thread.opcodes[8:$bits(disposition_a)+8-1]=disposition_o(.delete(100),.sleep(1),.self_read(1),.self_read_address(sharedAddress_u64+0),
.exec_conditional(2),.exec_info(pass),.exec_id(sharedAddress_u64+1));#10;

assert(incoming_thread ==state.thread) else $error("disposition failed conditional exec");
assert(incoming_control.incoming ==1) else $error("disposition failed conditional exec");
assert(incoming_control.incoming_id ==54) else $error("disposition failed conditional exec");
assert(incoming_control.sleep == 1) else $error("disposition failed conditional exec");
assert(incoming_control.delete ==1) else $error("disposition failed conditional exec");
assert(incoming_control.execute_info ==pass) else $error("disposition failed conditional exec");
assert(incoming_control.execute_id ==64) else $error("disposition failed conditional exec");
assert(read1.valid==1) else $error("disposition failed conditional exec");
assert(read2.valid==0) else $error("disposition failed conditional exec");
assert(write.valid==0) else $error("disposition failed conditional exec");

end;

always begin
	clk<=0;#5;
	clk<=1;#5;
end;

endmodule;