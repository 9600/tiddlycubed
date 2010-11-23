/*
 * @ModuleName FAT16_Client
 * @Author Ali Dixon
 * @Date 07/06/2008
 * @Version 1.0
 * @Description: Client side functions for SD_FAT16
 *
 * Copyright XMOS Ltd 2008
*/ 

#include <xs1.h>
#include <string.h>
#include "FAT16_client.h"
#include "FAT16_def.h"

#define READ_WRITE_BUFFER_SIZE 512


// Initialise the card and file system
XMOS_RTN_t FAT16_Clnt_initialise(chanend server)
{
  uint returnCode;
  master
  {
    server <: (int)FAT16_CMD_initialise;
    server <: (int)0;  // argc
  }
  
  slave
  {
    server :> returnCode;
  }
    
  return returnCode;
}


// Open a file
XMOS_RTN_t FAT16_Clnt_fopen(chanend server, FP_t fp[], char filename[], char mode)
{
  uint i;
  uint returnCode;
  
  i=0;  

  master 
  { 
    server <: (uint)FAT16_CMD_fopen;
    server <: (uint) 2;   // argc
    i=0;
    
    while (filename[i] != '\0')
    {
      server <: (char)filename[i];
      i++;
    }
    
    server <: (char)'\0';
    server <: (char)mode;
    server <: (char)'\0';    
  }  
  
  slave 
  {    
    server :> returnCode;
    server :> fp[0];
  }    
  return returnCode;
}

// Close a file
XMOS_RTN_t FAT16_Clnt_fclose(chanend server, FP_t fp[])
{
  uint returnCode;
  master 
  { 
    server <: (uint)FAT16_CMD_fclose;
    server <: (uint) 0;   // argc    
  }  
  
  // send args
  master
  {
    server <: fp[0];
  }
  
  // receive args
  slave
  {
    server :> returnCode;
    server :> fp[0];
  }
  
  return returnCode;
}


// Read from an open file
uint FAT16_Clnt_fread(chanend server, FP_t fp[], char buffer[], uint size, uint count)
{
  uint i;
  uint numBytesRead = 0;
     
  if ((size * count) <= READ_WRITE_BUFFER_SIZE)
  { 
    master 
    { 
      server <: (uint)FAT16_CMD_fread;
      server <: (uint) 0;   // argc
      i=0;
    }   
    
    // send specific args
    master
    {
      server <: fp[0];
      server <: size;
      server <: count;  
    } 
      
    slave
    {
      // data count
      server :> numBytesRead;      
      if (numBytesRead > 0)
      { 
        // receive data 
        for (uint i=0; i<numBytesRead; i++)
        {
          server :> buffer[i];
        }  
        server :> fp[0];
      } 
    }     
  }   
  return numBytesRead;
}


// Write to an open file
uint FAT16_Clnt_fwrite(chanend server, FP_t fp[], char buffer[], uint size, uint count)
{
  uint numBytesWritten = 0;
  uint i;
  
  if ((size * count) <= READ_WRITE_BUFFER_SIZE)
  {
      
    master 
    { 
      server <: (uint)FAT16_CMD_fwrite;
      server <: (uint) 0;   // argc
      i=0;    
    }    
      
    master
    {
      server <: fp[0];
      server <: size;
      server <: count;
          
      // send data 
      for (uint i=0; i<count; i++)
      {
        server <: (char)buffer[i];
      } 
    }
  
    // return args
    slave
    {
      server :> numBytesWritten;
      server :> fp[0];
    }   
  }
    
  return numBytesWritten;
}


// Open the dir with the given name
XMOS_RTN_t FAT16_Clnt_opendir(chanend server, char name[], DIR_t dir[])
{
  uint returnCode;
  master
  {
    server <: FAT16_CMD_opendir;
    server <: 0;  // argc
  }
  
  // send current dir
  master 
  {
    server <: dir[0];  
  }
  
  // return args
  slave 
  {  
    server :> returnCode;
    server :> dir[0];  
  }
    
  return XMOS_SUCCESS;
}


// Close the given dir
XMOS_RTN_t FAT16_Clnt_closedir(chanend server, DIR_t dir[])
{
  uint returnCode;
  master
  {
    server <: FAT16_CMD_closedir;
    server <: 0;  // argc
  }
  
  // send current dir
  master 
  {
    server <: dir[0];  
  }
  
  // return args
  slave 
  {  
    server :> returnCode;
    server :> dir[0];  
  }  
  return XMOS_SUCCESS;
}


// readdir
uint FAT16_Clnt_readdir(chanend server, DIR_t dir[])
{
  uint returnCode;
  master
  {
    server <: FAT16_CMD_readdir;
    server <: 0;  // argc
  }
  
  // send current dir
  master 
  {
    server <: dir[0];  
  }
  
  // return args
  slave 
  {  
    server :> returnCode;
    server :> dir[0];  
  }
  
  return returnCode;
}


// List current directory (uses xlog)
XMOS_RTN_t FAT16_Clnt_ls(chanend server)
{
  uint returnCode;
  master
  {
    server <: FAT16_CMD_ls;
    server <: 0;  // argc
  }
  
  // return args
  slave 
  {  
    server :> returnCode;
  }
  
  return returnCode;
}


// Delete a file
XMOS_RTN_t FAT16_Clnt_rm(chanend server, FP_t fp[], char filename[])
{
  uint i;
  uint returnCode;
  
  i=0;  

  master 
  { 
    server <: (uint)FAT16_CMD_rm;
    server <: (uint) 1;   // argc
    i=0;
    
    while (filename[i] != '\0')
    {
      server <: (char)filename[i];
      i++;
    }
    
    server <: (char)'\0';
  }  
  
  // return args
  slave 
  {    
    server :> returnCode;
  }
    
  return returnCode;
}


// Close the server
XMOS_RTN_t FAT16_Clnt_finish(chanend server)
{
  uint i;
  uint returnCode;
  
  i=0;  

  master 
  { 
    server <: (uint)FAT16_CMD_finish;
    server <: (uint) 0;   // argc
    i=0;    
  }  
  
  // return args
  slave 
  {    
    server :> returnCode;
  }
    
  return returnCode;
}
