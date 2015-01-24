
# Object files directory
# Warning: this will be removed by make clean!
#
OBJDIR = obj

# Target file name (without extension)
TARGET = $(OBJDIR)/blink

# CMSIS root
CMSISROOT = ../STM32Cube_FW_F4_V1.3.0/Drivers/CMSIS

# Define all C source files (dependencies are generated automatically)
#
SOURCES += main.c
SOURCES += startup_stm32f407xx.s
SOURCES += system_stm32f4xx.c

OBJECTS  = $(addprefix $(OBJDIR)/,$(addsuffix .o,$(basename $(SOURCES))))

# Place -D, -U or -I options here for C and C++ sources
CPPFLAGS += -I$(CMSISROOT)/Include
CPPFLAGS += -I$(CMSISROOT)/Device/ST/STM32F4xx/Include
CPPFLAGS += -DSTM32F407xx -DHSE_VALUE=16000000L

#---------------- Compiler Options C ----------------
#  -g*:          generate debugging information
#  -O*:          optimization level
#  -f...:        tuning, see GCC documentation
#  -Wall...:     warning level
#  -Wa,...:      tell GCC to pass this to the assembler.
#    -adhlns...: create assembler listing
CFLAGS  = -Wall
CFLAGS	+= -std=c99
CFLAGS	+= -gdwarf-2
CFLAGS	+= -ffunction-sections
CFLAGS	+= -fdata-sections
CFLAGS	+= -O2
#CFLAGS += -Wextra
#CFLAGS += -Wpointer-arith
#CFLAGS += -Wstrict-prototypes
#CFLAGS += -Winline
#CFLAGS += -Wunreachable-code
#CFLAGS += -Wundef
CFLAGS += -Wa,-adhlns=$(OBJDIR)/$(*F).lst

# Optimize use of the single-precision FPU
#
#CFLAGS += -fsingle-precision-constant

# This will not work without recompiling libs
#
# CFLAGS += -fshort-double

#---------------- Assembler Options ----------------
#  -Wa,...:   tell GCC to pass this to the assembler
#  -adhlns:   create listing
#
ASFLAGS = -Wa,-adhlns=$(OBJDIR)/$(*F).lst


#---------------- Linker Options ----------------
#  -Wl,...:     tell GCC to pass this to linker
#    -Map:      create map file
#    --cref:    add cross reference to  map file
LDFLAGS += -lm
LDFLAGS += -Wl,-Map=$(TARGET).map,--cref
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -TSTM32F407VG_FLASH.ld

#============================================================================


# Define programs and commands
TOOLCHAIN = arm-none-eabi
CC        = $(TOOLCHAIN)-gcc
OBJCOPY   = $(TOOLCHAIN)-objcopy
OBJDUMP   = $(TOOLCHAIN)-objdump
SIZE      = $(TOOLCHAIN)-size
NM        = $(TOOLCHAIN)-nm
#OPENOCD   = 
STFLASH    = st-flash



# Compiler flags to generate dependency files
GENDEPFLAGS = -MMD -MP -MF $(OBJDIR)/$(*F).d


# Combine all necessary flags and optional flags
# Add target processor to flags.
#

CPU = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16

CFLAGS   += $(CPU)
ASFLAGS  += $(CPU)
LDFLAGS  += $(CPU)

# Default target.
all:  gccversion build showsize

build: elf hex lss sym

elf: $(TARGET).elf
hex: $(TARGET).hex
bin: $(TARGET).bin
lss: $(TARGET).lss
sym: $(TARGET).sym


# Display compiler version information
gccversion: 
	@$(CC) --version


# Show the final program size
showsize: elf
	@echo
	@$(SIZE) $(TARGET).elf 2>/dev/null


# Flash the device  
flash: bin
#	$(OPENOCD) -f "openocd.cfg" -c "flash_image $(TARGET).elf; shutdown"
	$(STFLASH) write $(TARGET).bin 0x8000000


# Target: clean project
clean:
	@echo Cleaning project:
	rm -fr $(OBJDIR)


# Create extended listing file from ELF output file
%.lss: %.elf
	@echo
	@echo Creating Extended Listing: $@
	$(OBJDUMP) -h -S -z $< > $@


# Create a symbol table from ELF output file
%.sym: %.elf
	@echo
	@echo Creating Symbol Table: $@
	$(NM) -n $< > $@


# Link: create ELF output file from object files
.SECONDARY: $(TARGET).elf
.PRECIOUS:  $(OBJECTS)
$(TARGET).elf: $(OBJECTS)
	@echo
	@echo Linking: $@
	$(CC) $^ $(LDFLAGS) --output $@ 


# Create final output files (.hex, .eep) from ELF output file.
%.hex: %.elf
	@echo
	@echo Creating hex file: $@
	$(OBJCOPY) -O ihex $< $@

%.bin: %.elf
	@echo
	@echo Creating bin file: $@
	$(OBJCOPY) -O binary $< $@


# Compile: create object files from C source files
$(OBJDIR)/%.o: %.c
	@echo
	@echo Compiling C: $<
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $(GENDEPFLAGS) $< -o $@ 

# Assemble: create object files from assembler source files
$(OBJDIR)/%.o: %.s
	@echo
	@echo Assembling: $<
	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

# Create object file directories
$(shell mkdir -p $(OBJDIR) 2>/dev/null)
#$(shell mkdir -p $(OBJDIR)/src 2>/dev/null)

# Include the dependency files
-include $(wildcard $(OBJDIR)/*.d)


# Listing of phony targets
.PHONY: all build clean \
        elf lss sym \
        showsize gccversion
