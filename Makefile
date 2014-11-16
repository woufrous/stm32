PROJ		= blink
CPU		= cortex-m4
STM32		= STM32F407xx
SRC		= main.c
LDSCRIPT	= STM32F407VG_FLASH.ld

CMSIS		= ../STM32Cube_FW_F4_V1.3.0/Drivers/CMSIS
INCLUDE		= -I$(CMSIS)/Include \
		  -I$(CMSIS)/Device/ST/STM32F4xx/Include

# default source files
SRC	+= system_stm32f4xx.c
SRC	+= startup_stm32f407xx.s

OBJ	= $(addsuffix .o,$(basename $(SRC)))

HWCONF	+= -mcpu=$(CPU) -mthumb -mfloat-abi=softfp -mfpu=fpv4-sp-d16

# Flags
CFLAGS	= $(INCLUDE)
CFLAGS	+= $(HWCONF)
CFLAGS	+= -std=c99
CFLAGS	+= -gdwarf-2
CFLAGS	+= -ffunction-sections
CFLAGS	+= -fdata-sections
CFLAGS	+= -Wall
CFLAGS	+= -D$(STM32)
#CFLAGS	+= -Wa,-adhlns=$(OBJDIR)/$(*F).lst
CFLAGS	+= -fsingle-precision-constant
CFLAGS	+= --specs=nosys.specs
#LDFLAGS	+= -lm
#LDFLAGS	+= -Wl,-Map=$(PROJ).map,--cref
#LDFLAGS	+= -Wl,--gc-sections
LDFLAGS	+= -T$(LDSCRIPT)
LDFLAGS	+= --specs=nosys.specs

# Tools
TARGET	= arm-none-eabi-
CC	= $(TARGET)gcc
AS	= $(TARGET)as

all: elf

elf: $(PROJ).elf

showconfig:
	@echo "Build flags"
	@echo "------------"
	@echo "TARGET: $(TARGET)"
	@echo "SRC: $(SRC)"
	@echo "CFLAGS: $(CFLAGS)"

$(PROJ).elf: $(OBJ)
	$(CC) $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(AS) -c $< -o $@

clean:
	rm *.o
	rm $(PROJ).elf

.PHONY:
	all showconfig elf clean
