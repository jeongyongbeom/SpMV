`timescale 1ns / 1ps


module SpMV_core(

	input				i_clk,
	input				i_rstn,
	input				i_start,

	input [15:0]		i_read_data_A,
	input [15:0]		i_read_data_B,
	input [7:0]			count,
	input [135:0]		row_ptr,
	
	output [2:0]		o_state,
	output [255:0]		o_register
);

    parameter IDLE  = 3'b000;
    parameter LOAD  = 3'b001;
    parameter MUL   = 3'b010;
    parameter ADD   = 3'b011;
    parameter WRITE = 3'b100;
    
    reg [2:0] state; 
    reg [2:0] next_state;
    
 	// Current State Register
	always @(posedge i_clk or negedge i_rstn) begin
		if(!i_rstn)     state <= IDLE;
		else			state <= next_state;
	end
   
   // Signal Declaration
	wire w_finish = ((state == WRITE) && ((row_ptr[135:128]-1 == count) | ((count != 8'b0) && (count[3:0] == 4'b0)))) ? 1'b1: 1'b0;
	assign o_state = state;
   
   wire [15:0] mat_vector, in_vector;
   
	// Next State Logic
	always @(*) begin
		case(state)
			IDLE: begin
				if(i_start)      next_state <= LOAD;
				else		     next_state <= IDLE;
			end
			LOAD: begin
			                     next_state <= MUL;
			end
			MUL: begin
			                     next_state <= ADD;
			end
			ADD: begin
			                     next_state <= WRITE;
			end
			WRITE: begin
			    if(w_finish)     next_state <= IDLE;
				else		     next_state <= LOAD;
			end
			default: 		     next_state <= IDLE;
		endcase
	end

	wire [15:0] mul_result;
	wire [15:0] reg_result;
	
	reg [15:0] register [0:15];
	reg [3:0] reg_addr;
	wire [15:0] out;
	integer i;
	
	assign mat_vector = (state == LOAD)? i_read_data_A: 16'b0;
	assign in_vector = (state == LOAD)? i_read_data_B: 16'b0;
	assign reg_result = register[reg_addr];
	
	genvar k;
	generate
		for(k=0; k<16; k=k+1) begin: OUTPUT_SORTING
			assign o_register[16*k +: 16] = register[k];
		end
	endgenerate
	
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			for(i=0; i<16; i=i+1) begin
				register[i] <= 16'b0;
			end
		end else begin
			if(state == ADD) register[reg_addr] <= out;
			else			   register[reg_addr] <= register[reg_addr];
		end
	end
	
	// To get register address using comparator
	always @(*) begin
		if(!i_rstn) reg_addr <= 4'b0;
		else begin
			for(i=0; i<16; i=i+1) begin
				if((row_ptr[i*8 +: 8] < count+1) && (count+1 <= row_ptr[(i+1)*8 +: 8])) begin
					reg_addr <= i;
				end
			end
		end
	end
	
	SpMV_fp16_mul multiplication(
	    .i_clk(i_clk),
		.i_rstn(i_rstn),
		.vector(mat_vector),
		.value(in_vector),

		.result(mul_result)
	);
	
	SpMV_fp16_add addition(
	    .i_clk(i_clk),
		.i_rstn(i_rstn),
		.mul_result(mul_result),
		.reg_result(reg_result),

		.result(out)
	);

endmodule
