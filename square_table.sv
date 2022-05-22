`define numWaves	4096

module square_table(input logic CLK, 
					  input logic [11:0] ADDR,
					  output logic [15:0] SAMPLE
					  );
					  
logic [15:0] wave [`numWaves];

initial begin

	$readmemh("square_table.txt", wave);

end
					  
always_ff @ (posedge CLK) begin

	SAMPLE <= wave[ADDR];

end

endmodule
