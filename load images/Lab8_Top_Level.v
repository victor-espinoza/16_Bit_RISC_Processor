`timescale 1ns / 1ps
/*********************************************************
* Class:          CECS 301 T-Th 2:00PM
* Designer:       Thien Tran; Steven Lam
* Instructor:     R. W. Allison
*
* Project Number: 8 
* Module Name:    Lab 8 Top Level Module 
* Project Name:   16-bit RISC Processor
* Rev. Date:      12/3/2013 
*
* Purpose: This is the top level module for our lab 8. It 
*          interconnects the RISC Processor, memory, display
*          controller, and debounce modules. It also 
*          increments and resets the mem_counter.
*
* Comments: 
*************************************************************/
module Lab8_Top_Level(clk, reset, status, AD_sel, step, step_mem, dump_mem, an, 
                      ca, cb, cc, cd, ce, cf, cg);

   //-----------Input Ports----------------
   input               clk, reset, AD_sel, step, step_mem, dump_mem;
   
   //-----------Output Ports---------------
   output wire         ca, cb, cc, cd, ce, cf, cg;
   output wire  [3:0]  an;
   output wire  [7:0]  status; 
   
   //------------Internal Variables--------
   wire        mw_en, clk_500Hz_out, CPU_de, step_mem_de, clk_out;
   wire [15:0] Address, RISC_Out, RISC_In;
   wire [7:0]  mem_Adr;
   reg [15:0]  mem_counter;
   
   
   //---------------------Code Starts Here-----------------
   
   BUFG clock_buff(.I(clk), .O(clk_out));
   
   //-------------------Clock 500Hz------------------------
	clock_500Hz clk_module(clk_out, reset, clk_500Hz_out);
   
   //-------------------CU/EU debounce---------------------
   debounce step_clk(clk_500Hz_out, reset, step, CPU_de);
   
   //-------------------Mem debounce-----------------------
	debounce mem_debounce(clk_500Hz_out, reset, step_mem, step_mem_de);
   
   //-------------------RISC Processor---------------------
   RISC_Processor RISC(CPU_de, reset, status, mw_en,
                       Address, RISC_In, RISC_Out);
                       
   //------------------Display Controller------------------
   display_controller display_Controller (
                                 clk_out,
                                 reset,
                                 AD_sel,     // display switch input
                                 RISC_In,    // 16 bit Data 0 input
                                 mem_Adr,   // 16 bit Data 1 input
                                 an,         // 4 anodes
                                 ca,cb,cc,cd,ce,cf,cg
                                 );
                                 
   //--------------------Memory Management-----------------
   // clears mem_counter if reset is pushed
   always @ (posedge step_mem_de or posedge reset) begin
      if (reset == 1'b1) 
         mem_counter <= 16'b0;
         
      else
         mem_counter <= mem_counter + 1;
   end
   
   // Assign mem_adr based on mem_dump
   assign mem_Adr = dump_mem ? mem_counter[7:0] : Address;
   
      //-----------------------Memory----------------------
   ram1 memory(clk_out, mw_en, mem_Adr, RISC_Out, RISC_In); 


endmodule
