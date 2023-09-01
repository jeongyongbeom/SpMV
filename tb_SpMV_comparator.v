`timescale 1ns / 1ps

module tb_SpMV_comparator();

	reg				i_clk;
	reg				i_rstn;

	reg [7:0]		count;
	reg [135:0]		row_ptr;

	wire [3:0]		reg_addr;


	SpMV_comparator uut(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.count(count),
		.row_ptr(row_ptr),

		.reg_addr(reg_addr)
	);

	initial begin
		i_clk = 1'b0; i_rstn = 1'b0;
		#30 i_rstn = 1'b1;
	end

	always begin
		#5 i_clk = ~i_clk;
	end

	initial begin
		row_ptr = 0;
		#74 row_ptr = 136'h0a_09_09_09_07_07_07_07_04_04_04_03_02_02_01_00_00;
		#10 count = 1;
		#10 count = 2;
		#10 count = 3;
		#10 count = 4;
		#10 count = 5;
		#10 count = 6;
		#10 count = 7;
		#10 count = 8;
		#10 count = 9;
		#10 count = 10;

		#400
		$finish;
	end

	initial begin
		$dumpfile("tb_SpMV_comparator.vcd");
		$dumpvars(0,tb_SpMV_comparator);
	end

	endmodule





