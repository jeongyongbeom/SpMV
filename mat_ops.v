`timescale 1ns / 1ns
module mat_ops#(
	parameter DATA_LEN = 32,
	parameter M = 8,
	parameter N = 8,
	parameter K = 8,
	parameter ROW_SIZE = (DATA_LEN*K),
	parameter MAT_SIZE = (DATA_LEN*K*M),
	
	parameter ADDRESS_SIZE = 4,
	parameter READ_A_ADDR_OFFSET = 8,
	parameter READ_B_ADDR_OFFSET = 0,
	parameter WRITE_B_ADDR_OFFSET = 8,
	parameter READ    = 3'b000,
	parameter MAT_MUL = 3'b001,
	parameter WRITE   = 3'b010,
	parameter DONE    = 3'b011,
	parameter IDLE	  = 3'b111,

	//parameter READ_READ0 = 4'd0,
	//parameter READ_READ1 = 4'd1,
	//parameter READ_READ2 = 4'd2,
	//parameter READ_READ3 = 4'd3,
	//parameter READ_READ4 = 4'd4,
	//parameter READ_READ5 = 4'd5,
	//parameter READ_READ6 = 4'd6,
	//parameter READ_READ7 = 4'd7,
	//parameter READ_WAIT  = 4'd8,
	parameter READ_DONE  = 4'd9,
	parameter READ_IDLE  = 4'd15,

	// parameter MAT_MUL_MUL0   = 4'd0,
	// parameter MAT_MUL_MUL1   = 4'd1,
	// parameter MAT_MUL_MUL2   = 4'd2,
	// parameter MAT_MUL_MUL3   = 4'd3,
	// parameter MAT_MUL_MUL4   = 4'd4,
	// parameter MAT_MUL_MUL5   = 4'd5,
	// parameter MAT_MUL_MUL6   = 4'd6,
	// parameter MAT_MUL_MUL7   = 4'd7,
	// parameter MAT_MUL_STORE  = 4'd8,
	 parameter MAT_MUL_DONE	    = 4'd9,
	// parameter MAT_MUL_IDLE	 = 4'b1111

	// parameter WRITE_WRITE0 = 4'd0,
	// parameter WRITE_WRITE1 = 4'd1,
	// parameter WRITE_WRITE2 = 4'd2,
	// parameter WRITE_WRITE3 = 4'd3,
	// parameter WRITE_WRITE4 = 4'd4,
	// parameter WRITE_WRITE5 = 4'd5,
	// parameter WRITE_WRITE6 = 4'd6,
	// parameter WRITE_WRITE7 = 4'd7,
    parameter WRITE_DONE   = 4'd8,
	parameter WRITE_IDLE   = 4'd15
)(
	input 					 		  i_clk,
	input 					 		  i_rstn,
	input							  i_start,
	///////////// read a //////////
	input   [DATA_LEN*N-1:0]	  	  i_read_data_A,
	output	[ADDRESS_SIZE-1:0]	  	  o_address_A,
	output  						  o_wr_en_A,
	
	///////////// read b //////////
	input   [DATA_LEN*N-1:0]	  	  i_read_data_B,
	output	 [ADDRESS_SIZE-1:0]	  	  o_address_B,
	output  						  o_wr_en_B,

	///////////// write b//////////	
	output  [DATA_LEN*N-1:0]	  	  o_write_data_B,
	
	output  [2:0]					  o_state,
	output	[3:0]					  o_read_state,
	output	[3:0]					  o_mat_mul_state,
	output	[3:0]					  o_write_state,
	output							  o_done

);
	reg  [2:0] state;     
	reg  [2:0] next_state; 
	
	wire  [3:0] read_state;
	wire  [3:0] mat_mul_state;
	wire  [3:0] write_state;
	
	assign o_read_state 	= read_state;
	assign o_mat_mul_state  = mat_mul_state;
	assign o_write_state	= write_state;
	
	wire read_start  ;
	wire read_done  ;
	wire mat_mul_start;
	wire mat_mul_done;
	wire write_start ;
	wire write_done ;
	wire read_reset ;
	
	wire [(DATA_LEN*N*M)-1:0]  read_A;
	wire [(DATA_LEN)-1:0]      parse_read_A[0:M-1][0:K-1];
	wire [(DATA_LEN*N*M)-1:0]  read_B;
	wire [(DATA_LEN)-1:0]      parse_read_B[0:K-1][0:N-1];
	wire [(DATA_LEN*N*M)-1:0]  matmul_C;
	wire [(DATA_LEN)-1:0]      parse_matmul_C[0:M-1][0:N-1];
	
    wire [ADDRESS_SIZE-1:0] write_address_B;
    wire [ADDRESS_SIZE-1:0] read_address_B;
	wire [ADDRESS_SIZE-1:0] address_A;

	wire w_en_B;
	
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end	
	end
	
	assign o_state = state;
	
	always @(*) begin
		case(state) 
			IDLE:           begin
					         	if( i_start  )  next_state = READ;
					         	else 	     	next_state = IDLE;
					        end
			READ:        begin
					            if(read_done )  next_state = MAT_MUL;
					         	else 	     	next_state = READ;		
					        end
			MAT_MUL:        begin			         	
								if(mat_mul_done) 
												next_state = WRITE;
					         	else 			next_state = MAT_MUL;
					        end				
			WRITE:        begin
					         	if(write_done)  next_state = DONE;
					         	else 	     	next_state = WRITE;
					        end
			DONE:           begin
					         					next_state = IDLE;
					        end 
		endcase      
	end
	
	assign read_start    = (state == IDLE   )   && (next_state     == READ);
	assign read_done     = (state == READ   )   && (read_state     == READ_DONE);
	assign mat_mul_start = (state == READ   )   && (next_state     == MAT_MUL);
	assign mat_mul_done  = (state == MAT_MUL)   && (mat_mul_state  == MAT_MUL_DONE);
	assign write_start   = (state == MAT_MUL)   && (next_state     == WRITE);
	assign write_done    = (state == WRITE  )   && (write_state    == WRITE_DONE);
	assign read_reset    = (state == DONE   );
	assign o_done        = (state == DONE   );
	assign o_address_A   = address_A;
	assign o_address_B   = (w_en_B == 1'b1) ? (write_address_B) : read_address_B;
	assign o_wr_en_A     = 1'b0;
	assign o_wr_en_B     = (w_en_B == 1'b1) ? w_en_B : 1'b0;
	
	
M10K_read_buffer #(.DATA_LEN(DATA_LEN), .ADDRESS_SIZE(ADDRESS_SIZE), .OFFSET(READ_A_ADDR_OFFSET)) r0
(
	.i_clk         (i_clk ),			
	.i_rstn        (i_rstn),               
	.i_read_reset  (read_reset),           
	.i_read_start  (read_start),           
	.i_read_data   (i_read_data_A),        
				                           
	.o_store_mat   (read_A),             
	.o_read_addr   (address_A),            
	.o_state       (read_state)            
	
);

M10K_read_buffer #(.DATA_LEN(DATA_LEN), .ADDRESS_SIZE(ADDRESS_SIZE), .OFFSET(READ_B_ADDR_OFFSET)) r1
(
	
	.i_clk		   (i_clk ),
	.i_rstn  	   (i_rstn),
	.i_read_reset  (read_reset),
	.i_read_start  (read_start),
	.i_read_data   (i_read_data_B),
	
	.o_store_mat   (read_B),
	.o_read_addr   (read_address_B),
	.o_state       ()
);
mat_mul m0(
	.i_clk		(i_clk),
	.i_rstn     (i_rstn),
	.i_start    (mat_mul_start),
	.i_mat_a    (read_A),
	.i_mat_b    (read_B),
	.o_mat_c    (matmul_C),
	.o_state    (mat_mul_state),
	.o_done		()
);

M10K_write #(.DATA_LEN(DATA_LEN), .ADDRESS_SIZE(ADDRESS_SIZE), .OFFSET(WRITE_B_ADDR_OFFSET)) w0
(
	.i_clk 		 	(i_clk ),
	.i_rstn 		(i_rstn),
	.i_write_start  (write_start),
	.i_in_mat 		(matmul_C),
	 
	.o_write_addr 	(write_address_B),
	.o_write_data 	(o_write_data_B),
	.o_write_start  (w_en_B),
	.o_state 		(write_state)
);


genvar i;
	generate
	for(i=0; i<K; i=i+1) begin: PARSE_MAT_A	    
		assign parse_read_A[0][i] = read_A[((DATA_LEN*K)*0) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_A[1][i] = read_A[((DATA_LEN*K)*1) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_A[2][i] = read_A[((DATA_LEN*K)*2) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_A[3][i] = read_A[((DATA_LEN*K)*3) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_A[4][i] = read_A[((DATA_LEN*K)*4) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_A[5][i] = read_A[((DATA_LEN*K)*5) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_A[6][i] = read_A[((DATA_LEN*K)*6) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_A[7][i] = read_A[((DATA_LEN*K)*7) + DATA_LEN*(i) +: DATA_LEN];
		
		assign parse_read_B[0][i] = read_B[((DATA_LEN*K)*0) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_B[1][i] = read_B[((DATA_LEN*K)*1) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_B[2][i] = read_B[((DATA_LEN*K)*2) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_B[3][i] = read_B[((DATA_LEN*K)*3) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_B[4][i] = read_B[((DATA_LEN*K)*4) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_B[5][i] = read_B[((DATA_LEN*K)*5) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_B[6][i] = read_B[((DATA_LEN*K)*6) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_read_B[7][i] = read_B[((DATA_LEN*K)*7) + DATA_LEN*(i) +: DATA_LEN];
		
		assign parse_matmul_C[0][i] = matmul_C[((DATA_LEN*K)*0) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_matmul_C[1][i] = matmul_C[((DATA_LEN*K)*1) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_matmul_C[2][i] = matmul_C[((DATA_LEN*K)*2) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_matmul_C[3][i] = matmul_C[((DATA_LEN*K)*3) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_matmul_C[4][i] = matmul_C[((DATA_LEN*K)*4) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_matmul_C[5][i] = matmul_C[((DATA_LEN*K)*5) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_matmul_C[6][i] = matmul_C[((DATA_LEN*K)*6) + DATA_LEN*(i) +: DATA_LEN];
		assign parse_matmul_C[7][i] = matmul_C[((DATA_LEN*K)*7) + DATA_LEN*(i) +: DATA_LEN];
	end
	endgenerate

endmodule

