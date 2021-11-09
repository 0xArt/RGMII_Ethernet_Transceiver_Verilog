`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
// 
// Create Date: 01/24/2021 06:35:25 PM
// Design Name: 
// Module Name: crc32_in8
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


module crc32_in8(
    input  wire i_clk,
    input  wire i_dv, 
    input  wire [7:0] i_data_in,
    output wire o_dv,
    output wire [7:0] o_data_out
);

//reverse bits
wire [7:0] crc_in;
assign crc_in = {i_data_in[0],i_data_in[1],i_data_in[2],i_data_in[3],i_data_in[4],i_data_in[5],i_data_in[6],i_data_in[7]};

reg [7:0] crc_out = 0; 
assign o_data_out = crc_out;

reg [31:0] crc_reg = 0; 
reg [1:0] count = 0; 
reg [1:0] state = 0; 


reg dv_out = 0;
assign o_dv = dv_out;
wire [31:0] newcrc;
wire [31:0] newcrc_xor;
assign newcrc_xor = newcrc ^ 32'hFFFF_FFFF;
wire [31:0] newcrc_xor_br;
assign newcrc_xor_br = {newcrc_xor[0],newcrc_xor[1],newcrc_xor[2],newcrc_xor[3],newcrc_xor[4],newcrc_xor[5],newcrc_xor[6],newcrc_xor[7],newcrc_xor[8],newcrc_xor[9],newcrc_xor[10],newcrc_xor[11],newcrc_xor[12],newcrc_xor[13],newcrc_xor[14],newcrc_xor[15],newcrc_xor[16],newcrc_xor[17],newcrc_xor[18],newcrc_xor[19],newcrc_xor[20],newcrc_xor[21],newcrc_xor[22],newcrc_xor[23],newcrc_xor[24],newcrc_xor[25],newcrc_xor[26],newcrc_xor[27],newcrc_xor[28],newcrc_xor[29],newcrc_xor[30],newcrc_xor[31]};
    
wire [7:0] d;
assign d = crc_in;
wire [31:0] c; 
assign c = crc_reg;  
assign newcrc[0] = d[6] ^ d[0] ^ c[24] ^ c[30];
assign newcrc[1] = d[7] ^ d[6] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[30] ^ c[31];
assign newcrc[2] = d[7] ^ d[6] ^ d[2] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[26] ^ c[30] ^ c[31];
assign newcrc[3] = d[7] ^ d[3] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[27] ^ c[31];
assign newcrc[4] = d[6] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[28] ^ c[30];
assign newcrc[5] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
assign newcrc[6] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
assign newcrc[7] = d[7] ^ d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[29] ^ c[31];
assign newcrc[8] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
assign newcrc[9] = d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29];
assign newcrc[10] = d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[2] ^ c[24] ^ c[26] ^ c[27] ^ c[29];
assign newcrc[11] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[3] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
assign newcrc[12] = d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[4] ^ c[24] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30];
assign newcrc[13] = d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ c[5] ^ c[25] ^ c[26] ^ c[27] ^ c[29] ^ c[30] ^ c[31];
assign newcrc[14] = d[7] ^ d[6] ^ d[4] ^ d[3] ^ d[2] ^ c[6] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ c[31];
assign newcrc[15] = d[7] ^ d[5] ^ d[4] ^ d[3] ^ c[7] ^ c[27] ^ c[28] ^ c[29] ^ c[31];
assign newcrc[16] = d[5] ^ d[4] ^ d[0] ^ c[8] ^ c[24] ^ c[28] ^ c[29];
assign newcrc[17] = d[6] ^ d[5] ^ d[1] ^ c[9] ^ c[25] ^ c[29] ^ c[30];
assign newcrc[18] = d[7] ^ d[6] ^ d[2] ^ c[10] ^ c[26] ^ c[30] ^ c[31];
assign newcrc[19] = d[7] ^ d[3] ^ c[11] ^ c[27] ^ c[31];
assign newcrc[20] = d[4] ^ c[12] ^ c[28];
assign newcrc[21] = d[5] ^ c[13] ^ c[29];
assign newcrc[22] = d[0] ^ c[14] ^ c[24];
assign newcrc[23] = d[6] ^ d[1] ^ d[0] ^ c[15] ^ c[24] ^ c[25] ^ c[30];
assign newcrc[24] = d[7] ^ d[2] ^ d[1] ^ c[16] ^ c[25] ^ c[26] ^ c[31];
assign newcrc[25] = d[3] ^ d[2] ^ c[17] ^ c[26] ^ c[27];
assign newcrc[26] = d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[18] ^ c[24] ^ c[27] ^ c[28] ^ c[30];
assign newcrc[27] = d[7] ^ d[5] ^ d[4] ^ d[1] ^ c[19] ^ c[25] ^ c[28] ^ c[29] ^ c[31];
assign newcrc[28] = d[6] ^ d[5] ^ d[2] ^ c[20] ^ c[26] ^ c[29] ^ c[30];
assign newcrc[29] = d[7] ^ d[6] ^ d[3] ^ c[21] ^ c[27] ^ c[30] ^ c[31];
assign newcrc[30] = d[7] ^ d[4] ^ c[22] ^ c[28] ^ c[31];
assign newcrc[31] = d[5] ^ c[23] ^ c[29];  


reg [31:0] crc_32b_xor_br;



localparam S_IDLE 	       	         = 8'h00;
localparam S_COMPUTE         	     = 8'h01;
localparam S_FINISH 	             = 8'h02;


always @(posedge i_clk) begin 
    case(state)
         S_IDLE:begin
             crc_out <= i_data_in;
             if(i_dv) begin 
                state <= S_COMPUTE; 
                dv_out <= i_dv;
                 crc_reg[31:0]<= newcrc[31:0]; 
             end 
             else begin 
                 crc_reg[31:0] <= 32'hFFFF_FFFF;
                state <= S_IDLE;
             end
         end 
         
         S_COMPUTE:begin 
            if(i_dv) begin
                 crc_reg <= newcrc; 
                 crc_32b_xor_br <= newcrc_xor_br;
                 crc_out <= i_data_in;
                 dv_out <= i_dv;
            end else begin
                crc_32b_xor_br <= {8'b0000_0000,crc_32b_xor_br[31:8]};  
                crc_out[7:0] <= crc_32b_xor_br[7:0]; 
                state <= S_FINISH; 
            end
            
            
         end 
         
         S_FINISH:begin 
             crc_32b_xor_br <= {8'b0000_0000,crc_32b_xor_br[31:8]}; 
             crc_out[7:0] <= crc_32b_xor_br[7:0];  
             count <= count + 1'b1;
             if(count==3) begin 
                state <= S_IDLE; 
                 dv_out <= 0;
             end 
         end 
    endcase 
end
 

endmodule
