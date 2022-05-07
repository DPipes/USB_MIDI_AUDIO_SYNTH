# USB_MIDI_AUDIO_SYNTH

This is a final code as demoed for an FPGA design project for ECE 385 in the spring of 2022 at the University of Illinois - Urbana Champaign.

The design is a digital audio synthesiser that takes input via USB-MIDI. It is running on a MAX10 FPGA, handling USB input with a MAX3451 over SPI, and outputting audio with a SGTL5000 over I2S.

The audio synthesizer can handle playing all 128 MIDI notes simultaneously and it works via wavetable synthesis. It has control over attack, decay, sustain, and release times; attack and sustain amplitudes; and other MIDI controls such as pitch bend, mod wheel, sustain pedal, etc.

To run the design it needs to be connected to some sort of MIDI controller via the USB port. In its current configuration it cannot act as USB slave. Therefore, it cannot connect to a PC to recieve MIDI data, though an Android phone was successful intermittently. With an acceptable device connected, it only needs to be programmed through Quartus and Eclipse and after initializing it should be able to play notes as sent from the MIDI controller.

MIDI Notes:
	- The device is only configured to play notes on the channel indexed 0, commonly referred to as channel 1 in MIDI, any notes sent on other channels will not be played.
	- Many of the controls (volume, pitch bend, ADSR settings, mod wheel, etc.) are mapped to specific MIDI control numbers that may be configured differently depending on the controller, even without these controls it should still be able to play properly after being programmed in Eclipse.
	- The control numbers it uses are listed below.

Control Changes:

MODULATION WHEEL		0x01
CHANNEL VOLUME		0x07	
WAVETABLE 1 SEL		0x09	Selects from the upper byte of the control value which of the 8 wavetables is played when not using mod wheel.
WAVETABLE 2 SEL		0x0E	Selects from the upper byte of the control value which of the 8 wavetables is used when mixing with mod wheel.
SUSTAIN PEDAL		0x40	
INVERT PEDAL		0x52*	When high, inverts pedal control. Depending on the devices used, some pedals will read high when off and this counters that. 
MODULATION WHEEL ACTIVE	0x55*	Allows the mod wheel to be used to mix 2 wavetable outputs together.
BEND ACTIVE			0x56*	Allows pitch bend wheel to be used.
ATTACK TIME HIGH		0x49	
ATTACK TIME LOW		0x68	In order to allow finer control of ADSR times, there is both a high and low control for each parameter.
DECAY TIME HIGH		0x4B	These are not high and low bytes, rather the HIGH control has a total range 25 times that of the LOW control.
DECAY TIME LOW		0x69	The attack and decay times do not have as great of a range as the release time which is also less than the sustain time.
SUSTAIN TIME HIGH		0x03	This is so that the user has very fine control of attack and decay, which will generally be shorter, and it is possible to
SUSTAIN TIME LOW		0x6A	have prolonged sustain and release times.
RELEASE TIME HIGH		0x48
RELEASE TIME LOW		0x6B	
ATTACK AMPLITUDE		0x6C	The attack amplitude control is relative to the sustain amplitude. At 0 the attack amplitude will equal the sustain amplitude and
SUSTAIN AMPLITUDE		0x6D	at a maximum it will be double

*These parameters read the least significant bit of the control value so they should be connected to a switch that only outputs either 0x00 or 0x7F.