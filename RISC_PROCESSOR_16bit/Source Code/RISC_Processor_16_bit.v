`timescale 1ns / 1ps
/***********************************************************************
 *
 * Author:   Edward Mares
 * Partner:  Victor Espinoza
 * Email:    eddy.mares@gmail.com
 * Filename: RISC_Processor_16_bit.v
 * Date:     December 05, 2013
 * Version:  1.0
 *
 * Notes:    RISC 16-bit processor module that contains the Control
 *           Unit and the CPU EU. 
 *
 **********************************************************************/


module RISC_Processor_16_bit(clk, reset, status, mw_en, address, D_in, D_out);
   //inputs
   input               clk, reset;
   input       [15:0]  D_in;
   //outputs
   output wire  [7:0]  status; 
   output              mw_en;
   output      [15:0]  D_out, address;
   
   //local declarations
   wire        adr_sel, s_sel, pc_ld, 
               pc_inc, pc_sel, ir_ld, mw_en, rw_en;
   wire [3:0]  alu_op;
   wire [2:0]  W_adr, R_adr, S_adr, alu_status;
   wire [15:0] IR;
      

   
   // module CU     (clk, reset, IR, N, Z, C, W_Adr, R_Adr, S_Adr, 
   //                adr_sel, s_sel, pc_ld, pc_inc, pc_sel, ir_ld, 
   //                mw_en, rw_en, alu_op, status)   
   CU control_unit  (clk, reset, IR, alu_status[0], alu_status[1], 
                     alu_status[2], W_adr, R_adr, S_adr, adr_sel, s_sel,
                     pc_ld, pc_inc, pc_sel, ir_ld, mw_en, rw_en, alu_op, 
                     status);
                    
   //module CPU_EU  (clk, reset, W_en, S_Sel, N, Z, C, Adr_Sel, PC_ld, 
   //                IR_ld, PC_inc, Address_data, D_in, D_out, PC_sel, 
   //                ALU_OP, W_adr, S_adr, R_adr, IR_out);
   CPU_EU cpu_eu (clk, reset, rw_en, s_sel, alu_status[0], alu_status[1], 
                  alu_status[2], adr_sel, pc_ld, ir_ld, pc_inc, address, D_in, 
                  D_out, pc_sel, alu_op, W_adr, S_adr, R_adr, IR);
                  

endmodule
