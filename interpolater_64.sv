module interpolater_64(input logic [5:0] VAL,
							  input logic [15:0] SAMPLE_A, SAMPLE_B,
							  output logic [15:0] INT_SAMPLE
							 );
logic [15:0] DIFF;
logic [21:0] INT_VAL, EXT_SAMPLE, SEXT_DIFF;

always_comb begin
	DIFF = SAMPLE_B - SAMPLE_A;
	SEXT_DIFF = {DIFF[15], DIFF[15], DIFF[15], DIFF[15], DIFF[15], DIFF[15], DIFF}
	INT_VAL = SEXT_DIFF * {16'h0000, VAL};
	EXT_SAMPLE = {SAMPLE_A, 6'h00} + INT_VAL;
	INT_SAMPLE = EXT_SAMPLE[21:6];
end

endmodule