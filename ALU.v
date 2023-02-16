module ALU(
	input [15:0] Ra,
	input [15:0] Rb,
	input [1:0] ALUK,
	output reg [15:0] ALUOut);

	always @ (ALUK or Ra or Rb) begin
		if (ALUK == 2'b00)
			ALUOut <= Ra + Rb;
		else if (ALUK == 2'b01)
			ALUOut <= Ra & Rb;
		else if (ALUK == 2'b10)
			ALUOut <= ~Ra;
		else if (ALUK == 2'b11)
			ALUOut <= Ra;
	end

endmodule