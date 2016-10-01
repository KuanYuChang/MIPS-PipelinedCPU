`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/14
 * Design Name: 	Pipeline CPU
 * Module Name:		Instr_Memory 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 ******************************************************************/
 
`define INSTR_NUM 1024
module Instr_Memory(
    pc_addr_i,
	instr_o
	);
     
//I/O ports
input  [32-1:0]  pc_addr_i;
output [32-1:0]	 instr_o;

//Internal Signals
reg    [32-1:0]	 instr_o;
integer          i;

//32 words Memory
/*DO NOT CHANGE INSTRUCTION MEM SIZE*/	
reg    [32-1:0]  Instr_Mem [0:`INSTR_NUM-1];

//Parameter
    
//Main function
always @(pc_addr_i) begin
	instr_o = Instr_Mem[pc_addr_i/4];
end
    
//Initial Memory Contents
initial begin
	for ( i=0; i<32; i=i+1 )
		Instr_Mem[i] = 32'b0; 	
end
endmodule