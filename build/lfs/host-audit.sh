#!/usr/bin/env bash
# NEO-OS / LFS host readiness report (read-only, no sudo required).
# This is an inventory, NOT an official LFS host compliance checker.
set -u

target_dir="${1:-.}"
if [[ ! -d "$target_dir" ]]; then
  printf 'ERROR: directory not found: %s\n' "$target_dir" >&2
  exit 2
fi

section() { printf '\n== %s ==\n' "$1"; }
readout() {
  local label="$1" cmd="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '%-22s %s\n' "$label" "$(command -v "$cmd")"
  else
    printf '%-22s %s\n' "$label" 'MISSING'
  fi
}

printf 'NEO-OS LFS host readiness inventory\n'
printf 'READ-ONLY. No changes made. This is not LFS certification.\n'
printf 'Run against a directory on the filesystem you intend to use for builds.\n'

section "Host identity"
if command -v uname >/dev/null 2>&1; then
  printf 'Kernel: '; uname -sr
  printf 'Architecture: '; uname -m
fi
if [[ -r /etc/os-release ]]; then
  # Read OS release as inert data; never source an untrusted shell script.
  grep -E '^(PRETTY_NAME|NAME|VERSION_ID)=' /etc/os-release || true
fi

section "CPU and memory"
if command -v nproc >/dev/null 2>&1; then
  printf 'Visible logical processors: '; nproc
fi
if command -v free >/dev/null 2>&1; then
  free -h
elif [[ -r /proc/meminfo ]]; then
  grep -m 1 '^MemTotal:' /proc/meminfo
fi

section "Disk availability at chosen build path"
printf 'Directory: %s\n' "$target_dir"
if command -v df >/dev/null 2>&1; then
  df -h -- "$target_dir"
fi
printf 'No disk partitioning or filesystem changes are performed.\n'

section "Build tools (presence only)"
# Versions and compatibility must be assessed against the exact LFS book!
for tool in bash as ld bison bzip2 chown coreutils diff find gawk gcc g++ grep gzip m4 make patch perl python3 sed tar texi2any xz; do
  readout "$tool" "$tool"
done
printf '\nAdditional useful tools:\n'
for tool in git cmake ninja qemu-system-x86_64 qemu-img kvm-ok; do
  readout "$tool" "$tool"
done

section "Selected tool versions"
for tool in bash as ld bison gcc g++ make python3 tar xz; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%-12s' "$tool"
    "$tool" --version 2>/dev/null | head -n 1 || true
  fi
done

section "Virtualization"
if [[ -e /dev/kvm ]]; then
  if [[ -r /dev/kvm && -w /dev/kvm ]]; then
    printf '/dev/kvm: present and accessible to this user\n'
  else
    printf '/dev/kvm: present but current user cannot access (or permissions limited)\n'
  fi
else
  printf '/dev/kvm: absent; QEMU software emulation may still work\n'
fi
if [[ -r /proc/cpuinfo ]] && grep -Eq '(^flags|^Features).* (vmx|svm)( |$)' /proc/cpuinfo; then
  printf 'CPU virtualization feature: detected\n'
else
  printf 'CPU virtualization feature: not detected (may be unavailable or hidden)\n'
fi

section "Next gate"
printf '%s\n' 'Compare this report with the exact official LFS host-system requirements'
printf '%s\n' 'and errata. Confirm enough disk/RAM separately before allocating a'
printf '%s\n' 'disposable QEMU image. Never build against your host root filesystem.'
