`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
// 
// Create Date: 01/26/2021 11:36:24 AM
// Design Name: 
// Module Name: eth_tx_fsm
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


module eth_tx_fsm(
        input  wire          i_eth_clk,
        input  wire          i_rst,
        input  wire [15:0]   i_eth_tx_size,
        input  wire          i_eth_tx_start, // start transmission
        input  wire          i_eth_tx_lfsr_enable,
        input  wire [7:0 ]   i_eth_data_in_8b,
        input  wire [7:0 ]   i_lfsr_data,
        input  wire [7:0 ]   i_gap_count,
        output wire          o_eth_txen,
        output reg  [15:0]   o_eth_mem_rd_addr = 0, //address to memory
        output wire [3:0 ]   o_eth_txd_4b,
        output wire          o_eth_txck,
        output wire          o_busy,
        output reg           o_lfsr_enable = 0
    );
    
    
    localparam S_IDLE 	       	         = 8'd0;
    localparam S_TRANSMIT_PREAMBLE 	     = 8'd1;
    localparam S_TRANSMIT_SOF 	         = 8'd2;
    localparam S_TRANSMIT_MAC_DES 	     = 8'd3;
    localparam S_TRANSMIT_MAC_SRC 	     = 8'd4;
    localparam S_TRANSMIT_PAYLOAD 	     = 8'd5;
    localparam S_TRANSMIT_CRC 	         = 8'd6;
    localparam S_TRANSMIT_GAP 	         = 8'd7;


    //MAC source/destination is fixed but this can be made an input
    wire [47:0] mac_destination = 48'hFF_FF_FF_FF_FF_FF;
	wire [47:0] mac_source      = 48'h1A_2B_3C_4D_5E_6F;
	
    reg  [7:0]   state = S_IDLE;
    reg  [7:0]   proc_cntr = 0;
    reg          crc_enable = 0;
    reg  [47:0]  saved_mac_destination = 0;
	reg  [47:0]  saved_mac_source = 0;
    reg  [7:0]   tx_data = 0;
    reg          tx_enable = 0;
    reg          tx_enable_delay = 'd0;
    reg  [7:0]   tx_data_delay = 0;
    reg  [2:0]   r_eth_tx_start = 0;
    reg  [15:0]  tx_size_cache;
    wire [7:0]   crc_data_out;
    reg  [7:0]   r_gap_count;
    wire         crc_dv;
    
    reg          fsm_busy = 0;
    wire         eth_clk_90_locked;
    //module should indicate busy if MMCM/PLL is not locked
    assign       o_busy = (eth_clk_90_locked) ? fsm_busy : 1;

    //make switch to CRC module when its time to trasmit CRC at end of packet
    wire [7:0]   output_data;
    assign       output_data = (state == S_TRANSMIT_CRC) ? crc_data_out : tx_data_delay;
    
    
    //if lfsr mode is enabled, transmit lfsr test sequence instead of data from TX memory
    reg          eth_tx_lfsr_enable = 0;
    wire [7:0]   recieved_data;
    assign       recieved_data = (eth_tx_lfsr_enable) ? i_lfsr_data : i_eth_data_in_8b;
    
    //start signal pos edge detector
    wire         eth_tx_start_re;
    assign       eth_tx_start_re = (r_eth_tx_start[2] == 0 && r_eth_tx_start[1] == 1) ? 1 : 0;


    //minimum payload size is 60 to be compliant with winpcap
    wire [15:0] tx_size;
    assign tx_size = (i_eth_tx_size < 60) ? 16'd60 : i_eth_tx_size;
    
    
     //delay flops
    always @(posedge i_eth_clk)begin
        if(i_rst)begin
            tx_data_delay <= 0;
            r_eth_tx_start <= 0;
            tx_enable_delay <= 0;
        end
        else begin
            r_eth_tx_start[0]      <= i_eth_tx_start;
            r_eth_tx_start[1]      <= r_eth_tx_start[0];
            r_eth_tx_start[2]      <= r_eth_tx_start[1];
            tx_enable_delay  <= tx_enable;
            tx_data_delay    <= tx_data;
        end
    end
    
    
    
    //state machine
    always @(posedge i_eth_clk) begin
        if(i_rst)begin
            o_eth_mem_rd_addr <= 0;
            fsm_busy <= 0;
            proc_cntr <= 0;
            crc_enable <= 0;
            tx_enable <= 0;
            saved_mac_destination <= 0;
            saved_mac_source <= 0;
            state <= S_IDLE;
            tx_size_cache <= 0;
            eth_tx_lfsr_enable <= 0;
            o_lfsr_enable <= 0;
            r_gap_count <= 0;
        end
        else begin
            case(state)
            
                S_IDLE: begin
                    o_eth_mem_rd_addr <= 0;
                    tx_data <= 0;
                    if(eth_tx_start_re)begin
                        state <= S_TRANSMIT_PREAMBLE;
                        proc_cntr <= 0;
                        fsm_busy  <= 1;
                        tx_size_cache <= tx_size;
                        saved_mac_destination <= mac_destination;
                        saved_mac_source      <= mac_source;
                        o_eth_mem_rd_addr     <= 0;
                        r_gap_count <= i_gap_count;
                        eth_tx_lfsr_enable <= i_eth_tx_lfsr_enable;
                    end
                end
                
                S_TRANSMIT_PREAMBLE: begin
                    //preamble consists of 7 byts of 8'h55
                    tx_enable <= 1;
                    if(proc_cntr < 7)begin
                        proc_cntr <= proc_cntr + 1;
                        tx_data <= 8'h55;
                    end
                    else begin
                        state <= S_TRANSMIT_SOF;
                        tx_data <= 8'hD5;
                        proc_cntr <= 0;
                    end
                end
                
                
                S_TRANSMIT_SOF: begin
                    //start of frame is 1 byte of 8'D5
                    state <= S_TRANSMIT_MAC_DES;
                    crc_enable <= 1'b1;                   
                    tx_data <= saved_mac_destination[47:40];
                    saved_mac_destination <= {saved_mac_destination[39:0], 8'b0};
                    proc_cntr <= 1;
                end
                
                S_TRANSMIT_MAC_DES: begin
                    if(proc_cntr < 6)begin
                        tx_data <= saved_mac_destination[47:40];
                        saved_mac_destination <= {saved_mac_destination[39:0], 8'b0};
                        proc_cntr <= proc_cntr + 1;
                    end
                    else begin
                        state <= S_TRANSMIT_MAC_SRC;
                        proc_cntr <= 1;
                        tx_data <= saved_mac_source[47:40];
                        saved_mac_source <= {saved_mac_source[39:0], 8'b0};
                    end
                end
                
                S_TRANSMIT_MAC_SRC: begin
                    if(proc_cntr < 6)begin
                        tx_data <= saved_mac_source[47:40];
                        saved_mac_source <= {saved_mac_source[39:0], 8'b0};
                        proc_cntr <= proc_cntr + 1;
                        if(proc_cntr == 5)begin
                           o_eth_mem_rd_addr <= o_eth_mem_rd_addr + 1'b1;
                        end
                        if(proc_cntr == 4)begin
                           if(eth_tx_lfsr_enable)begin
                                o_lfsr_enable <= 1;
                            end
                        end
                    end
                    else begin
                        state <= S_TRANSMIT_PAYLOAD;
                        tx_data <= recieved_data;
                        o_eth_mem_rd_addr <= o_eth_mem_rd_addr + 1'b1;
                    end
                end
                
                S_TRANSMIT_PAYLOAD: begin
                   tx_data <= recieved_data;
                   if(o_eth_mem_rd_addr <= tx_size_cache) begin
                        o_eth_mem_rd_addr <= o_eth_mem_rd_addr + 1'b1;
                   end
                   else begin
                      state <= S_TRANSMIT_CRC;
                      proc_cntr <= 0;
                      crc_enable <= 0;
                      o_lfsr_enable <= 0;
                   end
                end
                
                S_TRANSMIT_CRC:begin
                    if(proc_cntr < 4)begin
                        proc_cntr <= proc_cntr + 1;
                        if(proc_cntr == 3)begin
                           tx_enable <= 0;
                           tx_data <= 0;
                        end
                    end
                    else begin
                        if(r_gap_count == 0)begin
                            fsm_busy <= 0;
                            state <= S_IDLE;
                        end
                        else begin
                            state <= S_TRANSMIT_GAP;
                            proc_cntr <= 0;
                        end
                    end
                end
                
                S_TRANSMIT_GAP: begin
                    if(proc_cntr < r_gap_count)begin
                        proc_cntr <= proc_cntr + 1;
                    end
                    else begin
                        fsm_busy <= 0;
                        state <= S_IDLE;
                    end
                end            
            endcase
        end
    end
    

    crc32_in8 crc32_in8_tx_inst(
          .i_clk(i_eth_clk) //
        , .i_dv(crc_enable) //
        , .i_data_in(tx_data) //
        , .o_dv(crc_dv)
        , .o_data_out(crc_data_out) //
    );
    
    
     //create 90 degrees phase shifted version of i_eth_clk
     //this will give us 2ns of data setup time
     //satisifying the 1.8ns of data setup time required
    /*
     ____      ____
    |    |____|    |____     ....     i_eth clk:

      -t- = 2ns
       ____      ____
    __|    |____|    |____   ....     eth_clk_90:
    */
     
     wire eth_clk_90;
     clk_wiz_1  clk_wiz_1_inst(
        .reset(i_rst),
        .clk_in1(i_eth_clk),
        .clk_out1(eth_clk_90),
        .locked(eth_clk_90_locked)
    );
    
    
     ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT(1'b0),            // Initial value of Q = 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_txck (
        .Q(o_eth_txck),          // 1-bit output for positive edge of clock
        .C(eth_clk_90),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D1(1'b1),                // 1-bit DDR data input
        .D2(1'b0),                // 1-bit DDR data input
        .R(1'b0),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    
    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT(1'b0),            // Initial value of Q = 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_txd0 (
        .Q(o_eth_txd_4b[0]),          // 1-bit output for positive edge of clock
        .C(i_eth_clk),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D1(output_data[0]),                // 1-bit DDR data input
        .D2(output_data[4]),                // 1-bit DDR data input
        .R(i_rst),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    
    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT(1'b0),            // Initial value of Q = 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_txd1 (
        .Q(o_eth_txd_4b[1]),          // 1-bit output for positive edge of clock
        .C(i_eth_clk),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D1(output_data[1]),                // 1-bit DDR data input
        .D2(output_data[5]),                // 1-bit DDR data input
        .R(i_rst),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    
    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT(1'b0),            // Initial value of Q = 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_txd2 (
        .Q(o_eth_txd_4b[2]),          // 1-bit output for positive edge of clock
        .C(i_eth_clk),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D1(output_data[2]),                // 1-bit DDR data input
        .D2(output_data[6]),                // 1-bit DDR data input
        .R(i_rst),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    
    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT(1'b0),            // Initial value of Q = 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_txd3 (
        .Q(o_eth_txd_4b[3]),          // 1-bit output for positive edge of clock
        .C(i_eth_clk),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D1(output_data[3]),                // 1-bit DDR data input
        .D2(output_data[7]),                // 1-bit DDR data input
        .R(i_rst),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    
    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT(1'b0),            // Initial value of Q = 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_txen (
        .Q(o_eth_txen),          // 1-bit output for positive edge of clock
        .C(i_eth_clk),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D1(tx_enable_delay),                // 1-bit DDR data input
        .D2(tx_enable_delay),                // 1-bit DDR data input
        .R(i_rst),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    
    
  
    
    
endmodule
