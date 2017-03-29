`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Edward Mares
 * Partner:  Victor Espinoza
 * Email:    eddy.mares@gmail.com
 * Filename: integer_datapath.v
 * Date:     November 2, 2013
 * Version:  1.0
 *
 * Notes:    This top level module is used to pull together our register_file
 *           module that we created in our last lab and connect it to an alu   
 *           module so that we can perform basic functions on our register      
 *           file.
 *
 *******************************************************************************/
module integer_datapath(clk, reset, W_en, W_Adr, S_Adr, DS, S_Sel, 
                        R_Adr, ALU_OP, N, Z, C, Reg_Out, Alu_Out);
   //Inputs
   input              clk, reset, W_en, S_Sel;
   input        [2:0] W_Adr, S_Adr, R_Adr;
   input        [3:0] ALU_OP;
   input       [15:0] DS;
   
   //Outputs
   output wire        N, Z, C;
   output wire [15:0] Reg_Out, Alu_Out;
   
   //Local Wires 
   wire        [15:0] R, S, S_muxed;
   
   //      register_file(clk, reset, W, W_Adr, we, R_Adr, S_Adr, R, S);
   register_file regi (clk, reset, Alu_Out, W_Adr, W_en, R_Adr, S_Adr, R, S);
   
   assign S_muxed = (S_Sel) ? DS : S;
   
   assign Reg_Out = R;
   
   //      alu(R, S, Alu_OP, Y, N, Z, C);
   alu  alu (R, S_muxed, ALU_OP, Alu_Out, N, Z, C);

endmodule
