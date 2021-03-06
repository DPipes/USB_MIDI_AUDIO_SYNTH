`define NUM_REGS 600

module vram (
	input logic CLK,
	input logic RESET,
	input  logic AVL_WRITE,
	input  logic [3:0] AVL_BYTE_EN,
	input  logic [9:0] AVL_ADDR,
	input  logic [31:0] AVL_WRITEDATA,
	output logic [31:0] AVL_READDATA,
	input  logic [9:0] VGA_ADDR,
	output logic [31:0] VGA_READDATA);
	
logic [3:0][7:0] mem [`NUM_REGS];

always_ff @(posedge CLK) begin

	if (AVL_WRITE) begin
		if(AVL_BYTE_EN[0]) mem[AVL_ADDR][0] <= AVL_WRITEDATA[7:0];
		if(AVL_BYTE_EN[1]) mem[AVL_ADDR][1] <= AVL_WRITEDATA[15:8];
		if(AVL_BYTE_EN[2]) mem[AVL_ADDR][2] <= AVL_WRITEDATA[23:16];
		if(AVL_BYTE_EN[3]) mem[AVL_ADDR][3] <= AVL_WRITEDATA[31:24];
	end
		
	AVL_READDATA <= mem[AVL_ADDR];
	VGA_READDATA <= mem[VGA_ADDR];

end

endmodule
