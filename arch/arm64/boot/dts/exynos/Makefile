dtb-$(CONFIG_ARCH_EXYNOS7) += exynos7-espresso.dtb

ifeq ($(CONFIG_SOC_EXYNOS7885_ANDROID_VERSION_P),y)
dts-dirs := dtbo
endif

ifeq ($(CONFIG_SOC_EXYNOS7885_ANDROID_VERSION_P),y)
always		:= $(dtb-y) $(dtbo-y)
subdir-y	:= $(dts-dirs)
clean-files	:= *.dtb *.dtbo
endif

