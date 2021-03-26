import EV_types::*;
import DataInterface_pkg::*;
import ContextCache_pkg::*;


//
//write bit and write register
//read bit reader_request_id read_recive_id read_target
//read
//



module DataInterface(
input rst,
input clk,
input halt,
input read_request_t	read1,
input read_request_t	read2,
input write_request_t	write,
output read_return_t	read_back
);


function automatic void reset_data(
ref data_register_union_t memory [EV_types::DataStorageLength-1:0],
ref read_request_t request_list [EV_types::ContextThreadLength*2:-1]);

for(int i=0;i<EV_types::DataStorageLength;i++)
	memory[i] = 0;
for(int i=0;i<EV_types::ContextThreadLength*2;i++)
	request_list[i] = 0;
request_list[-1] = 0;

endfunction;


function automatic void complete_write(
ref data_register_union_t memory [EV_types::DataStorageLength-1:0],
input write_request_t write);

//logging



if (write.valid == 1) begin
memory[write.address] = write.data;
end;

endfunction;

//add to the request list  if it is valid
function automatic void add_to_queue(
ref read_request_t request_list [EV_types::ContextThreadLength*2:-1],
input read_request_t read);

if(read.valid == 1) begin

request_list[request_list[-1]] = read;
request_list[-1] = request_list[-1]+1; 
end

endfunction;

function automatic read_request_t pop_from_queue(
ref read_request_t request_list [EV_types::ContextThreadLength*2:-1]
);

if(request_list[-1] > 0) begin

pop_from_queue = request_list[0];//take out first
for(int i=0;i<EV_types::ContextThreadLength*2-1;i++) begin//update list
	request_list[i] = request_list[i+1];
end
request_list[-1] = request_list[-1]-1;

end else begin
	pop_from_queue = 0;//send back an invalid 
	pop_from_queue.valid = 0;
end

endfunction;

function read_return_t convert_request(
input data_register_union_t memory [EV_types::DataStorageLength-1:0],
input read_request_t read_request
);

convert_request.valid = read_request.valid;
convert_request.data = memory[read_request.read_address];
convert_request.request_id = read_request.request_id;
convert_request.receive_id =read_request.receive_id;
convert_request.read_address=read_request.read_address;

endfunction;




data_register_union_t memory [EV_types::DataStorageLength-1:0];
read_request_t request_list [EV_types::ContextThreadLength*2:-1];

read_request_t request_to_return;
integer data_latency;


always_ff @(posedge clk) begin
    if(rst == 1) begin
        reset_data(memory,request_list);
        request_to_return <= #CQ 0;
        data_latency = delayfunction(request_list[-1]);
        read_back <= #CQ 0;
    end else begin// normal operation
        //logging
        if(write.valid == 1)
            debuglogger::log_write_request(write.address,memory[write.address],write.data);
        if(read1.valid == 1)
            debuglogger::log_read_request(read1,1);
        if(read2.valid == 1)
            debuglogger::log_read_request(read1,2);
        
	//handle the incoming requests
        add_to_queue(request_list,read1);
        add_to_queue(request_list,read2);
        complete_write(memory,write);
        
        
          
         
        
        //figuring out the return
        if(request_list[0].valid == 1 && request_list[-1]>0 && halt == 0) begin//there is a request to process
            if (data_latency == 0) begin//we have waited for completion
                if(request_list[0].valid == 1) begin//time to complete the request
                    request_to_return = pop_from_queue(request_list);
                    //send back the request
                end else begin//there is no request being work on check the list
                    $error("why is there an invalid request");
                    request_to_return = pop_from_queue(request_list);
                end
            
            end
            if(data_latency > 0) begin
                if(halt == 0) begin
                    data_latency = data_latency - 1;
                end
            end
            
            
        end
        if(request_to_return.valid == 1) begin//if we just started a new read
            read_back <= #CQ convert_request(memory,request_to_return);//read the memory and send it back
            data_latency = delayfunction(request_list[-1]);//set next delay based on queue size
            request_to_return <= #CQ 0;//clear the return value
            
            //log the returning read
            debuglogger::log_read_complete(request_to_return);
        end else begin
            read_back <= #CQ 0;
        end
    end
end



endmodule;



