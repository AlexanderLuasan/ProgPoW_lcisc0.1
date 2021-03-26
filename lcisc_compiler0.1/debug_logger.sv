
package debuglogger;
import EV_types::*;
import DataInterface_pkg::*;


function automatic void inital_write_memory(ref data_register_union_t memory [DataStorageLength-1:0]);
int fd;
fd = $fopen("inital_data.dat","w");
if(fd) $display("writting inital_data.dat");
else $display("failed to write inital_data.dat");
for(int i=0;i<DataStorageLength;i++) begin
    $fwrite(fd,"%h\n",memory[i]);
end
$fclose(fd);

endfunction;

function automatic void final_write_memory(ref data_register_union_t memory [DataStorageLength-1:0]);
int fd;
fd = $fopen("final_data.dat","w");
if(fd) $display("writting final_data.dat");
else $display("failed to write final_data.dat");
for(int i=0;i<DataStorageLength;i++) begin
    $fwrite(fd,"%h\n",memory[i]);
end
$fclose(fd);

endfunction;



function void clear_log();
int fd;
fd = $fopen("lcisc.log","w");
if(fd) $display("clearing lcisc.log");
else $display("failed to write lcisc.log");
$fclose(fd);
endfunction;


function void start_log(int fd, string log_type);
    $fwrite(fd,"{\"type\":\"%s\"",log_type);
endfunction;
function void end_log(int fd );
    $fwrite(fd,"}\n");
endfunction

function void log_hex(int fd, string name, logic[EV_Size-1:0] value);
    $fwrite(fd,",\"%s\":\"%h\"",name,value);
endfunction;

function void log_time(int fd);
    $fwrite(fd,",\"time\": %d",$time);
endfunction

function void log_number(int fd, string name, longint value );

    $fwrite(fd,",\"%s\":%d",name,value);

endfunction

function void log_string(int fd, string name, string value);
    $fwrite(fd,",\"%s\":\"%s\"",name,value);
endfunction

function void log_operation_call(input thread_id_t thread_id,input string function_name,input string info);

int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");

start_log(fd,"operation");
log_time(fd);
log_number(fd,"thread_id",thread_id);
log_string(fd,"operation",function_name);
log_string(fd,"arguments",info);
end_log(fd);


$fclose(fd);

endfunction;


function void log_thread_creation(input thread_id_t thread_id,input string status);

int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");

start_log(fd,"thread_create");
log_time(fd);
log_number(fd,"thread_id",thread_id);
log_string(fd,"status",status);
end_log(fd);


$fclose(fd);

endfunction;



function void log_thread_deletion(input thread_id_t thread_id);
int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");
start_log(fd,"thread_delete");
log_time(fd);
log_number(fd,"thread_id",thread_id);
end_log(fd);
$fclose(fd);
endfunction;


function void log_thread_fork(input thread_id_t thread_id,input string forking_method,input thread_id_t target,input thread_id_t created,input string created_status);
int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");
start_log(fd,"thread_fork");
log_time(fd);
log_number(fd,"thread_id",thread_id);
log_number(fd,"target",target);
log_string(fd,"method",forking_method);
log_number(fd,"created",created);
log_string(fd,"created_status",created_status);
end_log(fd);
$fclose(fd);
endfunction;


function void log_thread_exec(input thread_id_t thread_id,input string exec_method,input thread_id_t target);
int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");
start_log(fd,"thread_exec");
log_time(fd);
log_number(fd,"thread_id",thread_id);
log_number(fd,"target",target);
log_string(fd,"method",exec_method);
end_log(fd);
$fclose(fd);
endfunction;

function void log_thread_status(input thread_id_t thread_id,input string status);
int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");
start_log(fd,"thread_status");
log_time(fd);
log_number(fd,"thread_id",thread_id);
log_string(fd,"status",status);
end_log(fd);
$fclose(fd);
endfunction;


function void log_read_request(input read_request_t request,input integer channel);
int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");
start_log(fd,"read_request");
log_time(fd);
log_number(fd,"request_id",request.request_id);
log_number(fd,"receive_id",request.receive_id);
log_number(fd,"address",request.read_address);
log_number(fd,"channel",channel);
end_log(fd);
$fclose(fd);
endfunction;

function void log_read_complete(input read_request_t request);
int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");
start_log(fd,"read_complete");
log_time(fd);
log_number(fd,"request_id",request.request_id);
log_number(fd,"receive_id",request.receive_id);
log_number(fd,"address",request.read_address);
end_log(fd);
$fclose(fd);
endfunction;


function void log_write_request(input data_address_t address,input data_register_union_t start,input data_register_union_t after);
int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");
start_log(fd,"write_request");
log_time(fd);
log_number(fd,"address",address);
log_hex(fd,"start",start);
log_hex(fd,"after",after);
end_log(fd);
$fclose(fd);
endfunction;

function void log_shared_write(input shared_register_union_t start,input shared_register_union_t after);
int fd;
fd = $fopen("lcisc.log","a");
if(!fd) $display("failed to write lcisc.log");
start_log(fd,"shared_write");
log_time(fd);
log_hex(fd,"start",start);
log_hex(fd,"after",after);
end_log(fd);
$fclose(fd);
endfunction

endpackage