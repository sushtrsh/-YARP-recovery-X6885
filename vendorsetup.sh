#!/bin/bash
#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

export ALLOW_MISSING_DEPENDENCIES=true

# Terapkan patch build-system (bootstrap vendor ramdisk + zstd). Idempotent.
_dev_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ws_root="$(cd "${_dev_dir}/../../.." && pwd)"
_patch="${_dev_dir}/patches/01-twrp-vendor-ramdisk-bootstrap.patch"
if [[ ! -f "${_patch}" ]] || ! command -v patch >/dev/null 2>&1; then
    echo "[X6885] patch / file patch tidak ada: ${_patch}"
    return 1
fi
if (cd "${_ws_root}" && patch -p1 -N --dry-run --silent < "${_patch}" >/dev/null 2>&1); then
    (cd "${_ws_root}" && patch -p1 -N --silent < "${_patch}") || { echo "[X6885] gagal apply patch"; return 1; }
    echo "[X6885] Applied $(basename "${_patch}")."
elif (cd "${_ws_root}" && patch -p1 -R --dry-run --silent < "${_patch}" >/dev/null 2>&1); then
    echo "[X6885] Already applied $(basename "${_patch}")."
else
    echo "[X6885] Patch tidak cocok dengan source tree:"
    (cd "${_ws_root}" && patch -p1 -N --dry-run -i "${_patch}" </dev/null 2>&1 | head -60)
    return 1
fi
unset _dev_dir _ws_root _patch
