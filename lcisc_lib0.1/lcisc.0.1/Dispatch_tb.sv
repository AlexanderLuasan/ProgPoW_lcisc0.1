//import EV_types::*;
//import PipelineStage_pkg::*;
//import Adder::*;
//module Dispatch_tb;

//logic clk;
//pipeline_pass_structure Input_state;
//pipeline_pass_structure Output_state;
//logic rst;

//pipeline_pass_structure internalDispatchA;
//pipeline_pass_structure internalDispatchB;

//pipeline_operation instructionSetup = wrap(adder,adder_o(threadAddress_u32,threadAddress_u32+1,sharedAddress_u32));
//pipeline_operation instruction1 = wrap(adder,adder_o(sharedAddress_u32,sharedAddress_u32,sharedAddress_u32));

//initial begin
//Input_state = 0;
//rst = 1;#20;
//assert(DUT.shared_data.u32[0] == 0) else $error("rst failed");
//rst = 0;
//Input_state.system.active_thread = 1;
//Input_state.thread.opcodes[$bits(pipeline_operation)*0:$bits(pipeline_operation)*1-1] = instructionSetup;
//Input_state.thread[0] = 1;
//#10;
//Input_state.thread.opcodes[$bits(pipeline_operation)*0:$bits(pipeline_operation)*1-1] = instruction1;#10;
//assert(DUT.shared_data.u32[0] == 1) else $error("first go failed");
//#10;
//assert(DUT.shared_data.u32[0] == 2) else $error("second go failed");
//#10;
//assert(DUT.shared_data.u32[0] == 4) else $error("third go failed");
//#10;

//end;

//Dispatch DUT(
//	.inState(Input_state),
//	.outState(Output_state),
//	.internalInState(internalDispatchA),
//	.internalOutState(internalDispatchB),
//	.clk(clk),
//	.rst(rst)
//	);


//PipelineStage DispatchInternal(
//	.inState(internalDispatchA),
//	.outState(internalDispatchB),
//	.clk(clk),.rst(rst)
//);




//always begin
//	clk <= 0; #5;
//	clk <= 1; #5;
//end;

//endmodule;
