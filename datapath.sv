`define numKeys 128

module data_path(input logic CLK, RESET, SW,
					  input logic LD_PHASE, LD_TONE, LD_AMP, LD_VEL,
					  input logic TONE_MUX, PHASE_MUX, AMP_SEL,
					  input logic NOTE_ON, ATT_ON,
					  input logic [6:0] KEY, AVL_KEY, AVL_VEL,
					  input logic [19:0] PEAK_AMP, ATT_STEP, DEC_STEP, SUS_AMP, SUS_STEP, REL_STEP,
					  output logic NOTE_END, ATT_OFF,
					  output logic [6:0] AVL_READVEL,
					  output logic [31:0] TONE
					 );

// Registers to hold key velocity from NIOS II, current phase, amplitude, and play counter for each note
logic [6:0]		vel_reg [`numKeys];
logic [20:0]	amp_reg [`numKeys];
logic [23:0]	phase_reg [`numKeys];

logic [2:0]		AMP_MUX;
logic [6:0]		VELOCITY;
logic [15:0]	SAMPLE;
logic [20:0]	AMP_O, ATT_AMP, DEC_AMP, SUS_AMP, REL_AMP, AMP_MUX_O;
logic [23:0]	PHASE, PHASE_INC, PHASE_MUX_O, F;
logic [27:0]	AMP;
logic [31:0]	SEXT_SAMPLE, AMP_SAMPLE, TONE_INC, TONE_MUX_O;

// Tables that hold phase step for each note and wavetable to be played
f_table F_TABLE(.*);
wave_table WAVE_TABLE(.*, .ADDR({SW, PHASE[23:12]}));

always_ff @ (posedge CLK) begin

	if(RESET) begin
		TONE <= 0;
		AVL_READVEL <= 0;
	end
	else begin
		if(LD_PHASE)	phase_reg[KEY] <= PHASE_MUX_O;
		if(LD_AMP)		amp_reg[KEY] <= AMP_MUX_O;
		if(LD_TONE)		TONE <= TONE_MUX_O;

		if(LD_VEL)		vel_reg[AVL_KEY] <= AVL_VEL;
		
		AVL_READVEL <= vel_reg[AVL_KEY];
	end
end

always_comb begin
	
	ATT_OFF = 1'b0;
	NOTE_END =	1'b0;
	
	AMP_O =		amp_reg[KEY];
	VELOCITY =	vel_reg[KEY];
	PHASE =		phase_reg[KEY];
	
	PHASE_INC = PHASE + F;
	
	case(PHASE_MUX)
		1'b0: PHASE_MUX_O = 24'h000000;
		1'b1: PHASE_MUX_O = PHASE_INC;
	endcase
	
	// Calculate possible next amplification multipliers
	ATT_AMP = AMP_O + ATT_STEP;
	DEC_AMP = AMP_O - DEC_STEP;
	SUS_AMP = AMP_O - SUS_STEP;
	REL_AMP = AMP_O - REL_STEP;
	
	if (ATT_ON) AMP_MUX[1:0] = 2'h0;
	else if (AMP_O > SUS_AMP) AMP_MUX[1:0] = 2'h1;
	else if (NOTE_ON) AMP_MUX[1:0] = 2'h2;
	else AMP_MUX[1:0] = 2'h3;
	AMP_MUX[2] = AMP_SEL;
	
	case(AMP_MUX)
		3'h0: AMP_MUX_O = ATT_AMP;
		3'h1: AMP_MUX_O = DEC_AMP;
		3'h2: AMP_MUX_O = SUS_AMP;
		3'h3: AMP_MUX_O = REL_AMP;
		default: AMP_MUX_O = 21'b0;
	endcase
	
	SEXT_SAMPLE = {SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE};
	
	AMP = AMP_MUX_O * {14'h000, VELOCITY};
	
	// Signals to transition for attack and end of note
	if ((ATT_AMP >= PEAK_AMP) || !ATT_ON) ATT_OFF = 1'b1;					// Could overshoot since it is checking if greater than or equal to
	if (((AMP < REL_STEP) && !ATT_ON) NOTE_END = 1'b1;
	
	AMP_SAMPLE = SEXT_SAMPLE * {16'h0000, AMP[27:12]};
	
	TONE_INC = TONE + AMP_SAMPLE;
	
	if (TONE[31] & AMP_SAMPLE[31] & ~TONE_INC[31]) TONE_INC = 32'h80000000;
	if (~TONE[31] & ~AMP_SAMPLE[31] & TONE_INC[31]) TONE_INC = 32'h7FFFFFFF;
	
	case(TONE_MUX)
		1'b0: TONE_MUX_O = 32'h0;
		1'b1: TONE_MUX_O = TONE_INC;
	endcase
	
end

endmodule
