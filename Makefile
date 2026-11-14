#-------------------------------------------------------------------------------
.SUFFIXES:
#-------------------------------------------------------------------------------

ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>/devkitpro")
endif

TOPDIR ?= $(CURDIR)
include $(DEVKITPRO)/libounce/switch2_rules

#-------------------------------------------------------------------------------
# TARGET is the name of the output
# BUILD is the directory where object files & intermediate files will be placed
# SOURCES is a list of directories containing source code
# INCLUDES is a list of directories containing header files
# ROMFS is a folder to generate app's romfs
# APP_TITLE is the title of the app
# APP_AUTHOR is the author of the app
# APP_VERSION is the version of the app
# ICON is the icon image for the app
#-------------------------------------------------------------------------------
TARGET      := nces-switch2
BUILD       := build
SOURCES     := src
INCLUDES    := include
ROMFS       := romfs

APP_TITLE   := Nic Cage Eats Stuff
APP_AUTHOR  := Cart1416, PennyLoafer
APP_VERSION := 1.0.0
ICON        := icon.jpg

#-------------------------------------------------------------------------------
# options for code generation
#-------------------------------------------------------------------------------
ARCH        := $(SWITCH2_CPU) -mtp=soft -fPIE

CFLAGS      := -g -Wall -O2 -ffunction-sections -fdata-sections \
               $(ARCH) $(DEFINES)
CFLAGS      += $(INCLUDE) -D__SWITCH__ -D__SWITCH2__
CFLAGS      += -I$(PORTLIBS)/include/SDL2

CXXFLAGS    := $(CFLAGS) -std=gnu++17
ASFLAGS     := -g $(ARCH)
LDFLAGS     = -specs=$(LIBNX)/switch.specs -g $(ARCH) \
              -Wl,-Map,$(notdir $*.map) -Wl,--gc-sections

LIBS        := -Wl,--start-group \
               -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2 \
               -lvorbisidec -lmodplug -lmpg123 -lopusfile -lopus -logg -lFLAC \
               -lfreetype -lharfbuzz -lpng -ljpeg -lwebp -lz -lbz2 \
               -lEGL -lglapi -ldrm_nouveau -lnx -lpthread -lm \
               -Wl,--end-group

#-------------------------------------------------------------------------------
# list of directories containing libraries, this must be the top level
# containing include and lib
#-------------------------------------------------------------------------------
LIBDIRS     := $(PORTLIBS) $(LIBNX)

ifneq ($(BUILD),$(notdir $(CURDIR)))

export OUTPUT   := $(CURDIR)/$(TARGET)
export TOPDIR   := $(CURDIR)

export VPATH    := $(foreach dir,$(SOURCES),$(CURDIR)/$(dir))
export DEPSDIR  := $(CURDIR)/$(BUILD)

CFILES      := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
CPPFILES    := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
SFILES      := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))

#-------------------------------------------------------------------------------
# use CXX for linking C++ projects, CC for standard C
#-------------------------------------------------------------------------------
ifeq ($(strip $(CPPFILES)),)
    export LD := $(CC)
else
    export LD := $(CXX)
endif

export SRCFILES := $(CPPFILES) $(CFILES) $(SFILES)
export OFILES   := $(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)
export INCLUDE  := $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir)) \
                   $(foreach dir,$(LIBDIRS),-I$(dir)/include) \
                   -I$(CURDIR)/$(BUILD)

export LIBPATHS := $(foreach dir,$(LIBDIRS),-L$(dir)/lib)

ifeq ($(strip $(ICON)),)
    icons := $(wildcard *.jpg)
    ifneq (,$(findstring $(TARGET).jpg,$(icons)))
        export APP_ICON := $(TOPDIR)/$(TARGET).jpg
    else
        ifneq (,$(findstring icon.jpg,$(icons)))
            export APP_ICON := $(TOPDIR)/icon.jpg
        endif
    endif
else
    export APP_ICON := $(TOPDIR)/$(ICON)
endif

ifeq ($(strip $(NO_ICON)),)
    export NROFLAGS += --icon=$(APP_ICON)
endif
ifeq ($(strip $(NO_NACP)),)
    export NROFLAGS += --nacp=$(CURDIR)/$(TARGET).nacp
endif
ifneq ($(ROMFS),)
    export NROFLAGS += --romfsdir=$(CURDIR)/$(ROMFS)
endif

.PHONY: $(BUILD) clean all

all: $(BUILD)

$(BUILD): $(SRCFILES)
	@[ -d $@ ] || mkdir -p $@
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

clean:
	@echo clean ...
	@rm -fr $(BUILD) $(TARGET).nro $(TARGET).nacp $(TARGET).elf

else
.PHONY: all

DEPENDS := $(OFILES:.o=.d)

#-------------------------------------------------------------------------------
# main targets
#-------------------------------------------------------------------------------
all: $(OUTPUT).nro

$(OUTPUT).nro : $(OUTPUT).elf $(OUTPUT).nacp
$(OUTPUT).elf : $(OFILES)

-include $(DEPENDS)

endif
