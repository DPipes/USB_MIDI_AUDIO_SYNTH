
module USB_MIDI_AUDIO_SYNTH (
	clk_clk,
	hex_digits_export,
	i2c0_sda_in,
	i2c0_scl_in,
	i2c0_sda_oe,
	i2c0_scl_oe,
	i2s_clk_clk,
	input_port_run,
	input_port_fifo_full,
	key_external_connection_export,
	keycode_export,
	leds_export,
	main_clk_clk,
	output_port_ld_fifo,
	output_port_tone,
	reset_reset_n,
	sdram_clk_clk,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	spi0_MISO,
	spi0_MOSI,
	spi0_SCLK,
	spi0_SS_n,
	sw_wire_export,
	usb_gpx_export,
	usb_irq_export,
	usb_rst_export);	

	input		clk_clk;
	output	[15:0]	hex_digits_export;
	input		i2c0_sda_in;
	input		i2c0_scl_in;
	output		i2c0_sda_oe;
	output		i2c0_scl_oe;
	output		i2s_clk_clk;
	input		input_port_run;
	input		input_port_fifo_full;
	input	[3:0]	key_external_connection_export;
	output	[7:0]	keycode_export;
	output	[13:0]	leds_export;
	output		main_clk_clk;
	output		output_port_ld_fifo;
	output	[31:0]	output_port_tone;
	input		reset_reset_n;
	output		sdram_clk_clk;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[15:0]	sdram_wire_dq;
	output	[1:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	input		spi0_MISO;
	output		spi0_MOSI;
	output		spi0_SCLK;
	output		spi0_SS_n;
	input	[9:0]	sw_wire_export;
	input		usb_gpx_export;
	input		usb_irq_export;
	output		usb_rst_export;
endmodule
