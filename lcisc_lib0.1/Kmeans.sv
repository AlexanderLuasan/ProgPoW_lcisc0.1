package Kmeans;
import Programing::*;
import EV_types::*;
import ContextCache_pkg::*;
import PipelineStage_pkg::*;
import Disposition_pkg::*;
import Adder::*;
import DifferenceMap::*;
import MultiplyMap::*;
import AccumulateReduce::*;
import ArraySwap::*;
import Move::*;
import SimpleComparison::*;
import ConditionalIncrement::*;
import Operation_pkg::*;
import AdditionMap::*;
//point of size n located at zero in the memory

let st(x) = flagCount+(x)*pipelineStageSize;
let fn(x) = flagCount+(x+1)*pipelineStageSize-1;

parameter NUMBER_OF_ATTRIBUTES = 2;
parameter NUMBER_OF_POINTS = 40;

parameter cluster_data_addess_start = 50; 
parameter NUMBER_OF_CLUSTERS = 3;

//shared register
parameter number_of_clusters = 	sharedAddress_u32; 
parameter cluster_number    = 	sharedAddress_u32+1;
parameter max_points =  	sharedAddress_u32+2;
parameter complted_points =	sharedAddress_u32+3;
parameter point_number =  	sharedAddress_u32+4;

parameter cluster_start = 	sharedAddress_u32+6;
parameter divisor = 	cluster_start+NUMBER_OF_ATTRIBUTES;
//data reister type point
parameter point_start = dataAddress_u32; 
parameter min_distance_value = point_start+NUMBER_OF_ATTRIBUTES;
parameter min_distance_cluster = min_distance_value+1;



//step one caclulate distances
//cluster is in shared
//point is data

parameter calcDistance_thread=2;
function program_instruction calcDistance();
parameter temp_location_for_accumulate = threadAddress_u32+1;
parameter CONST_ONE = threadAddress_u32+2;
calcDistance=0;
calcDistance.thread.u32[2] = -1;
calcDistance.thread.u32[3] = -1;
calcDistance.status = ContextCache_pkg::template;

//increment values
calcDistance.thread.opcodes[st(0):fn(0)] = wrap(differenceMap,differenceMap_o(complted_points,CONST_ONE,2));

// temp_location_for_accumulate = dist(cluster,point)
//dist is diference multiply sum
calcDistance.thread.opcodes[st(1):fn(1)] = wrap(differenceMap,differenceMap_o(cluster_start,point_start,NUMBER_OF_ATTRIBUTES));
calcDistance.thread.opcodes[st(2):fn(2)] = wrap(multiplyMap,multiplyMap_o(cluster_start,cluster_start,NUMBER_OF_ATTRIBUTES));
calcDistance.thread.opcodes[st(3):fn(3)] = wrap(accumulateReduce,accumulateReduce_o(cluster_start,NUMBER_OF_ATTRIBUTES,temp_location_for_accumulate));


calcDistance.thread.opcodes[st(4):fn(4)] = wrap(no_opp,0);
//if(temp_location_for_accumulate<min_distance_value) flag 1
calcDistance.thread.opcodes[st(5):fn(5)] = wrap(comparison,comparison_o(temp_location_for_accumulate,AltB,min_distance_value,1));

//flag 1 min_distance_value   = temp_location_for_accumulate 
//   and min_distance_cluster = cluter_number
calcDistance.thread.opcodes[st(6):fn(6)] = wrap(move,move_o(.address1(temp_location_for_accumulate),.address2(min_distance_value),.conditional_flag(1)));
calcDistance.thread.opcodes[st(7):fn(7)] = wrap(move,move_o(.address1(cluster_number),.address2(min_distance_cluster),.conditional_flag(1)));

calcDistance.thread.opcodes[st(8):fn(8)] = wrap(comparison,comparison_o(point_number,AlteqB,max_points,2));

//write back the result and end execution
calcDistance.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
 = disposition_o(.write(100),.write_back(1),.delete(-2),.sleep(2),.self_read(2),.self_read_address(sharedAddress_u64+2));

