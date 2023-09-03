`timescale 1ns / 1ns

module SpMV_core(

	input				i_clk,
	input				i_rstn,

	input				i_start,

	input [15:0]		i_read_data_A,
	input [15:0]		i_read_data_B,

	input [7:0]			count,
	input [135:0]		row_ptr,
	
	output  			o_done,
	output [255:0]		o_register
);	
	parameter IDLE		= 3'b000;
	parameter MUL 		= 3'b001;
	parameter REG_READ  = 3'b010;
	parameter ADD		= 3'b011;
	parameter REG_WRITE	= 3'b100;

	integer i;

	genvar k;
	generate
		for(k=0; k<16; k=k+1) begin: OUTPUT_SORTING
			assign o_register[16*k +: 16] = register[k];
		end
	endgenerate
	
	
	reg [2:0] current_state;
	reg [2:0] next_state;

	// Current State Register
	always @(posedge i_clk, posedge i_rstn) begin
		if(!i_rstn) current_state <= IDLE;
		else		current_state <= next_state;
	end

	// Next State Logic
	always @(*) begin
		case(current_state)
			IDLE: begin
				if(i_start) next_state <= MUL;
				else		next_state <= IDLE;
			end
			MUL: begin
							next_state <= REG_READ;
			end
			REG_READ: begin
							next_state <= ADD;
			end
			ADD: begin
							next_state <= REG_WRITE;
			end
			REG_WRITE: begin
				if(o_done)	next_state <= IDLE;
				else		next_state <= MUL;
			end
			default: 		next_state <= IDLE;
		endcase
	end
	
	assign o_done = ((count != 8'b0)&&(count[3:0] == 4'b0)) ? 1'b1: 1'b0;
	
	reg [15:0] register [0:15];
	reg [3:0] reg_addr;

	wire [15:0] mul_result;
	wire [15:0] reg_result = (current_state == REG_READ)? register[reg_addr]: 16'b0;

	wire [15:0] out;

	SpMV_fp16_mul multiplication(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.vector(i_read_data_A),
		.value(i_read_data_B),

		.result(mul_result)
	);
	
	SpMV_fp16_add addition(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.mul_result(mul_result),
		.reg_result(reg_result),

		.result(out)
	);

	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			for(i=0; i<16; i=i+1) begin
				register[i] <= 16'b0;
			end
		end else begin
			if(current_state == REG_WRITE)  register[reg_addr] <= out;
			else							register[reg_addr] <= register[reg_addr];
		end
	end

	// To get register address using comparator
	always @(*) begin
		if(!i_rstn) reg_addr <= 4'b0;
		else begin
			for(i=0; i<16; i=i+1) begin
				if((row_ptr[i*8 +: 8] < count) && (count <= row_ptr[(i+1)*8 +: 8])) begin
					reg_addr <= i;
				end
			end
		end
	end


	endmodule

