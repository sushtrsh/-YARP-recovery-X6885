#!/system/bin/sh
# Dijalankan init (service prep_format) saat TWRP set twrp.prep_format=1, sebelum Format Data.
# Melepas /vendor supaya TWRP bisa unmap dynamic partition.
LOG=/tmp/prep_format.log
echo "== prep_format $(date)" >> "$LOG"

pkill -f mcdaemon.sh
pkill mcDriverDaemon
pkill wmt_launcher
pkill wlan_assistant
pkill wmt_loader
pkill wpa_supplicant
sleep 1

i=0
while [ $i -lt 10 ]; do
  umount /vendor >> "$LOG" 2>&1 && break
  i=$((i + 1))
  sleep 1
done

grep " /vendor " /proc/mounts >> "$LOG" 2>&1 || echo "/vendor released" >> "$LOG"
setprop twrp.prep_format.done 1
