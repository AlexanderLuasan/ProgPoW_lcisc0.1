import EV_types::*;
import DataInterface_pkg::*;




module Scheduler(
input logic clk,
input logic rst,
input logic halt,

input read_return_t data_return,

output read_return_t data_deliver,

output logic operate,

input thread_id_t waiting_thread_count,
input thread_id_t waiting_next_id,
input thread_id_t waiting_next_id2,

output logic requesting_thread,
output thread_id_t requested_thread_id

);

read_return_t buffered_data [3:0];
logic run_next; 
thread_id_t buffered_workQueue;
logic work_queue;


always_ff @(posedge clk) begin

if(rst == 1) begin
	requesting_thread <= #CQ 0;
	requested_thread_id <= #CQ 0;
	data_deliver <= #CQ 0;
	run_next <= #CQ 0;
	operate <= #CQ 0;
	work_queue <= #CQ 0;
	buffered_workQueue <= #CQ 0;
	for(int i=0;i<4;i++) 
		buffered_data[i] <= #CQ 0;
end else begin
	//are we running this cycle
	operate <= #CQ run_next;
	
	
	if(buffered_data[0].valid == 1) begin // we need to send data to the organization unit this cycle
		data_deliver <= #CQ buffered_data[0];
	end else begin
		data_deliver <= #CQ 0;
	end

	//figure out what will happend next cycle
	if(buffered_data[1].valid==1) begin // next cycle we will send a data to the organization unit
		requested_thread_id <= #CQ buffered_data[1].receive_id;
		requesting_thread <= #CQ 1;
		run_next <= #CQ 1;
		work_queue <= #CQ 0;
	end else if(waiting_thread_count>0+run_next && halt == 0) begin // we don't have data so we can run a non data request
		
		if(work_queue != 1) begin
			requested_thread_id <= #CQ waiting_next_id;
			buffered_data[1].receive_id <= #CQ waiting_next_id;
			work_queue <= #CQ 1;
		end else begin
			requested_thread_id <= #CQ buffered_workQueue;
			buffered_data[1].receive_id <= #CQ buffered_workQueue;
			work_queue <= #CQ 1;
		end
		if(waiting_thread_count>1)
			buffered_workQueue <= #CQ waiting_next_id2;
		requesting_thread <= #CQ 1;
		run_next <= #CQ 1;
	end else begin//nothing to do next cycle
		requested_thread_id <= #CQ 0;
		requesting_thread <= #CQ 0;
		run_next <= #CQ 0;
		work_queue <= #CQ 0;
	end


	for(int i=0;i<3;i++)
		buffered_data[i] <= #CQ buffered_data[i+1];
	
	buffered_data[2] <= #CQ data_return;

end


end






endmodule;
