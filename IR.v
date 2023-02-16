module IR(
	input [15:0] BUS,
	input ldIR,
	output [15:0] IROut,
	input clk,
	input rst);

	reg16b IRreg (
		.D (BUS),
		.en (ldIR),
		.rst (rst),
		.clk (clk),
		.Q (IROut));

endmodule