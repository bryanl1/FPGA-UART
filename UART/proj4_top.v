//****************************************************************//
// This document contains information proprietary to the          //
// CSULB student that created the file - any reuse without        //
// adequate approval and documentation is prohibited              //
//                                                                //
// Class: CECS 460 Spring 2018                                              
// Project name: Project 4 Full UART with TSI                                       
// File name: Proj4_top.v                                          
//                                                                //
// Created by Bryan Linares on 5/8/18                        
// Copyright © 2018 Bryan Linares. All rights reserved.              
//                                                                //
// Abstract: UART Project Top 
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

module Proj4_460_Top(clk, rst, baud, eight, parity_en, ohel, rx, tx, led );

   input    clk, rst; 
   input    [3:0] baud; 
   input    eight, parity_en, ohel; 
   input    rx; //LOC=C4
   output   tx; //LOC=D4
   output   [15:0] led;
   
   wire     clk_w, rst_w;
   wire     [3:0] baud_w;
   wire     eight_w, parity_en_w, ohel_w;
   wire     rx_w;
   wire     [15:0] led_w;
    
   UART  core     (.clk(clk_w), .rst(rst_w), .baud(baud_w), .eight(eight_w), 
                   .parity_en(parity_en_w), .ohel(ohel_w), .rx(rx_w), .tx(tx_w), 
                   .led(led_w)); 
               
   TSI   uart_tsi   (.clk_i(clk), .rst_i(rst),  .baud_i(baud), .eight_i(eight),
                   .parity_en_i(parity_en), .ohel_i(ohel), .rx_i(rx), .tx_i(tx_w), 
                   .led_i(led_w),
                   
                   .clk_o(clk_w), .rst_o(rst_w),  .baud_o(baud_w), .eight_o(eight_w), 
                   .parity_en_o(parity_en_w), .ohel_o(ohel_w), .rx_o(rx_w), .tx_o(tx), 
                   .led_o(led));
endmodule
