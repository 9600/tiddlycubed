/*
 * @ModuleName SD bus controller
 * @Author Ali Dixon
 * @Date 07/06/2008
 * @Version 1.0
 * @Description: Provide functions for controlling the SD bus
 *
 * Copyright XMOS Ltd 2008
*/

#include <xs1.h>
#include <xclib.h>
#include "SD_phy.h"

// Delay required for SPI frequency
uint SD_SPI_BIT_PERIOD;
uint SD_INIT_BIT_PERIOD;
uint SD_FAST_BIT_PERIOD;

// Initialise bus
uint SD_phy_initialise(port p_sd_cmd, port p_sd_clk, port p_sd_dat, port p_sd_rsv)
{
  uint i;

  SD_INIT_BIT_PERIOD = (SW_REF_CLK_MHZ * 1000000 / (unsigned) 100000)/2; //100khz;
  SD_SPI_BIT_PERIOD = SD_INIT_BIT_PERIOD;
  SD_FAST_BIT_PERIOD =SD_INIT_BIT_PERIOD;
  p_sd_clk <: 0;
  p_sd_cmd <: 0;
  p_sd_dat <: 0;
  p_sd_rsv <: 1;

  // Send all '1's to wake up card
  for (i=0; i<30; i=i+1)
  {
    SD_phy_sendCMDByte(0xFF, p_sd_cmd, p_sd_clk);
  }

  return 0;
}


uint SD_phy_setHighSpeed()
{
  SD_SPI_BIT_PERIOD = (SW_REF_CLK_MHZ * 1000000 / (unsigned) 10000000)/2; //300khz;
  return 0;
}


uint SD_phy_setLowSpeed()
{
  SD_SPI_BIT_PERIOD = SD_INIT_BIT_PERIOD;
  return 0;
}


// Get R1 response - 48 bits. R3 response is identical (48 bits)
void SD_phy_getR1Response(r1Response_t r[], port p_sd_cmd, port p_sd_clk)
{
  uint data;

  SD_phy_receiveStartCommandBits(p_sd_cmd, p_sd_clk);

  // reserved bits
  data = SD_phy_receiveCommandBits(6, p_sd_cmd, p_sd_clk);
  r[0].commandIndex = data;

  // card status
  data = SD_phy_receiveCommandBits(32, p_sd_cmd, p_sd_clk);
  r[0].data = data;

  // crc and end bit
  data = SD_phy_receiveCommandBits(8, p_sd_cmd, p_sd_clk);
  r[0].crc = data;

  // reserved end bits
  SD_phy_receiveCommandBits(8, p_sd_cmd, p_sd_clk);
}


// Get R2 response - 136 bits
void SD_phy_getR2Response(r2Response_t r[], port p_sd_cmd, port p_sd_clk)
{
  uint otherBits;
  uint data;

  SD_phy_receiveStartCommandBits(p_sd_cmd, p_sd_clk);

  // reserved bits
  otherBits = SD_phy_receiveCommandBits(6, p_sd_cmd, p_sd_clk);

  // data bits (CID or CSD)
  data = SD_phy_receiveCommandBits(32, p_sd_cmd, p_sd_clk);
  r[0].data[0] = data;
  data = SD_phy_receiveCommandBits(32, p_sd_cmd, p_sd_clk);
  r[0].data[1] = data;
  data = SD_phy_receiveCommandBits(32, p_sd_cmd, p_sd_clk);
  r[0].data[2] = data;
  data = SD_phy_receiveCommandBits(32, p_sd_cmd, p_sd_clk);
  r[0].data[3] = data;

  // crc and end bit
  data = SD_phy_receiveCommandBits(8, p_sd_cmd, p_sd_clk);

  // reserved end bits
  SD_phy_receiveCommandBits(8, p_sd_cmd, p_sd_clk);
}


// Get R3 response - 48 bits.
uint SD_phy_getR3Response(r3Response_t r[], port p_sd_cmd, port p_sd_clk)
{
  uint data;
  uint otherBits;

  SD_phy_receiveStartCommandBits(p_sd_cmd, p_sd_clk);

  // reserved bits
  otherBits = SD_phy_receiveCommandBits(6, p_sd_cmd, p_sd_clk);

  // data bits (OCR)
  data = SD_phy_receiveCommandBits(32, p_sd_cmd, p_sd_clk);
  r[0].data = data;

  // reserved and end bits
  otherBits = SD_phy_receiveCommandBits(8, p_sd_cmd, p_sd_clk);

  SD_phy_receiveCommandBits(8, p_sd_cmd, p_sd_clk);

  return 0;
}


