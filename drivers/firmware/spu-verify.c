// SPDX-License-Identifier: GPL-2.0
/*
 * SPU firmware signature verification.
 *
 * The s5e3830 platform has no SPU (secure processor) firmware-loading
 * backend ported yet, so verification is reported as unavailable rather
 * than silently trusting the image.
 */

#include <linux/errno.h>
#include <linux/export.h>
#include <linux/printk.h>
#include <linux/types.h>

long spu_firmware_signature_verify(const char *fw_name, const u8 *fw_data,
				   const long fw_size)
{
	pr_err("%s: not supported on this platform (fw %s, size %ld)\n",
	       __func__, fw_name, fw_size);

	return -EOPNOTSUPP;
}
EXPORT_SYMBOL(spu_firmware_signature_verify);
