module RAM(
	input [15:0] BUS,
	output [15:0] MDROut,
	input ldMDR,
	input ldMAR,
	input selMDR,
	input memWE,
	input clk,
	input rst,

	//External Access
	input [15:0] memAddrExt,
	input [15:0] memDataExt,
	input memWEExt,
	output [15:0] memOutExt,
	input clkExt);


	wire [15:0] memOut;
	wire [15:0] MAROut;
	reg [15:0] MDRIn;

	always @ (memOut or BUS or selMDR) begin
		if (selMDR)
			MDRIn <= memOut;
		else
			MDRIn <= BUS;
	end

	reg16b regMDR(
		.D (MDRIn),
		.en (ldMDR),
		.rst (rst),
		.clk (clk),
		.Q (MDROut));

	reg16b regMAR(
		.D (BUS),
		.en (ldMAR),
		.rst (rst),
		.clk (clk),
		.Q (MAROut));

	// Memory Kernal
	// A is primary access
	// B is external access
	mem2port memKernal(
		.address_a (MAROut),
		.address_b (memAddrExt),
		.clock_a (clk),
		.clock_b (clkExt),
		.data_a (MDROut),
		.data_b (memDataExt),
		.wren_a (memWE),
		.wren_b (memWEExt),
		.q_a (memOut),
		.q_b (memOutExt));

endmodule