// The SD command sequence consists of 6 bytes:
//     Byte 0      Command byte: 01XXXXXX   where Xs are command
//     Byte 4:1    32 bit argument: all 0 if not needed
uint SD_phy_sendCommand(uint cmd, uint args, port p_sd_cmd, port p_sd_clk)
{
  uint data;
  uint crc1 = 0;
  uint tmp;
  data = (cmd | 64) & 127;
  crc1 = 0;
  tmp = bitrev(data) >> 24;
  crc8shr(crc1, tmp, CRC7_POLY_REV);

  tmp = bitrev(args);
  crc8shr(crc1, tmp, CRC7_POLY_REV);
  crc8shr(crc1, tmp>>8, CRC7_POLY_REV);
  crc8shr(crc1, tmp>>16, CRC7_POLY_REV);
  crc8shr(crc1, tmp>>24, CRC7_POLY_REV);
  crc1 = bitrev(crc1);

  SD_phy_sendCMDByte(data, p_sd_cmd, p_sd_clk);

  SD_phy_sendCMDByte(args >> 24, p_sd_cmd, p_sd_clk);
  SD_phy_sendCMDByte(args >> 16, p_sd_cmd, p_sd_clk);
  SD_phy_sendCMDByte(args >> 8, p_sd_cmd, p_sd_clk);
  SD_phy_sendCMDByte(args, p_sd_cmd, p_sd_clk);

  tmp = bitrev(crc1);
  crc8shr(tmp, 0x0, CRC7_POLY_REV);
  crc8shr(tmp, 0x0, CRC7_POLY_REV);
  crc8shr(tmp, 0x0, CRC7_POLY_REV);
  crc8shr(tmp, 0x0, CRC7_POLY_REV);

  crc1 = bitrev(tmp);

  // shift 7 bit CRC into bits 7:1
  crc1 = ((crc1>>24));

  // 'or' in the stop bit.
  data = (crc1 | 1);
  SD_phy_sendCMDByte(data, p_sd_cmd, p_sd_clk);

  p_sd_cmd :> int tmp;

  return 0;
}


// User Functions
uint SD_phy_receiveStartCommandBits(port p_sd_cmd, port p_sd_clk)
{
  return SD_phy_receiveStartBits(p_sd_cmd, p_sd_clk);
}

uint SD_phy_receiveStartDataBits(port p_sd_clk, port p_sd_dat)
{
  return SD_phy_receiveStartBits(p_sd_dat, p_sd_clk);
}

uint SD_phy_receiveCommandBits(uint numBits, port p_sd_cmd, port p_sd_clk)
{
  return SD_phy_receiveBits(p_sd_cmd, numBits, p_sd_clk);
}

uint SD_phy_receiveDataBits(uint numBits, port p_sd_clk, port p_sd_dat)
{
  return SD_phy_receiveBits(p_sd_dat, numBits, p_sd_clk);
}

uint SD_phy_sendDataBits(uint numBits, uint data, port p_sd_clk, port p_sd_dat)
{
  return SD_phy_sendBits(p_sd_dat, numBits, data, p_sd_clk);
}


// Receive the given number of bits on CMD, upto a maximum of 32 bits.
// Generate the clock to retreive the data.
// Return the received data.
uint SD_phy_receiveStartBits(port p, port p_sd_clk)
{
  uint totBits;
  uint bit;
  uint data;
  timer t;
  uint time;
  uint error;
  uint i;
  totBits = 0;
  data = 0;

  error = 0;

  t :> time;

  // set to input
  p :> int tmp;

  bit = 1;

  // receive start bit
  i = 0;
  while (bit != 0)
  {
    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 1;        // set clock high

    time = time + 5;
    t when timerafter(time) :> time;
    p :> bit;
    data = (data << 1) | bit;

    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 0;        // set clock low
    totBits = totBits + 1;

    i = i + 1;
    if (i > 500)
    {
      error = 1;
      break;
    }
  }

  if (!error)
  {
    // receive transmitter bit
    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 1;        // set clock high

    time = time + 5;
    t when timerafter(time) :> time;
    p :> bit;
    data = (data << 1) | bit;

    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 0;        // set clock low
    totBits = totBits + 1;
  }

  // return transmitter bit
  return bit;
}


// Receive the given number of bits on CMD, upto a maximum of 32 bits.
// Generate the clock to retreive the data.
// Return the received data.
uint SD_phy_receiveBits(port p, uint numBits, port p_sd_clk)
{
  uint totBits;
  uint bit;
  uint data;
  timer t;
  uint time;

  totBits = 0;
  data = 0;

  t :> time;

  // set to input
  p :> int tmp;

  // now receive data bits
  while (totBits < numBits)
  {
    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 1;        // set clock high

    time = time + 5;
    t when timerafter(time) :> time;
    p :> bit;
    data = (data << 1) | bit;

    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 0;        // set clock low
    totBits = totBits + 1;
  }

  return data;
}


