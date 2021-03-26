import SimpleConditional::*;
import EV_enums::*;
package fnv1a;
import Operation_pkg::*;



parameter u64_addressSize =  $clog2(EV_types::EV_Length_u64);
typedef struct packed{
    address_u32_t value;
    ia_u32_t modifier;
} fnv1a_a;




function fnv1a_a fnv1a_o(address_u32_t value, ia_u32_t modifier);

	fnv1a_o.value = value;
	fnv1a_o.modifier = modifier;


endfunction;
integer unsigned FNV_PRIME = 'h1000193;
function EV_types::exe_env_u fnv1a_f(input EV_types::exe_env_u state, input fnv1a_a arguments); 
integer unsigned A;
integer unsigned B;
integer unsigned C;
fnv1a_f=state;

A = state.u32[arguments.value];
B = ia_u32_value(arguments.modifier,state);
C = (A^B) * FNV_PRIME;
fnv1a_f.u32[arguments.value] = C;

$display("fnva1 %d %d = %d",A,B,(A^B) * FNV_PRIME);

endfunction;


endpackage;
