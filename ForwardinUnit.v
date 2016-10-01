`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/03
 * Design Name: 	Pipeline CPU
 * Module Name:		ForwardinUnit 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 
 * Please DO NOT change the module name, or your'll get ZERO point.
 * You should add your code here to complete the project 3 (bonus.)
 ******************************************************************/
 
module ForwardinUnit(
	input EX_MEMRegWrite,
	input MEM_WBRegWrite,
	input [4:0] EX_MEMRegisterRd,
	input [4:0] MEM_WBRegisterRd,
	input [4:0] ID_EXRegisterRs,
	input [4:0] ID_EXRegisterRt,
	output reg [1:0] ForwardA,
	output reg [1:0] ForwardB
);
	
	//ForwardA
	always @(*) begin
		if(EX_MEMRegWrite 
		&& (EX_MEMRegisterRd != 0) 
		&& (EX_MEMRegisterRd == ID_EXRegisterRs))
			ForwardA = 2'b10;
		else if(MEM_WBRegWrite 
		&& (MEM_WBRegisterRd != 0) 
		&& (EX_MEMRegisterRd != ID_EXRegisterRs) 
		&& (MEM_WBRegisterRd == ID_EXRegisterRs))
			ForwardA = 2'b01;
		else
			ForwardA = 2'b00;
	end
	
	//ForwardB
	always @(*) begin
		if(EX_MEMRegWrite 
		&& (EX_MEMRegisterRd != 0) 
		&& (EX_MEMRegisterRd == ID_EXRegisterRt))
			ForwardB = 2'b10;
		else if(MEM_WBRegWrite 
		&& (MEM_WBRegisterRd != 0) 
		&& (EX_MEMRegisterRd != ID_EXRegisterRt) 
		&& (MEM_WBRegisterRd == ID_EXRegisterRt))
			ForwardB = 2'b01;
		else
			ForwardB = 2'b00;
	end

endmodule
