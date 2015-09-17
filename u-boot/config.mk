#
# (C) Copyright 2000
# Wolfgang Denk, DENX Software Engineering, wd@denx.de.
#
# See file CREDITS for list of people who contributed to this
# project.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#

#########################################################################

#export	ARCH CPU BOARD VENDOR SOC

# clean the slate ...
#���������ͬ�ı�ǣ�������õ�
PLATFORM_RELFLAGS =
PLATFORM_CPPFLAGS =
PLATFORM_LDFLAGS =

#
# When cross-compiling on NetBSD, we have to define __PPC__ or else we
# will pick up a va_list declaration that is incompatible with the
# actual argument lists emitted by the compiler.
#
# [Tested on NetBSD/i386 1.5 + cross-powerpc-netbsd-1.3]

ifeq ($(ARCH),ppc)
ifeq ($(CROSS_COMPILE),powerpc-netbsd-)
PLATFORM_CPPFLAGS+= -D__PPC__
endif
ifeq ($(CROSS_COMPILE),powerpc-openbsd-)
PLATFORM_CPPFLAGS+= -D__PPC__
endif
endif

ifeq ($(ARCH),arm)
ifeq ($(CROSS_COMPILE),powerpc-netbsd-)
PLATFORM_CPPFLAGS+= -D__ARM__
endif
ifeq ($(CROSS_COMPILE),powerpc-openbsd-)
PLATFORM_CPPFLAGS+= -D__ARM__
endif
endif

ifeq ($(ARCH),blackfin)
PLATFORM_CPPFLAGS+= -D__BLACKFIN__ -mno-underscore
endif

ifdef	ARCH
#PLATFORM_CPPFLAGS += -DCONFIG_MIPS -D__MIPS__
#u-boot/mips_config.mk 
sinclude $(TOPDIR)/$(ARCH)_config.mk	# include architecture dependend rules
endif

#���¶�����
ifdef	CPU
#CPU = mips u-boot/cpu/mips/config.mk
sinclude $(TOPDIR)/cpu/$(CPU)/config.mk	# include  CPU	specific rules
endif
ifdef	SOC
#SOC = ar7240 u-boot/cpu/mips/ar7240/config.mk ������
sinclude $(TOPDIR)/cpu/$(CPU)/$(SOC)/config.mk	# include  SoC	specific rules
endif
ifdef	VENDOR
# VENDOR = ar7240
# BOARD = ap121
# BOARDDIR = ar7240/ap121
BOARDDIR = $(VENDOR)/$(BOARD)
else
BOARDDIR = $(BOARD)
endif
ifdef	BOARD
# u-boot/board/ar7240/ap121/config.mk
sinclude $(TOPDIR)/board/$(BOARDDIR)/config.mk	# include board specific rules
endif

#########################################################################
#export	ARCH CPU BOARD VENDOR SOC
# ARCH   = mips
# CPU    = mips
# BOARD  = ap121
# VENDOR = ar7240
# SOC    = ar7240
# u-boot/mips_config.mk 
# u-boot/cpu/mips/config.mk
# u-boot/cpu/mips/ar7240/config.mk ������
# u-boot/board/ar7240/ap121/config.mk
# BOARDDIR = ar7240/ap121
#########################################################################

#shell�����ж�
# CONFIG_SHELL = sh
CONFIG_SHELL	:= $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
		    else if [ -x /bin/bash ]; then echo /bin/bash; \
		    else echo sh; fi ; fi)

#$(HOSTOS)-$(HOSTARCH) = linux-i686
ifeq ($(HOSTOS)-$(HOSTARCH),darwin-ppc)
HOSTCC		= cc
else
HOSTCC		= gcc
endif

# -Wall ��ʹ�����о��档
# -ansi ��ʹ��c++98��׼ȥ�������
# -O2 �Ǵ򿪵ڶ������Ż�
# -o test ��˵���Ϊtest
# -Wstrict-prototypesʹ���˷�ԭ�͵ĺ�������ʱ��������  
# -fomit-frame-pointer��ȥ���������
HOSTCFLAGS	= -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer

#strip��������ȥ��Ŀ���ļ��е�һЩ���ű����Է��ű���Ϣ,�Լ�С����Ĵ�С
HOSTSTRIP	= strip

