`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Author:         Victor Espinoza
// Partner:        Edward Mares
// Email:          victor.alfonso94@gmail.com
//
// Create Date:    22:46:40 11/10/2013  
// Module Name:    CPU_EU 
// File Name:      CPU_EU.v
//
// Description:    This module brings togehter our integer datapath module and 
//                 connects it to two 16 bit registers in order to create our
//                 CPU_EU module.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module CPU_EU(clk, reset, W_en, S_Sel, N, Z, C, Adr_Sel, PC_ld, IR_ld,
              PC_inc, Address_data, D_in, D_out, PC_sel, ALU_OP, W_adr, 
              S_adr, R_adr, IR_out);
    
   //Inputs
   input wire             clk, reset, W_en, S_Sel, Adr_Sel, PC_ld, IR_ld, PC_inc,
                          PC_sel;
   input wire      [15:0] D_in;
   input wire      [3:0]  ALU_OP;
   input wire      [2:0]  W_adr, S_adr, R_adr;
   
   //Outputs
   output wire        N, Z, C;
   output wire [15:0] Address_data, D_out, IR_out;
   
   //Local Declarations
   wire [15:0] Reg_out, PC_out, SignExt, PC_mux, add_16_bit;
   
   //   integer_datapath(clk, reset, W_en, W_Adr, S_Adr, DS, S_Sel, 
   //                    R_Adr, ALU_OP, N, Z, C, Reg_Out, Alu_Out);
   integer_datapath  intData (clk, reset, W_en, W_adr, S_adr, D_in,  
                              S_Sel, R_adr, ALU_OP, N, Z, C, 
                              Reg_out, D_out);

   //               module PC (clk, reset, in, ld, inc, out);
   CPU_EU_Registers        PC (clk, reset, PC_mux, PC_ld, PC_inc, PC_out);
   
   //                module IR(clk, reset, ir_ld, Din, Dout);
   IR_Register              IR (clk, reset,  D_in, IR_ld, IR_out);  
   
   assign SignExt = {{8{IR_out[7]}}, IR_out[7:0]};  
   assign add_16_bit = PC_out + SignExt;   
   assign PC_mux = (PC_sel) ? D_out: add_16_bit;
   
   assign Address_data = (Adr_Sel == 1'b1) ? Reg_out : PC_out;
   
endmodule
