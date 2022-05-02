
#include <stdio.h>
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_i2c.h"
#include "altera_avalon_i2c_regs.h"
#include "sys/alt_irq.h"
#include "include/hidboot.h"
#include "include/usbhub.h"
#include "include/sgtl5000.h"
#include "include/usbh_midi.h"
#include "include/audio_synth.h"

// Satisfy the IDE, which needs to see the include statement in the ino too.
#ifdef dobogusinclude
#include <spi4teensy3.h>
#endif
#include "include/SPI.h"

/*
 *******************************************************************************
 * USB-MIDI dump utility
 * Copyright (C) 2013-2021 Yuuichi Akagawa
 *
 * for use with USB Host Shield 2.0 from Circuitsathome.com
 * https://github.com/felis/USB_Host_Shield_2.0
 *
 * This is sample program. Do not expect perfect behavior.
 *******************************************************************************
 */


USB Usb;
//USBHub Hub(&Usb);
USBH_MIDI  Midi(&Usb);

ALT_AVALON_I2C_DEV_t *i2c_dev; //pointer to instance structure

void MIDI_poll();

void onInit()
{
  char buf[20];
  uint16_t vid = Midi.idVendor();
  uint16_t pid = Midi.idProduct();
  sprintf(buf, "VID:%04X, PID:%04X", vid, pid);
  printf("%s\n", buf);
}

void MIDI_setup()
{
	if (Usb.Init() == -1)
		printf ("Error\n\r");
	printf ("USB Started\n\r");

	// Register onInit() function
	Midi.attachOnInit(onInit);
}

// Poll USB MIDI Controller and send to serial MIDI
void MIDI_poll()
{
  uint8_t note, vel;
  uint8_t bufMidi[MIDI_EVENT_PACKET_SIZE];
  uint16_t  rcvd;

  if (Midi.RecvData( &rcvd,  bufMidi) == 0 ) {
    for (int i = 0; i < MIDI_EVENT_PACKET_SIZE; i++) {\
    	if (bufMidi[i] == 0x90) {
    		note = bufMidi[i+1];
    		vel = bufMidi[i+2];
    		i += 2;

    		set_note(note, vel);

        	if(vel == 0) {
        		printf("Note Off:	%d\n", note);
        	}
        	else {
        		printf("Note On:	%d\n", note);
        	}

    	}
    }
  }
}

void control() {
	uint8_t con;
	con = IORD_ALTERA_AVALON_PIO_DATA(KEY_BASE);
	if ((~con & 0x1) && (~con & 0x2)) {
	}
	else if (~con & 0x1) SGTL5000vol_up(i2c_dev);
	else if (~con & 0x2) SGTL5000vol_down(i2c_dev);
}

int main() {

	uint8_t timer;
	alt_u16 att_m_seconds = 250;
	alt_u16 dec_m_seconds = 100;
	alt_u16 rel_m_seconds = 300;
	float peak_amp = 1.3;

	printf("Initializing SGTL5000...\n");

	//get a pointer to the avalon i2c instance
	i2c_dev = alt_avalon_i2c_open("/dev/i2c_0");
	if (NULL==i2c_dev) printf("Error: Cannot find /dev/i2c_0\n");

	//set up registers
	SGTL5000init(i2c_dev);

	printf("Starting audio...\n");
	SGTL5000audio_on(i2c_dev);
	//AUDIO TEST PATH MIC-ADC-DAC-HEADPHONE
	/*
	I2Creg_wr(i2c_dev, DIG_POWER, DAC_POWERUP_DIG | ADC_POWERUP_DIG);
	I2Creg_wr(i2c_dev, SSS_CTRL, 0x0001);
	I2Creg_wr(i2c_dev, ANA_CTRL, MUTE_LO | !MUTE_HP | !MUTE_ADC);
	I2Creg_wr(i2c_dev, ANA_TEST1, TM_SELECT_MIC | TESTMODE);
	I2Creg_wr(i2c_dev, ANA_POWER, DAC_MONO | LINREG_SIMPLE_POWERUP | STARTUP_POWERUP | VDDC_CHRGPMP_POWERUP | LINREG_D_POWERUP | ADC_MONO | REFTOP_POWERUP | HEADPHONE_POWERUP | VAG_POWERUP | DAC_POWERUP_ANA | CAPLESS_HEADPHONE_POWERUP | ADC_POWERUP_ANA);
	I2Creg_wr(i2c_dev, ADCDAC_CTRL, VOL_RAMP_EN | !DAC_MUTE_RIGHT | !DAC_MUTE_LEFT);
	*/

	SGTL5000status(i2c_dev);

	printf("Audio running\n");

	printf("Initializing ADSR...\n");

	calc_adsr(att_m_seconds, dec_m_seconds, rel_m_seconds, peak_amp);

	printf("ADSR set\n");

	MIDI_setup();

	printf("MIDI set\n");

	while (Usb.getUsbTaskState() != USB_STATE_RUNNING) {
		Usb.Task();
        printf("%X\n", Usb.getUsbTaskState());
	}

	printf("USB running\n");

	while(1) {
		if ( Midi ) {
			MIDI_poll();
		}
		//timer ++;
		//if (timer & 0x70) {
		//	control();
		//	timer = 0;
		//}
	}

	printf("Ended");
}
