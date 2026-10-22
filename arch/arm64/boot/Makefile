#
# arch/arm64/boot/Makefile
#
# This file is included by the global makefile so that you can add your own
# architecture-specific flags and dependencies.
#
# This file is subject to the terms and conditions of the GNU General Public
# License.  See the file "COPYING" in the main directory of this archive
# for more details.
#
# Copyright (C) 2012, ARM Ltd.
# Author: Will Deacon <will.deacon@arm.com>
#
# Based on the ia64 boot/Makefile.
#

OBJCOPYFLAGS_Image :=-O binary -R .note -R .note.gnu.build-id -R .comment -S

targets := Image Image.bz2 Image.gz Image.lz4 Image.lzma Image.lzo
targets += dtb.img dtbo.img

# Device trees to build.  SUBDIRS selects which subdirectory of
# arch/arm64/boot/dts/ to pack, so "make SUBDIRS=samsung/a12s dtbo.img"
# produces an image with only that board's overlays.  Without SUBDIRS every
# entry of the dts Makefile is packed, matching what "make dtbs" builds.
dtsmakefile := $(srctree)/arch/arm64/boot/dts/Makefile
dtstree := $(srctree)/arch/arm64/boot/dts
SUBDIRS ?=
list_dts = $(shell awk -v prefix="$(SUBDIRS)/" -v var="$(1)" \
	'$$1 == var && $$2 == "+=" && (prefix == "/" || index($$3, prefix) == 1) { print $$3 }' \
	$(dtsmakefile))

DTB_LIST  ?= $(call list_dts,dtb-y)
DTBO_LIST ?= $(call list_dts,dtbo-y)
DTB_OBJS  := $(addprefix $(dtstree)/, $(DTB_LIST))
DTBO_OBJS := $(addprefix $(dtstree)/, $(DTBO_LIST))
DTBO_PAGE_SIZE ?= 4096

$(obj)/Image: vmlinux FORCE
	$(call if_changed,objcopy)

$(obj)/Image.bz2: $(obj)/Image FORCE
	$(call if_changed,bzip2)

$(obj)/Image.gz: $(obj)/Image FORCE
	$(call if_changed,gzip)

$(obj)/Image.lz4: $(obj)/Image FORCE
	$(call if_changed,lz4)

$(obj)/Image.lzma: $(obj)/Image FORCE
	$(call if_changed,lzma)

$(obj)/Image.lzo: $(obj)/Image FORCE
	$(call if_changed,lzo)

$(obj)/dtb.img: $(DTB_OBJS) FORCE
	$(call if_changed,cat)

$(obj)/dtbo.img: $(DTBO_OBJS) FORCE
	$(call if_changed,mkdtboimg)

install:
	$(CONFIG_SHELL) $(srctree)/$(src)/install.sh $(KERNELRELEASE) \
	$(obj)/Image System.map "$(INSTALL_PATH)"

zinstall:
	$(CONFIG_SHELL) $(srctree)/$(src)/install.sh $(KERNELRELEASE) \
	$(obj)/Image.gz System.map "$(INSTALL_PATH)"
