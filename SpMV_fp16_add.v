`timescale 1ns / 1ps

module SpMV_fp16_add(i_clk, i_rstn, mul_result, reg_result, result);
    
    input i_clk, i_rstn;
    input [15:0] mul_result, reg_result;
    
    output reg [15:0] result;
    
    reg [255:0] matrix [0:15];
    reg [15:0] sum [0:15];
    
    reg [11:0] b_ALU_result; 
	 
	 integer k;
	 
	 always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) result <= 16'b0;
		else begin
			
			// To Address Denormalized Number
			if((mul_result[14:10] == 5'b0) && (reg_result[14:10] == 5'b0)) result = 16'b0;
			else if((mul_result[14:10] == 5'bx)  |  (reg_result[14:10] == 5'bx)) result = 16'bx;
			else if((mul_result[14:10] == 5'b0) && !(reg_result[14:10] == 5'b0)) result = reg_result;
			else if((reg_result[14:10] == 5'b0) && !(mul_result[14:10] == 5'b0)) result = mul_result;
			
			// To Address Normalized Number
			else begin
			
				// Exponent_A > Exponent_B
				if (mul_result[14:10] > reg_result[14:10]) begin
					if(mul_result[15] != reg_result[15])	b_ALU_result = {2'b01,mul_result[9:0]} - ({2'b01,reg_result[9:0]} >> (mul_result[14:10] - reg_result[14:10]));
					else 												b_ALU_result = {2'b01,mul_result[9:0]} + ({2'b01,reg_result[9:0]} >> (mul_result[14:10] - reg_result[14:10]));
					result[14:10] = mul_result[14:10];
					
				// Exponent_A < Exponent_B
				end else if(mul_result[14:10] < reg_result[14:10]) begin
					if(mul_result[15] != reg_result[15])	b_ALU_result = {2'b01,reg_result[9:0]} - ({2'b01,mul_result[9:0]} >> (reg_result[14:10] - mul_result[14:10]));
					else												b_ALU_result = {2'b01,reg_result[9:0]} + ({2'b01,mul_result[9:0]} >> (reg_result[14:10] - mul_result[14:10]));
					result[14:10] = reg_result[14:10];
					
				// Exponent_A = Exponent_B
				end else begin
					if(mul_result[15] == reg_result[15])	b_ALU_result = {2'b01,mul_result[9:0]} + ({2'b01,reg_result[9:0]} >> (mul_result[14:10] - reg_result[14:10]));
					else begin
						if(mul_result[9:0] >= reg_result[9:0])	b_ALU_result = {2'b01,mul_result[9:0]} - ({2'b01,reg_result[9:0]} >> (mul_result[14:10] - reg_result[14:10]));
						else												b_ALU_result = {2'b01,reg_result[9:0]} - ({2'b01,mul_result[9:0]} >> (reg_result[14:10] - mul_result[14:10]));
					end
					result[14:10] = reg_result[14:10];
				end
				
				// Normalization
            if(b_ALU_result[11] == 1'b1) begin
					if(mul_result[14:10] >= reg_result[14:10]) result[14:10] = mul_result[14:10] + 1'b1;
               else 			 										 result[14:10] = reg_result[14:10] + 1'b1;
               result[9:0] = b_ALU_result[10:1];
					
				end else result[9:0] = b_ALU_result[9:0];
				
				// Sign
				if(mul_result[15] == reg_result[15]) result[15] = mul_result[15];
				else begin
					if(mul_result[14:10] > reg_result[14:10]) 		result[15] = mul_result[15];
					else if(mul_result[14:10] < reg_result[14:10])	result[15] = reg_result[15];
					else begin
						if(mul_result[9:0] >= reg_result[9:0]) 		result[15] = mul_result[15];
						else														result[15] = reg_result[15];
					end
				end
			end
		end
	end
endmodule
