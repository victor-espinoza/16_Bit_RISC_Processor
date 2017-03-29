`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author:   Victor Espinoza
// Partner:  Edward Mares
// Email:    victor.alfonso94@gmail.com
// Filename: CU.v
// Date:     December 05, 2013
// Version:  1.0
//
// Notes:    Control unit for a RISC 16-bit processor using Moore finite 
//           state logic. 
//
//////////////////////////////////////////////////////////////////////////////////

//*******************************************************************************
module CU(clk, reset, IR, N, Z, C,              // control unit inputs
          W_Adr, R_Adr, S_Adr,                  // these are
          adr_sel, s_sel,                       // the control
          pc_ld, pc_inc, pc_sel, ir_ld,         // word output
          mw_en, rw_en, alu_op,                 // fields
          status);                              // LED outputs
//*******************************************************************************

   input          clk, reset;                   //clk and reset
   input [15:0]   IR;                           //instruction register input
   input            N, Z, C;                    //datapath status inputs
   output [2:0]   W_Adr, R_Adr, S_Adr;          //register file address outputs
   output         adr_sel, s_sel;               //mux select outputs
   output         pc_ld, pc_inc, pc_sel, ir_ld; //pc load, pc inc, pc select, ir load
   output         mw_en, rw_en;                 //memory_write, register_file write
   output [3:0]   alu_op;                       //ALU opcode output
   output [7:0]   status;                       //8 LED outputs to display current 
                                                //state
   
   /*************************
    *      data structures    *
    *************************/
    
   reg [2:0]      W_Adr, R_Adr, S_Adr;      //these 12
   reg            adr_sel, s_sel;           //fields
   reg            pc_ld, pc_inc;            //make up 
   reg            pc_sel, ir_ld;            //the
   reg            mw_en, rw_en;             //control word      
   reg [3:0]      alu_op;                   //of the control unit
   
   reg [4:0]      state;                    // present state register
   reg [4:0]      nextstate;                // next state register
   reg [7:0]      status;                   // LED status/state outputs
   reg             ps_N, ps_Z, ps_C;        // present state flags register
   reg            ns_N, ns_Z, ns_C;         // next state flags register
   
   parameter   RESET=0, FETCH=1, DECODE=2, 
               ADD=3,   SUB=4,   CMP=5,    MOV=6,
               INC=7,   DEC=8,   SHL=9,    SHR=10,
               LD=11,   STO=12,  LDI=13,
               JE=14,   JNE=15,  JC=16,    JMP=17,
               HALT=18,
               ILLEGAL_OP=31;
               
   /**********************************
    *      301 Control Unit Sequencer  *
    **********************************/
    
   // synchronous state register assignment
   always @(posedge clk or posedge reset)
      if (reset)
         state = RESET;
      else
         state = nextstate;
         
   // synchrounout flags register assignment
   always @(posedge clk or posedge reset)
      if (reset)
         {ps_N, ps_Z, ps_C} = 3'b0;
      else
         {ps_N, ps_Z, ps_C} = {ns_N, ns_Z, ns_C};
         
   // combinational logic section for both next state logic
   // and control word for cpu_execution_unit and memory
   always @( state )
      case ( state )
      
         RESET:   begin      // Default Control Word Values  -- 
                           // LED pattern = 1111_1111
            W_Adr   = 3'b000; R_Adr  = 3'b000;  S_Adr = 3'b000; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = 3'b0;
            status = 8'hFF;
            nextstate = FETCH;
         end

         FETCH:   begin      // IR <-- M[PC], PC <- PC+1  -- 
                           // LED pattern = 1000_0000
            W_Adr   = 3'b000; R_Adr  = 3'b000;  S_Adr = 3'b000; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b1;   pc_sel = 1'b0;   ir_ld = 1'b1;   
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status = 8'h80;
            nextstate = DECODE;
         end   
         
         DECODE:   begin      //Default Control Word Values  -- 
                           //LED pattern = 1100_0000
            W_Adr   = 3'b000; R_Adr  = 3'b000;  S_Adr = 3'b000; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status = 8'hC0;
            case ( IR[15:12] )
               4'b0000: nextstate = ADD;
               4'b0001: nextstate = SUB;
               4'b0010: nextstate = CMP;
               4'b0011: nextstate = MOV;
               4'b0100: nextstate = SHL;
               4'b0101: nextstate = SHR;
               4'b0110: nextstate = INC;
               4'b0111: nextstate = DEC;
               4'b1000: nextstate = LD;
               4'b1001: nextstate = STO;
               4'b1010: nextstate = LDI;
               4'b1011: nextstate = HALT;
               4'b1100: nextstate = JE;
               4'b1101: nextstate = JNE;
               4'b1110: nextstate = JC;
               4'b1111: nextstate = JMP;
               default: nextstate = ILLEGAL_OP;
            endcase
         end
         
         ADD: begin      //R[ir(8:6)] <-- R[ir(5:3)] + R[ir(2:0)] -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b00000}
            W_Adr   = IR[8:6]; R_Adr  = IR[5:3];  S_Adr = IR[2:0]; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0010;
            {ns_N, ns_Z, ns_C} = {N, Z, C};      //flags have potential to change   
            status = {ps_N, ps_Z, ps_C, 5'b00000};
            nextstate = FETCH;            //go gack to fetch
         end

         SUB: begin      //R[ir(8:6)] <-- R[ir(5:3)] - R[ir(2:0)] -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b00001}
            W_Adr   = IR[8:6]; R_Adr  = IR[5:3];  S_Adr = IR[2:0]; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0011;
            {ns_N, ns_Z, ns_C} = {N, Z, C};      //flags have potential to change
            status = {ps_N, ps_Z, ps_C, 5'b00001};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         CMP: begin      //R[ir(5:3)] - R[ir(2:0)] -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b00010}
            W_Adr   = 3'b000; R_Adr  = IR[5:3];  S_Adr = IR[2:0]; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0011;
            {ns_N, ns_Z, ns_C} = {N, Z, C};      //flags have potential to change
            status = {ps_N, ps_Z, ps_C, 5'b00010};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         MOV: begin      //R[ir(8:6)] <-- R[ir(2:0)] -- 
                        //LED pattern = {ns_N, ns_Z, ns_C, 5'b00011}
            W_Adr   = IR[8:6]; R_Adr = 3'b000;  S_Adr = IR[2:0]; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status = {ns_N, ns_Z, ns_C, 5'b00011};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         SHL: begin      //R[ir(8:6)] <-- R[ir(2:0)] << 1 -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b00100}
            W_Adr   = IR[8:6]; R_Adr  = 3'b000;  S_Adr = IR[2:0]; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0110;
            {ns_N, ns_Z, ns_C} = {N, Z, C};      //flags have potential to change
            status = {ps_N, ps_Z, ps_C, 5'b00100};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         SHR: begin      //R[ir(8:6)] <-- R[ir(2:0)] >> 1 -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b00101}
            W_Adr   = IR[8:6]; R_Adr  = 3'b000;  S_Adr = IR[2:0]; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0111;
            {ns_N, ns_Z, ns_C} = {N, Z, C};      //flags have potential to change
            status = {ps_N, ps_Z, ps_C, 5'b00101};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         INC: begin      //R[ir(8:6)] <-- R[ir(2:0)] + 1 -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b00110}
            W_Adr   = IR[8:6]; R_Adr  = 3'b000;  S_Adr = IR[2:0]; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0100;
            {ns_N, ns_Z, ns_C} = {N, Z, C};      //flags have potential to change
            status = {ps_N, ps_Z, ps_C, 5'b00110};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         DEC: begin      //R[ir(8:6)] <-- R[ir(2:0)] - 1 -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b00111}
            W_Adr   = IR[8:6]; R_Adr  = 3'b000;  S_Adr = IR[2:0]; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0101;
            {ns_N, ns_Z, ns_C} = {N, Z, C};      //flags have potential to change
            status = {ps_N, ps_Z, ps_C, 5'b00111};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         LD: begin      //R[ir(8:6)] <-- M[ir(2:0)] -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b01000}
            W_Adr   = IR[8:6]; R_Adr = IR[2:0]; S_Adr = 3'b000; 
            adr_sel = 1'b1;   s_sel  = 1'b1;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status = {ps_N, ps_Z, ps_C, 5'b01000};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         STO: begin      //M[ir(8:6)] <-- R[ir(2:0)] -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b01001}
            W_Adr   = 3'b000; R_Adr  = IR[8:6]; S_Adr = IR[2:0]; 
            adr_sel = 1'b1;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b1;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status = {ps_N, ps_Z, ps_C, 5'b01001};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         LDI: begin      //R[ir(8:6)] <-- M[PC],  PC <-- PC + 1 -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b01010}
            W_Adr   = IR[8:6]; R_Adr = 3'b000;  S_Adr = 3'b000; 
            adr_sel = 1'b0;   s_sel  = 1'b1;
            pc_ld   = 1'b0;   pc_inc = 1'b1;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status = {ps_N, ps_Z, ps_C, 5'b01010};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         JE: begin      //if (ps_Z=1) PC <-- PC + se_IR[7:0] -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b01100}
            W_Adr   = 3'b000; R_Adr  = 3'b000;  S_Adr = 3'b000; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_inc  = 1'b0;   ir_ld  = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status  = {ps_N, ps_Z, ps_C, 5'b01100};
            if (ps_Z == 1)begin
               pc_ld  = 1'b1;
            end//end if
            else begin
               pc_ld  = 1'b0;
            end//end else
            nextstate = FETCH;            //go gack to fetch         
         end
         
         JNE: begin      //if (ps_Z=0) PC <-- PC + se_IR[7:0] -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b01101}
            W_Adr   = 3'b000; R_Adr  = 3'b000;  S_Adr = 3'b000; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_inc  = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b1;   
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status  = {ps_N, ps_Z, ps_C, 5'b01101};
            if (ps_Z == 0)begin
               pc_ld  = 1'b1;      
            end//end if
            else begin
               pc_ld  = 1'b0;
            end//end else
            nextstate = FETCH;            //go gack to fetch         
         end
         
         JC: begin      //if (ps_C=1) PC <-- PC + se_IR[7:0] -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b01110}
            W_Adr   = 3'b000; R_Adr  = 3'b000;  S_Adr = 3'b000; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_inc = 1'b0;     ir_ld = 1'b1;     pc_sel = 1'b0;
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status = {ps_N, ps_Z, ps_C, 5'b01110};
            if (ps_C == 1)begin
               pc_ld  = 1'b1;            
            end//end if
            else begin
               pc_ld  = 1'b0;
            end//end else
               
            nextstate = FETCH;            //go gack to fetch         
         end
         
         JMP: begin      //PC <-- R[ir(2:0)] -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b01111}
            W_Adr   = 3'b000; R_Adr  = IR[2:0];  S_Adr = IR[2:0]; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b1;   pc_inc = 1'b0;   pc_sel = 1'b1;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status  = {ps_N, ps_Z, ps_C, 5'b01111};
            nextstate = FETCH;            //go gack to fetch         
         end
         
         HALT: begin      //Default Control Word Values -- 
                        //LED pattern = {ps_N, ps_Z, ps_C, 5'b01011}
            W_Adr   = 3'b000; R_Adr  = 3'b000;  S_Adr = 3'b000; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status  = {ps_N, ps_Z, ps_C, 5'b01011};
            nextstate = HALT;               //loop here forever
         end
         
         ILLEGAL_OP: begin   //Default Control Word Values -- 
                           //LED pattern = 1111_0000
            W_Adr   = 3'b000; R_Adr  = 3'b000;  S_Adr = 3'b000; 
            adr_sel = 1'b0;   s_sel  = 1'b0;
            pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0;   ir_ld = 1'b0;   
            mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
            {ns_N, ns_Z, ns_C} = {ps_N, ps_Z, ps_C};      //flags remain the same
            status  = 8'hF0;            
            nextstate = ILLEGAL_OP;         //loop here forever   
         end   
         
      endcase      
endmodule
