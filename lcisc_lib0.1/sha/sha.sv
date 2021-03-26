import EV_types::*;
import SimpleConditional::*;
import EV_enums::*;
package Sha;
import Operation_pkg::*;


typedef struct packed{
	ia_u32_t sha_length;
    logic[1:0] sha_version;
} sha_a;


function sha_a sha_o(
    integer sha_length = i(0),
    logic[1:0] sha_version = 0
);
	sha_o.sha_length = sha_length;
    sha_o.sha_version = sha_version;

endfunction;

typedef logic[64-1:0] u64_t;
typedef logic[8-1:0] u8_t;
typedef union packed{
      u64_t [25-1:0] u64;
      u8_t [25*8-1:0] u8;
} hash_type;


u64_t keccakf_rndc [24] = '{
        'h0000000000000001, 'h0000000000008082, 'h800000000000808a,
        'h8000000080008000, 'h000000000000808b, 'h0000000080000001,
        'h8000000080008081, 'h8000000000008009, 'h000000000000008a,
        'h0000000000000088, 'h0000000080008009, 'h000000008000000a,
        'h000000008000808b, 'h800000000000008b, 'h8000000000008089,
        'h8000000000008003, 'h8000000000008002, 'h8000000000000080,
        'h000000000000800a, 'h800000008000000a, 'h8000000080008081,
        'h8000000000008080, 'h0000000080000001, 'h8000000080008008
    };
int keccakf_rotc[24] = '{
        1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14,
        27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44
    };
int keccakf_piln [24] = '{
        10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4,
        15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1
    };

function u64_t ROTL64(u64_t a,u64_t r);
ROTL64 = (((a) << (r)) | ((a) >> (64 - (r))));
endfunction

function u64_t [25-1:0] keccak_f(u64_t [25-1:0] st, u64_t RC);
    int i, j, r;
    u64_t t, bc[5];

    //theta
    for (i = 0; i < 5; i++)
        bc[i] = st[i] ^ st[i + 5] ^ st[i + 10] ^ st[i + 15] ^ st[i + 20];
        
    for (i = 0; i < 5; i++) begin
        t = ROTL64(bc[(i + 1) % 5], 1);
        t = bc[(i + 4) % 5] ^ ROTL64(bc[(i + 1) % 5], 1);
        for (j = 0; j < 25; j += 5) begin
            st[j + i] ^= t;
        end
    end
    
    //rho pi
    t = st[1];
    for (i = 0; i < 24; i++) begin
        j = keccakf_piln[i];
        bc[0] = st[j];
        st[j] = ROTL64(t, keccakf_rotc[i]);
        t = bc[0];
    end

    //chi
    for (j = 0; j < 25; j += 5) begin
        for (i = 0; i < 5; i++) begin
            bc[i] = st[j + i];
        end
        for (i = 0; i < 5; i++) begin
            st[j + i] ^= (~bc[(i + 1) % 5]) & bc[(i + 2) % 5];
        end
    end
    
    //iota
    st[0] ^= RC;
    keccak_f = st;
endfunction;

function EV_types::exe_env_s sha_f(input EV_types::exe_env_s state, input sha_a arguments);
hash_type st;
integer length;
sha_f=state;
st = 0;
length = arguments.sha_length;
//copy the data into the state
for(integer i = 0; i<EV_types::dataLength_u64; i++) begin
    if(i*8<length)
        st.u64[i] = state.data.u64[i];
end
//based on the length put in the 
st.u8[length] = st.u8[length] ^ 1;

if(arguments.sha_version == 0) begin
    st.u8[135] = st.u8[135] ^ 'h80;
end else begin
    st.u8[71] = st.u8[71] ^ 'h80;
end

for(int i=0;i<24;i++) begin
    st.u64 = keccak_f(st.u64,keccakf_rndc[i]);


if(arguments.sha_version == 0) begin

    for(int i =0;i<256/64;i++) begin
        sha_f.data.u64[i] = st.u64[i];
    end

end else begin
    for(int i =0;i<512/64;i++) begin
        sha_f.data.u64[i] = st.u64[i];
    end
end



end

    

endfunction;


endpackage;
