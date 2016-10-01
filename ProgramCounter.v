`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/15
 * Design Name: 	Pipeline CPU
 * Module Name:		ProgramCounter 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/

module ProgramCounter(
    input clk_i,
	input rst_i,
	input PCWrite,
	input [32-1:0] pc_in_i,
	output reg [32-1:0] pc_out_o
);
    
	//Main function
	always @(posedge clk_i) begin
		if(~rst_i) pc_out_o <= 0;
		else if(PCWrite) pc_out_o <= pc_in_i;
		else pc_out_o <= pc_out_o;
	end

endmodule