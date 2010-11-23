/*
 * @ModuleName FAT16_client
 * @Author Ali Dixon
 * @Date 07/06/2008
 * @Version 1.0
 * @Description: Channel interface to FAT16 file system
 *
 * Copyright XMOS Ltd 2008
*/

#ifndef __FAT16_CLIENT_H__
#define __FAT16_CLIENT_H__

#include <xs1.h>
#include "sw_comps_common.h"
#include "FAT16.h"

XMOS_RTN_t FAT16_Clnt_initialise(chanend server);
XMOS_RTN_t FAT16_Clnt_finish(chanend server);

XMOS_RTN_t FAT16_Clnt_fopen(chanend server, FP_t fp[], char filename[], char mode);
XMOS_RTN_t FAT16_Clnt_fclose(chanend server, FP_t fp[]);
uint FAT16_Clnt_fread(chanend server, FP_t fp[], char buffer[], uint size, uint count);
uint FAT16_Clnt_fwrite(chanend server, FP_t fp[], char buffer[], uint size, uint count);
XMOS_RTN_t FAT16_Clnt_rm(chanend server, FP_t fp[], char filename[]);
uint FAT16_Clnt_readdir(chanend server, DIR_t dir[]);
XMOS_RTN_t FAT16_Clnt_opendir(chanend server, char name[], DIR_t dir[]);
XMOS_RTN_t FAT16_Clnt_closedir(chanend server, DIR_t dir[]);
XMOS_RTN_t FAT16_Clnt_rm(chanend server, FP_t fp[], char filename[]);

// Unsupported functions - to be removed
XMOS_RTN_t FAT16_Clnt_ls(chanend server);

#endif // __FAT16_CLIENT_H__

