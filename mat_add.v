`timescale 1ns / 1ns
module mat_add#(
	parameter DATA_LEN = 32,
	parameter M = 8,
	parameter N = 8,
	parameter K = 8,
	parameter ROW_SIZE = (DATA_LEN*K),
	parameter MAT_SIZE = (DATA_LEN*K*M)
)(
	input  signed	[MAT_SIZE-1:0]	  i_mat_add_a,
	input  signed	[MAT_SIZE-1:0]	  i_mat_add_b,
	output signed 	[MAT_SIZE-1:0]	  o_mat_add_c
);

wire signed [DATA_LEN-1:0] parse_mat_a[0:M-1][0:K-1];
wire signed [DATA_LEN-1:0] parse_mat_b[0:K-1][0:N-1];
wire signed [DATA_LEN-1:0] parse_mat_c[0:M-1][0:N-1];

genvar i;
generate
	for(i=0; i<K; i=i+1) begin: PARSE_MAT_A
		assign parse_mat_a[0][i] = i_mat_add_a[(ROW_SIZE*0) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_a[1][i] = i_mat_add_a[(ROW_SIZE*1) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_a[2][i] = i_mat_add_a[(ROW_SIZE*2) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_a[3][i] = i_mat_add_a[(ROW_SIZE*3) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_a[4][i] = i_mat_add_a[(ROW_SIZE*4) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_a[5][i] = i_mat_add_a[(ROW_SIZE*5) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_a[6][i] = i_mat_add_a[(ROW_SIZE*6) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_a[7][i] = i_mat_add_a[(ROW_SIZE*7) + (DATA_LEN*i) +: DATA_LEN];
	end
endgenerate

generate
	for(i=0; i<N; i=i+1) begin: PARSE_MAT_B
		assign parse_mat_b[0][i] = i_mat_add_b[(ROW_SIZE*0) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_b[1][i] = i_mat_add_b[(ROW_SIZE*1) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_b[2][i] = i_mat_add_b[(ROW_SIZE*2) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_b[3][i] = i_mat_add_b[(ROW_SIZE*3) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_b[4][i] = i_mat_add_b[(ROW_SIZE*4) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_b[5][i] = i_mat_add_b[(ROW_SIZE*5) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_b[6][i] = i_mat_add_b[(ROW_SIZE*6) + (DATA_LEN*i) +: DATA_LEN];
		assign parse_mat_b[7][i] = i_mat_add_b[(ROW_SIZE*7) + (DATA_LEN*i) +: DATA_LEN];
	end
endgenerate

generate
	for(i=0; i<N; i=i+1) begin: PARSE_MAT_C
		assign o_mat_add_c[(ROW_SIZE*0) + (DATA_LEN*i) +: DATA_LEN] = parse_mat_c[0][i];
		assign o_mat_add_c[(ROW_SIZE*1) + (DATA_LEN*i) +: DATA_LEN] = parse_mat_c[1][i];
		assign o_mat_add_c[(ROW_SIZE*2) + (DATA_LEN*i) +: DATA_LEN] = parse_mat_c[2][i];
		assign o_mat_add_c[(ROW_SIZE*3) + (DATA_LEN*i) +: DATA_LEN] = parse_mat_c[3][i];
		assign o_mat_add_c[(ROW_SIZE*4) + (DATA_LEN*i) +: DATA_LEN] = parse_mat_c[4][i];
		assign o_mat_add_c[(ROW_SIZE*5) + (DATA_LEN*i) +: DATA_LEN] = parse_mat_c[5][i];
		assign o_mat_add_c[(ROW_SIZE*6) + (DATA_LEN*i) +: DATA_LEN] = parse_mat_c[6][i];
		assign o_mat_add_c[(ROW_SIZE*7) + (DATA_LEN*i) +: DATA_LEN] = parse_mat_c[7][i];
	end
endgenerate

generate
	for(i=0; i<N; i=i+1) begin: MAT_ADD
		assign parse_mat_c[0][i] = parse_mat_a[0][i] + parse_mat_b[0][i];
		assign parse_mat_c[1][i] = parse_mat_a[1][i] + parse_mat_b[1][i];
		assign parse_mat_c[2][i] = parse_mat_a[2][i] + parse_mat_b[2][i];
		assign parse_mat_c[3][i] = parse_mat_a[3][i] + parse_mat_b[3][i];
		assign parse_mat_c[4][i] = parse_mat_a[4][i] + parse_mat_b[4][i];
		assign parse_mat_c[5][i] = parse_mat_a[5][i] + parse_mat_b[5][i];
		assign parse_mat_c[6][i] = parse_mat_a[6][i] + parse_mat_b[6][i];
		assign parse_mat_c[7][i] = parse_mat_a[7][i] + parse_mat_b[7][i];
	end
endgenerate

endmodule
