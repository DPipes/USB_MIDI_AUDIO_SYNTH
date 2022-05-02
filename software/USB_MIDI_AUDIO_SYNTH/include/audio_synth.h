
#if !defined(__AUDIO_SYNTH_H__)
#define __AUDIO_SYNTH_H__

#define NOTES 128
#define AUDIO_BASE	0x4001400
#define PEAK_A		0x00
#define ATT_L		0x01
#define ATT_S		0x02
#define DEC_L		0x03
#define DEC_S		0x04
#define REL_L		0x05
#define REL_S		0x06
#define F_S			44100

#include "system.h"
#include "alt_types.h"

struct AUDIO_SYNTH_STRUCT {
	alt_u32 NOTE [NOTES];
};

struct ADSR_STRUCT {
	alt_u32 VAL [8];
};

static volatile struct AUDIO_SYNTH_STRUCT* keys = (AUDIO_SYNTH_STRUCT *) AUDIO_BASE;
static volatile struct ADSR_STRUCT* adsr = (ADSR_STRUCT *) AUDIO_BASE + 0x80;

void set_note(alt_u8 note, alt_u8 vel);
void set_adsr(alt_u8 par, alt_u32 val);
void calc_adsr(alt_u16 att_m_seconds, alt_u16 dec_m_seconds, alt_u16 rel_m_seconds, float peak_amp);

#endif
