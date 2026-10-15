//
// exynos_smc wrapper around the __exynos_smc SMC trampoline
// (arch/arm64/kernel/exynos-smc.S). Declared in <linux/smc.h>.
//
#include <linux/export.h>
#include <linux/smc.h>

int exynos_smc(unsigned long cmd, unsigned long arg1, unsigned long arg2, unsigned long arg3)
{
	return __exynos_smc(cmd, arg1, arg2, arg3);
}
EXPORT_SYMBOL(exynos_smc);