endfunction;

//produce 8 copies of itself and launch 
parameter map_data_thread = 1;
function program_instruction map_data();
parameter const_one = threadAddress_u32;
parameter const_zero = threadAddress_u32+1;


parameter reading_address_u64 = threadAddress_u64+2;
parameter reading_address_u32 = threadAddress_u32+4;
parameter map_function = threadAddress_u64+3;
map_data = 0;
map_data.status = ContextCache_pkg::template;
map_data.thread.u32[0] = 1;
map_data.thread.u32[1] = 0;



map_data.thread.u64[3] = calcDistance_thread;


//increment point_number += 1 we did not split last cycle
map_data.thread.opcodes[st(0):fn(0)] = wrap(adder,adder_o(point_number,const_one,point_number));

//see if we have completely incremented if so delete else we create a new copy of self to continue execution
map_data.thread.opcodes[st(1):fn(1)] = wrap(comparison,comparison_o(point_number,AgtB,max_points,1));

//caclulate address  reading_address = point_number
map_data.thread.opcodes[st(2):fn(2)] = wrap(adder,adder_o(point_number,const_zero,reading_address_u32));




map_data.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
=disposition_o(	.self_read(100),.self_read_address(reading_address_u64),
		.sleep(100),
		.exec_conditional(100),.exec_info(copy),.exec_id(map_function),
		.fork_conditional(-1),.fork_info(fork_me_copy),.fork_sleep(-100),
		.delete(1)
		);

endfunction;

parameter load_cluster_thread=0;
function program_instruction load_cluster();
parameter launch_map_id = threadAddress_u64+1;   
load_cluster = 0;
load_cluster.status =  ContextCache_pkg::template;
load_cluster.thread.u64[0] = cluster_data_addess_start;
load_cluster.thread.u64[1] = map_data_thread;


//if flag swap data with shared
load_cluster.thread.opcodes[st(0):fn(0)] = wrap(arraySwap,arraySwap_o(cluster_start,dataAddress_u32,NUMBER_OF_ATTRIBUTES,1));

//finding the address
load_cluster.thread.opcodes[st(1):fn(1)] = wrap(adder,adder_o(threadAddress_u32,cluster_number,threadAddress_u32));

//if flag1 then flag2
load_cluster.thread.opcodes[st(2):fn(2)] = wrap(comparison,comparison_o(threadAddress_u32,AeqB,threadAddress_u32,2,1));
//if (not flag1) then flag 1
load_cluster.thread.opcodes[st(3):fn(3)] = wrap(comparison,comparison_o(threadAddress_u32,AeqB,threadAddress_u32,1,-1));
//if flag2 then not flag1
load_cluster.thread.opcodes[st(4):fn(4)] = wrap(comparison,comparison_o(threadAddress_u32,AneqB,threadAddress_u32,1,2));
load_cluster.thread.opcodes[st(5):fn(5)] = wrap(no_opp,0);
load_cluster.thread.opcodes[st(6):fn(6)] = wrap(no_opp,0);
load_cluster.thread.opcodes[st(7):fn(7)] = wrap(no_opp,0);
load_cluster.thread.opcodes[st(8):fn(8)] = wrap(no_opp,0);

//if flag 1 read
//if flag 2 delete
load_cluster.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
= disposition_o(.self_read(1),.self_read_address(threadAddress_u64),.sleep(1),
		.delete(2),
		.fork_conditional(2),.fork_info(fork_other_copy),.fork_sleep(0),.fork_id(launch_map_id)
		);


endfunction;


parameter cluster_loop_wait_thread = 4;
parameter cluster_loop_thread = 3;
function program_instruction cluster_loop();

parameter MAX_CLUSTER = threadAddress_u32+6;
parameter current_cluster = threadAddress_u32+7;
parameter TOTAL_POINTS = threadAddress_u32+8;
parameter CONST_ZERO = threadAddress_u32+9;
parameter CONST_NEG_1 = threadAddress_u32+10;
parameter CONST_ZERO2 = threadAddress_u32+11;
parameter CONST_ONE = threadAddress_u32+12;

