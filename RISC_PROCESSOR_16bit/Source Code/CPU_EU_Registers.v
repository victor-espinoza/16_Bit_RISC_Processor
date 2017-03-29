`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Author:         Victor Espinoza
// Partner:        Edward Mares
// Email:          victor.alfonso94@gmail.com
//
// Create Date:    22:55:06 11/18/2013 
// Module Name:    CPU_EU_Registers 
// File Name:      CPU_EU_Registers.v
// 
// Description:    This module is used to create the two 16-bit registers that we
//                 connect to our CPU_EU module. The registers support loading and
//                 incrementing as well as reset.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_EU_Registers(clk, reset, D_in, ld, inc, D_out);

   input            clk, reset, ld, inc;
   input     [15:0] D_in;
   output    [15:0] D_out;
   reg       [15:0] D_out;

   //Create the register files used in the CPU_EU module
   always@ (posedge clk or posedge reset)begin
      if (reset)
         D_out <= 16'b0;
      else begin
         if ( ld == 1'b1 && inc == 1'b1 )
            D_out <= D_in + 16'b0000_0000_0000_0001;
         else
            if (ld == 1'b1)
               D_out <= D_in;
            else 
               if (inc == 1'b1)
                  D_out <= D_out + 16'b0000_0000_0000_0001;
               else
                  D_out <= D_out;
      end   
   end

endmodule
