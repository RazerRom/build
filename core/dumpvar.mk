# ---------------------------------------------------------------
# the setpath shell function in envsetup.sh uses this to figure out
# what to add to the path given the config we have chosen.
ifeq ($(CALLED_FROM_SETUP),true)

ifneq ($(filter /%,$(HOST_OUT_EXECUTABLES)),)
ABP:=$(HOST_OUT_EXECUTABLES)
else
ABP:=$(PWD)/$(HOST_OUT_EXECUTABLES)
endif

ANDROID_BUILD_PATHS := $(ABP)
ANDROID_PREBUILTS := prebuilt/$(HOST_PREBUILT_TAG)
ANDROID_GCC_PREBUILTS := prebuilts/gcc/$(HOST_PREBUILT_TAG)

# The "dumpvar" stuff lets you say something like
#
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-TARGET_OUT
# or
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-abs-HOST_OUT_EXECUTABLES
#
# The plain (non-abs) version just dumps the value of the named variable.
# The "abs" version will treat the variable as a path, and dumps an
# absolute path to it.
#
dumpvar_goals := \
	$(strip $(patsubst dumpvar-%,%,$(filter dumpvar-%,$(MAKECMDGOALS))))
ifdef dumpvar_goals

  ifneq ($(words $(dumpvar_goals)),1)
    $(error Only one "dumpvar-" goal allowed. Saw "$(MAKECMDGOALS)")
  endif

  # If the goal is of the form "dumpvar-abs-VARNAME", then
  # treat VARNAME as a path and return the absolute path to it.
  absolute_dumpvar := $(strip $(filter abs-%,$(dumpvar_goals)))
  ifdef absolute_dumpvar
    dumpvar_goals := $(patsubst abs-%,%,$(dumpvar_goals))
    ifneq ($(filter /%,$($(dumpvar_goals))),)
      DUMPVAR_VALUE := $($(dumpvar_goals))
    else
      DUMPVAR_VALUE := $(PWD)/$($(dumpvar_goals))
    endif
    dumpvar_target := dumpvar-abs-$(dumpvar_goals)
  else
    DUMPVAR_VALUE := $($(dumpvar_goals))
    dumpvar_target := dumpvar-$(dumpvar_goals)
  endif

.PHONY: $(dumpvar_target)
$(dumpvar_target):
	@echo $(DUMPVAR_VALUE)

endif # dumpvar_goals

ifneq ($(dumpvar_goals),report_config)
PRINT_BUILD_CONFIG:=
endif

endif # CALLED_FROM_SETUP


ifneq ($(PRINT_BUILD_CONFIG),)
HOST_OS_EXTRA:=$(shell python -c "import platform; print(platform.platform())")
$(info ============================================)
$(info   PLATFORM_VERSION_CODENAME=$(PLATFORM_VERSION_CODENAME))
$(info   PLATFORM_VERSION=$(PLATFORM_VERSION))
$(info   BLISS_VERSION=$(BLISS_VERSION))
$(info   TARGET_PRODUCT=$(TARGET_PRODUCT))
$(info   TARGET_BUILD_VARIANT=$(TARGET_BUILD_VARIANT))
$(info   TARGET_BUILD_TYPE=$(TARGET_BUILD_TYPE))
$(info   TARGET_BUILD_APPS=$(TARGET_BUILD_APPS))
$(info   TARGET_ARCH=$(TARGET_ARCH))
$(info   TARGET_ARCH_VARIANT=$(TARGET_ARCH_VARIANT))
$(info   TARGET_CPU_VARIANT=$(TARGET_CPU_VARIANT))
# Rom ToolChain
ifdef TARGET_GCC_VERSION
$(info   TARGET_GCC_VERSION=$(TARGET_GCC_VERSION))
else
$(info   TARGET_GCC_VERSION=4.8)
endif
# Kernel ToolChain
ifdef TARGET_GCC_VERSION_ARM
$(info   TARGET_KERNEL_TOOLCHAIN=$(TARGET_GCC_VERSION_ARM))
else
$(info   TARGET_KERNEL_TOOLCHAIN=$(TARGET_GCC_VERSION))
endif
$(info   BUILD_ID=$(BUILD_ID))
$(info   HOST_ARCH=$(HOST_ARCH))
$(info   HOST_OS=$(HOST_OS))
$(info   HOST_OS_EXTRA=$(HOST_OS_EXTRA))
$(info   HOST_BUILD_TYPE=$(HOST_BUILD_TYPE))
$(info   HOST_CC=$(HOST_CC))
$(info   HOST_OUT_EXECUTABLES=$(HOST_OUT_EXECUTABLES))
$(info   OUT_DIR=$(OUT_DIR))

# BlissRom Flags Start #
ifdef BLISS_BUILD_BLOCK
$(info   BLISS_BUILD_BLOCK=$(BLISS_BUILD_BLOCK))
else
$(info   BLISS_BUILD_BLOCK=false)
endif
ifdef BLISS_WIPE_CACHES
$(info   BLISS_WIPE_CACHES=$(BLISS_WIPE_CACHES))
else
$(info   BLISS_WIPE_CACHES=false)
endif
ifdef O3_FLAGS
$(info   O3_FLAGS=$(USE_O3_OPTIMIZATIONS))
else
$(info   O3_FLAGS=false)
endif
ifdef STRICT_ALIASING
$(info   STRICT_ALIASING=$(STRICT_ALIASING))
else
$(info   STRICT_ALIASING=false)
endif
ifdef ENABLE_GCCONLY
$(info   ENABLE_GCCONLY=$(ENABLE_GCCONLY))
else
$(info   ENABLE_GCCONLY=false)
endif
ifdef FLOOP_NEST_OPTIMIZE
$(info   FLOOP_NEST_OPTIMIZE=$(FLOOP_NEST_OPTIMIZE))
else
$(info   FLOOP_NEST_OPTIMIZE=false)
endif
ifdef GRAPHITE_OPTS
$(info   GRAPHITE_OPTS=$(GRAPHITE_OPTS))
else
$(info   GRAPHITE_OPTS=false)
endif
ifdef KRAIT_TUNINGS
$(info   KRAIT_TUNINGS=$(KRAIT_TUNINGS))
else
$(info   KRAIT_TUNINGS=false)
endif
ifdef FFAST_MATH
$(info   FFAST_MATH=$(FFAST_MATH))
else
$(info   FFAST_MATH=false)
endif
# BlissRom Flags End #

# SaberMod Flags Start #
#ifneq (,$(GCC_OPTIMIZATION_LEVELS))
#$(info   SM_AND_VERSION=$(SM_AND_VERSION))
#$(info   SM_KERNEL_VERSION=$(SM_KERNEL_VERSION))
#ADDITIONAL_BUILD_PROPERTIES += \
#    ro.sm.android=$(SM_AND_VERSION) \
#    ro.sm.kernel=$(SM_KERNEL_VERSION) \
#    ro.sm.flags=$(GCC_OPTIMIZATION_LEVELS)
#endif
# SaberMod Flags End #

$(info ============================================)
endif
