/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK_100,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [9:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

//put other local variables here
logic [10:0] ROM_ADDR;
logic [31:0] RAM_DATA, RAM_READDATA, RAM_WRITEDATA, CTRL_REG;
logic [7:0] ROM_DATA, glyph_data;
logic [9:0] DrawX, DrawY, RAM_ADDR;
logic [3:0] red_on, green_on, blue_on, red_off, green_off, blue_off;
logic pixel_clk, inv, pixel_on, blank, RAM_WRITE, CLK;

//Declare submodules..e.g. VGA controller, ROMS, etc
font_rom ROM(.addr(ROM_ADDR), .data(ROM_DATA));
vga_controller VGA(.CLK(CLK), .RESET(RESET), .hs(hs), .vs(vs), .pixel_clk(pixel_clk), .blank(blank), .sync(       ), .DrawX(DrawX), .DrawY(DrawY));

vram VRAM(.*, .AVL_WRITE(RAM_WRITE), .AVL_WRITEDATA(RAM_WRITEDATA), .AVL_READDATA(RAM_READDATA), .AVL_ADDR(AVL_ADDR[9:0]), .VGA_READDATA(RAM_DATA), .VGA_ADDR(RAM_ADDR));
   
always_ff @ (posedge CLK_100 or posedge RESET) begin
	if(RESET) CLK <= 1'b0;
	else CLK <= ~(CLK);
end	

// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
always_ff @(posedge CLK) begin
	RAM_WRITE <= 1'b0;
	
	if(AVL_ADDR < 600) begin
		if(AVL_WRITE) begin
			RAM_WRITE <= 1'b1;
			RAM_WRITEDATA <= AVL_WRITEDATA;
		end
		AVL_READDATA <= RAM_READDATA;
	end
	else begin
		if (AVL_ADDR == 600) begin
			if (AVL_WRITE) begin
				CTRL_REG <= AVL_WRITEDATA;
			end
			AVL_READDATA <= CTRL_REG;
		end
	end
	
end


//handle drawing (may either be combinational or sequential - or both).

always_comb begin

	RAM_ADDR = (DrawY[8:4] * 20) + DrawX[9:5];
	
	case (DrawX[4:3]) 
		2'b00: glyph_data = RAM_DATA[7:0];
		2'b01: glyph_data = RAM_DATA[15:8];
		2'b10: glyph_data = RAM_DATA[23:16];
		2'b11: glyph_data = RAM_DATA[31:24];
	endcase
	
	red_on = CTRL_REG[24:21];
	green_on = CTRL_REG[20:17];
	blue_on = CTRL_REG[16:13];
	
	red_off = CTRL_REG[12:9];
	green_off = CTRL_REG[8:5];
	blue_off = CTRL_REG[4:1];
	
	ROM_ADDR = {glyph_data[6:0],DrawY[3:0]};
	
	inv = glyph_data[7];
	
	pixel_on = ROM_DATA[~DrawX[2:0]];
	
	if(inv) begin
		pixel_on = !pixel_on;
	end
	
	if(!blank) begin
		red = 4'b0000;
		blue = 4'b0000;
		green = 4'b0000;
	end
	
	else if(pixel_on) begin
		red = red_on;
		green = green_on;
		blue = blue_on;
	end
	
	else begin
		red = red_off;
		green = green_off;
		blue = blue_off;
	end
end

endmodule
