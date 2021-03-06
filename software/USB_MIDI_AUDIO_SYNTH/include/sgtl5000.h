
#if !defined(__SGTL5000_H__)
#define __SGTL5000_H__

#include "altera_avalon_i2c.h"
#include "altera_avalon_i2c_regs.h"
#include "sys/alt_irq.h"

// SGTL5000 I2C Address
#define	SGTL5000_ADDR	0x0A

// SGTL5000 Register Addresses
#define	ID				0x0000
#define	DIG_POWER		0x0002
#define	CLK_CTRL		0x0004
#define	I2S_CTRL		0x0006
#define	SSS_CTRL		0x000A
#define	ADCDAC_CTRL		0x000E
#define	DAC_VOL			0x0010
#define	PAD_STRENGTH	0x0014
#define	ANA_ADC_CTRL	0x0020
#define	ANA_HP_CTRL		0x0022
#define	ANA_CTRL		0x0024
#define	LINREG_CTRL		0x0026
#define	REF_CTRL		0x0028
#define	MIC_CTRL		0x002A
#define	LINE_OUT_CTRL	0x002C
#define	LINE_OUT_VOL	0x002E
#define	ANA_POWER		0x0030
#define	PLL_CTRL		0x0032
#define	CLK_TOP_CTRL	0x0034
#define	ANA_STATUS		0x0036
#define	ANA_TEST1		0x0038
#define	ANA_TEST2		0x003A
#define	SHORT_CTRL		0x003C

// SGTL5000 Register Vals

// DIG_POWER
#define	ADC_POWERUP_DIG		0x0040	//N Enable the ADC block
#define DAC_POWERUP_DIG		0x0020	//S Enable the DAC block
#define	DAP_POWERUP		0x0010	//N Enable the DAP block
#define	I2S_OUT_POWERUP	0x0002	//N Enable the I2S data output
#define	I2S_IN_POWERUP	0x0001	//S Enable the I2S data input

// CLK_CTRL
// RATE_MODE and MCLK_FREQ are left at default 0
// RATE_MODE = SYS_FS specified
// MCLK_FREQ = 256*Fs
#define SYS_FS_441		0x0004	//S Set the internal sample rate to 44.1 kHz

// I2S_CTRL
// I2S_MODE left at default 0
// I2S_MODE = Standard I2S Mode
#define SCLKFREQ		0x0100	//N Set I2S_SCLK to 32*Fs
#define MS				0x0080	//N Set I2S_LRCLK and I2S_SCLK to outputs
#define SCLK_INV		0x0040	//N Set data valid on falling edge of I2S_SCLK
#define DLEN_16			0x0030	//S? Set I2S data length to 16 bits
#define DLEN_24			0x0010	//S? Set I2S data length to 24 bits
#define DLEN_32			0x0000
#define LRALIGN			0x0002	//N Set data word to start after I2S_LRCLK transition
#define LRPOL			0x0001	//N Set I2S_LRCLK polarity to 0-Right, 1-Left

// SSS_CTRL		Can swap channels and select inputs and outputs
#define DAC_SELECT_I2S_IN 0x0010 //L Set DAC data source to I2S_IN

// ADCDAC_CTRL
#define VOL_BUSY_DAC_RIGHT 0x2000	//RO Right DAC busy
#define VOL_BUSY_DAC_LEFT  0x1000	//RO Left DAC busy
#define	VOL_RAMP_EN		0x0200	//L? Enable volume ramp, Set soft mute
#define VOL_EXPO_RAMP	0x0100	//N? Set exponential volume ramp
#define DAC_MUTE_RIGHT	0x0008	//DP Mute right DAC
#define DAC_MUTE_LEFT	0x0004	//DP Mute left DAC

// DAC_VOL	0.5dB steps
#define DAC_VOL_INIT	0x3C 	//S Initial DAC volume setting
#define DAC_VOL_STEP	0x02	//	Step amount on volume button press
#define DAC_MAX_VOL		0x3C	//	Max volume for either channel
#define DAC_MIN_VOL		0xF0	//	Minimum volume for either channel
#define DAC_VOL_RANGE	0xB4	//	Total range of DAC volume control
// [15:8] Sets right volume
// [7:0] Sets left volume
// Max 0x3C	0dB
// Min 0xF0 -90dB
// Mute 0xFC or greater

