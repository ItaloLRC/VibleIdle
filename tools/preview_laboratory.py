"""Production GUI geometry via mock services; approximate font, not Studio QA."""
import ctypes
import ctypes.util
from PIL import Image, ImageDraw, ImageFont
from verify import MODULES, ROOT
from client_smoke import bundle

INJECT=r'''
if true then
    local fragments={};for _,family in ipairs(shared.Balance.AGENT_FAMILIES) do fragments[family.id]=100 end
    local f=fixture(1,{newCollection=true,money=100000000000,profile={fragments=fragments,
        lifetimeEarned=1000000000,prestigeClaimed=100,prestigeCount=1,chips=100}})
    f.root.Size=f.udim2.fromOffset(WIDTH,HEIGHT);f:feature("Laboratory");for _=1,6 do f:tick(.1) end
    f.lab.list.CanvasPosition=f.vec2.new(0,SCROLL)
    local function walk(node,clip)
        if node.Visible==false then return end
        local p,s=node.AbsolutePosition,node.AbsoluteSize
        local x,y,w,h=p.X,p.Y,s.X,s.Y
        if node.ClipsDescendants then clip={math.max(clip[1],x),math.max(clip[2],y),math.min(clip[3],x+w),math.min(clip[4],y+h)} end
        if w>0 and h>0 then
            local color=node.properties.BackgroundColor3
            local alpha=node.BackgroundTransparency or 0
            if color and alpha<1 then
                previewRows[#previewRows+1]=table.concat({"r",x,y,w,h,color[1],color[2],color[3],alpha,0,"",clip[1],clip[2],clip[3],clip[4],""},"\t")
            end
            if node.properties.Text and node.Text~="" and (node.TextTransparency or 0)<1 then
                color=node.TextColor3 or {231,228,224}
                local text=node.Text:gsub("\n","\\n"):gsub("\t"," ")
                previewRows[#previewRows+1]=table.concat({"t",x,y,w,h,color[1],color[2],color[3],node.TextTransparency or 0,
                    node.TextSize or 14,node.TextXAlignment and node.TextXAlignment.Name or "Left",clip[1],clip[2],clip[3],clip[4],text},"\t")
            end
        end
        local sorted={};for i,child in ipairs(node.children) do sorted[#sorted+1]={child,i} end
        table.sort(sorted,function(a,b) return (a[1].ZIndex or 1)==(b[1].ZIndex or 1) and a[2]<b[2] or (a[1].ZIndex or 1)<(b[1].ZIndex or 1) end)
        for _,entry in ipairs(sorted) do
            local child=entry[1];if child.ClassName=="Frame" or child.ClassName=="TextLabel" or child.ClassName=="TextButton" or child.ClassName=="ScrollingFrame" then walk(child,clip) end
        end
    end
    walk(f.lab.frame,{0,0,WIDTH,HEIGHT})
    return 107
end
'''

