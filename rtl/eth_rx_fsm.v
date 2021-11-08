`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com  
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
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
        input wire [3:0]    i_eth_rxd_4b,
        output reg [15:0]   o_eth_mem_wr_addr = 0, //address to memory    
        output reg          o_eth_mem_we = 0, //we to memory
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
    localparam S_IDLE 	       	         = 8'h00;
    localparam S_CAPTURE_MAC_SRC 	     = 8'h01;
    localparam S_CAPTURE_LENGTH 	     = 8'h02;
    localparam S_CAPTURE_PAYLOAD 	     = 8'h03;
    localparam S_CAPTURE_CRC 	         = 8'h04;
    localparam S_DELAY                   = 8'h05;
    localparam S_COMPARE_CRC 	         = 8'h06;
    localparam S_PROCESS_CAPTURE 	     = 8'h07;
    
    
    
    
    wire [7:0] crc_data_out;
    wire o_dv;
    reg crc_enable = 0;




    reg  [1:0]  cal_select = 0;
    wire [7:0]  cal_select_data;
    
    wire [7:0]  captured_byte_alt;
	wire [47:0] cal_select_destination;
	wire [47:0] target_destination  = 48'h1A_2B_3C_4D_5E_6F;
    reg  [15:0] payload_length = 0;
    reg [7:0]   state = S_IDLE;
    reg [15:0]  proc_cntr = 0;
    reg [31:0]  captured_crc    = 0;
    reg [31:0]  computed_crc    = 0;
    reg [47:0]  captured_source = 0;
    reg [47:0]  captured_destination = 0;
    reg [47:0]  captured_destination_alt = 0;
    reg [55:0]  captured_byte_alt_delay = 0;

    
    //retimer flops
    //retimes top control signals to current eth sm signals
    reg [2:0]  r_eth_dv = 0;
    reg [7:0]  captured_byte = 0;
    reg [55:0] cal_select_data_delay = 0;
    reg [31:0] captured_byte_delay = 0;

    reg [1:0]  r_eth_rst_waddr = 0;
    wire [7:0] crc_data_input;
    


    //delay flops
    always @(posedge i_eth_clk)begin
        if(i_rst)begin
            r_eth_dv = 0;
            captured_byte <= 0;
            cal_select_data_delay <= 0;
            captured_byte_delay <= 0;
        end
        else begin
            r_eth_dv[0] <= i_eth_dv;
            r_eth_dv[1] <= r_eth_dv[0];
            r_eth_dv[2] <= r_eth_dv[1];
      
            //data sample if all delays are correct
            captured_byte <= {rxd3_ddr_q[1],rxd2_ddr_q[1],rxd1_ddr_q[1],rxd0_ddr_q[1],rxd3_ddr_q[0],rxd2_ddr_q[0],rxd1_ddr_q[0],rxd0_ddr_q[0]}; //Reverse nibbles
            captured_byte_delay[7:0] <= captured_byte;
            captured_byte_delay[31:8] <= captured_byte_delay[23:0];
            //alternative data sample for when delay is not correct
            captured_byte_alt_delay[7:0] <= captured_byte_alt;
            captured_byte_alt_delay[55:8] <= captured_byte_alt_delay[47:0];
            
            
            cal_select_data_delay[7:0] <= cal_select_data;
            cal_select_data_delay[55:8] <= cal_select_data_delay[47:0];
            
            //double flop retimer
            r_eth_rst_waddr[0] <= i_eth_rst_waddr;
            r_eth_rst_waddr[1] <= r_eth_rst_waddr[0];
        end
    end
    
    
    //alternative data sample for when delay is not correct
    assign captured_byte_alt = {captured_byte_delay[11:8],captured_byte_delay[23:20]};
    assign o_eth_data_out_8b = cal_select_data;
    
    //mac destination data delay calibration chosen by FSM
    assign cal_select_destination = (cal_select == 0) ? captured_destination : captured_destination_alt;

    //data delay calibration chosen by FSM
    assign cal_select_data = (cal_select == 0) ? captured_byte : captured_byte_alt;
    
    //crc data delay calibration chosen by FSM
    assign crc_data_input = (cal_select == 0 )? cal_select_data_delay[55:48] : captured_byte_alt_delay[55:48];
        
    //data validity checks
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
        end
        else begin
            case(state)
                
                
                S_IDLE: begin
                    if(r_eth_rst_waddr[1] == 1)begin
                        o_eth_mem_wr_addr <= 0;
                        o_packet_count <= 0;
                        captured_destination <= 0;
                        payload_length <= 0;
                    end
                    else begin
                        //self calibration
                        if(captured_destination == target_destination)begin
                            //if target destination is found with normal delays select calibration 0
                            o_busy <= 1;
                            cal_select <= 0;
                            crc_enable <= 1;
                            state <= S_CAPTURE_MAC_SRC;
                            //we are one clock cycle behind so we must capture first byte of mac source now
                            captured_source[7:0] <= cal_select_data;
                            captured_source[47:8] <= captured_source[39:0];
                        end
                        else if (captured_destination_alt == target_destination)begin
                            //if target destination is found with extra delays select calibration 1
                            cal_select <= 1;
                            o_busy <= 1;
                            crc_enable <= 1;
                            state <= S_CAPTURE_MAC_SRC;
                            //we are one clock cycle behind so we must capture first byte of mac source now
                            captured_source[7:0] <= cal_select_data;
                            captured_source[47:8] <= captured_source[39:0];
                        end
                        else begin
                            //otherwise keep scanning for correct destination
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
                    captured_source[7:0] <= cal_select_data;
                    captured_source[47:8] <= captured_source[39:0];
                    if(proc_cntr < 4)begin
                        proc_cntr <= proc_cntr + 1;
                    end
                    else begin
                        state <= S_CAPTURE_LENGTH;
                        proc_cntr <= 0;
                        //payload_length[15:8] <= cal_select_data;
                    end
                end
                
                S_CAPTURE_LENGTH: begin
                    //we use packet length data bytes within the packet to determine how many bytes to read
                    //this saves us the trouble of considering potential dealys with the RXCTL signal
                    payload_length[15:0] <= payload_length[7:0];
                    payload_length[7:0] <= cal_select_data;
                    if(proc_cntr < 1)begin
                        proc_cntr <= proc_cntr + 1;
                    end
                    else begin
                        proc_cntr <= 0;
                        o_eth_mem_we <= 1;
                        state <= S_CAPTURE_PAYLOAD;
                    end
                end
                
                S_CAPTURE_PAYLOAD: begin
                    if(o_eth_mem_wr_addr < 16'd65530)begin
                        o_eth_mem_wr_addr <= o_eth_mem_wr_addr + 1'b1;
                    end
                     if(proc_cntr < (payload_length-1))begin
                        proc_cntr <= proc_cntr + 1;
                    end
                    else begin
                        o_eth_mem_we <= 0;
                        state <= S_CAPTURE_CRC;
                        proc_cntr <= 0;   
                    end                   
                end
                
                S_CAPTURE_CRC: begin
                    if(proc_cntr < 4)begin
                        captured_crc[7:0] <= cal_select_data[7:0];
                        captured_crc[31:8] <= captured_crc[23:0];
                        proc_cntr <= proc_cntr + 1;
                    end
                    else begin
                        proc_cntr <= 0;
                        state <= S_DELAY;
                    end
                end
                
                
                S_DELAY: begin
                    //delay needed for CRC module to respond with valid data
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
                    captured_source <= 0;
                    proc_cntr <= 0;
                    state <= S_IDLE;
                end
            endcase
        end
    end
        
        
        
        
     crc32_in8 crc32_in8_rx_inst(
          .i_clk(i_eth_clk) //
        , .i_dv(crc_enable) //
        , .i_data_in(crc_data_input) //
        , .o_dv(o_dv)
        , .o_data_out(crc_data_out) //
    );
    
    

    
    
endmodule
