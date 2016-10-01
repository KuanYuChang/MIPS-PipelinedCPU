`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/03
 * Design Name: 	Pipeline CPU
 * Module Name:		Pipe_CPU
 * Project Name: 	Architecture Project_3 Pipeline CPU
 *
 * Please DO NOT change the module name, or your'll get ZERO point.
 * You should add your code here to complete the project 3.
 ******************************************************************/
module Pipe_CPU(
	input clk_i,
	input rst_i
);

/****************************************
 *          Internal signal             *
 ****************************************/

/**** IF stage ****/
wire [32-1:0]	nextPC;
wire [32-1:0]	instAddr;
wire [32-1:0]	IF_PCadd4;
wire [32-1:0]	IF_inst;

/**** ID stage ****/
wire [32-1:0]	ID_PCadd4;
wire [32-1:0]	ID_inst;
wire [32-1:0]	ID_RSdata;
wire [32-1:0]	ID_RTdata;
wire [32-1:0]	ID_imm_32;
wire [32-1:0]	ID_imm_32_sht_2;
wire [32-1:0]	ID_PCaddImm;
wire [3-1:0]	ID_ALU_op;

/**** EX stage ****/
wire [32-1:0]	EX_RSdata;
wire [32-1:0]	EX_RTdata;
wire [32-1:0]	EX_ALUresult;
wire [32-1:0]	EX_imm_32;
wire [32-1:0]	RT_RD_data;
wire [32-1:0]	ALU_src1;
wire [32-1:0]	ALU_src2;
wire [5-1:0]	EX_RSaddr;
wire [5-1:0]	EX_RTaddr;
wire [5-1:0]	EX_RDaddr;
wire [5-1:0]	EX_WriteAddr;
wire [4-1:0]	ALUCtrl;
wire [3-1:0]	EX_ALU_op;
wire [2-1:0]	ForwardA;
wire [2-1:0]	ForwardB;

/**** MEM stage ****/
wire [32-1:0]	MEM_ALUresult;
wire [32-1:0]	MEM_RTdata;
wire [32-1:0]	MEM_DMread;
wire [5-1:0]	MEM_WriteAddr;

/**** WB stage ****/
wire [32-1:0]	WB_WriteData;
wire [32-1:0]	WB_DMread;
wire [32-1:0]	WB_ALUresult;
wire [5-1:0]	WB_WriteAddr;

/********************************************
 *       	Instantiate modules            	*
 *	Instantiate the components in IF stage	*
 ********************************************/

ProgramCounter PC(
	.clk_i		(clk_i),
	.rst_i		(rst_i),
	.PCWrite	(~PC_stall),
	.pc_in_i	(nextPC[32-1:0]),
	.pc_out_o	(instAddr[32-1:0]));

Instr_Memory IM(
	.pc_addr_i	(instAddr[32-1:0]),
	.instr_o	(IF_inst[32-1:0]));

Adder Add_pc(
	.src1_i	(instAddr[32-1:0]),
	.src2_i	(32'd4),
	.sum_o	(IF_PCadd4[32-1:0]));

MUX_2to1 #(.size(32)) MUX_PC(
	.data0_i	(IF_PCadd4[32-1:0]),
	.data1_i	(ID_PCaddImm[32-1:0]),
	.select_i	(ID_Branch & (ID_RSdata[32-1:0] == ID_RTdata[32-1:0])),
	.data_o		(nextPC[32-1:0]));

Pipe_Reg #(.size(32)) IF_ID_PCadd4(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(~FIDreg_stall),
	.flush	(ID_Branch & (ID_RSdata[32-1:0] == ID_RTdata[32-1:0])),
	.data_i	(IF_PCadd4[32-1:0]),
	.data_o	(ID_PCadd4[32-1:0]));

Pipe_Reg #(.size(32)) IF_ID_inst(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(~FIDreg_stall),
	.flush	(ID_Branch & (ID_RSdata[32-1:0] == ID_RTdata[32-1:0])),
	.data_i	(IF_inst[32-1:0]),
	.data_o	(ID_inst[32-1:0]));

/********************************************
 *       	Instantiate modules            	*
 *	Instantiate the components in ID stage	*
 ********************************************/

Reg_File RF(
	.clk_i		(clk_i),
	.rst_i		(rst_i),
	.RSaddr_i	(ID_inst[25:21]),
	.RTaddr_i	(ID_inst[20:16]),
	.RDaddr_i	(WB_WriteAddr[5-1:0]),
	.RDdata_i	(WB_WriteData[32-1:0]),
	.RegWrite_i	(WB_RegWrite),
	.RSdata_o	(ID_RSdata[32-1:0]),
	.RTdata_o	(ID_RTdata[32-1:0]));

Decoder Control(
	.instr_op_i	(ID_inst[31:26]),
	.ALUSrc_o	(ID_ALUSrc),
	.ALU_op_o	(ID_ALU_op[3-1:0]),
	.RegDst_o	(ID_RegDst),
	.MemWrite_o	(ID_MemWrite),
	.MemRead_o	(ID_MemRead),
	.Branch_o	(ID_Branch),
	.RegWrite_o	(ID_RegWrite),
	.MemtoReg_o	(ID_MemtoReg));

Sign_Extend Sign_Extend(
	.data_i	(ID_inst[16-1:0]),
	.data_o	(ID_imm_32[32-1:0]));

Hazard_Detect HD(
	.MemRead_IDEX_i	(EX_MemRead),
	.RS_ID_IFID_i	(ID_inst[25:21]),
	.RT_ID_IFID_i	(ID_inst[20:16]),
	.RT_ID_IDEX_i	(EX_RTaddr[5-1:0]),
	.PC_stall_o		(PC_stall),
	.FIDreg_stall_o	(FIDreg_stall),
	.NopCtrl_o		(NopCtrl));

Shift_Left_Two_32 Shift_Left_2(
	.data_i	(ID_imm_32[32-1:0]),
	.data_o	(ID_imm_32_sht_2[32-1:0]));

Adder pc_imm(
	.src1_i	(ID_PCadd4[32-1:0]),
	.src2_i	(ID_imm_32_sht_2[32-1:0]),
	.sum_o	(ID_PCaddImm[32-1:0]));

Pipe_Reg #(.size(1)) ID_EX_ALUSrc(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(NopCtrl),
	.data_i	(ID_ALUSrc),
	.data_o	(EX_ALUSrc));

Pipe_Reg #(.size(3)) ID_EX_ALU_op(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(NopCtrl),
	.data_i	(ID_ALU_op[3-1:0]),
	.data_o	(EX_ALU_op[3-1:0]));

Pipe_Reg #(.size(1)) ID_EX_RegDst(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(NopCtrl),
	.data_i	(ID_RegDst),
	.data_o	(EX_RegDst));

Pipe_Reg #(.size(1)) ID_EX_MemWrite(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(NopCtrl),
	.data_i	(ID_MemWrite),
	.data_o	(EX_MemWrite));

Pipe_Reg #(.size(1)) ID_EX_MemRead(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(NopCtrl),
	.data_i	(ID_MemRead),
	.data_o	(EX_MemRead));

Pipe_Reg #(.size(1)) ID_EX_RegWrite(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(NopCtrl),
	.data_i	(ID_RegWrite),
	.data_o	(EX_RegWrite));

Pipe_Reg #(.size(1)) ID_EX_MemtoReg(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(NopCtrl),
	.data_i	(ID_MemtoReg),
	.data_o	(EX_MemtoReg));

Pipe_Reg #(.size(32)) ID_EX_RSdata(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(ID_RSdata[32-1:0]),
	.data_o	(EX_RSdata[32-1:0]));

Pipe_Reg #(.size(32)) ID_EX_RTdata(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(ID_RTdata[32-1:0]),
	.data_o	(EX_RTdata[32-1:0]));

Pipe_Reg #(.size(32)) ID_EX_imm_32(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(ID_imm_32[32-1:0]),
	.data_o	(EX_imm_32[32-1:0]));

Pipe_Reg #(.size(5)) ID_EX_RSaddr(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(ID_inst[25:21]),
	.data_o	(EX_RSaddr[5-1:0]));

Pipe_Reg #(.size(5)) ID_EX_RTaddr(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(ID_inst[20:16]),
	.data_o	(EX_RTaddr[5-1:0]));

Pipe_Reg #(.size(5)) ID_EX_RDaddr(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(ID_inst[15:11]),
	.data_o	(EX_RDaddr[5-1:0]));

/********************************************
 *       	Instantiate modules            	*
 *	Instantiate the components in EX stage	*
 ********************************************/

ALU ALU(
	.src1_i		(ALU_src1[32-1:0]),
	.src2_i		(ALU_src2[32-1:0]),
	.ctrl_i		(ALUCtrl[4-1:0]),
	.result_o	(EX_ALUresult[32-1:0]),
	.zero_o		(EX_zero));

ALU_Ctrl ALU_Ctrl(
	.funct_i	(EX_imm_32[6-1:0]),
	.ALUOp_i	(EX_ALU_op[3-1:0]),
	.ALUCtrl_o	(ALUCtrl[4-1:0]));

MUX_2to1 #(.size(32)) MUX_RT_RD_data(
	.data0_i	(RT_RD_data[32-1:0]),
	.data1_i	(EX_imm_32[32-1:0]),
	.select_i	(EX_ALUSrc),
	.data_o		(ALU_src2[32-1:0]));

MUX_2to1 #(.size(5)) MUX_WriteAddr(
	.data0_i	(EX_RTaddr[5-1:0]),
	.data1_i	(EX_RDaddr[5-1:0]),
	.select_i	(EX_RegDst),
	.data_o		(EX_WriteAddr[5-1:0]));

MUX_3to1 #(.size(32)) MUX_ALU_src1(
	.data0_i	(EX_RSdata[32-1:0]),
	.data1_i	(WB_WriteData[32-1:0]),
	.data2_i	(MEM_ALUresult[32-1:0]),
	.select_i	(ForwardA[2-1:0]),
	.data_o		(ALU_src1[32-1:0]));

MUX_3to1 #(.size(32)) MUX_ALU_src2(
	.data0_i	(EX_RTdata[32-1:0]),
	.data1_i	(WB_WriteData[32-1:0]),
	.data2_i	(MEM_ALUresult[32-1:0]),
	.select_i	(ForwardB[2-1:0]),
	.data_o		(RT_RD_data[32-1:0]));

ForwardinUnit FU(
	.EX_MEMRegWrite		(MEM_RegWrite),
	.MEM_WBRegWrite		(WB_RegWrite),
	.EX_MEMRegisterRd	(MEM_WriteAddr[5-1:0]),
	.MEM_WBRegisterRd	(WB_WriteAddr[5-1:0]),
	.ID_EXRegisterRs	(EX_RSaddr[5-1:0]),
	.ID_EXRegisterRt	(EX_RTaddr[5-1:0]),
	.ForwardA			(ForwardA[2-1:0]),
	.ForwardB			(ForwardB[2-1:0]));

Pipe_Reg #(.size(1)) EX_MEM_MemWrite(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(EX_MemWrite),
	.data_o	(MEM_MemWrite));

Pipe_Reg #(.size(1)) EX_MEM_MemRead(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(EX_MemRead),
	.data_o	(MEM_MemRead));

Pipe_Reg #(.size(1)) EX_MEM_RegWrite(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(EX_RegWrite),
	.data_o	(MEM_RegWrite));

Pipe_Reg #(.size(1)) EX_MEM_MemtoReg(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(EX_MemtoReg),
	.data_o	(MEM_MemtoReg));

Pipe_Reg #(.size(32)) EX_MEM_ALUresult(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(EX_ALUresult[32-1:0]),
	.data_o	(MEM_ALUresult[32-1:0]));

Pipe_Reg #(.size(32)) EX_MEM_RTdata(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(RT_RD_data[32-1:0]),
	.data_o	(MEM_RTdata[32-1:0]));

Pipe_Reg #(.size(5)) EX_MEM_WriteAddr(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(EX_WriteAddr[5-1:0]),
	.data_o	(MEM_WriteAddr[5-1:0]));

/********************************************
 *       	Instantiate modules            	*
 *	Instantiate the components in MEM stage	*
 ********************************************/

Data_Memory DM(
	.clk_i		(clk_i),
	.rst_i		(rst_i),
	.addr_i		(MEM_ALUresult[32-1:0]),
	.data_i		(MEM_RTdata[32-1:0]),
	.MemRead_i	(MEM_MemRead),
	.MemWrite_i	(MEM_MemWrite),
	.data_o		(MEM_DMread[32-1:0]));

Pipe_Reg #(.size(1)) MEM_WB_RegWrite(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(MEM_RegWrite),
	.data_o	(WB_RegWrite));

Pipe_Reg #(.size(1)) MEM_WB_MemtoReg(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(MEM_MemtoReg),
	.data_o	(WB_MemtoReg));

Pipe_Reg #(.size(32)) MEM_WB_DMread(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(MEM_DMread[32-1:0]),
	.data_o	(WB_DMread[32-1:0]));

Pipe_Reg #(.size(32)) MEM_WB_ALUresult(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(MEM_ALUresult[32-1:0]),
	.data_o	(WB_ALUresult[32-1:0]));

Pipe_Reg #(.size(5)) MEM_WB_WriteAddr(
	.clk_i	(clk_i),
	.rst_i	(rst_i),
	.write	(1'b1),
	.flush	(1'b0),
	.data_i	(MEM_WriteAddr[5-1:0]),
	.data_o	(WB_WriteAddr[5-1:0]));

/********************************************
 *       	Instantiate modules            	*
 *	Instantiate the components in WB stage	*
 ********************************************/

MUX_2to1 #(.size(32)) Mux3(
	.data0_i	(WB_ALUresult[32-1:0]),
	.data1_i	(WB_DMread[32-1:0]),
	.select_i	(WB_MemtoReg),
	.data_o		(WB_WriteData[32-1:0]));

endmodule
