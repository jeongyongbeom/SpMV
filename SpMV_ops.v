
module SpMV_ops(

	input         i_clk,
	input         i_rstn,
	input         i_start,

    input [15:0]   i_read_data_A,
    input [15:0]   i_read_data_B,


	output [255:0]   o_register
);

	parameter IDLE	= 3'b000;
	parameter READ  = 3'b001;
	parameter CORE	= 3'b010;
	parameter WRITE = 3'b011;
	parameter DONE	= 3'b100;
    
	reg [2:0] state;
    reg [2:0] next_state;
    
   always @(posedge i_clk, negedge i_rstn) begin
      if(!i_rstn)   state <= IDLE;
      else			state <= next_state;
   end
   
   // Signal Declaration
   wire read_done, core_done, write_done;
   wire read_A_done, read_B_done;
   assign read_done = (read_A_done && read_B_done)? 1'b1: 1'b0;
   

   wire core_fin;
   wire [135:0] row_ptr;

   assign core_fin = (count == row_ptr[135:128])? 1'b1: 1'b0;

   always @(*) begin
      case(state)
         IDLE: begin
            if(i_start)		next_state <= READ;
            else			next_state <= IDLE;
         end
         READ: begin
            if(read_done)   next_state <= CORE;
            else			next_state <= READ;
         end
         CORE: begin
			 if(core_done) begin
				 if(core_fin)	next_state <= WRITE;
				 else			next_state <= READ;
			 end
			 else			next_state <= CORE;
         end
         WRITE: begin
            if(write_done)  next_state <= DONE;
            else			next_state <= WRITE;
         end
         DONE: begin
							next_state <= IDLE;
         end
         default:			next_state <= IDLE;
      endcase
   end


	// Decoder for Input Vector
	wire o_col_idx;
	
	wire [15:0] in_vector;
	assign in_vector = o_in_vector[o_col_idx[count*4 +: 4 ]*4 +: 4];

   M10K_read_SRAM0(
      .i_clk(i_clk),
      .i_rstn(i_rstn),
	  .i_read_start_IV(i_read_start_IV),
	  .i_read_start_MV(i_read_start_MV),
	  .count(count),
	
      .i_read_data(i_read_data_A),
      
      .o_read_addr(o_addr_A),
      .o_in_vector(o_in_vector),
	  .o_mat_vector(o_mat_vector),
      .o_state(o_state_buffer_A)
      );
   
    M10K_read_SRAM1(
      .i_clk(i_clk),
      .i_rstn(i_rstn),
	  .i_read_start_RP(i_read_start_RP),
	  .i_read_start_CI(i_read_start_CI),
	  .count(count),
	
      .i_read_data(i_read_data_B),
      
      .o_read_addr(o_addr_B),
      .o_row_ptr(o_row_ptr),
	  .o_col_idx(o_col_idx),
      .o_state(o_state_buffer_B)
      );
	
	SpMV_core(
		.i_clk(i_clk),
		.i_rstn(i_rstn),



		.count(count),
		.
     
        
	 
	endmodule
