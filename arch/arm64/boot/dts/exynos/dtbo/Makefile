
ifeq ($(CONFIG_SOC_EXYNOS7885_ANDROID_VERSION_P),y)
dtb-y += exynos7885.dtb
endif

ifeq ($(CONFIG_SOC_EXYNOS7885_ANDROID_VERSION_P),y)
dtb-$(CONFIG_MACH_EXYNOS7885_A10_OPEN) := \
	exynos7884B-a10_eur_open_00.dtbo \
	exynos7884B-a10_eur_open_01.dtbo \
	exynos7884B-a10_kor_open_00.dtbo \
	exynos7884B-a10_kor_open_03.dtbo \
	exynos7884B-a10_kor_open_05.dtbo \
	exynos7884B-a10_sea_open_00.dtbo \
	exynos7884B-a10_swa_open_00.dtbo
endif

ifeq ($(CONFIG_SOC_EXYNOS7885_ANDROID_VERSION_P),y)
always         := $(dtb-y) $(dtbo-y)
subdir-y       := $(dts-dirs)
clean-files    := *.dtb *.dtbo
endif

