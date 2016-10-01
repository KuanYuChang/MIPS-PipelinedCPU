`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/14
 * Design Name: 	Pipeline CPU
 * Module Name:		MUX_3to1 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/
     
module MUX_3to1(
	data0_i,
	data1_i,
	data2_i,
	select_i,
	data_o
);

	parameter size = 0;
	
	input [size-1:0] data0_i;
	input [size-1:0] data1_i;
	input [size-1:0] data2_i;
	input [2-1:0] select_i;
	output [size-1:0] data_o;
	wire [size-1:0] w;
	
	MUX_2to1 #(.size(size)) d1(
		.data0_i(data0_i),
		.data1_i(data2_i),
		.select_i(select_i[1]),
		.data_o(w)
	);
	
	MUX_2to1 #(.size(size)) d0(
		.data0_i(w),
		.data1_i(data1_i),
		.select_i(select_i[0]),
		.data_o(data_o)
	);

endmodule 