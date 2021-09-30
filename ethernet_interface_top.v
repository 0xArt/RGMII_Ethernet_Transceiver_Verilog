`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
// 
// Create Date: 02/05/2021 09:23:54 AM
// Design Name: 
// Module Name: ethernet_interface_top
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


module ethernet_interface_top(

        /************************************
                    Shared Signals
        ************************************/
        input  wire          i_main_clk, //125 MHz from Phy
        input  wire          i_rst,      
        
        
        /************************************
                    TX SIGNALS
                   (FPGA -> PHY)
        ************************************/
        //TX  FSM Control Signals
        input  wire [15:0]   i_tx_payload_size,
        input  wire          i_tx_start, // start transmission
        input  wire          i_tx_use_lfsr,
        input  wire [7:0]    i_tx_gap_count,
        //TX FSM Status Outputs
        output wire         o_tx_fsm_busy,
        //TX Outputs to PHY
        output wire         o_tx_phy_clk,
        output wire [3:0]   o_tx_phy_data,
        output wire         o_tx_phy_dv,
        
        
        /************************************
                    RX SIGNALS
                   (PHY -> FPGA)
        ************************************/
        //RX FSM Control Signals
        input wire          i_rx_rst_waddr,
        //RX FSM Status Outputs
        output wire          o_rx_fsm_busy,
        output wire [9:0]    o_rx_packet_count,
        output wire          o_rx_valid_packet,
        
        //RX Inputs From PHY
        input wire           i_rx_phy_dv,
        input wire  [3:0]    i_rx_phy_data,
        
        
        /************************************
                LFSR Generator Control
        ************************************/
        input wire [31:0]   i_lfsr_seed,
        input wire          i_lfsr_seed_rst,

        
        /************************************
                TX Memory Port A Signals
        ************************************/
        //Port B is used by tx fsm to read and push said data to phy
        //Port A is used by external module to write data to be pushed to phy
        input wire [7:0]  i_eth_tx_mem_data_in,
        input wire [15:0] i_eth_tx_mem_addr_a,
        input wire        i_eth_tx_mem_we,
        input wire        i_eth_tx_mem_clk_a,
        
        /************************************
                RX Memory Port B Signals
        ************************************/
        //Port B is used by external module to read data captured by rx fsm
        //Port A is used by rx fsm to store captured data from phy
        output wire [7:0]   o_eth_rx_mem_data_out,
        input  wire [15:0]  i_eth_rx_mem_addr_b,
        input  wire         i_eth_rx_mem_clk_b
    );
    
    
        wire       lfsr_generator_enable;
        wire [7:0] lfsr_generator_data; 
        
               

        //ETH tx mem wires Port B wires:
        wire [15:0] eth_tx_mem_addr_b;
        wire [7:0]  eth_tx_mem_data_out;

    
        eth_tx_fsm ethernet_tx_fsm_inst(
             .i_eth_clk(i_main_clk)
            , .i_rst(i_rst)
            
            // Control Signals
            , .i_eth_tx_size(i_tx_payload_size)
            , .i_eth_tx_start(i_tx_start)
            , .i_gap_count(i_tx_gap_count)
            , .i_eth_tx_lfsr_enable(i_tx_use_lfsr)
            , .o_busy(o_tx_fsm_busy)

            //Phy Signals
            , .o_eth_txen(o_tx_phy_dv)
            , .o_eth_txd_4b(o_tx_phy_data)
            , .o_eth_txck(o_tx_phy_clk)

            //Memory Signals
            , .o_eth_mem_rd_addr(eth_tx_mem_addr_b) //read addr to memory
            , .i_eth_data_in_8b(eth_tx_mem_data_out) //data from memory
            
            // LFSR Sequence Generator Signals
            , .o_lfsr_enable(lfsr_generator_enable)
            , .i_lfsr_data(lfsr_generator_data)
        );
        
       blk_mem_eth eth_tx_mem_inst(
            //Write port: (from CSM)
              .clka(i_eth_tx_mem_clk_a)
            , .addra(i_eth_tx_mem_addr_a)
            , .dina(i_eth_tx_mem_data_in)
            , .wea(i_eth_tx_mem_we)
            
            //Read port (to ETH PHY)    
            , .clkb(i_main_clk)
            , .addrb(eth_tx_mem_addr_b)
            , .doutb(eth_tx_mem_data_out)
        );
    
        
        //LFSR Generator    
        lfsr_wrapper lfsr_wrapper_inst(
             .i_clk(i_main_clk)
            ,.i_rst_seed(i_lfsr_seed_rst)
            ,.i_enable(lfsr_generator_enable)
            ,.i_seed_data(i_lfsr_seed)
            ,.o_lfsr_data(lfsr_generator_data)
        );
        
        
        //ETH rx mem wires Port A wires:
        wire [15:0] eth_rx_mem_addr_a;
        wire [7:0]  eth_rx_mem_data_in;
        wire        eth_rx_mem_we;
        
        eth_rx_fsm eth_rx_fsm_inst(
             .i_eth_clk(i_main_clk)    
            , .i_rst(i_rst)
            // PHY Signals
            , .i_eth_dv(i_rx_phy_dv)
            , .i_eth_rxd_4b(i_rx_phy_data)
            
            //Memory Signals
            , .o_eth_mem_we(eth_rx_mem_we) //we to memory
            , .o_eth_mem_wr_addr(eth_rx_mem_addr_a) //address to memory    
            , .o_eth_data_out_8b(eth_rx_mem_data_in)
            
            // Control Signals
            , .i_eth_rst_waddr(i_rx_rst_waddr)
            , .o_busy(o_rx_fsm_busy)
            , .o_packet_count(o_rx_packet_count)
            , .o_valid_packet(o_rx_valid_packet)
        );
        
        
        
        
        
        blk_mem_eth eth_rx_mem_inst(
            //Write port: (from ethernet PHY)
              .clka(i_main_clk)
            , .addra(eth_rx_mem_addr_a)
            , .dina(eth_rx_mem_data_in)
            , .wea(eth_rx_mem_we)
            
            //Read port (to CSM)    
            , .clkb(i_eth_rx_mem_clk_b)
            , .addrb(i_eth_rx_mem_addr_b)
            , .doutb(o_eth_rx_mem_data_out)
        );
        
        
        
        
        
        endmodule
