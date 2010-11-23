// Top level test for SD card bus

#include <xs1.h>
#include <platform.h>
#include <safestring.h>
#include <print.h>
#include "SD_phy.h"
#include "SD_link.h"
#include "FAT16.h"
#include "FAT16_server.h"
#include "FAT16_client.h"

#define DELAY 0xFFFFFF

// SD ports
on stdcore[3] : port p_sd_cmd = XS1_PORT_1H;
on stdcore[3] : port p_sd_clk = XS1_PORT_1E;
on stdcore[3] : port p_sd_dat = XS1_PORT_1F;
on stdcore[3] : port p_sd_rsv = XS1_PORT_1G;


// Test the SD card
void XDK_test(chanend FAT16_server)
{
	char buffer[500];
	DIR_t dir[1];
	FP_t fp[1];
	FP_t writeFile0[1];
	FP_t writeFile1[1];
	FP_t writeFile2[1];
	FP_t writeFile3[1];

	// init the card
	if (FAT16_Clnt_initialise(FAT16_server) != XMOS_SUCCESS)
	{
		printstrln("Error could not initialise card");
		return;
	}

	// read the root dir
	if (FAT16_Clnt_opendir(FAT16_server, ".", dir) == XMOS_SUCCESS)
	{
		while (FAT16_Clnt_readdir(FAT16_server, dir) != 0)
		{
			printstrln("########## Reading entry ");
			printhexln(dir[0].entryNum);
			printstrln("name: ");
			printstrln(dir[0].name);
			printstrln("entryAddr: ");
			printhexln(dir[0].entryAddr);
			printstrln("attributes: ");
			printhexln(dir[0].attributes);
		}
	}
	else
	{
		printstrln("Error - unable to open dir");
		return;
	}

	// check all required files are present
	if (FAT16_Clnt_fopen(FAT16_server, fp, "XDK.XB", 'r') != XMOS_SUCCESS) { printstrln("Error: XDK missing from card"); }
	if (FAT16_Clnt_fopen(FAT16_server, fp, "SPLASH1.BMP", 'r') != XMOS_SUCCESS) { printstrln("Error: SPLASH1 missing from card"); }
	if (FAT16_Clnt_fopen(FAT16_server, fp, "SPLASH2.BMP", 'r') != XMOS_SUCCESS) { printstrln("Error: SPLASH2 missing from card"); }
	if (FAT16_Clnt_fopen(FAT16_server, fp, "SPLASH3.BMP", 'r') != XMOS_SUCCESS)	{ printstrln("Error: SPLASH3 missing from card"); }
	if (FAT16_Clnt_fopen(FAT16_server, fp, "FREQ.XB", 'r') != XMOS_SUCCESS) { printstrln("Error: FREQ missing from card"); }
	if (FAT16_Clnt_fopen(FAT16_server, fp, "PONG.XB", 'r') != XMOS_SUCCESS)	{ printstrln("Error: PONG missing from card"); }
	if (FAT16_Clnt_fopen(FAT16_server, fp, "MBROT.XB", 'r') != XMOS_SUCCESS) { printstrln("Error: MBROT missing from card"); }
	if (FAT16_Clnt_fopen(FAT16_server, fp, "RGBLEDS.XB", 'r') != XMOS_SUCCESS) { printstrln("Error: RGBLEDS missing from card"); }
	if (FAT16_Clnt_fopen(FAT16_server, fp, "MOREAPPS.XB", 'r') != XMOS_SUCCESS)	{ printstrln("Error: MOREAPPS missing from card"); }
	FAT16_Clnt_fclose(FAT16_server, fp);

	// Write test

	// delete the test file first
	FAT16_Clnt_rm(FAT16_server, fp, "TEST.TXT");

	// check we can write
	if (FAT16_Clnt_fopen(FAT16_server, fp, "TEST.TXT", 'w') != XMOS_SUCCESS)
	{
		printstrln("Error: unable to write to card");
		//return;
	}
	else
	{
		buffer[0] = 'h';
		buffer[1] = 'e';
		buffer[2] = 'l';
		buffer[3] = 'l';
		buffer[4] = 'o';
		
		if (FAT16_Clnt_fwrite(FAT16_server, fp, buffer, 1, 5) != 5)
		{
			printstrln("Error writing to file");
			return;
		}
		
		FAT16_Clnt_fclose(FAT16_server, fp);

		// read back the file
		if (FAT16_Clnt_fopen(FAT16_server, fp, "TEST.TXT", 'r') != XMOS_SUCCESS)
		{
			printstrln("Error: unable to write to card");
			return;
		}
		else
		{
			buffer[0] = ' ';
			buffer[1] = ' ';
			buffer[2] = ' ';
			buffer[3] = ' ';
			buffer[4] = ' ';

			if (FAT16_Clnt_fread(FAT16_server, fp, buffer, 1, 5) != 5)
			{
				printstrln("Error reading from file - incorrect length");
				return;
			}
			else
			{
				if ((buffer[0] == 'h') && (buffer[1] == 'e') && (buffer[2] == 'l') && (buffer[3] == 'l') && (buffer[4] == 'o'))
				{
					printstrln("Read back written file - OK");

					if (FAT16_Clnt_fopen(FAT16_server, fp, "TEST.TXT", 'r') != XMOS_SUCCESS)
					{
						printstrln("Error deleting file");
						return;
					}
				}
				else
				{
					printstrln("Error reading from file - incorrect data");
					return;
				}
			}
		}
		
		printstrln("Write test 1 passed.");
	}
 
	// delete the test file first
	FAT16_Clnt_rm(FAT16_server, fp, "TEST.TXT");

	// check we can write
	if ( (FAT16_Clnt_fopen(FAT16_server, writeFile0, "FILE0.TXT", 'w') | FAT16_Clnt_fopen(FAT16_server, writeFile1, "FILE1.TXT", 'w') | FAT16_Clnt_fopen(FAT16_server, writeFile2, "FILE2.TXT", 'w') | FAT16_Clnt_fopen(FAT16_server, writeFile3, "FILE3.TXT", 'w') ) != XMOS_SUCCESS)
	{
		printstrln("Error: unable to write to card");
		return;
	}
	else
	{
		buffer[0] = 'h';
		buffer[1] = 'e';
		buffer[2] = 'l';
		buffer[3] = 'l';
		buffer[4] = 'o';
		buffer[5] = ' ';
		buffer[6] = 'w';
		buffer[7] = 'o';
		buffer[8] = 'r';
		buffer[9] = 'l';
		buffer[10] = 'd';

		if (FAT16_Clnt_fwrite(FAT16_server, writeFile0, buffer, 1, 2) + FAT16_Clnt_fwrite(FAT16_server, writeFile1, buffer, 1, 5) + FAT16_Clnt_fwrite(FAT16_server, writeFile2, buffer, 1, 8) + FAT16_Clnt_fwrite(FAT16_server, writeFile3, buffer, 1, 11) != (2+5+8+11))
		{
			printstrln("Error writing to file");
			return;
		}

		FAT16_Clnt_fclose(FAT16_server, writeFile0);
		FAT16_Clnt_fclose(FAT16_server, writeFile1);
		FAT16_Clnt_fclose(FAT16_server, writeFile2);
		FAT16_Clnt_fclose(FAT16_server, writeFile3);

		// delete the test files
		FAT16_Clnt_rm(FAT16_server, writeFile0, "FILE0.TXT");
		FAT16_Clnt_rm(FAT16_server, writeFile1, "FILE1.TXT");
		FAT16_Clnt_rm(FAT16_server, writeFile2, "FILE2.TXT");
		FAT16_Clnt_rm(FAT16_server, writeFile3, "FILE3.TXT");
		
		printstrln("Write test 2 passed.");
	}
}


void test ( chanend FAT16_Server )
{
	unsigned 	t;
	timer 		tmr;
		
	// Wait 3 seconds first
	tmr :> t;
	tmr when timerafter(t + 300000000) :> t;
	
	// Run the tests
	XDK_test( FAT16_Server );
    
    // Shut down FAT16 server
    FAT16_Clnt_finish( FAT16_Server );
}


// Program entry point
int main()
{
	chan 		FAT16;

	par
	{
		on stdcore[3] : test(FAT16);
		on stdcore[3] : FAT16_server(FAT16, p_sd_cmd, p_sd_clk, p_sd_dat, p_sd_rsv);
    }

	return 0;
}