parameter fork_id_for_load_cluster = threadAddress_u64;
parameter fork_id_for_cluster_wait = threadAddress_u64+1;
parameter fork_id_for_cluster_loop = threadAddress_u64+2;

cluster_loop = 0;
cluster_loop.status = ContextCache_pkg::template;

cluster_loop.thread.u64[0] = load_cluster_thread;
cluster_loop.thread.u64[1] = cluster_loop_wait_thread;
cluster_loop.thread.u64[2] = cluster_loop_thread;

cluster_loop.thread.u32[6] = NUMBER_OF_CLUSTERS;
cluster_loop.thread.u32[7] = 0;
cluster_loop.thread.u32[8] = NUMBER_OF_POINTS;
cluster_loop.thread.u32[9] = 0;
cluster_loop.thread.u32[10] = -1;
cluster_loop.thread.u32[11] = 0;
cluster_loop.thread.u32[12] = 1;

cluster_loop.thread.opcodes[st(0):fn(0)] = wrap(arraySwap,arraySwap_o(MAX_CLUSTER,number_of_clusters,6,-1));
cluster_loop.thread.opcodes[st(1):fn(1)] = wrap(arraySwap,arraySwap_o(MAX_CLUSTER,number_of_clusters,6,-1));
cluster_loop.thread.opcodes[st(2):fn(2)] = wrap(comparison,comparison_o(CONST_ZERO,AeqB,CONST_ZERO,8));
cluster_loop.thread.opcodes[st(3):fn(3)] = wrap(adder,adder_o(current_cluster,CONST_ONE,current_cluster));



cluster_loop.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
= disposition_o(
		.exec_conditional(100),.exec_info(pass),.exec_id(fork_id_for_cluster_wait),
		.fork_conditional(100),.fork_info(fork_other_copy),.fork_sleep(0),.fork_id(fork_id_for_load_cluster)
		);

endfunction;


function program_instruction cluster_loop_wait();

parameter MAX_CLUSTER = threadAddress_u32+6;
parameter current_cluster = threadAddress_u32+7;
parameter TOTAL_POINTS = threadAddress_u32+8;
parameter CONST_ZERO = threadAddress_u32+9;
parameter CONST_NEG_1 = threadAddress_u32+10;
parameter CONST_ZERO2 = threadAddress_u32+11;
parameter CONST_ONE = threadAddress_u32+12;

parameter fork_id_for_load_cluster = threadAddress_u64;
parameter fork_id_for_cluster_wait = threadAddress_u64+1;
parameter fork_id_for_cluster_loop = threadAddress_u64+2;

cluster_loop_wait = 0;
cluster_loop_wait.status = ContextCache_pkg::template;

cluster_loop_wait.thread.u64[0] = load_cluster_thread;
cluster_loop_wait.thread.u64[1] = cluster_loop_wait_thread;
cluster_loop_wait.thread.u64[2] = cluster_loop_thread;

cluster_loop_wait.thread.u32[6] = NUMBER_OF_CLUSTERS;
cluster_loop_wait.thread.u32[7] = 0;
cluster_loop_wait.thread.u32[8] = NUMBER_OF_POINTS;
cluster_loop_wait.thread.u32[9] = 0;
cluster_loop_wait.thread.u32[10] = -1;
cluster_loop_wait.thread.u32[11] = 0;
cluster_loop_wait.thread.u32[12] = 1;


cluster_loop_wait.thread.opcodes[st(0):fn(0)] = wrap(comparison,comparison_o(complted_points,AgteqB,max_points,2));

cluster_loop_wait.thread.opcodes[st(1):fn(1)] = wrap(comparison,comparison_o(current_cluster,AgteqB,MAX_CLUSTER,8,2));

cluster_loop_wait.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
= disposition_o(
		.delete(8),
		.exec_conditional(2),.exec_info(pass),.exec_id(fork_id_for_cluster_loop)

		);
