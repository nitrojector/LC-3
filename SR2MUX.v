module SR2MUX(
	input [4:0] IRImm,
	input [16:0] SR2,
	output reg [16:0] SR2MUXOut,
	input IR5);

	always @ (*) begin
		if (IR5)
			SR2MUXOut <= { {11{IRImm[4]}}, IRImm };
		else
			SR2MUXOut <= SR2;
	end

endmodule