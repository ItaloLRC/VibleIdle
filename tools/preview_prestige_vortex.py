"""Render live motion equations over approximate UI: not a Studio screenshot."""
import ctypes
import ctypes.util
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[1]
W,H=640,360


def poses():
    lua=ctypes.CDLL(ctypes.util.find_library("lua5.4") or ctypes.util.find_library("lua54"))
    lua.luaL_newstate.restype=ctypes.c_void_p
    lua.luaL_openlibs.argtypes=[ctypes.c_void_p]
    lua.luaL_loadbufferx.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_size_t,ctypes.c_char_p,ctypes.c_char_p]
    lua.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_ssize_t,ctypes.c_void_p]
    lua.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];lua.lua_tolstring.restype=ctypes.c_char_p
    lua.lua_close.argtypes=[ctypes.c_void_p]
    code="local M=(function()\n"+(ROOT/"src/shared/PrestigeMotion.luau").read_text(encoding="utf-8")+"\nend)()\n"
    code+='''local rows={}
for frame=0,184 do
    local age=frame/60;local p=M.pose(age,false)
    rows[#rows+1]=table.concat({"p",frame,p.scale,p.angle,p.veil,p.hole,tostring(p.covered)},"\\t")
    if p.spiral then for index=1,M.SPECKS do
        local s=M.speck(index,age,640,360)
        rows[#rows+1]=table.concat({"s",frame,index,s.x,s.y,s.size,s.alpha,s.length,s.angle},"\\t")
    end end
end
return table.concat(rows,"\\n")'''
    state=lua.luaL_newstate();lua.luaL_openlibs(state);encoded=code.encode()
    try:
        if lua.luaL_loadbufferx(state,encoded,len(encoded),b"vortex_preview",None) or lua.lua_pcallk(state,0,1,0,0,None):
            raise RuntimeError(lua.lua_tolstring(state,-1,None).decode())
        return lua.lua_tolstring(state,-1,None).decode()
    finally:
        lua.lua_close(state)


def panel(draw,box,color):
    x,y,r,b=box
    draw.rectangle((x+4,y+4,r+4,b+4),fill=(11,8,17))
    draw.rectangle(box,fill=(137,106,159))
    draw.rectangle((x+3,y+3,r-3,b-3),fill=color)


