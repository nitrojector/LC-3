module reg16b(
	input [15:0] D,
	input en,
	input rst,
	input clk,
	output reg [15:0] Q);

	always @(posedge clk or posedge rst) begin
		if (rst)
			Q <= 16'b0000000000000000;
		else if (en)
			Q <= D;
	end

endmodule