endfunction;



parameter acumulate1_cluster_thread = 7;
parameter acumulate2_cluster_thread = 8;
parameter acumulate3_cluster_thread = 9;
function program_instruction acumulate3();

parameter accumulate1_function_id = threadAddress_u64;
parameter accumulate2_function_id = threadAddress_u64+1;
parameter accumulate3_function_id = threadAddress_u64+2;
parameter point_location = threadAddress_u32+6;
acumulate3 = 0;
acumulate3.thread.u64[0] = acumulate1_cluster_thread;
acumulate3.thread.u64[1] = acumulate2_cluster_thread;
acumulate3.thread.u64[2] = acumulate3_cluster_thread;
acumulate3.thread.u32[point_location+NUMBER_OF_ATTRIBUTES] = 1;
acumulate3.status = ContextCache_pkg::template;
acumulate3.thread.opcodes[st(0):fn(0)] = wrap(conInc,conditionalIncrement_o(complted_points,AltB,i(NUMBER_OF_POINTS),i(1)));


acumulate3.thread.opcodes[st(1):fn(1)] = wrap(comparison,comparison_o(threadAddress_u32,AeqB,threadAddress_u32,8));

acumulate3.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
= disposition_o(
		.delete(100)
		);

endfunction;

function program_instruction acumulate2();

parameter accumulate1_function_id = threadAddress_u64;
parameter accumulate3_function_id = threadAddress_u64+1;

parameter point_location = threadAddress_u32+4;
acumulate2 = 0;
acumulate2.thread.u64[0] = acumulate2_cluster_thread;
acumulate2.thread.u64[1] = acumulate3_cluster_thread;

acumulate2.thread.u32[4+NUMBER_OF_ATTRIBUTES] = 1;
acumulate2.status = ContextCache_pkg::template;
acumulate2.thread.opcodes[st(0):fn(0)] = wrap(additionMap,additionMap_o(cluster_start,point_location,i(NUMBER_OF_ATTRIBUTES+1)));

acumulate2.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
= disposition_o(
		.exec_conditional(100),.exec_info(copy),.exec_id(accumulate3_function_id)
		);



endfunction;


function program_instruction acumulate1();
//someone has alread read for me
parameter accumulate_function_id = threadAddress_u64;
parameter accumulate3_function_id = threadAddress_u64+1;
parameter point_location = threadAddress_u32+4;
acumulate1 = 0;

acumulate1.thread.u64[0] = acumulate2_cluster_thread;
acumulate1.thread.u64[1] = acumulate3_cluster_thread;
acumulate1.thread.u32[4+NUMBER_OF_ATTRIBUTES] = 1;
acumulate1.status = ContextCache_pkg::template;
//if point number < 40 point number + 1
acumulate1.thread.opcodes[st(0):fn(0)] = wrap(conInc,conditionalIncrement_o(point_number,AltB,i(NUMBER_OF_POINTS),i(1),1));

//compare nearest cluster set flag 2 if this should be added
acumulate1.thread.opcodes[st(1):fn(1)] = wrap(comparison,comparison_o(cluster_number,AeqB,min_distance_cluster,2));

//set up for accumulate
acumulate1.thread.opcodes[st(2):fn(2)] = wrap(arraySwap,arraySwap_o(point_start,point_location,NUMBER_OF_ATTRIBUTES,2));
//if not accumulate jump to complete
acumulate1.thread.opcodes[st(3):fn(3)] = wrap(move,move_o(.address1(threadAddress_u32),.address2(threadAddress_u32+2),.conditional_flag(-2)));



acumulate1.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
= disposition_o(
		.delete(-1),
		.sleep(1),
		.self_read(1),.self_read_address(sharedAddress_u64+2),
		.fork_conditional(1000),.fork_info(fork_other_pass),.fork_id(accumulate_function_id)
		);

endfunction;


//purpose zero cluster numbers
//set the cluter number
//zero the max_point / completed points
parameter load_accumulate_thread = 6;
function program_instruction load_accumulate();


