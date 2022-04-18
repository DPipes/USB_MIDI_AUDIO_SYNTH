
#define _SGTL5000_C_

#include "system.h"
#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "SGTL5000.h"
#include "altera_avalon_i2c.h"
#include "altera_avalon_i2c_regs.h"
#include <sys/alt_stdio.h>
#include <unistd.h>

// Writes to I2C register
// The SGTL5000 only uses first byte to define register addresses
// so function only takes 1 byte of register data
void I2Creg_wr(ALT_AVALON_I2C_DEV_t *dev, alt_u8 reg, alt_u16 val) {
	alt_u8 val1, val2;
	val1 = val >> 8;
	val2 = val;
	alt_u8 txbuffer[4] = {0x00, reg, val1, val2};
	if(alt_avalon_i2c_master_tx(dev, txbuffer, 4, ALT_AVALON_I2C_NO_INTERRUPTS) != ALT_AVALON_I2C_SUCCESS){
		printf("I2C Register Write Error");
	}
	return;
}

alt_u16* I2Cbytes_wr(ALT_AVALON_I2C_DEV_t* dev, alt_u8 reg, alt_u8 nwords, alt_u16* data) {
	alt_u8 txbuffer[2*nwords+2];
	txbuffer[0] = 0;
	txbuffer[1] = reg;
	int i = 0;
	for (i = 0;i < nwords;i++) {
		txbuffer[i+2] = data[i] >> 8;
		txbuffer[i+3] = data[i];
	}
	if(alt_avalon_i2c_master_tx(dev, txbuffer, 2*nwords+2, ALT_AVALON_I2C_NO_INTERRUPTS) != ALT_AVALON_I2C_SUCCESS){
		printf("I2C Bytes Write Error");
	}
	return (data+nwords);
}

alt_u16 I2Creg_rd(ALT_AVALON_I2C_DEV_t* dev, alt_u8 reg) {
	alt_u8 txbuffer[2] = {0x00, reg};
	alt_u8 rxbuffer[2] = {0x00, 0x00};
	alt_u16 rx;
	if(alt_avalon_i2c_master_tx_rx(dev, txbuffer, 2, rxbuffer, 2, ALT_AVALON_I2C_NO_INTERRUPTS) != ALT_AVALON_I2C_SUCCESS){
		printf("I2C Register Read Error");
	}
	rx = rxbuffer[0] << 8 | rxbuffer[1];
	return rx;
}

alt_u16* I2Cbytes_rd(ALT_AVALON_I2C_DEV_t* dev, alt_u8 reg, alt_u8 nwords, alt_u16* data) {
	alt_u8 txbuffer[2] = {0x00, reg};
	alt_u8 rxbuffer[nwords*2];
	int i = 0;
	if(alt_avalon_i2c_master_tx_rx(dev, txbuffer, 2, rxbuffer, 2*nwords, ALT_AVALON_I2C_NO_INTERRUPTS) != ALT_AVALON_I2C_SUCCESS) {
		printf("I2C Bytes Read Error");
	}
	for(i = 0; i < nwords; i++) {
		data[i] = rxbuffer[2*i] << 8 | rxbuffer[2*i + 1];
	}
	return (data+nwords);
}

void SGTL5000init(ALT_AVALON_I2C_DEV_t* dev) {

	//Sets address of SGTL5000 which is 0x0A
	alt_avalon_i2c_master_target_set(dev, SGTL5000_ADDR);

	//Writes parameters to registers

	I2Creg_wr(dev, ANA_POWER, DAC_MONO | LINREG_SIMPLE_POWERUP | STARTUP_POWERUP | VDDC_CHRGPMP_POWERUP | LINREG_D_POWERUP | VAG_POWERUP | ADC_MONO | REFTOP_POWERUP | HEADPHONE_POWERUP | DAC_POWERUP_ANA | CAPLESS_HEADPHONE_POWERUP);

	//Maybe needed?
	I2Creg_wr(dev, REF_CTRL, 0x004E);
	I2Creg_wr(dev, LINE_OUT_CTRL, 0x0322);

	I2Creg_wr(dev, DIG_POWER, DAC_POWERUP_DIG | I2S_IN_POWERUP);
	I2Creg_wr(dev, CLK_CTRL, SYS_FS_441);
	I2Creg_wr(dev, I2S_CTRL, DLEN_24);
	I2Creg_wr(dev, SSS_CTRL, DAC_SELECT_I2S_IN);

}

void SGTL5000audio_on(ALT_AVALON_I2C_DEV_t* dev) {

	//Unmute audio
	I2Creg_wr(dev, ANA_HP_CTRL, HP_VOL_INIT);
	I2Creg_wr(dev, DAC_VOL, DAC_VOL_INIT);
	I2Creg_wr(dev, ADCDAC_CTRL, VOL_RAMP_EN | !DAC_MUTE_RIGHT | !DAC_MUTE_LEFT);
	I2Creg_wr(dev, ANA_CTRL, MUTE_LO | !MUTE_HP | MUTE_ADC);

}
