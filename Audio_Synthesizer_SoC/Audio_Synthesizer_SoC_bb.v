
module Audio_Synthesizer_SoC (
	clk_clk,
	hex_digits_export,
	i2c_port_sda_in,
	i2c_port_scl_in,
	i2c_port_sda_oe,
	i2c_port_scl_oe,
	i2s_clk_clk,
	leds_export,
	main_clk_clk,
	reset_reset_n,
	spi_port_MISO,
	spi_port_MOSI,
	spi_port_SCLK,
	spi_port_SS_n,
	usb_gpx_export,
	usb_irq_export,
	usb_rst_export,
	synth_port_run,
	synth_port_fifo_full,
	synth_port_ld_fifo,
	synth_port_tone);	

	input		clk_clk;
	output	[15:0]	hex_digits_export;
	input		i2c_port_sda_in;
	input		i2c_port_scl_in;
	output		i2c_port_sda_oe;
	output		i2c_port_scl_oe;
	output		i2s_clk_clk;
	output	[13:0]	leds_export;
	output		main_clk_clk;
	input		reset_reset_n;
	input		spi_port_MISO;
	output		spi_port_MOSI;
	output		spi_port_SCLK;
	output		spi_port_SS_n;
	input		usb_gpx_export;
	input		usb_irq_export;
	output		usb_rst_export;
	input		synth_port_run;
	input		synth_port_fifo_full;
	output		synth_port_ld_fifo;
	output	[31:0]	synth_port_tone;
endmodule
