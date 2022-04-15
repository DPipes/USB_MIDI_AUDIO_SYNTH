`define FIFO_DEPTH 16

// 16 word 16 bit FIFO with input and output clocks
// Can expand to 32 bit if stereo is implemented

module fifo_16x16 (input logic W_CLK, R_CLK, RESET, READ, WRITE,
						  input logic [15:0] DIN,
						  output logic FULL, EMPTY,
						  output logic [15:0] DOUT
						  );
						  
logic [15:0] REG [`FIFO_DEPTH];

// READ_COUNTER points to next word to be output
// WRITE_COUNTER points to next word to be written to
logic [3:0] READ_COUNTER, WRITE_COUNTER;

always_comb begin
	
	EMPTY = (READ_COUNTER == WRITE_COUNTER);
	FULL = (WRITE_COUNTER + 1 == READ_COUNTER);
	
end

// Set to read on negative clock edge so its output lines up with each left-right audio sample
always_ff @ (negedge R_CLK) begin
	
	if (RESET) begin
		DOUT <= 0;
		READ_COUNTER <= 0;
	end
	
	if (READ) begin
		if (READ_COUNTER != WRITE_COUNTER) begin
			DOUT <= REG[READ_COUNTER];
			READ_COUNTER <= (READ_COUNTER + 1);
		end
	end
	
end
	
always_ff @ (posedge W_CLK) begin

	if (RESET) begin
		WRITE_COUNTER <= 0;
	end
	
	if (WRITE) begin
		if (WRITE_COUNTER + 1 != READ_COUNTER) begin
			REG[WRITE_COUNTER] <= DIN;
			WRITE_COUNTER <= (WRITE_COUNTER + 1);
		end
	end
	
end

endmodule
