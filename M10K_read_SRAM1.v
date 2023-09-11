`timescale 1ns / 1ps

module M10K_read_SRAM1(
	
	input i_clk,
	input i_rstn,
	input i_read_start_RP,
	input i_read_start_CI,
	input [7:0] i_count,
	
	input [255:0] i_read_data,

	output [4:0] o_read_addr,
	output [135:0] o_row_ptr,
	output [3:0] o_col_idx,
	output [1:0] o_state
	);
	
	parameter IDLE		= 2'b00;
	parameter RP_READ	= 2'b01;
	parameter CI_READ	= 2'b10;
	parameter DONE		= 2'b11;

	//Signal Declaration
	reg [255:0] buffer_row_ptr;
	reg [255:0] buffer_col_idx;
	wire read_CI_fin;

	reg [1:0] state;
	reg [1:0] next_state;
	
	
    assign o_state = state;
    assign read_CI_fin = (state == CI_READ) && (i_count[5:0] == 6'b0);
    
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) state <= IDLE;
		else		state <= next_state;
	end
	
	always @(*) begin
		case(state)
			IDLE: begin
				if(i_read_start_RP)			next_state <= RP_READ;
				else if(i_read_start_CI)	next_state <= CI_READ;
				else						next_state <= IDLE;
			end
			RP_READ: begin
				    						next_state <= CI_READ;
			end
			CI_READ: begin
				if(read_CI_fin)				next_state <= DONE;
				else						next_state <= CI_READ;
			end
			DONE: begin
											next_state <= IDLE;
			end
		endcase
	end
	
	// DATA transfer SRMA0 to Input Vector Buffer & Value Buffer
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			buffer_row_ptr		<= 256'b0;
			buffer_col_idx		<= 256'b0;
		end else begin
			case(state)
				IDLE: begin
					buffer_row_ptr		<= buffer_row_ptr;
					buffer_col_idx		<= buffer_col_idx;
				end
				RP_READ: begin
					buffer_row_ptr		<= i_read_data;
				end
				CI_READ: begin
					buffer_col_idx		<= i_read_data;
				end
				DONE: begin
					buffer_row_ptr		<= buffer_row_ptr;
					buffer_col_idx		<= buffer_col_idx;
				end
			endcase
		end
	end

	// Output
	assign o_row_ptr = buffer_row_ptr[135:0];
	assign o_col_idx = buffer_col_idx[(i_count%64)*4 +: 4];


endmodule
