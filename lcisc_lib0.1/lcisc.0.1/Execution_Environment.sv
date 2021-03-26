import UserValues::*;

//declare execution enviroment sizes
//size -> number of bits
//lengh -> number of words/segments
//count -> length

package EV_types;

parameter CQ=1.0;
//programable datasizes
parameter word_size = 32; //size of word in bits
parameter dword_size = 64; //size of word in bits
parameter sword_size = 16;  //size of word in bits




//length of different parts
parameter sharedLength	= UserValues::sharedLength;	//count of native words in global
parameter dataLength	=UserValues::dataLength;	//count of native words in data
parameter threadLength	=UserValues::threadLength;	//count of native words in thread including flags space
parameter flagCount	=UserValues::flagCount;	//number of general flags


parameter u32_size = 32; 
parameter u64_size= 64; 
parameter u16_size= 16;
parameter u8_size= 8; 

parameter sharedWordSize= 	u32_size;	//size of shared segments
parameter dataWordSize =	u32_size;	//size of data segments
parameter threadWordSize=	u32_size;	//size of thread segments
parameter executionWordSize = 	u32_size;	//size of execution segments

parameter ContextThreadLength = UserValues::ContextThreadLength; // count of threads in context
typedef logic[$clog2(ContextThreadLength)-1:0] thread_id_t;
parameter DataStorageLength = UserValues::DataStorageLength; //number of data registers in the data;
typedef logic[$clog2(DataStorageLength)-1:0] data_address_t;


//declare the basic_types 
//typedef logic[word_size-1:0] 	word_t;
//typedef logic[dword_size-1:0] 	dword_t;
//typedef logic[sword_size-1:0] 	sword_t; 

typedef logic[u32_size-1:0]	u32_t;
typedef logic[u64_size-1:0]	u64_t;
//typedef logic[u16_size-1:0]	u16_t;
//typedef logic[u8_size-1:0]	u8_t;






//total length of each register
parameter shared_register_size = sharedLength*sharedWordSize;
parameter data_register_size = dataWordSize*dataLength;
parameter thread_register_size = threadWordSize * threadLength;


//find total size of execution enviromen
parameter EV_Size = shared_register_size+data_register_size+thread_register_size;//`globalLength*`globalWordSize + `dataLength*`dataWordSize + threadLength*threadWordSize

//find the lengths of the EV for diferent sizes
//parameter EV_Length_word = EV_Size / word_size;
//parameter EV_Length_dword = EV_Size / dword_size;
//parameter EV_Length_sword = EV_Size / sword_size;
//parameter EV_Length_native = EV_Size / executionWordSize;
parameter EV_Length_u32 = EV_Size / u32_size;
parameter EV_Length_u64 = EV_Size / u64_size;
//parameter EV_Length_u16 = EV_Size / u16_size;
//parameter EV_Length_u8 = EV_Size / u8_size;

//see if any word does not fully fill the EV
parameter EV_Remainder_u32  =EV_Size - EV_Length_u32  * u32_size;
parameter EV_Remainder_u64 =EV_Size - EV_Length_u64 * u64_size;
//parameter EV_Remainder_u16 =EV_Size - EV_Length_u16 * u16_size;
//parameter EV_Remainder_u8 =EV_Size - EV_Length_u8 * u8_size;

//union of the shared regiester

parameter sharedLength_u32 = shared_register_size/u32_size;
parameter sharedLength_u64 = shared_register_size/u64_size;
typedef union packed{
  logic [shared_register_size-1:0] all;
  //logic [sharedLength-1:0] [sharedWordSize-1:0] native; //default
  //logic [shared_register_size/word_size-1:0] [word_size-1:0] word; //divide into words
  //logic [shared_register_size/dword_size-1:0] [dword_size-1:0] dword; //divide into dwords
  //logic [shared_register_size/sword_size-1:0] [sword_size-1:0] sword; //devide into swords
  logic [shared_register_size/u32_size-1:0] [u32_size-1:0] u32;
  logic [shared_register_size/u64_size-1:0] [u64_size-1:0] u64;
  //logic [shared_register_size/u16_size-1:0] [u16_size-1:0] u16;
  //logic [shared_register_size/u8_size-1:0] [u8_size-1:0] u8;
} shared_register_union_t;
//union of the data register

parameter dataLength_u32 = data_register_size/u32_size;
parameter dataLength_u64 = data_register_size/u64_size;
typedef union packed{
  logic [data_register_size-1:0] all;
  //logic [dataLength-1:0] [dataWordSize-1:0] native; //default
  //logic [data_register_size/word_size-1:0] [word_size-1:0] word; //divide into words
  //logic [data_register_size/dword_size-1:0] [dword_size-1:0] dword; //divide into dwords
  //logic [data_register_size/sword_size-1:0] [sword_size-1:0] sword; //devide into swords
  logic [data_register_size/u32_size-1:0] [u32_size-1:0] u32;
  logic [data_register_size/u64_size-1:0] [u64_size-1:0] u64;
  //logic [data_register_size/u16_size-1:0] [u16_size-1:0] u16;
  //logic [data_register_size/u8_size-1:0] [u8_size-1:0] u8;
} data_register_union_t;

