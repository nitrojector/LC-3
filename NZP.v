module NZP(
	input [15:0] BUS,
	input [15:0] IR,
	input ldCC,
	output reg NVal,
	output reg ZVal,
	output reg PVal,
	input clk,
	input rst);

	reg NCalc, ZCalc, PCalc;

	initial begin
		NVal <= 0;
		ZVal <= 0;
		PVal <= 0;
		NCalc <= 0;
		ZCalc <= 0;
		PCalc <= 0;
	end

	always @ (BUS) begin
		if (BUS[15] == 1'b1) begin
			NCalc <= 1;
			ZCalc <= 0;
			PCalc <= 0;
		end else if (BUS == 16'b0) begin
			NCalc <= 0;
			ZCalc <= 1;
			PCalc <= 0;
		end else begin
			NCalc <= 0;
			ZCalc <= 0;
			PCalc <= 1;
		end
	end

	always @(negedge clk) begin
		if (rst) begin
			NVal <= 0;
			ZVal <= 0;
			PVal <= 0;
		end else if (ldCC) begin
			NVal <= NCalc;
			ZVal <= ZCalc;
			PVal <= PCalc;
		end
	end

endmodule