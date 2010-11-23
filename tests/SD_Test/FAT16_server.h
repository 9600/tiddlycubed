/*
 * @ModuleName FAT16_server
 * @Author Ali Dixon
 * @Date 07/06/2008
 * @Version 1.0
 * @Description: Server side functions for FAT16 file system
 *
 * Copyright XMOS Ltd 2008
*/

#ifndef __FAT16_SERVER_H__
#define __FAT16_SERVER_H__

#include <xs1.h>
#include "sw_comps_common.h"
#include "FAT16.h"

void FAT16_server(chanend client1, port p_sd_cmd, port p_sd_clk, port p_sd_dat, port p_sd_rsv);

#endif // __FAT16_SERVER_H__

