#
# Copyright (c) 2013 Samsung Electronics Co., Ltd.
#		http://www.samsung.com
#
# Licensed under GPLv2
#

obj-$(CONFIG_EXYNOS_DPU30) += mcd-panel.o

mcd-panel-y += mcd_panel_register.o
mcd-panel-$(CONFIG_EXYNOS_MIPI_DSIM) += timenval.o panel.o panel_bl.o dimming.o panel_drv.o panel_irc.o decon_board.o decon_notify.o decon_void_regulator.o decon_assist.o
mcd-panel-$(and $(CONFIG_SMCDSD_LCD_DEBUG),$(subst undefined,y,$(origin CONFIG_SAMSUNG_PRODUCT_SHIP))) += dd_lcd.o dd_backlight.o dd_param.o dd_assist.o
mcd-panel-$(CONFIG_EXYNOS_DECON_MDNIE) += mdnie.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_SYSFS) += sysfs.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_SPI) += spi.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_COPR) += copr.o
mcd-panel-$(CONFIG_DISPLAY_USE_INFO) += dpui.o
mcd-panel-$(CONFIG_PANEL_NOTIFY) += panel_notify.o
mcd-panel-$(CONFIG_SUPPORT_DDI_FLASH) += panel_poc.o
mcd-panel-$(CONFIG_EXTEND_LIVE_CLOCK) += aod/aod_drv.o
mcd-panel-$(CONFIG_SUPPORT_POC_SPI) += panel_spi.o
mcd-panel-$(CONFIG_SUPPORT_I2C) += panel_i2c.o
mcd-panel-$(CONFIG_DYNAMIC_FREQ) += df/dynamic_freq.o

mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_DUMMY_LCD_V320) += dummy_lcd/dummy_lcd.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_NT36525B_CTC_A12S) += nt36525b_ctc/nt36525b_ctc.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_ILI9882Q_BOE_A12S) += ili9882q_boe/ili9882q_boe.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_NT36525B_SHARP_A12S) += nt36525b_sharp/nt36525b_sharp.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_NT36525B_DTC_A12S) += nt36525b_dtc/nt36525b_dtc.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_TD4150_BOE_A12S) += td4150_boe/td4150_boe.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_TD4375_BOE_A12S) += td4375_boe/td4375_boe.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_ILI7807S_A12S) += ili7807s/ili7807s.o
mcd-panel-$(CONFIG_EXYNOS_DECON_LCD_TD4160_BOE_A12S) += td4160_boe/td4160_boe.o