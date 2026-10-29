"""Offline source-art contact sheet; not a Roblox Studio rendering."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from generate_mascots import entries, ROOT

def main():
    catalog=json.loads((ROOT/"assets/mascots/catalog.json").read_text(encoding="utf-8-sig"))
    art={item["id"]:item for item in entries(catalog)}
    image=Image.new("RGB",(1040,1400),(22,19,29));draw=ImageDraw.Draw(image)
    try:
        font=ImageFont.truetype("C:/Windows/Fonts/consola.ttf",17)
        title=ImageFont.truetype("C:/Windows/Fonts/consolab.ttf",24)
    except OSError:
        font=title=ImageFont.load_default()
    draw.text((24,16),"AGENT LAB / 9 FAMILIES, 4 RARITIES",font=title,fill=(222,226,226))
    tiers=[("","COMMON",(170,192,184)),("_rare","RARE",(104,187,240)),
           ("_epic","EPIC",(187,116,238)),("_legendary","LEGENDARY",(244,193,76))]
    for column,(_,label,color) in enumerate(tiers): draw.text((24+column*256,60),label,font=font,fill=color)
    for row,base in enumerate(catalog["mascots"]):
        for column,(suffix,label,color) in enumerate(tiers):
            entry=art[base["id"]+suffix];x=24+column*256;y=92+row*142
            draw.rectangle((x,y,x+238,y+130),fill=(39,32,48),outline=color,width=2)
            palette=entry.get("palette",{"#":entry["color"]})
            for py,line in enumerate(entry["pixels"]):
                for px,symbol in enumerate(line):
                    if symbol!=".":draw.rectangle((x+55+px*8,y+8+py*8,x+62+px*8,y+15+py*8),fill=tuple(palette[symbol]))
            # Interior holes remain transparent in every tier, preserving the face.
            for py,line in enumerate(base["pixels"]):
                for px,symbol in enumerate(line):
                    if symbol=="." and 2<=px<=13: assert entry["pixels"][py][px]=="."
            draw.text((x+12,y+101),base["name"],font=font,fill=(222,226,226))
    draw.text((24,1380),"Source pixel art preview / native SVG geometry verified separately",font=font,fill=(154,147,164))
    output=ROOT/"build/agent-rarity-contact-sheet.png";image.save(output);print(output)
if __name__=="__main__":main()
