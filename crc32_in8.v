`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
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


module crc32_in8(i_clk,i_dv,i_data_in,o_dv,o_data_out); 

input wire i_clk; //
input wire i_dv; //
input [7:0] i_data_in; //
output wire o_dv;
output [7:0] o_data_out; // 


wire [7:0] crc_in;
//assign crc_in = i_data_in;
assign crc_in = {i_data_in[0],i_data_in[1],i_data_in[2],i_data_in[3],i_data_in[4],i_data_in[5],i_data_in[6],i_data_in[7]};
//assign crc_in = {i_data_in[3:0],i_data_in[7:4]};

reg [7:0] crc_out = 0; //
assign o_data_out = crc_out;

reg [31:0] crc_reg = 0; //
reg [1:0] count = 0; //
reg [1:0] state = 0; //

wire [31:0] next_crc_reg; //

reg dv_out = 0;
assign o_dv = dv_out;
/*
assign next_crc_reg[ 0] = crc_reg[24] ^ crc_reg[30] ^ crc_in[0] ^ crc_in[6]; 
assign next_crc_reg[ 1] = crc_reg[24] ^ crc_reg[25] ^ crc_reg[30] ^ crc_reg[31] ^ crc_in[0] ^ crc_in[1] ^ crc_in[6] ^ crc_in[7]; 
assign next_crc_reg[ 2] = crc_reg[24] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[30] ^ crc_reg[31] ^ crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[6] ^ crc_in[7]; 
assign next_crc_reg[ 3] = crc_reg[25] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[31] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[7]; 
assign next_crc_reg[ 4] = crc_reg[24] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[28] ^ crc_reg[30] ^ crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6]; 
assign next_crc_reg[ 5] = crc_reg[24] ^ crc_reg[25] ^ crc_reg[27] ^ crc_reg[28] ^ crc_reg[29] ^ crc_reg[30] ^ crc_reg[31] ^ crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7]; 
assign next_crc_reg[ 6] = crc_reg[25] ^ crc_reg[26] ^ crc_reg[28] ^ crc_reg[29] ^ crc_reg[30] ^ crc_reg[31] ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7]; 
assign next_crc_reg[ 7] = crc_reg[24] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[29] ^ crc_reg[31] ^ crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[7]; 
assign next_crc_reg[ 8] = crc_reg[0] ^ crc_reg[24] ^ crc_reg[25] ^ crc_reg[27] ^ crc_reg[28] ^ crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[4]; 
assign next_crc_reg[ 9] = crc_reg[1] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[28] ^ crc_reg[29] ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5]; 
assign next_crc_reg[10] = crc_reg[2] ^ crc_reg[24] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[29] ^ crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5]; 
assign next_crc_reg[11] = crc_reg[3] ^ crc_reg[24] ^ crc_reg[25] ^ crc_reg[27] ^ crc_reg[28] ^ crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[4]; 
assign next_crc_reg[12] = crc_reg[4] ^ crc_reg[24] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[28] ^ crc_reg[29] ^ crc_reg[30] ^ crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6]; 
assign next_crc_reg[13] = crc_reg[5] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[29] ^ crc_reg[30] ^ crc_reg[31] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7]; 
assign next_crc_reg[14] = crc_reg[6] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[28] ^ crc_reg[30] ^ crc_reg[31] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7]; 
assign next_crc_reg[15] = crc_reg[7] ^ crc_reg[27] ^ crc_reg[28] ^ crc_reg[29] ^ crc_reg[31] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7]; 
assign next_crc_reg[16] = crc_reg[8] ^ crc_reg[24] ^ crc_reg[28] ^ crc_reg[29] ^ crc_in[0] ^ crc_in[4] ^ crc_in[5]; 
assign next_crc_reg[17] = crc_reg[9] ^ crc_reg[25] ^ crc_reg[29] ^ crc_reg[30] ^ crc_in[1] ^ crc_in[5] ^ crc_in[6]; 
assign next_crc_reg[18] = crc_reg[10] ^ crc_reg[26] ^ crc_reg[30] ^ crc_reg[31] ^ crc_in[2] ^ crc_in[6] ^ crc_in[7]; 
assign next_crc_reg[19] = crc_reg[11] ^ crc_reg[27] ^ crc_reg[31] ^ crc_in[3] ^ crc_in[7]; 
assign next_crc_reg[20] = crc_reg[12] ^ crc_reg[28] ^ crc_in[4]; 
assign next_crc_reg[21] = crc_reg[13] ^ crc_reg[29] ^ crc_in[5]; 
assign next_crc_reg[22] = crc_reg[14] ^ crc_reg[24] ^ crc_in[0]; 
assign next_crc_reg[23] = crc_reg[15] ^ crc_reg[24] ^ crc_reg[25] ^ crc_reg[30] ^ crc_in[0] ^ crc_in[1] ^ crc_in[6]; 
assign next_crc_reg[24] = crc_reg[16] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[31] ^ crc_in[1] ^ crc_in[2] ^ crc_in[7]; 
assign next_crc_reg[25] = crc_reg[17] ^ crc_reg[26] ^ crc_reg[27] ^ crc_in[2] ^ crc_in[3]; 
assign next_crc_reg[26] = crc_reg[18] ^ crc_reg[24] ^ crc_reg[27] ^ crc_reg[28] ^ crc_reg[30] ^ crc_in[0] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6]; 
assign next_crc_reg[27] = crc_reg[19] ^ crc_reg[25] ^ crc_reg[28] ^ crc_reg[29] ^ crc_reg[31] ^ crc_in[1] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7]; 
assign next_crc_reg[28] = crc_reg[20] ^ crc_reg[26] ^ crc_reg[29] ^ crc_reg[30] ^ crc_in[2] ^ crc_in[5] ^ crc_in[6]; 
assign next_crc_reg[29] = crc_reg[21] ^ crc_reg[27] ^ crc_reg[30] ^ crc_reg[31] ^ crc_in[3] ^ crc_in[6] ^ crc_in[7]; 
assign next_crc_reg[30] = crc_reg[22] ^ crc_reg[28] ^ crc_reg[31] ^ crc_in[4] ^ crc_in[7]; 
assign next_crc_reg[31] = crc_reg[23] ^ crc_reg[29] ^ crc_in[5]; 
  */
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
parameter idle = 2'b00; //
parameter compute = 2'b01; //
parameter finish = 2'b10; //
//
reg [31:0] crc_32b_xor_br;
//
always @(posedge i_clk) begin 
    case(state) //
     idle:begin //
         if(i_dv) begin //l 
            state <= compute; 
            dv_out <= i_dv;
         end else 
            state <= idle; 
     end 
     compute:begin 
         
         if(~i_dv) // 
            state <= finish; 
         else begin
            state <= compute; 
            dv_out <= i_dv;
         end
     end 
     finish:begin 
         if(count==3) begin //
            state <= idle; 
             dv_out <= 0;
         end else 
            state <= finish; 
     end 
    endcase 
end
 
always @(posedge i_clk) begin // 

     case(state) 
         idle:begin //
             //crc_reg[31:0] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000; 
             if(~i_dv) begin
                 crc_reg[31:0] <= 32'hFFFF_FFFF;
                 //crc_reg[31:0] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000; 
             end else begin
                 crc_reg[31:0]<= newcrc[31:0]; 
             end
             crc_out <= i_data_in;
             
         end 
         compute:begin // 
            if(i_dv) begin
                 crc_reg <= newcrc; 
                 crc_32b_xor_br <= newcrc_xor_br;
                 crc_out <= i_data_in;
            end else begin
                crc_32b_xor_br <= {8'b0000_0000,crc_32b_xor_br[31:8]};  
                crc_out[7:0] <= crc_32b_xor_br[7:0]; 
            end
            
         end 
         finish:begin //
             crc_32b_xor_br <= {8'b0000_0000,crc_32b_xor_br[31:8]}; 
             crc_out[7:0] <= crc_32b_xor_br[7:0];  
             count <= count + 1'b1;
         end 
    endcase 
end
endmodule
