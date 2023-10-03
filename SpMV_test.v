`timescale 1ns / 1ps

module SpMV_test(
	input i_clk,
	input i_rstn,
	
	input [255:0] i_read_data_A,
	input [255:0] i_read_data_B,
	
	output [4:0] o_address_A,
	output o_wr_en_A,
	output [255:0] o_write_data_A,
	
	output [4:0] o_address_B,
	output o_wr_en_B,
	output [255:0] o_write_data_B,
	
	output [2:0] o_state,
	output o_done
	);

	parameter POLLING = 2'b01;
	parameter START	= 2'b10;
	parameter OPS		= 2'b11;
	parameter DONE		= 2'b00;	
	
	reg [1:0] state;
	reg [1:0] next_state;
	
	wire poll_done;
	wire ops_done;
	wire ops_start;
	wire ops_wr_en_A;
	wire ops_wr_en_B;
	wire [4:0] ops_address_A;
	wire [4:0] ops_address_B;
	wire [2:0] ops_state;
	wire [4:0] ops_SRAM0_state;
	wire [3:0] ops_SRAM1_state;
	wire [1:0] ops_core_state;
	wire 		  ops_write_state;
	
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
			POLLING: begin
				if(poll_done)	next_state <= START;
				else				next_state <= POLLING;
			end
			START: begin
									next_state <= OPS;
			end
			OPS: begin
				if(ops_done)	next_state <= DONE;
				else				next_state <= OPS;
			end
			DONE: begin
									next_state <= POLLING;
			end
			default: 			next_state <= POLLING;
		endcase
	end
	
	
	assign ops_start 			= (state == START);
	
	assign o_address_A 		= ((state == POLLING) || (state == DONE))? 5'b0: ops_address_A;
	assign o_wr_en_A 			= (state == DONE)? 1'b1: 1'b0;
	assign o_write_data_A 	= 256'b0;
		
	assign o_address_B 		= ((state == POLLING) || (state == DONE))? 5'b0: ops_address_B;
	assign o_wr_en_B 			= ((state == POLLING) || (state == DONE))? 1'b0: ops_wr_en_B;
	
	assign poll_done 			= (state == POLLING) && ((i_read_data_A[31:0] == {{31{1'b0}}, 1'b1}));
	assign o_done				= (state == DONE);
	
	
	SpMV_ops_test ops_test(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_start(ops_start),
		
		.i_read_data_A(i_read_data_A),
		.i_read_data_B(i_read_data_B),
		
		.o_result(o_write_data_B),
		.o_wr_en_A(ops_wr_en_A),
		.o_wr_en_B(ops_wr_en_B),
		.o_address_A(ops_address_A),
		.o_address_B(ops_address_B),

		.o_state(ops_state),
		.o_SRAM0_state(ops_SRAM0_state),
		.o_SRAM1_state(ops_SRAM1_state),
		.o_write_state(ops_write_state),

		.o_done(ops_done)
	);      

endmodule
