
import EV_types::*;
import DataInterface_pkg::*;

module OrganizationUnit(
		input read_return_t data_return,
		input thread_program_stuct_t thread,
		input active,
		input thread_id_t thread_id,
		input logic clk,
		input logic rst,
		output pipeline_pass_structure execution_ev
		
	);

always_ff @(posedge clk) begin
	if(rst == 0 && active == 1) begin
		//execution_ev <= #CQ 0;
		execution_ev.thread <= #CQ thread.thread;
		execution_ev.instuctions <= #CQ thread.instuctions;
		execution_ev.data <= #CQ (data_return.valid==1)?data_return.data:0;
		execution_ev.system.active_thread <= #CQ active;
		execution_ev.system.id <= #CQ thread_id;
		execution_ev.system.data_address <= #CQ data_return.read_address;

		if(active==0 && data_return.valid == 1) $warning("data is given but active is false");
		if(thread_id != data_return.receive_id && data_return.valid == 1) $warning("data returned but not for correct thread");
	end else begin
		execution_ev <= #CQ 0;
	end
	
end;

endmodule;