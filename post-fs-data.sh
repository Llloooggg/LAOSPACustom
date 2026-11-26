#!/system/bin/sh
# L AOSPA custom - llloooggg.ru
if command -v resetprop >/dev/null 2>&1; then
  resetprop -n ro.surface_flinger.clear_slots_with_set_layer_buffer true
  resetprop -n ro.input.video_enabled false
  # enable HW rounded corners: drop the disabling prop from odm
  resetprop --delete vendor.display.enable_rounded_corner 2>/dev/null
fi