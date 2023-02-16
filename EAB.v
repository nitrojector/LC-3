module EAB(
	input [15:0] IR,
	input [15:0] SR1,
	input [15:0] PC,
	input [1:0] selADDR2MUX,
	input selADDR1MUX,
	output reg [15:0] EABOut);

	reg [15:0] sext11;
	reg [15:0] sext9;
	reg [15:0] sext6;

	reg [15:0] addr1;
	reg [15:0] addr2;

	always @ (IR) begin
		sext11 <= { {5{IR[10]}}, IR[10:0] };
		sext9  <= { {7{IR[8]}},  IR[8:0]  };
		sext6  <= { {10{IR[5]}}, IR[5:0]  };
	end

	always @ (*) begin
		if (selADDR1MUX)
			addr1 <= SR1;
		else
			addr1 <= PC;
	end

	always @ (*) begin
		if (selADDR2MUX == 2'b00)
			addr2 <= 16'b0;
		else if (selADDR2MUX == 2'b01)
			addr2 <= sext6;
		else if (selADDR2MUX == 2'b10)
			addr2 <= sext9;
		else
			addr2 <= sext11;
	end

	always @ (*) begin
		EABOut <= addr1 + addr2;
	end

endmodule

