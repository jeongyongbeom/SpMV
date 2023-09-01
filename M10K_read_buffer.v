module M10K_read_buffer#(
	parameter DATA_LEN = 32,
	parameter M = 8,
	parameter N = 8,
	parameter ADDRESS_SIZE = 4,
	parameter OFFSET = 4'd0,
	parameter READ0 = 4'd0,
	parameter READ1 = 4'd1,
	parameter READ2 = 4'd2,
	parameter READ3 = 4'd3,
	parameter READ4 = 4'd4,
	parameter READ5 = 4'd5,
	parameter READ6 = 4'd6,
	parameter READ7 = 4'd7,
	parameter WAIT  = 4'd8,
	parameter DONE  = 4'd9,
	parameter IDLE  = 4'd15	
)(
	input 					 		     i_clk,
	input 					 		     i_rstn,
	input							     i_read_reset,
	input							     i_read_start,
	input   [DATA_LEN*N-1:0]	  	     i_read_data,
	
	output   [DATA_LEN*M*N-1:0]	         o_store_mat,
	output	reg [ADDRESS_SIZE-1:0]       o_read_addr,
	output  [3:0]  					     o_state,
	output								 o_done
	
);
	reg  [3:0] state;     
	reg  [3:0] next_state;
	
	reg  [DATA_LEN*N-1:0] store_vec [0:M-1];
	
	assign o_state = state;
	assign o_done  = (state == DONE);
	
	genvar i;	
	generate
	for(i=0; i<M; i=i+1) begin: OUTPUT_MERGE
		assign o_store_mat[(DATA_LEN*N)*((i)) +: (DATA_LEN*N)] = store_vec[i];
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
			IDLE: begin
						if(i_read_start)   next_state = READ0;
						else 	     	   next_state = IDLE;
					end
			READ0: begin
						next_state = READ1;
					end
			READ1: begin
						next_state = READ2;
					end
			READ2: begin
						next_state = READ3;
					end
			READ3: begin
						next_state = READ4;
					end
			READ4: begin
						next_state = READ5;
					end
			READ5: begin
						next_state = READ6;
					end
			READ6: begin
						next_state = READ7;
					end
			READ7: begin
						next_state = WAIT;
					end
			WAIT: begin
						next_state = DONE;
					end
			DONE:  begin
					    if(i_read_reset)  next_state = IDLE;
						else 	     	  next_state = DONE;
				   end
			default:begin
						next_state = IDLE;
					end
		endcase
	end

	always @(*) begin
		case(state) 
			IDLE:  begin
						o_read_addr  = READ0 + OFFSET;			
					end
			READ0: begin		
						o_read_addr  = READ0 + OFFSET;	
					end
			READ1: begin
	
						o_read_addr  = READ1 + OFFSET;
					end
			READ2: begin
					
						o_read_addr  = READ2 + OFFSET;
					end
			READ3: begin
						
						o_read_addr  = READ3 + OFFSET;
					end
			READ4: begin
						
						o_read_addr  = READ4 + OFFSET;
					end
			READ5: begin
						
						o_read_addr  = READ5 + OFFSET;
					end
			READ6: begin
						
						o_read_addr  = READ6 + OFFSET;
					end
			READ7: begin
						
						o_read_addr  = READ7 + OFFSET;
					end
			WAIT : begin
						
						o_read_addr  = READ0 + OFFSET;
					end
			DONE:  begin
					    
						o_read_addr  = READ0 + OFFSET;
				   end
			default:begin
						
						o_read_addr  = READ0 + OFFSET;
					end
		endcase
	end
	
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			store_vec[0] <= {(DATA_LEN*N){1'b0}};
			store_vec[1] <= {(DATA_LEN*N){1'b0}};
			store_vec[2] <= {(DATA_LEN*N){1'b0}};
			store_vec[3] <= {(DATA_LEN*N){1'b0}};
			store_vec[4] <= {(DATA_LEN*N){1'b0}};
			store_vec[5] <= {(DATA_LEN*N){1'b0}};
			store_vec[6] <= {(DATA_LEN*N){1'b0}};
			store_vec[7] <= {(DATA_LEN*N){1'b0}};
			end
		else begin
			case(state) 
				IDLE:  begin
							store_vec[0] <= {(DATA_LEN*N){1'b0}};
							store_vec[1] <= {(DATA_LEN*N){1'b0}};
							store_vec[2] <= {(DATA_LEN*N){1'b0}};
							store_vec[3] <= {(DATA_LEN*N){1'b0}};
							store_vec[4] <= {(DATA_LEN*N){1'b0}};
							store_vec[5] <= {(DATA_LEN*N){1'b0}};
							store_vec[6] <= {(DATA_LEN*N){1'b0}};
							store_vec[7] <= {(DATA_LEN*N){1'b0}};
						end
				READ0: begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= store_vec[1];
							store_vec[2] <= store_vec[2];
							store_vec[3] <= store_vec[3];
							store_vec[4] <= store_vec[4];
							store_vec[5] <= store_vec[5];
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	store_vec[7];		
						end
				READ1: begin
							store_vec[0] <= i_read_data ; 
							store_vec[1] <= store_vec[1];
							store_vec[2] <= store_vec[2];
							store_vec[3] <= store_vec[3];
							store_vec[4] <= store_vec[4];
							store_vec[5] <= store_vec[5];
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	store_vec[7];
						end 
				READ2: begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= i_read_data ;
							store_vec[2] <= store_vec[2];
							store_vec[3] <= store_vec[3];
							store_vec[4] <= store_vec[4];
							store_vec[5] <= store_vec[5];
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	store_vec[7];
						end 
				READ3: begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= store_vec[1];
							store_vec[2] <= i_read_data ;
							store_vec[3] <= store_vec[3];
							store_vec[4] <= store_vec[4];
							store_vec[5] <= store_vec[5];
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	store_vec[7];
						end 
				READ4: begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= store_vec[1];
							store_vec[2] <= store_vec[2];
							store_vec[3] <= i_read_data ;
							store_vec[4] <= store_vec[4];
							store_vec[5] <= store_vec[5];
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	store_vec[7];
						end 
				READ5: begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= store_vec[1];
							store_vec[2] <= store_vec[2];
							store_vec[3] <= store_vec[3];
							store_vec[4] <= i_read_data ;
							store_vec[5] <= store_vec[5];
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	store_vec[7];
						end 
				READ6: begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= store_vec[1];
							store_vec[2] <= store_vec[2];
							store_vec[3] <= store_vec[3];
							store_vec[4] <= store_vec[4];
							store_vec[5] <= i_read_data ;
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	store_vec[7];
						end 
				READ7: begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= store_vec[1];
							store_vec[2] <= store_vec[2];
							store_vec[3] <= store_vec[3];
							store_vec[4] <= store_vec[4];
							store_vec[5] <= store_vec[5];
							store_vec[6] <= i_read_data ;
							store_vec[7] <=	store_vec[7];
						end 
				WAIT : begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= store_vec[1];
							store_vec[2] <= store_vec[2];
							store_vec[3] <= store_vec[3];
							store_vec[4] <= store_vec[4];
							store_vec[5] <= store_vec[5];
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	i_read_data ;
						end
				DONE:  begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= store_vec[1];
							store_vec[2] <= store_vec[2];
							store_vec[3] <= store_vec[3];
							store_vec[4] <= store_vec[4];
							store_vec[5] <= store_vec[5];
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	store_vec[7];
					   end
				default:begin
							store_vec[0] <= store_vec[0];
							store_vec[1] <= store_vec[1];
							store_vec[2] <= store_vec[2];
							store_vec[3] <= store_vec[3];
							store_vec[4] <= store_vec[4];
							store_vec[5] <= store_vec[5];
							store_vec[6] <= store_vec[6];
							store_vec[7] <=	store_vec[7];
						end
			endcase
		end
	end
endmodule
