module RegFile(
	input [2:0] SR1,
	input [2:0] SR2,
	input [2:0] DR,
	output [15:0] R1,
	output [15:0] R2,
	input [15:0] BUS,
	input clk,
	input ldReg,
	input rst,

	//External Viewing
	input [2:0] regSelExt,
	output [15:0] regOutExt);

	wire [127:0] qAgg;
	wire [7:0] wEnSigs;

	decode328 wSelDec(
		.in (DR),
		.out (wEnSigs));

	genvar i;

	generate
		for (i = 0; i < 8; i = i + 1) begin : regFileRegs
			reg16b regs (BUS, ldReg & wEnSigs[i], rst, clk, qAgg[16*(i+1)-1:16*i]);
		end
	endgenerate

	mux128to16 out1 (
		.in (qAgg),
		.sel (SR1),
		.out (R1));

	mux128to16 out2 (
		.in (qAgg),
		.sel (SR2),
		.out (R2));

	mux128to16 outExt (
		.in (qAgg),
		.sel (regSelExt),
		.out (regOutExt));

endmodule

module decode328(
	input [2:0] in,
	output reg [7:0] out);

	always @ (in) begin
		case (in)
			3'b000:
				out <= 8'b00000001;
			3'b001:
				out <= 8'b00000010;
			3'b010:
				out <= 8'b00000100;
			3'b011:
				out <= 8'b00001000;
			3'b100:
				out <= 8'b00010000;
			3'b101:
				out <= 8'b00100000;
			3'b110:
				out <= 8'b01000000;
			3'b111:
				out <= 8'b10000000;
			// default:
			// 	out <= 8'b00000000;
		endcase
	end

endmodule

module mux128to16(
	input [127:0] in,
	input [2:0] sel,
	output reg [15:0] out);

	always @ (sel or in) begin
		case (sel)
			3'b000:
				out <= in[15:0];
			3'b001:
				out <= in[31:16];
			3'b010:
				out <= in[47:32];
			3'b011:
				out <= in[63:48];
			3'b100:
				out <= in[79:64];
			3'b101:
				out <= in[95:80];
			3'b110:
				out <= in[111:96];
			3'b111:
				out <= in[127:112];
		endcase
	end
endmodule