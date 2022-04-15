// I2S Module for 44.1 kHz sample rate
// Takes input of 256 * 44.1 kHz MCLK
// Generates 64 * 44.1 kHz SCLK and 44.1 kHz LRCLK

module i2s (input logic MCLK, RESET, DOUT, FIFO_EMPTY,
				input logic [15:0] AUDIO,
				output logic LRCLK, SCLK, DIN, FIFO_READ
				);

logic [7:0] COUNTER;
logic [3:0] PHASE_COUNTER;
logic FLAG, TRANSMIT;

// FIFO_READ is always high so the FIFO will put out a new value every LRCLK if it can
assign FIFO_READ = 1;

always_ff @ (posedge MCLK) begin
	
	if(RESET) begin
	
		COUNTER <= 0;
	
	end
	
	COUNTER <= (COUNTER + 1);
	
	SCLK <= COUNTER[1];	// Counts MCLK/4
	LRCLK <= COUNTER[7]; // Counts MCLK/256
	
end

always_ff @ (posedge SCLK) begin
	
	if (RESET) begin
	
		PHASE_COUNTER <= 0;
		
	end
	
	FLAG <= LRCLK;
	
	// The read clock of the FIFO is LRCLK so its write bit can be held high
	//FIFO_READ <= 0;
	
	if (LRCLK != FLAG) begin
		
		TRANSMIT <= 1;
		
		//if (!LRCLK && !FIFO_EMPTY) FIFO_READ <= 1;
		
	end
	
	if (TRANSMIT) PHASE_COUNTER <= (PHASE_COUNTER + 1);
	
	if (PHASE_COUNTER == 15) TRANSMIT <= 0;
	
end

always_ff @ (negedge SCLK) begin

	if (TRANSMIT) DIN <= AUDIO[~PHASE_COUNTER];
	
end

endmodule
