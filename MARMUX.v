module MARMUX(
	input [15:0] IR,
	input [15:0] EAB,
	input sel,
	output reg [15:0] MARMUXOut);

	always @ (*) begin
		if (sel)
			MARMUXOut <= EAB;
		else
			MARMUXOut <= 16'b0 + IR[7:0];
	end

endmodule