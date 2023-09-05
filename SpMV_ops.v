`timescale 1ns / 1ns

module SpMV_ops(

   input         i_clk,
   input         i_rstn,
   input         i_start,

   input [15:0]   i_read_data_A,
   input [15:0]   i_read_data_B,


   output [255:0]   o_register
);

   parameter IDLE   = 3'b000;
   parameter READ  = 3'b001;
   parameter CORE   = 3'b010;
   parameter WRITE = 3'b011;
   parameter DONE   = 3'b100;

    reg [2:0] state;
    reg [2:0] next_state;
    
   always @(posedge i_clk, negedge i_rstn) begin
      if(!i_rstn)   state <= IDLE;
      else      state <= next_state;
   end
   
   // Signal Declaration
   wire read_done, core_done, write_done;
   
   always @(*) begin
      case(state)
         IDLE: begin
            if(i_start)   next_state <= READ;
            else      next_state <= IDLE;
         end
         READ: begin
            if(read_done)   next_state <= CORE;
            else         next_state <= READ;
         end
         CORE: begin
            if(core_done)   next_state <= WRITE;
            else         next_state <= CORE;
         end
         WRITE: begin
            if(write_done)   next_state <= DONE;
            else         next_state <= WRITE;
         end
         DONE: begin
                        next_state <= IDLE;
         end
         default:         next_state <= IDLE;
      endcase
   end
   
   M10K_read_in_vector_buffer(
      .i_clk(i_clk),
      .i_rstn(i_rstn),
      .i_read_data(i_read_data_A),
      
      .o_read_addr(o_addr_in_vector),
      .o_in_vector(o_in_vector),
      .o_state(o_in_vector_read_done)
      );
   
   M10K_read_value_buffer(
      .i_clk(i_clk),
      .i_rstn(i_rstn),
      .i_read_data(i_read_data_A),
      
      .o_read_addr(o_addr_mat_vector),
      .o_mat_vector(o_mat_vector),
      .o_state(o_mat_vector_read_done)
      );
      
    M10K_read_col_index_buffer(
		.i_clk(i_clk),
        .i_rstn(i_rstn),
        .i_read_data(i_read_data_B),
        
		.o_read_addr(o_addr_col_idx),
		.o_in_vector(o_col_idx),
		.o_state(o_col_idx_read_done)
      );
      
    M10K_read_row_ptr_buffer(
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .i_read_data(i_read_data_B),
        
		.o_read_addr(o_addr_row_ptr),
		.o_in_vector(o_row_ptr),
		.o_state(o_row_ptr_read_done)
      );
      
      
   
   
   
endmodule
