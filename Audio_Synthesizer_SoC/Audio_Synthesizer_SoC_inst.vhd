	component Audio_Synthesizer_SoC is
		port (
			clk_clk              : in  std_logic                     := 'X'; -- clk
			hex_digits_export    : out std_logic_vector(15 downto 0);        -- export
			i2c_port_sda_in      : in  std_logic                     := 'X'; -- sda_in
			i2c_port_scl_in      : in  std_logic                     := 'X'; -- scl_in
			i2c_port_sda_oe      : out std_logic;                            -- sda_oe
			i2c_port_scl_oe      : out std_logic;                            -- scl_oe
			i2s_clk_clk          : out std_logic;                            -- clk
			leds_export          : out std_logic_vector(13 downto 0);        -- export
			main_clk_clk         : out std_logic;                            -- clk
			reset_reset_n        : in  std_logic                     := 'X'; -- reset_n
			spi_port_MISO        : in  std_logic                     := 'X'; -- MISO
			spi_port_MOSI        : out std_logic;                            -- MOSI
			spi_port_SCLK        : out std_logic;                            -- SCLK
			spi_port_SS_n        : out std_logic;                            -- SS_n
			usb_gpx_export       : in  std_logic                     := 'X'; -- export
			usb_irq_export       : in  std_logic                     := 'X'; -- export
			usb_rst_export       : out std_logic;                            -- export
			synth_port_run       : in  std_logic                     := 'X'; -- run
			synth_port_fifo_full : in  std_logic                     := 'X'; -- fifo_full
			synth_port_ld_fifo   : out std_logic;                            -- ld_fifo
			synth_port_tone      : out std_logic_vector(31 downto 0)         -- tone
		);
	end component Audio_Synthesizer_SoC;

	u0 : component Audio_Synthesizer_SoC
		port map (
			clk_clk              => CONNECTED_TO_clk_clk,              --        clk.clk
			hex_digits_export    => CONNECTED_TO_hex_digits_export,    -- hex_digits.export
			i2c_port_sda_in      => CONNECTED_TO_i2c_port_sda_in,      --   i2c_port.sda_in
			i2c_port_scl_in      => CONNECTED_TO_i2c_port_scl_in,      --           .scl_in
			i2c_port_sda_oe      => CONNECTED_TO_i2c_port_sda_oe,      --           .sda_oe
			i2c_port_scl_oe      => CONNECTED_TO_i2c_port_scl_oe,      --           .scl_oe
			i2s_clk_clk          => CONNECTED_TO_i2s_clk_clk,          --    i2s_clk.clk
			leds_export          => CONNECTED_TO_leds_export,          --       leds.export
			main_clk_clk         => CONNECTED_TO_main_clk_clk,         --   main_clk.clk
			reset_reset_n        => CONNECTED_TO_reset_reset_n,        --      reset.reset_n
			spi_port_MISO        => CONNECTED_TO_spi_port_MISO,        --   spi_port.MISO
			spi_port_MOSI        => CONNECTED_TO_spi_port_MOSI,        --           .MOSI
			spi_port_SCLK        => CONNECTED_TO_spi_port_SCLK,        --           .SCLK
			spi_port_SS_n        => CONNECTED_TO_spi_port_SS_n,        --           .SS_n
			usb_gpx_export       => CONNECTED_TO_usb_gpx_export,       --    usb_gpx.export
			usb_irq_export       => CONNECTED_TO_usb_irq_export,       --    usb_irq.export
			usb_rst_export       => CONNECTED_TO_usb_rst_export,       --    usb_rst.export
			synth_port_run       => CONNECTED_TO_synth_port_run,       -- synth_port.run
			synth_port_fifo_full => CONNECTED_TO_synth_port_fifo_full, --           .fifo_full
			synth_port_ld_fifo   => CONNECTED_TO_synth_port_ld_fifo,   --           .ld_fifo
			synth_port_tone      => CONNECTED_TO_synth_port_tone       --           .tone
		);

