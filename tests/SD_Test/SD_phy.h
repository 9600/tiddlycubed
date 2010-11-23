// SPI controller for SD

#ifndef __SD_PHY_H__
#define __SD_PHY_H__

#include <xs1.h>
#include "sw_comps_common.h"

#define CRC7_POLY 0x12000000
#define CRC7_POLY_REV 0x48

extern uint SD_SPI_BIT_PERIOD;

// SD commands
#define GO_IDLE_STATE 0          // CMD0
#define SEND_OP_COND  1          // CMD1
#define ALL_SEND_CID  2          // CMD2
#define SET_RELATIVE_ADDR 3      // CMD3
// CMD4
// CMD5
// CMD6
#define SELECT_DESELECT_CARD 7   // CMD7
#define SEND_IF_COND 8           // CMD 8
#define SEND_CSD 9               // CMD9
#define SEND_CID 10              // CMD10
// CMD11
#define STOP_TRANSMISSION 12     // CMD12
#define SEND_STATUS 13           // CMD13
// CMD14
#define GO_INACTIVE_STATE 15     // CMD15
#define SET_BLOCKLEN 16          // CMD16
#define READ_SINGLE_BLOCK 17     // CMD17
#define READ_MULTIPLE_BLOCK 18   // CMD18
// CMD19
#define WRITE_SINGLE_BLOCK 24    // CMD24
#define WRITE_MULTIPLE_BLOCK 25  // CMD25
// CMD26
#define PROGRAM_CSD 27           // CMD27
#define SET_WRITE_PROT 28        // CMD28
#define CLR_WRITE_PROT 29        // CMD29
#define SEND_WRITE_PLOT 30       // CMD30
// CMD31
#define TAG_SECTOR_START 32      // CMD32
#define TAG_SECTOR_END 33        // CMD33
#define UNTAG_SECTOR 34          // CMD34
#define TAG_ERASE_START_GROUP 35 // CMD35
#define TAG_ERASE_GROUP_END 36   // CMD36
#define UNTAG_ERASE_GROUP 37     // CMD37
#define ERASE 38                 // CMD38

#define LOCK_UNLOCK 42           // CMD42

// Application specific commands - must be prefixd by APP_CMD
#define APP_CMD 55               // CMD55

#define SD_SET_BUS_WIDTH 6       // ACMD6
#define SD_STATUS 13             // ACMD13
#define SD_SEND_OP_COND 41       // ACMD41

// Current state of SD card
enum SD_CARD_STATE
{
  SD_CARD_STATE_idle = 0,
  SD_CARD_STATE_ready,
  SD_CARD_STATE_ident,
  SD_CARD_STATE_stby,
  SD_CARD_STATE_tran,
  SD_CARD_STATE_data,
  SD_CARD_STATE_rcv,
  SD_CARD_STATE_prg,
  SD_CARD_STATE_dis
};

#define BLOCK_SIZE 512 // num bytes in a block

// Structure to hold a block of data
typedef struct SD_DATA_BLOCK_t
{
  uint blockSize;
  uint data[BLOCK_SIZE>>2];
  uint crc;
} SDDataBlock_t;

// Structure to hold an R1 response
typedef struct R1_RESPONSE
{
  uint commandIndex;
  uint data;
  uint crc;
} r1Response_t;

// Structure to hold an R2 response
typedef struct R2_RESPONSE
{
  uint data[5];   // only 136 bits used.
} r2Response_t;

// Structure to hold an R3 response
typedef struct R3_RESPONSE
{
  uint data;
} r3Response_t;

typedef enum SD_status
{
  SD_STATUS_ok = 0,
  SD_STATUS_error
} SD_status_t;

typedef enum DAT_status
{
  DAT_start = 0,
  DAT_data,
  DAT_end,
  DAT_done
} DAT_status_t;

typedef enum CMD_status
{
  CMD_start = 0,
  CMD_transmitter,
  CMD_data,
  CMD_done
} CMD_status_t;

// Public functions
uint SD_phy_initialise(port p_sd_cmd, port p_sd_clk, port p_sd_dat, port p_sd_rsv);
uint SD_phy_setHighSpeed();
uint SD_phy_setLowSpeed();
uint SD_phy_sendCommand(uint cmd, uint args, port p_sd_cmd, port p_sd_clk);
uint SD_phy_sendCommandUserCrc(uint cmd, uint args, uint crc);
void SD_phy_getR1Response(r1Response_t r[], port p_sd_cmd, port p_sd_clk);
void SD_phy_getR2Response(r2Response_t r[], port p_sd_cmd, port p_sd_clk);
uint SD_phy_getR3Response(r3Response_t r[], port p_sd_cmd, port p_sd_clk);
uint SD_phy_receiveDataBlockWithR1Response(SDDataBlock_t dataBlock[], r1Response_t r[], port p_sd_cmd, port p_sd_clk, port p_sd_dat);

// Private functions
uint Test_toggle();
uint SD_phy_sendCMDByte(uint inByte, port p_sd_cmd, port p_sd_clk);
uint SD_phy_receiveStartCommandBits(port p_sd_cmd, port p_sd_clk);
uint SD_phy_receiveCommandBits(uint numBits, port p_sd_cmd, port p_sd_clk);
uint SD_phy_receiveStartDataBits(port p_sd_clk, port p_sd_dat);
uint SD_phy_receiveDataBits(uint numBits, port p_sd_clk, port p_sd_dat);
uint SD_phy_sendDataBits(uint numBits, uint data, port p_sd_clk, port p_sd_dat);
uint SD_phy_receiveStartBits(port p, port p_sd_clk);
uint SD_phy_receiveBits(port p, uint numBits, port p_sd_clk);
uint SD_phy_sendBits(port p, uint numBits, uint data, port p_sd_clk);
uint SD_phy_sendBit(port p, timer t, uint time, uint bit);

// SPI mode functions
uint SPI_initialise();
uint SPI_init();
uint SPI_sendCommand(uint cmd, uint args, uint CRC);
uint SPI_receiveFirstDataBits(uint numBits);
uint SPI_receiveDataBits(uint numBits);
uint SPI_sendCMDByte(uint inByte);

#endif // __SD_PHY_H__
