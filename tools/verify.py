#!/usr/bin/env python3
"""Structure + real core specs. Luau CLI preferred; Lua 5.4 fallback for this Lua-compatible subset."""
from pathlib import Path
import ctypes
import ctypes.util
import json
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from build_place import ROOT, build, resolved_tree
from client_smoke import bundle as client_smoke_bundle
from generate_mascots import verify_generated as verify_mascots
from generate_store_icons import verify_generated as verify_store_icons
from generate_skill_fire import verify_generated as verify_skill_fire

MODULES = {"Telemetry": "src/server/Telemetry.luau", "Premium": "src/shared/PremiumRules.luau", "Commerce": "src/server/CommerceService.luau", "Craft": "src/shared/AgentCrafting.luau", "PrestigeMotion": "src/shared/PrestigeMotion.luau", "Tree": "src/shared/SkillTreeLayout.luau", "Cards": "src/shared/AgentCards.luau", "Prestige": "src/shared/PrestigeRules.luau", "Tuning": "src/shared/StudioTuning.luau", "Collectibles": "src/shared/StreakCollectibles.luau", "Balance": "src/shared/Balance.luau", "State": "src/shared/State.luau",
           "Simulation": "src/shared/Simulation.luau", "Rules": "src/shared/UpgradeRules.luau",
           "RateLimiter": "src/shared/RateLimiter.luau", "Protocol": "src/shared/Protocol.luau",
           "ProfileRepository": "src/server/ProfileRepository.luau", "Layout": "src/shared/NetworkLayout.luau",
           "Prompt": "src/shared/PromptRules.luau", "Draft": "src/shared/PromptDraft.luau",
           "Flow": "src/shared/NetworkFlow.luau", "Agent": "src/shared/AgentSession.luau",
           "Session": "src/shared/PromptSession.luau", "Composer": "src/shared/PromptComposer.luau",
           "Cash": "src/shared/CashFeedback.luau", "Collection": "src/shared/TokenCollection.luau", "Skill": "src/shared/SkillCheck.luau",
           "Auto": "src/shared/AgentAutomation.luau", "Dance": "src/shared/MascotDance.luau", "Music": "src/shared/Soundtrack.luau"}


def structural():
    verify_mascots()
    verify_store_icons()
    verify_skill_fire()
    project = json.loads((ROOT / "default.project.json").read_text(encoding="utf-8"))
    required = {"ReplicatedStorage", "ServerScriptService", "ServerStorage", "StarterPlayer", "Workspace"}
    assert required <= project["tree"].keys()
    place = build()
    first = place.read_bytes()
    build()
    assert place.read_bytes() == first, "Place export must be deterministic"
    tree = ET.fromstring(first)
    assert tree.attrib["version"] == "4"
    items = list(tree.iter("Item"))
    assert len({item.attrib["referent"] for item in items}) == len(items)
    assert len([item for item in items if item.attrib["class"] == "SpawnLocation"]) == 1
    players = next(item for item in items if item.attrib["class"] == "Players")
    assert players.find("Properties/bool[@name='CharacterAutoLoads']").text == "false", "UI-only place must not spawn avatars"
    starter_gui = next(item for item in items if item.attrib["class"] == "StarterGui")
    assert starter_gui.find("Properties/token[@name='ClipsDescendantsSupportsRotation']").text == "2", "Rotated network edges must clip in the scroll viewport"
    sources = [item.find("Properties/ProtectedString[@name='Source']") for item in items]
    embedded = [node.text for node in sources if node is not None]
    for path in ROOT.glob("src/**/*.luau"):
        assert path.read_text(encoding="utf-8") in embedded, f"Source missing or changed in place: {path}"
    assert not any(item.find("Properties/string[@name='Name']").text == "StudioCommand" for item in items)
    config = (ROOT / "src/server/ServerConfig.luau").read_text()
    assert any(f'STORAGE_MODE = "{mode}"' in config for mode in ("MEMORY", "DATASTORE")), "Unknown storage mode"
    service = (ROOT / "src/server/GameService.luau").read_text(encoding="utf-8")
    assert "Simulation.advance(" not in service, "Money must come from prompts, never passive server/Studio ticks"
    assert "PromptSession.submit(" in service, "Runtime must use the server-issued manual prompt path"
    print(f"PASS structural checks: {len(items)} instances, {len(embedded)} embedded sources, deterministic export")


