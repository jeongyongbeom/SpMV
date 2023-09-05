`timescale 1ns / 1ns

module SpMV_ops(

	input			i_clk,
	input			i_rstn,
	input			i_start,

	input [15:0]	i_read_data_A,
	input 

	input [15:0]	i_read_data_B,


	output [255:0]	o_register
);

	parameter IDLE	= 3'b000;
	parameter READ  = 3'b001;
	parameter CORE	= 3'b010;
	parameter WRITE = 3'b011;
	parameter DONE	= 3'b100;

	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn)	state <= IDLE;
		else		state <= next_state;
	end

	always @(*) begin
		case(state)
			IDLE: begin
				if(i_start)	next_state <= READ;
				else		next_state <= IDLE;
			end
			READ: begin
				if(read_done)	next_state <= CORE;
				else			next_state <= READ;
			end
			CORE: begin
				if(core_done)	next_state <= WRITE;
				else			next_state <= CORE;
			end
			WRITE: begin
				if(write_done)	next_state <= DONE;
				else			next_state <= WRITE;
			DONE: begin
								next_state <= IDLE;
			end
			default:			next_state <= IDLE;
		endcase
	end



	
