
package DoubleData;

import Programing::*;
import EV_types::*;
import ContextCache_pkg::*;
import PipelineStage_pkg::*;
import Disposition_pkg::*;
import Adder::*;


function program_instruction main();

main.status = ContextCache_pkg::work_queue;

main.thread.u32[0] = 1;
main.thread.u32[1] = 1;
main.thread.u32[2] = -1;
main.thread.opcodes[flagCount+(0)*pipelineStageSize:flagCount+(1)*pipelineStageSize-1] = wrap(adder,adder_o(threadAddress_u32+1,threadAddress_u32+1,threadAddress_u32+1));
main.thread.opcodes[flagCount+(1)*pipelineStageSize:flagCount+(2)*pipelineStageSize-1] = wrap(adder,adder_o(threadAddress_u32+0,threadAddress_u32+2,threadAddress_u32+2));
main.thread.opcodes[flagCount+(2)*pipelineStageSize:flagCount+(3)*pipelineStageSize-1] = wrap(adder,adder_o(threadAddress_u32+1,dataAddress_u32,dataAddress_u32));
main.thread.opcodes[flagCount+(3)*pipelineStageSize:flagCount+(4)*pipelineStageSize-1] = wrap(no_opp,0);
main.thread.opcodes[flagCount+(4)*pipelineStageSize:flagCount+(5)*pipelineStageSize-1] = wrap(no_opp,0);
main.thread.opcodes[flagCount+(5)*pipelineStageSize:flagCount+(5)*pipelineStageSize+$bits(disposition_a)-1]
 = disposition_o(
.sleep(-100),
.write(100),
.write_address(threadAddress_u64+1)
);


endfunction;


function program_data program_threads();

program_threads.length = 1;
program_threads.program_threads[0] = main();

endfunction;



endpackage;