`timescale 1ns / 1ps
/***********************************************************************
 *
 * Author:   Edward Mares
 * Partner:  Victor Espinoza
 * Email:    eddy.mares@gmail.com
 * Filename: top_level.v
 * Date:     November 30, 2013
 * Version:  1.0
 *
 * Notes:    Top Level of a RISC 16-bit processor          
 *
 **********************************************************************/

module top_level(clk, reset, step_mem, step_clk, AD_sel, dump_mem, a3, 
                 a2, a1, a0, a, b , c, d, e, f, g, status);
   
   //Inputs
   input              clk, reset, step_mem, step_clk, AD_sel, dump_mem;
   
   //Outputs
   output wire        a3, a2, a1, a0, a, b , c, d, e, f, g;
   output wire [8:0]  status;
      
   //Local Declarations
   wire                 clk_IBUFG, cpu_cu_clk, mw_en, mem_we, clk_out;
   wire [15:0]        disp_mux, address, D_in, D_out, madr;
   reg  [15:0]        mem_counter;

    //BUFG buffer for intial 50 MHz clock
   BUFG        clock_buff (.I(clk), .O(clk_IBUFG));
   
   //module   clk_500HZ(clk_in, reset, clk_out);
   clk_500HZ   board_clk (clk_IBUFG, reset, clk_out);
   
   //         debounce(clk, reset, Din, Dout);
   debounce           d1 (clk_out, reset, step_clk, cpu_cu_clk), 
                      d2 (clk_out, reset, step_mem,  mem_we);
               
   //module RISC_Processor_16_bit(clk, reset, status, mw_en, Address, 
   //                               D_In, D_Out);
   RISC_Processor_16_bit RISC(cpu_cu_clk, reset, status, mw_en, address, 
                              D_in, D_out);
                       
   //mem_counter register logic
   always @(posedge mem_we or posedge reset) begin
      if (reset)
         mem_counter <= 16'b0;
      else
         mem_counter <= mem_counter + 1;
   end
   
   //2 2-to-1 mux instantiations
   assign disp_mux = (AD_sel) ? madr        : D_in;
   assign madr     = dump_mem ? mem_counter : address;
   
   //module ram1a(clk, we, addr, din, dout);           
   ram3c ram (clk_IBUFG, mw_en, madr[7:0], D_out, D_in);
   
   //module display_controller(clk, reset, ad_high, ad_low, d_high, d_low,  
   //                            a3, a2, a1, a0, a, b, c, d, e, f, g); 
   display_controller display (clk_IBUFG, reset, disp_mux[15:12], disp_mux[11:8], 
                               disp_mux[7:4], disp_mux[3:0], a3, a2, a1, a0, a, b, 
                               c, d, e, f, g);
endmodule 

//total lines of code: 1245