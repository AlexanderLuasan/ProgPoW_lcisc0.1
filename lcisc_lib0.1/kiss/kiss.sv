
import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package Kiss;
import Operation_pkg::*;


//parameter address32 = $clog2(EV_types::EV_Length_word);
parameter u64_addressSize =  $clog2(EV_types::EV_Length_u64);
typedef struct packed{
    address_u32_t kiss_data;
	address_u32_t value_vector;
	integer length; 
} kiss_a;




function kiss_a kiss_o(
input address_u32_t kiss_data, input address_u32_t value_vector, input address_u32_t length = 1);

	kiss_o.value_vector = value_vector;
	kiss_o.kiss_data = kiss_data;
	kiss_o.length = length;

endfunction;

function EV_types::exe_env_u kiss_f(input EV_types::exe_env_u state, input kiss_a arguments); 
integer unsigned z,w,jsr,jcong;
integer unsigned MWC;
integer unsigned A;
integer i;
kiss_f=state;

//inialize
z = state.u32[arguments.kiss_data+0];
w = state.u32[arguments.kiss_data+1];
jsr = state.u32[arguments.kiss_data+2];
jcong = state.u32[arguments.kiss_data+3];


for(int i=0;i<arguments.length;i++) begin
    
    z = 36969 * (z & 65535) + (z>>16);
    w = 18000 * (w & 65535) + (w>>16);
    MWC = (z << 16) + w;
    jsr = jsr ^ (jsr << 17);
    jsr = jsr ^ (jsr >> 13);
    jsr = jsr ^ (jsr << 5);
    jcong = 69069 * jcong + 1234567;
    A = (MWC ^ jcong) + jsr;
    kiss_f.u32[arguments.value_vector+i] = A;

end

//save back

kiss_f.u32[arguments.kiss_data+0] = z;
kiss_f.u32[arguments.kiss_data+1] = w;
kiss_f.u32[arguments.kiss_data+2] = jsr;
kiss_f.u32[arguments.kiss_data+3] = jcong;



endfunction;


endpackage;