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

<b>0x07: CHANNEL VOLUME</b>

<b>0x09: WAVETABLE 1</b>

- Selects which of the 8 wavetables is played when not using mod wheel. Selection is based on upper byte of the control value.

<b>0x0E: WAVETABLE 2</b>

- Selects which of the 8 wavetables is used when mixing with mod wheel. Selection is based on upper byte of the control value.

<b>0x55: MODULATION WHEEL ACTIVE</b>	*

- Allows the mod wheel to be used to mix 2 wavetable outputs together.

<b>0x01: MODULATION WHEEL</b>

<b>0x40: SUSTAIN PEDAL</b>

<b>0x52: INVERT PEDAL</b>	*

- When high, inverts pedal control. Depending on the devices used, some pedals will read high when off and this counters that. 

<b>0x56: BEND ACTIVE</b>	*

- Allows pitch bend wheel to be used.

<em>In order to allow finer control of ADSR times, there is both a high and low control for each parameter. These are not high and low bytes, rather the HIGH control has a total range 25 times that of the LOW control. The attack and decay times do not have as great of a range as the release time which is also less than the sustain time. This is so that the user has very fine control of attack and decay, which will generally be shorter, and it is possible to have prolonged sustain and release times.</em>

<b>0x49: ATTACK TIME HIGH</b>

<b>0x68: ATTACK TIME LOW</b>

<b>0x4B: DECAY TIME HIGH</b>

<b>0x69: DECAY TIME LOW</b>

<b>0x03: SUSTAIN TIME HIGH</b>

<b>0x6A: SUSTAIN TIME LOW</b>

<b>0x48: RELEASE TIME HIGH</b>

<b>0x6B: RELEASE TIME LOW</b>	

<em>The attack amplitude control is relative to the sustain amplitude. At 0 the attack amplitude will equal the sustain amplitude and at a maximum it will be double. I would not recommend setting either amplitude exactly to 0 though because it gets funky and will beat you up.</em>

<b>0x6C: ATTACK AMPLITUDE</b>	

<b>0x6D: SUSTAIN AMPLITUDE</b>

*<em> These parameters read the least significant bit of the control value so they should be connected to a switch that only outputs either 0x00 or 0x7F.</em>
