//****************************************************************//
// This document contains information proprietary to the          //
// CSULB student that created the file - any reuse without        //
// adequate approval and documentation is prohibited              //
//                                                                //
// Class: CECS 460 Spring 2018                                              
// Project name: Project 4 Full UART with TSI                                       
// File name: UART.v                                          
//                                                                //
// Created by Bryan Linares on 5/8/18                        
// Copyright © 2018 Bryan Linares. All rights reserved.              
//                                                                //
// Abstract: UART Module  
// Edit history: 5/10  Revisions 4.0
//                                                                //
// In submitting this file for class work at CSULB                //
// I am confirming that this is my work and the work              //
// of no one else.                                                //
//                                                                //
// In the event other code sources are utilized I will            //
// document which portion of code and who is the author           //
//                                                                //
// In submitting this code I acknowledge that plagiarism          //
// in student project work is subject to dismissal from the class //
//****************************************************************//
`timescale 1ns / 1ps

module UART( clk, rst, baud, eight, parity_en, ohel,
             rx, tx, led);
             
   input clk, rst; 
   input eight, parity_en, ohel;
   input rx; 
   input [3:0] baud;
   output tx;
   output reg [15:0] led;
   
   wire rst_s;
   wire TXRDY, RXRDY, PERR, OVF, FERR;
   wire interrupt, interrupt_ack;
   wire [15:0] port_id;
   wire read_strobe, write_strobe;
   wire [15:0] data;
   wire [15:0] writes, reads;
   wire [7:0] in_port;
   wire [7:0]rxdata;
   
   //////////////Baud decoder//////////////count clocks for bit time 
   reg [18:0] k;
   always @(*) 
      case(baud) 
         4'b0000: k = 333333 - 1;   // baud rate = 300 bits per
         4'b0001: k = 83333  - 1;   // baud rate = 1200 
         4'b0010: k = 41677  - 1;   // baud rate = 2400   
         4'b0011: k = 20833  - 1;   // baud rate = 4800    
         4'b0100: k = 10417  - 1;   // baud rate = 9600   
         4'b0101: k = 5208   - 1;   // baud rate = 19200  
         4'b0110: k = 2604   - 1;   // baud rate = 38400  
         4'b0111: k = 1736   - 1;   // baud rate = 57600  
         4'b1000: k = 868    - 1;   // baud rate = 115300  
         4'b1001: k = 434    - 1;   // baud rate = 230400 
         4'b1010: k = 217    - 1;   // baud rate = 460800 
         4'b1011: k = 109    - 1;   // baud rate = 921600 
         default: k = 333333 - 1;   // baud rate = 300    switches down
      endcase              
   
   wire RXRDY_pulse, TXRDY_pulse;
   assign uart_int = RXRDY_pulse | TXRDY_pulse;
   assign in_port = (port_id == 16'h0001) ? {3'b000, OVF, FERR, PERR, TXRDY, RXRDY} : rxdata;
      
   AISO     aiso (.clk(clk), .reset(rst), 
                  .reset_s(rst_s));
   rsflop   intrflop (.clk(clk), .rst_s(rst_s), .S(uart_int), .R(interrupt_ack), 
                     .Q(interrupt));       
   UART_tx txengine ( .clk(clk), .rst(rst_s), .load(writes[0]), 
                      .data(data[7:0]), .k(k), .eight(eight), .parity_en(parity_en), 
                      .ohel(ohel), .TXRDY(TXRDY), .tx(tx) );
                            
   UART_rx  rxengine ( .clk(clk), .rst(rst_s), 
                           .clr(reads[0]), 
                           .rx(rx), .eight(eight), .parity_en(parity_en), 
                           .ohel(ohel), .k(k), 
                           .data(rxdata), .RXRDY(RXRDY), .PERR(PERR), 
                           .FERR(FERR), .OVF(OVF));                         
                           
   ped           pulse_rx (.clk(clk), .rst(rst_s), .ped_in(RXRDY), 
                           .ped_out(RXRDY_pulse));
   ped           pulse_tx (.clk(clk), .rst(rst_s), .ped_in(TXRDY), 
                           .ped_out(TXRDY_pulse));
                           
   address_decode addr( .port_id(port_id), .write_strobe(write_strobe), 
                        .read_strobe(read_strobe), .writes(writes), .reads(reads));
    
   ///////////////////////////TramelBlaze Instantiation////////////////////////////// 
   tramelblaze_top   tb ( .CLK(clk),   .RESET(rst_s), 
                          .IN_PORT({8'b0, in_port}), .INTERRUPT(interrupt), 
                          .OUT_PORT(data), .PORT_ID(port_id), 
                          .READ_STROBE(read_strobe), .WRITE_STROBE(write_strobe), 
                          .INTERRUPT_ACK(interrupt_ack) );          
   /////////////////////////////Set LEDS//////////////////////////////////////////// 
   always @ (posedge clk, posedge rst_s) 
      if (rst_s) 
         led <= 16'b0; 
      else if (port_id == 16'h0001 && write_strobe)
         led <= data;
                                                                                  
endmodule
