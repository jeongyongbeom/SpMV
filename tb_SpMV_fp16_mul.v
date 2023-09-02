`timescale 1ns / 1ps

module tb_SpMV_fp16_mul();
   
    reg i_clk, i_rstn;
    reg [15:0] vector, value;
    
    wire [15:0] result;
    
    SpMV_fp16_mul uut (.i_clk(i_clk), .i_rstn(i_rstn), .vector(vector), .value(value), .result(result));
    
	initial begin
		i_clk = 1'b0; i_rstn = 1'b0;
		#30 i_rstn = 1'b1;
	end
    
   always begin
       #5 i_clk = ~i_clk;
   end
	
	initial begin
		vector = 16'b0_10001_1100000000;
		value  = 16'b0_10000_1000000000;
		#400
		$finish;
	end

	initial begin
		$dumpfile("tb_SpMV_fp16_mul.vcd");
		$dumpvars(0, tb_SpMV_fp16_mul);
	end


endmodule