//union of the thread register

parameter threadLength_u32 = thread_register_size/u32_size;
parameter threadLength_u64 = thread_register_size/u64_size;
typedef union packed{
  logic [thread_register_size-1:0] all;
  //logic [threadLength-1:0] [0:threadWordSize-1] native; //default //local data access
  //logic [thread_register_size/word_size-1:0] [word_size-1:0] word; //divide into words
  //logic [thread_register_size/dword_size-1:0] [dword_size-1:0] dword; //divide into dwords
  //logic [thread_register_size/sword_size-1:0] [sword_size-1:0] sword; //devide into swords
  logic [thread_register_size/u32_size-1:0] [u32_size-1:0] u32;
  logic [thread_register_size/u64_size-1:0] [u64_size-1:0] u64;
  //logic [thread_register_size/u16_size-1:0] [u16_size-1:0] u16;
  //logic [thread_register_size/u8_size-1:0] [u8_size-1:0] u8;
  //opcode access
  //logic [0:thread_register_size-1]  opcodes;
  logic [0:thread_register_size-1]  flags;
} thread_register_union_t;

typedef struct packed {
  logic [UserValues::program_instruction_size-1:0] opcodes;
} program_instucions_t;


typedef struct packed {
	logic active_thread;
	thread_id_t id;
	data_address_t data_address;
} system_register_t;

typedef struct packed {
	thread_register_union_t thread;
	shared_register_union_t shared;
	data_register_union_t data;
} execution_evn_struct;

parameter dataAddress_u32 = 0;
parameter sharedAddress_u32 = dataLength_u32;
parameter threadAddress_u32 = sharedAddress_u32+sharedLength_u32;

parameter dataAddress_u64 = 0;
parameter sharedAddress_u64 = dataLength_u64;
parameter threadAddress_u64 = sharedAddress_u64+sharedLength_u64;


typedef union packed {
 logic [EV_Size-1:0] all;
 //logic [EV_Length_native-1:0] [executionWordSize-1:0] native;
 //logic [EV_Length_word-1:0] [word_size-1:0] word; //divide into words
 //logic [EV_Length_dword-1:0] [dword_size-1:0] dword; //divide into dwords
 //logic [EV_Length_sword-1:0] [sword_size-1:0] sword; //devide into swords
 logic [EV_Length_u32-1:0] [u32_size-1:0] u32;
 logic [EV_Length_u64-1:0] [u64_size-1:0] u64;
 //logic [EV_Length_u16-1:0] [u16_size-1:0] u16;
 //logic [EV_Length_u8-1:0] [u8_size-1:0] u8;
 execution_evn_struct execution_ev;
} execution_evn_union;

typedef execution_evn_struct exe_env_s;
typedef execution_evn_union exe_env_u;



typedef struct packed{
	system_register_t system;
	thread_register_union_t thread;
  program_instucions_t instuctions;
	shared_register_union_t shared;
	data_register_union_t data;
} pipeline_pass_structure_t;

typedef pipeline_pass_structure_t pipeline_pass_structure;

typedef struct packed{
  thread_register_union_t thread;
  program_instucions_t instuctions;
} thread_program_stuct_t;



function execution_evn_struct get_execution_environment(pipeline_pass_structure_t pipeline_pass_structure);
  get_execution_environment.thread = pipeline_pass_structure.thread;
  get_execution_environment.data = pipeline_pass_structure.data;
  get_execution_environment.shared = pipeline_pass_structure.shared;
endfunction

function pipeline_pass_structure_t set_execution_environment(pipeline_pass_structure_t pipeline_pass_structure, execution_evn_struct enviroment);
  set_execution_environment = pipeline_pass_structure;
  set_execution_environment.thread = enviroment.thread;
  set_execution_environment.data = enviroment.data;
  set_execution_environment.shared = enviroment.shared;
endfunction


function thread_program_stuct_t get_thread_program_struct(pipeline_pass_structure_t pipeline_pass_structure);
  get_thread_program_struct.thread = pipeline_pass_structure.thread;
  get_thread_program_struct.instuctions = pipeline_pass_structure.instuctions;
endfunction

function pipeline_pass_structure_t set_thread_program_struct(pipeline_pass_structure_t pipeline_pass_structure, thread_program_stuct_t thread_program_stuct);
  set_thread_program_struct = pipeline_pass_structure;
  set_thread_program_struct.thread = thread_program_stuct.thread;
  set_thread_program_struct.instuctions = thread_program_stuct.instuctions;
endfunction

//typedef logic[$clog2(EV_types::EV_Length_word)-1:0] addressWord_t;

endpackage
