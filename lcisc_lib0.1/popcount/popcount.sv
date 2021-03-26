import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package PopCount;
import Operation_pkg::*;


typedef struct packed{
	address_u32_t  arr_1;
    address_u32_t length;
}popCount_a;

function popCount_a popCount_o(
input address_u32_t arr_1, 
input address_u32_t length );

popCount_o.arr_1  = arr_1;
popCount_o.length = length; 

endfunction


function integer unsigned popCount(input logic[32-1:0] a);
integer i;
popCount = 0;
for(i=0;i<32;i++)begin
    if( ((a>>(31-i)) & 1) == 1) begin
        popCount = popCount + 1;
    end
end
endfunction

function EV_types::exe_env_u popCount_f(input EV_types::exe_env_u state, input popCount_a arguments);
integer unsigned A;

popCount_f=state;

for(int i=0;i<arguments.length;i++) begin
    A  = popCount(state.u32[arguments.arr_1+i]);
    popCount_f.u32[arguments.arr_1 + i] = A;
end
	
endfunction


endpackage