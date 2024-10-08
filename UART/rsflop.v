//****************************************************************//
// This document contains information proprietary to the          //
// CSULB student that created the file - any reuse without        //
// adequate approval and documentation is prohibited              //
//                                                                //
// Class: CECS 460 Spring 2018                                              
// Project name: Project 4 Full UART with TSI                                       
// File name: rsflop.v                                          
//                                                                //
// Created by Bryan Linares on 5/8/18                        
// Copyright � 2018 Bryan Linares. All rights reserved.              
//                                                                //
// Abstract: Set Reset Flop
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

module rsflop(clk, rst, S, R, Q);
   
   input    clk, rst, S, R; 
   output   Q; 
   reg Q; 
   
   always @ (posedge clk, posedge rst_s)
      if (rst)  Q <= 1'b0; 
      else if (S) Q <= 1'b1; 
      else if (R) Q <= 1'b0; 
      else        Q <= Q; 

endmodule
