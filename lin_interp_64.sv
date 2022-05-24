module lin_interp_64(input logic [5:0] SEL,
							input logic [15:0] SAMPLE_1, SAMPLE_2,
							output logic [15:0] SAMPLE_OUT
						  );
logic [15:0] DIFF;
logic [21:0] SEXT_DIFF, SAMPLE_O;

always_comb begin
	DIFF = SAMPLE_2 - SAMPLE_1;
	SEXT_DIFF = {DIFF[15], DIFF[15], DIFF[15], DIFF[15], DIFF[15], DIFF[15], DIFF};
	SAMPLE_O = {SAMPLE_1, 6'h00} + (SEXT_DIFF * SEL);
	SAMPLE_OUT = SAMPLE_O[21:6];
end
			
endmodule