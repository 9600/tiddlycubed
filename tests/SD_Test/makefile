SOURCES = FAT16_client.xc FAT16.xc FAT16_server.xc SD_link.xc SD_phy.xc test.xc
FLAGS = -Wall -O3 -target=XC-2

ifeq "$(OS)" "Windows_NT"
DELETE = del
else
DELETE = rm -f
endif

all: build

clean:
	$(DELETE) *.o *.a *.xi *.s *.xe *.xb

build:
	xcc $(FLAGS) $(SOURCES) -o sdcard.xe
	xobjdump --strip sdcard.xe
