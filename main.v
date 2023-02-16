module main(
	//External Clock (only apply to memory access)
	input clkExt,

	//External Memory Access
	input [15:0] memAddrExt,
	input [15:0] memDataExt,
	input memWEExt,
	output [15:0] memOutExt,

	//External RegFile Access
	input [2:0] regSelExt,
	output [15:0] regOutExt,

	//Component Information
	output [15:0] PCOut,
	output [15:0] IROut,
	output [15:0] MARMUXOut,
	output [15:0] BUS,
	output NVal,
	output ZVal,
	output PVal,
	output [5:0] FSM_state,

	//Processor Control
	input clk,
	input rst);


	//Component Output Wires
	wire [15:0] EABOut;
	wire [15:0] ALUOut;
	wire [15:0] SR1Out;
	wire [15:0] SR2Out;
	wire [15:0] MDROut;

	//FSM Control Wires
	//	TSB
	wire gateMARMUX;
	wire gatePC;
	wire gateALU;
	wire gateMDR;

	//	MUX
	wire selMARMUX;
	wire [1:0] selPCMUX;
	wire selADDR1MUX;
	wire [1:0] selADDR2MUX;
	wire selMDR;

	//	Load
	wire ldPC;
	wire ldReg;
	wire ldIR;
	wire ldMDR;
	wire ldMAR;

	//	Data / Control
	wire [2:0] dSR1;
	wire [2:0] dSR2;
	wire [2:0] dDR;
	wire [1:0] dALUK;
	wire dMemWE;

	//Misc.
	wire [15:0] ALURbIn;



	//Modules
	FSM FSM0(
		.IR (IROut),
		.BUS (BUS),
		.NVal (NVal),
		.ZVal (ZVal),
		.PVal (PVal),

		.gateMARMUX (gateMARMUX),
		.gatePC (gatePC),
		.gateALU (gateALU),
		.gateMDR (gateMDR),

		.selMARMUX (selMARMUX),	
		.selPCMUX (selPCMUX),
		.selADDR1MUX (selADDR1MUX),
		.selADDR2MUX (selADDR2MUX),
		.selMDR (selMDR),

		.ldPC (ldPC),
		.ldReg (ldReg),
		.ldIR (ldIR),
		.ldMDR (ldMDR),
		.ldMAR (ldMAR),

		.dSR1 (dSR1),
		.dSR2 (dSR2),
		.dDR (dDR),
		.dALUK (dALUK),
		.dMemWE (dMemWE),

		.FSM_state (FSM_state),

		.clk (clk),
		.rst (rst));

	PC PC0(
		.BUS (BUS),
		.EAB (EABOut),
		.ldPC (ldPC),
		.selPCMUX (selPCMUX),
		.PCOut (PCOut),
		.clk (clk),
		.rst (rst));

	TSB tsbPC(
		.in (PCOut),
		.en (gatePC),
		.out (BUS));

	IR IR0(
		.BUS (BUS),
		.ldIR (ldIR),
		.IROut (IROut),
		.clk (clk),
		.rst (rst));

	SR2MUX ALURb(
		.IRImm (IROut[4:0]),
		.SR2 (SR2Out),
		.SR2MUXOut (ALURbIn),
		.IR5 (IROut[5]));

	ALU ALU0(
		.Ra (SR1Out),
		.Rb (ALURbIn),
		.ALUK (dALUK),
		.ALUOut (ALUOut));

	TSB tsbALU(
		.in (ALUOut),
		.en (gateALU),
		.out (BUS));

	RegFile RegFile0(
		.SR1 (dSR1),
		.SR2 (dSR2),
		.DR (dDR),
		.R1 (SR1Out),
		.R2 (SR2Out),
		.BUS (BUS),
		.clk (clk),
		.ldReg (ldReg),
		.rst (rst),
		.regSelExt (regSelExt),
		.regOutExt (regOutExt));

	EAB EAB0(
		.IR (IROut),
		.SR1 (SR1Out),
		.PC (PCOut),
		.selADDR1MUX (selADDR1MUX),
		.selADDR2MUX (selADDR2MUX),
		.EABOut (EABOut));

	MARMUX MARMUX0(
		.IR (IROut),
		.EAB (EABOut),
		.sel (selMARMUX),
		.MARMUXOut (MARMUXOut));

	TSB tsbMARMUX(
		.in (MARMUXOut),
		.en (gateMARMUX),
		.out (BUS));

	RAM RAM0(
		.BUS (BUS),
		.MDROut (MDROut),
		.ldMDR (ldMDR),
		.ldMAR (ldMAR),
		.selMDR (selMDR),
		.memWE (dMemWE),
		.clk (clk),
		.rst (rst),

		//External Access
		.memAddrExt (memAddrExt),
		.memDataExt (memDataExt),
		.memWEExt (memWEExt),
		.memOutExt (memOutExt),
		.clkExt (clkExt));

	TSB tsbMDR(
		.in (MDROut),
		.en (gateMDR),
		.out (BUS));


	// We want to update cond. when the regFile is
	// being written, which is when ldReg is true,
	// where the data written is in the BUS.
	NZP NZP0(
		.BUS (BUS),
		.IR (IROut),
		.ldCC (ldReg),
		.NVal (NVal),
		.ZVal (ZVal),
		.PVal (PVal),
		.clk (clk),
		.rst (rst));

endmodule