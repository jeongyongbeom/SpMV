`timescale 1ns / 1ns
module mat_outer#(
	parameter DATA_LEN = 32,
	parameter M = 8,
	parameter N = 8,
	parameter K = 8,
	parameter ROW_SIZE = (DATA_LEN*K),
	parameter MAT_SIZE = (DATA_LEN*K*M)
)(
	input 								  i_clk,
	input								  i_rstn,
	input  signed		[ROW_SIZE-1:0]	  i_vec_at,
	input  signed		[ROW_SIZE-1:0]	  i_vec_b,
	output reg signed 	[MAT_SIZE-1:0]	  o_mat_c
);

reg    signed		[MAT_SIZE-1:0]	  mat_copy_a;
reg    signed		[MAT_SIZE-1:0]	  mat_copy_b;

wire signed [DATA_LEN-1:0] parse_vec_at[0:M-1];
wire signed [DATA_LEN-1:0] parse_vec_b[0:M-1];
wire signed [DATA_LEN-1:0] parse_mat_copy_a[0:M-1][0:K-1];
wire signed [DATA_LEN-1:0] parse_mat_copy_b[0:K-1][0:N-1];
wire signed [DATA_LEN-1:0] parse_mat_outer_c[0:M-1][0:N-1];

genvar i;
generate
	for(i=0; i<M; i=i+1) begin: PARSE_INPUT_VECTORS
		assign parse_vec_at[i] = i_vec_at[(DATA_LEN)*(i) +: (DATA_LEN)];
		assign parse_vec_b[i]  = i_vec_b[(DATA_LEN)*(i) +: (DATA_LEN)];
	end
endgenerate

generate
	for(i=0; i<K; i=i+1) begin: PARSE_MAT_A	    
		assign parse_mat_copy_a[0][i] = mat_copy_a[(ROW_SIZE * 0) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_a[1][i] = mat_copy_a[(ROW_SIZE * 1) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_a[2][i] = mat_copy_a[(ROW_SIZE * 2) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_a[3][i] = mat_copy_a[(ROW_SIZE * 3) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_a[4][i] = mat_copy_a[(ROW_SIZE * 4) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_a[5][i] = mat_copy_a[(ROW_SIZE * 5) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_a[6][i] = mat_copy_a[(ROW_SIZE * 6) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_a[7][i] = mat_copy_a[(ROW_SIZE * 7) + (DATA_LEN * i) +: DATA_LEN];
	end
endgenerate

generate
	for(i=0; i<K; i=i+1) begin: PARSE_MAT_B
		assign parse_mat_copy_b[0][i] = mat_copy_b[(ROW_SIZE * 0) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_b[1][i] = mat_copy_b[(ROW_SIZE * 1) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_b[2][i] = mat_copy_b[(ROW_SIZE * 2) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_b[3][i] = mat_copy_b[(ROW_SIZE * 3) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_b[4][i] = mat_copy_b[(ROW_SIZE * 4) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_b[5][i] = mat_copy_b[(ROW_SIZE * 5) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_b[6][i] = mat_copy_b[(ROW_SIZE * 6) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_copy_b[7][i] = mat_copy_b[(ROW_SIZE * 7) + (DATA_LEN * i) +: DATA_LEN];
	end
endgenerate

generate
	for(i=0; i<N; i=i+1) begin: PARSE_MAT_C
		assign parse_mat_outer_c[0][i] =  o_mat_c[(ROW_SIZE * 0) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_outer_c[1][i] =  o_mat_c[(ROW_SIZE * 1) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_outer_c[2][i] =  o_mat_c[(ROW_SIZE * 2) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_outer_c[3][i] =  o_mat_c[(ROW_SIZE * 3) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_outer_c[4][i] =  o_mat_c[(ROW_SIZE * 4) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_outer_c[5][i] =  o_mat_c[(ROW_SIZE * 5) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_outer_c[6][i] =  o_mat_c[(ROW_SIZE * 6) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_outer_c[7][i] =  o_mat_c[(ROW_SIZE * 7) + (DATA_LEN * i) +: DATA_LEN];
	end
endgenerate


generate
	for(i=0; i<K; i=i+1) begin: COPY_INPUT_ROW	    
		always @(posedge i_clk, negedge i_rstn) begin
			if(!i_rstn) begin
				mat_copy_a[(ROW_SIZE * 0) + (DATA_LEN * i) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_a[(ROW_SIZE * 1) + (DATA_LEN * i) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_a[(ROW_SIZE * 2) + (DATA_LEN * i) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_a[(ROW_SIZE * 3) + (DATA_LEN * i) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_a[(ROW_SIZE * 4) + (DATA_LEN * i) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_a[(ROW_SIZE * 5) + (DATA_LEN * i) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_a[(ROW_SIZE * 6) + (DATA_LEN * i) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_a[(ROW_SIZE * 7) + (DATA_LEN * i) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
																		
				mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 0) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 1) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 2) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 3) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 4) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 5) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 6) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 7) +: DATA_LEN] <= {(DATA_LEN){1'b0}};
			end
			else begin
				mat_copy_a[(ROW_SIZE * 0) + (DATA_LEN * i) +: DATA_LEN] <= parse_vec_at[0];
			    mat_copy_a[(ROW_SIZE * 1) + (DATA_LEN * i) +: DATA_LEN] <= parse_vec_at[1];
			    mat_copy_a[(ROW_SIZE * 2) + (DATA_LEN * i) +: DATA_LEN] <= parse_vec_at[2];
			    mat_copy_a[(ROW_SIZE * 3) + (DATA_LEN * i) +: DATA_LEN] <= parse_vec_at[3];
			    mat_copy_a[(ROW_SIZE * 4) + (DATA_LEN * i) +: DATA_LEN] <= parse_vec_at[4];
			    mat_copy_a[(ROW_SIZE * 5) + (DATA_LEN * i) +: DATA_LEN] <= parse_vec_at[5];
			    mat_copy_a[(ROW_SIZE * 6) + (DATA_LEN * i) +: DATA_LEN] <= parse_vec_at[6];
			    mat_copy_a[(ROW_SIZE * 7) + (DATA_LEN * i) +: DATA_LEN] <= parse_vec_at[7];
																	    
				mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 0) +: DATA_LEN] <= parse_vec_b[0];
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 1) +: DATA_LEN] <= parse_vec_b[1];
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 2) +: DATA_LEN] <= parse_vec_b[2];
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 3) +: DATA_LEN] <= parse_vec_b[3];
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 4) +: DATA_LEN] <= parse_vec_b[4];
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 5) +: DATA_LEN] <= parse_vec_b[5];
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 6) +: DATA_LEN] <= parse_vec_b[6];
			    mat_copy_b[(ROW_SIZE * i) + (DATA_LEN * 7) +: DATA_LEN] <= parse_vec_b[7];
			end		
		end
	end
endgenerate


generate
	for(i=0; i<N; i=i+1) begin: MAT_MUL
		always @(posedge i_clk, negedge i_rstn) begin
			if(!i_rstn) begin
				o_mat_c[(DATA_LEN*N)*0 + (DATA_LEN)*(i) +: (DATA_LEN)] <= 0;
				o_mat_c[(DATA_LEN*N)*1 + (DATA_LEN)*(i) +: (DATA_LEN)] <= 0;
				o_mat_c[(DATA_LEN*N)*2 + (DATA_LEN)*(i) +: (DATA_LEN)] <= 0;
				o_mat_c[(DATA_LEN*N)*3 + (DATA_LEN)*(i) +: (DATA_LEN)] <= 0;
				o_mat_c[(DATA_LEN*N)*4 + (DATA_LEN)*(i) +: (DATA_LEN)] <= 0;
				o_mat_c[(DATA_LEN*N)*5 + (DATA_LEN)*(i) +: (DATA_LEN)] <= 0;
				o_mat_c[(DATA_LEN*N)*6 + (DATA_LEN)*(i) +: (DATA_LEN)] <= 0;
				o_mat_c[(DATA_LEN*N)*7 + (DATA_LEN)*(i) +: (DATA_LEN)] <= 0;
			end
			else begin
				o_mat_c[(DATA_LEN*N)*0 + (DATA_LEN)*(i) +: (DATA_LEN)] <= parse_mat_copy_a[0][i] * parse_mat_copy_b[0][i];
				o_mat_c[(DATA_LEN*N)*1 + (DATA_LEN)*(i) +: (DATA_LEN)] <= parse_mat_copy_a[1][i] * parse_mat_copy_b[1][i];
				o_mat_c[(DATA_LEN*N)*2 + (DATA_LEN)*(i) +: (DATA_LEN)] <= parse_mat_copy_a[2][i] * parse_mat_copy_b[2][i];
				o_mat_c[(DATA_LEN*N)*3 + (DATA_LEN)*(i) +: (DATA_LEN)] <= parse_mat_copy_a[3][i] * parse_mat_copy_b[3][i];
				o_mat_c[(DATA_LEN*N)*4 + (DATA_LEN)*(i) +: (DATA_LEN)] <= parse_mat_copy_a[4][i] * parse_mat_copy_b[4][i];
				o_mat_c[(DATA_LEN*N)*5 + (DATA_LEN)*(i) +: (DATA_LEN)] <= parse_mat_copy_a[5][i] * parse_mat_copy_b[5][i];
				o_mat_c[(DATA_LEN*N)*6 + (DATA_LEN)*(i) +: (DATA_LEN)] <= parse_mat_copy_a[6][i] * parse_mat_copy_b[6][i];
				o_mat_c[(DATA_LEN*N)*7 + (DATA_LEN)*(i) +: (DATA_LEN)] <= parse_mat_copy_a[7][i] * parse_mat_copy_b[7][i];
			end		
		end
	
	end
endgenerate

endmodule
