
module SpMV_ops(

	input         i_clk,
	input         i_rstn,
	input         i_start,

    input [255:0]   i_read_data_A,
    input [255:0]   i_read_data_B,

	output reg [255:0]   o_result,
	output                 o_wr_en_A,
	output                 o_wr_en_B,
	output [4:0]           o_address_A,
	output [4:0]           o_address_B,
	
	output [2:0]           o_state,
	output [1:0]           o_SRAM0_state,
	output [1:0]           o_core_state,
	output                 o_write_state,
	
    output                 o_done
);
    
    // Parameter for SpMV_ops Module
	parameter IDLE	= 3'b000;
	parameter READ  = 3'b001;
	parameter CORE	= 3'b010;
	parameter WRITE = 3'b011;
	parameter DONE	= 3'b100;
	
	// Parameter for SpMV_core Module
	parameter CORE_IDLE  = 3'b000;
	parameter CORE_WRITE = 3'b100;
	
	// Parameter for M10K_read_SRAM0 Module
	parameter S0_IDLE      = 2'b00;
	parameter S0_IV_READ   = 2'b01;
	parameter S0_MV_READ   = 2'b10;
	parameter S0_READ_DONE = 2'b11;
	
	// Parameter for M10K_read_SRAM0 Module
	parameter S1_READ_DONE = 2'b11;
    
	reg [2:0] state;
    reg [2:0] next_state;
    
   always @(posedge i_clk, negedge i_rstn) begin
      if(!i_rstn)   state <= IDLE;
      else			state <= next_state;
   end
   
   // Signal Declaration
   wire read_done, core_done, write_done;
   wire read_A_done, read_B_done;
   wire core_start;
   wire core_fin;
   wire core_16;
   
   wire [2:0] core_state;
   wire [1:0] SRAM0_state;
   wire [1:0] SRAM1_state;
   
   reg [7:0] count;
   
   wire read_start_IV;
   wire read_start_MV;
   wire [255:0] register;
   wire write_en;
   wire [135:0] row_ptr;
   
   wire [4:0] address_A, read_address_B;
   
   assign o_SRAM0_state = SRAM0_state;
   assign o_SRAM1_state = SRAM1_state;
   assign o_core_state = core_state;
   assign o_write_state = (write_en)? 1'b1: 1'b0;
   
   assign write_en = (state == WRITE);
  
   assign read_start_IV = (state == IDLE) && (next_state == READ) && (count == 8'b0);
   assign read_start_MV = (((state == IDLE) && (next_state == READ) && (count[3:0] == 4'b0000)) | ((state == READ) && (SRAM0_state == S0_IV_READ)))? 1'b1: 1'b0;
   assign read_start_RP = (state == IDLE) && (next_state == READ);
   assign read_start_CI = (state == IDLE) && (next_state == READ) && (count[5:0] == 6'b0);
   
   assign read_A_done = (state == READ) && (SRAM0_state == S0_READ_DONE);
   assign read_B_done = (state == READ) && (SRAM1_state == S1_READ_DONE);
   assign read_done = (read_A_done && read_B_done)? 1'b1: 1'b0;
   
   assign core_start = (state == READ) && (next_state == CORE);
   assign core_done = (state == CORE) && (core_state == CORE_WRITE);
   assign core_fin = (count == row_ptr[135:128])? 1'b1: 1'b0;
   assign core_16 = (count != 8'b0) && (count[3:0] == 4'b0000);
   
   assign o_address_A = address_A;
   assign o_address_B = (write_en)? 16: read_address_B;
   
   assign o_wr_en_A = 1'b0;
   assign o_wr_en_B = (write_en == 1'b1)? 1'b1: 1'b0;
   
  

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
            if(core_16)       next_state <= READ;
            else if(core_fin) next_state <= WRITE;
            else              next_state <= CORE;
         end
         WRITE: begin
                   			next_state <= DONE;
         end
         DONE: begin
							next_state <= IDLE;
         end
         default:			next_state <= IDLE;
      endcase
   end

	// Decoder for Input Vector
	wire [3:0] o_col_idx;
	
	wire [15:0] mat_vector;
	wire [255:0] o_in_vector;
	wire [15:0] in_vector;
	assign in_vector = o_in_vector[o_col_idx*16 +: 16];
    
	// Counter
	always @(posedge i_clk, negedge i_rstn) begin
		if(!i_rstn) count <= 256'b0;
		else if(core_done) begin
			count <= count + 1'b1;
		end else begin
			count <= count;
		end
	end		

   M10K_read_SRAM0 S0(
      .i_clk(i_clk),
      .i_rstn(i_rstn),
	  .i_read_start_IV(read_start_IV),
	  .i_read_start_MV(read_start_MV),
	  .i_count(count),
	
      .i_read_data(i_read_data_A),
      
      .o_read_addr(address_A),
      .o_in_vector(o_in_vector),
	  .o_mat_vector(mat_vector),
      .o_state(SRAM0_state)
      );
   
    M10K_read_SRAM1 S1(
      .i_clk(i_clk),
      .i_rstn(i_rstn),
	  .i_read_start_RP(read_start_RP),
	  .i_read_start_CI(read_start_CI),
	  .i_count(count),
	
      .i_read_data(i_read_data_B),
      
      .o_read_addr(read_address_B),
      .o_row_ptr(row_ptr),
	  .o_col_idx(o_col_idx),
      .o_state(SRAM1_state)
      );
	
	SpMV_core core(
		.i_clk(i_clk),
		.i_rstn(i_rstn),
		.i_start(core_start),
		
		.i_read_data_A(mat_vector),
		.i_read_data_B(in_vector),
		.count(count),
		.row_ptr(row_ptr),
		
		.o_state(core_state),
		.o_register(register)
	);

    always @(posedge i_clk, negedge i_rstn) begin
        if(!i_rstn)      o_result <= 256'b0;
        else begin
            if(write_en) o_result <= register;
            else         o_result <= o_result;
        end
    end
	 
	endmodule
