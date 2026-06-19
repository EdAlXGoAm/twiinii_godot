# Twiinii Godot

2.5D Twiinii World prototype for Web export.

## Requirements

- Godot 4 CLI available as `godot4` or `godot`
- Godot Web export templates installed

## Run locally

```bash
godot4 --path /root/productive/twiinii_godot
```

## Export Web build

```bash
/root/productive/twiinii_godot/build_web.sh
```

The Web export is written to:

```text
/root/productive/twiinii_godot/build/web/index.html
```

Sync into Twiinii with:

```bash
/root/productive/twiinii/scripts/sync-godot-world.sh
```