// ANA_HP_CTRL 0.5dB steps
#define HP_VOL_INIT		0x18	//S	Initial volume setting, quite low
#define HP_VOL_STEP		0x02	//	Step amount on volume button press
#define HP_MAX_VOL		0x00	//	Max volume for either channel
#define HP_MIN_VOL		0x7F	//	Minimum volume for either channel
// [14:8] Sets right headphone volume
// [6:0] Sets left headphone volume
// Max 0x00	12dB
//     0x18 0dB
// Min 0x7F -51.5dB

// ANA_CTRL
#define MUTE_LO			0x0100	//L? Mute LINEOUT
#define SELECT_HP		0x0040	//N	Set headphone input to LINEIN
#define EN_ZCD_HP		0x0020	//N? Enable the headphone zero cross detector
#define MUTE_HP			0x0010	//DP Mute headphone output
#define SELECT_ADC		0x0004	//N? Set ADC input to LINEIN
#define EN_ZCD_ADC		0x0002	//N? Enable the ADC analog zero cross detector
#define MUTE_ADC		0x0001	//L? Mute ADC

// REF_CTRL
#define VAG_VAL_9		0x004E	//S	Set internal ground bias to 0.9V

// ANA_POWER
#define DAC_MONO		0x4000	//DP? Set DAC to stereo
#define LINREG_SIMPLE_POWERUP 0x2000 //DP Power up the digital supply regulator
#define STARTUP_POWERUP	0x1000	//DP Power up the power up circuitry
#define VDDC_CHRGPMP_POWERUP 0x0800 //N Power up the VDDC charge pump block
#define PLL_POWERUP		0x0400	//N Power up the PLL
#define LINREG_D_POWERUP 0x0200	//N Power up the VDDD linear regulator
#define VCOAMP_POWERUP	0x0100	//N Power up the PLL VCO amplifier
#define VAG_POWERUP		0x0080	//N Power up the VAG reference buffer
#define ADC_MONO		0x0040	//DP? Set ADC to stereo
#define REFTOP_POWERUP	0x0020	//L	Power up the reference bias currents
#define HEADPHONE_POWERUP 0x0010 //S Power up the headphone amplifiers
#define DAC_POWERUP_ANA		0x0008	//S Power up the DAC
#define CAPLESS_HEADPHONE_POWERUP 0x0004 //N? Power up the capless headphone mode
#define ADC_POWERUP_ANA		0x0002	//N Power up the ADC
#define LINEOUT_POWERUP	0x0001	//N Power up the LINEOUT amplifiers

// ANA_STATUS
#define LRSHORT_STS		0x0200	//RO Short detected on left or right headphone driver
#define CSHORT_STS		0x0100	//RO Short detected on capless headphone center channel driver
#define PLL_IS_LOCKED	0x0010	//RO PLL is locked

// ANA_TEST1
#define	TM_SELECT_MIC	0x0002	//T	Enable the mic-adc-dac-HP path
#define TESTMODE		0x0001	//T ENable the analog test mode paths

// ANA_TEST2
#define MONOMODE_DAC	0x1000	//T Copy the left channel DAC to the right channel

void I2Creg_wr(ALT_AVALON_I2C_DEV_t*, alt_u8, alt_u16);

alt_u16* I2Cbytes_wr(ALT_AVALON_I2C_DEV_t*, alt_u8, alt_u8, alt_u16*);

alt_u16 I2Creg_rd(ALT_AVALON_I2C_DEV_t*, alt_u8);

alt_u16* I2Cbytes_rd(ALT_AVALON_I2C_DEV_t*, alt_u8, alt_u8, alt_u16*);

void SGTL5000init(ALT_AVALON_I2C_DEV_t*);

void SGTL5000audio_on(ALT_AVALON_I2C_DEV_t*);

void SGTL5000status(ALT_AVALON_I2C_DEV_t*);

void SGTL5000vol_change(ALT_AVALON_I2C_DEV_t*, alt_u8 vol);

#endif
