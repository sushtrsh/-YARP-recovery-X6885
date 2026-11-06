#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/infinix/X6885

# Configure base.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Configure core_64_bit_only.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Configure emulated_storage.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Configure virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

ENABLE_VIRTUAL_AB := true
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    init_boot \
    lk \
    odm \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm

# Kernel
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false
PRODUCT_ENABLE_UFFD_GC := true

# Dynamic Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := false
PRODUCT_BUILD_SUPER_EMPTY_IMAGE := false

# API
PRODUCT_SHIPPING_API_LEVEL := 34
PRODUCT_TARGET_VNDK_VERSION := 34

# Vendor Properties
PRODUCT_VENDOR_PROPERTIES += \
    ro.twrp.vendor_boot=true

PRODUCT_PACKAGES_DEBUG += \
    bootctl

# FastbootD
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    android.hardware.fastboot@1.0-impl-mock.recovery \
    fastbootd

# Health HAL
PRODUCT_PACKAGES += \
    android.hardware.health-service.example \
    android.hardware.health-service.example_recovery

# Security
PRODUCT_PACKAGES += \
    android.hardware.security.rkp-V3-ndk \
    android.hardware.security.secureclock-V1-ndk \
    android.hardware.security.sharedsecret-V1-ndk

# Keystore2
PRODUCT_PACKAGES += \
    android.system.keystore2

# Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper-V1-ndk

# Keymint
PRODUCT_PACKAGES += \
    android.hardware.security.keymint-V3-ndk

# create_pl_dev
PRODUCT_PACKAGES += \
    create_pl_dev \
    create_pl_dev.recovery

# Update engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

# Wi-Fi Packages (TWRP recovery variant without AIDL)
PRODUCT_PACKAGES += \
    wpa_supplicant_recovery \
    wpa_cli_recovery

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/system/etc/wifi/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf

# Stock modules live only in PLATFORM; they are available in both boot modes.
MTK_VENDOR16_RAMDISK_MODULES_DIR := $(DEVICE_PATH)/prebuilt/modules
MTK_VENDOR16_RAMDISK_FSTABS := $(DEVICE_PATH)/recovery/root/first_stage_ramdisk/fstab.mt6789
$(call inherit-product, $(DEVICE_PATH)/common/mt6789-vendor16/vendor_ramdisk.mk)