COMPRESS    = lzma
#########################################################################
#
# Option checker (courtesy linux kernel) to ensure
# only supported compiler options are used
#
# CC = mips-linux-gcc
# CFLAGS  = -O -D__KERNEL__ -I./u-boot/include-fno-builtin -ffreestanding -nostdinc -isystem mips-linux-gcc -print-file-name=include -pipe -DCONFIG_MIPS -D__MIPS__ -Wall -Wstrict-prototypes 
# �������д���������£�
# if $(CC) $(CFLAGS) $(1) -S -o /dev/null -xc /dev/null > /dev/null 2>&1;then
# 	echo "$(1)";
# else
# 	echo "$(2)";
# fi;
# ���Կ�������һ�������������CC�Ǳ�����������CFLAGS�Ǳ���ѡ�����ѡ��
# 	-S����������������������л��Ȳ�����
# 	-o /dev/null : �����ļ���/dev/null�����������κα�����,Ҫ������ļ�ҲΪ�ա�
# 	-xc: ָ����c���Ա���
# ���ô�����磺call cc-option,-a,-b �����֧��-aѡ���򷵻�-a���򷵻�-b��
cc-option = $(shell if $(CC) $(CFLAGS) $(1) -S -o /dev/null -xc /dev/null \
		> /dev/null 2>&1; then echo "$(1)"; else echo "$(2)"; fi ;)

#
# Include the make variables (CC, etc...)
#
AS	= $(CROSS_COMPILE)as
LD	= $(CROSS_COMPILE)ld
CC	= $(CROSS_COMPILE)gcc
CPP	= $(CC) -E
AR	= $(CROSS_COMPILE)ar
NM	= $(CROSS_COMPILE)nm
STRIP	= $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
RANLIB	= $(CROSS_COMPILE)RANLIB

# CROSS_COMPILE = mips-linux-
# �����޸�һ��ͷ�ļ�ʱ�� �������°����е�Դ�ļ�������һ�Σ� ʹ��depend ,�Ϳ�ֻ���������ͷ�ļ���Դ�ļ�
.depend : CC = @$(CROSS_COMPILE)gcc

RELFLAGS= $(PLATFORM_RELFLAGS)

#-fomit-frame-pointer
OPTFLAGS= -O

ifndef LDSCRIPT
# LDSCRIPT = u-boot/board/ar7240/ap121/u-boot.lds
LDSCRIPT := $(TOPDIR)/board/$(BOARDDIR)/u-boot.lds
endif

#��֮��Ŀ�϶��0xff���
OBJCFLAGS += --gap-fill=0xff

LDSCRIPT_BOOTSTRAP := $(TOPDIR)/board/$(BOARDDIR)/u-boot-bootstrap.lds

#��������include·��
gccincdir := $(shell $(CC) -print-file-name=include)

#�˱����ۺ���DBGFLAGS��OPTFLAGS��RELFLAGS����ѡ���������__KERBEL__
#������TEXT_BASE����
#���include����·��
#-fno-builtin �����ܲ��������»��ߵ��ڽ�����
#-ffreestanding ��������������
#-nostdinc	��Ҫ�ڱ�׼ϵͳĿ¼��Ѱ��ͷ�ļ� ֻ��-Iָ����Ŀ¼������
#-isystem ָ��ϵͳĿ¼
#-pipe	�ڱ���Ĳ�ͬ�׶�ʹ�ùܵ�ͨѶ
#$(PLATFORM_CPPFLAGS)	���
CPPFLAGS := $(DBGFLAGS) $(OPTFLAGS) $(RELFLAGS)		\
	-D__KERNEL__ -DTEXT_BASE=$(TEXT_BASE)		\
	-I$(TOPDIR)/include				\
	-fno-builtin -ffreestanding -nostdinc -isystem	\
	$(gccincdir) -pipe $(PLATFORM_CPPFLAGS)

#-Wstrict-prototypes�����������������û�и������������򾯸�
ifdef BUILD_TAG
CFLAGS := $(CPPFLAGS) -Wall -Wstrict-prototypes \
	-DBUILD_TAG='"$(BUILD_TAG)"'
else
CFLAGS := $(CPPFLAGS) -Wall -Wstrict-prototypes
ifeq ($(COMPRESSED_UBOOT),1)
CFLAGS += -DCOMPRESSED_UBOOT=1
else
CFLAGS += -DCOMPRESSED_UBOOT=0
endif

ifeq ($(BUILD_OPTIMIZED),y)
CFLAGS += -Os -funit-at-a-time -mips32r2 -mtune=mips32r2
endif
endif

ifeq ($(BUILD_TYPE),jffs2)
CFLAGS += -DROOTFS=1
else
ifeq ($(BUILD_TYPE),squashfs)
CFLAGS += -DROOTFS=2
endif
endif

