#
# Makefile for the fingerprint sensor drivers.
#
ccflags-y := -Wformat

obj-$(CONFIG_SENSORS_FINGERPRINT) += fingerprint.o fingerprint_sysfs.o

fingerprint-$(CONFIG_SENSORS_FINGERPRINT) += fingerprint_common.o
# gw3x e o unico consumidor dos helpers spi_clk_*/cpu_speedup_*; o provedor LSI
# vinha numa config propria (SENSORS_FINGERPRINT_LSI) que nao existe aqui.
fingerprint-$(CONFIG_SENSORS_GW3X) += gw3x_common.o gw3x_spidev.o fingerprint_common_lsi.o
