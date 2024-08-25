//****************************************************************//
// This document contains information proprietary to the          //
// CSULB student that created the file - any reuse without        //
// adequate approval and documentation is prohibited              //
//                                                                //
// Class: CECS 460 Spring 2018                                              
// Project name: Project 4 Full UART with TSI                                       
// File name: UART_rx.v                                          
//                                                                //
// Created by Bryan Linares on 5/8/18                        
// Copyright © 2018 Bryan Linares. All rights reserved.              
//                                                                //
// Abstract: UART receive engine 
// Edit history: 5/15  Revisions 4.0
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
//////////////////////////////////////////
///Receive engine adapted from Pong Chu
/////////////////////////////////////////
`timescale 1ns / 1ps

module UART_rx(clk, rst, clr, rx, eight, parity_en, ohel, k, data, RXRDY, PERR, FERR, OVF);
   
   input    clk, rst;
   input    clr;
   input    rx; 
   input    eight, parity_en, ohel;
   input    [18:0] k;
   output reg   RXRDY, PERR, FERR, OVF;
   output   [7:0] data; 
   
   reg [1:0] s, next_s; 
   reg start, doit;
   
   always @ (posedge clk, posedge rst) 
      if (rst) s <= 2'b0;
      else     s <= next_s;
      
   always @ (*) 
      case(s)
         2'b00: 
            begin 
               start = 0;  doit  = 0;
               if (~rx) next_s = 2'b01;
               else next_s = 2'b00;
            end
         2'b01:
            begin 
               start = 1; doit  = 1;
               if (rx)next_s = 2'b00;
               else if (~rx && ~btu) next_s = 2'b01;
               else if (~rx && btu) next_s = 2'b10;
               else next_s = 2'b01;
            end 
         2'b10: 
            begin 
               start = 0; doit  = 1; 
               if (done) next_s = 2'b00;
               else next_s = 2'b10;
            end
         default: 
            begin 
               next_s = 2'b00; start  = 0; doit   = 0;
            end 
      endcase

   reg [3:0] bit_countReg;
   reg [3:0] bit_count;
   reg [3:0] count;
   always @(*) 
      case ({doit, btu})
         2'b00 : bit_count = 4'b0; 
         2'b01 : bit_count = 4'b0;
         2'b10 : bit_count = bit_countReg;
         2'b11 : bit_count = bit_countReg + 1;
   endcase
   always @ (posedge clk, posedge rst)
      if (rst) 
         bit_countReg <= 4'b0; 
      else 
         bit_countReg <= bit_count;

   // bit amount changes depending
   assign done = (bit_countReg == count);  
   always @ (*) 
      case ({eight, parity_en})
         2'b00 : count = 9;       // start+ 7 data + stop bit
         2'b01 : count = 10;      // start+ 7 data + parity bit + stop bit 
         2'b10 : count = 10;      // start+ 8 data + stop bit
         2'b11 : count = 11;      // start+ 8 data + parity bit + stop bit
         default: count = 9;
      endcase

   reg [18:0] btc_reg;
   reg [18:0] btc;
   reg [18:0] bitTime;
   always @(*) 
      case({doit, btu})
         2'b00 : btc = 19'b0;
         2'b01 : btc = 19'b0;
         2'b10 : btc = btc_reg + 1;
         2'b11 : btc = 19'b0;
      endcase

   always @(posedge clk, posedge rst) 
      if (rst) btc_reg <= 19'b0; 
      else btc_reg <= btc;
      
   always @ (*)
      if (start) bitTime = k >> 1;
      else       bitTime = k;   
   assign btu = (btc_reg == bitTime);    
   
   //shift reg
   reg [9:0] shiftRegOut;
   assign sh = btu & ~start;
   always @ (posedge clk, posedge rst) 
      if (rst) 
         shiftRegOut <= 10'b0;
      else if (sh)   
         shiftRegOut <= {rx, shiftRegOut[9:1]};
  
  // keeps bit placements right side consistent
   reg [9:0] remapped_bits;
   always @ (*)
      case ({eight, parity_en})
         2'b00: remapped_bits =  {2'b11, shiftRegOut[9:2]};
         2'b01: remapped_bits =  {1'b1,  shiftRegOut[9:1]};
         2'b10: remapped_bits =  {1'b1,  shiftRegOut[9:1]};
         2'b11: remapped_bits =  shiftRegOut;
      endcase   
   assign data = (eight) ? remapped_bits[7:0] : {1'b0, remapped_bits[6:0]};
   
   reg p_gen;
   reg p_bit;
   reg p_errorcheck; 
   always @ (*) 
      begin 
         if (eight) p_bit = remapped_bits[8];
         else       p_bit = remapped_bits[7];
            
         case ({eight, ohel}) 
            2'b00: p_gen = ^remapped_bits[6:0];    //7E1
            2'b01: p_gen = ~^remapped_bits[6:0];   //7O1
            2'b10: p_gen = ^remapped_bits[7:0];    //8E1
            2'b11: p_gen = ~^remapped_bits[7:0];   //8O1
         endcase
         p_errorcheck = (p_bit ^ p_gen);
      end
      
   reg stopit;
   always @(*) 
      case({eight, parity_en})
         2'b00 : stopit = remapped_bits[7];
         2'b01 : stopit = remapped_bits[8];
         2'b10 : stopit = remapped_bits[8];
         2'b11 : stopit = remapped_bits[9];
      endcase
   
   ///output status flops
   always @(posedge clk, posedge rst)
      if (rst) RXRDY <= 0; 
      else if (done)RXRDY <= 1; 
      else if (clr) RXRDY <= 0; 
      else RXRDY <= RXRDY;
            
   always @(posedge clk, posedge rst)
      if (rst) PERR <= 0; 
      else if (p_errorcheck & done & parity_en) PERR <= 1; 
      else if (clr)  PERR <= 0; 
      else PERR <= PERR;
         
   always@ (posedge clk, posedge rst) 
      if (rst) OVF <= 0; 
      else if (RXRDY & done) OVF <= 1; 
      else if (clr) OVF <= 0; 
      else OVF <= OVF; 
      
   always@ (posedge clk, posedge rst) 
      if (rst) FERR <= 0; 
      else if (~stopit & done) FERR <= 1; 
      else if (clr) FERR <= 0; 
      else FERR <= FERR;  
           
endmodule
