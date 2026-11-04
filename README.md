# YARP Recovery Project for Infinix X6885

Unofficial TWRP Recovery device tree for Android 16 on the MediaTek MT6789

## Device Information

| Item | Value |
| --- | --- |
| Device | `Infinix X6885` |
| Platform | `MT6789` |
| Architecture | `ARM64` |
| Android Version | `Android 16` |
| SDK Version | `36` |
| Vendor Security Patch | `2026-09-05` |
| Kernel Module ABI | `6.12.38-android16-5-gcc51d883045d-4k` |
| Platform Modules | `234 modules + 5 stock metadata files` |

## Build Instructions (GitHub Actions)

1. Fork / push this repository.
2. Open the **Actions** tab in your repository.
3. Select **TWRP Recovery Build A16**.
4. Click **Run workflow**.
5. Configure the workflow inputs:
   - `MANIFEST_URL`: `https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git`
   - `MANIFEST_BRANCH`: `twrp-16.0`
   - `DEVICE_TREE_URL`: URL to this device tree repository
   - `DEVICE_TREE_BRANCH`: `main`
   - `DEVICE_PATH`: `device/infinix/X6885`
   - `DEVICE_NAME`: `X6885`
   - `MAKEFILE_NAME`: `twrp_X6885`
   - `BUILD_TARGET`: `vendorboot`

## Flashing Instructions

Flash the compiled vendor boot image via fastboot:

```bash
fastboot flash vendor_boot vendor_boot.img
fastboot reboot recovery
```

## Disclaimer

This is an **unofficial device tree**. Builds are provided as-is, without any guarantee of stability or compatibility.

**DWYOR (Do With Your Own Risk).**
Always keep stock backups ready.
