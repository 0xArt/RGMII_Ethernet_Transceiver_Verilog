`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2021 10:22:52 AM
// Design Name: 
// Module Name: lfsr_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lfsr_wrapper
  ( 
    input wire i_clk
  , input wire i_rst_seed
  , input wire i_enable
  , input wire [31:0] i_seed_data  // Optional Seed Value
  , output reg [7:0] o_lfsr_data = 0
  );

	reg [2:0] state;
	
	
	localparam S_IDLE 	       	         = 3'd0;
    localparam S_RST_SEED        	     = 3'd1;
    localparam S_TRANSMIT_COUNT          = 3'd2;
    localparam S_TRANSMIT_LFSR		     = 3'd3;
	
  // Purpose: Load up LFSR with Seed if Data Valid (DV) pulse is detected.
  // Othewise just run LFSR when enabled.
  
  reg [31:0] packet_count = 32'h01234567;
  reg [31:0] word_32b_out;
  
  reg [1:0] byte_count = 0;
  
  wire [31:0] lfsr_32b_data;
  reg en_lfsr = 0;
  always @(posedge i_clk) begin
    case(state)
		S_IDLE: begin
		  en_lfsr <= 1'b0; //Increment LFSR by one word
			if(i_rst_seed) begin
				packet_count <= 32'h01234567;
			end else begin
				if(i_enable) begin
					o_lfsr_data <= word_32b_out[31:24];
					word_32b_out <= {word_32b_out[23:0],8'd0};
					state <= S_TRANSMIT_COUNT;
					byte_count <= 0;
				end else begin
					word_32b_out <= packet_count;
				end
			end
		end
		S_RST_SEED: begin
			
		end
		S_TRANSMIT_COUNT: begin
			if(i_enable) begin
				if(byte_count != 2'd2) begin 
					byte_count <= byte_count + 1'b1;
					word_32b_out <= {word_32b_out[23:0],8'd0};
				end else begin	
					state <= S_TRANSMIT_LFSR;
					en_lfsr <= 1'b1; //Increment LFSR by one word
					byte_count <= 0;
					word_32b_out <= lfsr_32b_data;
				end
				o_lfsr_data <= word_32b_out[31:24];
				
			end else 
				state <= S_IDLE;
		end
		S_TRANSMIT_LFSR: begin
			if(i_enable) begin
				if(byte_count != 2'd3) begin 
					byte_count <= byte_count + 1'b1;
					en_lfsr <= 1'b0;
					word_32b_out <= {word_32b_out[23:0],8'd0};
				end else begin	
					byte_count <= 0;
					en_lfsr <= 1'b1; //Increment LFSR by one word
					word_32b_out <= lfsr_32b_data;
				end
				o_lfsr_data <= word_32b_out[31:24];
				
			end else begin
				packet_count <= packet_count + 1'b1;
				en_lfsr <= 1'b0; //Increment LFSR by one word
				state <= S_IDLE;
			end
		end
		default: begin
			state <= S_IDLE;
		end
	endcase
  end
  
 
 lfsr #(.NUM_BITS(32)) i_lfsr
  ( .i_clk      (i_clk)
  , .i_rst_seed    (i_rst_seed)
  , .i_enable   (en_lfsr)
  , .i_seed_data(i_seed_data)
  , .o_lfsr_data(lfsr_32b_data)
  );
 
endmodule
