module TSB(
	input [15:0] in,
	input en,
	output [15:0] out);

	assign out = en ? in : 16'bzzzzzzzzzzzzzzzz;

endmodule