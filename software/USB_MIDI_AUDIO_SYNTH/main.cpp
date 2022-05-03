
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

USB Usb;
USBH_MIDI  Midi(&Usb);

//pointer to instance structure
ALT_AVALON_I2C_DEV_t *i2c_dev;

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

// Poll USB MIDI Controller and send to synthesizer
void MIDI_poll()
{
  uint8_t note, vel;
  uint8_t bufMidi[MIDI_EVENT_PACKET_SIZE];
  uint16_t  rcvd;

  if (Midi.RecvData( &rcvd,  bufMidi) == 0 ) {
    for (int i = 0; i < MIDI_EVENT_PACKET_SIZE; i++) {
    	switch (bufMidi[i] & MIDI_MASK) {
			case NOTE_OFF:
				note = bufMidi[i+1];
				i += 2;
				set_note(note, 0x00);
				printf("Note Off\n");
				break;
			case NOTE_ON:
				note = bufMidi[i+1];
				vel = bufMidi[i+2];
				i += 2;
				set_note(note, vel);
				printf("Note On\n");
				break;
			case CONTROL_CHANGE:
				//PEDAL CONTROLS HERE
				printf("Control Change\n");
				break;
			case PITCH_BEND:
				//PITCH WHEEL CONTROLS HERE
				printf("Pitch Bend\n");
				break;
			default:
				break;
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

	//Initial ADSR values
	alt_u16 att_m_seconds = 500;
	alt_u16 dec_m_seconds = 500;
	alt_u16 rel_m_seconds = 500;
	float peak_amp = 1.8;

	printf("Initializing SGTL5000...\n");

	//get a pointer to the avalon i2c instance
	i2c_dev = alt_avalon_i2c_open("/dev/i2c_0");
	if (NULL==i2c_dev) printf("Error: Cannot find /dev/i2c_0\n");

	//set up registers
	SGTL5000init(i2c_dev);

	printf("Starting audio...\n");
	SGTL5000audio_on(i2c_dev);
	SGTL5000status(i2c_dev);
	printf("Audio running\n");

	printf("Initializing ADSR...\n");
	calc_adsr(att_m_seconds, dec_m_seconds, rel_m_seconds, peak_amp);
	printf("ADSR set\n");

	MIDI_setup();
	printf("MIDI set\n");

	while (Usb.getUsbTaskState() != USB_STATE_RUNNING) {
		Usb.Task();
	}
	printf("USB running\n");

	while(1) {
		if ( Midi ) {
			MIDI_poll();
		}
		timer ++;
		if (timer & 0x40) {
			control();
			timer = 0;
		}
	}
}