def main():
    data=poses();(ROOT/"build/prestige-vortex-motion.tsv").write_text(data,encoding="utf-8")
    samples={};specks={}
    for row in data.splitlines():
        r=row.split("\t");frame=int(r[1])
        if r[0]=="p": samples[frame]=tuple(map(float,r[2:6]))+(r[6]=="true",)
        else: specks.setdefault(frame,[]).append(tuple(map(float,r[2:])))
    font=ImageFont.load_default(size=13)
    wall=Image.new("RGBA",(W,H));d=ImageDraw.Draw(wall)
    for y in range(18):
        for x in range(32):
            dx,dy=((x+.5)/32-.5)*1.7778,(y+.5)/18-.37
            radius=math.sqrt(dx*dx+dy*dy);lower=max(0,min(1,(dy+.05)/.6))
            glow=math.exp(-((radius-.60)/.15)**2)*lower
            rim=math.exp(-((radius-.60)/.024)**2)*lower**2
            inside=max(0,min(1,(.61-radius)*18))
            purple=inside*math.exp(-((dx+.08)**2/.20+(dy-.27)**2/.16))
            red=math.exp(-((dx-.56)**2/.20+(dy-.38)**2/.24))
            rgb=(8+112*purple+60*glow+60*red,3+4*purple+8*glow,24+134*purple+84*glow)
            color=tuple(max(0,min(255,int((v+(peak-v)*min(1,rim))/16+.5)*16)) for v,peak in zip(rgb,(255,222,154)))
            d.rectangle((x*20,y*20,x*20+20,y*20+20),fill=color)
    prestige=Image.new("RGBA",(W,H),(27,23,34));d=ImageDraw.Draw(prestige)
    d.text((20,12),"< MAIN CLI",font=font,fill=(237,224,214));d.text((510,12),"PRESTIGE",font=font,fill=(240,185,83))
    panel(d,(72,54,312,140),(42,31,56));panel(d,(328,54,568,140),(42,31,56))
    d.text((96,72),"YOU HAVE",font=font,fill=(239,230,212));d.text((96,105),"1 CHIP",font=font,fill=(249,173,70))
    d.text((350,72),"EACH EARNED CHIP",font=font,fill=(239,230,212));d.text((350,105),"+5% CASH",font=font,fill=(137,235,142))
    panel(d,(72,154,568,306),(42,31,56))
    d.text((196,180),"PRESTIGE CONFIRMED",font=font,fill=(240,185,83));d.text((182,216),"A NEW RUN IS BEGINNING",font=font,fill=(239,230,212))
    normal=wall.copy();d=ImageDraw.Draw(normal)
    d.text((14,12),"$0.00",font=font,fill=(137,235,142));d.text((14,34),"1 CHIP",font=font,fill=(240,185,83))
    panel(d,(26,82,444,286),(28,28,32));d.text((42,96),"MAIN CLI",font=font,fill=(239,230,212))
    d.rectangle((42,126,428,128),fill=(71,61,79));d.text((44,154),"AGENT 01",font=font,fill=(205,127,97))
    d.text((44,210),"> Agents are preparing tokens.",font=font,fill=(174,162,185))
    d.rectangle((350,242,422,270),fill=(205,127,97));d.text((365,248),"SELL",font=font,fill=(23,20,28))
    for y,title in ((90,"TOKEN VALUE"),(158,"AGENT COUNT"),(226,"CONTEXT")):
        panel(d,(470,y,626,y+54),(46,34,48));d.text((482,y+15),title,font=font,fill=(240,185,83))
    d.rectangle((0,326,W,H),fill=(29,25,37));d.text((16,340),"Main CLI               Guide",font=font,fill=(239,230,212))
    frames=[];colors=((133,73,167),(205,127,97),(78,40,112))
    for frame,(scale,angle,veil,hole,covered) in samples.items():
        canvas=Image.new("RGBA",(W,H),(9,5,17))
        if covered: canvas=normal.copy()
        else:
            for layer in (wall,prestige):
                transformed=layer.resize((max(1,int(W*scale)),max(1,int(H*scale))),Image.Resampling.NEAREST).rotate(-angle,expand=True,resample=Image.Resampling.NEAREST)
                canvas.alpha_composite(transformed,((W-transformed.width)//2,(H-transformed.height)//2))
        canvas.alpha_composite(Image.new("RGBA",(W,H),(9,5,17,int(255*veil))))
        dust=Image.new("RGBA",(W,H));draw=ImageDraw.Draw(dust)
        for index,x,y,size,alpha,length,angle in specks.get(frame,[]):
            angle=math.radians(angle)
            points=[]
            for dx,dy in ((-length/2,-size/2),(length/2,-size/2),(length/2,size/2),(-length/2,size/2)):
                points.append((int(x+dx*math.cos(angle)-dy*math.sin(angle)),int(y+dx*math.sin(angle)+dy*math.cos(angle))))
            draw.polygon(points,fill=colors[(int(index)-1)//48]+(int(255*(1-alpha)),))
        canvas.alpha_composite(dust);draw=ImageDraw.Draw(canvas)
        radius=math.hypot(W,H)*hole
        if radius:
            for i in range(1,25):
                half=math.sqrt(144-(i-12.5)**2)*radius/12
                draw.rectangle((int(W/2-half),int(H/2+(i-13)*radius/12),math.ceil(W/2+half),math.ceil(H/2+(i-12)*radius/12)),fill=(9,5,17))
        frames.append(canvas.convert("RGB"))
    frames[0].save(ROOT/"build/prestige-vortex-preview.gif",save_all=True,append_images=frames[1:]+[frames[-1]]*30,duration=17,loop=0,optimize=False)
    sheet=Image.new("RGB",(W*3,H*2))
    for i,index in enumerate((0,24,54,90,132,184)): sheet.paste(frames[index],((i%3)*W,(i//3)*H))
    sheet.save(ROOT/"build/prestige-vortex-contact-sheet.png")
    print("Rendered live motion over approximate UI; not Studio. GIF loops for preview only.")


if __name__=="__main__": main()
