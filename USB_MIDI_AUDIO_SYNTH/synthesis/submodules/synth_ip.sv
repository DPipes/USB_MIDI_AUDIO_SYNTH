`define numKeys 128

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

logic				LD_PHASE, LD_COUNT, LD_TONE, LD_VEL, LD_KEY, LD_PLAY, AVL_PLAY;
logic				TONE_MUX, COUNTER_MUX, PHASE_MUX;
logic				NOTE_END, NOTE_ON;
logic [2:0]		PLAY;
logic [6:0]		KEY, NEXT_KEY, AVL_KEY, AVL_VEL, AVL_READVEL;
logic [19:0]	PEAK_ATT, ATT_LEN, ATT_STEP, DEC_LEN, DEC_STEP, REL_LEN, REL_STEP;

data_path DATA_PATH(.*);

always_ff @ (posedge CLK) begin
	
	if (RESET) 
		state <= halted;
	else 
		state <= next_state;
	
	if (LD_KEY) KEY <= NEXT_KEY;
	if (LD_PLAY) play_reg[KEY][2:1] <= {!NOTE_END, PLAY[0]};
	
	if (AVL_WRITE) begin
		
		if (AVL_ADDR[7]) begin
			case (AVL_ADDR[6:0])
				0: PEAK_ATT <= AVL_WRITEDATA[19:0];
				1: ATT_LEN <= AVL_WRITEDATA[19:0];
				2: ATT_STEP <= AVL_WRITEDATA[19:0];
				3: DEC_LEN <= AVL_WRITEDATA[19:0];
				4: DEC_STEP <= AVL_WRITEDATA[19:0];
				5: REL_LEN <= AVL_WRITEDATA[19:0];
				6: REL_STEP <= AVL_WRITEDATA[19:0];
				default: ;
			endcase
		end
		else begin
			play_reg[AVL_KEY][0] <= AVL_PLAY;
		end
		
	end
	
end

always_comb begin
	
	
	next_state = state;
	NEXT_KEY = KEY + 7'h01;
	PLAY = play_reg[KEY];
	
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
	AVL_READDATA = {25'h000000, AVL_READVEL};
	if (AVL_WRITE && !AVL_ADDR[7]) LD_VEL = 1'b1;
	
	unique case (state)
	
		halted:
			if (RUN) next_state = start;
			
		start:
			if (FIFO_FULL) next_state = start;
			else next_state = check_key;
		
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
				PHASE_MUX = PLAY[1];
			end
			LD_COUNT = 1'b1;
			LD_PHASE = 1'b1;
			LD_PLAY = 1'b1;
			end
		
		key_off: 
			begin
			LD_KEY = 1'b1;
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
