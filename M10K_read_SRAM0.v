`timescale 1ns / 1ps

module M10K_read_SRAM0(
	
	input i_clk,
	input i_rstn,
	input i_read_start_IV,
	input i_read_start_MV,
	input [7:0] i_count,
	
	input [255:0] i_read_data,

	output [4:0] o_read_addr,
	output [255:0] o_in_vector,
	output [15:0] o_mat_vector,
	output [1:0] o_state
	);
	
	parameter IDLE		= 2'b00;
	parameter IV_READ	= 2'b01;
	parameter MV_READ	= 2'b10;
	parameter DONE		= 2'b11;

	//Signal Declaration
	reg [255:0] buffer_in_vector;
	reg [255:0] buffer_mat_vector;
	wire  read_MV_fin;

	reg [1:0] state;
	reg [1:0] next_state;
	
	assign o_state = state;
    assign read_MV_fin = (state == MV_READ) && (i_count[3:0] == 4'b0000);
    assign o_read_addr = (state == IV_READ)? 16:
						 (state == MV_READ)? 17: 0;
    
    
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) state <= IDLE;
		else		state <= next_state;
	end
	
	always @(*) begin
		case(state)
			IDLE: begin
				if(i_read_start_IV)			next_state <= IV_READ;
				else if(i_read_start_MV)	next_state <= MV_READ;
				else						next_state <= IDLE;
			end
			IV_READ: begin
				                			next_state <= MV_READ;
			end
			MV_READ: begin
				if(read_MV_fin)				next_state <= DONE;
				else						next_state <= MV_READ;
			end
			DONE: begin
											next_state <= IDLE;
			end
		endcase
	end
	
	// DATA transfer SRMA0 to Input Vector Buffer & Value Buffer
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			buffer_in_vector		<= 256'b0;
			buffer_mat_vector		<= 256'b0;
		end else begin
			case(state)
				IDLE: begin
					buffer_in_vector		<= buffer_in_vector;
					buffer_mat_vector		<= buffer_mat_vector;
				end
				IV_READ: begin
					buffer_in_vector		<= i_read_data;
				end
				MV_READ: begin
					buffer_mat_vector		<= i_read_data;
				end
				DONE: begin
					buffer_in_vector		<= buffer_in_vector;
					buffer_mat_vector		<= buffer_mat_vector;
				end
			endcase
		end
	end

	// Output
	assign o_mat_vector = buffer_mat_vector[(i_count%16)*16 +: 16];
	assign o_in_vector = buffer_in_vector;


endmodule
