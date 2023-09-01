`timescale 1ns / 1ps

module tb_SpMV_fp16_add();
	
	parameter fp16 = 16;
	
	reg i_clk, i_rstn;
	reg [15:0] mul_result, reg_result;
	
	wire [15:0] result;
	

	SpMV_fp16_add #(.fp16(fp16)) uut(.i_clk(i_clk), .i_rstn(i_rstn), .mul_result(mul_result), .reg_result(reg_result), .result(result));
	
	
	initial begin
		i_clk = 1'b0; i_rstn = 1'b0;
		#30 i_rstn = 1'b1;
	end
    
   always begin
       #5 i_clk = ~i_clk;
   end
	
	
	initial begin
		mul_result = 16'b0_10011_0000000000;
		reg_result = 16'b0_10000_0000000000;
		# 74
		mul_result = 16'b0_10101_0000000000;
		reg_result = 16'b0_10011_0000000000;
		
		#400
		$finish;
	end
endmodule

