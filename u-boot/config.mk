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
#清除三个不同的标记，下面会用到
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

#以下都存在
ifdef	CPU
#CPU = mips u-boot/cpu/mips/config.mk
sinclude $(TOPDIR)/cpu/$(CPU)/config.mk	# include  CPU	specific rules
endif
ifdef	SOC
#SOC = ar7240 u-boot/cpu/mips/ar7240/config.mk 不存在
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
# u-boot/cpu/mips/ar7240/config.mk 不存在
# u-boot/board/ar7240/ap121/config.mk
# BOARDDIR = ar7240/ap121
#########################################################################

#shell环境判断
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

# -Wall 是使能所有警告。
# -ansi 是使用c++98标准去编译代码
# -O2 是打开第二级的优化
# -o test 是说输出为test
# -Wstrict-prototypes使用了非原型的函数声明时给出警告  
# -fomit-frame-pointer　去除函数框架
HOSTCFLAGS	= -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer

#strip经常用来去除目标文件中的一些符号表、调试符号表信息,以减小程序的大小
HOSTSTRIP	= strip

COMPRESS    = lzma
#########################################################################
#
# Option checker (courtesy linux kernel) to ensure
# only supported compiler options are used
#
# CC = mips-linux-gcc
# CFLAGS  = -O -D__KERNEL__ -I./u-boot/include-fno-builtin -ffreestanding -nostdinc -isystem mips-linux-gcc -print-file-name=include -pipe -DCONFIG_MIPS -D__MIPS__ -Wall -Wstrict-prototypes 
# 这条语句写整齐了如下：
# if $(CC) $(CFLAGS) $(1) -S -o /dev/null -xc /dev/null > /dev/null 2>&1;then
# 	echo "$(1)";
# else
# 	echo "$(2)";
# fi;
# 可以看出这是一条编译命令，变量CC是编译器，变量CFLAGS是编译选项，其中选项
# 	-S：编译后立即结束，不进行汇编等操作。
# 	-o /dev/null : 生成文件到/dev/null，即不生成任何编译结果,要编译的文件也为空。
# 	-xc: 指定按c语言编译
# 调用此语句如：call cc-option,-a,-b 则如果支持-a选项则返回-a否则返回-b。
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
# 则当你修改一个头文件时， 必须重新把所有的源文件都编译一次， 使用depend ,就可只编译包含此头文件的源文件
.depend : CC = @$(CROSS_COMPILE)gcc

RELFLAGS= $(PLATFORM_RELFLAGS)

#-fomit-frame-pointer
OPTFLAGS= -O

ifndef LDSCRIPT
# LDSCRIPT = u-boot/board/ar7240/ap121/u-boot.lds
LDSCRIPT := $(TOPDIR)/board/$(BOARDDIR)/u-boot.lds
endif

#段之间的空隙用0xff填充
OBJCFLAGS += --gap-fill=0xff

LDSCRIPT_BOOTSTRAP := $(TOPDIR)/board/$(BOARDDIR)/u-boot-bootstrap.lds

#编译器的include路径
gccincdir := $(shell $(CC) -print-file-name=include)

#此变量综合了DBGFLAGS，OPTFLAGS，RELFLAGS编译选项，并定义了__KERBEL__
#定义了TEXT_BASE变量
#添加include搜索路径
#-fno-builtin 不接受不是两个下划线的内建函数
#-ffreestanding 安独立环境编译
#-nostdinc	不要在标准系统目录中寻找头文件 只在-I指定的目录中搜索
#-isystem 指定系统目录
#-pipe	在编译的不同阶段使用管道通讯
#$(PLATFORM_CPPFLAGS)	添加
CPPFLAGS := $(DBGFLAGS) $(OPTFLAGS) $(RELFLAGS)		\
	-D__KERNEL__ -DTEXT_BASE=$(TEXT_BASE)		\
	-I$(TOPDIR)/include				\
	-fno-builtin -ffreestanding -nostdinc -isystem	\
	$(gccincdir) -pipe $(PLATFORM_CPPFLAGS)

#-Wstrict-prototypes如果函数的声明或定义没有给出参数类型则警告
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

#-Bstatic静态编译 使用u-boot.lds连接描述文件，此文件是LDSCRIPT变量保存的路径复制过来的
#连接运行时的内存地址
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

#下面几行规定了各种文件的编译时用到的编译选项：
#模式匹配
#CPP为预编译选项,将需要预编译的.S汇编文件编译成不需要预编译的.s文件
#$(CURDIR)此变量代表 make 的工作目录
#$<为规则依赖
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
