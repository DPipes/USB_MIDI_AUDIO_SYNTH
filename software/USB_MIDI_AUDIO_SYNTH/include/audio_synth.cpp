#include "system.h"
#include <stdio.h>
#include "audio_synth.h"

void set_note(alt_u8 note, alt_u8 vel) {
	alt_u32 set_val;

	if(vel == 0) {
		set_val = keys->NOTE[note];
	}
	else {
		set_val = 0x80 + vel;
	}

	keys->NOTE[note] = set_val;
}

void set_adsr(alt_u8 par, alt_u32 val) {
	adsr->VAL[par] = val;
}

void calc_adsr(alt_u16 att_m_seconds, alt_u16 dec_m_seconds, alt_u16 rel_m_seconds, float peak_amp) {

	alt_u32 ATT_LEN, ATT_STEP, PEAK_ATT, DEC_LEN, DEC_STEP, REL_LEN, REL_STEP;

	if (att_m_seconds > 5000) {
		printf("ERRROR: Requested attack length is too long.\n");
		return;
	}
	if (dec_m_seconds > 5000) {
		printf("ERRROR: Requested decay length is too long.\n");
		return;
	}
	if (rel_m_seconds > 10000) {
		printf("ERRROR: Requested release length is too long.\n");
		return;
	}
	if (peak_amp > (float) 1.9) {
		printf("ERROR: Requested peak attack amplitude is too large.\n");
		return;
	}

	ATT_LEN = (att_m_seconds * F_S) / 1000;
	ATT_STEP = (peak_amp * (alt_u32) 0x80000) / ATT_LEN;
	PEAK_ATT = ATT_LEN * ATT_STEP;
	DEC_LEN = (dec_m_seconds * F_S) / 1000;
	DEC_STEP = ((peak_amp - 1) * (alt_u32) 0x80000) / DEC_LEN;
	REL_LEN = (rel_m_seconds * 44100) / 1000;
	REL_STEP = ((alt_u32) 0x80000) / REL_LEN;

	printf("ATT_LEN:  %X\n", ATT_LEN);
	printf("ATT_STEP: %X\n", ATT_STEP);
	printf("PEAK_ATT: %X\n", PEAK_ATT);
	printf("DEC_LEN:  %X\n", DEC_LEN);
	printf("DEC_STEP: %X\n", DEC_STEP);
	printf("REL_LEN:  %X\n", REL_LEN);
	printf("REL_STEP: %X\n", REL_STEP);

	set_adsr(ATT_L, ATT_LEN);
	set_adsr(ATT_S, ATT_STEP);
	set_adsr(PEAK_A, PEAK_ATT);
	set_adsr(DEC_L, DEC_LEN);
	set_adsr(DEC_S, DEC_STEP);
	set_adsr(REL_L, REL_LEN);
	set_adsr(REL_S, REL_STEP);

	return;
}
