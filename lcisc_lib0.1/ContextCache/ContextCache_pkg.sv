import EV_types::*;
package ContextCache_pkg;



typedef enum{
	none,
	clear,
	copy,
	pass
}exec_enum_t;

typedef enum{
	no_fork,
	fork_me_copy,
	fork_other_copy,
	fork_other_pass
}fork_enum_t;

typedef enum{
	no_thread,
	executing,
	template,
	wait_for_trigger,
	work_queue
}thread_status_t;

typedef struct packed{
logic incoming;
EV_types::thread_id_t incoming_id;
logic delete;
logic sleep;

//exec
exec_enum_t execute_info;
EV_types::thread_id_t execute_id;
//fork data
fork_enum_t forking_info;
logic fork_sleep;
EV_types::thread_id_t forking_id;

} ContextCache_Control;

endpackage;