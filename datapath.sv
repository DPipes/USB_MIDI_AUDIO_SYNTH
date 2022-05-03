`define numKeys 128

module data_path(input logic CLK, RESET, SW,
					  input logic LD_PHASE, LD_TONE, LD_COUNT, LD_VEL,
					  input logic TONE_MUX, COUNTER_MUX, PHASE_MUX,
					  input logic NOTE_ON,
					  input logic [6:0] KEY, AVL_KEY, AVL_VEL,
					  input logic [19:0] PEAK_ATT, ATT_LEN, ATT_STEP, DEC_LEN, DEC_STEP, REL_LEN, REL_STEP,
					  output logic NOTE_END,
					  output logic [6:0] AVL_READVEL,
					  output logic [31:0] TONE
					 );

// Registers to hold key velocity from NIOS II, current phase, amplitude, and play counter for each note
logic [6:0]		vel_reg [`numKeys];
logic [20:0]	counter_reg [`numKeys];
logic [23:0]	phase_reg [`numKeys];

logic [1:0]		AMP_MUX;
logic [6:0]		VELOCITY;
logic [15:0]	SAMPLE;
logic [19:0]	ATT_MULT, DEC_MULT, REL_MULT, AMP_MUX_O;
logic [20:0]	COUNTER, COUNTER_INC, COUNTER_MUX_O;
logic [23:0]	PHASE, PHASE_INC, PHASE_MUX_O, F;
logic [26:0]	AMP;
logic [30:0]	SEXT_SAMPLE, AMP_SAMPLE;
logic [31:0]	SEXT_AMP_SAMPLE, TONE_INC, TONE_MUX_O;

// Tables that hold phase step for each note and wavetable to be played
f_table F_TABLE(.*);
wave_table WAVE_TABLE(.*, .ADDR({SW, PHASE_MUX_O[23:12]}));

always_ff @ (posedge CLK) begin

	if(RESET) begin
		TONE <= 0;
		AVL_READVEL <= 0;
	end
	else begin
		if(LD_PHASE)	phase_reg[KEY] <= PHASE_INC;
		if(LD_COUNT)	counter_reg[KEY] <= COUNTER_INC;
		if(LD_TONE)		TONE <= TONE_MUX_O;

		if(LD_VEL)		vel_reg[AVL_KEY] <= AVL_VEL;
		
		AVL_READVEL <= vel_reg[AVL_KEY];
	end
end

always_comb begin
	
	NOTE_END = 1'b0;
	
	COUNTER = counter_reg[KEY];
	VELOCITY = vel_reg[KEY];
	PHASE = phase_reg[KEY];
	
	case(COUNTER_MUX)
		1'b0: COUNTER_MUX_O = 21'h0;
		1'b1: COUNTER_MUX_O = COUNTER;
	endcase
	
	case(PHASE_MUX)
		1'b0: PHASE_MUX_O = 24'h000000;
		1'b1: PHASE_MUX_O = PHASE;
	endcase
	
	COUNTER_INC = COUNTER_MUX_O + 21'h000001;
	PHASE_INC = PHASE_MUX_O + F;
	
	// Calculate possible next amplification multipliers
	ATT_MULT = ATT_STEP * COUNTER_MUX_O[19:0];
	DEC_MULT = PEAK_ATT - (DEC_STEP * (COUNTER_MUX_O[19:0] - ATT_LEN));
	REL_MULT = 20'h80000 - (REL_STEP * COUNTER_MUX_O[19:0]);
	
	// Decide which amplification state depending on length of time note has been played
	if(COUNTER_MUX_O < {1'b0, ATT_LEN}) begin
		AMP_MUX = 2'b00;
	end
	else if ((COUNTER_MUX_O - ATT_LEN) < {1'b0, DEC_LEN}) begin
		AMP_MUX = 2'b01;
		if ((COUNTER_MUX_O - ATT_LEN + 1) == {1'b0, DEC_LEN}) COUNTER_INC = 21'h100000;
	end
	else if (NOTE_ON) begin
		AMP_MUX = 2'b10;
		COUNTER_INC = 21'h100000;
	end
	else begin
		AMP_MUX = 2'b11;
	end
	
	case(AMP_MUX)
		2'b00: AMP_MUX_O = ATT_MULT;
		2'b01: AMP_MUX_O = DEC_MULT;
		2'b10: AMP_MUX_O = 20'h80000;
		2'b11: AMP_MUX_O = REL_MULT;
	endcase
	
	SEXT_SAMPLE = {SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE[15], SAMPLE};
	if (!PHASE_MUX) SEXT_SAMPLE = 31'h0000000;
	
	AMP = AMP_MUX_O * {13'h000, VELOCITY};
	
	// Tell FSM to turn note off when volume becomes low enough
	if((COUNTER_MUX_O[19:0] >= REL_LEN) && COUNTER_MUX_O[20]) NOTE_END = 1'b1;
	
	// Multiplying by 15 bit amplification to leave headroom for summing
	//	Can extend up to ~16 bits
	AMP_SAMPLE = SEXT_SAMPLE * {16'h0000, AMP[26:12]};
	
	SEXT_AMP_SAMPLE = {AMP_SAMPLE[30], AMP_SAMPLE};
	
	TONE_INC = TONE + SEXT_AMP_SAMPLE;
	
	case(TONE_MUX)
		1'b0: TONE_MUX_O = 32'h0;
		1'b1: TONE_MUX_O = TONE_INC;
	endcase
	
end

endmodule
