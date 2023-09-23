`timescale 1ns / 1ps

module SpMV_fp16_mul(i_clk, i_rstn, vector, value, result);

    input i_clk, i_rstn;
    input [15:0] vector, value;

    output reg [15:0] result;
    
    reg [21:0] P;
    
    // Transfer input vector and value to register.
    always @(posedge i_clk or negedge i_rstn) begin
        if(!i_rstn) begin
				result = 16'b0;
        end else begin
				if((vector[14:10] == 5'b0) | (value[14:10] == 5'b0)) 			result = 16'b0;
				else if((vector[14:10] == 5'b1) | (value[14:10] == 5'b1))   result = 16'bx;
				else begin
				
					// For Sign bit
					result[15] = vector[15] ^ value[15];
					
					// For Exponent
					result[14:10] = vector[14:10] + value[14:10] - 15;
					
					// For Mantissa
					P = {1'b1,vector[9:0]} * {1'b1,value[9:0]};
					
					// For Normalize
					if(P[21] == 1'b1) begin
					    result[9:0] = P[20:11];
                        result[14:10] = result[14:10] + 1'b1;
               end else if(P[21] == 1'b0) begin
                   result[9:0] = P[19:10];
               end
				end
			end
		end

endmodule
