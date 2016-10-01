`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/14
 * Design Name: 	Pipeline CPU
 * Module Name:		ALU_Ctrl
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/

module ALU_Ctrl(
	input [6-1:0] funct_i,
	input [3-1:0] ALUOp_i,
	output reg [4-1:0] ALUCtrl_o
);

	always@(*) begin
		case(ALUOp_i)
			3'b000:	ALUCtrl_o = 4'b0010; //LW SW
			3'b001:	ALUCtrl_o = 4'b0110; //BEQ
			3'b010: case(funct_i)
						6'b10_0000:	ALUCtrl_o = 4'b0010; //ADD
						6'b10_0010:	ALUCtrl_o = 4'b0110; //SUB
						6'b10_0100:	ALUCtrl_o = 4'b0000; //AND
						6'b10_0101:	ALUCtrl_o = 4'b0001; //OR
						6'b10_1010:	ALUCtrl_o = 4'b0111; //SLT
						default:	ALUCtrl_o = 4'b0000;
					endcase
			3'b011:	ALUCtrl_o = 4'b0111;
			default:ALUCtrl_o = 4'b0000;
		endcase
	end

endmodule
