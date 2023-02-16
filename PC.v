module PC (
	input [15:0] BUS,
	input [15:0] EAB,
	input ldPC,
	input [1:0] selPCMUX,
	output [15:0] PCOut,
	//output reg [15:0] PCInc,
	input clk,
	input rst);

	reg [15:0] PC, PCInc; //

	reg16b regPC(
		.D (PC),
		.Q (PCOut),
		.en (ldPC),
		.rst (rst),
		.clk (clk));

	initial
		PC <= 16'h0000;

	always @ (posedge clk) begin
		if (ldPC)
			PCInc <= PC + 16'd1;
	end

	always @ (BUS or EAB or PCInc or selPCMUX) begin
		if (selPCMUX == 2'b00)
			PC <= PCInc;
		else if (selPCMUX == 2'b01)
			PC <= BUS;
		else if (selPCMUX == 2'b10)
			PC <= EAB;
	end

endmodule