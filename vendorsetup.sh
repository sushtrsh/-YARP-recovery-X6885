#!/bin/bash
#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

export ALLOW_MISSING_DEPENDENCIES=true

_dev_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ws_root="$(cd "${_dev_dir}/../../.." && pwd)"


if [ -d "${_ws_root}/external" ] && [ ! -d "${_ws_root}/external/gflags" ]; then
    echo "[X6885] Menyiapkan dependensi external/gflags..."
    git clone https://android.googlesource.com/platform/external/gflags/ -b android-12.1.0_r4 "${_ws_root}/external/gflags" >/dev/null 2>&1 || true
fi

if ! command -v patch >/dev/null 2>&1; then
    echo "[X6885] command 'patch' tidak ada"
    return 1
fi
for _patch in "${_dev_dir}"/patches/*.patch; do
    [[ -f "${_patch}" ]] || { echo "[X6885] tidak ada file patch di ${_dev_dir}/patches"; return 1; }
    if (cd "${_ws_root}" && patch -p1 -N --dry-run --silent < "${_patch}" >/dev/null 2>&1); then
        (cd "${_ws_root}" && patch -p1 -N --silent < "${_patch}") || { echo "[X6885] gagal apply $(basename "${_patch}")"; return 1; }
        echo "[X6885] Applied $(basename "${_patch}")."
    elif (cd "${_ws_root}" && patch -p1 -R --dry-run --silent < "${_patch}" >/dev/null 2>&1); then
        echo "[X6885] Already applied $(basename "${_patch}")."
    else
        echo "[X6885] Patch tidak cocok dengan source tree: $(basename "${_patch}")"
        (cd "${_ws_root}" && patch -p1 -N --dry-run -i "${_patch}" </dev/null 2>&1 | head -60)
        return 1
    fi
done
unset _dev_dir _ws_root _patch
