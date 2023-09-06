
module M10K_read_SRAM0(
	
	input i_clk,
	input i_rstn,
	input i_read_start_IV,
	input i_read_start_MV,
	input count,
	
	input [255:0] i_read_data,

	output [4:0] o_read_addr,
	output [15:0] o_in_vector,
	output [15:0] o_mat_vector,
	output o_state,
	);
	
	parameter IDLE		= 2'b00;
	parameter IN_READ	= 2'b01;
	parameter MAT_READ	= 2'b10;
	parameter DONE		= 2'b11;


	//Signal Declaration
	reg [255:0] buffer_in_vector;
	reg [255:0] buffer_mat_vector;
	wire i_read_start_IV, i_read_start_MV;
	wire read_IV_fin, read_MV_fin;

	reg [1:0] state;
	reg [1:0] next_state;

	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) state <= IDLE;
		else		state <= next_state;
	end
	
	always @(*) begin
		case(state)
			IDLE: begin
				if(i_read_start_IV)			next_state <= IN_READ;
				else if(i_read_start_MV)	next_state <= MAT_READ;
				else						next_state <= IDLE;
			end
			IN_READ: begin
				if(read_IV_fin)				next_state <= MAT_READ;
				else						next_state <= IN_READ;
			end
			MAT_READ: begin
				if(read_MV_fin)				next_state <= DONE;
				else						next_state <= MAT_READ;
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
					buffer_in_vector		<= 256'b0;
					buffer_mat_vector		<= 256'b0;
				end
				IN_READ: begin
					buffer_in_vector		<= i_read_data;
				end
				MAT_READ: begin
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
	assign o_mat_vector = buffer_mat_vector[(count%16)*16 +: 16];


	











endmodule

