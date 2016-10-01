`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/14
 * Design Name: 	Pipeline CPU
 * Module Name:		Shift_Left_Two_32 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/

module Shift_Left_Two_32(
	input [32-1:0] data_i,
	output [32-1:0] data_o
);
	
	assign data_o = data_i << 2;
	
endmodule