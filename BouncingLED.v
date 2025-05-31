`timescale 1ns/1ps

module BouncingLED(
	input CLOCK_50,
	input [2:0] KEY,
	output reg [9:0] LEDR,
	output [7:0] HEX0,
	output [7:0] HEX1,
	output [7:0] HEX2,
	output [7:0] HEX3
	);
	
	//I am operating in a signed q8.24 fixed point arithmetic format.
	//MSB sign, 7 bits integer, 24 bits decimal
	

	
	//KEY Syncronization wires and reg
	reg [1:0] KEY_sync, KEY_A, KEY_B;
	wire KEY_0, KEY_1;
	assign KEY_0 = KEY_sync[0];
	assign KEY_1 = KEY_sync[1];
	
	//Velocity reg and parameters
	reg signed [31:0] velocity;
	localparam signed [31:0] delta_velocity_low = 32'sd3355; 
	localparam signed [31:0] delta_velocity_high = 32'sd3356; 
	reg [7:0] seconds_passed;
	wire time_step;
	reg time_step_reg;
	reg delta_switch_flag;
	wire [7:0] position_msb;
	assign position_msb = position[31:24];
	wire [7:0] velocity_msb;
	assign velocity_msb = velocity[31:24];
	//Floor / ceilinginformation
	localparam signed [31:0] FLOOR = 32'sd0;
	localparam signed [31:0] CEIL = 32'sd10;
	
	//Position reg
	reg signed [31:0] position;
	
	//Syncronize keys
	always @(posedge CLOCK_50) begin
		KEY_sync <= KEY_B;
		KEY_B <= KEY_A;
		KEY_A <= KEY;
	end

	always @(posedge CLOCK_50) begin
		time_step_reg <= time_step;
			
		if (!KEY_0) begin //Reset
			position <= 32'sd1000;
			velocity <= 32'sh03000000;
		end
		if (!KEY_1) //Use key 1 to add some velocity
			velocity <= (velocity <= 32'sb0) ? velocity + 32'sh03000000 : 32'sh03000000; //If falling, set velocity to small addand. If rising, add small addand
	
		//Subtract a little from the velocity each time step.
		//Switch between a low estimate and high estimate each time
		//to account for error in fixed point arithmetic.
		if (time_step_reg) begin
			if (delta_switch_flag) begin
				velocity <= velocity - delta_velocity_low;
				delta_switch_flag <= !delta_switch_flag;
			end else begin
				velocity <= velocity - delta_velocity_high;
				delta_switch_flag <= ~delta_switch_flag;
			end
			
			//Update position
			position <= position + (velocity >>> 16);
			
			//Bounce off floor
			if ((position <= FLOOR) && (velocity < 0)) begin
//				velocity <= -(velocity >>> 1);
				velocity <= -((velocity >>> 2) * 3);
//				velocity <= -(velocity  >>> 2);
				position <= 32'sh00000100;
			end
			if (position < 32'sb0)
				position <= 32'sb0;
			
			//Bounce off ceiling
			if ((position_msb >= CEIL) && (velocity > 0)) begin
				velocity <= -(velocity);
				position[31:24] <= CEIL - 1'b1;
			end
		end
		
		
	end
	
	
	always @(*) begin
		if (position < 32'sd1677721 * 1)
			LEDR[9:0] = 10'b0000000001;
		else if (position < 32'sd1677721 * 2)
			LEDR[9:0] = 10'b0000000010;
		else if (position < 32'sd1677721 * 3)
			LEDR[9:0] = 10'b0000000100;
		else if (position < 32'sd1677721 * 4)
			LEDR[9:0] = 10'b0000001000;
		else if (position < 32'sd1677721 * 5)
			LEDR[9:0] = 10'b0000010000;
		else if (position < 32'sd1677721 * 6)
			LEDR[9:0] = 10'b0000100000;
		else if (position < 32'sd1677721 * 7)
			LEDR[9:0] = 10'b0001000000;
		else if (position < 32'sd1677721 * 8)
			LEDR[9:0] = 10'b0010000000;
		else if (position < 32'sd1677721 * 9)
			LEDR[9:0] = 10'b0100000000;
		else
			LEDR[9:0] = 10'b1000000000;
	end
	
//	always @(*) begin
//		if (position < 32'sd18641351 * 1)
//			LEDR[9:0] = 10'b0000000001;
//		else if (position < 32'sd18641351 * 2)
//			LEDR[9:0] = 10'b0000000010;
//		else if (position < 32'sd18641351 * 3)
//			LEDR[9:0] = 10'b0000000100;
//		else if (position < 32'sd18641351 * 4)
//			LEDR[9:0] = 10'b0000001000;
//		else if (position < 32'sd18641351 * 5)
//			LEDR[9:0] = 10'b0000010000;
//		else if (position < 32'sd18641351 * 6)
//			LEDR[9:0] = 10'b0000100000;
//		else if (position < 32'sd18641351 * 7)
//			LEDR[9:0] = 10'b0001000000;
//		else if (position < 32'sd18641351 * 8)
//			LEDR[9:0] = 10'b0010000000;
//		else if (position < 32'sd18641351 * 9)
//			LEDR[9:0] = 10'b0100000000;
//		else
//			LEDR[9:0] = 10'b1000000000;
//	end


	
	
		
	Timer_20_48us Timer_20_48us(
		.CLOCK_50(CLOCK_50),
		.Rollover(time_step),
		.Reset(!KEY[0]),
		);
		
	HEXDisplay HEX0Display(
		.HexInput(position_msb[3:0]),
		.DisplayOut(HEX0)
		);
	
	HEXDisplay HEX1Display(
		.HexInput(position_msb[7:4]),
		.DisplayOut(HEX1)
		);
		
	HEXDisplay HEX2Display(
		.HexInput(velocity_msb[3:0]),
		.DisplayOut(HEX2)
		);
	
	HEXDisplay HEX3Display(
		.HexInput(velocity_msb[7:4]),
		.DisplayOut(HEX3)
		);
		
		
		

		
endmodule
