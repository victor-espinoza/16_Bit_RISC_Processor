`timescale 1ns / 1ps
/****************************************************************************
 *
 * Author:   Edward Mares
 * Partner:  Victor Espinoza
 * Email:    eddy.mares@gmail.com
 * Filename: decoder_3_to_8.v
 * Date:     October 26, 2013
 * Version:  1.1
 *
 * Notes:    This decoder consists of three inputs and eight outputs. In 
 *           order for the decoder to function, the enable must be 
 *           asserted. Depending on what the input value is, the appropriate
 *           output values are assigned to the eight outputs, assuming that
 *           the enable is asserted.
 *
 ***************************************************************************/
module decoder_3_to_8(din, en, y7, y6, y5, y4, y3, y2, y1, y0);
        input [2:0] din;
        input       en;
        output reg  y7, y6, y5, y4, y3, y2, y1, y0;
        
        always@(din or en) 
            if(en)
               case(din)
                  3'b000:  {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b00000001;
                  3'b001:  {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b00000010;
                  3'b010:  {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b00000100;
                  3'b011:  {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b00001000;
                  3'b100:  {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b00010000;
                  3'b101:  {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b00100000;
                  3'b110:  {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b01000000;
                  3'b111:  {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b10000000;
                  default: {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b00000000;
               endcase
            else
                  {y7,y6,y5,y4,y3,y2,y1,y0} = 8'b00000000;
                  
endmodule