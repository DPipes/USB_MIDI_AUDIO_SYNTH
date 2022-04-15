// Synth module
// Takes input from CPU and generates mono audio samples to send to I2S module

module synth (input logic RESET, CLK, LRCLK, SCLK, FIFO_FULL,
				  input logic [9:0] SW,
				  //input logic PHASE [11:0],			WILL COME FROM CPU
				  output logic FIFO_WRITE,
				  output logic [15:0] AUDIO_OUT
				 );

logic SAW;
logic [3:0] KEY, MEM_WAIT;
logic [15:0] SAMPLE;
logic [15:0] TONE;
logic [19:0] SCALE_COUNTER; // Plays each note for ~1 second
logic [23:0] PHASE, INC; // TEMPORARY

// Wavetable has sine and sawtooth data when SW[8] is high saw is selected
wavetable WAVE(.CLK(CLK), .ADDR({SW[7], PHASE[23:12]}), .SAMPLE(SAMPLE));

always_ff @ (posedge CLK) begin
	
	if (RESET) begin
		SAW <= 1;
		TONE <= 0;
		AUDIO_OUT <= 0;
		PHASE <= 0;
		SCALE_COUNTER <= 0;
		FIFO_WRITE <= 0;
		MEM_WAIT <= 0;
	end
	
	FIFO_WRITE <= 0;
	
	// Generates rough saw wave
	if (16'h7FFF - PHASE < (2 * INC)) SAW <= ~SAW;
	
	// Select frequency, A4 to A6 scale
	case (KEY) 
	
		0: begin
			INC <= 24'h28DD5;
		end

		1: begin
			INC <= 24'h2DDE6;
		end
		
		2: begin
			INC <= 24'h337C9;
		end
		
		3: begin
			INC <= 24'h368C3;
		end

		4: begin
			INC <= 24'h3D3A2;
		end

		5: begin
			INC <= 24'h44B9D;
		end

		6: begin
			INC <= 24'h4D245;
		end

		7: begin
			INC <= 24'h51BAA;
		end

		8: begin
			INC <= 24'h5BBCF;
		end

		9: begin
			INC <= 24'h66F8E;
		end

		10: begin
			INC <= 24'h6D186;
		end

		11: begin
			INC <= 24'h7A748;
		end

		12: begin
			INC <= 24'h89739;
		end

		13: begin
			INC <= 24'h9A48B;
		end

		14: begin
			INC <= 24'hA3754;
		end

		15: begin
			INC <= 24'h146EB;
		end
		
		default: ;
		
	endcase
	
	// Select saw, ramp, or sine
	case (SW[9:7])
	
		3'b00: begin
			if (SAW) begin
				AUDIO_OUT <= PHASE[23:8];
			end
			else begin
				AUDIO_OUT <= ~PHASE[23:8];
			end
		end
		
		3'b01: begin
			AUDIO_OUT <= PHASE[23:8];		
		end
		
		3'b10: begin
			AUDIO_OUT <= SAMPLE;
		end
		
		3'b11: begin
			AUDIO_OUT <= SAMPLE;
		end
			
		default: ;
	
	endcase
	
	// Let user select notes or step through scale
	case (SW[6]) 
	
		0: begin
			KEY <= SW[3:0];
			SCALE_COUNTER <= 20'b0;
		end
		
		1: begin
			KEY <= SCALE_COUNTER[19:16];
		end
	
	endcase
	
	// Directly connected SAMPLE for testing, TONE will be sent as sum of SAMPLEs
	//TONE <= SAMPLE;
	
	if (!FIFO_FULL) begin
		MEM_WAIT <= (MEM_WAIT + 1);
		if (MEM_WAIT == 0) begin
			PHASE <= (PHASE + INC);
			SCALE_COUNTER <= (SCALE_COUNTER + 1);
			FIFO_WRITE <= 1;
		end
	end
	
end

always_ff @ (posedge SCLK) begin
	;
end

always_ff @ (negedge LRCLK) begin
	;
end

endmodule