// Receive the given number of bits on DAT, upto a maximum of 32 bits.
// Generate the clock to retreive the data.
// Return the received data.
uint SD_phy_receiveDataBlockWithR1Response(SDDataBlock_t dataBlock[], r1Response_t r[], port p_sd_cmd, port p_sd_clk, port p_sd_dat)
{
  uint datBitPos = 0;
  uint datWordCnt = 0;
  uint cmdBitPos = 0;
  uint cmdWordCnt = 0;
  uint datBit;
  uint cmdBit;
  uint datWord = 0;
  uint cmdWord = 0;
  DAT_status_t datState = DAT_start;
  CMD_status_t cmdState = CMD_start;

  timer t;
  uint time;

  // skip Nac cyckes
  SD_phy_receiveDataBits(4, p_sd_clk, p_sd_dat);

  t :> time;

  // set to input
  p_sd_dat :> uint tmp;
  p_sd_cmd :> uint tmp;

  // now receive data bits and cmd bits
  while ((datState != DAT_done) | (cmdState != CMD_done))
  {
    // set clock high
    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 1;

    time = time + 5;
    t when timerafter(time) :> time;
    p_sd_dat :> datBit;
    p_sd_cmd :> cmdBit;

    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 0;

    // receive dat bits
    switch (datState)
    {
      case DAT_start:
      {
        datBitPos += 1;

        // detect start bit
        if (datBit == 0)
        {
          datState = DAT_data;
          datBitPos = 0;
        }

        // Detect error
        if (datBitPos > 1000)
        {
          return XMOS_FAIL;
        }

        break;
      }
      case DAT_data:
      {
        // receive data
        datWord = (datWord << 1) | datBit;
        datBitPos += 1;

        // store word
        if (datBitPos == 32)
        {
          dataBlock[0].data[datWordCnt] = datWord;
          datWord = 0;
          datBitPos = 0;
          datWordCnt += 1;

          if (datWordCnt >= (BLOCK_SIZE>>2))
          {
            datState = DAT_end;
            datWordCnt = 0;
            datWord = 0;
          }
        }
        break;
      }
      case DAT_end:
      {
        // receive crc and end bits
        datWord = (datWord << 1) | datBit;
        datBitPos += 1;


        if (datBitPos == 32)
        {
          // receive crc
          if (datWordCnt == 0)
          {
            dataBlock[0].crc = datWord >> 16;
          }
          datBitPos = 0;
          datWordCnt += 1;
          datWord = 0;
          if (datWordCnt > 4)
          {
            datState = DAT_done;
          }
        }

        break;
      }
      case DAT_done:
      {
        break;
      }
    }

    // receive cmd bits
    switch (cmdState)
    {
      case CMD_start:
      {
        cmdBitPos += 1;

        // detect start bit
        if (cmdBit == 0)
        {
          cmdState = CMD_transmitter;
          cmdBitPos = 0;
        }

        // Detect error
        if (cmdBitPos > 1000)
        {
          return XMOS_FAIL;
        }
        break;
      }
      case CMD_transmitter:
      {
        cmdBitPos += 1;
        // detect transmitter bit
        if (cmdBit == 1)
        {
          cmdState = CMD_data;
          cmdBitPos = 0;
        }

        // Detect error
        if (cmdBitPos > 1000)
        {
          return XMOS_FAIL;
        }
        break;
      }
      case CMD_data:
      {
        // receive data
        cmdWord = (cmdWord << 1) | cmdBit;
        cmdBitPos += 1;

        // store word
        if (cmdBitPos == 32)
        {
          r[0].data = cmdWord;
          cmdWord = 0;
          cmdBitPos = 0;
          cmdWordCnt += 1;

          if (cmdWordCnt > 2)
            cmdState = CMD_done;
        }
        break;
      }
      case CMD_done:
      {
        break;
      }
    }
  }

  time = time + SD_SPI_BIT_PERIOD;
  t when timerafter(time) :> time;

  return XMOS_SUCCESS;
}


// Send the given number of bits on DAT, upto a maximum of 32 bits.
// Generate the clock to send the data.
uint SD_phy_sendBits(port p, uint numBits, uint data, port p_sd_clk)
{
  uint totBits;
  uint bit;
  timer t;
  uint time;
  totBits = 0;

  t :> time;

  // now receive data bits
  while (totBits < numBits)
  {

    bit = (data & 0x80000000) >> (31);
    data = data << 1;
    p <: bit;

    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 1;        // set clock high


    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 0;        // set clock low

    totBits = totBits + 1;
  }

  time = time + SD_SPI_BIT_PERIOD;
  t when timerafter(time) :> time;

  return 0;
}


// Send byte to slave on CMD.  MSB first
// SD cards clock data in on the rising clock edge
uint SD_phy_sendCMDByte(uint inByte, port p_sd_cmd, port p_sd_clk)
{
  uint bitCount;
  uint bit;
  uint byte;
  timer t;
  uint time;

  byte = inByte;
  bitCount = 0;

  t :> time;

  while (bitCount < 8)
  {

    bit = (byte & 128) >> 7;
    p_sd_cmd <: bit;

    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 1;        // set clock high

    byte = byte << 1;
    bitCount = bitCount + 1;

    time = time + SD_SPI_BIT_PERIOD;
    t when timerafter(time) :> time;
    p_sd_clk <: 0;        // set clock low
  }

  time = time + SD_SPI_BIT_PERIOD;
  t when timerafter(time) :> time;

  return 0;
}
