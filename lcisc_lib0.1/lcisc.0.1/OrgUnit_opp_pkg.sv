

import ContextCache_pkg::*;
import SimpleConditional::*;
import DataInterface_pkg::*;
import Operation_pkg::*;

package orgunit;
import EV_types::*;
parameter u64_addressSize =  $clog2(EV_types::EV_Length_u64);
typedef logic[u64_addressSize-1:0] u64_type;

typedef Operation_pkg::system_register_type system_register_type;

typedef struct packed{
	u64_type location;
	system_register_type request_value; 

}orgunit_a;

function orgunit_a orgunit_o(
	u64_type location = 0,
	system_register_type request_value = Operation_pkg::nothing
);

orgunit_o.location = location;
orgunit_o.request_value=request_value;
endfunction;

function pipeline_pass_structure orgunit_f(pipeline_pass_structure main, orgunit_a args );
exe_env_u exe_env;
exe_env = get_execution_environment(main);

if(args.request_value == Operation_pkg::id)
	exe_env.u64[args.location] = main.system.id;
if(args.request_value == Operation_pkg::address)
	exe_env.u64[args.location] = main.system.data_address;

orgunit_f = set_execution_environment(main,exe_env);

endfunction;

endpackage;


