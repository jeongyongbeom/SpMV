`timescale 1ns / 1ps


module M10K_read_SRAM1(
	
	input i_clk,
	input i_rstn,
	
	input i_read_reset,
	input i_read_start,
	
	input [7:0] 		i_count,
	
	input [255:0] 		i_read_data,

	output reg [4:0] 	o_read_addr,
	output [255:0] 	o_row_ptr,
	output [3:0] 		o_col_idx,
	output [3:0] 		o_state,
	output 				o_done
	);
	
	
	parameter READ_RP	= 4'd0;
	parameter READ1 	= 4'd1;
	parameter READ2 	= 4'd2;
	parameter READ3 	= 4'd3;
	parameter READ4 	= 4'd4;
	parameter WAIT		= 4'd5;
	parameter DONE		= 4'd6;
	parameter IDLE  	= 4'd15;
	
	parameter OFFSET  = 4'd0;
	
	//////// Buffer //////////
	reg [255:0] 	buffer_row_ptr;
	reg [255:0] 	buffer_col_idx[0:3];

	reg [3:0] state;
	reg [3:0] next_state;
	
   assign o_state = state;
	 	
	// Output
	assign o_row_ptr = buffer_row_ptr;
	
	assign o_col_idx = (i_count[7:6] == 2'b00)? buffer_col_idx[0][(i_count%64)*4 +: 4]:
							 (i_count[7:6] == 2'b01)? buffer_col_idx[1][(i_count%64)*4 +: 4]:
							 (i_count[7:6] == 2'b10)? buffer_col_idx[2][(i_count%64)*4 +: 4]:
							 (i_count[7:6] == 2'b11)? buffer_col_idx[3][(i_count%64)*4 +: 4]: 4'b0;
	
	assign o_done = (state == DONE);
	
	//Signal Declaration
	wire read_done;
	
   // Current State Register
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) state <= IDLE;
		else			state <= next_state;
	end
	
	// Next State Logic
	always @(*) begin
		case(state)
			IDLE: begin
				if(i_read_start)		next_state <= READ_RP;
				else						next_state <= IDLE;
			end
			READ_RP: begin
				if(read_done)			next_state <= DONE;
				else						next_state <= READ1;
			end
			READ1: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ2;
			end
			READ2: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ3;
			end
			READ3: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ4;
			end
			READ4: begin
											next_state <= WAIT;
			end
			WAIT: begin
											next_state <= DONE;
			end
			DONE: begin
				if(i_read_reset)		next_state <= IDLE;
				else						next_state <= DONE;
			end
			default: begin
											next_state <= IDLE;
			end								
		endcase
	end
	
	// Address
	always @(*) begin
		case(state)
			IDLE: begin
				o_read_addr <= READ_RP + OFFSET;
			end
			READ_RP: begin
				o_read_addr <= READ_RP + OFFSET;
			end
			READ1: begin
				o_read_addr <= READ1 + OFFSET;
			end
			READ2: begin
				o_read_addr <= READ2 + OFFSET;
			end
			READ3: begin
				o_read_addr <= READ3 + OFFSET;
			end
			READ4: begin
				o_read_addr <= READ4 + OFFSET;
			end
			WAIT: begin
				o_read_addr <= READ_RP + OFFSET;
			end
			DONE: begin
				o_read_addr <= READ_RP + OFFSET;
			end
			default: begin
				o_read_addr <= READ_RP + OFFSET;
			end
		endcase
	end

	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			buffer_row_ptr					<= 256'b0;
			buffer_col_idx[0]				<= 256'b0;
			buffer_col_idx[1]				<= 256'b0;
			buffer_col_idx[2]				<= 256'b0;
			buffer_col_idx[3]				<= 256'b0;
		end else begin
			case(state)
				IDLE: begin
					buffer_row_ptr					<= 256'b0;
					buffer_col_idx[0]				<= 256'b0;
					buffer_col_idx[1]				<= 256'b0;
					buffer_col_idx[2]				<= 256'b0;
					buffer_col_idx[3]				<= 256'b0;
				end
				READ_RP: begin
					buffer_row_ptr					<= buffer_row_ptr	  ;
					buffer_col_idx[0]				<= buffer_col_idx[0];
					buffer_col_idx[1]				<= buffer_col_idx[1];
					buffer_col_idx[2]				<= buffer_col_idx[2];
					buffer_col_idx[3]				<= buffer_col_idx[3];
				end
				READ1: begin
					buffer_row_ptr					<= i_read_data		  ;
					buffer_col_idx[0]				<= buffer_col_idx[0];
					buffer_col_idx[1]				<= buffer_col_idx[1];
					buffer_col_idx[2]				<= buffer_col_idx[2];
					buffer_col_idx[3]				<= buffer_col_idx[3];
				end
				READ2: begin
					buffer_row_ptr					<= buffer_row_ptr	  ;
					buffer_col_idx[0]				<= i_read_data		  ;
					buffer_col_idx[1]				<= buffer_col_idx[1];
					buffer_col_idx[2]				<= buffer_col_idx[2];
					buffer_col_idx[3]				<= buffer_col_idx[3];
				end
				READ3: begin
					buffer_row_ptr					<= buffer_row_ptr	  ;
					buffer_col_idx[0]				<= buffer_col_idx[0];
					buffer_col_idx[1]				<= i_read_data	     ;
					buffer_col_idx[2]				<= buffer_col_idx[2];
					buffer_col_idx[3]				<= buffer_col_idx[3];
				end
				READ4: begin
					buffer_row_ptr					<= buffer_row_ptr	  ;
					buffer_col_idx[0]				<= buffer_col_idx[0];
					buffer_col_idx[1]				<= buffer_col_idx[1];
					buffer_col_idx[2]				<= i_read_data		  ;
					buffer_col_idx[3]				<= buffer_col_idx[3];
				end
				WAIT: begin
					buffer_row_ptr					<= buffer_row_ptr	  ;
					buffer_col_idx[0]				<= buffer_col_idx[0];
					buffer_col_idx[1]				<= buffer_col_idx[1];
					buffer_col_idx[2]				<= buffer_col_idx[2];
					buffer_col_idx[3]				<= i_read_data		  ;
				end
				DONE: begin
					buffer_row_ptr					<= buffer_row_ptr	  ;
					buffer_col_idx[0]				<= buffer_col_idx[0];
					buffer_col_idx[1]				<= buffer_col_idx[1];
					buffer_col_idx[2]				<= buffer_col_idx[2];
					buffer_col_idx[3]				<= buffer_col_idx[3];
				end
				default: begin
					buffer_row_ptr					<= buffer_row_ptr	  ;
					buffer_col_idx[0]				<= buffer_col_idx[0];
					buffer_col_idx[1]				<= buffer_col_idx[1];
					buffer_col_idx[2]				<= buffer_col_idx[2];
					buffer_col_idx[3]				<= buffer_col_idx[3];
				end
			endcase
		end
	end

endmodule
