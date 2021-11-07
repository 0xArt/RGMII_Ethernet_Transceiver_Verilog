`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com: 
// 
// Create Date: 11/06/2021 05:53:38 PM
// Design Name: 
// Module Name: ethernet_interface_top_tb
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


module ethernet_interface_top_tb(
    );
    
	reg [7:0] eth_msg [0:888];
    
    
    integer i;

    reg eth_rxck = 0;
    reg eth_rxck_extra_delay = 0;
    reg eth_rxctl = 0;
    reg [3:0] eth_rxd = 4'd0;
    reg       rx_rst_waddr = 0;
     //Routine for eth clock
    always begin
        #4000;
        eth_rxck <= ~eth_rxck;
    end
    
    
    always @(eth_rxck) begin
        #2000;
        eth_rxck_extra_delay <= ~eth_rxck_extra_delay;
    end
    
    
    reg tb_rst = 0;
    wire [9:0] packet_count;
    reg lfsr_seed_rst = 0;
    reg [31:0] lfsr_seed = 32'h01020304;
    reg        use_lfsr = 0;
    reg        tx_start = 0;
    wire       tx_fsm_busy;
    reg [15:0] tx_payload_size = 0;
    reg [15:0] gap_count = 'd2;
    
    ethernet_interface_top ethernet_interface_top_inst(
         .i_main_clk(eth_rxck)
        ,.i_rst(tb_rst)
        ,.i_tx_payload_size(tx_payload_size)
        ,.i_tx_start(tx_start)
        ,.i_tx_use_lfsr(use_lfsr)
        ,.i_tx_gap_count(gap_count)
        ,.o_tx_fsm_busy(tx_fsm_busy)
        ,.o_tx_phy_clk()
        ,.o_tx_phy_data()
        ,.o_tx_phy_dv()
        ,.i_rx_rst_waddr(rx_rst_waddr)
        ,.o_rx_fsm_busy()
        ,.o_rx_packet_count(packet_count)
        ,.o_rx_valid_packet()
        ,.i_rx_phy_dv(eth_rxctl)
        ,.i_rx_phy_data(eth_rxd)
        ,.i_lfsr_seed(lfsr_seed)
        ,.i_lfsr_seed_rst(lfsr_seed_rst)
        ,.i_eth_tx_mem_data_in()
        ,.i_eth_tx_mem_addr_a()
        ,.i_eth_tx_mem_we()
        ,.i_eth_tx_mem_clk_a(eth_rxck)
        ,.o_eth_rx_mem_data_out()
        ,.i_eth_rx_mem_addr_b()
        ,.i_eth_rx_mem_clk_b(eth_rxck)
    );

    
    
   
    
    initial begin 

        
        
        tb_rst = 1; 
        #2000;
        @(posedge eth_rxck);
        tb_rst = 0;
        #2000;
        
    
        //RX test with on time data
        repeat (1000) @(posedge eth_rxck);
        repeat (1) begin
            i = 0;
            repeat (30) begin
                
                @(negedge eth_rxck);
                #2000;
                eth_rxd <= eth_msg[i][3:0];
                @(posedge eth_rxck);
                #2000;
                if(i == 29)begin
                    eth_rxctl <= 1'b0;
                end
                eth_rxd <= eth_msg[i][7:4];
                
                i = i + 1;
            end
            repeat (50) @(posedge eth_rxck);
        end
        
        
        //RX test with delayed data
        repeat (1000) @(posedge eth_rxck);
        repeat (1) begin
            i = 0;
            repeat (30) begin
                
                @(negedge eth_rxck_extra_delay);
                #2000;
                eth_rxd <= eth_msg[i][3:0];
                @(posedge eth_rxck_extra_delay);
                #2000;
                if(i == 29)begin
                    eth_rxctl <= 1'b0;
                end
                eth_rxd <= eth_msg[i][7:4];
                
                i = i + 1;
            end
            repeat (50) @(posedge eth_rxck);
        end
        
        if(packet_count == 2)begin
            $display("RX PASS: Got both packets!");
        end
        else begin
            $display("RX ERROR: Did not get enough packets!");
            $stop;
        end
        
        @(posedge eth_rxck);
        use_lfsr = 1;
        @(posedge eth_rxck);
        tx_payload_size = 16'h000A;
        @(posedge eth_rxck);
        lfsr_seed_rst = 1;
        @(posedge eth_rxck);
        lfsr_seed_rst = 0;
        
        
        while(tx_fsm_busy == 1)begin
             #10;
        end
        @(posedge eth_rxck);
        tx_start = 1;
        while(tx_fsm_busy == 0)begin
             #10;
        end
        @(posedge eth_rxck);
        tx_start = 0;
        repeat (50) @(posedge eth_rxck);

        while(tx_fsm_busy == 0)begin
             #10;
        end
        
        use_lfsr = 0;
        
        repeat (100) @(posedge eth_rxck);

        $stop;
    end
    

    
    
    initial begin
        //Dest MAC
        eth_msg[ 0] = 8'h1A; 
        eth_msg[ 1] = 8'h2B; 
        eth_msg[ 2] = 8'h3C; 
        eth_msg[ 3] = 8'h4D; 
        eth_msg[ 4] = 8'h5E; 
        eth_msg[ 5] = 8'h6F; 
                
        //Src MAC
        eth_msg[ 6] = 8'hFF; 
        eth_msg[ 7] = 8'hFF; 
        eth_msg[ 8] = 8'hFF; 
        eth_msg[ 9] = 8'hFF; 
        eth_msg[10] = 8'hFF; 
        eth_msg[11] = 8'hFF;
        
        //Payload Length
        eth_msg[12] = 8'h00; 
        eth_msg[13] = 8'h0C; 
        //Payload
        eth_msg[14] = 8'h00; 
        eth_msg[15] = 8'h01;  
        eth_msg[16] = 8'h02;
        eth_msg[17] = 8'h03; 
        eth_msg[18] = 8'h04;
        eth_msg[19] = 8'h05;
        eth_msg[20] = 8'h06;
        eth_msg[21] = 8'h07;
        eth_msg[22] = 8'h08;
        eth_msg[23] = 8'h09;
        eth_msg[24] = 8'h0A;
        eth_msg[25] = 8'h0B;
        
        //CRC32
        //calculated using https://crccalc.com/
        eth_msg[26] = 8'h89; 
        eth_msg[27] = 8'h2A; 
        eth_msg[28] = 8'hDF; 
        eth_msg[29] = 8'h5D; 


        
            
    end
endmodule