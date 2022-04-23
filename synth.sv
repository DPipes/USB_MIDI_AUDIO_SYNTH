// Synth module
// Takes input from CPU and generates 24 bit mono audio samples to send to I2S module

module synth (input logic RESET, CLK, LRCLK, SCLK, FIFO_FULL,
				  input logic [7:0] KEYCODE,
				  input logic [9:0] SW,
				  //input logic PHASE [11:0],			WILL COME FROM CPU??
				  output logic FIFO_WRITE,
				  output logic [23:0] AUDIO_OUT
				 );

logic SAW;
logic [6:0] NOTE;
logic [3:0] STATE;
logic [11:0] ADDR;
logic [19:0] SCALE_COUNTER; // Plays each note for ~1 second
logic [23:0] PHASE, PHASE_2, PHASE_3, PHASE_4, TONE, INC, SAMPLE, SAMPLE_, SUM; // TEMPORARY

// Wavetable has sine and sawtooth data when SW[8] is high saw is selected
wavetable WAVE(.CLK(CLK), .ADDR({SW[8], ADDR}), .SAMPLE(SAMPLE[15:0]));


always_comb begin

	SAMPLE[23:16] = {SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15]};
	SUM = TONE + SAMPLE_;
	if (TONE[23] & SAMPLE_[23] & ~SUM[23]) SUM = 24'h80000;
	if (~TONE[23] & ~SAMPLE_[23] & SUM[23]) SUM = 24'h7FFFF;
	
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
	
	// Select frequency, 8 full octaves by MIDI number from C0 to B8
	case (KEYCODE) 

		12: INC <= 24'h184c;
		13: INC <= 24'h19be;
		14: INC <= 24'h1b46;
		15: INC <= 24'h1ce5;
		16: INC <= 24'h1e9d;
		17: INC <= 24'h206f;
		18: INC <= 24'h225d;
		19: INC <= 24'h2468;
		20: INC <= 24'h2692;
		21: INC <= 24'h28dd;
		22: INC <= 24'h2b4b;
		23: INC <= 24'h2dde;
		24: INC <= 24'h3099;
		25: INC <= 24'h337c;
		26: INC <= 24'h368c;
		27: INC <= 24'h39cb;
		28: INC <= 24'h3d3a;
		29: INC <= 24'h40de;
		30: INC <= 24'h44ba;
		31: INC <= 24'h48d0;
		32: INC <= 24'h4d24;
		33: INC <= 24'h51bb;
		34: INC <= 24'h5697;
		35: INC <= 24'h5bbd;
		36: INC <= 24'h6131;
		37: INC <= 24'h66f9;
		38: INC <= 24'h6d18;
		39: INC <= 24'h7395;
		40: INC <= 24'h7a75;
		41: INC <= 24'h81bd;
		42: INC <= 24'h8974;
		43: INC <= 24'h91a0;
		44: INC <= 24'h9a49;
		45: INC <= 24'ha375;
		46: INC <= 24'had2d;
		47: INC <= 24'hb77a;
		48: INC <= 24'hc263;
		49: INC <= 24'hcdf2;
		50: INC <= 24'hda31;
		51: INC <= 24'he72a;
		52: INC <= 24'hf4e9;
		53: INC <= 24'h10379;
		54: INC <= 24'h112e7;
		55: INC <= 24'h12340;
		56: INC <= 24'h13491;
		57: INC <= 24'h146eb;
		58: INC <= 24'h15a5b;
		59: INC <= 24'h16ef3;
		60: INC <= 24'h184c5;
		61: INC <= 24'h19be3;
		62: INC <= 24'h1b461;
		63: INC <= 24'h1ce54;
		64: INC <= 24'h1e9d2;
		65: INC <= 24'h206f2;
		66: INC <= 24'h225ce;
		67: INC <= 24'h24680;
		68: INC <= 24'h26923;
		69: INC <= 24'h28dd5;
		70: INC <= 24'h2b4b6;
		71: INC <= 24'h2dde7;
		72: INC <= 24'h3098b;
		73: INC <= 24'h337c7;
		74: INC <= 24'h368c3;
		75: INC <= 24'h39ca8;
		76: INC <= 24'h3d3a4;
		77: INC <= 24'h40de5;
		78: INC <= 24'h44b9c;
		79: INC <= 24'h48cff;
		80: INC <= 24'h4d245;
		81: INC <= 24'h51baa;
		82: INC <= 24'h5696c;
		83: INC <= 24'h5bbce;
		84: INC <= 24'h61315;
		85: INC <= 24'h66f8e;
		86: INC <= 24'h6d186;
		87: INC <= 24'h73951;
		88: INC <= 24'h7a748;
		89: INC <= 24'h81bca;
		90: INC <= 24'h89738;
		91: INC <= 24'h919fe;
		92: INC <= 24'h9a48b;
		93: INC <= 24'ha3754;
		94: INC <= 24'had2d8;
		95: INC <= 24'hb779b;
		96: INC <= 24'hc262b;
		97: INC <= 24'hcdf1b;
		98: INC <= 24'hda30b;
		99: INC <= 24'he72a2;
		100: INC <= 24'hf4e90;
		101: INC <= 24'h103793;
		102: INC <= 24'h112e71;
		103: INC <= 24'h1233fc;
		104: INC <= 24'h134915;
		105: INC <= 24'h146ea8;
		106: INC <= 24'h15a5b0;
		107: INC <= 24'h16ef36;
		108: INC <= 24'h184c55;
		109: INC <= 24'h19be37;
		110: INC <= 24'h1b4617;
		111: INC <= 24'h1ce544;
		112: INC <= 24'h1e9d21;
		113: INC <= 24'h206f26;
		114: INC <= 24'h225ce1;
		115: INC <= 24'h2467f8;
		116: INC <= 24'h26922a;
		117: INC <= 24'h28dd50;
		118: INC <= 24'h2b4b60;
		119: INC <= 24'h2dde6d;
		
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
				SAMPLE_ <= SAMPLE << 7;
			end
			
			4'h3: begin
				TONE <= SAMPLE_;
				ADDR <= PHASE_2[23:12];
			end
			
			4'h4: begin
				;
			end
			
			4'h5: begin
				SAMPLE_ <= SAMPLE << 6;
			end
			
			4'h6: begin
				if (SW[6]) TONE <= SUM;
				ADDR <= PHASE_3[23:12];
			end
			
			4'h7: begin
				;
			end
			
			4'h8: begin
				SAMPLE_ <= SAMPLE << 6;
			end
			
			4'h9: begin
				if (SW[6]) TONE <= SUM;
				ADDR <= PHASE_4[23:12];
			end
			
			4'hA: begin
				;
			end
			
			4'hB: begin
				SAMPLE_ <= SAMPLE << 6;
			end
			
			4'hC: begin
				if (SW[5]) TONE <= SAMPLE_;
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
				/*case (KEYCODE)					REMOVED FOR MIDI SETUP
			
					56: NOTE <= 0;
				
					57: NOTE <= 1;
				
					59: NOTE <= 2;

					61: NOTE <= 3;
				
					62: NOTE <= 4;
				
					64: NOTE <= 5;
				
					66: NOTE <= 6;
				
					68: NOTE <= 7;
				
					69: NOTE <= 8;
				
					71: NOTE <= 9;
				
					73: NOTE <= 10;
					
					default: NOTE <= 15;
				
				endcase*/
				
			end
			
			default: ;
			
		endcase
		
	end
	
	// Select to automatically step through scale rather than take user input
	//if (SW[7]) NOTE <= SCALE_COUNTER[19:16];	REMOVED FOR MIDI SETUP
	else SCALE_COUNTER <= 0;
	
end

always_ff @ (posedge SCLK) begin
	;
end

always_ff @ (negedge LRCLK) begin
	;
end

endmodule
