`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/14
 * Design Name: 	Pipeline CPU
 * Module Name:		ALU
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/

module ALU(
    input [32-1:0] src1_i,
	input [32-1:0] src2_i,
	input [4-1:0] ctrl_i,
	output reg [32-1:0] result_o,
	output zero_o
);

	always @(*) begin
		case(ctrl_i)
			4'b0000:	result_o = src1_i & src2_i;	//AND
			4'b0001:	result_o = src1_i | src2_i;	//OR
			4'b0010:	result_o = $signed(src1_i) + $signed(src2_i);	//ADD
			4'b0110:	result_o = $signed(src1_i) - $signed(src2_i);	//SUB
			4'b0111:	result_o = ($signed(src1_i) < $signed(src2_i)) ? 32'd1 : 32'd0; //SLT
			4'b1100:	result_o = src1_i ^ src2_i;	//NOR
			default:	result_o = 32'd0;
		endcase
	end

	assign zero_o = (result_o == 32'd0) ? 1 : 0;

endmodule
