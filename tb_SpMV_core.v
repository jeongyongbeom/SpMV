`timescale 1ns / 1ps

module tb_SpMV_core();

	reg			i_clk;
	reg			i_rstn;

	reg			i_start;

	reg	[15:0]	i_read_data_A;
	reg [15:0]	i_read_data_B;

	reg [7:0]	count;
	reg [135:0] row_ptr;

	wire 		 o_done;
	wire [255:0] o_register;

	SpMV_core uut(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_start(i_start),
		.i_read_data_A(i_read_data_A),
		.i_read_data_B(i_read_data_B),
		.count(count),
		.row_ptr(row_ptr),
	
		.o_done(o_done),
		.o_register(o_register)
	);

	initial begin
		i_clk = 1'b0; i_rstn = 1'b0; i_start = 1'b0;
		#30 i_rstn = 1'b1;
		#17 i_start = 1'b1;
	end

	always begin
		#5 i_clk = ~i_clk;
	end

	initial begin
		i_read_data_A = 0;
		i_read_data_B = 0;
		#74	// A = 16, B = 2
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;
		#74
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;
		#74
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;
		#74
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;
		#74
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;
		#74
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;
		#74
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;
		#74
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;
		#74
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;
		#74
		i_read_data_A = 16'b0_10011_0000000000;
		i_read_data_B = 16'b0_10000_0000000000;

		#400
		$finish;

	end


	initial begin
		row_ptr = 0;
		#74 row_ptr = 136'h0a_09_09_09_07_07_07_07_04_04_04_03_02_02_01_00_00;
	end
	
	initial begin
		count = 0;
		#74 count = 1;
		#74 count = 2;
		#74 count = 3;
		#74 count = 4;
		#74 count = 5;
		#74 count = 6;
		#74 count = 7;
		#74 count = 8;
		#74 count = 9;
		#74 count = 10;
	end

	initial begin
		$dumpfile("tb_SpMV_core.vcd");
		$dumpvars(0,tb_SpMV_core);
	end


endmodule


		
