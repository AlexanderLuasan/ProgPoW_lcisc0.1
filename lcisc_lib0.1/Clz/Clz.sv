import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package Clz;
import Operation_pkg::*;


typedef struct packed{
	address_u32_t  arr_1;
    address_u32_t length;
}clz_a;

function clz_a clz_o(
input address_u32_t arr_1, 
input address_u32_t length );

clz_o.arr_1  = arr_1;
clz_o.length = length; 

endfunction


function integer unsigned clz(input logic[32-1:0] a);
integer i;
logic found;
found = 0;
for(i=0;i<32;i++)begin
    if(found == 0) begin
        if( (a>>(31-i)) > 0) begin
            clz = i;
            found =1;
        end
    end

end
endfunction

function EV_types::exe_env_u clz_f(input EV_types::exe_env_u state, input clz_a arguments);
integer unsigned A;

clz_f=state;

for(int i=0;i<arguments.length;i++) begin
    A  = clz(state.u32[arguments.arr_1+i]);
    clz_f.u32[arguments.arr_1 + i] = A;
end
	
endfunction


endpackage