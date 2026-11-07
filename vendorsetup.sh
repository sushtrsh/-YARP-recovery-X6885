#!/bin/bash
#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

export ALLOW_MISSING_DEPENDENCIES=true

_had_errexit=0
case "$-" in *e*) _had_errexit=1 ;; esac
set +e

_dev_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ws_root="$(cd "${_dev_dir}/../../.." && pwd)"
_debug_dir="${_ws_root}/patch_debug"

if [ -d "${_ws_root}/external" ] && [ ! -d "${_ws_root}/external/gflags" ]; then
    echo "[X6885] Menyiapkan dependensi external/gflags..."
    git clone https://android.googlesource.com/platform/external/gflags/ -b android-12.1.0_r4 "${_ws_root}/external/gflags" >/dev/null 2>&1 || true
fi

if ! command -v patch >/dev/null 2>&1; then
    echo "[X6885] command 'patch' tidak ada"
    [ "${_had_errexit}" = "1" ] && set -e
    unset _had_errexit
    return 1
fi

_patch_cmd() {
    (cd "${_ws_root}" && patch -p1 --batch --no-backup-if-mismatch "$@" </dev/null)
}

_dump_debug() {
    local _patch="$1" _pname
    _pname="$(basename "${_patch}")"
    mkdir -p "${_debug_dir}/logs" "${_debug_dir}/targets"

    _patch_cmd -N --dry-run -i "${_patch}" > "${_debug_dir}/logs/${_pname}.log" 2>&1
    head -60 "${_debug_dir}/logs/${_pname}.log"

    # Simpan file target asli dari source tree untuk debugging
    grep -E '^\+\+\+ b/' "${_patch}" | sed 's|^+++ b/||' | while read -r _target_file; do
        if [ -f "${_ws_root}/${_target_file}" ]; then
            mkdir -p "$(dirname "${_debug_dir}/targets/${_target_file}")"
            cp -f "${_ws_root}/${_target_file}" "${_debug_dir}/targets/${_target_file}"
            echo "[X6885] Debug target file tersimpan: ${_target_file}"
        else
            echo "[X6885] Target tidak ditemukan di source tree: ${_target_file}"
        fi
    done

    cp -f "${_patch}" "${_debug_dir}/logs/"
}

_failed_patches=""
_applied_count=0
_already_count=0

for _patch in "${_dev_dir}"/patches/*.patch; do
    if [ ! -f "${_patch}" ]; then
        echo "[X6885] tidak ada file patch di ${_dev_dir}/patches"
        break
    fi
    _pname="$(basename "${_patch}")"

    if _patch_cmd -N --dry-run --silent -i "${_patch}" >/dev/null 2>&1; then
        if _patch_cmd -N --silent -i "${_patch}"; then
            echo "[X6885] Applied ${_pname}."
            _applied_count=$((_applied_count + 1))
        else
            echo "[X6885] GAGAL saat apply ${_pname} (lolos dry-run), dilewati."
            _dump_debug "${_patch}"
            _failed_patches="${_failed_patches} ${_pname}"
        fi
    elif _patch_cmd -R --dry-run --silent -i "${_patch}" >/dev/null 2>&1; then
        echo "[X6885] Already applied ${_pname}."
        _already_count=$((_already_count + 1))
    else
        echo "[X6885] Patch tidak cocok dengan source tree: ${_pname}, dilewati."
        _dump_debug "${_patch}"
        _failed_patches="${_failed_patches} ${_pname}"
    fi
done

echo "[X6885] Ringkasan patch: ${_applied_count} baru diterapkan, ${_already_count} sudah terpasang."
if [ -n "${_failed_patches}" ]; then
    echo "[X6885] ==== PATCH GAGAL (dilewati):${_failed_patches} ===="
    mkdir -p "${_debug_dir}"
    for _f in ${_failed_patches}; do echo "${_f}"; done > "${_debug_dir}/FAILED_PATCHES.txt"
    _rc=0
    [ "${X6885_STRICT:-0}" = "1" ] && _rc=1
else
    echo "[X6885] Semua patch berhasil/sudah terpasang."
    _rc=0
fi

unset -f _patch_cmd _dump_debug
unset _dev_dir _ws_root _debug_dir _patch _pname _failed_patches _applied_count _already_count _f
_ret=${_rc}
unset _rc
[ "${_had_errexit}" = "1" ] && set -e
unset _had_errexit
return "${_ret}" 2>/dev/null || exit "${_ret}"
