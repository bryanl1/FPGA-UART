//****************************************************************//
// This document contains information proprietary to the          //
// CSULB student that created the file - any reuse without        //
// adequate approval and documentation is prohibited              //
//                                                                //
// Class: CECS 460 Spring 2018                                              
// Project name: Project 4 Full UART with VIC                                       
// File name: UART_tx.v                                          
//                                                                //
// Created by Bryan Linares on 5/8/18                        
// Copyright © 2018 Bryan Linares. All rights reserved.              
//                                                                //
// Abstract: UART transmit engine 
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

 module UART_tx(clk, rst, load, data, k, eight, parity_en, ohel, TXRDY, tx );

   input    clk, rst, load; 
   input    [7:0] data; 
   input    eight, parity_en, ohel;
   input    [18:0] k; 
   output   tx; 
   output   TXRDY;
   
   ///////////rs flops//////
   reg TXRDY; 
   always @ (posedge clk, posedge rst) 
      if (rst) TXRDY <= 1'b1; 
      else if (done) TXRDY <= 1'b1;
      else if (load) TXRDY <= 1'b0;
      else           TXRDY <= TXRDY;
    
   reg doit; 
   always @ (posedge clk, posedge rst) 
      if (rst)  doit <= 1'b0; 
      else if (loadd1) doit <= 1'b1;
      else if (done)   doit <= 1'b0;
      else             doit <= doit;
      
   reg loadd1; 
   always @ (posedge clk, posedge rst) 
      if (rst) loadd1 <= 1'b0; 
      else     loadd1 <= load; 
      
   reg [7:0] ldata;
   always @ (posedge clk, posedge rst) 
      if(rst) ldata <= 8'b0;
      else if (load) ldata <= data;
      
   reg [3:0] bitCountReg;
   reg [3:0] bit_count;
   always @(*)
      case ({doit, btu})
         2'b00: bit_count = 4'b0; 
         2'b01: bit_count = 4'b0;
         2'b10: bit_count = bitCountReg;
         2'b11: bit_count = bitCountReg + 1;
         2'b11: bit_count = bitCountReg + 1;
      endcase 
      
   assign done = (bitCountReg == 11);   
   always @(posedge clk, posedge rst) 
      if (rst) bitCountReg <= 4'b0; 
      else     bitCountReg <= bit_count;   
      
   reg [18:0] bitTimeCountReg;
   reg [18:0] btc;
   always @(*) 
      case({doit, btu})
         2'b00: btc = 19'b0;
         2'b01: btc = 19'b0;
         2'b10: btc = bitTimeCountReg + 1;
         2'b11: btc = 19'b0;
      endcase
      
   assign btu = (bitTimeCountReg == k);   
   always @(posedge clk, posedge rst) 
      if (rst) bitTimeCountReg <= 19'b0; 
      else     bitTimeCountReg <= btc;
         
   reg bit9, bit10;
   always @(*) 
      case({eight, parity_en, ohel}) 
         3'b000 : {bit10, bit9} = 2'b11;                 // 7N1
         3'b001 : {bit10, bit9} = 2'b11;                 // 7N1
         3'b010 : {bit10, bit9} = {1'b1, ^ldata[6:0]};            // 7E1
         3'b011 : {bit10, bit9} = {1'b1, ~(^ldata[6:0])};            // 7O1
         3'b100 : {bit10, bit9} = {1'b1, ldata[7]};      // 8N1
         3'b101 : {bit10, bit9} = {1'b1, ldata[7]};      // 8N1
         3'b110 : {bit10, bit9} = {^ldata[7:0], ldata[7]};        // 8E1 
         3'b111 : {bit10, bit9} = {~(^ldata[7:0]), ldata[7]};        // 8O1
         default: {bit10, bit9} = 2'b00; //err
      endcase 
      
   //////////////////
   //shift register//
   //////////////////
   reg [10:0] sr;
   always @ (posedge clk, posedge rst) 
      if (rst) sr <= 11'hFFFF;              // reset to all 1's
      else if (loadd1) 
         sr <= {bit10, bit9, ldata[6:0], 2'b01};
      else if (btu) 
         sr <= {1'b1, sr[10:1]}; //1 in 
   assign tx = sr[0];
endmodule
