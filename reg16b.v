module reg16b(
	input [15:0] D,
	input en,
	input rst,
	input clk,
	output reg [15:0] Q);

	always @(negedge clk) begin
		if (rst)
			Q <= 16'h0000;
		else if (en)
			Q <= D;
	end
endmodule