`define numKeys 128
`define numCtrl 16

module synth_ip(input logic CLK, RESET, RUN, AVL_WRITE, AVL_READ, FIFO_FULL,
					 input logic [7:0] AVL_ADDR,
					 input logic [31:0] AVL_WRITEDATA,
					 output logic LD_FIFO,
					 output logic [31:0] AVL_READDATA, TONE
					);

enum logic [2:0] {halted,
						start,
						check_key,
						key_on,
						key_off,
						write}   state, next_state;
logic [2:0]		play_reg [`numKeys];
logic [31:0]	ctrl_reg [`numCtrl];

logic				LD_PHASE, LD_TONE, LD_AMP, LD_VEL, LD_KEY, LD_PLAY, AVL_PLAY;
logic				TONE_MUX, PHASE_MUX, AMP_SEL;
logic				NOTE_ON, NOTE_END, ATT_ON, ATT_OFF, SUS;
logic [2:0]		PLAY, NEXT_PLAY, MIX_MUX_1, MIX_MUX_2;
logic [6:0]		KEY, NEXT_KEY, AVL_KEY, AVL_VEL, AVL_READVEL, SUS_PEDAL, MIX, PED_INV;
logic [13:0]	BEND;
logic [20:0]	PEAK_ATT, ATT_STEP, DEC_STEP, PEAK_SUS, SUS_STEP, REL_STEP;

data_path DATA_PATH(.*);

always_ff @ (posedge CLK or posedge RESET) begin
	
	if (RESET) begin
		state <= halted;
		KEY <= 0;
	end
	else begin
		state <= next_state;
		
		if (LD_KEY) KEY <= NEXT_KEY;
		if (LD_PLAY) play_reg[KEY] <= NEXT_PLAY;
		
		if (AVL_WRITE) begin
			
			if (AVL_ADDR[7]) begin
				ctrl_reg[AVL_ADDR[3:0]] <= AVL_WRITEDATA;
			end
			else begin
				play_reg[AVL_KEY][0] <= AVL_PLAY;
				if(AVL_PLAY) play_reg[AVL_KEY][1] <= 1'b1;
			end
		end
	end
	
end

always_comb begin
	
	
	PLAY =		play_reg[KEY];
	PEAK_ATT =	ctrl_reg[0][20:0];
	ATT_STEP =	ctrl_reg[1][20:0];
	DEC_STEP =	ctrl_reg[2][20:0];
	PEAK_SUS =	ctrl_reg[3][20:0];
	SUS_STEP =	ctrl_reg[4][20:0];
	REL_STEP =	ctrl_reg[5][20:0];
	SUS_PEDAL = ctrl_reg[6][6:0];
	MIX =			ctrl_reg[7][6:0];
	MIX_MUX_1 = ctrl_reg[8][6:4];
	MIX_MUX_2 = ctrl_reg[9][6:4];
	BEND =		ctrl_reg[10][13:0];
	PED_INV =	ctrl_reg[11][6:0];
	AVL_PLAY =	AVL_WRITEDATA[7];
	AVL_KEY =	AVL_ADDR[6:0];
	AVL_VEL =	AVL_WRITEDATA[6:0];
	
	next_state = state;
	NEXT_KEY = KEY + 7'h01;
	
	LD_PHASE =	1'b0;
	LD_AMP =		1'b0;
	LD_TONE =	1'b0;
	LD_FIFO =	1'b0;
	LD_KEY =		1'b0;
	LD_PLAY =	1'b0;
	LD_VEL =		1'b0;
	
	TONE_MUX =	1'b1;
	PHASE_MUX =	1'b1;
	AMP_SEL =	1'b0;
	SUS =			1'b0;
	if ((SUS_PEDAL ^ PED_INV) >= 7'h40) SUS = 1'b1;
	NOTE_ON = (PLAY[0] || SUS);
	ATT_ON =		PLAY[1];
	NEXT_PLAY = {!NOTE_END, !ATT_OFF, PLAY[0] && !NOTE_END};
	
	if (AVL_ADDR[7]) AVL_READDATA = {12'h000, ctrl_reg[AVL_ADDR[3:0]]};
	else begin
		AVL_READDATA = {25'h000000, AVL_READVEL};
		if (AVL_WRITE && !AVL_ADDR[7]) LD_VEL = 1'b1;
	end
	
	unique case (state)
	
		halted:
			if (RUN) next_state = start;
			
		start:
			if (!FIFO_FULL) next_state = check_key;
		
		check_key: 
			if (PLAY) next_state = key_on;
			else next_state = key_off;
			
		key_on: 
			if (KEY == 7'h7F) next_state = write;
			else next_state = start;
		
		key_off: 
			if (KEY == 7'h7F) next_state = write;
			else next_state = start;
		
		write: 
			next_state = start;
		
		default: ;
		
	endcase
		
	case (state)
		
		halted: ;
		
		start: ;
		
		check_key: ;
		
		key_on: 
			begin
			LD_KEY = 1'b1;
			TONE_MUX = 1'b1;
			LD_TONE = 1'b1;
			AMP_SEL = 1'b0;
			LD_AMP = 1'b1;
			LD_PHASE = 1'b1;
			LD_PLAY = 1'b1;
			PHASE_MUX = 1'b1;
			end
		
		key_off: 
			begin
			LD_KEY = 1'b1;
			PHASE_MUX = 1'b0;
			LD_PHASE = 1'b1;
			AMP_SEL = 1'b1;
			LD_AMP = 1'b1;
			end
		
		write: 
			begin
			LD_FIFO = 1'b1;
			TONE_MUX = 1'b0;
			LD_TONE = 1'b1;
			end
		
		default: ;
		
	endcase
end

endmodule
