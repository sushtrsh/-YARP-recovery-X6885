#!/bin/bash
#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

export ALLOW_MISSING_DEPENDENCIES=true

_dev_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ws_root="$(cd "${_dev_dir}/../../.." && pwd)"
_debug_dir="${_ws_root}/patch_debug"

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
        _pname="$(basename "${_patch}")"
        echo "[X6885] Patch tidak cocok dengan source tree: ${_pname}"
        
        mkdir -p "${_debug_dir}/logs" "${_debug_dir}/targets"
        
        (cd "${_ws_root}" && patch -p1 -N --dry-run -i "${_patch}" </dev/null > "${_debug_dir}/logs/${_pname}.log" 2>&1)
        cat "${_debug_dir}/logs/${_pname}.log" | head -60

        # Ambil file target asli dari source tree TWRP
        grep -E '^\+\+\+ b/' "${_patch}" | sed 's|^+++ b/||' | while read -r _target_file; do
            if [ -f "${_ws_root}/${_target_file}" ]; then
                _dest="${_debug_dir}/targets/${_target_file}"
                mkdir -p "$(dirname "${_dest}")"
                cp -f "${_ws_root}/${_target_file}" "${_dest}"
                echo "[X6885] Debug target file tersimpan: ${_target_file}"
            fi
        done

        cp -f "${_patch}" "${_debug_dir}/logs/"
        return 1
    fi
done
unset _dev_dir _ws_root _debug_dir _patch _pname _target_file _dest
