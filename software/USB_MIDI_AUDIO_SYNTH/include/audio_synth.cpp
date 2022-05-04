#include "system.h"
#include <stdio.h>
#include "audio_synth.h"

void set_note(alt_u8 note, alt_u8 vel) {
	alt_u32 set_val;

	if(vel == 0x00) {
		set_val = synth->KEY[note];
	}
	else {
		set_val = 0x80 + vel;
	}

	synth->KEY[note] = set_val;
}

void set_adsr(alt_u8 par, alt_u32 val) {
	synth->ADSR[par] = val;
}

void calc_adsr(alt_u16 att_m_seconds, alt_u16 dec_m_seconds, alt_u16 sus_m_seconds, alt_u16 rel_m_seconds, float peak_att, float peak_sus) {

	alt_u32 PEAK_ATT, PEAK_SUS, ATT_STEP, DEC_STEP, SUS_STEP, REL_STEP;
	alt_u32 ATT_LEN, DEC_LEN, SUS_LEN, REL_LEN;

	if (att_m_seconds > 5000) {
		printf("ERROR: Requested attack length is too long.\n");
		return;
	}
	if (dec_m_seconds > 5000) {
		printf("ERROR: Requested decay length is too long.\n");
		return;
	}
	if (sus_m_seconds > 20000) {
		printf("ERROR: Requested sustain length is too long.\n");
		return;
	}
	if (sus_m_seconds < rel_m_seconds) {
		printf("ERROR: Requested sustain length must be longer than release length.\n");
		return;
	}
	if (rel_m_seconds > 10000) {
		printf("ERROR: Requested release length is too long.\n");
		return;
	}
	if (peak_att > (float) 1.9) {
		printf("ERROR: Requested peak attack amplitude is too large.\n");
		return;
	}
	if (peak_sus >= peak_att) {
		printf("ERROR: Requested sustain amplitude is too large.\n");
		return;
	}

	PEAK_ATT = peak_att * (alt_u32) 0x80000;
	PEAK_SUS = peak_sus * (alt_u32) 0x80000;
	ATT_LEN = (att_m_seconds * F_S) / 1000;
	ATT_STEP = PEAK_ATT / ATT_LEN;
	DEC_LEN = (dec_m_seconds * F_S) / 1000;
	DEC_STEP = (PEAK_ATT - PEAK_SUS) / DEC_LEN;
	SUS_LEN = (sus_m_seconds * F_S) / 1000;
	SUS_STEP = PEAK_SUS / SUS_LEN;
	REL_LEN = (rel_m_seconds * F_S) / 1000;
	REL_STEP = PEAK_SUS / REL_LEN;

	set_adsr(PEAK_A, PEAK_ATT);
	printf("PEAK_ATT Set:  %X\n", synth->ADSR[PEAK_A]);
	set_adsr(ATT_S, ATT_STEP);
	printf("ATT_STEP Set:  %X\n", synth->ADSR[ATT_S]);
	set_adsr(DEC_S, DEC_STEP);
	printf("DEC_STEP Set:  %X\n", synth->ADSR[DEC_S]);
	set_adsr(PEAK_S, PEAK_SUS);
	printf("PEAK_S Set:  %X\n", synth->ADSR[PEAK_S]);
	set_adsr(SUS_S, SUS_STEP);
	printf("SUS_STEP Set:  %X\n", synth->ADSR[SUS_S]);
	set_adsr(REL_S, REL_STEP);
	printf("REL_STEP Set:  %X\n", synth->ADSR[REL_S]);

	return;
}
