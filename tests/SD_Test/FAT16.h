/*
 * @ModuleName FAT16
 * @Author Ali Dixon
 * @Date 07/06/2008
 * @Version 1.0
 * @Description: FAT16 file system
 *
 * Copyright XMOS Ltd 2008
*/

#ifndef __FAT16_H__
#define __FAT16_H__

#include <xs1.h>
#include "sw_comps_common.h"
#include "FAT16_def.h"
#include "SD_phy.h"

extern uint dataStartSector;
extern uint sectorsPerCluster;
extern uint rootDirStartSector;
extern uint currentDirSectorAddr;

XMOS_RTN_t FAT_initialise(SDDataBlock_t dataBlock[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);
XMOS_RTN_t FAT_readPartitionTable(SDDataBlock_t dataBlock[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);
uint FAT_readFATPartition(SDDataBlock_t dataBlock[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);
uint FAT_directoryList(SDDataBlock_t dataBlock[], DIR_t dir[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);
uint FAT_find(SDDataBlock_t dataBlock[], FP_t fp[], char name[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);
uint FAT_validateFileName(char filename[], char shortfilename[], char ext[]);

uint FAT_readDirTableEntry(SDDataBlock_t dataBlock[], char fileName[], DIR_t dir[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);

uint FAT_getClusterAddress(uint clusterNum);
uint FAT_getNextCluster(SDDataBlock_t dataBlock[], uint clusterNum, port p_sd_cmd, port p_sd_clk, port p_sd_dat);
uint FAT_setNextCluster(SDDataBlock_t dataBlock[], uint clusterNum, uint nextClusterNum, port p_sd_cmd, port p_sd_clk, port p_sd_dat);
uint FAT_getFreeCluster(SDDataBlock_t dataBlock[], uint prevCluster, port p_sd_cmd, port p_sd_clk, port p_sd_dat);

XMOS_RTN_t FAT_fopen(SDDataBlock_t dataBlock[], FP_t fp[], char filename[], char mode, port p_sd_cmd, port p_sd_clk, port p_sd_dat);
XMOS_RTN_t FAT_fclose(SDDataBlock_t dataBlock[], FP_t fp[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);
XMOS_RTN_t FAT_fdelete(SDDataBlock_t dataBlock[], FP_t fp[], char filename[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);
uint FAT_fread(SDDataBlock_t dataBlock[], FP_t fp[], char buffer[], uint size, uint count, port p_sd_cmd, port p_sd_clk, port p_sd_dat);
uint FAT_fwrite(SDDataBlock_t dataBlock[], FP_t fp[], char buf[], uint size, uint count, port p_sd_cmd, port p_sd_clk, port p_sd_dat);

XMOS_RTN_t CheckFileNameRules(char filename[]);


#endif // __FAT16_H__

