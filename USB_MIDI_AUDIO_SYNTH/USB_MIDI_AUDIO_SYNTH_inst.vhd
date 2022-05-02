	component USB_MIDI_AUDIO_SYNTH is
		port (
			clk_clk                        : in    std_logic                     := 'X';             -- clk
			hex_digits_export              : out   std_logic_vector(15 downto 0);                    -- export
			i2c0_sda_in                    : in    std_logic                     := 'X';             -- sda_in
			i2c0_scl_in                    : in    std_logic                     := 'X';             -- scl_in
			i2c0_sda_oe                    : out   std_logic;                                        -- sda_oe
			i2c0_scl_oe                    : out   std_logic;                                        -- scl_oe
			i2s_clk_clk                    : out   std_logic;                                        -- clk
			input_port_run                 : in    std_logic                     := 'X';             -- run
			input_port_sw                  : in    std_logic                     := 'X';             -- sw
			input_port_fifo_full           : in    std_logic                     := 'X';             -- fifo_full
			key_external_connection_export : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			keycode_export                 : out   std_logic_vector(7 downto 0);                     -- export
			leds_export                    : out   std_logic_vector(13 downto 0);                    -- export
			main_clk_clk                   : out   std_logic;                                        -- clk
			output_port_ld_fifo            : out   std_logic;                                        -- ld_fifo
			output_port_tone               : out   std_logic_vector(31 downto 0);                    -- tone
			reset_reset_n                  : in    std_logic                     := 'X';             -- reset_n
			sdram_clk_clk                  : out   std_logic;                                        -- clk
			sdram_wire_addr                : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_wire_ba                  : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_wire_cas_n               : out   std_logic;                                        -- cas_n
			sdram_wire_cke                 : out   std_logic;                                        -- cke
			sdram_wire_cs_n                : out   std_logic;                                        -- cs_n
			sdram_wire_dq                  : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_wire_dqm                 : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_wire_ras_n               : out   std_logic;                                        -- ras_n
			sdram_wire_we_n                : out   std_logic;                                        -- we_n
			spi0_MISO                      : in    std_logic                     := 'X';             -- MISO
			spi0_MOSI                      : out   std_logic;                                        -- MOSI
			spi0_SCLK                      : out   std_logic;                                        -- SCLK
			spi0_SS_n                      : out   std_logic;                                        -- SS_n
			sw_wire_export                 : in    std_logic_vector(9 downto 0)  := (others => 'X'); -- export
			usb_gpx_export                 : in    std_logic                     := 'X';             -- export
			usb_irq_export                 : in    std_logic                     := 'X';             -- export
			usb_rst_export                 : out   std_logic                                         -- export
		);
	end component USB_MIDI_AUDIO_SYNTH;

	u0 : component USB_MIDI_AUDIO_SYNTH
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                     clk.clk
			hex_digits_export              => CONNECTED_TO_hex_digits_export,              --              hex_digits.export
			i2c0_sda_in                    => CONNECTED_TO_i2c0_sda_in,                    --                    i2c0.sda_in
			i2c0_scl_in                    => CONNECTED_TO_i2c0_scl_in,                    --                        .scl_in
			i2c0_sda_oe                    => CONNECTED_TO_i2c0_sda_oe,                    --                        .sda_oe
			i2c0_scl_oe                    => CONNECTED_TO_i2c0_scl_oe,                    --                        .scl_oe
			i2s_clk_clk                    => CONNECTED_TO_i2s_clk_clk,                    --                 i2s_clk.clk
			input_port_run                 => CONNECTED_TO_input_port_run,                 --              input_port.run
			input_port_sw                  => CONNECTED_TO_input_port_sw,                  --                        .sw
			input_port_fifo_full           => CONNECTED_TO_input_port_fifo_full,           --                        .fifo_full
			key_external_connection_export => CONNECTED_TO_key_external_connection_export, -- key_external_connection.export
			keycode_export                 => CONNECTED_TO_keycode_export,                 --                 keycode.export
			leds_export                    => CONNECTED_TO_leds_export,                    --                    leds.export
			main_clk_clk                   => CONNECTED_TO_main_clk_clk,                   --                main_clk.clk
			output_port_ld_fifo            => CONNECTED_TO_output_port_ld_fifo,            --             output_port.ld_fifo
			output_port_tone               => CONNECTED_TO_output_port_tone,               --                        .tone
			reset_reset_n                  => CONNECTED_TO_reset_reset_n,                  --                   reset.reset_n
			sdram_clk_clk                  => CONNECTED_TO_sdram_clk_clk,                  --               sdram_clk.clk
			sdram_wire_addr                => CONNECTED_TO_sdram_wire_addr,                --              sdram_wire.addr
			sdram_wire_ba                  => CONNECTED_TO_sdram_wire_ba,                  --                        .ba
			sdram_wire_cas_n               => CONNECTED_TO_sdram_wire_cas_n,               --                        .cas_n
			sdram_wire_cke                 => CONNECTED_TO_sdram_wire_cke,                 --                        .cke
			sdram_wire_cs_n                => CONNECTED_TO_sdram_wire_cs_n,                --                        .cs_n
			sdram_wire_dq                  => CONNECTED_TO_sdram_wire_dq,                  --                        .dq
			sdram_wire_dqm                 => CONNECTED_TO_sdram_wire_dqm,                 --                        .dqm
			sdram_wire_ras_n               => CONNECTED_TO_sdram_wire_ras_n,               --                        .ras_n
			sdram_wire_we_n                => CONNECTED_TO_sdram_wire_we_n,                --                        .we_n
			spi0_MISO                      => CONNECTED_TO_spi0_MISO,                      --                    spi0.MISO
			spi0_MOSI                      => CONNECTED_TO_spi0_MOSI,                      --                        .MOSI
			spi0_SCLK                      => CONNECTED_TO_spi0_SCLK,                      --                        .SCLK
			spi0_SS_n                      => CONNECTED_TO_spi0_SS_n,                      --                        .SS_n
			sw_wire_export                 => CONNECTED_TO_sw_wire_export,                 --                 sw_wire.export
			usb_gpx_export                 => CONNECTED_TO_usb_gpx_export,                 --                 usb_gpx.export
			usb_irq_export                 => CONNECTED_TO_usb_irq_export,                 --                 usb_irq.export
			usb_rst_export                 => CONNECTED_TO_usb_rst_export                  --                 usb_rst.export
		);

