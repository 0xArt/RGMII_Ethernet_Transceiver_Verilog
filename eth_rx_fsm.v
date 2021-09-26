`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com  
// Engineer:    Artin Isagholian
// 
// Create Date: 07/12/2021 10:44:43 AM
// Design Name: 
// Module Name: eth_rx_fsm
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


module eth_rx_fsm(
        input wire          i_eth_clk,
        input wire          i_rst,
        input wire          i_eth_rst_waddr,
        input wire          i_eth_dv,
        output reg          o_eth_mem_we = 0, //we to memory
        output reg [15:0]   o_eth_mem_wr_addr = 0, //address to memory    
        input wire [3:0]    i_eth_rxd_4b,
        output wire [7:0]   o_eth_data_out_8b,
        output reg          o_busy = 0,
        output reg [9:0]    o_packet_count = 0,
        output reg          o_valid_packet = 0
    );
    
    
    
    
    

    
    //
    // DDR input register for rxd 0
    //
    wire  [1:0] rxd0_ddr_q;         // Output from DDR register, MSb = rising edge bit, LSb = falling edge bit
    IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT_Q1(1'b0),            // Initial value of Q1: 1'b0 or 1'b1
        .INIT_Q2(1'b0),            // Initial value of Q2: 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_rxd0 (
        .Q1(rxd0_ddr_q[0]),          // 1-bit output for positive edge of clock
        .Q2(rxd0_ddr_q[1]),          // 1-bit output for negative edge of clock
        .C(i_eth_clk),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D(i_eth_rxd_4b[0]),                // 1-bit DDR data input
        .R(i_rst),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    //
    // DDR input register for rxd 1
    //
    wire  [1:0] rxd1_ddr_q;         // Output from DDR register, MSb = rising edge bit, LSb = falling edge bit
    IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT_Q1(1'b0),            // Initial value of Q1: 1'b0 or 1'b1
        .INIT_Q2(1'b0),            // Initial value of Q2: 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_rxd1 (
        .Q1(rxd1_ddr_q[0]),          // 1-bit output for positive edge of clock
        .Q2(rxd1_ddr_q[1]),          // 1-bit output for negative edge of clock
        .C(i_eth_clk),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D(i_eth_rxd_4b[1]),                // 1-bit DDR data input
        .R(i_rst),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    //
    // DDR input register for rxd 2
    //
    wire  [1:0] rxd2_ddr_q;         // Output from DDR register, MSb = rising edge bit, LSb = falling edge bit
    IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT_Q1(1'b0),            // Initial value of Q1: 1'b0 or 1'b1
        .INIT_Q2(1'b0),            // Initial value of Q2: 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_rxd2 (
        .Q1(rxd2_ddr_q[0]),          // 1-bit output for positive edge of clock
        .Q2(rxd2_ddr_q[1]),          // 1-bit output for negative edge of clock
        .C(i_eth_clk),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D(i_eth_rxd_4b[2]),                // 1-bit DDR data input
        .R(i_rst),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    //
    // DDR input register for rxd 3
    //
    wire  [1:0] rxd3_ddr_q;         // Output from DDR register, MSb = rising edge bit, LSb = falling edge bit
    IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                              //    or "SAME_EDGE_PIPELINED"
        .INIT_Q1(1'b0),            // Initial value of Q1: 1'b0 or 1'b1
        .INIT_Q2(1'b0),            // Initial value of Q2: 1'b0 or 1'b1
        .SRTYPE("ASYNC")           // Set/Reset type: "SYNC" or "ASYNC"
    ) r_ddr_rxd3 (
        .Q1(rxd3_ddr_q[0]),          // 1-bit output for positive edge of clock
        .Q2(rxd3_ddr_q[1]),          // 1-bit output for negative edge of clock
        .C(i_eth_clk),                  // 1-bit primary clock input
        .CE(1'b1),                 // 1-bit clock enable input
        .D(i_eth_rxd_4b[3]),                // 1-bit DDR data input
        .R(i_rst),                   // 1-bit reset
        .S(1'b0)                   // 1-bit set
    );
    
    
    
    
        
    //state machine
    localparam S_IDLE 	       	         = 8'd0;
    localparam S_CAPTURE_MAC_SRC 	     = 8'd1;
    localparam S_CAPTURE_LENGTH 	     = 8'd2;
    localparam S_CAPTURE_PAYLOAD 	     = 8'd3;
    localparam S_CAPTURE_CRC 	         = 8'd4;
    localparam S_DELAY                   = 8'd5;
    localparam S_COMPARE_CRC 	         = 8'd6;
    localparam S_PROCESS_CAPTURE 	     = 8'd7;
    
    
    
    
    wire [7:0] crc_data_out;
    wire o_dv;
    reg crc_enable = 0;




    reg  [1:0]  cal_select = 0;
    wire [7:0]  cal_select_data;
    
    wire [7:0] captured_byte_alt;
    

	//wire [47:0] target_destination  = 48'h8C_EC_4B_E8_BC_65;
	wire [47:0] cal_select_destination;
	wire [47:0] target_destination  = 48'h1A_2B_3C_4D_5E_6F;
    reg [15:0]  payload_length = 0;

    reg [7:0] state = S_IDLE;
    reg [7:0] proc_cntr = 0;
    reg [31:0] captured_crc    = 0;
    reg [31:0] computed_crc    = 0;
    reg [47:0] captured_source = 0;
    reg [47:0] captured_destination = 0;
    reg [47:0] captured_destination_alt = 0;
    reg [55:0] captured_byte_alt_delay = 0;

    
    //retimer flops
    //retimes top csm sm signals to current eth sm signals
    reg [2:0]  eth_dv = 0;
    reg [7:0]  captured_byte = 0;
    reg [55:0] cal_select_data_delay = 0;
    reg [31:0] captured_byte_delay = 0;

    reg [1:0] eth_rst_waddr = 0;
    reg [15:0] counter = 0;
    wire [7:0] crc_data_input;
    
    always @(posedge i_eth_clk)begin
        if(i_rst)begin
            eth_dv = 0;
            captured_byte <= 0;
            cal_select_data_delay <= 0;
            captured_byte_delay <= 0;
        end
        else begin
            eth_dv[0] <= i_eth_dv;
            eth_dv[1] <= eth_dv[0];
            eth_dv[2] <= eth_dv[1];
      
            captured_byte <= {rxd3_ddr_q[1],rxd2_ddr_q[1],rxd1_ddr_q[1],rxd0_ddr_q[1],rxd3_ddr_q[0],rxd2_ddr_q[0],rxd1_ddr_q[0],rxd0_ddr_q[0]}; //Reverse nibbles
            captured_byte_delay[7:0] <= captured_byte;
            captured_byte_delay[31:8] <= captured_byte_delay[23:0];
            
            cal_select_data_delay[7:0] <= cal_select_data;
            cal_select_data_delay[55:8] <= cal_select_data_delay[47:0];
            
            captured_byte_alt_delay[7:0] <= captured_byte_alt;
            captured_byte_alt_delay[55:8] <= captured_byte_alt_delay[47:0];
            
            eth_rst_waddr[0] <= i_eth_rst_waddr;
            eth_rst_waddr[1] <= eth_rst_waddr[0];
        end
    end
    
    
    
    assign captured_byte_alt = {captured_byte_delay[11:8],captured_byte_delay[23:20]};
    assign cal_select_data = (cal_select == 0) ? captured_byte : captured_byte_alt;
    assign o_eth_data_out_8b = cal_select_data;
    assign cal_select_destination = (cal_select == 0) ? captured_destination : captured_destination_alt;
    assign crc_data_input = (cal_select == 0 )? cal_select_data_delay[55:48] : captured_byte_alt_delay[55:48];


    
    
    
    
    



    wire crc_ok;
    assign crc_ok = (captured_crc == computed_crc) ? 1'b1 : 1'b0;
        
    wire destination_ok;
    assign destination_ok = (cal_select_destination == target_destination) ? 1'b1 : 1'b0;
    
    wire data_ok;
    assign data_ok =  (crc_ok & destination_ok);
    
    
    
    always @(posedge i_eth_clk)begin
        if(i_rst)begin
            state <= S_IDLE;
            o_eth_mem_wr_addr <= 0;
            o_eth_mem_we <= 0;
            proc_cntr <= 0;
            o_busy <= 0;
            o_packet_count <= 0;
            crc_enable <= 0;
            captured_crc    <= 0;
            computed_crc    <= 0;
            captured_source <= 0;
            captured_destination <= 0;
            o_valid_packet <= 0;
            payload_length <= 0;
            counter <= 0;
        end
        else begin
            case(state)
                
                
                S_IDLE: begin
                    if(eth_rst_waddr[1] == 1)begin
                        o_eth_mem_wr_addr <= 0;
                        o_packet_count <= 0;
                        captured_destination <= 0;
                        payload_length <= 0;
                    end
                    else begin
                        if(captured_destination == target_destination)begin
                            o_busy <= 1;
                            cal_select <= 0;
                            crc_enable <= 1;
                            state <= S_CAPTURE_MAC_SRC;
                            captured_source[7:0] <= cal_select_data;
                            captured_source[47:8] <= captured_source[39:0];
                        end
                        else if (captured_destination_alt == target_destination)begin
                            cal_select <= 1;
                            o_busy <= 1;
                            crc_enable <= 1;
                            state <= S_CAPTURE_MAC_SRC;
                            captured_source[7:0] <= cal_select_data;
                            captured_source[47:8] <= captured_source[39:0];
                        end
                        else begin
                            captured_destination[7:0] <= captured_byte[7:0];
                            captured_destination[47:8] <= captured_destination[39:0];
                            
                            captured_destination_alt[7:0] <= captured_byte_alt[7:0];
                            captured_destination_alt[47:8] <= captured_destination_alt[39:0];
                        end
                    end
                    o_valid_packet <= 0;
                    proc_cntr <= 0;
                end
                
                S_CAPTURE_MAC_SRC: begin
                    if(proc_cntr < 5)begin
                        proc_cntr <= proc_cntr + 1;
                        captured_source[7:0] <= cal_select_data;
                        captured_source[47:8] <= captured_source[39:0];
                    end
                    else begin
                        state <= S_CAPTURE_LENGTH;
                        payload_length[15:8] <= cal_select_data;
                    end
                end
                
                S_CAPTURE_LENGTH: begin
                    payload_length[7:0] <= cal_select_data;
                    counter <= 0;
                    o_eth_mem_we <= 1;
                    state <= S_CAPTURE_PAYLOAD;
                end
                
                S_CAPTURE_PAYLOAD: begin
                    if(o_eth_mem_wr_addr < 16'd65530)begin
                        o_eth_mem_wr_addr <= o_eth_mem_wr_addr + 1'b1;
                    end
                    if(counter < payload_length)begin
                        counter <= counter + 1;
                    end
                    else begin
                        o_eth_mem_we <= 0;
                        state <= S_CAPTURE_CRC;
                        captured_crc[7:0] <= cal_select_data[7:0];
                        captured_crc[31:8] <= captured_crc[23:0];
                        proc_cntr <= 0;   
                    end
                end
                
                S_CAPTURE_CRC: begin
                    if(proc_cntr < 3)begin
                        captured_crc[7:0] <= cal_select_data[7:0];
                        captured_crc[31:8] <= captured_crc[23:0];
                        proc_cntr <= proc_cntr + 1;
                    end
                    else begin
                        proc_cntr <= 0;
                        /*
                        if(cal_select == 0)begin
                            counter <= 0;
                        end
                        else begin
                            counter <= 1;
                        end
                        */
                        state <= S_DELAY;
                    end
                end
                
                
                S_DELAY: begin
                    if(proc_cntr < 1)begin
                        proc_cntr <= proc_cntr + 1;
                    end
                    else begin
                        if(crc_enable == 1)begin
                            crc_enable <= 0;
                        end
                        else begin
                            state <= S_COMPARE_CRC;
                            proc_cntr <= 0;
                        end
                    end

                end
                
                S_COMPARE_CRC: begin
                    if(proc_cntr < 4)begin
                        computed_crc[7:0] <= crc_data_out;
                        computed_crc[31:8] <= computed_crc[23:0];
                        proc_cntr <= proc_cntr + 1;
                    end
                    else begin
                        state <= S_PROCESS_CAPTURE;
                    end
                end

                
                S_PROCESS_CAPTURE: begin
                    if(data_ok)begin
                        o_valid_packet <= 1;
                        if(o_packet_count < 62) begin
                            o_packet_count <= o_packet_count + 1;
                            o_eth_mem_wr_addr <= (o_packet_count+1) * 1024;
                        end
                        else begin
                            o_eth_mem_wr_addr <= (o_packet_count) * 1024;
                        end
                    end
                    else begin
                        o_eth_mem_wr_addr <= (o_packet_count) * 1024;
                    end
                    o_busy <= 0;
                    captured_destination <= 0;
                    captured_destination_alt <= 0;
                    counter <= 0;
                    state <= S_IDLE;
                end
            endcase
        end
    end
        
        
        
        
     crc32_in8 i_crc32_rx(
          .i_clk(i_eth_clk) //
        , .i_dv(crc_enable) //
        , .i_data_in(crc_data_input) //
        , .o_dv(o_dv)
        , .o_data_out(crc_data_out) //
    );
    
    

    
    
endmodule
