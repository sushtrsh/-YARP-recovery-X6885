BOARD_VENDOR_RAMDISK_BOOTSTRAP := true
BOARD_RAMDISK_USE_ZSTD := true

# Compile the MT6789 sepolicy into the recovery policy.
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/common/mt6789-vendor16/sepolicy/private
