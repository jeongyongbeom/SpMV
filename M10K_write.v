`timescale 1ns / 1ns
module M10K_write#(
	parameter DATA_LEN = 32,
	parameter M = 8,
	parameter N = 8,
	parameter ADDRESS_SIZE = 4,
	parameter OFFSET = 0,
	
	parameter WRITE0 = 4'd0,
	parameter WRITE1 = 4'd1,
	parameter WRITE2 = 4'd2,
	parameter WRITE3 = 4'd3,
	parameter WRITE4 = 4'd4,
	parameter WRITE5 = 4'd5,
	parameter WRITE6 = 4'd6,
	parameter WRITE7 = 4'd7,
    parameter DONE   = 4'd8,
	parameter IDLE   = 4'd15 
)(
	input 					 		 		 i_clk,
	input 					 		  	    i_rstn,
	input							  			 i_write_start,
	input       [DATA_LEN*M*N-1:0]	  i_in_mat,
	
	output	reg [ADDRESS_SIZE-1:0]	  o_write_addr,
	output  reg [DATA_LEN*N-1:0]	  	 o_write_data,
	output  reg						  o_write_start,
	output [3:0]					  o_state,
	output 							  o_done
);
		  
	reg  [3:0] state;     
	reg  [3:0] next_state;
	
	wire [DATA_LEN*N-1:0] in_vec [0:M-1];
	
	assign o_state = state;
	assign o_done = (state == DONE);
	
	genvar i;
	generate
	for(i=0; i<M; i=i+1) begin: INPUT_PARSE
		assign in_vec[i] = i_in_mat[(DATA_LEN*N)*((i)) +: (DATA_LEN*N)];
	end
	endgenerate
	
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end	
	end
		
	always @(*) begin
		case(state) 
			IDLE:  begin
						if(i_write_start)
							next_state = WRITE0;
						else 	     	
							next_state = IDLE;
					end
			WRITE0: begin
						next_state = WRITE1;
					end
			WRITE1: begin
						next_state = WRITE2;
					end
			WRITE2: begin
						next_state = WRITE3;
					end
			WRITE3: begin
						next_state = WRITE4;
					end
			WRITE4: begin
						next_state = WRITE5;
					end
			WRITE5: begin
						next_state = WRITE6;
					end
			WRITE6: begin
						next_state = WRITE7;
					end
			WRITE7: begin
						next_state = DONE;
					end
			DONE: begin
						next_state = IDLE;
					end
			default:begin
						next_state = IDLE;
					end
		endcase
	end
	
	always @(*) begin
		case(state) 
			WRITE0: begin
						o_write_data      = in_vec[0];
						o_write_addr      = WRITE0 + OFFSET;
						o_write_start     = 1'b1;
					end
			WRITE1: begin
						o_write_data      = in_vec[1];
						o_write_addr      = WRITE1 + OFFSET;
						o_write_start     = 1'b1; 
					end
			WRITE2: begin
						o_write_data      = in_vec[2];
						o_write_addr      = WRITE2 + OFFSET;
						o_write_start     = 1'b1;
					end
			WRITE3: begin
						o_write_data      = in_vec[3];
						o_write_addr      = WRITE3 + OFFSET;
						o_write_start     = 1'b1;
					end
			WRITE4: begin
						o_write_data      = in_vec[4];
						o_write_addr      = WRITE4 + OFFSET;
						o_write_start     = 1'b1;
					end
			WRITE5: begin
						o_write_data      = in_vec[5];
						o_write_addr      = WRITE5 + OFFSET;
						o_write_start     = 1'b1;
					end
			WRITE6: begin
						o_write_data      = in_vec[6];
						o_write_addr      = WRITE6 + OFFSET;
						o_write_start     = 1'b1; 
					end
			WRITE7: begin
						o_write_data      = in_vec[7];
						o_write_addr      = WRITE7+ OFFSET;
						o_write_start     = 1'b1;
					end
			default:begin
						o_write_data      = {(DATA_LEN*N)*{1'b0}};
						o_write_addr      = {(ADDRESS_SIZE)*{1'b0}};
						o_write_start     = 1'b0;
					end
		endcase
	end
	
endmodule
