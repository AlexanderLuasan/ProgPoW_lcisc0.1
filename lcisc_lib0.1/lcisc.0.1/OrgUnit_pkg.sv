
import orgunit::*;

package OrgUnit_pkg;

typedef enum{
	Org,
	no_opp
} orgunit_operation_t;

typedef orgunit::orgunit_a orgunit_operation;

function orgunit_operation wrap(orgunit_operation_t opcode, orgunit::orgunit_a args);

if(opcode == no_opp)
	wrap = orgunit::orgunit_o();
else
	wrap = args;

endfunction;

parameter orgunitSize = $bits(orgunit_operation);

endpackage;