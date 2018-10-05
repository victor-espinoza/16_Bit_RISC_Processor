# Lab_8_16_Bit_RISC_Processor
Project Overview: 
Fully functioning 16-Bit RISC Processor using Verilog.  
  
In this project, we complete the CECS 301 16-bit RISC Processor. This is done by connecting the CPU_EU with a timing and control unit (CU) Verilog module and the 256x16 Memory (developed in Lab_7). The CU is a Moore implementation of a finite state machine, where the outputs (control signals for the CPU_EU and Memory) are a function of the present state. The CU controls the execution of instructions for our 301 RISC Processor.  
  
In order for our RISC processor to be able to execute both conditional and unconditional jump instructions, we needed to modify the CPU_EU module developed in Lab_7. The conditional jump instruction requires the PC to be loaded with 16-bit values that are relative to its current value. Almost all processors do "releative jumps" by adding the current contents of the PC to a signed "offset". If the offset is expressed in less bits than the PC itself (as is usually the case) then there must be a "sign extension" of the offset to make it the same size as the PC before the addition. Adding this sign extension to the CPU_EU addresses this problem and allows the RISC processor to execute both types of jumps.

Here is the schematic for this project:
![ScreenShot](https://cloud.githubusercontent.com/assets/14812721/24825980/8ac514e8-1be0-11e7-9af7-ba3486b6dc6e.jpg)

Dependencies:   
This project was created using Xilinx ISE Project Navigator Version: 14.7.  
  
Project Verification:   
In order to verify that all of the instructions of our RISC Processor are working, we needed to execute (by stepping through) the instructions for all three memory modules. The binary content of the memory modules that we generated are shown below. We needed to complete each page by disassembling the machine code, filling in the "Register Written" column (where applicable), filling in the final contents of the CPU and Memory registers that were written to by the program that was executed and writing down the exact number of instructions that were executed. This was verified by stepping through the program on the Nexys2 board and verifying that our derived contents and those displayed on the Nexys2 board 7-segment-displays were the same.
Page 1:  
![ScreenShot](https://cloud.githubusercontent.com/assets/14812721/24825982/96805fae-1be0-11e7-9a8d-edb942e12555.jpg)  
  
Page 2:  
![ScreenShot](https://cloud.githubusercontent.com/assets/14812721/24825984/9f758dfa-1be0-11e7-9ca2-33d565da7954.jpg)  
  
Page 3:  
![ScreenShot](https://cloud.githubusercontent.com/assets/14812721/24825985/a5a9620a-1be0-11e7-9a1b-dff0c7bc098d.jpg)  
