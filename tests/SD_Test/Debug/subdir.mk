################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
XC_SRCS += \
../FAT16.xc \
../FAT16_client.xc \
../FAT16_server.xc \
../SD_link.xc \
../SD_phy.xc \
../test.xc 

XN_SRCS += \
../XC-2.xn 

OBJS += \
./FAT16.o \
./FAT16_client.o \
./FAT16_server.o \
./SD_link.o \
./SD_phy.o \
./test.o 


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.xc
	@echo 'Building file: $<'
	@echo 'Invoking: XC Compiler'
	xcc -O0 -g -Wall -c -o "$@" "$<" "../XC-2.xn"
	@echo 'Finished building: $<'
	@echo ' '


