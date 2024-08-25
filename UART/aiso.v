//****************************************************************//
// This document contains information proprietary to the          //
// CSULB student that created the file - any reuse without        //
// adequate approval and documentation is prohibited              //
//                                                                //
// Class: CECS 460 Spring 2018                                              
// Project name: Project 4 Full UART with TSI                                       
// File name: aiso.v                                          
//                                                                //
// Created by Bryan Linares on 5/8/18                        
// Copyright © 2018 Bryan Linares. All rights reserved.              
//                                                                //
// Abstract: Asynch In Synch out for Reset
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
 //	Notes:	The module has two flops that are connected to 
//          the same clock. Module takes an asynchronous
//			   signal in and then output a synchronous signal.
//				Synchs release of reset to all flops to avoid metastability.
///////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module AISO(clk, reset, reset_s);

   input    clk, reset; 
   output   reset_s; 
   reg      inreg, outreg; 
   
   always @ (posedge clk, posedge reset) 
      if (reset) {inreg, outreg} <= {1'b0, 1'b0};
      else       {inreg, outreg} <= {1'b1, inreg};
      
   assign reset_s = ~outreg; 
endmodule
