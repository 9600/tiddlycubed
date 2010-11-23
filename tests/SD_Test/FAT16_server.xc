/*
 * @ModuleName FAT16_server
 * @Author Ali Dixon
 * @Date 07/06/2008
 * @Version 1.0
 * @Description: Server side functions for SD_FAT16
 *
 * Copyright XMOS Ltd 2008
*/

#include <xs1.h>
#include "FAT16_server.h"
#include "SD_link.h"
#include "SD_phy.h"
#include "FAT16_def.h"
#include "FAT16.h"


void FAT16_server(chanend client1, port p_sd_cmd, port p_sd_clk, port p_sd_dat, port p_sd_rsv)
{
  SDDataBlock_t dataBlock[1];
  XMOS_RTN_t returnCode;
  char buffer[500];

  FAT16_CMD_t cmd;
  uint argc;
  char tmp;
  uint i;
  uint j;
  char argv[5][20];
  FP_t fp[1];
  DIR_t dir[1];
  uint active = TRUE;

  //clear the dataBlock
  for(i=0;i<128;i++){
    dataBlock[0].data[i]=0;
  }

  while (active)
  {
    select
    {
      // receive rpc args
      case slave
      {
        client1 :> cmd;
        client1 :> argc;

        for (i=0; i<argc; i++)
        {
          j=0;
          do
          {
            client1 :> tmp;
            argv[i][j] = tmp;
            j++;
          }
          while (tmp != '\0');
        }
      }:

      {
        switch (cmd)
        {
          case FAT16_CMD_initialise:
          {
            if (SD_link_initialise(p_sd_cmd, p_sd_clk, p_sd_dat, p_sd_rsv) == XMOS_SUCCESS)
            {
              if (FAT_initialise(dataBlock, p_sd_cmd, p_sd_clk, p_sd_dat) == XMOS_SUCCESS)
              {
                currentDirSectorAddr = rootDirStartSector;
                returnCode = XMOS_SUCCESS;
              }
              else
              {
                returnCode = XMOS_FAIL;
              }
            }
            else
            {
              returnCode = XMOS_FAIL;
            }

            master
            {
              client1 <: returnCode;
            }


            break;
          }
          case FAT16_CMD_fopen:
          {
            uint found;

            currentDirSectorAddr = rootDirStartSector;

            // read current dir sector
            SD_readSingleBlock(currentDirSectorAddr, dataBlock, p_sd_cmd, p_sd_clk, p_sd_dat);
            found = FAT_fopen(dataBlock, fp, argv[0], argv[1][0], p_sd_cmd, p_sd_clk, p_sd_dat);


            // send back
            master
            {
              client1 <: found;
              client1 <: fp[0];
            }
            break;
          }
          case FAT16_CMD_fclose:
          {
            slave
            {
              client1 :> fp[0];
            }

            currentDirSectorAddr = rootDirStartSector;

            // read current dir sector
            SD_readSingleBlock(currentDirSectorAddr, dataBlock, p_sd_cmd, p_sd_clk, p_sd_dat);
            FAT_fclose(dataBlock, fp, p_sd_cmd, p_sd_clk, p_sd_dat);

            master
            {
              client1 <: returnCode;
              client1 <: fp[0];
            }
            break;
          }
          case FAT16_CMD_fread:
          {
            uint size;
            uint count;
            char buf[15];
            uint numBytes;


            slave
            {
              client1 :> fp[0];
              client1 :> size;
              client1 :> count;
            }
            numBytes = FAT_fread(dataBlock, fp, buffer, size, count, p_sd_cmd, p_sd_clk, p_sd_dat);

            // send data
            master
            {
              client1 <: numBytes;
              if (numBytes > 0)
              {
                for (uint i=0; i<numBytes; i++)
                {
                  client1 <: (char)buffer[i];
                }
                client1 <: fp[0];
              }
            }

            break;
          }
          case FAT16_CMD_fwrite:
          {
            uint size;
            uint count;
            uint numBytesWritten = 0;
            // receive data
            slave
            {
              client1 :> fp[0];
              client1 :> size;
              client1 :> count;

              for (int i=0; i<count; i++)
              {
                client1 :> buffer[i];
              }
            }

            numBytesWritten = FAT_fwrite(dataBlock, fp, buffer, size, count, p_sd_cmd, p_sd_clk, p_sd_dat);

            // return args
            master
            {
              client1 <: numBytesWritten;
              client1 <: fp[0];
            }
            break;
          }
          case FAT16_CMD_readdir:
          {
            char fileName[255];

            slave
            {
              client1 :> dir[0];
            }


            // Read directory
            returnCode = FAT_readDirTableEntry(dataBlock, fileName, dir, p_sd_cmd, p_sd_clk, p_sd_dat);

            // return args
            master
            {
              client1 <: returnCode;
              client1 <: dir[0];
            }

            break;
          }
          case FAT16_CMD_opendir:
          {
            returnCode = XMOS_SUCCESS;

            slave
            {
              client1 :> dir[0];
            }

            dir[0].entryNum = 0xFFFFFFFF;
            dir[0].entryAddr = 0x0;
            currentDirSectorAddr = rootDirStartSector;
            // return args
            master
            {
              client1 <: returnCode;
              client1 <: dir[0];
            }
            break;
          }
          case FAT16_CMD_closedir:
          {
            returnCode = XMOS_SUCCESS;

            slave
            {
              client1 :> dir[0];
            }

            // return args
            master
            {
              client1 <: returnCode;
              client1 <: dir[0];
            }
            break;
          }
          case FAT16_CMD_ls:
          {
            currentDirSectorAddr = rootDirStartSector;
            returnCode = SD_readSingleBlock(currentDirSectorAddr, dataBlock, p_sd_cmd, p_sd_clk, p_sd_dat);
            if (returnCode == XMOS_SUCCESS)
            {
              returnCode = FAT_directoryList(dataBlock, dir, p_sd_cmd, p_sd_clk, p_sd_dat);
            }

            // return args
            master
            {
              client1 <: returnCode;
            }

            break;
          }
          case FAT16_CMD_rm:
          {
            returnCode = XMOS_FAIL;

            currentDirSectorAddr = rootDirStartSector;

            // read current dir sector
            SD_readSingleBlock(currentDirSectorAddr, dataBlock, p_sd_cmd, p_sd_clk, p_sd_dat);
            
            if (FAT_find(dataBlock, fp, argv[0], p_sd_cmd, p_sd_clk, p_sd_dat))
            {
              if (fp[0].attributes == 0x10)
              {
                // directory
                returnCode = XMOS_FAIL;
              }
              else
              {
                returnCode = FAT_fdelete(dataBlock, fp, argv[0], p_sd_cmd, p_sd_clk, p_sd_dat);
              }
            }
            else
            {
              returnCode = XMOS_FAIL;
            }

            // return args
            master
            {
              client1 <: returnCode;
            }


            break;
          }
          case FAT16_CMD_finish:
          {
            active = FALSE;


            // return args
            master
            {
              client1 <: returnCode;
            }
            break;
          }
        }
        break;
      }
    }
  }
}
