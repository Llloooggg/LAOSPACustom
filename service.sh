#!/system/bin/sh
# L AOSPA custom - llloooggg.ru
# Runs at late_start, after Magisk has mounted /vendor/lib64/nt.
# Magisk mounts the private libs as system_file; relabel them to vendor_file so
# vendor_sensor_notifier can dlopen them without a broad system_file allow.

MODDIR=${0%/*}

sleep 2
chcon u:object_r:vendor_file:s0 "$MODDIR/system/vendor/lib64/nt" \
    "$MODDIR/system/vendor/lib64/nt/l" "$MODDIR/system/vendor/lib64/nt/s" 2>/dev/null

# the notifier starts in class main before this script; restart it now
setprop ctl.restart vendor.sensor-notifier

# TCP BBR + fq qdisc (needs the proc_net allow in sepolicy.rule)
echo bbr > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
echo fq > /proc/sys/net/core/default_qdisc 2>/dev/null