def geometry(width,height,scroll,target="Lab"):
    lua=ctypes.CDLL(ctypes.util.find_library("lua5.4") or ctypes.util.find_library("lua54"))
    lua.luaL_newstate.restype=ctypes.c_void_p
    lua.luaL_openlibs.argtypes=[ctypes.c_void_p]
    lua.luaL_loadbufferx.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_size_t,ctypes.c_char_p,ctypes.c_char_p]
    lua.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_ssize_t,ctypes.c_void_p]
    lua.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];lua.lua_tolstring.restype=ctypes.c_char_p
    lua.lua_close.argtypes=[ctypes.c_void_p]
    injection=INJECT.replace("WIDTH",str(width)).replace("HEIGHT",str(height)).replace("SCROLL",str(scroll))
    if target in ("TransitionCover","TransitionReveal","TransitionReady"):
        injection=injection.replace('newCollection=true,','motion=true,newCollection=true,')
        frames={"TransitionCover":3,"TransitionReveal":12,"TransitionReady":24}[target]
        injection=injection.replace('f:feature("Laboratory");for _=1,6 do f:tick(.1) end',
            'f:finishUi();f:feature("Laboratory");for _=1,'+str(frames)+' do f:tick(1/60) end')
        injection=injection.replace('walk(f.lab.frame,{0,0,'+str(width)+','+str(height)+'})',
            'walk(f.root,{0,0,'+str(width)+','+str(height)+'});walk(f.onboarding.root,{0,0,'+str(width)+','+str(height)+'});walk(f.motion.cover,{0,0,'+str(width)+','+str(height)+'})')
    if target in ("Start","TutorialSkill","TutorialSell","TutorialVisitor","TutorialDone"):
        injection=injection.replace('newCollection=true,','onboarding=true,agents=true,visitors=true,newCollection=true,')
        injection=injection.replace('f:feature("Laboratory")','f.dancers.layer.Size=f.udim2.fromOffset('+str(width)+','+str(height)+');f:feature("Laboratory")')
        action=''
        if target!="Start":
            action='f.onboarding:start(true)'
            if target=="TutorialSell":action+=';f.onboarding:advance("Sell");for _=1,15 do f:tick(.1) end'
            if target=="TutorialVisitor":action+=';f.onboarding:advance("Visitor");for _=1,100 do f:tick(.1) end'
            if target=="TutorialDone":action+=';f.onboarding:advance("Done")'
        injection=injection.replace('f:feature("Laboratory")',action or 'f.onboarding:layout()')
        injection=injection.replace('f.lab.list.CanvasPosition=f.vec2.new(0,'+str(scroll)+')','f.onboarding:layout()')
        injection=injection.replace('walk(f.lab.frame,{0,0,'+str(width)+','+str(height)+'})',
            'walk(f.root,{0,0,'+str(width)+','+str(height)+'});walk(f.dancers.layer,{0,0,'+str(width)+','+str(height)+'});walk(f.skill.layer.Parent,{0,0,'+str(width)+','+str(height)+'});walk(f.onboarding.root,{0,0,'+str(width)+','+str(height)+'})')
    if target in ("Cards","Prestige","SkillTree"):
        page="f.cardPage" if target=="Cards" else "f.progression"
        injection=injection.replace('f:feature("Laboratory")',f'f:feature("{target}")')
        injection=injection.replace('f.lab.list.CanvasPosition',page+'.body.CanvasPosition')
        injection=injection.replace('walk(f.lab.frame,','walk('+page+'.frame,')
        if target=="SkillTree":
            injection=injection.replace(page+'.body.CanvasPosition=f.vec2.new(0,'+str(scroll)+')',page+':centerTree()')
    if target=="Robux":
        injection=injection.replace('f:feature("Laboratory")','f:feature("RobuxShop")')
        injection=injection.replace('f.lab.list.CanvasPosition','f.robuxShop.body.CanvasPosition')
        injection=injection.replace('walk(f.lab.frame,','walk(f.robuxShop.frame,')
    if target=="CLI":
        injection=injection.replace('f:feature("Laboratory")','f:main()')
        injection=injection.replace('f.lab.list.CanvasPosition=f.vec2.new(0,'+str(scroll)+')', '''
    local avatar=f.dancers.pool[1]
    f.dancers.layer.Size=f.udim2.fromOffset('''+str(width)+''','''+str(height)+''')
    avatar:activate({mascotId="ember_rare",familyId="ember",familyName="Ember",rarity="Rare",rank=2,
        fragments=2,collectibleId=999,width=128,x=.5,y=.75},false)
    f.dancers:showFragments(avatar,{id=999,fragments=2});avatar:hide()
    f.dancers:tick(.1)
''')
        injection=injection.replace('walk(f.lab.frame,','walk(f.root,')
        injection=injection.replace('    return 107','    walk(f.dancers.layer,{0,0,'+str(width)+','+str(height)+'})\n    return 107')
    source="local previewRows={}\n"+bundle(MODULES).replace("local passed,failures=0,{}","local passed,failures=0,{}\n"+injection)+"\nreturn table.concat(previewRows,'\\n')"
    state=lua.luaL_newstate();lua.luaL_openlibs(state);code=source.encode()
    try:
        if lua.luaL_loadbufferx(state,code,len(code),b"lab_preview",None) or lua.lua_pcallk(state,0,1,0,0,None):
            raise RuntimeError(lua.lua_tolstring(state,-1,None).decode())
        return lua.lua_tolstring(state,-1,None).decode()
    finally:lua.lua_close(state)

