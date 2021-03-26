
 
import EV_types::*;

package Rotate;
import Operation_pkg::*;
import SimpleConditional::*;

typedef struct packed{
	ia_u32_t operand1;
	ia_u32_t operand2;
	address_u32_t destination;
	logic left ;
} rotate_a;

function rotate_a rotate_o(
input ia_u32_t operand1, input ia_u32_t operand2,
input address_u32_t dest, input logic left = 1);
	rotate_o.operand1 = operand1;
	rotate_o.operand2 = operand2;
	rotate_o.destination = dest;
	rotate_o.left = left;

endfunction;

function integer unsigned ROTL32(integer unsigned x,integer unsigned n);
    ROTL32 = ( ((x) << (n%32)) | ((x) >> (32 - (n%32))) );
endfunction

function integer unsigned ROTR32(integer unsigned x,integer unsigned n);
    ROTR32 = ( ((x) >> (n%32)) | ((x) << (32 - (n%32))) );
endfunction



function automatic EV_types::exe_env_u rotate_f(input EV_types::exe_env_u state, input rotate_a arguments);
integer unsigned A;
integer unsigned B;
rotate_f.all=state.all;

A = ia_u32_value(arguments.operand1,state);
B = ia_u32_value(arguments.operand2,state);

if(arguments.left == 1) begin
    rotate_f.u32[arguments.destination] = ROTL32(A,B);
end else begin
    rotate_f.u32[arguments.destination] = ROTR32(A,B);
end


endfunction;

endpackage;