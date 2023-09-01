module SpMV_comparator(

	input				i_clk,
	input				i_rstn,
	
	input [7:0]			count,
	input [135:0]		row_ptr, // 8-bit for 17 element

	output reg [3:0]	reg_addr
);

	integer i;	

always @(posedge i_clk, negedge i_rstn) begin
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

				
