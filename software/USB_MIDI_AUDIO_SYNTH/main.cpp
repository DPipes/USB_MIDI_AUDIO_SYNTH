
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

//Initial global values
alt_u16 att_h = 0;
alt_u16 dec_h = 0;
alt_u16 sus_h = 0;
alt_u16 rel_h = 0;
alt_u16 att_l = 10;
alt_u16 dec_l = 30;
alt_u16 sus_l = 3000;
alt_u16 rel_l = 80;
float peak_att = 1.1;
float peak_sus = 0.8;
bool ped_flip = 0;

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
  uint8_t channel, ctrl, par;
  uint8_t bufMidi[MIDI_EVENT_PACKET_SIZE];
  uint16_t  rcvd;
  uint32_t long_par;

  if (Midi.RecvData( &rcvd,  bufMidi) == 0 ) {
		channel = (bufMidi[1] & 0x0F);
		ctrl = bufMidi[2];
		par = bufMidi[3];
	switch (bufMidi[1] & 0xF0) {
		case NOTE_OFF:
		case NOTE_ON:
			set_note(channel, ctrl, par);
			break;
		case CONTROL_CHANGE:
			long_par = par;
			switch(ctrl) {
				case MOD_WHEEL:
					set_ctrl(channel, MOD, long_par);
					break;
				case CHAN_VOL:
					SGTL5000vol_change(i2c_dev, par);
					break;
				case SUSTAIN_PEDAL:
					if(ped_flip) long_par = ~long_par;
					set_ctrl(channel, SUS, long_par);
					break;
				case PEDAL_FLIP:
					ped_flip = par;
					break;
				case MOD_WHEEL_ON:
					set_ctrl(channel, MOD_ON, long_par);
					break;
				case SAMPLE_1_SEL:
					set_ctrl(channel, SAMPLE_1, long_par);
					break;
				case SAMPLE_2_SEL:
					set_ctrl(channel, SAMPLE_2, long_par);
					break;
				case BEND_ON_:
					set_ctrl(channel, BEND_ON, long_par);
					break;
				case ATT_TIME_H:
					att_h= (par * 5000) / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				case DEC_TIME_H:
					dec_h = (par * 5000) / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				case SUS_TIME_H:
					sus_h = (par * 20000) / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				case REL_TIME_H:
					rel_h = (par * 10000) / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				case ATT_TIME_L:
					att_l = (par * 200) / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				case DEC_TIME_L:
					dec_l = (par * 200) / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				case SUS_TIME_L:
					sus_l = (par * 800) / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				case REL_TIME_L:
					rel_l = (par * 400) / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				case PEAK_ATT:
					peak_att = (float) (par * 2) / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				case PEAK_SUS:
					peak_sus = (float) par / 0x7F;
					calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
					break;
				default:
					break;
			}
			break;
		case PITCH_BEND:
			long_par = (par << 7) + ctrl;
			set_ctrl(channel, BEND, long_par);
			break;
		default:
			break;
	}
  }
}

int main() {

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
	calc_adsr(att_h, att_l, dec_h, dec_l, sus_h, sus_l, rel_h, rel_l, peak_att, peak_sus);
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
	}
}
