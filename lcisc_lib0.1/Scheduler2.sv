import EV_types::*;
import DataInterface_pkg::*;

module Scheduler2( 
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

read_return_t next_data;
logic next_run;


always_ff @(posedge clk) begin

    if(rst == 1) begin
        next_data = 0;
        next_run = 0;
        requested_thread_id = 0;
        requesting_thread = 0;
        data_deliver = 0;
        operate = 0;
    end else begin // normal operation
        
        if(next_run == 1) begin//deliver the last set of values
            operate <= #CQ next_run;
            data_deliver <= #CQ next_data;
        end else begin
            operate <= #CQ 0;
            data_deliver <= #CQ 0;
        end
        
        if(data_return.valid == 1) begin//set the next values
            next_data <= #CQ data_return;
            next_run <= #CQ 1;
            requesting_thread <= #CQ 1;
            requested_thread_id <= #CQ data_return.receive_id;
        end else if(
             (
             (next_run == 0 && waiting_thread_count>0 ) ||
             (waiting_thread_count>0 && (next_data.receive_id !=waiting_next_id && next_run == 1) ) ||//not this next cycle
             (waiting_thread_count>1 && (next_data.receive_id == waiting_next_id && next_data.receive_id != waiting_next_id2 && next_run == 1) )//has two but this cycle runs not this
             )
             && halt == 0) begin
            next_data.data <= #CQ 0;
            next_data.receive_id<= #CQ (!(waiting_thread_count>1 && (next_data.receive_id == waiting_next_id && next_data.receive_id != waiting_next_id2 && next_run == 1)))?waiting_next_id:waiting_next_id2;
            next_data.request_id<= #CQ (!(waiting_thread_count>1 && (next_data.receive_id == waiting_next_id && next_data.receive_id != waiting_next_id2 && next_run == 1)))?waiting_next_id:waiting_next_id2;
            next_data.read_address <= #CQ 0;
            next_data.valid <= #CQ 1;
            next_run <= #CQ 1;
            requesting_thread <= #CQ 1;
            requested_thread_id <= #CQ (!(waiting_thread_count>1 && (next_data.receive_id == waiting_next_id && next_data.receive_id != waiting_next_id2 && next_run == 1)))?waiting_next_id:waiting_next_id2;
        end else begin
            next_data <= #CQ 0;
            next_run <= #CQ 0;
            requesting_thread <= #CQ 0;
            requested_thread_id <= #CQ 0;
        end
            
            
        
    
    
    end



end


endmodule;
