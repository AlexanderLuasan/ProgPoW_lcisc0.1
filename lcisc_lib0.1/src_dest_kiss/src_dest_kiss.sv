
import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package src_dest_kiss;
import Operation_pkg::*;



typedef struct packed{
    address_u32_t kiss_data;
	address_u32_t src_vector;
    address_u32_t dst_vector;
} src_dest_kiss_a;




function src_dest_kiss_a src_dest_kiss_o(
input address_u32_t kiss_data, input address_u32_t src_vector, input address_u32_t dst_vector);

	src_dest_kiss_o.src_vector = src_vector;
	src_dest_kiss_o.kiss_data = kiss_data;
	src_dest_kiss_o.dst_vector = dst_vector;

endfunction;

typedef logic[32-1:0] u32_t;


function EV_types::exe_env_u src_dest_kiss_f(input EV_types::exe_env_u state, input src_dest_kiss_a arguments); 
integer unsigned z,w,jsr,jcong;
integer unsigned MWC;
integer unsigned j,t;
u32_t[32-1:0] src,dest;
integer i;
src_dest_kiss_f=state;

//inialize
z = state.u32[arguments.kiss_data+0];
w = state.u32[arguments.kiss_data+1];
jsr = state.u32[arguments.kiss_data+2];
jcong = state.u32[arguments.kiss_data+3];



for(i=0;i<32;i++) begin
    src[i] = i;
    dest[i] = i;
end

for(i=31;i>0;i--) begin
    
    z = 36969 * (z & 65535) + (z>>16);
    w = 18000 * (w & 65535) + (w>>16);
    MWC = (z << 16) + w;
    jsr = jsr ^ (jsr << 17);
    jsr = jsr ^ (jsr >> 13);
    jsr = jsr ^ (jsr << 5);
    jcong = 69069 * jcong + 1234567;
    
    j = ((MWC ^ jcong) + jsr)%(i+1);
    t = dest[i];
    dest[i] = dest[j];
    dest[j] = t;


    z = 36969 * (z & 65535) + (z>>16);
    w = 18000 * (w & 65535) + (w>>16);
    MWC = (z << 16) + w;
    jsr = jsr ^ (jsr << 17);
    jsr = jsr ^ (jsr >> 13);
    jsr = jsr ^ (jsr << 5);
    jcong = 69069 * jcong + 1234567;
    
    j = ((MWC ^ jcong) + jsr)%(i+1);
    t = src[i];
    src[i] = src[j];
    src[j] = t;

end

//save back

src_dest_kiss_f.u32[arguments.kiss_data+0] = z;
src_dest_kiss_f.u32[arguments.kiss_data+1] = w;
src_dest_kiss_f.u32[arguments.kiss_data+2] = jsr;
src_dest_kiss_f.u32[arguments.kiss_data+3] = jcong;


for(i = 0;i<32;i++) begin
    src_dest_kiss_f.u32[arguments.src_vector + i] = src[i];
    src_dest_kiss_f.u32[arguments.dst_vector + i] = dest[i];
end


endfunction;


endpackage;