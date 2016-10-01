`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/14
 * Design Name: 	Pipeline CPU
 * Module Name:		Adder
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/

module Adder(
    input [32-1:0] src1_i,
	input [32-1:0] src2_i,
	output [32-1:0]	sum_o
);

	assign sum_o = $signed(src1_i) + $signed(src2_i);

endmodule
