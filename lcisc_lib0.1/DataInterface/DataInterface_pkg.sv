import EV_types::*;
package DataInterface_pkg;


typedef struct packed{
logic 				valid;
EV_types::thread_id_t 		request_id;
EV_types::thread_id_t 		receive_id;
EV_types::data_address_t 	read_address;
} read_request_t;

typedef struct packed{
logic 				valid;
EV_types::data_register_union_t	data;
EV_types::data_address_t	address;
} write_request_t;


typedef struct packed{
logic 				valid;
EV_types::data_register_union_t	data;
EV_types::thread_id_t 		request_id;
EV_types::thread_id_t 		receive_id;
EV_types::data_address_t 	read_address;
} read_return_t;


function integer delayfunction(integer unsigned queue_size);
case(queue_size)//set delay for next item based on size of queue 
   0:delayfunction = 4;
   1:delayfunction = 3;
   2:delayfunction = 2;
   3:delayfunction = 1;
   4:delayfunction = 0;
   default: delayfunction = 0;
   endcase
endfunction


endpackage;