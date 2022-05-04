`define numKeys 128
`define numCtrl 8

module synth_ip(input logic CLK, RESET, RUN, AVL_WRITE, AVL_READ, SW, FIFO_FULL,
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
logic [19:0]	ctrl_reg [`numCtrl];

logic				LD_PHASE, LD_COUNT, LD_TONE, LD_VEL, LD_KEY, LD_PLAY, AVL_PLAY;
logic				TONE_MUX, COUNTER_MUX, PHASE_MUX;
logic				NOTE_END, NOTE_ON;
logic [2:0]		PLAY;
logic [6:0]		KEY, NEXT_KEY, AVL_KEY, AVL_VEL, AVL_READVEL, SUSTAIN_PEDAL;
logic [19:0]	PEAK_ATT, ATT_LEN, ATT_STEP, DEC_LEN, DEC_STEP, REL_LEN, REL_STEP;

data_path DATA_PATH(.*);

always_ff @ (posedge CLK or posedge RESET) begin
	
	if (RESET) begin
		state <= halted;
		ctrl_reg[0] <= 20'hE2194;
		ctrl_reg[1] <= 20'hAC44;
		ctrl_reg[2] <= 20'h15;
		ctrl_reg[3] <= 20'hAC44;
		ctrl_reg[4] <= 20'h9;
		ctrl_reg[5] <= 20'hAC44;
		ctrl_reg[6] <= 20'hB;
		ctrl_reg[7] <= 20'h0;
		KEY <= 0;
	end
	else begin
		state <= next_state;
		
		if (LD_KEY) KEY <= NEXT_KEY;
		if (LD_PLAY) play_reg[KEY][2:1] <= {!NOTE_END, PLAY[0]};
		
		if (AVL_WRITE) begin
			
			if (AVL_ADDR[7]) begin
				ctrl_reg[AVL_ADDR[2:0]] <= AVL_WRITEDATA[19:0];
			end
			else begin
				play_reg[AVL_KEY][0] <= AVL_PLAY;
			end
		end
	end
	
end

always_comb begin
	
	next_state = state;
	NEXT_KEY = KEY + 7'h01;
	
	PLAY = play_reg[KEY];
	PEAK_ATT = ctrl_reg[0];
	ATT_LEN = ctrl_reg[1];
	ATT_STEP = ctrl_reg[2];
	DEC_LEN = ctrl_reg[3];
	DEC_STEP = ctrl_reg[4];
	REL_LEN = ctrl_reg[5];
	REL_STEP = ctrl_reg[6];
	SUSTAIN_PEDAL = ctrl_reg[7][6:0];
	
	LD_PHASE = 1'b0;
	LD_COUNT = 1'b0;
	LD_TONE = 1'b0;
	LD_FIFO = 1'b0;
	LD_KEY = 1'b0;
	LD_PLAY = 1'b0;
	LD_VEL = 1'b0;
	
	TONE_MUX = 1'b1;
	COUNTER_MUX = 1'b1;
	PHASE_MUX = 1'b1;
	
	NOTE_ON = PLAY[0];
	
	AVL_PLAY = AVL_WRITEDATA[7];
	AVL_KEY = AVL_ADDR[6:0];
	AVL_VEL = AVL_WRITEDATA[6:0];
	
	if (AVL_ADDR[7]) AVL_READDATA = {12'h000, ctrl_reg[AVL_ADDR[2:0]]};
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
			if (PLAY[0] == 1'b1) begin
				COUNTER_MUX = PLAY[1];
			end
			LD_COUNT = 1'b1;
			LD_PHASE = 1'b1;
			LD_PLAY = 1'b1;
			PHASE_MUX = 1'b1;
			end
		
		key_off: 
			begin
			LD_KEY = 1'b1;
			PHASE_MUX = 1'b0;
			LD_PHASE = 1'b1;
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
