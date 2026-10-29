--!nonstrict
-- Original radial map and passive stepped hexagon geometry. No services/timers.
local Layout={nodeWidth=240,nodeHeight=208,padding=48,columnStep=280,rowStep=240}
local positions={
    boot={5,5},tokens={4,5},agents={4,4},focus={5,4},cache={4,6},swarm={3,4},context={6,6},
    focus10={6,3},core={5,6},focus15={6,2},fortune={3,5},overclock={3,3},memory={6,7},
    focus20={7,2},fortune2={2,5},swarm2={2,4},memory2={6,8},focus25={7,1},mastery={5,7},
    focus30={8,1},focus35={8,0},focus40={9,0},focus50={10,0},luck={6,5},luck2={7,5},luck3={8,5},luck4={9,5},
    cash1={1,5},cash2={0,5},cash3={0,4},cash4={0,3},speed1={2,3},speed2={1,3},speed3={1,2},speed4={1,1},
    luck5={10,5},luck6={11,5},luck7={11,6},luck8={11,7},chip4={7,8},chip5={7,9},chip6={8,9},chip7={8,10},
    swarm3={2,6},swarm4={1,6},swarm5={1,7},swarm6={0,7},focus60={10,1},focus70={10,2},focus80={11,2},focus100={11,3},
    fusion={3,1},magnet={2,9},singularity={5,10},
}
function Layout.position(id)
    local p=assert(positions[id],"Missing skill tree position: "..tostring(id))
    return {x=Layout.padding+p[1]*Layout.columnStep,y=Layout.padding+p[2]*Layout.rowStep,
        width=Layout.nodeWidth,height=Layout.nodeHeight}
end
function Layout.bounds(nodes)
    local width,height=0,0
    for _,node in ipairs(nodes) do
        local p=Layout.position(node.id)
        width=math.max(width,p.x+p.width+Layout.padding);height=math.max(height,p.y+p.height+Layout.padding)
    end
    return {width=width,height=height}
end
function Layout.hex(inset)
    inset=inset or 0
    local width,height=Layout.nodeWidth-2*inset,Layout.nodeHeight-2*inset
    local rects={}
    for y=0,height-1,8 do
        local h=math.min(8,height-y)
        local cut=math.floor((math.abs(y+h/2-height/2)/(height/2)*width/4)/4+.5)*4
        rects[#rects+1]={x=inset+cut,y=inset+y,width=width-2*cut,height=h}
    end
    return rects
end
function Layout.link(parent,child)
    local a,b=Layout.position(parent),Layout.position(child)
    local ax,ay=a.x+a.width/2,a.y+a.height/2
    local bx,by=b.x+b.width/2,b.y+b.height/2
    local dx,dy=bx-ax,by-ay
    local angle=math.atan2 and math.atan2(dy,dx) or math.atan(dy,dx)
    return {x=math.floor((ax+bx)/2),y=math.floor((ay+by)/2),
        length=math.ceil(math.sqrt(dx*dx+dy*dy)),angle=angle*180/math.pi}
end
function Layout.family(node)
    if node.id=="boot" or node.id=="core" or node.id=="mastery" or node.id=="fusion" or node.id=="singularity" then return "core" end
    if node.luck then return "luck" end
    if node.auto then return "focus" end
    if node.chip then return "memory" end
    if node.collect then return "swarm" end
    if node.speed then return "agents" end
    return "tokens"
end
return Layout
