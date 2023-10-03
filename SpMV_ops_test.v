`timescale 1ns / 1ps

module SpMV_ops_test(
	input         	i_clk,
	input         	i_rstn,
	input         	i_start,

   input [255:0]  i_read_data_A,
   input [255:0]  i_read_data_B,

	output [255:0]     o_result,
	
	output             o_wr_en_A,
	output             o_wr_en_B,
	output [4:0]       o_address_A,
	output [4:0]       o_address_B,
	
	output [2:0]       o_state,
	output [4:0]       o_SRAM0_state,
	output [3:0]       o_SRAM1_state,
	output             o_write_state,
	
   output             o_done
);

   // Parameter for SpMV_ops Module
	parameter IDLE		= 3'b000;
	parameter READ 	   = 3'b001;
	parameter CORE		= 3'b010;
	parameter WRITE 	= 3'b011;
	parameter DONE		= 3'b100;
	
	// Parameter for M10K_read_SRAM0 Module
	parameter S0_READ_DONE = 5'd18;
	
	// Parameter for M10K_read_SRAM1 Module
	parameter S1_READ_DONE = 4'd6;
	
	// Parameter for Core Module
	parameter CORE_DONE    = 3'b100;
	parameter CORE_WRITE   = 3'b011;
	
	wire [4:0] 		ops_address_A;
	wire [255:0] 	all_in_vector;
	wire [15:0] 	mat_value;
	wire [4:0]		s0_state;
	wire 				s0_done;
	
	wire [4:0] 		ops_address_B;
	wire [255:0] 	row_ptr;
	wire [3:0] 		col_idx;
	wire [3:0]		s1_state;
	wire 				s1_done;
	
	wire read_reset;
	wire read_start;
	wire read_done;	
	
	wire core_start;
	wire core_done;
	wire [2:0] core_state;
	
	reg [7:0] count;
	
	reg [3:0] state;
	reg [3:0] next_state;
	
	wire [255:0] register;
	
	// Current State Register
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end	
	end
	
	assign o_state = state;
	
   always @(*) begin
      case(state)
         IDLE: begin
            if(i_start)		next_state <= READ;
            else				next_state <= IDLE;
         end
         READ: begin
            if(read_done)  next_state <= CORE;
            else				next_state <= READ;
         end
		CORE: begin
			if(core_done)	   next_state <= WRITE;
			else					next_state <= CORE;
	    end
        WRITE: begin
                   			next_state <= DONE;
         end
         DONE: begin
									next_state <= IDLE;
         end
         default:				next_state <= IDLE;
      endcase
   end

	assign o_result		 		= register;

	assign o_wr_en_A 				= 1'b0;
	assign o_wr_en_B 				= (state == WRITE);
	
	assign o_address_A			= ops_address_A;
	assign o_address_B			= (state == WRITE) ? 5'b10000 : ops_address_B;
	
	assign o_SRAM0_state			= s0_state;
	assign o_SRAM1_state			= s1_state;
	assign o_write_state			= (state == WRITE);
	
	assign o_done					= (state == DONE);
	
	assign read_reset = (state == DONE);
	assign read_start = (state == IDLE) && (next_state == READ);
	assign read_done  = (state == READ) && (s0_state == S0_READ_DONE) && (s1_state == S1_READ_DONE);
	
	assign core_start = (state == READ) && (next_state == CORE) && (core_state != CORE_DONE);
	assign core_done  = (state == CORE) && (count == row_ptr[135:128]);
	assign core_write = (core_state == CORE_WRITE);
	
	// Counter
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) count <= 256'b0;
		else if(core_write) begin
			count <= count + 1'b1;
		end else begin
			count <= count;
		end
	end			
	
	// Decoder for Input Vector
	wire [15:0] in_vector;
	assign in_vector = all_in_vector[col_idx*16 +: 16];
	
	
	M10K_read_SRAM0 S0(
     .i_clk(i_clk),
     .i_rstn(i_rstn),
	  
	  .i_read_reset(read_reset),
	  .i_read_start(read_start),
	  .i_count(count),
	
     .i_read_data(i_read_data_A),
      
     .o_read_addr(ops_address_A),
     .o_in_vector(all_in_vector),
	  .o_mat_vector(mat_value),
     .o_state(s0_state),
	  .o_done(s0_done)
     );
	  
	M10K_read_SRAM1 S1(
     .i_clk(i_clk),
     .i_rstn(i_rstn),
	  
	  .i_read_reset(read_reset),
	  .i_read_start(read_start),
	  .i_count(count),
	
     .i_read_data(i_read_data_B),
      
     .o_read_addr(ops_address_B),
     .o_row_ptr(row_ptr),
	  .o_col_idx(col_idx),
     .o_state(s1_state),
	  .o_done(s1_done)
     );
	  
	SpMV_core core(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_start(core_start),
		
		.mat_value(mat_value),
		.in_vector(in_vector),
		.count(count),
		.row_ptr(row_ptr),
		
		.o_state(core_state),
		.o_register(register)
	);
	  
endmodule
