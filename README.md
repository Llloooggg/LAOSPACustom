# L AOSPA custom

ROM: Paranoid Android Vauxite (Android 15), POCO F5 (marble).

## What it does

- `sensor-notifier` with the `RawLightNotifier` extension: feeds the raw
  under-display ALS into the vendor `ssccalapi`, so auto-brightness no longer
  reacts to the screen's own light (white photos/UI no longer "jump").
- Hardware rounded screen corners.
- Disables V4L device scanning in EventHub.
- Releases SurfaceFlinger buffer slots earlier.
- Headset buttons: `Button_Jack.kl` for ukee and waipio.

## Auto-brightness (ALS)

The stock PA build ships a `sensor-notifier` without the light extension, so
`tcs3701` (behind the panel) is published uncompensated: a white UI at 15%
brightness read as ~47 lux in a dark room, a dark UI as ~1.6 lux. That is the
"brightness jumps between photos" bug.

The binary here is the LineageOS 23.2 (marble) build, which includes
`RawLightNotifier` + `LightNotifier` and routes them through
`libssccalapi@2.0.so` (present in the HOS2 vendor). It replaces
`/vendor/bin/sensor-notifier` only; everything else is untouched and removing
this module restores the stock binary after a reboot.

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

Provenance:
- `LineageOS/android_device_xiaomi_marble` `lineage-23.2` `light/RawLightNotifier.cpp`
- `LineageOS/android_device_xiaomi_sm8450-common` `lineage-23.2` `sensors/sensor-notifier`


## Sound

Dolby: [Dolby Atmos Sony Xperia 5 V](https://github.com/reiryuki/Dolby-Atmos-Sony-Xperia-5-V-Magisk-Module)
(DAX 3.7, config 3.4.0).
