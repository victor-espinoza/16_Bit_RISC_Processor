`timescale 1ns / 1ps
/***********************************************************************
 *
 * Author:   Edward Mares
 * Partner:  Victor Espinoza
 * Email:    eddy.mares@gmail.com
 * Filename: ram1a.v
 * Date:     December 05, 2013
 * Version:  1.0
 *
 * Notes:    1st ram module for the RISC 16-bit processor.
 *
 **********************************************************************/
module ram1a(
    //inputs
    input         clk,
    input         we,
    input [7:0]   addr,
    input [15:0]  din,
    //outputs
    output [15:0] dout
    );
   
   //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
   ram_256x16 dut (
      .clka(clk),
      .wea(we), // Bus [0 : 0] 
      .addra(addr), // Bus [7 : 0] 
      .dina(din), // Bus [15 : 0] 
      .douta(dout)); // Bus [15 : 0] 

   // INST_TAG_END ------ End INSTANTIATION Template ---------


endmodule
