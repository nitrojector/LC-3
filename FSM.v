module FSM(
	//Inputs
	input [15:0] IR,
	input [15:0] BUS,
	input NVal,
	input ZVal,
	input PVal,
	//TSB Control
	output reg gateMARMUX,
	output reg gatePC,
	output reg gateALU,
	output reg gateMDR,
	//MUX
	output reg selMARMUX,	
	output reg [1:0] selPCMUX,
	output reg selADDR1MUX,
	output reg [1:0] selADDR2MUX,
	output reg selMDR,
	//Load
	output reg ldPC,
	output reg ldReg,
	output reg ldIR,
	output reg ldMDR,
	output reg ldMAR,
	//Data / Control
	output reg [2:0] dSR1,
	output reg [2:0] dSR2,
	output reg [2:0] dDR,
	output reg [1:0] dALUK,
	output reg dMemWE,
	//FSM State Output
	output reg [5:0] FSM_state,
	//Processor
	input clk,
	input rst);

	reg [5:0] FSM_next;

	initial
		FSM_state <= 6'd63;

	always @ (negedge clk)
		FSM_state <= FSM_next;

	// always @ (posedge rst)
	// 	FSM_state <= 6'd33;

	always @ (posedge clk) begin
		case (FSM_state)

			// ===> FETCH

			18: begin
				// MAR <- PC
				// PC <- PC + 1

				// TSBs
				gateMARMUX <= 0; gatePC <= 1;        gateALU <= 0;      gateMDR <= 0;
				// SEL
				selMARMUX <= 0;	 selPCMUX <= 2'b00;  selADDR1MUX <= 0;  selADDR2MUX <= 2'b00;  selMDR <= 0;
				// LOAD
				ldPC <= 1;       ldReg <= 0;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 1;

				FSM_next <= 6'd33;
			end

			33: begin
				// MDR <- m[MAR]

				// TSBs
				gateMARMUX <= 0; gatePC <= 0;        gateALU <= 0;      gateMDR <= 0;
				// SEL
				selMARMUX <= 0;	 selPCMUX <= 2'b00;  selADDR1MUX <= 0;  selADDR2MUX <= 2'b00;  selMDR <= 1;
				// LOAD
				ldPC <= 0;       ldReg <= 0;         ldIR <= 0;         ldMDR <= 1;            ldMAR <= 0;

				FSM_next <= 6'd35;
			end

			35: begin
				// IR <- MDR

				// TSBs
				gateMARMUX <= 0; gatePC <= 0;        gateALU <= 0;      gateMDR <= 1;
				// SEL
				selMARMUX <= 0;	 selPCMUX <= 2'b00;  selADDR1MUX <= 0;  selADDR2MUX <= 2'b00;  selMDR <= 0;
				// LOAD
				ldPC <= 0;       ldReg <= 0;         ldIR <= 1;         ldMDR <= 0;            ldMAR <= 0;

				FSM_next <= 6'd32;
			end

			// <=== FETCH

			// ===> DECODE

			32: begin
				// FSM_next <- IR[15:12]

				// TSBs
				gateMARMUX <= 0; gatePC <= 0;        gateALU <= 0;      gateMDR <= 0;
				// SEL
				selMARMUX <= 0;	 selPCMUX <= 2'b00;  selADDR1MUX <= 0;  selADDR2MUX <= 2'b00;  selMDR <= 0;
				// LOAD
				ldPC <= 0;       ldReg <= 0;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 0;

				FSM_next <= { 2'b00, IR[15:12] };
			end

			// <=== DECODE

			// ===> EXECUTE

			1: begin
				// ADD+
				// DR <- SR1 + [SR2 / SEXT[imm5]]

				// TSBs
				gateMARMUX <= 0; gatePC <= 0;        gateALU <= 1;      gateMDR <= 0;
				// LOAD
				ldPC <= 0;       ldReg <= 1;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 0;
				// DATA CTRL
				dSR1 <= IR[8:6]; dSR2 <= IR[2:0];    dDR <= IR[11:9];   dALUK <= 2'b00;        dMemWE <= 0;

				FSM_next <= 6'd18;
			end

			5: begin
				// AND+
				// DR <- SR1 & [SR2 / SEXT[imm5]]

				// TSBs
				gateMARMUX <= 0; gatePC <= 0;        gateALU <= 1;      gateMDR <= 0;
				// LOAD
				ldPC <= 0;       ldReg <= 1;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 0;
				// DATA CTRL
				dSR1 <= IR[8:6]; dSR2 <= IR[2:0];    dDR <= IR[11:9];   dALUK <= 2'b01;        dMemWE <= 0;

				FSM_next <= 6'd18;
			end

			9: begin
				// NOT
				// DR <- ~SR

				// TSBs
				gateMARMUX <= 0; gatePC <= 0;        gateALU <= 1;      gateMDR <= 0;
				// LOAD
				ldPC <= 0;       ldReg <= 1;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 0;
				// DATA CTRL
				dSR1 <= IR[8:6]; dSR2 <= 3'b000;     dDR <= IR[11:9];   dALUK <= 2'b10;        dMemWE <= 0;

				FSM_next <= 6'd18;
			end

			15: begin
				// TRAP s0
				// MAR <- ZEXT[IR[7:0]]

				// TSBs
				gateMARMUX <= 1; gatePC <= 0;        gateALU <= 0;      gateMDR <= 0;
				// SEL
				selMARMUX <= 0;	 selPCMUX <= 2'b00;  selADDR1MUX <= 0;  selADDR2MUX <= 2'b00;  selMDR <= 0;
				// LOAD
				ldPC <= 0;       ldReg <= 0;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 1;
				// DATA CTRL
				dSR1 <= 3'b000;  dSR2 <= 3'b000;     dDR <= 3'b000;     dALUK <= 2'b11;        dMemWE <= 0;

				FSM_next <= 6'd28;
			end

			28: begin
				// TRAP s1
				// MDR <- m[MAR]
				// R7 <- PC

				// TSBs
				gateMARMUX <= 0; gatePC <= 1;        gateALU <= 0;      gateMDR <= 0;
				// SEL
				selMARMUX <= 0;	 selPCMUX <= 2'b00;  selADDR1MUX <= 0;  selADDR2MUX <= 2'b00;  selMDR <= 1;
				// LOAD
				ldPC <= 0;       ldReg <= 1;         ldIR <= 0;         ldMDR <= 1;            ldMAR <= 0;
				// DATA CTRL
				dSR1 <= 3'b000;  dSR2 <= 3'b000;     dDR <= 3'b111;     dALUK <= 2'b11;        dMemWE <= 0;

				FSM_next <= 6'd30;
			end

			30: begin
				// TRAP s2
				// PC <- MDR

				// TSBs
				gateMARMUX <= 0; gatePC <= 0;        gateALU <= 0;      gateMDR <= 1;
				// SEL
				selMARMUX <= 0;	 selPCMUX <= 2'b01;  selADDR1MUX <= 0;  selADDR2MUX <= 2'b00;  selMDR <= 0;
				// LOAD
				ldPC <= 1;       ldReg <= 0;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 0;
				// DATA CTRL
				dSR1 <= 3'b000;  dSR2 <= 3'b000;     dDR <= 3'b000;     dALUK <= 2'b11;        dMemWE <= 0;

				FSM_next <= 6'd18;
			end

			14: begin
				// LEA
				// DR <- PC + offest9

				// TSBs
				gateMARMUX <= 1; gatePC <= 0;        gateALU <= 0;      gateMDR <= 0;
				// SEL
				selMARMUX <= 1;	 selPCMUX <= 2'b00;  selADDR1MUX <= 0;  selADDR2MUX <= 2'b10;  selMDR <= 0;
				// LOAD
				ldPC <= 0;       ldReg <= 1;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 0;
				// DATA CTRL
				dSR1 <= 3'b000;  dSR2 <= 3'b000;     dDR <= IR[11:9];   dALUK <= 2'b11;        dMemWE <= 0;

				FSM_next <= 6'd18;
			end

			12: begin
				// JMP (RET = JMP 111)
				// PC <- BaseR

				// TSBs
				gateMARMUX <= 0; gatePC <= 0;        gateALU <= 0;      gateMDR <= 0;
				// SEL
				selMARMUX <= 0;	 selPCMUX <= 2'b10;  selADDR1MUX <= 1;  selADDR2MUX <= 2'b00;  selMDR <= 0;
				// LOAD
				ldPC <= 1;       ldReg <= 0;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 0;
				// DATA CTRL
				dSR1 <= IR[8:6];  dSR2 <= 3'b000;     dDR <= 3'b000;     dALUK <= 2'b11;        dMemWE <= 0;

				FSM_next <= 6'd18;
			end

			2: begin
				// LD
				//
			end

			// <=== EXECUTE

			default: begin
				// ...

				// TSBs
				gateMARMUX <= 0; gatePC <= 0;        gateALU <= 0;      gateMDR <= 0;
				// SEL
				selMARMUX <= 0;	 selPCMUX <= 2'b00;  selADDR1MUX <= 0;  selADDR2MUX <= 2'b00;  selMDR <= 0;
				// LOAD
				ldPC <= 0;       ldReg <= 0;         ldIR <= 0;         ldMDR <= 0;            ldMAR <= 0;
				// DATA CTRL
				dSR1 <= 3'b000;  dSR2 <= 3'b000;     dDR <= 3'b000;     dALUK <= 2'b11;        dMemWE <= 0;
			end

		endcase

		if (FSM_state == 6'd63)
			FSM_next <= 6'd18;
	end


endmodule