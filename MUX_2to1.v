`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/14
 * Design Name: 	Pipeline CPU
 * Module Name:		MUX_2to1 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/
     
module MUX_2to1(
	data0_i,
	data1_i,
	select_i,
	data_o
);

	parameter size = 0;
	
	input [size-1:0] data0_i;
	input [size-1:0] data1_i;
	input select_i;
	output reg [size-1:0] data_o;
	
	always @(*) begin
		case(select_i)
			1'b1:	data_o = data1_i;
			1'b0:	data_o = data0_i;
		endcase
	end

endmodule 