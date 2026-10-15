/* SPDX-License-Identifier: GPL-2.0 */
#ifndef __ASM_SMCCC_H
#define __ASM_SMCCC_H

#include <linux/const.h>

/*
 * SMCCC specification interface
 * ARM DEN 0028A
 */

/* Function IDs */
#define SMCCC_VERSION			0x80000000
#define SMCCC_ARCH_FEATURES		0x80000001
#define SMCCC_ARCH_SOC_ID		0x80000002
#define SMCCC_ARCH_WORKAROUND_1		0x80008000
#define SMCCC_ARCH_WORKAROUND_2		0x80007FFF

/* Return codes */
#define SMCCC_RET_SUCCESS		0
#define SMCCC_RET_NOT_SUPPORTED		-1
#define SMCCC_RET_NOT_REQUIRED		-2

#ifndef __ASSEMBLY__

#include <linux/types.h>

struct arm_smccc_res {
	unsigned long a0;
	unsigned long a1;
	unsigned long a2;
	unsigned long a3;
};

void arm_smccc_smc(unsigned long a0, unsigned long a1,
		    unsigned long a2, unsigned long a3,
		    unsigned long a4, unsigned long a5,
		    unsigned long a6, unsigned long a7,
		    struct arm_smccc_res *res);

void arm_smccc_hvc(unsigned long a0, unsigned long a1,
		    unsigned long a2, unsigned long a3,
		    unsigned long a4, unsigned long a5,
		    unsigned long a6, unsigned long a7,
		    struct arm_smccc_res *res);

#endif /* __ASSEMBLY__ */
#endif /* __ASM_SMCCC_H */
