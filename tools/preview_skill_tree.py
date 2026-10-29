"""Offline native-geometry proxy, not a Roblox/PressStart2P screenshot."""
import ctypes
import ctypes.util
from pathlib import Path
import re
import textwrap
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]


def scene():
    library = ctypes.util.find_library("lua5.4") or ctypes.util.find_library("lua54")
    if not library:
        raise RuntimeError("Use the installed Lua5.4 runtime on PATH.")
    lua = ctypes.CDLL(library)
    lua.luaL_newstate.restype = ctypes.c_void_p
    lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
    lua.luaL_loadbufferx.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p, ctypes.c_char_p]
    lua.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_ssize_t, ctypes.c_void_p]
    lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
    lua.lua_tolstring.restype = ctypes.c_char_p
    lua.lua_close.argtypes = [ctypes.c_void_p]
    source = (ROOT / "src/client/PrestigePage.luau").read_text(encoding="utf-8")
    icons = re.search(r"local icons=(\{[\s\S]*?\n\})", source).group(1)
    code = ""
    for name, path in {"B": "Balance", "T": "SkillTreeLayout"}.items():
        code += f"local {name}=(function()\n{(ROOT / ('src/shared/'+path+'.luau')).read_text(encoding='utf-8')}\nend)()\n"
    code += "local icons=" + icons + "\n"
    code += '''
local bounds=T.bounds(B.PRESTIGE_NODES)
local rows={"bounds\\t"..bounds.width.."\\t"..bounds.height}
for _,kind in ipairs({{name="edge",inset=0},{name="face",inset=4}}) do
    for _,r in ipairs(T.hex(kind.inset)) do
        rows[#rows+1]=table.concat({kind.name,r.x,r.y,r.width,r.height},"\\t")
    end
end
for _,node in ipairs(B.PRESTIGE_NODES) do
    local p=T.position(node.id)
    rows[#rows+1]=table.concat({"node",node.id,p.x,p.y,node.name,node.description:gsub("\\n"," / "),
        node.cost,table.concat(node.parents,","),T.family(node),table.concat(icons[node.icon or node.id],"/")},"\\t")
end
return table.concat(rows,"\\n")
'''
    state = lua.luaL_newstate()
    lua.luaL_openlibs(state)
    encoded = code.encode("utf-8")
    try:
        if lua.luaL_loadbufferx(state, encoded, len(encoded), b"tree_preview", None) or lua.lua_pcallk(state, 0, 1, 0, 0, None):
            raise RuntimeError(lua.lua_tolstring(state, -1, None).decode())
        return lua.lua_tolstring(state, -1, None).decode()
    finally:
        lua.lua_close(state)


def main():
    data = scene()
    (ROOT / "build/expanded-tree-layout.tsv").write_text(data, encoding="utf-8")
    rows = [row.split("\t") for row in data.splitlines()]
    width, height = int(rows[0][1]), int(rows[0][2])
    shapes = {kind: [tuple(map(int, r[1:])) for r in rows if r[0] == kind] for kind in ("edge", "face")}
    nodes = {r[1]: dict(x=int(r[2]), y=int(r[3]), name=r[4], note=r[5], cost=int(r[6]),
        parents=r[7].split(",") if r[7] else [], family=r[8], icon=r[9].split("/")) for r in rows if r[0] == "node"}
    palette = {"core": ((205,127,97),(55,35,43)), "tokens": ((240,185,83),(53,42,30)),
        "agents": ((137,235,142),(27,48,43)), "focus": ((133,198,255),(26,39,57)),
        "luck": ((215,172,255),(46,31,59)), "memory": ((249,204,111),(53,45,31)),
        "swarm": ((205,127,97),(54,34,30))}
    owned = set("boot tokens agents focus cache swarm context focus10 core fortune overclock memory luck luck2 cash1 speed1".split())
    image = Image.new("RGB", (width, height), (27,23,34))
    draw = ImageDraw.Draw(image)
    for y in range(0,height,96):
        for x in range(0,width,96):
            draw.rectangle((x,y,x+1,y+1), fill=(51,45,58))
    for id,node in nodes.items():
        tint = palette[node["family"]][0]
        for parent in node["parents"]:
            a = nodes[parent]
            points = [(a["x"]+120,a["y"]+104), (node["x"]+120,node["y"]+104)]
            draw.line(points, fill=(15,12,20), width=8)
            color = (240,185,83) if id in owned else tint if all(p in owned for p in node["parents"]) else (60,52,69)
            draw.line(points, fill=color, width=4)
    def font(size):
        try:
            return ImageFont.load_default(size=size)
        except TypeError:
            return ImageFont.load_default()
    def centered(value,x,y,w,size,color):
        for line in textwrap.wrap(value, max(1,w//size), break_long_words=False) or [""]:
            length=draw.textbbox((0,0),line,font=font(size))[2]
            draw.text((x+(w-length)//2,y),line,font=font(size),fill=color)
            y+=size+2
    for id,node in nodes.items():
        x,y=node["x"],node["y"]
        available=all(p in owned for p in node["parents"])
        tint,face=palette[node["family"]]
        edge=(240,185,83) if id in owned else tint if available else (60,52,69)
        for kind,color in (("edge",edge),("face",face if available or id in owned else (34,30,42))):
            for rx,ry,rw,rh in shapes[kind]:
                draw.rectangle((x+rx,y+ry,x+rx+rw-1,y+ry+rh-1),fill=color)
        colors={"a": tint,"b": (27,28,32),"c": (239,230,212)}
        for row,line in enumerate(node["icon"]):
            for col,letter in enumerate(line):
                if letter not in colors:
                    continue
                color=colors[letter]
                if not available and id not in owned:
                    color=tuple(int(v*.55+34*.45) for v in color)
                draw.rectangle((x+96+col*6,y+16+row*6,x+101+col*6,y+21+row*6),fill=color)
        centered(node["name"],x+12,y+70,216,14,(236,228,216))
        centered(node["note"],x+16,y+112,208,11,(174,162,185))
        price=(f'{node["cost"]/1000:.1f}K' if node["cost"]>=1000 else str(node["cost"]))+" Chips"
        label="UNLOCKED" if id in owned else price if available else "LOCKED"
        draw.rectangle((x+48,y+154,x+191,y+183),fill=(16,13,22))
        draw.rectangle((x+50,y+152,x+189,y+179),fill=(205,127,97) if available and id not in owned else (44,36,52))
        centered(label,x+48,y+160,144,13,(137,235,142) if id in owned else (239,230,212))
    image.save(ROOT / "build/expanded-tree-preview.png")
    root=nodes["boot"]
    image.crop((root["x"]-480,root["y"]-380,root["x"]+720,root["y"]+580)).save(ROOT / "build/expanded-tree-core-preview.png")
    print(f"Rendered {len(nodes)} nodes at {width}x{height}; geometry proxy with approximate type, not Studio.")


if __name__ == "__main__":
    main()
