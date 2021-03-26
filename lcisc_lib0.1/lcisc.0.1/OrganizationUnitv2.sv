
import EV_types::*;
import DataInterface_pkg::*;
import OrgUnit_pkg::*;
import orgunit_access_function_pkg::*;
module OrganizationUnitV2(
		input read_return_t data_return,
		input thread_program_stuct_t thread,
		input active,
		input thread_id_t thread_id,
		input logic clk,
		input logic rst,
		output pipeline_pass_structure execution_ev
		
	);
pipeline_pass_structure internal_state;
orgunit_a org_unit_operation;
always_ff @(posedge clk) begin
	if(rst == 0 && active == 1) begin
		//execution_ev <= #CQ 0;
		internal_state.thread = thread.thread;
		internal_state.instuctions = thread.instuctions;
		internal_state.data = (data_return.valid==1)?data_return.data:0;
		internal_state.shared = 0;
		internal_state.system.active_thread = active;
		internal_state.system.id = thread_id;
		internal_state.system.data_address =data_return.read_address;

		org_unit_operation = org_unit_access_function(internal_state);
		
        execution_ev  <= #CQ orgunit_f(internal_state,org_unit_operation);

		if(active==0 && data_return.valid == 1) $warning("data is given but active is false");
		if(thread_id != data_return.receive_id && data_return.valid == 1) $warning("data returned but not for correct thread");
	end else begin
		execution_ev <= #CQ 0;
	end
	
end;

endmodule;