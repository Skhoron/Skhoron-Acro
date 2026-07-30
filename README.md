# Skhoron Acro

FPV drone simulator for Android. Physics-accurate, open source.

## Stack

- Godot 4.3
- GDScript
- Android target (API 24+)

## Physics model

- Motor thrust: `T = kT × ω²`
- Motor torque: `Q = kQ × ω²`
- Betaflight-style PID (P/I/D per axis)
- Voltage sag under load
- Prop wash turbulence
- Ground effect
- Motor temperature limiting
- Prop damage affecting thrust

## Features

- 7 camera modes (FPV, 3rd person rear/front, orbit, cinematic, fixed, director)
- 5-second streak multiplier (up to ×3.0)
- 5-second rewind
- Ghost replay (best lap)
- Wind gusts
- Killzone at 85% of visual mesh
- Academy: 5 lessons, 4 medal tiers
- 10 drones (3 unlocked, 7 locked)
- 5 maps

## Build

Push to `main` → GitHub Actions builds APK automatically.
APK available under Actions → Artifacts.

## License

GPL v3 — see [LICENSE](LICENSE)