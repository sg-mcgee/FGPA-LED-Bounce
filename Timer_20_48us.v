`timescale 1ns/1ps

module Timer_20_48us(
	input CLOCK_50, Reset,
	output reg [25:0] Count, Rollover
	);

	always @(posedge CLOCK_50) begin
		Rollover <= 1'b0;
		if (Reset) begin
			Count <= 26'b0;
			Rollover <= 1'b0;
		end else
			Count <= Count + 26'b1;
		
		if (Count >= 1024) begin
			Rollover <= 1'b1;
			Count <= 26'b0;
		end
	end
		
endmodule
