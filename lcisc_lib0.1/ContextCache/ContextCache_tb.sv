`timescale 1ns/1ns
import ContextCache_pkg::*;
import EV_types::*;

module ContextCache_tb;


logic clk;
logic rst;

thread_register_union_t thread_a;
thread_register_union_t thread_b;
thread_register_union_t thread_c;
thread_register_union_t thread_ba;

//user insert
logic user_insert;
thread_register_union_t incoming_user_thread;
thread_status_t incoming_user_status;
thread_id_t user_insert_id;

//
logic requesting_thread;
thread_id_t requested_thread_id;
thread_register_union_t requested_thread_return;
thread_id_t requested_thread_return_id;

//scheduler
thread_id_t number_of_threads;
thread_id_t next_thread;

//disposition

ContextCache_Control incoming_control; 


thread_register_union_t incoming_thread;


ContextCache #(.opcode_size(4)) DUT (
.clk(clk),
.rst(rst),
.user_insert(user_insert),
.incoming_user_thread(incoming_user_thread),
.incoming_user_status(incoming_user_status),
.user_insert_id(user_insert_id),

.waiting_thread_count(number_of_threads),
.waiting_next_id(next_thread),

.requesting_thread(requesting_thread),
.requested_thread_id(requested_thread_id),
.requested_thread_return(requested_thread_return),
.out_thread_id(requested_thread_return_id),

.incoming_control(incoming_control),
.incoming_thread(incoming_thread)
/*.incoming_control.incoming_id(incoming_id),
.incoming_control.delete(delete),
.incoming_control.sleep(sleep),


.incoming_control.execute_info(execute_info),
.incoming_control.execute_id(execute_id),

.incoming_control.forking_info(forking_info),
.incoming_control.fork_sleep(fork_sleep),
.incoming_control.forking_id(forking_id)*/

);



initial begin
	thread_a = 0;
	thread_a.u32[0] = 0;
	thread_a.u32[1] = 1;
	thread_a.u32[2] = 2;
	thread_a.u32[3] = 3;
	thread_a.u32[4] = 4;
	thread_a.all[$bits(thread_register_union_t)-1:$bits(thread_register_union_t)-9] = 9'b111111011;

	thread_b = 0;
	thread_b.u32[0] = 4;
	thread_b.u32[1] = 3;
	thread_b.u32[2] = 2;
	thread_b.u32[3] = 1;
	thread_b.u32[4] = 0;
	thread_b.all[$bits(thread_register_union_t)-1:$bits(thread_register_union_t)-9] = 9'b111011111;

	thread_c = 0;
	thread_c.u32[0] = 4;
	thread_c.u32[1] = 3;
	thread_c.u32[2] = 2;
	thread_c.u32[3] = 1;
	thread_c.u32[4] = 0;
	thread_c.all[$bits(thread_register_union_t)-1:$bits(thread_register_union_t)-9] = 9'b111101111;

	thread_ba = 0;

	thread_ba.u32[0] = 0;
	thread_ba.u32[1] = 1;
	thread_ba.u32[2] = 2;
	thread_ba.u32[3] = 3;
	thread_ba.u32[4] = 4;
	thread_ba.all[$bits(thread_register_union_t)-1:$bits(thread_register_union_t)-9] = 9'b111011011;
	rst = 1;
	requesting_thread=0;
	incoming_control.incoming = 0;
	user_insert=0;#4;
	rst = 0;
	assert (number_of_threads == 0 ) else $error("ContextCache0_failed");//at reset would be zero
	assert (requested_thread_return == 0) else $error("contextCache0.1 failed");
	assert (requested_thread_return_id == 0) else $error("contextCache0.2 failed");
	assert (user_insert_id == 0) else $error("ContextCache0.3_failed");//rst should be zero
	incoming_user_thread = thread_a;//input user thread a
	user_insert = 1;
	incoming_user_status = work_queue;#4;
	assert (user_insert_id == 0) else $error("ContextCache1_failed");//should be in the 0 spot
	assert (number_of_threads == 1 ) else $error("ContextCache1.1_failed");//1
	user_insert = 0;

	incoming_user_thread = thread_b;
	user_insert = 1;
	incoming_user_status = work_queue;#4;
	assert (user_insert_id == 1) else $error("ContextCache2_failed");//input user if the 1 spot
	assert (number_of_threads == 2 ) else $error("ContextCache2.1_failed");//1+1
	assert (requested_thread_return == 0) else $error("contextCache2.2 failed");
	assert (requested_thread_return_id == 0) else $error("contextCache2.3 failed");
	user_insert = 0;

	incoming_user_thread = thread_c;
	user_insert = 1;
	incoming_user_status = work_queue;#4;
	assert (user_insert_id == 2) else $error("ContextCache3_failed");//input user if the 2 spot
	assert (number_of_threads == 3 ) else $error("ContextCache3.1_failed");//2+1
	user_insert = 0;


	requesting_thread = 1;//read the 1 index thread
	requested_thread_id = 1;#4;
	assert (requested_thread_return == thread_b) else $error("ContextCache4_failed"); 
	assert (number_of_threads == 2 ) else $error("ContextCache4.1_failed");//3-1
	assert (requested_thread_return_id == 1) else $error("contextCache4.2 failed");
	requesting_thread = 0;

	
	incoming_control.incoming = 1;// return the thread b
	incoming_control.incoming_id = 1; // thread_id
	incoming_control.delete = 0;
	incoming_control.sleep = 0;// to wait
	incoming_thread = thread_b; // is thread b
	incoming_control.execute_info =none; 	// no transfrom
	incoming_control.execute_id = 0;// no excu id
	incoming_control.forking_info = no_fork;
	incoming_control.fork_sleep = 0;
	incoming_control.forking_id = 0;
	#4;
	assert (DUT.thread_context[1]==thread_b && 
		DUT.thread_status[1] == work_queue) else $error("ContextCache5_failed");
	assert (number_of_threads == 3 ) else $error("ContextCache5.1_failed");//2+1
	incoming_control.incoming = 0;

	requesting_thread = 1;//read the 0 index thread
	requested_thread_id = 0;#4;
	assert (requested_thread_return == thread_a) else $error("ContextCache6_failed"); 
	assert (number_of_threads == 2 ) else $error("ContextCache6.1_failed");//3-1
	requesting_thread = 0;

	
	incoming_control.incoming = 1;// return the thread a
	incoming_control.incoming_id = 0; // thread_id
	incoming_control.delete = 0;
	incoming_control.sleep = 0;// to wait
	incoming_thread = thread_a; // is thread a
	incoming_control.execute_info =pass; 	// no transfrom
	incoming_control.execute_id = 1;		// index of thread b
	incoming_control.forking_info = no_fork;
	incoming_control.fork_sleep = 0;
	incoming_control.forking_id = 0;#4; 	
	assert (DUT.thread_context[0].all[$bits(thread_register_union_t)-1:$bits(thread_register_union_t)-4]== 4'b1110&&
		DUT.thread_context[0].all[$bits(thread_register_union_t)-4:$bits(thread_register_union_t)-9]== 5'b11011&&
		DUT.thread_context[0] == thread_ba&&
		DUT.thread_status[0] == work_queue) else $error("ContextCache7_failed");
	assert (number_of_threads == 3 ) else $error("ContextCache7.1_failed");//2+1
	incoming_control.incoming = 0;
	//now thread_ba is in 0
	
	requesting_thread = 1;//read the 2 index thread
	requested_thread_id = 2;#4;
	assert (requested_thread_return == thread_c) else $error("ContextCache8_failed"); 
	assert (number_of_threads == 2 ) else $error("ContextCache8.1_failed");//3-1
	requesting_thread = 0;

	//return the thread c have it copy thread b
	incoming_control.incoming = 1;
	incoming_control.incoming_id = 2; // thread_id the index of thread c
	incoming_control.delete = 0;
	incoming_control.sleep = 0;// to wait
	incoming_thread = thread_c; // is thread c
	incoming_control.execute_info =copy; 	// no transfrom
	incoming_control.execute_id = 1; 	// id should be b 
	incoming_control.forking_info = no_fork;
	incoming_control.fork_sleep = 0;
	incoming_control.forking_id = 0;#4;
	assert (DUT.thread_context[2] == thread_b &&
		DUT.thread_status[2] == work_queue) else $error("ContextCache9_failed");
	assert (number_of_threads == 3 ) else $error("ContextCache9.1_failed");//2+1
	incoming_control.incoming = 0;

	requesting_thread = 1;//read the 0 index thread type thread_ba
	requested_thread_id = 0;#10;
	assert (requested_thread_return == thread_ba) else $error("ContextCache10_failed"); 
	assert (number_of_threads == 2 ) else $error("ContextCache10.1_failed");//3-1
	requesting_thread = 0;

	
	incoming_control.incoming = 1;//return and delete the thread_ba in index 0
	incoming_control.incoming_id = 0; // thread_id the index of thread ba
	incoming_control.delete = 1;
	incoming_control.sleep = 0;// should not matter
	incoming_thread = thread_ba; // is thread b
	incoming_control.execute_info = copy; 	// no transfrom
	incoming_control.execute_id = 0;
	incoming_control.forking_info = no_fork;
	incoming_control.fork_sleep = 0;
	incoming_control.forking_id = 0;#4;
	assert (DUT.thread_context[0] == 0 &&
		DUT.thread_status[0] == no_thread) else $error("ContextCache11_failed");
	assert (number_of_threads == 2 ) else $error("ContextCache11.1_failed");//2 + 0
	incoming_control.incoming = 0;

	incoming_user_thread = thread_a;//input user thread a
	user_insert = 1;
	incoming_user_status = work_queue;#4;
	assert (user_insert_id == 3) else $error("ContextCache12_failed");//should be in the 3 spot
	assert (number_of_threads == 3 ) else $error("ContextCache12.1_failed");//2 + 1
	user_insert = 0;

	//do a fork  that creates a ba thread
	//take out "a" fork_pass "b"
	requesting_thread = 1;//read the 3 index thread type thread a
	requested_thread_id = 3;#4;
	assert (requested_thread_return == thread_a) else $error("ContextCache13_failed"); 
	assert (number_of_threads == 2 ) else $error("ContextCache13.1_failed");//3-1
	requesting_thread = 0;
	
	incoming_control.incoming = 1;//return the thread_ba in index 3
	incoming_control.incoming_id = 3; // thread_id the index of thread ba
	incoming_control.delete = 0;
	incoming_control.sleep = 0;
	incoming_thread = thread_a; // is thread a
	incoming_control.execute_info = none; 	// no transfrom
	incoming_control.execute_id = 0;
	incoming_control.forking_info = fork_other_pass;
	incoming_control.fork_sleep = 0;
	incoming_control.forking_id = 1;#4;//location of a 'b'
	//creates a new ba thread in spot 4
	assert (DUT.thread_context[4].all[$bits(thread_register_union_t)-1:$bits(thread_register_union_t)-4]== 4'b1110&&
		DUT.thread_context[4].all[$bits(thread_register_union_t)-4:$bits(thread_register_union_t)-9]== 5'b11011&&
		DUT.thread_context[4] == thread_ba&&
		DUT.thread_status[4] == work_queue) else $error("ContextCache14_failed");
	
	assert (number_of_threads == 4 ) else $error("ContextCache14.1_failed");//2+2
	assert (DUT.thread_context[3] == thread_a && DUT.thread_status[3] == work_queue) else $error("ContextCache14.2_failed");
	incoming_control.incoming = 0;
	//do a fork that creates a perfect c thread
	//take out "c" fork_me_copy  select anything
	//also convert the original c into an ab with a perfect copy

	requesting_thread = 1;//read the 2 index thread type thread c
	requested_thread_id = 2;#4;
	assert (requested_thread_return == thread_b) else $error("ContextCache15_failed"); 
	assert (number_of_threads == 3 ) else $error("ContextCache15.1_failed");//4-1
	requesting_thread = 0;
	
	incoming_control.incoming = 1;//return the thread_b
	incoming_control.incoming_id = 2; // thread_id the index of thread_b is 2
	incoming_control.delete = 0;
	incoming_control.sleep = 0;
	incoming_thread = thread_b; // is thread b
	incoming_control.execute_info = copy; 	// no transfrom
	incoming_control.execute_id = 4;//id of thread ba
	incoming_control.forking_info = fork_me_copy;
	incoming_control.fork_sleep = 0;
	incoming_control.forking_id = 0;#4;
	//creates a new c thread in spot 5
	assert (DUT.thread_context[5] == thread_b&&
		DUT.thread_status[5] == work_queue) else $error("ContextCache16_failed");
	assert (number_of_threads == 5 ) else $error("ContextCache16.1_failed");//3+2
	assert (DUT.thread_context[2] == thread_ba && DUT.thread_status[2] == work_queue)else $error("ContextCache16.2_failed");//original thread is now a an ab thread

	$display("done testing context cache");
	
	
	
	
end

always begin
	clk <= 0; #2;
	clk <= 1; #2;
end;


endmodule;
