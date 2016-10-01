`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/14
 * Design Name: 	Pipeline CPU
 * Module Name:		Decoder
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/

module Decoder(
	input [6-1:0] instr_op_i,
	output ALUSrc_o,
	output [3-1:0] ALU_op_o,
	output RegDst_o,
	output MemWrite_o,
	output MemRead_o,
	output Branch_o,
	output RegWrite_o,
	output MemtoReg_o
);

	reg [10-1:0] dec;

	always @(*) begin
		case(instr_op_i)
			6'b00_0000:	dec = 10'b1001000_010;	//R-type
			6'b10_0011:	dec = 10'b0111100_000;	//LW
			6'b10_1011:	dec = 10'b0100010_000;	//SW
			6'b00_0100:	dec = 10'b0000001_001;	//BEQ
			6'b00_1000:	dec = 10'b0101000_000;	//ADDI
			6'b00_1010:	dec = 10'b0101000_011;	//SLTI
			default:	dec = 10'b1111111_111;
		endcase
	end

	assign RegDst_o   = dec[9];
	assign ALUSrc_o   = dec[8];
	assign MemtoReg_o = dec[7];
	assign RegWrite_o = dec[6];
	assign MemRead_o  = dec[5];
	assign MemWrite_o = dec[4];
	assign Branch_o   = dec[3];
	assign ALU_op_o   = dec[2:0];

endmodule
