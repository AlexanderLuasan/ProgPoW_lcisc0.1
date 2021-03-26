
import EV_types::*;
import ContextCache_pkg::*;
import SimpleConditional::*;
import DataInterface_pkg::*;

package disposition;

parameter u64_addressSize =  $clog2(EV_types::EV_Length_u64);
typedef struct packed{
	//reactive info
	SimpleConditional::singleFlagConditional_a 	delete;
	SimpleConditional::singleFlagConditional_a 	sleep;

	// transfrom info
	SimpleConditional::singleFlagConditional_a	exec_conditional;
	ContextCache_pkg::exec_enum_t	exec_info;
	logic  [u64_addressSize-1:0]  	exec_id;

	//fork info
	SimpleConditional::singleFlagConditional_a	fork_conditional;
	ContextCache_pkg::fork_enum_t	fork_info;
	logic				fork_sleep;
	logic  [u64_addressSize-1:0]  	fork_id;
	
	//disposition information

	SimpleConditional::singleFlagConditional_a 	self_read;
	SimpleConditional::singleFlagConditional_a 	other_read;
	SimpleConditional::singleFlagConditional_a 	write; 
	logic 						write_back;
	logic  [u64_addressSize-1:0]  	self_read_address; //address of the value u64
	logic  [u64_addressSize-1:0]  	read_other_who;
	logic  [u64_addressSize-1:0]  	read_other_where;
	logic  [u64_addressSize-1:0]  	write_address;


}disposition_a;

function disposition_a disposition_o(

input integer delete = -1000 ,
input integer sleep = -1000 ,
input integer exec_conditional = -1000,
input 	ContextCache_pkg::exec_enum_t exec_info = ContextCache_pkg::none,
integer exec_id = 0,
input integer fork_conditional = -1000,
input 	ContextCache_pkg::fork_enum_t fork_info = ContextCache_pkg::no_fork,
input logic fork_sleep = 0,
integer fork_id = 0,
input integer self_read = -1000,
integer self_read_address = 0,
input integer other_read = -1000,
integer read_other_who = 0,
integer read_other_where = 0,
input integer write = -1000,
input integer write_back = 0,
integer write_address = 0

);



disposition_o.delete = SimpleConditional::checkSingleCondition_o(delete);
disposition_o.sleep = SimpleConditional::checkSingleCondition_o(sleep);
disposition_o.exec_conditional  = SimpleConditional::checkSingleCondition_o(exec_conditional);
disposition_o.exec_info = exec_info;
disposition_o.fork_conditional = SimpleConditional::checkSingleCondition_o(fork_conditional);
disposition_o.fork_info = fork_info;
disposition_o.fork_sleep = fork_sleep;
disposition_o.self_read = SimpleConditional::checkSingleCondition_o(self_read);
disposition_o.other_read = SimpleConditional::checkSingleCondition_o(other_read);
disposition_o.write = SimpleConditional::checkSingleCondition_o(write);
disposition_o.write_back = write_back;


disposition_o.exec_id=exec_id;
disposition_o.fork_id=fork_id;
disposition_o.self_read_address=self_read_address;
disposition_o.read_other_who=read_other_who;
disposition_o.read_other_where=read_other_where;
disposition_o.write_address=write_address;



endfunction;

endpackage;


