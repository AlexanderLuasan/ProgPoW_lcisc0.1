import EV_types::*;
import ContextCache_pkg::*;
import program_encoder::*;

module ContextCache(
input logic clk,
input logic rst,
//user input
input logic user_insert,
input thread_program_stuct_t incoming_user_thread,
input thread_status_t incoming_user_status,
output thread_id_t user_insert_id,

//requesting
input logic requesting_thread,
input thread_id_t requested_thread_id,
output thread_program_stuct_t requested_thread_return,
output thread_id_t out_thread_id,

//waiting to execute info for the scheduler
output thread_id_t waiting_thread_count,
output thread_id_t waiting_next_id,
output thread_id_t waiting_next_id2,

//from disposition
input ContextCache_Control incoming_control,

input thread_program_stuct_t incoming_thread

);
parameter opcode_size = $bits(program_instruction_struct_t);



function automatic void reset_cache(
ref thread_program_stuct_t thread_context [EV_types::ContextThreadLength-1:0],
ref thread_status_t thread_status [EV_types::ContextThreadLength-1:0],
ref thread_id_t free_list [EV_types::ContextThreadLength-1:-1],
ref thread_id_t work_queue [EV_types::ContextThreadLength-1:-1]);

for(int i=0;i<EV_types::ContextThreadLength;i++) begin
	thread_context[i] = 0;
	thread_status[i] = no_thread;
	free_list[i] = i;
	work_queue[i] = 0;
end
work_queue[-1] = 0;
free_list[-1] = EV_types::ContextThreadLength-1;
endfunction;



function automatic void add_to_queue(
ref thread_id_t work_queue [EV_types::ContextThreadLength-1:-1],
input thread_id_t thread_id
);
work_queue[work_queue[-1]] = thread_id;
work_queue[-1] = work_queue[-1]+1; 
endfunction;

function automatic void remove_from_queue(
ref thread_id_t work_queue [EV_types::ContextThreadLength-1:-1],
input thread_id_t thread_id
);
logic after;
after = 0;
for(int i=0;i<EV_types::ContextThreadLength-1;i++) begin
	if(after == 1)
		work_queue[i] = work_queue[i+1];
	else if(work_queue[i] == thread_id && i < work_queue[-1]) begin
		after = 1;
		work_queue[i] = work_queue[i+1];
		work_queue[-1] = work_queue[-1]-1; 
	end
end
endfunction;


function automatic thread_id_t get_next_id(
ref thread_id_t free_list [EV_types::ContextThreadLength-1:-1]);
get_next_id = free_list[0];
free_list[-1] = free_list[-1]-1;
for(int i=0;i<EV_types::ContextThreadLength-1;i++) begin
	free_list[i] = free_list[i+1];
end
endfunction;

function automatic void free_id(
ref thread_id_t free_list [EV_types::ContextThreadLength-1:-1],
input thread_id_t thread_id);
free_list[free_list[-1]] = thread_id;
free_list[-1] = free_list[-1]+1;
endfunction;

//the creation function
function automatic thread_id_t write_new_thread(
ref thread_program_stuct_t thread_context [EV_types::ContextThreadLength-1:0],
ref thread_status_t thread_status [EV_types::ContextThreadLength-1:0],
ref thread_id_t free_list [EV_types::ContextThreadLength-1:-1],
ref thread_id_t work_queue [EV_types::ContextThreadLength-1:-1],
input thread_program_stuct_t new_thread,
input thread_status_t new_thread_status
);
thread_id_t location;
location = get_next_id(free_list);



thread_context[location] = new_thread;
thread_status[location] = new_thread_status;
if (new_thread_status == ContextCache_pkg::work_queue) begin//add to work queue
	add_to_queue(work_queue,location);
end
write_new_thread= location;

log_thread_creation(location,new_thread_status.name);

endfunction;

function automatic thread_program_stuct_t get_thread_execute(
ref thread_program_stuct_t thread_context [EV_types::ContextThreadLength-1:0],
ref thread_status_t thread_status [EV_types::ContextThreadLength-1:0],
input thread_id_t thread_id
);
get_thread_execute = thread_context[thread_id];
thread_status[thread_id] = executing;
endfunction;


function automatic void delete_thread(
ref thread_program_stuct_t thread_context [EV_types::ContextThreadLength-1:0],
ref thread_status_t thread_status [EV_types::ContextThreadLength-1:0],
ref thread_id_t free_list [EV_types::ContextThreadLength-1:-1],
input thread_id_t thread_id);
	free_id(free_list,thread_id);
	thread_context[thread_id] = 0;
	thread_status[thread_id] = no_thread;
	
	debuglogger::log_thread_deletion(thread_id);
endfunction; 