def lua_fallback():
    library = ctypes.util.find_library("lua5.4") or ctypes.util.find_library("lua54")
    if not library: return False
    lua = ctypes.CDLL(library)
    lua.luaL_newstate.restype = ctypes.c_void_p
    lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
    lua.luaL_loadbufferx.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p, ctypes.c_char_p]
    lua.luaL_loadbufferx.restype = ctypes.c_int
    lua.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_ssize_t, ctypes.c_void_p]
    lua.lua_pcallk.restype = ctypes.c_int
    lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
    lua.lua_tolstring.restype = ctypes.c_char_p
    lua.lua_settop.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lua.lua_close.argtypes = [ctypes.c_void_p]
    state = lua.luaL_newstate()
    assert state, "Lua allocation failed"
    lua.luaL_openlibs(state)

    def load(code, name):
        encoded = code.encode("utf-8")
        result = lua.luaL_loadbufferx(state, encoded, len(encoded), name.encode(), None)
        if result: raise RuntimeError(lua.lua_tolstring(state, -1, None).decode())

    try:
        files = sorted(ROOT.glob("src/**/*.luau")) + sorted(ROOT.glob("tests/*.luau"))
        for path in files:
            load(path.read_text(encoding="utf-8"), path.relative_to(ROOT).as_posix())
            lua.lua_settop(state, 0)
        print(f"PASS Lua-compatible syntax: {len(files)} sources (not Roblox type checking)", flush=True)
        code = "local modules = {}\n"
        for name, relative in MODULES.items():
            code += f"modules.{name} = (function()\n{(ROOT / relative).read_text(encoding='utf-8')}\nend)()\n"
        code += "local specs = (function()\n" + (ROOT / "tests/Specs.luau").read_text(encoding="utf-8") + "\nend)()\n"
        code += "assert(specs.run(modules) >= 111)\n"
        code += "local manual = (function()\n" + (ROOT / "tests/PromptSessionSpecs.luau").read_text(encoding="utf-8") + "\nend)()\n"
        code += "assert(manual.run(modules) >= 68)\n"
        code += "local commerce = (function()\n" + (ROOT / "tests/CommerceSpecs.luau").read_text(encoding="utf-8") + "\nend)()\n"
        code += "assert(commerce.run(modules) >= 16)\n"
        code += client_smoke_bundle(MODULES)
        load(code, "core_and_client_specs")
        if lua.lua_pcallk(state, 0, 0, 0, 0, None):
            raise RuntimeError(lua.lua_tolstring(state, -1, None).decode())
    finally: lua.lua_close(state)
    return True


def main():
    structural()
    if "--structure-only" in sys.argv:
        print("SKIP runtime explicitly requested; core specs and Studio remain pending")
        return
    if shutil.which("luau"):
        subprocess.run(["luau", "tests/Run.luau"], cwd=ROOT, check=True)
        with tempfile.TemporaryDirectory(prefix="vibeidle-client-") as temporary:
            runner = Path(temporary) / "client_smoke.luau"
            runner.write_text(client_smoke_bundle(MODULES), encoding="utf-8")
            subprocess.run(["luau", str(runner)], cwd=ROOT, check=True)
        if shutil.which("luau-compile"):
            for path in ROOT.glob("src/**/*.luau"):
                subprocess.run(["luau-compile", str(path)], cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
        print("PASS Luau core specs. Studio integration/visual QA still required.")
    elif lua_fallback():
        print("PASS core specs on Lua 5.4 subset. Luau type checking and Studio integration/visual QA still required.")
    else:
        print("No runtime. Install Luau CLI, or run the same Specs in Studio. Use --structure-only only to inspect export.", file=sys.stderr)
        raise SystemExit(2)


if __name__ == "__main__": main()
