
package Operation_pkg;
import EV_types::*;

typedef enum {
	nothing,
	id,
	address
} system_register_type;


typedef enum{
	AgtB =0,
	AltB=1,
	AeqB=2,
	AneqB=3,
	AgteqB=4,
	AlteqB=5
}compareOperation_t;


/*
imediate/address_u32
stores an integer value either a small imediate value
or an address location


*/
parameter address_u32_bits = $clog2($bits(exe_env_u)/32);
typedef logic [address_u32_bits-1:0] address_u32_t;

typedef struct packed{
logic immediate;
logic [address_u32_bits-1:0] value;
} ia_u32_t;

function integer ia_u32_value(input ia_u32_t ia_u32,input exe_env_u ev);

if(ia_u32.immediate==0) begin
    ia_u32_value = ev.u32[ia_u32.value];
end else begin
    if(ia_u32.value[address_u32_bits-1] == 0) begin // positive integer
    	ia_u32_value = ia_u32.value;
    end else begin//negative
	ia_u32.value = 0 - ia_u32.value;
	ia_u32_value = -ia_u32.value;
    end
end

endfunction;

function ia_u32_t i(input integer number);i.immediate = 1;i.value = number;endfunction;
function ia_u32_t a(input integer number);a.immediate = 0;a.value = number;endfunction;






endpackage;
