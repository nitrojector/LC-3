module SEXT(
	input [8:0] in,
	output reg [15:0] out);

	always @(*) begin
	    out[15:0] <= { {7{in[8]}}, in[8:0] };
	end
endmodule