# avoid trigraph warnings while parsing pci.h (produced by NIOS gcc-2.9)
# this option have to be placed behind -Wall -- that's why it is here
ifeq ($(ARCH),nios)
ifeq ($(findstring 2.9,$(shell $(CC) --version)),2.9)
CFLAGS := $(CPPFLAGS) -Wall -Wno-trigraphs
endif
endif

ifeq ($(BUILD_TYPE),jffs2)
CFLAGS += -DROOTFS=1
else
ifeq ($(BUILD_TYPE),squashfs)
CFLAGS += -DROOTFS=2
endif
endif

AFLAGS_DEBUG := -Wa,-gstabs

AFLAGS := $(AFLAGS_DEBUG) -D__ASSEMBLY__ $(CPPFLAGS)
ifeq ($(COMPRESSED_UBOOT),1)
AFLAGS += -DCOMPRESSED_UBOOT=1
else
AFLAGS += -DCOMPRESSED_UBOOT=0
endif

#-Bstatic��̬���� ʹ��u-boot.lds���������ļ������ļ���LDSCRIPT���������·�����ƹ�����
#��������ʱ���ڴ��ַ
LDFLAGS += -Bstatic -T $(LDSCRIPT) -Ttext $(TEXT_BASE) $(PLATFORM_LDFLAGS)

ifeq ($(COMPRESSED_UBOOT), 1)
LDFLAGS_BOOTSTRAP += -Bstatic -T $(LDSCRIPT_BOOTSTRAP) -Ttext $(BOOTSTRAP_TEXT_BASE) $(PLATFORM_LDFLAGS)
endif

# Location of a usable BFD library, where we define "usable" as
# "built for ${HOST}, supports ${TARGET}".  Sensible values are
# - When cross-compiling: the root of the cross-environment
# - Linux/ppc (native): /usr
# - NetBSD/ppc (native): you lose ... (must extract these from the
#   binutils build directory, plus the native and U-Boot include
#   files don't like each other)
#
# So far, this is used only by tools/gdb/Makefile.

ifeq ($(HOSTOS)-$(HOSTARCH),darwin-ppc)
BFD_ROOT_DIR =		/usr/local/tools
else
ifeq ($(HOSTARCH),$(ARCH))
# native
BFD_ROOT_DIR =		/usr
else
#BFD_ROOT_DIR =		/LinuxPPC/CDK		# Linux/i386
#BFD_ROOT_DIR =		/usr/pkg/cross		# NetBSD/i386
BFD_ROOT_DIR =		/opt/powerpc
endif
endif

ifeq ($(PCI_CLOCK),PCI_66M)
CFLAGS := $(CFLAGS) -DPCI_66M
endif

#CFLAGS += $(UBOOT_GCC_4_3_3_EXTRA_CFLAGS) -g
CFLAGS += $(UBOOT_GCC_4_3_3_EXTRA_CFLAGS)

#########################################################################

export	CONFIG_SHELL HPATH HOSTCC HOSTCFLAGS CROSS_COMPILE \
	AS LD CC CPP AR NM STRIP OBJCOPY OBJDUMP \
	MAKE
export	TEXT_BASE PLATFORM_CPPFLAGS PLATFORM_RELFLAGS CPPFLAGS CFLAGS AFLAGS

#V = 1
ifeq ($(V),1)
  Q =
else
  Q = @
endif

# Q = (NULL)
# V = 1
export quiet Q V

#########################################################################

#���漸�й涨�˸����ļ��ı���ʱ�õ��ı���ѡ�
#ģʽƥ��
#CPPΪԤ����ѡ��,����ҪԤ�����.S����ļ�����ɲ���ҪԤ�����.s�ļ�
#$(CURDIR)�˱������� make �Ĺ���Ŀ¼
#$<Ϊ��������
%.s:	%.S
ifneq ($(V),1)
	@echo [CPP] $(CURDIR)/$<
endif
	$(Q)$(CPP) $(AFLAGS) -o $@ $(CURDIR)/$<

%.o:	%.S
ifneq ($(V),1)
	@echo [CC] $(CURDIR)/$<
endif
	$(Q)$(CC) $(AFLAGS) -c -o $@ $(CURDIR)/$<

%.o:	%.c
ifneq ($(V),1)
	@echo [CC] $(CURDIR)/$<
endif
	$(Q)$(CC) $(CFLAGS) -c -o $@ $<

#########################################################################
