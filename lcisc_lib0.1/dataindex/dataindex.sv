import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package DataIndex;
import Operation_pkg::*;

parameter address_u64 = $clog2(EV_types::EV_Length_u64);
typedef struct packed{
	ia_u32_t  index;
	address_u32_t offset;
	logic[address_u64-1:0] row;
	address_u32_t row_length;
} dataIndex_a;


function dataIndex_a dataIndex_o(
input ia_u32_t  my_index, input address_u32_t offset,
input logic[address_u64-1:0] row, input integer row_length);
	dataIndex_o.index = my_index;
    dataIndex_o.offset = offset;
    dataIndex_o.row = row;
	dataIndex_o.row_length = row_length;

endfunction;

function EV_types::exe_env_u dataIndex_f(input EV_types::exe_env_u state, input dataIndex_a arguments);
integer index;

dataIndex_f = state;
index = ia_u32_value(arguments.index,state);
dataIndex_f.u32[arguments.offset] = index % arguments.row_length;
dataIndex_f.u64[arguments.row] = index / arguments.row_length;

endfunction;


endpackage;