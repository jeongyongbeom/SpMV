`timescale 1ns / 1ns
module mat_accum#(
	parameter DATA_LEN = 32,
	parameter M = 8,
	parameter N = 8,
	parameter K = 8,	
	parameter ROW_SIZE = (DATA_LEN*K),
	parameter MAT_SIZE = (DATA_LEN*K*M)
)(
	input 					 				  i_clk,
	input 					 				  i_rstn,
	input									  i_start,
	input  signed		[MAT_SIZE-1:0]	  i_mat_accum_a,
	output reg signed	[MAT_SIZE-1:0]	  o_mat_accum_c
);

wire signed	[MAT_SIZE-1:0]	  mat_add_c;
wire signed [DATA_LEN-1:0] parse_mat_accum_a [0:M-1][0:K-1] ;
wire signed [DATA_LEN-1:0] parse_mat_accum_b [0:M-1][0:K-1] ;
wire signed [DATA_LEN-1:0] parse_mat_accum_c [0:K-1][0:N-1] ;

genvar i;
generate
	for(i=0; i<K; i=i+1) begin: PARSE_MAT_A	    
		assign parse_mat_accum_a[0][i] = i_mat_accum_a[(ROW_SIZE * 0) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_a[1][i] = i_mat_accum_a[(ROW_SIZE * 1) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_a[2][i] = i_mat_accum_a[(ROW_SIZE * 2) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_a[3][i] = i_mat_accum_a[(ROW_SIZE * 3) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_a[4][i] = i_mat_accum_a[(ROW_SIZE * 4) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_a[5][i] = i_mat_accum_a[(ROW_SIZE * 5) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_a[6][i] = i_mat_accum_a[(ROW_SIZE * 6) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_a[7][i] = i_mat_accum_a[(ROW_SIZE * 7) + (DATA_LEN * i) +: DATA_LEN];
	end
	for(i=0; i<N; i=i+1) begin: PARSE_MAT_B_AND_C	    
		assign parse_mat_accum_c[0][i] = o_mat_accum_c[(ROW_SIZE * 0) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_c[1][i] = o_mat_accum_c[(ROW_SIZE * 1) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_c[2][i] = o_mat_accum_c[(ROW_SIZE * 2) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_c[3][i] = o_mat_accum_c[(ROW_SIZE * 3) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_c[4][i] = o_mat_accum_c[(ROW_SIZE * 4) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_c[5][i] = o_mat_accum_c[(ROW_SIZE * 5) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_c[6][i] = o_mat_accum_c[(ROW_SIZE * 6) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_c[7][i] = o_mat_accum_c[(ROW_SIZE * 7) + (DATA_LEN * i) +: DATA_LEN];
		
		assign parse_mat_accum_b[0][i] = o_mat_accum_c[(ROW_SIZE * 0) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_b[1][i] = o_mat_accum_c[(ROW_SIZE * 1) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_b[2][i] = o_mat_accum_c[(ROW_SIZE * 2) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_b[3][i] = o_mat_accum_c[(ROW_SIZE * 3) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_b[4][i] = o_mat_accum_c[(ROW_SIZE * 4) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_b[5][i] = o_mat_accum_c[(ROW_SIZE * 5) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_b[6][i] = o_mat_accum_c[(ROW_SIZE * 6) + (DATA_LEN * i) +: DATA_LEN];
		assign parse_mat_accum_b[7][i] = o_mat_accum_c[(ROW_SIZE * 7) + (DATA_LEN * i) +: DATA_LEN];
	end
endgenerate

mat_add u0(
	.i_mat_add_a(i_mat_accum_a),
	.i_mat_add_b(o_mat_accum_c),
	.o_mat_add_c(mat_add_c)
);

always @(posedge i_clk, negedge i_rstn) begin
	if(!i_rstn) begin
		o_mat_accum_c <= {(MAT_SIZE){1'b0}};	
	end
	else begin	
		if(i_start)
			o_mat_accum_c <= i_mat_accum_a;
		else
			o_mat_accum_c <= mat_add_c;
	end
end

endmodule
