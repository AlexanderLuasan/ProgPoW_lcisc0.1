
import Disposition_pkg::*;

import ContextCache_pkg::*;
import DataInterface_pkg::*;

package Programing; 
import EV_types::*;

parameter programMaxSize = 90;
parameter DataMaxSize = 10;
typedef struct packed {
EV_types::thread_program_stuct_t thread_and_instucions;
ContextCache_pkg::thread_status_t status;
} program_instruction;

function program_instruction blankThread;
blankThread.thread_and_instucions = 0;
blankThread.status = ContextCache_pkg::no_thread;

endfunction;




typedef struct{
integer length;
program_instruction program_threads [programMaxSize:0];
}program_data;


function void DisplayMemory(input data_register_union_t memory [DataStorageLength-1:0],
input integer row_count=10,input integer row_width=10,
input integer sr = 0,input integer sw = 0);
$display("----data contents----");
$write("row|\t");
for(int ii = row_width;ii>=sw;ii--) begin
	$write("%D|\t",ii);
end
$display("");
for(int i =sr;i<row_count;i++) begin
	$write("%D|\t",i);
	for(int ii = row_width; ii>=sw;ii--) begin
		$write("%D|\t", memory[i].u32[ii]);
	end
	$display("");
end

endfunction;


endpackage;














