/*
 * SPI controller for SD
*/

#ifndef __SD_LINK_H__
#define __SD_LINK_H__

#include <xs1.h>
#include "sw_comps_common.h"
#include "SD_phy.h"

XMOS_RTN_t SD_link_initialise( port p_sd_cmd, port p_sd_clk, port p_sd_dat, port p_sd_rsv);
void SD_getStatus();
XMOS_RTN_t SD_link_checkCardStatus(r1Response_t r, uint &currentState);
XMOS_RTN_t SD_readSingleBlock(uint blockNumber, SDDataBlock_t block[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);
XMOS_RTN_t SD_writeSingleBlock(uint blockNumber, SDDataBlock_t block[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);
void SD_link_check(port p_sd_cmd, port p_sd_clk, port p_sd_dat);
uint SD_blockCrc16(SDDataBlock_t dataBlock[]);

#endif // __SD_LINK_H__

