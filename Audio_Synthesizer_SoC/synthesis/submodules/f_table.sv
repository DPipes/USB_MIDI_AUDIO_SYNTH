`define numNotes 128

module f_table(input logic CLK,
					input logic [6:0] KEY,
					output logic [23:0] F
				  );
					  
logic [23:0] f [`numNotes];

initial begin

	$readmemh("f_table.txt", f);

end
					  
always_ff @ (posedge CLK) begin

	F <= f[KEY];

end

endmodule