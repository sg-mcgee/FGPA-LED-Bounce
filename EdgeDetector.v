`timescale 1ns/1ps

module EdgeDetector(
	input Signal,
	input CLOCK_50,
	output reg Edge
	);

	reg CurrentInput, OneClockDelay;

	always @(posedge CLOCK_50) begin
		CurrentInput <= Signal;
		OneClockDelay <= CurrentInput;
	end

	always @(posedge CLOCK_50) begin
	 	Edge = (CurrentInput & ~OneClockDelay) ? 1'b1 : 1'b0;
	end
endmodule
