
#if !defined(__AUDIO_SYNTH_H__)
#define __AUDIO_SYNTH_H__

#define AUDIO_BASE	0x4001400
#define NOTES 		128
#define CTRL		7
#define PEAK_A		0
#define ATT_L		1
#define ATT_S		2
#define DEC_L		3
#define DEC_S		4
#define REL_L		5
#define REL_S		6
#define SUS			7
#define F_S			44100

#include "system.h"
#include "alt_types.h"

struct AUDIO_SYNTH_STRUCT {
	alt_u32 KEY [NOTES];
	alt_u32 ADSR [CTRL];
};

static volatile struct AUDIO_SYNTH_STRUCT* synth = (AUDIO_SYNTH_STRUCT *) AUDIO_BASE;

void set_note(alt_u8 note, alt_u8 vel);
void set_adsr(alt_u8 par, alt_u32 val);
void calc_adsr(alt_u16 att_m_seconds, alt_u16 dec_m_seconds, alt_u16 rel_m_seconds, float peak_amp);

#endif
