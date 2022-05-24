
#if !defined(__AUDIO_SYNTH_H__)
#define __AUDIO_SYNTH_H__


#define NOTES 		128
#define CTRL_REGS	7
#define PEAK_A		0
#define ATT_S		1
#define DEC_S		2
#define PEAK_S		3
#define SUS_S		4
#define REL_S		5
#define SUS			6
#define MIX			7
#define SAMPLE_1	8
#define SAMPLE_2	9
#define BEND		10
#define	PED_INV		11
#define F_S			44100

#include "system.h"
#include "alt_types.h"

struct AUDIO_SYNTH_STRUCT {
	alt_u32 KEY [NOTES];
	alt_u32 CTRL [CTRL_REGS];
};

static volatile struct AUDIO_SYNTH_STRUCT* synth = (AUDIO_SYNTH_STRUCT *) WAVETABLE_AUDIO_SYNTHESIZER_0_BASE;

void set_note(alt_u8 channel, alt_u8 note, alt_u8 vel);
void set_ctrl(alt_u8 channel, alt_u8 par, alt_u32 val);
void calc_adsr(alt_u16 att_h, alt_u16 att_l, alt_u16 dec_h, alt_u16 dec_l, alt_u16 sus_h, alt_u16 sus_l, alt_u16 rel_h, alt_u16 rel_l, float peak_att, float peak_sus);
void init_ctrl(alt_u16 att_h, alt_u16 att_l, alt_u16 dec_h, alt_u16 dec_l, alt_u16 sus_h, alt_u16 sus_l, alt_u16 rel_h, alt_u16 rel_l, float peak_att, float peak_sus);

#endif
