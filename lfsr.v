`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
// 
// Create Date: 02/04/2021 10:24:13 AM
// Design Name: 
// Module Name: lfsr
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
//  Original file from https://www.nandland.com/vhdl/modules/lfsr-linear-feedback-shift-register.html
// 
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
// Parameters:
// NUM_BITS - Set to the integer number of bits wide to create your LFSR.
//////////////////////////////////////////////////////////////////////////////////

module lfsr #(parameter NUM_BITS = 6'd32)
  ( 
    input wire                  i_clk,
    input wire                  i_rst_seed,
    input wire                  i_enable,
    input wire  [NUM_BITS-1:0]  i_seed_data, 
    output wire [NUM_BITS-1:0]  o_lfsr_data
  );
 
  reg [NUM_BITS-1:0] r_lfsr = 0;
  reg                r_xnor = 0;


  assign o_lfsr_data = r_lfsr;
 
  // Load up LFSR with seet if rst pulse is detected.
  // Otherwise just run LFSR when enabled.
  always @(posedge i_clk) begin
    if (i_rst_seed) begin
      r_lfsr <= i_seed_data;
    end
    else begin
      if (i_enable) begin
        r_lfsr <= {r_lfsr[NUM_BITS-2:0], r_xnor};
      end
    end
  end
 
  // Create Feedback Polynomials.  Based on Application Note:
  // http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
  always @(*)
    begin
      case (NUM_BITS)
        3: begin
          r_xnor = r_lfsr[2] ^~ r_lfsr[1];
        end
        4: begin
          r_xnor = r_lfsr[3] ^~ r_lfsr[2];
        end
        5: begin
          r_xnor = r_lfsr[4] ^~ r_lfsr[2];
        end
        6: begin
          r_xnor = r_lfsr[5] ^~ r_lfsr[4];
        end
        7: begin
          r_xnor = r_lfsr[6] ^~ r_lfsr[5];
        end
        8: begin
          r_xnor = r_lfsr[7] ^~ r_lfsr[5] ^~ r_lfsr[4] ^~ r_lfsr[3];
        end
        9: begin
          r_xnor = r_lfsr[8] ^~ r_lfsr[4];
        end
        10: begin
          r_xnor = r_lfsr[9] ^~ r_lfsr[6];
        end
        11: begin
          r_xnor = r_lfsr[10] ^~ r_lfsr[8];
        end
        12: begin
          r_xnor = r_lfsr[11] ^~ r_lfsr[5] ^~ r_lfsr[3] ^~ r_lfsr[0];
        end
        13: begin
          r_xnor = r_lfsr[12] ^~ r_lfsr[3] ^~ r_lfsr[2] ^~ r_lfsr[0];
        end
        14: begin
          r_xnor = r_lfsr[13] ^~ r_lfsr[4] ^~ r_lfsr[2] ^~ r_lfsr[0];
        end
        15: begin
          r_xnor = r_lfsr[14] ^~ r_lfsr[13];
        end
        16: begin
          r_xnor = r_lfsr[15] ^~ r_lfsr[14] ^~ r_lfsr[12] ^~ r_lfsr[3];
          end
        17: begin
          r_xnor = r_lfsr[16] ^~ r_lfsr[13];
        end
        18: begin
          r_xnor = r_lfsr[17] ^~ r_lfsr[10];
        end
        19: begin
          r_xnor = r_lfsr[18] ^~ r_lfsr[5] ^~ r_lfsr[1] ^~ r_lfsr[0];
        end
        20: begin
          r_xnor = r_lfsr[19] ^~ r_lfsr[16];
        end
        21: begin
          r_xnor = r_lfsr[20] ^~ r_lfsr[18];
        end
        22: begin
          r_xnor = r_lfsr[21] ^~ r_lfsr[20];
        end
        23: begin
          r_xnor = r_lfsr[22] ^~ r_lfsr[17];
        end
        24: begin
          r_xnor = r_lfsr[23] ^~ r_lfsr[22] ^~ r_lfsr[21] ^~ r_lfsr[16];
        end
        25: begin
          r_xnor = r_lfsr[24] ^~ r_lfsr[21];
        end
        26: begin
          r_xnor = r_lfsr[25] ^~ r_lfsr[5] ^~ r_lfsr[1] ^~ r_lfsr[0];
        end
        27: begin
          r_xnor = r_lfsr[26] ^~ r_lfsr[4] ^~ r_lfsr[1] ^~ r_lfsr[0];
        end
        28: begin
          r_xnor = r_lfsr[27] ^~ r_lfsr[24];
        end
        29: begin
          r_xnor = r_lfsr[28] ^~ r_lfsr[26];
        end
        30: begin
          r_xnor = r_lfsr[29] ^~ r_lfsr[5] ^~ r_lfsr[3] ^~ r_lfsr[0];
        end
        31: begin
          r_xnor = r_lfsr[30] ^~ r_lfsr[27];
        end
        32: begin
          r_xnor = r_lfsr[31] ^~ r_lfsr[21] ^~ r_lfsr[1] ^~ r_lfsr[0];
        end
 
      endcase 
    end 
 
 
  
 
endmodule

