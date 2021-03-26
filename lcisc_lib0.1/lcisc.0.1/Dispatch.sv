import EV_types::*;
import debuglogger::*;
import dispatch_access_pkg::*;
import dispatch_operation::*;
module Dispatch(
	input  pipeline_pass_structure inState,
	output pipeline_pass_structure outState,

	//output pipeline_pass_structure internalInState,
	//input pipeline_pass_structure internalOutState,
	input logic rst,
	input logic clk);
	parameter  addressStart = 0;
	

shared_register_union_t shared_data;
exe_env_s exInState;
exe_env_s nextState;

dispatch_operation::pipeStage_operation stage_operation;



always_ff @(posedge clk) begin
	if (rst == 1) begin
        //internalInState <= #CQ 0;
        outState <= #CQ 0;
        shared_data <= #CQ 0;
	end if( inState.system.active_thread == 1) begin
	
//	if (internalOutState.system.active_thread == 1) begin
//		outState <= #CQ internalOutState;
//		shared_data <= #CQ internalOutState.shared;
		
//		//log any updates
//		debuglogger::log_shared_write(shared_data,internalOutState.shared);
		
//	end else begin
//		outState <= internalOutState;
//	end
//	if(inState.system.active_thread == 1) begin
//		internalInState <= #CQ inState;
//		internalInState.shared <= #CQ shared_data;
// 	end else begin
//		internalInState <= #CQ inState;
//	end
	//exInState.thread = inState.thread;
    //exInState.data = inState.data;
    //exInState.shared = shared_data;
    exInState = get_execution_environment(inState);
    exInState.shared = shared_data;
    stage_operation = dispatch_access_function(inState);
    
    nextState = dispatch_operation::Dispatch_process(stage_operation,exInState,inState.system.id);
    
    debuglogger::log_shared_write(shared_data,nextState.shared);
    shared_data = nextState.shared;
    
    //outState.thread <= #CQ nextState.thread;
    //outState.data <= #CQ nextState.data;
    //outState.shared <= #CQ nextState.shared;
    //outState.system <= #CQ inState.system;
    outState <= #CQ set_execution_environment(inState,nextState);
    
	
	end else begin
	    outState <= #CQ 0;
	end

end;

endmodule;