thread_program_stuct_t thread_context [EV_types::ContextThreadLength-1:0];
thread_status_t thread_status [EV_types::ContextThreadLength-1:0];
thread_id_t free_list [EV_types::ContextThreadLength-1:-1];
thread_id_t work_queue [EV_types::ContextThreadLength-1:-1];
thread_id_t created_thread;
//temp variable to store either work_queue or wait for tigger dependent on the fork sleep input
thread_status_t forking_status;

always_ff @(posedge clk) begin

	if(rst == 1) begin
		requested_thread_return <= #CQ 0;
		out_thread_id <= #CQ 0;
	end else if(requesting_thread==1) begin
		requested_thread_return <= #CQ get_thread_execute(thread_context,thread_status,requested_thread_id);
		remove_from_queue(work_queue,requested_thread_id);
		out_thread_id <= #CQ requested_thread_id;
	end

	//send the next running to the 
	
	
	if(rst == 1) begin
		reset_cache(thread_context,thread_status,free_list,work_queue);
		user_insert_id <= #CQ 0;
	end else if(user_insert == 1) begin//for the system to insert things
		user_insert_id <= #CQ write_new_thread(thread_context,thread_status,free_list,work_queue,incoming_user_thread,incoming_user_status);
	end else if (incoming_control.incoming == 1) begin
		debuglogger::log_operation_call(incoming_control.incoming_id,"Context_control",$sformatf("%p",incoming_control));
		//assume normal behavior

		thread_context[incoming_control.incoming_id] = incoming_thread;//copy new thread_data
		
		//handle the reactive
		if(incoming_control.delete == 1) begin//delete 
			delete_thread(thread_context,thread_status,free_list,incoming_control.incoming_id);
		end else if (incoming_control.sleep == 0) begin// if no trigger wait go for executing
			thread_status[incoming_control.incoming_id] = ContextCache_pkg::work_queue;
			add_to_queue(work_queue,incoming_control.incoming_id);
		end else begin // need to sleep for a trigger
			thread_status[incoming_control.incoming_id] = ContextCache_pkg::wait_for_trigger;
		end
		debuglogger::log_thread_status(incoming_control.incoming_id,thread_status[incoming_control.incoming_id].name);
		//handle the transfrom
		case (incoming_control.execute_info) 
			none	:thread_context[incoming_control.incoming_id] = incoming_thread;
			clear	:begin thread_context[incoming_control.incoming_id].thread = 0; end
			pass	:begin thread_context[incoming_control.incoming_id] = combine_thread(incoming_thread,thread_context[incoming_control.execute_id]); end
			copy	:begin thread_context[incoming_control.incoming_id] = thread_context[incoming_control.execute_id]; end
			default :thread_context[incoming_control.incoming_id] = incoming_thread;
		endcase
		
		debuglogger::log_thread_exec(incoming_control.incoming_id,incoming_control.execute_info.name,incoming_control.execute_id);
		
		forking_status = (incoming_control.fork_sleep == 1) ? ContextCache_pkg::wait_for_trigger : ContextCache_pkg::work_queue;
		case(incoming_control.forking_info)
			none:;
			fork_me_copy: created_thread = write_new_thread(thread_context,thread_status,free_list,work_queue,incoming_thread,forking_status)  ;//new thread is a copy of me 
			fork_other_copy: created_thread = write_new_thread(thread_context,thread_status,free_list,work_queue,thread_context[incoming_control.forking_id],forking_status); // new thread is copy of another thread
			fork_other_pass: created_thread = write_new_thread(thread_context,thread_status,free_list,work_queue,combine_thread(incoming_thread,thread_context[incoming_control.forking_id]),forking_status);// thread is the comb of me and another
			default:;
		endcase
		
		
	   	debuglogger::log_thread_fork(incoming_control.incoming_id,incoming_control.forking_info.name,incoming_control.forking_id,created_thread,forking_status.name);
	   	
	
	end

	waiting_thread_count <= #CQ work_queue[-1];
	waiting_next_id <= #CQ work_queue[0];
	waiting_next_id2 <= #CQ work_queue[1];
end;




//program from thread 2 / high of thread 2
//data from thread 1 / low of thread 1
function thread_program_stuct_t combine_thread(
input thread_program_stuct_t thread_1,
input thread_program_stuct_t thread_2
);
//combine_thread.all[$bits(thread_program_stuct_t)-opcode_size:0] 
//     =thread_1.all[$bits(thread_program_stuct_t)-opcode_size:0];
//combine_thread.opcodes[0:opcode_size] 
//     =thread_2.opcodes[0:opcode_size];
combine_thread.thread = thread_1.thread;
combine_thread.instuctions = thread_2.instuctions;
endfunction;

endmodule
