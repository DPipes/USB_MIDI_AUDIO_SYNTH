
module testbench();

timeunit 1ns;	

timeprecision 1ns;

logic CLK = 0;
logic MCLK = 0;
logic LRCLK, SCLK;
logic RESET, RUN, AVL_WRITE, SW, FIFO_FULL, FIFO_EMPTY, FIFO_READ, DIN, DOUT;
logic [7:0] AVL_ADDR;
logic [31:0] AVL_WRITEDATA;
logic LD_FIFO;
logic [31:0] AVL_READDATA, TONE, FIFO_OUT;

logic				LD_PHASE, LD_COUNT, LD_TONE, LD_VEL, LD_KEY, LD_PLAY, AVL_PLAY;
logic				TONE_MUX, COUNTER_MUX, PHASE_MUX;
logic				NOTE_END, NOTE_ON;
logic [2:0]		PLAY, state_, next_state_;
logic [6:0]		KEY, NEXT_KEY, AVL_KEY, AVL_VEL, AVL_READVEL;
logic [19:0]	PEAK_ATT, ATT_LEN, ATT_STEP, DEC_LEN, DEC_STEP, REL_LEN, REL_STEP;

synth_ip SYNTH(.*, .AVL_READ());

i2s I2S(.*, .AUDIO(FIFO_OUT));
					
FIFO fifo(.data(TONE), .rdclk(LRCLK), .rdreq(FIFO_READ), .wrclk(CLK), .wrreq(LD_FIFO), .q(FIFO_OUT), .rdempty(FIFO_EMPTY), .wrfull(FIFO_FULL));

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#5 CLK = ~CLK;
#5 CLK = ~CLK;
#5 CLK = ~CLK;
#5 CLK = ~CLK;
#5 CLK = ~CLK;
#5 CLK = ~CLK;
#5 CLK = ~CLK;
#5 CLK = ~CLK;
#5 CLK = ~CLK;
#5 CLK = ~CLK;
	MCLK = ~MCLK;
end

initial begin: CLOCK_INITIALIZATION
    CLK = 0;
	 MCLK = 0;
end 

initial begin: TEST_VECTORS
RESET = 1'b1;
RUN = 1'b0;
DOUT = 1'b0;
SW = 1'b0;
FIFO_FULL = 1'b0;

#1000 RESET = 1'b0;
	RUN = 1'b1;
	AVL_ADDR = 8'h3C;
	
#200 RUN = 1'b0;
	AVL_WRITEDATA = 32'h000000FF;
	AVL_WRITE = 1'b1;
	
#10 AVL_WRITE = 1'b0;

//if (ErrorCnt == 0)
//	$display("Success!");  // Command line output in ModelSim
//else
//	$display("%d error(s) detected. Try again!", ErrorCnt);

end

endmodule
