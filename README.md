# USB_MIDI_AUDIO_SYNTH

This is a final code as demoed for an FPGA design project for ECE 385 in the spring of 2022 at the University of Illinois - Urbana Champaign.

The design is a digital audio synthesiser that takes input via USB-MIDI. It is running on a MAX10 FPGA, handling USB input with a MAX3451 over SPI, and outputting audio with a SGTL5000 over I2S.

The audio synthesizer can handle all 128 MIDI notes simultaneously and is done via wavetable synthesis. It has control over attack, decay, sustain, and release times; attack and sustain amplitudes; and other MIDI controls such as pitch bend, mod wheel, sustain pedal, etc.
