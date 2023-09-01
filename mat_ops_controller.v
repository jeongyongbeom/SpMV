`timescale 1ns / 1ns
module mat_ops_controller #(
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
	parameter POLLING			= 2'b11,
	parameter START   		    = 2'b00,
	parameter OPS               = 2'b01,
	parameter DONE        		= 2'b10
)
(
	input 					 		  i_clk,
	input 					 		  i_rstn,

	///////////// read a //////////
	input   [DATA_LEN*N-1:0]	  	  i_read_data_A,
	output	[ADDRESS_SIZE-1:0]	  o_address_A,
	output  						  		  o_wr_en_A,
	
	///////////// write b//////////	
	output  [DATA_LEN*N-1:0]	  	  o_write_data_A,
	
	///////////// read b //////////
	input    [DATA_LEN*N-1:0]	  	  i_read_data_B,
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
	
	reg  [1:0] state;     
	reg  [1:0] next_state; 
	wire 	   poll_done;
	
	
	wire 							    ops_start			  ;
		///////////// read a ////////// 
	wire 	[ADDRESS_SIZE-1:0]	  	    ops_address_A         ;
	wire   						 	    ops_wr_en_A           ;
														
	///////////// read b //////////                    
	wire	 [ADDRESS_SIZE-1:0]	  	    ops_address_B         ;
	wire  	    					    ops_wr_en_B           ;
														
	///////////// write b//////////	                    
	wire    [DATA_LEN*N-1:0]	  	    ops_write_data_B      ;
	
	wire    [2:0]					    ops_state             ;
	wire	[3:0]					    ops_read_state        ;
	wire	[3:0]					    ops_mat_mul_state     ;
	wire	[3:0]					    ops_write_state       ;
	wire							    ops_done              ;
	
	
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			state <= POLLING;
		end
		else begin
			state <= next_state;
		end	
	end
	
	assign o_state = state;
	
	always @(*) begin
		case(state) 
			POLLING:        begin
					         	if(poll_done)    next_state = START;
					         	else 	     	 next_state = POLLING;
					        end                 
			START:          begin                
												 next_state = OPS;
					        end	
			OPS:            begin 
								if(ops_done)     next_state = DONE;
					         	else 	     	 next_state = OPS;
					        end	
			DONE:           begin                
					         					 next_state = POLLING;
					        end 
			default: 	    next_state = POLLING;
		endcase      
	end
	
	assign ops_start 		= (state == START);
	
	assign o_address_A		= ((state == POLLING) || (state == DONE)) ? {(ADDRESS_SIZE){1'b0}} : ops_address_A ;
	assign o_wr_en_A        = (state == POLLING) ? 1'b0 : ((state == DONE) ? 1'b1 :  ops_wr_en_A) ; 
	assign o_write_data_A   = {(DATA_LEN*N){1'b0}};
	
	assign o_address_B      = ((state == POLLING) || (state == DONE)) ? {(ADDRESS_SIZE){1'b0}} : ops_address_B ;
	assign o_wr_en_B        = ((state == POLLING) || (state == DONE)) ?		 1'b0			   : ops_wr_en_B   ;  

	assign poll_done		= (state == POLLING) && (i_read_data_A[DATA_LEN-1:0] == {{(DATA_LEN-1){1'b0}}, 1'b1});
	assign o_done           = (state == DONE);
	
	mat_ops u0(
	.i_clk			 (i_clk),
	.i_rstn          (i_rstn),
	.i_start         (ops_start),
					 
	.i_read_data_A   (i_read_data_A),
	.o_address_A     (ops_address_A),
	.o_wr_en_A       (ops_wr_en_A),
					 
	.i_read_data_B   (i_read_data_B),
	.o_address_B     (ops_address_B),
	.o_wr_en_B       (ops_wr_en_B),
					
	.o_write_data_B  (o_write_data_B),
					
	.o_state         (ops_state),
	.o_read_state    (o_read_state   ),
	.o_mat_mul_state (o_mat_mul_state),
	.o_write_state   (o_write_state  ),
	.o_done          (ops_done         )
);
	
endmodule

