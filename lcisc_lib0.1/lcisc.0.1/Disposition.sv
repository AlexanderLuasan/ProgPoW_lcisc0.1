import EV_types::*;
import ContextCache_pkg::*;
import SimpleConditional::*;
import DataInterface_pkg::*; 
import disposition_access_function_pkg::*;

import debuglogger::*;

module Disposition (
	input logic clk,
	input logic rst,
	input pipeline_pass_structure inputState,


	//data to cache
	
	output thread_program_stuct_t incoming_thread,
	output ContextCache_Control incoming_control,

	//data to memoroy

	output read_request_t	read1,
	output read_request_t	read2,
	output write_request_t	write
);
parameter  addressStart = 0;


Disposition_pkg::disposition_operation disp_operation;
exe_env_u EX_EV;





always_ff @(posedge clk) begin
	EX_EV = get_execution_environment(inputState);
	disp_operation = dispostion_access_function(inputState);
	if (rst == 0 && inputState.system.active_thread == 1) begin // both not reseting and active

		//always triggers
		incoming_thread <= #CQ get_thread_program_struct(inputState);
		incoming_control.incoming <= #CQ 1;
		incoming_control.incoming_id <= #CQ inputState.system.id;
		
		incoming_control.delete <= #CQ checkSingleCondition_f(EX_EV,disp_operation.delete);
		incoming_control.sleep <= #CQ checkSingleCondition_f(EX_EV,disp_operation.sleep);

		//exec
		if(checkSingleCondition_f(EX_EV,disp_operation.exec_conditional)==1) begin
			incoming_control.execute_info <= #CQ disp_operation.exec_info;
			incoming_control.execute_id <= #CQ EX_EV.u64[disp_operation.exec_id];
		end else begin 
			incoming_control.execute_info <= #CQ none;
			incoming_control.execute_id <= #CQ 0;
		end

		//$display("fork_condition flag %d, condition %b, negate %b",disposition_operation.fork_conditional.flag,disposition_operation.fork_conditional.condition,disposition_operation.fork_conditional.negate);
		if(checkSingleCondition_f(EX_EV,disp_operation.fork_conditional)==1) begin
			incoming_control.forking_info <= #CQ disp_operation.fork_info;
			incoming_control.forking_id <= #CQ EX_EV.u64[disp_operation.fork_id];
			incoming_control.fork_sleep <= #CQ disp_operation.fork_sleep;
		end else begin 
			incoming_control.forking_info <= #CQ no_fork;
			incoming_control.forking_id <= #CQ 0;
			incoming_control.fork_sleep <= #CQ 0;
		end
		
		if(inputState.system.id == 66)
		  $display(inputState.system.id);

		
		read1.valid <= #CQ checkSingleCondition_f(EX_EV,disp_operation.self_read);
		read1.request_id <= #CQ inputState.system.id;
		read1.receive_id <= #CQ inputState.system.id;
		read1.read_address <= #CQ EX_EV.u64[disp_operation.self_read_address];

		read2.valid <= #CQ checkSingleCondition_f(EX_EV,disp_operation.other_read);
		read2.request_id <= #CQ inputState.system.id;
		read2.receive_id <= #CQ EX_EV.u64[disp_operation.read_other_who];
		read2.read_address <= #CQ EX_EV.u64[disp_operation.read_other_where];

		write.valid <= #CQ checkSingleCondition_f(EX_EV,disp_operation.write);
		write.address <= #CQ  (disp_operation.write_back == 0)?EX_EV.u64[disp_operation.write_address]:inputState.system.data_address;
		write.data <= #CQ inputState.data;

	end else begin
		incoming_control <= #CQ 0;
		incoming_control.incoming <= #CQ 0;
		incoming_thread <= #CQ 0;
		read1 <= #CQ 0;
		read2 <= #CQ 0; 
		write <= #CQ 0;
	end;
end;
endmodule;



