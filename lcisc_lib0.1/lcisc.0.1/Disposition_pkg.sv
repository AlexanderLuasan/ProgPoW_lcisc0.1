
import disposition::*;

package Disposition_pkg;



typedef enum{
	Disp,
	no_opp
} disposition_operation_t;

typedef disposition::disposition_a disposition_operation;

function disposition_operation wrap(disposition_operation_t opcode, disposition::disposition_a args);

if(opcode == no_opp)
	wrap = disposition::disposition_o();
else
	wrap = args;

endfunction;

parameter dispositionSize = $bits(disposition_operation);

endpackage;
