# L AOSPA custom

Magisk module for Paranoid Android Vauxite (Android 15) on the POCO F5
(`marble`, SM7475). It fixes the ambient-light sensor feed used by
auto-brightness and adds a few small, reversible system tweaks.

Everything is delivered as Magisk overlays (`system/...` inside the module);
nothing in `/system`, `/vendor` or `/odm` is modified on disk. Removing the
module and rebooting restores the stock files.

## Contents

| Path | What it is |
| --- | --- |
| `system/vendor/bin/sensor-notifier` | LineageOS 23.2 `sensor-notifier` with `RawLightNotifier` (the ALS fix). Patched `dlopen` path. |
| `system/vendor/lib64/nt/l` | LineageOS 23.2 `libssccalapi@2.0.so`, private copy with `RUNPATH`/`NEEDED` rewritten. |
| `system/vendor/lib64/nt/s` | LineageOS 23.2 `libssc.so`, private copy for `nt/l`. |
| `sepolicy.rule` | `qipcrtr` access for `vendor_sensor_notifier`; narrow `allow magisk proc_net` for the BBR sysctls. |
| `service.sh` | Relabels `nt/*` to `vendor_file`, restarts the notifier, enables BBR + `fq`. |
| `post-fs-data.sh` | Restores exec bits, applies the two `system.prop` values, drops the rounded-corner disabling prop. |
| `system.prop` | `ro.surface_flinger.clear_slots_with_set_layer_buffer=true`, `ro.input.video_enabled=false`. |
| `system/vendor/usr/keylayout/*.kl` | Headset button mapping for `ukee` and `waipio` sound cards. |
| `build.ps1`, `.github/workflows` | Local build script and CI that publishes a release zip on tag. |

## Auto-brightness (ALS)

The stock PA build ships a `sensor-notifier` without the light extension, so
`tcs3701` (behind the panel) is published uncompensated: a white UI at 15%
brightness read as ~47 lux in a dark room, a dark UI as ~1.6 lux. That is the
"brightness jumps between photos" bug.

The binary here is the LineageOS 23.2 (marble) build, which includes
`RawLightNotifier` + `LightNotifier` and routes them through
`libssccalapi@2.0.so` (present in the HOS2 vendor). It replaces
`/vendor/bin/sensor-notifier` only; everything else keeps using the stock
vendor libraries.

Two extra bits are required for the vendor stack to accept it:

- `sepolicy.rule`: `vendor_sensor_notifier` needs `qipcrtr_socket` access,
  otherwise `init_current_sensors()` throws and the service crash-loops.
- `vendor/lib64/nt/l` + `nt/s`: the 23.2 `libssccalapi@2.0.so` (needed for a
  stable compensation) and its `libssc.so`, patched to load from this private
  dir. The notifier's `dlopen` string is patched to `/vendor/lib64/nt/l`, so
  the rest of the sensor stack keeps using the stock HOS2 libs.
- `service.sh`: Magisk mounts these files as `system_file`; the script relabels
  them to `vendor_file` at late_start and restarts the notifier, so no broad
  `system_file` allow is needed.

SELinux stays enforcing. The rules are limited to the notifier domain and to
`magisk` writing the two sysctl files.

## TCP BBR

`service.sh` sets `net.ipv4.tcp_congestion_control=bbr` and
`net.core.default_qdisc=fq` at late_start. The Glow kernel (5.10) has BBR
built in, so no kernel change is involved. The only SELinux addition is
`allow magisk proc_net file { write open }`, because the script runs in the
Magisk shell domain. Remove those two lines from `service.sh` (and the rule)
if you want the stock CUBIC behaviour back.

## What is *not* included

- No fingerprint HAL changes: `marble` has a side-mounted reader, and the
  UDFPS/LHBM code from `sm8450-common` does not apply to it.
- No GPU voltage / KonaBess changes: `vendor_boot` and `dtbo` are not touched.
- No Bluetooth property overrides: the stock stack already advertises the
  codecs and the battery service client, so nothing is forced.
- No brightness config or gamma changes: `config_autoBrightnessAdjustmentMaxGamma`
  is already 105% on this build.

## Install

Flash the release zip in Magisk (or `magisk --install-module <zip>`) and
reboot. The notifier is restarted automatically at boot by `service.sh`.

To remove: disable or delete the module in Magisk and reboot.

## Provenance

- `LineageOS/android_device_xiaomi_marble` `lineage-23.2` `light/RawLightNotifier.cpp`
- `LineageOS/android_device_xiaomi_sm8450-common` `lineage-23.2` `sensors/sensor-notifier`
- BBR sysctls and the `fq` qdisc are standard Linux 5.10 interfaces.

## Sound

Dolby: [Dolby Atmos Sony Xperia 5 V](https://github.com/reiryuki/Dolby-Atmos-Sony-Xperia-5-V-Magisk-Module)
(DAX 3.7, config 3.4.0). Provided by a separate module, not by this one.
