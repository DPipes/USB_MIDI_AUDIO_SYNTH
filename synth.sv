// Synth module
// Takes input from CPU and generates mono audio samples to send to I2S module

module synth (input logic RESET, CLK, LRCLK, SCLK, FIFO_FULL,
				  input logic [7:0] KEYCODE,
				  input logic [9:0] SW,
				  //input logic PHASE [11:0],			WILL COME FROM CPU??
				  output logic FIFO_WRITE,
				  output logic [23:0] AUDIO_OUT
				 );

logic SAW;
logic [3:0] NOTE;
logic [3:0] STATE;
logic [11:0] ADDR;
logic [19:0] SCALE_COUNTER; // Plays each note for ~1 second
logic [23:0] PHASE, PHASE_2, PHASE_3, PHASE_4, TONE, INC, SAMPLE, SUM; // TEMPORARY

// Wavetable has sine and sawtooth data when SW[8] is high saw is selected
wavetable WAVE(.CLK(CLK), .ADDR({SW[8], ADDR}), .SAMPLE(SAMPLE[15:0]));


always_comb begin

	SAMPLE[23:16] = {SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15]};
	SUM = TONE + SAMPLE;
	
end

always_ff @ (posedge CLK) begin
	
	if (RESET) begin
		SAW <= 1;
		TONE <= 0;
		AUDIO_OUT <= 0;
		SCALE_COUNTER <= 0;
		FIFO_WRITE <= 0;
		STATE <= 0;
	end
	
	FIFO_WRITE <= 0;
	
	// Generates not too terrible saw wave
	if (16'h7FFF - PHASE < (2 * INC)) SAW <= ~SAW;
	
	// Select frequency, A4 to A6 scale
	case (NOTE) 

		0: INC <= 24'h13491;

		1: INC <= 24'h146EB;

		2: INC <= 24'h16EF3;

		3: INC <= 24'h19BE3;

		4: INC <= 24'h1B461;

		5: INC <= 24'h1E9D2;

		6: INC <= 24'h225CE;

		7: INC <= 24'h26923;
		
		8: INC <= 24'h28DD5;

		9: INC <= 24'h2DDE7;
		
		10: INC <= 24'h337C7;
		
		11: INC <= 24'h368C3;

		12: INC <= 24'h3D3A4;

		13: INC <= 24'h44B9C;

		14: INC <= 24'h4D245;

		15: INC <= 24'h0;
		
		default: INC <= 24'h0;
		
	endcase
	
	// Select saw, ramp, or sine
	case (SW[9:8])
	
		3'b00: begin
			if (SAW) begin
				AUDIO_OUT <= PHASE;
			end
			else begin
				AUDIO_OUT <= ~PHASE;
			end
		end
		
		3'b01: begin
			AUDIO_OUT <= PHASE;		
		end
		
		3'b10: begin
			AUDIO_OUT <= TONE;
		end
		
		3'b11: begin
			AUDIO_OUT <= TONE;
		end
			
		default: ;
	
	endcase
	
	// Synthesis FSM
	if (!FIFO_FULL) begin
	
		STATE <= (STATE + 1);
		
		case (STATE)
		
			4'h0: begin
				ADDR <= PHASE[23:12];
			end
			
			4'h1: begin
				;
			end
			
			4'h2: begin
				;
			end
			
			4'h3: begin
			TONE <= SAMPLE;
				ADDR <= PHASE_2[23:12];
			end
			
			4'h4: begin
				;
			end
			
			4'h5: begin
				;
			end
			
			4'h6: begin
				if (SW[6]) TONE <= SUM;
				ADDR <= PHASE_3[23:12];
			end
			
			4'h7: begin
				;
			end
			
			4'h8: begin
				;
			end
			
			4'h9: begin
				if (SW[6]) TONE <= SUM;
				ADDR <= PHASE_4[23:12];
			end
			
			4'hA: begin
				;
			end
			
			4'hB: begin
				;
			end
			
			4'hC: begin
				if (SW[5]) TONE <= SAMPLE;
				if (SW[6]) TONE <= SUM;
			end
			
			4'hD: begin
			
				PHASE   <= (PHASE + INC);						// First harmonic
				PHASE_2 <= (PHASE_2 + (INC << 1));			// Second harmonic
				PHASE_3 <= (PHASE_3 + (3*INC));				// Third harmonic
				PHASE_4 <= (PHASE_4 + (INC << 2));			// Fourth harmonic
			
				// Increment scale counter and write sample to FIFO
				SCALE_COUNTER <= (SCALE_COUNTER + 1);
				if (SCALE_COUNTER[19:16] == 15) SCALE_COUNTER <= 0;
				FIFO_WRITE <= 1;
			
				// Translate keycode to note
				case (KEYCODE)
			
					53: NOTE <= 0;
				
					30: NOTE <= 1;
				
					31: NOTE <= 2;

					32: NOTE <= 3;
				
					33: NOTE <= 4;
				
					34: NOTE <= 5;
				
					35: NOTE <= 6;
				
					36: NOTE <= 7;
				
					37: NOTE <= 8;
				
					38: NOTE <= 9;
				
					39: NOTE <= 10;
					
					default: NOTE <= 15;
				
				endcase
				
			end
			
			default: ;
			
		endcase
		
	end
	
	// Select to automatically step through scale rather than take user input
	if (SW[7]) NOTE <= SCALE_COUNTER[19:16];
	else SCALE_COUNTER <= 0;
	
end

always_ff @ (posedge SCLK) begin
	;
end

always_ff @ (negedge LRCLK) begin
	;
end

endmodule
