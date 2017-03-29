`timescale 1ns / 1ps
/*********************************************************
* Class:      CECS 301 T-Th 2:00PM
* Designer:   Thien Tran; Steven Lam
* Instructor: R. W. Allison
*
* Project Number: 8
* Module Name:    Control Unit (FSM) 
* Project Name:   16-bit RISC Processor
* Rev. Date:      11/24/13 
*
* Purpose: A "Moore" finite state machine that implements 
*          the major cycles for fetching and executing 
*          instructions for the 301 16-bit RISC Processor
* Comments: 45 min
*************************************************************/
module cu(clk, reset, IR, C, N, Z,       // control unit inputs
          W_Adr, R_Adr, S_Adr,           // these are
			 adr_sel, s_sel,                //  the control
			 pc_ld, pc_inc, pc_sel, ir_ld,  //   word output
			 mw_en, rw_en, alu_op,          //    fields
			 status);                       // LED outputs
//***********************************************************

   input        clk, reset;                   // clock and reset
   input [15:0] IR;                           // instruction register input
   input        C, N, Z;                      // datapath status inputs
	output [2:0] W_Adr, R_Adr, S_Adr;          // register file address outputs
	output       adr_sel, s_sel;               // mux select outputs
   output       pc_ld, pc_inc, pc_sel, ir_ld; // pc load, pcinc, pc select, ir load
	output       mw_en, rw_en;                 // memory_write, register_file write
	output [3:0] alu_op;                       // ALU opcode output
	output [7:0] status;                       // 8 LED outputs to display current state
	
	/********************************
	 *     Internal Variables       *
	 ********************************/
	 
	reg [2:0] W_Adr, R_Adr, S_Adr;   // these 12
   reg       adr_sel, s_sel;
   reg       pc_ld, pc_inc;
   reg	    pc_sel, ir_ld;
	reg       mw_en, rw_en;
	reg [3:0] alu_op;
	
	reg [4:0] state;
	reg [4:0] nextstate;
	reg [7:0] status;
	reg       ps_N, ps_Z, ps_C;
	reg       ns_N, ns_Z, ns_C;
	
	parameter RESET=0, FETCH=1, DECODE=2,
	          ADD=3,   SUB=4,   CMP=5,   MOV=6,
				 INC=7,   DEC=8,   SHL=9,   SHR=10,
				 LD=11,   STO=12,  LDI=13,
				 JE=14,   JNE=15,  JC=16,   JMP=17,
				 HALT=18,
				 ILLEGAL_OP=31;
				 
	/********************************
	 *  301 Control Unit Sequencer  *
	 ********************************/	

   // synchronous state register assignment
   always @(posedge clk or posedge reset)
      if (reset)
         state = RESET;
      else
         state = nextstate;
			
	// synchronous flags register assignment
   always @(posedge clk or posedge reset)
      if (reset)
         {ps_N,ps_Z,ps_C} = 3'b0;
		else
		   {ps_N, ps_Z, ps_C} = {ns_N,ns_Z,ns_C};
			
	// combinational logic section for both next state logic
	// and control word for cpu_execution_unit and memory
	always @(state)
	  case (state)
	  
	  RESET: begin  // Default Control Word Values -- LED pattern = 1111_111
	      W_Adr   = 3'b000; R_Adr  = 3'b000; S_Adr  = 3'b000;
			adr_sel = 1'b0;   s_sel  = 1'b0;
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
         {ns_N,ns_Z,ns_C} = 3'b0;
         status = 8'hFF;
         nextstate = FETCH;
       end

       FETCH: begin  // IR <-- M[PC], PC <- PC+1 -- LED pattern = 1000_000
         W_Adr   = 3'b000; R_Adr  = 3'b000; S_Adr  = 3'b000;
			adr_sel = 1'b0;   s_sel  = 1'b0;
			pc_ld   = 1'b0;   pc_inc = 1'b1;   pc_sel = 1'b0; ir_ld = 1'b1;
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags remain the same
         status = 8'h80;
         nextstate = DECODE;
       end
       
       DECODE: begin  // Default Control Word Values -- LED pattern = 1100_0000
         W_Adr   = 3'b000; R_Adr  = 3'b000; S_Adr  = 3'b000;
			adr_sel = 1'b0;   s_sel  = 1'b0;
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000;
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags remain the same
         status = 8'hC0;
         case (IR[15:12])
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

       ADD: begin  // R[ir(8:6)] <-- R[ir(5:3)] + R[ir(2:0)] -- LED pattern = {ps_N,ps_Z,ps_C,5'b00000}
         // PUT CONTROL WORD FOR EXECUTION OF ADD HERE!!!
         W_Adr   = IR[8:6]; R_Adr  = IR[5:3]; S_Adr  = IR[2:0];
			adr_sel = 1'b0;   s_sel  = 1'b0; // s_sel is low to select S
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0010; // alu_op for add
         {ns_N,ns_Z,ns_C} = {N,Z,C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b00000};
         nextstate = FETCH;
       end	

       SUB: begin  // R[ir(8:6)] <-- R[ir(5:3)] - R[ir(2:0)] -- LED pattern = {ps_N,ps_Z,ps_C,5'b00001}
         // PUT CONTROL WORD FOR EXECUTION OF SUB HERE!!!
         W_Adr   = IR[8:6]; R_Adr  = IR[5:3]; S_Adr  = IR[2:0];
			adr_sel = 1'b0;   s_sel  = 1'b0; // s_sel is low to select S
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0011; // alu_op for sub
         {ns_N,ns_Z,ns_C} = {N,Z,C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b00001};
         nextstate = FETCH;
       end	
      
       CMP: begin  // R[ir(5:3)] - R[ir(2:0)] -- LED pattern = {ps_N,ps_Z,ps_C,5'b00010}
         // PUT CONTROL WORD FOR EXECUTION OF CMP HERE!!!
         W_Adr   = 3'b000; R_Adr  = IR[5:3]; S_Adr  = IR[2:0];
			adr_sel = 1'b0;   s_sel  = 1'b0; // s_sel is low to select S
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0011; // alu_op for subtract to compare
         {ns_N,ns_Z,ns_C} = {N,Z,C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b00010};
         nextstate = FETCH;
       end	

       MOV: begin  // R[ir(8:6)] <-- R[ir(2:0)] -- LED pattern = {ps_N,ps_Z,ps_C,5'b00011}
         // PUT CONTROL WORD FOR EXECUTION OF MOV HERE!!!
         W_Adr   = IR[8:6]; R_Adr  = 3'b000; S_Adr  = IR[2:0];
			adr_sel = 1'b0;   s_sel  = 1'b0; // s_sel is low to select S
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0000; // alu_op for Pass S to be moved to W's Adr
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b00011};
         nextstate = FETCH;
       end	

       SHL: begin  // R[ir(8:6)] <-- R[ir(2:0)] << 1 -- LED pattern = {ps_N,ps_Z,ps_C,5'b00100}
         // PUT CONTROL WORD FOR EXECUTION OF SHL HERE!!!
         W_Adr   = IR[8:6]; R_Adr  = 3'b000; S_Adr  = IR[2:0];
			adr_sel = 1'b0;   s_sel  = 1'b0; // s_sel is low to select S
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0110; // alu_op for shift left S
         {ns_N,ns_Z,ns_C} = {N,Z,C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b00100};
         nextstate = FETCH;
       end	
      
       SHR: begin  // R[ir(8:6)] <-- R[ir(2:0)] >> 1 -- LED pattern = {ps_N,ps_Z,ps_C,5'b00101}
         // PUT CONTROL WORD FOR EXECUTION OF SHR HERE!!!
         W_Adr   = IR[8:6]; R_Adr  = 3'b000; S_Adr  = IR[2:0];
			adr_sel = 1'b0;   s_sel  = 1'b0; // s_sel is low to select S
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0111; // alu_op for shift right S
         {ns_N,ns_Z,ns_C} = {N,Z,C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b00101};
         nextstate = FETCH;
       end	

       INC: begin  // R[ir(8:6)] <-- R[ir(2:0)] + 1-- LED pattern = {ps_N,ps_Z,ps_C,5'b00110}
         // PUT CONTROL WORD FOR EXECUTION OF INC HERE!!!
         W_Adr   = IR[8:6]; R_Adr  = 3'b000; S_Adr  = IR[2:0];
			adr_sel = 1'b0;   s_sel  = 1'b0; // s_sel is low to select S
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0100; // alu_op for increment S
         {ns_N,ns_Z,ns_C} = {N,Z,C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b00110};
         nextstate = FETCH;
       end	

       DEC: begin  // R[ir(8:6)] <-- R[ir(2:0)] - 1 -- LED pattern = {ps_N,ps_Z,ps_C,5'b00111}
         // PUT CONTROL WORD FOR EXECUTION OF DEC HERE!!!
         W_Adr   = IR[8:6]; R_Adr  = 3'b000; S_Adr  = IR[2:0];
			adr_sel = 1'b0;   s_sel  = 1'b0; // s_sel is low to select S
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0101; // alu_op for decrement S
         {ns_N,ns_Z,ns_C} = {N,Z,C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b00111};
         nextstate = FETCH;
       end	
      
       LD: begin  // R[ir(8:6)] <-- M[ir(2:0)] -- LED pattern = {ps_N,ps_Z,ps_C,5'b01000}
         // PUT CONTROL WORD FOR EXECUTION OF LOAD HERE!!!
         W_Adr   = IR[8:6]; R_Adr  = IR[2:0]; S_Adr  = 3'b000; // Not Using R/S_Adr
			adr_sel = 1'b1;   s_sel  = 1'b1; // s_sel is high to select D_out from memory
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0000; // alu_op for Load/Pass S (M[ir(2:0)])
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b01000};
         nextstate = FETCH;
       end	

       STO: begin  // M[ir(8:6)] <-- R[ir(2:0)] -- LED pattern = {ps_N,ps_Z,ps_C,5'b01001}
         // PUT CONTROL WORD FOR EXECUTION OF STO HERE!!!
         W_Adr   = 3'b000; R_Adr  = IR[8:6]; S_Adr  = IR[2:0]; // R_Adr is destination
			adr_sel = 1'b1;   s_sel  = 1'b0; // s_sel is low to select S and adr_sel is high to select R for destination
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0;
         mw_en   = 1'b1;   rw_en  = 1'b0;   alu_op = 4'b0000; // alu_op for Pass S; mw_en is high to write to memory at R_adr
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b01001};
         nextstate = FETCH;
       end	

       LDI: begin  // R[ir(8:6)] <-- M[PC], PC <-- PC + 1 -- LED pattern = {ps_N,ps_Z,ps_C,5'b01010}
         // PUT CONTROL WORD FOR EXECUTION OF LDI HERE!!!
         W_Adr   = IR[8:6]; R_Adr  = 3'b000; S_Adr  = 3'b000; // Writing to IR(8:6)
			adr_sel = 1'b0;   s_sel  = 1'b1; // s_sel is high to pass M[PC]; adr_sel is low to pass PC
			pc_ld   = 1'b0;   pc_inc = 1'b1;   pc_sel = 1'b0; ir_ld = 1'b0; // pc_inc is high to increment by one
         mw_en   = 1'b0;   rw_en  = 1'b1;   alu_op = 4'b0000; // alu_op for Pass S (M[PC])
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b01010};
         nextstate = FETCH;
       end	

       JE: begin  // if (ps_z=1) PC <-- PC + se_IR[7:0] -- LED pattern = {ps_N,ps_Z,ps_C,5'b01100}
         // PUT CONTROL WORD FOR EXECUTION OF JE HERE!!!
         if (ps_Z == 1) 
         pc_ld = 1'b1;
         else
         pc_ld = 1'b0;
         
         W_Adr   = 3'b000; R_Adr  = 3'b000; S_Adr  = 3'b000; // Not using any registers
			adr_sel = 1'b0;   s_sel  = 1'b0; // 
			pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0; // PC_sel is low to select se_IR[7:0]; pc_load is high to load signExt PC
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000; // alu_op for Pass S (But ALU is not being used)
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b01100};

         nextstate = FETCH;
       end	

       JNE: begin  // if (ps_z=0) PC <-- PC + se_IR[7:0] -- LED pattern = {ps_N,ps_Z,ps_C,5'b01101}
         // PUT CONTROL WORD FOR EXECUTION OF JNE HERE!!!
         if (ps_Z == 0) 
         pc_ld   = 1'b1;
         else
         pc_ld   = 1'b0;
         W_Adr   = 3'b000; R_Adr  = 3'b000; S_Adr  = 3'b000; // Not using any registers
			adr_sel = 1'b0;   s_sel  = 1'b0; // 
		   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b1; // PC_sel is low to select se_IR[7:0]; ir_ld is high to load ir for signExt; pc_load is high to load signExt PC
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000; // alu_op for Pass S (But ALU is not being used)
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b01101};
         nextstate = FETCH;
       end	
      
       JC: begin  // if (ps_C=1) PC <-- PC + se_IR[7:0] -- LED pattern = {ps_N,ps_Z,ps_C,5'b01110}  
         // PUT CONTROL WORD FOR EXECUTION OF JC HERE!!!
         if (ps_C == 1) 
         pc_ld   = 1'b1;
         else
         pc_ld   = 1'b0;
         W_Adr   = 3'b000; R_Adr  = 3'b000; S_Adr  = 3'b000; // Not using any registers
			adr_sel = 1'b0;   s_sel  = 1'b0; // 
			pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b1; // PC_sel is low to select se_IR[7:0]; ir_ld is high to load ir for signExt; pc_load is high to load signExt PC
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000; // alu_op for Pass S (But ALU is not being used)
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b01110};
         nextstate = FETCH;
       end	

       JMP: begin  // PC <-- R[ir(2:0)] -- LED pattern = {ps_N,ps_Z,ps_C,5'b01111}
         // PUT CONTROL WORD FOR EXECUTION OF JMP HERE!!!
         W_Adr   = 3'b000; R_Adr  = 3'b000; S_Adr  = IR[2:0]; // Using only S register
			adr_sel = 1'b0;   s_sel  = 1'b0; // s_sel is lwo to pass S (IR[2:0])
			pc_ld   = 1'b1;   pc_inc = 1'b0;   pc_sel = 1'b1; ir_ld = 1'b0; // pc_ls is high to load pc_mux value (ir[2:0]); pc_sel is high to to pass ir[2:0] into mux
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000; // alu_op for Pass S (ir[2:0])
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags change depending on operation
         status = {ps_N,ps_Z,ps_C,5'b01111};
         nextstate = FETCH;
       end	
       
       HALT: begin  // Default Control Word Values -- LED pattern = {ps_N,ps_Z,ps_C,5'b01011}
         // PUT CONTROL WORD FOR HALT HERE!!!
         W_Adr   = 3'b000; R_Adr  = 3'b000; S_Adr  = 3'b000; // No registers are used
			adr_sel = 1'b0;   s_sel  = 1'b0; // No signals are used
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0; // No signals are used
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000; // No signals are used
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags dont change
         status = {ps_N,ps_Z,ps_C,5'b01011};
         nextstate = HALT;                   // loop here forever
       end	

       ILLEGAL_OP: begin  // Default Control Word Values -- LED pattern = 1111_0000}
         // PUT CONTROL WORD FOR ILLEGAL OPCODE HERE!!!
         W_Adr   = 3'b000; R_Adr  = 3'b000; S_Adr  = 3'b000; // No registers are used
			adr_sel = 1'b0;   s_sel  = 1'b0; // No signals are used
			pc_ld   = 1'b0;   pc_inc = 1'b0;   pc_sel = 1'b0; ir_ld = 1'b0; // No signals are used
         mw_en   = 1'b0;   rw_en  = 1'b0;   alu_op = 4'b0000; // No signals are used
         {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};  // flags dont change
         status = 8'hF0;
         nextstate = ILLEGAL_OP;             // loop here forever
       end	
     endcase
        		 
endmodule
