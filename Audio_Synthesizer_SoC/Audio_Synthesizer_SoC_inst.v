	Audio_Synthesizer_SoC u0 (
		.clk_clk              (<connected-to-clk_clk>),              //        clk.clk
		.hex_digits_export    (<connected-to-hex_digits_export>),    // hex_digits.export
		.i2c_port_sda_in      (<connected-to-i2c_port_sda_in>),      //   i2c_port.sda_in
		.i2c_port_scl_in      (<connected-to-i2c_port_scl_in>),      //           .scl_in
		.i2c_port_sda_oe      (<connected-to-i2c_port_sda_oe>),      //           .sda_oe
		.i2c_port_scl_oe      (<connected-to-i2c_port_scl_oe>),      //           .scl_oe
		.i2s_clk_clk          (<connected-to-i2s_clk_clk>),          //    i2s_clk.clk
		.leds_export          (<connected-to-leds_export>),          //       leds.export
		.main_clk_clk         (<connected-to-main_clk_clk>),         //   main_clk.clk
		.reset_reset_n        (<connected-to-reset_reset_n>),        //      reset.reset_n
		.spi_port_MISO        (<connected-to-spi_port_MISO>),        //   spi_port.MISO
		.spi_port_MOSI        (<connected-to-spi_port_MOSI>),        //           .MOSI
		.spi_port_SCLK        (<connected-to-spi_port_SCLK>),        //           .SCLK
		.spi_port_SS_n        (<connected-to-spi_port_SS_n>),        //           .SS_n
		.usb_gpx_export       (<connected-to-usb_gpx_export>),       //    usb_gpx.export
		.usb_irq_export       (<connected-to-usb_irq_export>),       //    usb_irq.export
		.usb_rst_export       (<connected-to-usb_rst_export>),       //    usb_rst.export
		.synth_port_run       (<connected-to-synth_port_run>),       // synth_port.run
		.synth_port_fifo_full (<connected-to-synth_port_fifo_full>), //           .fifo_full
		.synth_port_ld_fifo   (<connected-to-synth_port_ld_fifo>),   //           .ld_fifo
		.synth_port_tone      (<connected-to-synth_port_tone>)       //           .tone
	);

