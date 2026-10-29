"""Run the authored Lua economy through an idealized, deterministic pacing model.

Not a player forecast: perfect full sales, expected rarity, fixed streak, no latency,
no cards, no offline income. Uses production prices/rewards/permanent effects.
"""
import ctypes
import ctypes.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    library = ctypes.util.find_library("lua5.4") or ctypes.util.find_library("lua54")
    if not library:
        raise RuntimeError("Lua 5.4 is required (Wireshark includes lua54.dll).")
    lua = ctypes.CDLL(library)
    lua.luaL_newstate.restype = ctypes.c_void_p
    lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
    lua.luaL_loadbufferx.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p, ctypes.c_char_p]
    lua.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_ssize_t, ctypes.c_void_p]
    lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
    lua.lua_tolstring.restype = ctypes.c_char_p
    lua.lua_close.argtypes = [ctypes.c_void_p]
    state = lua.luaL_newstate()
    lua.luaL_openlibs(state)
    code = ""
    for name, file in {"B": "Balance", "State": "State", "Rules": "UpgradeRules", "Sim": "Simulation", "Session": "PromptSession"}.items():
        code += f"local {name}=(function()\n{(ROOT / ('src/shared/' + file + '.luau')).read_text(encoding='utf-8')}\nend)()\n"
    code += (ROOT / "tools/progression_model.luau").read_text(encoding="utf-8")
    encoded = code.encode("utf-8")
    try:
        if lua.luaL_loadbufferx(state, encoded, len(encoded), b"progression_model", None) or lua.lua_pcallk(state, 0, 0, 0, 0, None):
            raise RuntimeError(lua.lua_tolstring(state, -1, None).decode())
    finally:
        lua.lua_close(state)


if __name__ == "__main__":
    main()
