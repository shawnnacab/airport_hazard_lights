module hazardlights(clk, reset, IN, OUT);		//hazardlights module: state machine
	input logic clk, reset;
	input logic [1:0] IN;
	output logic [2:0] OUT;
	
	//State variables.
	enum { A, B, C, D } ps, ns;		//ps = present state; ns = next state
	
	//Next State logic
	always_comb begin							//A = 101, B = 001, C = 010, D = 100
		case (ps)
			A: if(IN[1] == 0 && IN[0] == 0) ns = C;
				else if(IN[1] == 0 && IN[0] == 1) ns = B;
				else if(IN[1] == 1 && IN[0] == 0) ns = D;
				else		ns = A;	
			B: if(IN[1] == 0 && IN[0] == 0) ns = A;
				else if(IN[1] == 0 && IN[0] == 1) ns = C;
				else if(IN[1] == 1 && IN[0] == 0) ns = D;
				else		ns = A;
			C: if(IN[1] == 0 && IN[0] == 0) ns = A;
				else if(IN[1] == 0 && IN[0] == 1) ns = D;
				else if(IN[1] == 1 && IN[0] == 0) ns = B;
				else		ns = A;
			D: if(IN[1] == 0 && IN[0] == 0) ns = A;
				else if(IN[1] == 0 && IN[0] == 1) ns = B;
				else if(IN[1] == 1 && IN[0] == 0) ns = C;
				else		ns = A;
		endcase
	end // End of the always block for next state logic. 
	
	//Output logic - could also be another part of above block.
assign OUT[2] = (ns == A) | (ns == D);
assign OUT[1] = (ns == C);
assign OUT[0] = (ns == A) | (ns == B);
	//DFFs
	always_ff @(posedge clk) begin	//Introducing clock, execute only at pos edg of clk
		if (reset)
			ps <= A;		// on reset, set to A
		else 
			ps <= ns;	// otherwise out is equal to next state
	end
endmodule // end of hazardlights module

module hazardlights_testbench();
	logic clk, reset;
	logic [1:0] IN;
	logic [2:0] OUT;
	
	hazardlights dut (clk, reset, IN, OUT);
	
	//Set up the clock.
	parameter CLOCK_PERIOD = 100; 
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	//Set up the inputs to the design. Each line is a clock cycle.
	initial begin
															@(posedge clk);
		reset <= 1;										@(posedge clk);
		reset <= 0;  IN[1] <= 0; IN[0] <= 0;	@(posedge clk);
															@(posedge clk);
															@(posedge clk);
										 IN[0] <= 1;	@(posedge clk);
															@(posedge clk);
															@(posedge clk);
						 IN[1] <= 1; IN[0] <= 0;	@(posedge clk);
															@(posedge clk);
															@(posedge clk);
										 IN[0] <= 1;	@(posedge clk);
															@(posedge clk);
															@(posedge clk);
		$stop; //End the simulation.
	end
endmodule //hazardlights_testbench


module DE1_SoC (CLOCK_50, KEY, LEDR, SW);
	input logic				CLOCK_50; //50MHz clock.
	output logic [9:0]	LEDR;
	input logic	 [9:0]	KEY; //True when not pressed, False when pressed
	input logic  [9:0]	SW;
	
	//Generate clk off of CLOCK_50, whichClock picks rate.
	logic [31:0] clk;
	parameter whichClock = 25;
	clock_divider cdiv (CLOCK_50, clk);
	
	//Hook up FSM inputs and outputs.
	logic reset;
	
	assign reset = ~KEY[0];		//Reset when KEY[0] is pressed.
	
	hazardlights test (.clk(clk[whichClock]), .reset(reset), .IN(SW[1:0]), .OUT(LEDR[2:0]));
	
	// Show signals on LEDRs so we can see what is happening.
	assign LEDR[8] = reset;
	assign LEDR[9] = clk[whichClock];
	
endmodule //DE1_SoC

module clock_divider (clock, divided_clocks);
	input logic				clock;
	output logic [31:0]	divided_clocks;
	
	initial begin
		divided_clocks <= 0;
	end
	
	always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	end
endmodule //clock_divider

