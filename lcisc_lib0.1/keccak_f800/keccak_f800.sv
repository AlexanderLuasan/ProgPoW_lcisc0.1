
import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package keccak_f800;
import Operation_pkg::*;

//parameter address32 = $clog2(EV_types::EV_Length_word);
parameter u64_addressSize =  $clog2(EV_types::EV_Length_u64);
typedef struct packed{
	address_u32_t header;
	logic  [u64_addressSize-1:0]  	nonce;
	address_u32_t  digest; 
} keccak_f800_a;


function integer unsigned ROTL32(integer unsigned x,integer unsigned n);
    ROTL32 = (((x) << (n%32)) | ((x) >> (32 - (n%32))));
endfunction

function keccak_f800_a keccak_f800_o(
input address_u32_t header, input logic[u64_addressSize-1:0] nonce,input address_u32_t digest);

	keccak_f800_o.header = header;
	keccak_f800_o.nonce = nonce;
	keccak_f800_o.digest = digest;

endfunction;

integer unsigned keccakf_rotc[24] = '{1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14,
    27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44};
integer unsigned keccakf_piln[24] = '{10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4,
    15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1};
integer unsigned keccakf_rndc[22] = '{'h00000001, 'h00008082, 'h0000808a, 'h80008000, 'h0000808b, 'h80000001,
    'h80008081, 'h00008009, 'h0000008a, 'h00000088, 'h80008009, 'h8000000a,
    'h8000808b, 'h0000008b, 'h00008089, 'h00008003, 'h00008002, 'h00000080,
    'h0000800a, 'h8000000a, 'h80008081, 'h00008080};
    
typedef logic[25-1:0][32-1:0] keccak_state;

function keccak_state keccak_f800_round(keccak_state st, integer round);
    int unsigned j,i;
    integer unsigned t, bc[5];

    // Theta
    for (i = 0; i < 5; i++) begin
        bc[i] = st[i] ^ st[i + 5] ^ st[i + 10] ^ st[i + 15] ^ st[i + 20];
    end
    
    for (i = 0; i < 5; i++) begin
        t = bc[(i + 4) % 5] ^ ROTL32(bc[(i + 1) % 5], 1);
        for (j = 0; j < 25; j += 5) begin
            st[j + i] ^= t;
        end
    end

    // Rho Pi
    t = st[1];
    for (i = 0; i < 24; i++) begin
        j = keccakf_piln[i];
        bc[0] = st[j];
        st[j] = ROTL32(t, keccakf_rotc[i]);
        t = bc[0];
    end

    //  Chi
    for (j = 0; j < 25; j += 5) begin
        for (i = 0; i < 5; i++)
            bc[i] = st[j + i];
        for (i = 0; i < 5; i++)
            st[j + i] ^= (~bc[(i + 1) % 5]) & bc[(i + 2) % 5];
    end

    //  Iota
    st[0] ^= keccakf_rndc[round];
    keccak_f800_round = st;

endfunction


function EV_types::exe_env_u keccak_f800_f(input EV_types::exe_env_u state, input keccak_f800_a arguments); 
longint unsigned seed;
keccak_state st;
keccak_f800_f=state;

    seed = state.u64[arguments.nonce];
    // Initialization
    for (int i = 0; i < 25; i++)
        st[i] = 0;

    // Absorb phase for fixed 18 words of input
    for (int i = 0; i < 8; i++)
        st[i] = state.u32[arguments.header + i];
    
    st[8] = seed;
    st[9] = seed >> 32;
    for (int i = 0; i < 8; i++)
        st[10+i] = state.u32[arguments.digest + i];

    // keccak_f800 call for the single absorb pass
    for (int r = 0; r < 22; r++)
        st = keccak_f800_round(st, r);

    // Squeeze phase for fixed 8 words of output 
    // put them back into the header location
    for (int i = 0; i < 8; i++)
        keccak_f800_f.u32[arguments.header + i] = st[i];



endfunction;


endpackage;