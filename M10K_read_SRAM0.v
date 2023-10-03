`timescale 1ns / 1ps

module M10K_read_SRAM0(
	
	input i_clk,
	input i_rstn,
	
	input i_read_reset,
	input i_read_start,
	
	input [7:0] 		i_count,
	
	input [255:0] 		i_read_data,
	
	output reg [4:0]  o_read_addr,
	output [255:0] 	o_in_vector,
	output [15:0] 		o_mat_vector,
	output [4:0] 		o_state,
	output				o_done
	);
		
	parameter READ_IV	= 5'd0;
	parameter READ1 	= 5'd1;
	parameter READ2 	= 5'd2;
	parameter READ3 	= 5'd3;
	parameter READ4 	= 5'd4;
	parameter READ5 	= 5'd5;
	parameter READ6 	= 5'd6;
	parameter READ7 	= 5'd7;
	parameter READ8 	= 5'd8;
	parameter READ9 	= 5'd9;
	parameter READ10 	= 5'd10;
	parameter READ11 	= 5'd11;
	parameter READ12 	= 5'd12;
	parameter READ13 	= 5'd13;
	parameter READ14 	= 5'd14;
	parameter READ15 	= 5'd15;
	parameter READ16 	= 5'd16;
	parameter WAIT		= 5'd17;
	parameter DONE		= 5'd18;
	parameter IDLE  	= 5'd31;
	
	parameter OFFSET  = 4'd15;

	//////// Buffer //////////
	reg [255:0] 	buffer_in_vector;
	reg [255:0]     buffer_mat_vector[0:15];

	reg [4:0] state;
	reg [4:0] next_state;
	
	assign o_state = state;
	
	// Output
	assign o_in_vector 	= buffer_in_vector;
	assign o_mat_vector 	= (i_count[7:4] == 4'b0000)? buffer_mat_vector[0][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b0001)? buffer_mat_vector[1][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b0010)? buffer_mat_vector[2][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b0011)? buffer_mat_vector[3][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b0100)? buffer_mat_vector[4][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b0101)? buffer_mat_vector[5][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b0110)? buffer_mat_vector[6][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b0111)? buffer_mat_vector[7][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b1000)? buffer_mat_vector[8][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b1001)? buffer_mat_vector[9][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b1010)? buffer_mat_vector[10][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b1011)? buffer_mat_vector[11][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b1100)? buffer_mat_vector[12][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b1101)? buffer_mat_vector[13][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b1110)? buffer_mat_vector[14][(i_count%16)*16 +: 16]:
								  (i_count[7:4] == 4'b1111)? buffer_mat_vector[15][(i_count%16)*16 +: 16]: 16'b0;
	
	assign o_done = (state == DONE);
	
	//Signal Declaration
	wire read_done;
	
   // Current State Register
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) state <= IDLE;
		else			state <= next_state;
	end
	
	// Next State Logic
	always @(*) begin
		case(state)
			IDLE: begin
				if(i_read_start)		next_state <= READ_IV;
				else						next_state <= IDLE;
			end
			READ_IV: begin
				if(read_done)			next_state <= DONE;
				else						next_state <= READ1;
			end
			READ1: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ2;
			end
			READ2: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ3;
			end
			READ3: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ4;
			end
			READ4: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ5;
			end
			READ5: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ6;
			end
			READ6: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ7;
			end
			READ7: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ8;
			end
			READ8: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ9;
			end
			READ9: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ10;
			end
			READ10: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ11;
			end
			READ11: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ12;
			end
			READ12: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ13;
			end
			READ13: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ14;
			end
			READ14: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ15;
			end
			READ15: begin
				if(read_done)    		next_state <= DONE;
				else						next_state <= READ16;
			end
			READ16: begin
											next_state <= WAIT;
			end
			WAIT: begin
											next_state <= DONE;
			end
			DONE: begin
				if(i_read_reset)		next_state <= IDLE;
				else						next_state <= DONE;
			end
			default: begin
											next_state <= IDLE;
			end								
		endcase
	end
	
	// Address
	always @(*) begin
		case(state)
			IDLE: begin
				o_read_addr <= READ_IV + OFFSET;
			end
			READ_IV: begin
				o_read_addr <= READ_IV + OFFSET;
			end
			READ1: begin
				o_read_addr <= READ1 + OFFSET;
			end
			READ2: begin
				o_read_addr <= READ2 + OFFSET;
			end
			READ3: begin
				o_read_addr <= READ3 + OFFSET;
			end
			READ4: begin
				o_read_addr <= READ4 + OFFSET;
			end
			READ5: begin
				o_read_addr <= READ5 + OFFSET;
			end
			READ6: begin
				o_read_addr <= READ6 + OFFSET;
			end
			READ7: begin
				o_read_addr <= READ7 + OFFSET;
			end
			READ8: begin
				o_read_addr <= READ8 + OFFSET;
			end
			READ9: begin
				o_read_addr <= READ9 + OFFSET;
			end
			READ10: begin
				o_read_addr <= READ10 + OFFSET;
			end
			READ11: begin
				o_read_addr <= READ11 + OFFSET;
			end
			READ12: begin
				o_read_addr <= READ12 + OFFSET;
			end
			READ13: begin
				o_read_addr <= READ13 + OFFSET;
			end
			READ14: begin
				o_read_addr <= READ14 + OFFSET;
			end
			READ15: begin
				o_read_addr <= READ15 + OFFSET;
			end
			READ16: begin
				o_read_addr <= READ16 + OFFSET;
			end
			WAIT: begin
				o_read_addr <= READ_IV + OFFSET;
			end
			DONE: begin
				o_read_addr <= READ_IV + OFFSET;
			end
			default: begin
				o_read_addr <= READ_IV + OFFSET;
			end
		endcase
	end
	
	// DATA transfer SRMA0 to Input Vector Buffer & Value Buffer
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			buffer_in_vector				<= 256'b0;
			buffer_mat_vector[0]			<= 256'b0;
			buffer_mat_vector[1]			<= 256'b0;
			buffer_mat_vector[2]			<= 256'b0;
			buffer_mat_vector[3]			<= 256'b0;
			buffer_mat_vector[4]			<= 256'b0;
			buffer_mat_vector[5]			<= 256'b0;
			buffer_mat_vector[6]			<= 256'b0;
			buffer_mat_vector[7]			<= 256'b0;
			buffer_mat_vector[8]			<= 256'b0;
			buffer_mat_vector[9]			<= 256'b0;
			buffer_mat_vector[10]		<= 256'b0;
			buffer_mat_vector[11]		<= 256'b0;
			buffer_mat_vector[12]		<= 256'b0;
			buffer_mat_vector[13]		<= 256'b0;
			buffer_mat_vector[14]		<= 256'b0;
			buffer_mat_vector[15]		<= 256'b0;
		end else begin
			case(state)
				IDLE: begin
					buffer_in_vector				<= 256'b0;
					buffer_mat_vector[0]			<= 256'b0;
					buffer_mat_vector[1]			<= 256'b0;
					buffer_mat_vector[2]			<= 256'b0;
					buffer_mat_vector[3]			<= 256'b0;
					buffer_mat_vector[4]			<= 256'b0;
					buffer_mat_vector[5]			<= 256'b0;
					buffer_mat_vector[6]			<= 256'b0;
					buffer_mat_vector[7]			<= 256'b0;
					buffer_mat_vector[8]			<= 256'b0;
					buffer_mat_vector[9]			<= 256'b0;
					buffer_mat_vector[10]		<= 256'b0;
					buffer_mat_vector[11]		<= 256'b0;
					buffer_mat_vector[12]		<= 256'b0;
					buffer_mat_vector[13]		<= 256'b0;
					buffer_mat_vector[14]		<= 256'b0;
					buffer_mat_vector[15]		<= 256'b0;
				end
				READ_IV: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ1: begin
					buffer_in_vector				<= i_read_data				;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ2: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= i_read_data				;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ3: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= i_read_data				;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ4: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= i_read_data				;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ5: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= i_read_data				;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ6: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= i_read_data				;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ7: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= i_read_data				;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ8: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= i_read_data				;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ9: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= i_read_data				;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ10: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= i_read_data				;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ11: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= i_read_data				;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ12: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= i_read_data				;
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ13: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= i_read_data				;
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ14: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= i_read_data				;
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ15: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= i_read_data				;
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				READ16: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= i_read_data				;
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				WAIT: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= i_read_data				;
				end
				DONE: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
				default: begin
					buffer_in_vector				<= buffer_in_vector		;
					buffer_mat_vector[0]			<= buffer_mat_vector[0]	;
					buffer_mat_vector[1]			<= buffer_mat_vector[1]	;
					buffer_mat_vector[2]			<= buffer_mat_vector[2]	;
					buffer_mat_vector[3]			<= buffer_mat_vector[3]	;
					buffer_mat_vector[4]			<= buffer_mat_vector[4]	;
					buffer_mat_vector[5]			<= buffer_mat_vector[5]	;
					buffer_mat_vector[6]			<= buffer_mat_vector[6]	;
					buffer_mat_vector[7]			<= buffer_mat_vector[7]	;
					buffer_mat_vector[8]			<= buffer_mat_vector[8]	;
					buffer_mat_vector[9]			<= buffer_mat_vector[9]	;
					buffer_mat_vector[10]		<= buffer_mat_vector[10];
					buffer_mat_vector[11]		<= buffer_mat_vector[11];
					buffer_mat_vector[12]		<= buffer_mat_vector[12];
					buffer_mat_vector[13]		<= buffer_mat_vector[13];
					buffer_mat_vector[14]		<= buffer_mat_vector[14];
					buffer_mat_vector[15]		<= buffer_mat_vector[15];
				end
			endcase
		end
	end

endmodule
