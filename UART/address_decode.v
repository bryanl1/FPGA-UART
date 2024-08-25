`timescale 1ns / 1ps
//****************************************************************//
// This document contains information proprietary to the          //
// CSULB student that created the file - any reuse without        //
// adequate approval and documentation is prohibited              //
//                                                                //
// Class: CECS 460 Spring 2018                                              
// Project name: Project 4 Full UART with TSI                                      
// File name: address_decode.v                                          
//                                                                //
// Created by Bryan Linares on 5/8/18                        
// Copyright © 2018 Bryan Linares. All rights reserved.              
//                                                                //
// Abstract: Address Decoder , generates read and write enables
// Edit history: 5/15  Revision 4.0 
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
module address_decode(
    input [3:0] port_id,
    input write_strobe,
    input read_strobe,
    output reg [15:0] writes,
    output reg [15:0] reads
    );

      always@(*)begin
      writes = 0;
      reads = 0;
      case({read_strobe,write_strobe,port_id})
         6'b01_0000: begin
                    writes = 16'h0001; reads  = 16'h0000;
                    end
         6'b01_0001: begin
                    writes = 16'h0002; reads  = 16'h0000;
                    end 
         6'b10_0000: begin
                    writes = 16'h0000; reads  = 16'h0001;
                    end
         6'b10_0001: begin
                    writes = 16'h0000; reads  = 16'h0002;
                    end
         default: begin 
                     writes = 16'b0; reads  = 16'b0;
                  end
         endcase
      end
endmodule
