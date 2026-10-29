#!/usr/bin/env python3
"""Export the supported starter-project subset to a self-contained Roblox XML place.

No download or Studio automation. default.project.json remains compatible with Rojo 7.
Unknown property types fail explicitly; this is not a general-purpose Rojo replacement.
"""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
PART_CLASSES = {"Part", "SpawnLocation"}
MATERIALS = {"Plastic": 256, "SmoothPlastic": 272, "Neon": 288}
BOOL_PROPERTIES = {"Anchored", "CanCollide", "CanQuery", "CanTouch", "CastShadow", "Neutral", "Enabled", "CharacterAutoLoads"}
FLOAT_PROPERTIES = {"Transparency", "Reflectance", "Duration", "Brightness", "ClockTime", "Gravity"}
COLOR_PROPERTIES = {"Ambient", "OutdoorAmbient", "Color"}
SERVICES = {"Workspace", "ReplicatedStorage", "ServerScriptService", "ServerStorage", "StarterPlayer",
            "StarterGui", "Lighting", "Players", "SoundService"}


def source_identity(path):
    name = path.name
    for suffix, kind in [(".server.luau", "Script"), (".client.luau", "LocalScript"), (".luau", "ModuleScript")]:
        if name.endswith(suffix):
            return name[:-len(suffix)], kind
    raise ValueError(f"Unsupported source file: {path}")


def resolved_tree(name, spec):
    spec = dict(spec)
    path = ROOT / spec["$path"] if "$path" in spec else None
    if path and not path.exists():
        raise ValueError(f"Missing source: {path}")
    kind = spec.get("$className")
    if not kind:
        kind = source_identity(path)[1] if path and path.is_file() else (name if name in SERVICES else "Folder")
    children = [(key, val) for key, val in spec.items() if not key.startswith("$")]
    source = None
    if path and path.is_dir():
        for child in sorted(path.iterdir()):
            if child.name.startswith("."): continue
            if child.is_dir(): children.append((child.name, {"$path": child.relative_to(ROOT).as_posix()}))
            elif child.suffix == ".luau":
                child_name, _ = source_identity(child)
                children.append((child_name, {"$path": child.relative_to(ROOT).as_posix()}))
    elif path:
        source = path.read_text(encoding="utf-8")
    if len({key for key, _ in children}) != len(children):
        raise ValueError(f"Duplicate instance name beneath {name}")
    return kind, spec.get("$properties", {}), source, children


def value_element(props, kind, name, value):
    if name == "Position" and kind in PART_CLASSES:
        element = ET.SubElement(props, "CoordinateFrame", name="CFrame")
        for axis, component in zip("XYZ", value): ET.SubElement(element, axis).text = str(component)
        for row in range(3):
            for col in range(3): ET.SubElement(element, f"R{row}{col}").text = "1" if row == col else "0"
    elif name == "Size":
        element = ET.SubElement(props, "Vector3", name="size" if kind in PART_CLASSES else "Size")
        for axis, component in zip("XYZ", value): ET.SubElement(element, axis).text = str(component)
    elif name == "Color" and kind in PART_CLASSES:
        channels = [max(0, min(255, round(channel * 255))) for channel in value]
        packed = 0xFF000000 | channels[0] << 16 | channels[1] << 8 | channels[2]
        ET.SubElement(props, "Color3uint8", name="Color3uint8").text = str(packed)
    elif name in COLOR_PROPERTIES:
        element = ET.SubElement(props, "Color3", name=name)
        for axis, component in zip("RGB", value): ET.SubElement(element, axis).text = str(component)
    elif name == "Material":
        ET.SubElement(props, "token", name=name).text = str(MATERIALS[value])
    elif kind == "StarterGui" and name == "ClipsDescendantsSupportsRotation":
        # Enum.RolloutState: explicit opt-in so rotated neural edges clip on scroll.
        ET.SubElement(props, "token", name=name).text = str({"Default": 0, "Disabled": 1, "Enabled": 2}[value])
    elif name in BOOL_PROPERTIES and isinstance(value, bool):
        ET.SubElement(props, "bool", name=name).text = str(value).lower()
    elif name in FLOAT_PROPERTIES and isinstance(value, (int, float)):
        ET.SubElement(props, "float", name=name).text = str(value)
    elif isinstance(value, str):
        ET.SubElement(props, "string", name=name).text = value
    else:
        raise ValueError(f"Unsupported property {kind}.{name}: {value!r}; use Rojo or extend exporter with a test")


def build(output=None):
    project = json.loads((ROOT / "default.project.json").read_text(encoding="utf-8"))
    root = ET.Element("roblox", version="4")
    ET.SubElement(root, "External").text = "null"
    ET.SubElement(root, "External").text = "nil"
    serial = 0

    def add(parent, name, spec):
        nonlocal serial
        serial += 1
        kind, properties, source, children = resolved_tree(name, spec)
        item = ET.SubElement(parent, "Item", {"class": kind, "referent": f"RBX{serial:06d}"})
        props = ET.SubElement(item, "Properties")
        ET.SubElement(props, "string", name="Name").text = name
        for key, value in properties.items(): value_element(props, kind, key, value)
        if source is not None:
            ET.SubElement(props, "ProtectedString", name="Source").text = source
            if kind in {"Script", "LocalScript"}: ET.SubElement(props, "bool", name="Disabled").text = "false"
        for child_name, child_spec in children: add(item, child_name, child_spec)

    for name, spec in project["tree"].items():
        if not name.startswith("$"): add(root, name, spec)
    ET.indent(root, space="  ")
    payload = ET.tostring(root, encoding="utf-8", xml_declaration=True)
    target = Path(output) if output else ROOT / "build/VibeIdle.rbxlx"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(payload)
    manifest = {"place": target.name, "sha256": hashlib.sha256(payload).hexdigest(), "instances": serial,
                "source_hashes": {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                                  for p in sorted(ROOT.glob("src/**/*.luau"))}}
    (target.parent / "build-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Built {target.relative_to(ROOT)} ({serial} instances)")
    return target


if __name__ == "__main__": build()