parameter current_cluster_number = threadAddress_u32;
parameter shared_register_default = threadAddress_u32+1;


load_accumulate=0;
load_accumulate.status = ContextCache_pkg::template;
load_accumulate.thread.u32[0] = 0;

load_accumulate.thread.u32[1] = 0;
load_accumulate.thread.u32[2] = 0;
load_accumulate.thread.u32[3] = 0;
load_accumulate.thread.u32[4] = 0;
load_accumulate.thread.u32[5] = 0;
load_accumulate.thread.u32[6] = 0;

//set the shard register
load_accumulate.thread.opcodes[st(0):fn(0)] = wrap(arraySwap,arraySwap_o(cluster_number,current_cluster_number,5+NUMBER_OF_ATTRIBUTES,-1));
load_accumulate.thread.opcodes[st(1):fn(1)] = wrap(arraySwap,arraySwap_o(cluster_number,current_cluster_number,5+NUMBER_OF_ATTRIBUTES,-1));

//set flag 1
load_accumulate.thread.opcodes[st(2):fn(2)] = wrap(comparison,comparison_o(a(threadAddress_u32),AeqB,a(threadAddress_u32),1));

//if the points are completed set flag one
load_accumulate.thread.opcodes[st(3):fn(3)] = wrap(comparison,comparison_o(a(complted_points),AgteqB,i(NUMBER_OF_POINTS),2));


load_accumulate.thread.opcodes[st(3):fn(3)] = wrap(comparison,comparison_o(a(complted_points),AgteqB,i(NUMBER_OF_POINTS),2));


load_accumulate.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
= disposition_o(
		.delete(8),
		.exec_conditional(2),.exec_info(pass),.exec_id(0)
		
		);





endfunction;

parameter main_thread = 5;
function program_instruction main();

main = 0;
main.status = ContextCache_pkg::work_queue;
main.thread.u64[0] = acumulate1_cluster_thread;//cluster_loop_thread;
main.thread.opcodes[flagCount+(pipeLength+1)*pipelineStageSize:flagCount+(pipeLength+1)*pipelineStageSize+$bits(disposition_a)-1]
= disposition_o(
		.sleep(100),
		.exec_conditional(100),.exec_info(copy),.exec_id(threadAddress_u64),
		.self_read(100),.self_read_address(threadAddress_u64+1)
		);
endfunction;
function program_data program_threads();

program_threads.length = 10;
program_threads.program_threads[load_cluster_thread] = load_cluster();
program_threads.program_threads[map_data_thread] = map_data();
program_threads.program_threads[calcDistance_thread] = calcDistance();
program_threads.program_threads[cluster_loop_thread] = cluster_loop();
program_threads.program_threads[cluster_loop_wait_thread] = cluster_loop_wait();
program_threads.program_threads[main_thread] = main();

program_threads.program_threads[load_accumulate_thread] = load_accumulate();

program_threads.program_threads[acumulate1_cluster_thread] = acumulate1();
program_threads.program_threads[acumulate2_cluster_thread] = acumulate2();
program_threads.program_threads[acumulate3_cluster_thread] = acumulate3();





//program_threads.program_threads[cluster_loop_thread] = cluster_loop();
//program_threads.program_threads[cluster_loop_swap_thread] = cluster_loop_swap();

endfunction;

function automatic void  data_initlize(ref data_register_union_t memory [DataStorageLength:0]);

for(int i=0;i<NUMBER_OF_POINTS;i++) begin
	memory[i] = 0;
	memory[i].u32[1] = i;
	memory[i].u32[0] = i;
	memory[i].u32[2] = 100000000;
end

memory[cluster_data_addess_start].u32[0] = 25;
memory[cluster_data_addess_start].u32[1] = 25;

memory[cluster_data_addess_start+1].u32[0] = 5;
memory[cluster_data_addess_start+1].u32[1] = 5;

memory[cluster_data_addess_start+2].u32[0] = 1;
memory[cluster_data_addess_start+2].u32[1] = 1;
endfunction;


endpackage;

