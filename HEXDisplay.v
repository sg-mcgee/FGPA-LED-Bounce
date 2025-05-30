`timescale 1ns/1ps

module HEXDisplay(
	input [3:0] HexInput,
	output reg [7:0] DisplayOut
	);

	always @(*) begin
		case(HexInput)
			4'b0000: DisplayOut = ~8'b00111111;
			4'b0001: DisplayOut = ~8'b00000110;
			4'b0010: DisplayOut = ~8'b01011011;
			4'b0011: DisplayOut = ~8'b01001111;
			4'b0100: DisplayOut = ~8'b01100110;
			4'b0101: DisplayOut = ~8'b01101101;
			4'b0110: DisplayOut = ~8'b01111101;
			4'b0111: DisplayOut = ~8'b00000111;
			4'b1000: DisplayOut = ~8'b01111111;
			4'b1001: DisplayOut = ~8'b01100111;
			4'b1010: DisplayOut = ~8'b01110111;
			4'b1011: DisplayOut = ~8'b01111100;
			4'b1100: DisplayOut = ~8'b00111001;
			4'b1101: DisplayOut = ~8'b01011110;
			4'b1110: DisplayOut = ~8'b01111001;
			4'b1111: DisplayOut = ~8'b01110001;
			default: DisplayOut = ~8'b01101010;
		endcase
	end
endmodule