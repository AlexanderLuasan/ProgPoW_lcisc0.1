import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package bswap;
import Operation_pkg::*;


typedef struct packed{
	address_u32_t  arr_1;
    address_u32_t length;
}bswap_a;

function bswap_a bswap_o(
input address_u32_t arr_1, 
input address_u32_t length );

bswap_o.arr_1  = arr_1;
bswap_o.length = length; 

endfunction


function integer unsigned bswap(input integer unsigned a);
integer unsigned r;
r = (a<<16) | (a>>16);
bswap = ((r & 'h00ff00ff) << 8) | ((r >> 8) & 'h00ff00ff);

endfunction

function EV_types::exe_env_u bswap_f(input EV_types::exe_env_u state, input bswap_a arguments);
integer unsigned A;

bswap_f=state;

for(int i=0;i<arguments.length;i++) begin
    A  = bswap(state.u32[arguments.arr_1+i]);
    bswap_f.u32[arguments.arr_1 + i] = A;
end
	
endfunction


endpackage