`timescale 1ns / 1ps
module Hazard_Detect(
	input MemRead_IDEX_i,
	input [5-1:0] RS_ID_IFID_i,
	input [5-1:0] RT_ID_IFID_i,
	input [5-1:0] RT_ID_IDEX_i,
	output PC_stall_o,
	output FIDreg_stall_o,
	output NopCtrl_o
);

	reg result_o;

	always @(*) begin
		if(MemRead_IDEX_i
		&& ((RT_ID_IDEX_i == RS_ID_IFID_i) || (RT_ID_IDEX_i == RT_ID_IFID_i)))
			result_o = 1;
		else
			result_o = 0;
	end
	
	assign PC_stall_o = result_o;
	assign FIDreg_stall_o = result_o;
	assign NopCtrl_o = result_o;

endmodule