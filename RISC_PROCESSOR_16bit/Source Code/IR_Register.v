`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Author:         Victor Espinoza
// Partner:        Edward Mares
// Email:          victor.alfonso94@gmail.com
//
// Create Date:    20:52:40 11/19/2013 
// Module Name:    IR_Register 
// File Name:      IR_Register.v
//
// Description:    This is a register that is used to hold the output value  
//                 of the CPU_EU module.  
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module IR_Register(clk, reset, D_in, ld, D_out);

   input            clk, reset, ld;
   input     [15:0] D_in;
   output    [15:0] D_out;
   reg       [15:0] D_out;

   //Create the register files used in the CPU_EU module
   always@ (posedge clk or posedge reset)begin
      if (reset)
         D_out <= 16'b0;
      else
         if (ld)
            D_out <= D_in;   
         else
            D_out <= D_out;
   end

endmodule