def render(width,height,scroll,name,target="Lab"):
    rows=geometry(width,height,scroll,target)
    (ROOT/f"build/{name}.tsv").write_text(rows,encoding="utf-8")
    image=Image.new("RGB",(width,height),(18,15,24));draw=ImageDraw.Draw(image)
    for row in rows.splitlines():
        values=row.split("\t");kind=values[0];x,y,w,h=map(float,values[1:5]);color=tuple(round(float(v)) for v in values[5:8])
        clip=tuple(map(float,values[11:15]));left,top,right,bottom=max(0,clip[0],x),max(0,clip[1],y),min(width,clip[2],x+w),min(height,clip[3],y+h)
        if right<=left or bottom<=top:continue
        if kind=="r":
            alpha=float(values[8])
            if alpha<=0:draw.rectangle((left,top,right-1,bottom-1),fill=color)
            else:
                dimensions=(max(1,round(right-left)),max(1,round(bottom-top)))
                image.paste(Image.new("RGB",dimensions,color),(round(left),round(top)),Image.new("L",dimensions,round((1-alpha)*255)))
                draw=ImageDraw.Draw(image)
        else:
            size=int(float(values[9]));font=ImageFont.truetype("C:/Windows/Fonts/consolab.ttf",size)
            text=values[15].replace("\\n","\n");lines=[]
            for line in text.splitlines():
                words=line.split();current=""
                for word in words:
                    trial=(current+" "+word).strip()
                    if font.getlength(trial)>w and current:lines.append(current);current=word
                    else:current=trial
                lines.append(current)
            layer=Image.new("RGBA",(max(1,round(w)),max(1,round(h))))
            painter=ImageDraw.Draw(layer);line_height=size+2;offset=max(0,(h-len(lines)*line_height)/2)
            for i,line in enumerate(lines):
                tx=(w-font.getlength(line))/2 if values[10]=="Center" else 0
                painter.text((tx,offset+i*line_height-2),line,font=font,fill=(*color,round((1-float(values[8]))*255)))
            crop=layer.crop((round(left-x),round(top-y),round(right-x),round(bottom-y)))
            image.paste(crop,(round(left),round(top)),crop)
            draw=ImageDraw.Draw(image)
    draw.text((12,height-12),"PRODUCTION GEOMETRY / APPROXIMATE FONT / NOT STUDIO",fill=(160,150,174),font=ImageFont.truetype("C:/Windows/Fonts/consola.ttf",10))
    image.save(ROOT/f"build/{name}.png")

if __name__=="__main__":
    import sys
    if "--ux" in sys.argv:
        for target in ("Lab","Cards","Prestige","SkillTree","Robux","Start"):
            render(1280,900,0,"fluid-"+target.lower()+"-wide",target)
            render(360,640,0,"fluid-"+target.lower()+"-narrow",target)
        for target in ("TransitionCover","TransitionReveal","TransitionReady"):
            render(1280,900,0,"fluid-"+target.lower(),target)
        render(1280,900,500,"fluid-lab-recipes","Lab")
    elif "--onboarding" in sys.argv:
        for target in ("Start","TutorialSkill","TutorialSell","TutorialVisitor","TutorialDone"):
            render(1280,900,0,"onboarding-"+target.lower()+"-wide",target)
            render(360,640,0,"onboarding-"+target.lower()+"-narrow",target)
        render(320,360,0,"onboarding-skill-short","TutorialSkill")
        render(320,360,0,"onboarding-visitor-short","TutorialVisitor")
    elif "--readability" in sys.argv:
        for target in ("Lab","Cards","Prestige","SkillTree","Robux"):
            render(1280,900,0,"readability-"+target.lower()+"-wide",target)
            render(360,640,0,"readability-"+target.lower()+"-narrow",target)
        render(1280,900,500,"readability-lab-recipes","Lab")
        render(360,640,500,"readability-lab-recipe-narrow","Lab")
        render(360,640,500,"readability-prestige-details","Prestige")
        render(1280,900,500,"readability-robux-offers","Robux")
    elif "--robux" in sys.argv:
        render(1280,900,0,"robux-shop-overview","Robux")
        render(1280,900,390,"robux-shop-offers","Robux")
        render(360,640,0,"robux-shop-mobile","Robux")
    elif "--header" in sys.argv:
        render(1280,720,0,"header-fragments-wide","CLI")
        render(360,640,0,"header-fragments-narrow","CLI")
    else:
        render(1280,900,0,"laboratory-polish-overview")
        render(1280,900,240,"laboratory-polish-recipes")
        render(360,640,320,"laboratory-polish-mobile")
