#include "system.h"
#include <stdio.h>
#include "audio_synth.h"

void set_note(alt_u8 channel, alt_u8 note, alt_u8 vel) {
	alt_u32 set_val;

	if(note > 0x7F) {
		return;
	}

	switch (channel) {
		case 0:
			if(vel == 0x00) {
				set_val = synth->KEY[note];
			}
			else {
				set_val = 0x80 + vel;
			}
			synth->KEY[note] = set_val;
			break;
		default:
			break;
	}
}

void set_ctrl(alt_u8 channel, alt_u8 par, alt_u32 val) {
	switch (channel) {
		case 0:
			synth->CTRL[par] = val;
			break;
		default:
			break;
	}
}

void calc_adsr(alt_u16 att_h, alt_u16 att_l, alt_u16 dec_h, alt_u16 dec_l, alt_u16 sus_h, alt_u16 sus_l, alt_u16 rel_h, alt_u16 rel_l, float peak_att, float peak_sus) {

	alt_u16 att_m_seconds = att_h + att_l;
	alt_u16 dec_m_seconds = dec_h + dec_l;
	alt_u16 sus_m_seconds = sus_h + sus_l;
	alt_u16 rel_m_seconds = rel_h + rel_l;
	alt_u32 PEAK_ATT, PEAK_SUS, ATT_STEP, DEC_STEP, SUS_STEP, REL_STEP;
	alt_u32 ATT_LEN, DEC_LEN, SUS_LEN, REL_LEN;

	float p_att = peak_att + peak_sus;

	if (p_att > 2) p_att = 2;

	if (att_m_seconds > 5000) {
		//printf("ERROR: Requested attack length is too long.\n");
		return;
	}
	if (dec_m_seconds > 5000) {
		//printf("ERROR: Requested decay length is too long.\n");
		return;
	}
	if (sus_m_seconds > 20000) {
		//printf("ERROR: Requested sustain length is too long.\n");
		return;
	}
	if (sus_m_seconds < rel_m_seconds) {
		//printf("ERROR: Requested sustain length must be longer than release length.\n");
		return;
	}
	if (rel_m_seconds > 10000) {
		//printf("ERROR: Requested release length is too long.\n");
		return;
	}

	PEAK_ATT = p_att * (alt_u32) 0x80000;
	if(peak_att + peak_sus >= 2) PEAK_ATT = 0xFFFFF;
	PEAK_SUS = peak_sus * (alt_u32) 0x80000;
	ATT_LEN = (att_m_seconds * F_S) / 1000;
	if(!ATT_LEN) ATT_LEN = 1;
	ATT_STEP = PEAK_ATT / ATT_LEN;
	DEC_LEN = (dec_m_seconds * F_S) / 1000;
	if(!DEC_LEN) DEC_LEN = 1;
	DEC_STEP = (PEAK_ATT - PEAK_SUS) / DEC_LEN;
	SUS_LEN = (sus_m_seconds * F_S) / 1000;
	if(!SUS_LEN) SUS_LEN = 1;
	SUS_STEP = PEAK_SUS / SUS_LEN;
	REL_LEN = (rel_m_seconds * F_S) / 1000;
	if(!REL_LEN) REL_LEN = 1;
	REL_STEP = PEAK_SUS / REL_LEN;

	set_ctrl(0, PEAK_A, PEAK_ATT);
	set_ctrl(0, ATT_S, ATT_STEP);
	set_ctrl(0, DEC_S, DEC_STEP);
	set_ctrl(0, PEAK_S, PEAK_SUS);
	set_ctrl(0, SUS_S, SUS_STEP);
	set_ctrl(0, REL_S, REL_STEP);
	return;
}
