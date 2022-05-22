module TOP (

      ///////// Clocks /////////
      input     FPGA_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 3: 0]   SW,

      ///////// LED /////////
      output   [ 7: 0]   LED,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, CLK;
logic [1:0] EXTRA;

//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic	I2C_SDA_IN, I2C_SCL_IN, I2C_SDA_OE, I2C_SCL_OE;
	logic I2S_DOUT, I2S_DIN, I2S_MCLK, I2S_LRCLK, I2S_SCLK;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [7:0] keycode;
	logic [31:0] AUDIO_FIFO, AUDIO_OUT;	//Current sample to play
	logic AUDIO_EMPTY, AUDIO_FULL, AUDIO_READ, AUDIO_WRITE; //Audio FIFO signals

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//Assignments to setup I2C
	assign I2C_SCL_IN = ARDUINO_IO[15];
	assign ARDUINO_IO[15] = I2C_SCL_OE ? 1'b0 : 1'bz;
	assign I2C_SDA_IN = ARDUINO_IO[14];
	assign ARDUINO_IO[14] = I2C_SDA_OE ? 1'b0 : 1'bz;
	
	//Assignments to setup I2S
	assign ARDUINO_IO[1] = 1'bZ;
	assign I2S_DOUT = ARDUINO_IO[1];
	assign ARDUINO_IO[2] = I2S_DIN;
	assign ARDUINO_IO[3] = I2S_MCLK;
	assign ARDUINO_IO[4] = I2S_LRCLK;
	assign ARDUINO_IO[5] = I2S_SCLK;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}= 1'b0;
	
	Audio_Synthesizer_SoC SoC(
		.clk_clk(FPGA_CLK1_50),															//        clk.clk
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),		// hex_digits.export
		.i2c_port_sda_in(I2C_SDA_IN),														//   i2c_port.sda_in
		.i2c_port_scl_in(I2C_SCL_IN),														//           .scl_in
		.i2c_port_sda_oe(I2C_SDA_OE),														//           .sda_oe
		.i2c_port_scl_oe(I2C_SCL_OE),														//           .scl_oe
		.i2s_clk_clk(I2S_MCLK),          												//    i2s_clk.clk
		.leds_export({hundreds, signs, EXTRA, LED}),									//       leds.export
		.main_clk_clk(CLK),																	//   main_clk.clk
		.reset_reset_n(1'b1),																//      reset.reset_n
		.spi_port_MISO(SPI0_MISO),															//   spi_port.MISO
		.spi_port_MOSI(SPI0_MOSI),															//           .MOSI
		.spi_port_SCLK(SPI0_SCLK),															//           .SCLK
		.spi_port_SS_n(SPI0_CS_N),															//           .SS_n
		.synth_port_run(1'b1),																// synth_port.run
		.synth_port_fifo_full(AUDIO_FULL),												//           .fifo_full
		.synth_port_ld_fifo(AUDIO_WRITE),												//           .ld_fifo
		.synth_port_tone(AUDIO_FIFO),														//           .tone
		.usb_gpx_export(USB_GPX),															//    usb_gpx.export
		.usb_irq_export(USB_IRQ),															//    usb_irq.export
		.usb_rst_export(USB_RST)															//    usb_rst.export
	);

	// Generates I2S SCLK and LRCLK and transmits data to audio codec
	i2s I2S(.MCLK(I2S_MCLK), .RESET(Reset_h), .AUDIO(AUDIO_OUT), .FIFO_EMPTY(AUDIO_EMPTY), .LRCLK(I2S_LRCLK), .SCLK(I2S_SCLK), .FIFO_READ(AUDIO_READ), .DIN(I2S_DIN), .DOUT(I2S_DOUT));
	
	//	256 word FIFO to store samples. 256samples/44.1kHz means output delayed by 5.8ms
	FIFO AUDIO_fifo(.data(AUDIO_FIFO), .rdclk(I2S_LRCLK), .rdreq(AUDIO_READ), .wrclk(CLK), .wrreq(AUDIO_WRITE), .q(AUDIO_OUT), .rdempty(AUDIO_EMPTY), .wrfull(AUDIO_FULL));

	 
endmodule