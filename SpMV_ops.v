`timescale 1ns / 1ns

module SpMV_ops(

	input			i_clk,
	input			i_rstn,

	input [15:0]	i_read_data_A,
	input [15:0]	i_read_data_B,

	input [7:0]		count,
	input [135:0]	row_ptr,

	output [255:0]	o_register
);
	
	reg [15:0] register [0:15];
	
	genvar k;

	generate
		for(k=0; k<16; k=k+1) begin: OUTPUT_SORTING
			assign o_register[16*k +: 16] = register[k];
		end
	endgenerate
			
	
	integer i;	

	reg [3:0] reg_addr;
	
	wire [15:0] mul_result;
	wire [15:0] reg_result = register[reg_addr];

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
			register[reg_addr] <= out;
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

