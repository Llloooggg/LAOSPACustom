#!/system/bin/sh
# L AOSPA custom - llloooggg.ru

# sensor-notifier is exec'd by init; zip entries lose the exec bit
chmod 755 "$MODPATH/system/vendor/bin/sensor-notifier" 2>/dev/null
chmod 644 "$MODPATH/system/vendor/lib64/nt/l" "$MODPATH/system/vendor/lib64/nt/s" 2>/dev/null

if command -v resetprop >/dev/null 2>&1; then
  resetprop -n ro.surface_flinger.clear_slots_with_set_layer_buffer true
  resetprop -n ro.input.video_enabled false
  # enable HW rounded corners: drop the disabling prop from odm
  resetprop --delete vendor.display.enable_rounded_corner 2>/dev/null
fi