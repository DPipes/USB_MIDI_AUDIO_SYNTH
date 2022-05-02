`define numWaves	8192

module wave_table(input logic CLK, 
					  input logic [12:0] ADDR,
					  output logic [15:0] SAMPLE
					  );
					  
logic [15:0] wave [`numWaves];

initial begin

	$readmemh("wavetable.txt", wave);

end
					  
always_ff @ (posedge CLK) begin

	SAMPLE <= wave[ADDR];

end

endmodule
