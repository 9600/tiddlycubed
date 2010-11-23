/*
 * @ModuleName FAT16_def
 * @Author Ali Dixon
 * @Date 07/06/2008
 * @Version 1.0
 * @Description: Server side functions for FAT16 file system
 *
 * Copyright XMOS Ltd 2008
*/

#ifndef __FAT16_DEF_H__
#define __FAT16_DEF_H__

#include <xs1.h>
#include "sw_comps_common.h"

typedef enum FAT16_CMD
{
  FAT16_CMD_error = 0,
  FAT16_CMD_initialise,
  FAT16_CMD_fopen,
  FAT16_CMD_fclose,
  FAT16_CMD_fread,
  FAT16_CMD_fwrite,
  FAT16_CMD_readdir,
  FAT16_CMD_opendir,
  FAT16_CMD_closedir,
  FAT16_CMD_rm,
  FAT16_CMD_finish

  // for testing only
  ,
  FAT16_CMD_ls

} FAT16_CMD_t;

// file pointer structure
typedef struct FP
{
  uint startAddr;
  uint currentClusterNum;
  uint currentSectorNum;
  uint currentBytePos;
  uint attributes;
  uint size;

  // dir info
  uint dirEntry_blockNum;
  uint dirEntry_entryAddr;
} FP_t;

#define DIR_NAME_SIZE 50

// directory entry
typedef struct DIR
{
  uint attributes;

  uint entryAddr;  // offset of entry in FAT
  uint entryNum;   // number of entry in FAT
  char name[DIR_NAME_SIZE];   // string
}DIR_t;

// Channel protocol definitions
#define CHAN_ACK 1

#endif // __FAT16_DEF_H__

