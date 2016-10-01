`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/14
 * Design Name: 	Pipeline CPU
 * Module Name:		Sign_Extend 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/

module Sign_Extend(
	input [16-1:0] data_i,
    output [32-1:0] data_o
);

	assign data_o = $signed(data_i);

endmodule