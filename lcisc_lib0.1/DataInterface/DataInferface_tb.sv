`timescale 1ns/1ns
import DataInterface_pkg::*;
import EV_types::*;



module DataInterface_tb;


logic clk;
logic rst;
logic halt;

read_request_t read1;
read_request_t read2;
write_request_t write;

read_return_t read_back;


data_register_union_t datarow;


DataInterface DUT(
.rst(rst),
.clk(clk),
.halt(halt),
.read1(read1),
.read2(read2),
.write(write),
.read_back(read_back)
);

initial begin

rst = 1;
read1 = 0;
read2 = 0;
write = 0;
datarow = 0;
halt = 0;
#10;
rst = 0;

//put data in the fisrt rows of data
for(int i=0;i<10;i++) begin
    write.valid=1;
    write.address = i;
    datarow = 0;
    datarow.u32[i] = i; 
    write.data = datarow;#10;
end;
/* memory looks like
1,0,0,0
0,2,0,0
0,0,3,0
0,0,0,4
*/
//check the memory

for(int i=0;i<10;i++) begin
    assert(DUT.memory[i].u32[i] == i) else $error("Data interface failed to load data");
end;
write=0;


//make a number of read requests
for(int i = 0; i<10;i=i+3) begin
	read1.valid = 1;
	read1.request_id=7;
	read1.receive_id=7;
	read1.read_address = i;#10;
	read1.valid <= #1 0;
	#((DataInterface_pkg::delayfunction(0))*10);

	assert(read_back.valid == 1) else $error("Data interface solo read failed");
	assert(read_back.request_id == 7) else $error("Data interface solo read request id failed");
	assert(read_back.receive_id == 7) else $error("Data interface solo read recive id failed");
	assert(read_back.read_address == i) else $error("Data interface solo read address failed");
	assert(read_back.data.u32[i]==i) else $error("Data interface solo read data failed");
end;

//halt and fill the request list with a number of request
halt = 1;
for(int i = 0;i<10;i++) begin

read1.valid = 1;
read1.request_id = 7;
read1.receive_id = 8;
read1.read_address = i;//will read forward

read2.valid = 1;
read2.request_id = 9;
read2.receive_id = 10;
read2.read_address = 9-i;//will read backwards
#10;

end;
read2.valid = 0;
read1.valid = 0;
halt = 0;
#10;


for(int i =0;i<10;i++) begin

	if(i==0) begin
	   #((DataInterface_pkg::delayfunction(0))*10);//first time it will be a longer wait
	end else begin
	   #((DataInterface_pkg::delayfunction(DUT.request_list[-1])+1)*10);
	end
	//check the first read
   	assert(read_back.valid == 1) else $error("Data intrface batch read failed");
	assert(read_back.request_id == 7) else $error("Data intrface batch read request id failed");
	assert(read_back.receive_id == 8) else $error("Data intrface batch read recive id failed");
	assert(read_back.read_address == i) else $error("Data intrface batch read address failed");
	assert(read_back.data.u32[i]==i) else $error("Data intrface batch read data failed");
	
	#((DataInterface_pkg::delayfunction(DUT.request_list[-1])+1) *10);
	
	//check the second read
	assert(read_back.valid == 1) else $error("Data intrface batch read failed");
	assert(read_back.request_id == 9) else $error("Data intrface batch read request id failed");
	assert(read_back.receive_id == 10) else $error("Data intrface batch read recive id failed");
	assert(read_back.read_address == 9-i) else $error("Data intrface batch read address failed");
	assert(read_back.data.u32[9-i]==9-i) else $error("Data intrface batch read data failed");
	
	
end;
$display("done checking");
end;

always begin
	clk <= 0; #5;
	clk <= 1; #5;
end;

endmodule
