--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local shader=dxCreateShader(":px_avatars/shaders/hud_mask.fx")

ui.mapPos={3000, 3000}
ui.pos=false
ui.newPos=false
ui.tickPos=0
ui.login=""
ui.positions={}

for i=1,2 do
    local sY=(485/zoom)*(i-1)
    for i=1,4 do
        local sX=(344/zoom)*(i-1)
        ui.positions[#ui.positions+1]={sX=sX,sY=sY}
    end
end

ui.spawnsAll={
    {name="LAS VENTURAS", color={21, 15, 54}, desc="Główne miejsce spawnu", pos={2583.1855,1583.6008,10.8203,181.2423}},
    {name="PRZECHOWALNIA LV", color={204, 194, 255}, desc="Tu przechowasz pojazdy", pos={2391.8057,1504.4500,10.8203,182.0479}},
    {name="URZĄD LV", color={255, 0, 47}, desc="Tu załatwisz najważniejsze sprawy", pos={944.1544,1733.2072,8.8516,89.8218}},
    {name="FORT CARSON", color={230, 0, 122}, desc="Okoliczne miasteczko", pos={-231.0611,1212.5624,19.7422,179.2279}},
    {name="WIOSKA AREA51", color={0, 200, 100}, desc="Nowa wioska", pos={49.9471,1810.6649,18.3672,355.2780}},
}
ui.spawns={}

ui.lastRow=1
ui.row=1

ui.draw["WYBÓR SPAWNU"]=function(a)
    local x,y,z=interpolateBetween(ui.pos[1],ui.pos[2],ui.pos[3],ui.newPos[1],ui.newPos[2],ui.newPos[3],(getTickCount()-ui.tickPos)/250,"InOutQuad")
    ui.pos={x,y,z}

    -- left map
    local w,h=ui.mapPos[1],ui.mapPos[2],ui.mapPos[3],ui.mapPos[4]
    local x,y=ui.pos[1],ui.pos[2]
    dxSetRenderTarget(ui.rt,true)
        x,y=x+3000,y-3000
        x,y=w*(x/6000),h*(y/-6000)

        dxDrawImage(-x+((510/2)/zoom)-100/zoom,-y+((1080/2)/zoom),w,h, ui.map)
    dxSetRenderTarget()

    dxSetShaderValue(shader, "sMaskTexture",assets.textures[10])
    dxSetShaderValue(shader, "sPicTexture", ui.rt)

    dxDrawImage(0,0,510/zoom,sh,shader, 0, 0, 0, tocolor(255,255,255,255)) -- map
    dxDrawImage(510/2/zoom-38/2/zoom-100/zoom, 1080/2/zoom-55/zoom, 38/zoom, 55/zoom, assets.textures[11], 0, 0, 0, tocolor(255,255,255,a)) -- placeholder

    -- right
    dxDrawImage(552/zoom, 22/zoom, 41/zoom, 41/zoom, (ui.avatar and isElement(ui.avatar)) and ui.avatar or assets.textures[7], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawText("Zalogowany jako:", 552/zoom+54/zoom, 22/zoom, 41/zoom, 41/zoom+22/zoom-20/zoom, tocolor(125,125,125,a), 1, assets.fonts[5], "left", "center")
    dxDrawText(ui.login, 552/zoom+54/zoom, 22/zoom, 41/zoom, 41/zoom+22/zoom+20/zoom, tocolor(200,200,200,a), 1, assets.fonts[4], "left", "center")

    local w,h=267/zoom,128/zoom
    alogo:dxDrawMiniLogo(sw-160/zoom,15/zoom,w/2.2,h/2.2,a)

    -- center
    ui.row=math.floor(scroll:dxScrollGetPosition(ui.spawnScroll)+1)

    if(ui.lastRow ~= ui.row)then
        for i,v in pairs(ui.positions) do
            destroyAnimation(v.animate)
            v.animate=false
            v.hoverAlpha=0
        end
        ui.lastRow=ui.row
    end

    local k=0
    for i=ui.row,ui.row+8 do
        k=k+1

        local v=ui.positions[k]
        if(v)then
            local k=ui.spawns[i]
            if(k)then
                v.hoverAlpha=v.hoverAlpha or 0
                if(isMouseInPosition(552/zoom+v.sX, 86/zoom+v.sY, 296/zoom, 434/zoom) and v.hoverAlpha < 255 and not v.animate and (not v.tick or (v.tick and (getTickCount()-v.tick) > 300)))then
                    v.animate=animate(0, 255, "Linear", 250, function(a)
                        v.hoverAlpha=a
                    end, function()
                        v.animate=false
                    end)
    
                    ui.newPos=k.pos
                    ui.tickPos=getTickCount()
                    v.tick=getTickCount()
                elseif(not isMouseInPosition(552/zoom+v.sX, 86/zoom+v.sY, 296/zoom, 434/zoom) and v.hoverAlpha > 0 and not v.animate and (not v.tick or (v.tick and (getTickCount()-v.tick) > 300)))then
                    v.tick=getTickCount()
                    v.animate=animate(100, 0, "Linear", 250, function(a)
                        v.hoverAlpha=a
                    end, function()
                        v.animate=false
                    end)
                end
    
                dxDrawImage(552/zoom+v.sX, 86/zoom+v.sY, 296/zoom, 434/zoom, assets.textures[12], 0, 0, 0, tocolor(k.color[1], k.color[2], k.color[3], a))
                dxDrawImage(552/zoom+v.sX-20/zoom, 86/zoom+v.sY+(448-434)/2/zoom, 326/zoom, 448/zoom, assets.textures[13], 0, 0, 0, tocolor(255,255,255,a))
    
                dxDrawImage(552/zoom+v.sX, 86/zoom+v.sY, 296/zoom, 434/zoom, assets.textures[14], 0, 0, 0, tocolor(255, 255, 255, v.hoverAlpha > a and a or v.hoverAlpha))
                if(v.hoverAlpha > 150)then
                    dxDrawImage(552/zoom+v.sX+(296-269)/2/zoom, 86/zoom+v.sY+(438-269)/2/zoom-33/zoom, 269/zoom, 269/zoom, assets.textures[15], 0, 0, 0, tocolor(255,255,255,v.hoverAlpha > a and a or v.hoverAlpha))
                else
                    dxDrawImage(552/zoom+v.sX+(296-269)/2/zoom, 86/zoom+v.sY+(438-269)/2/zoom-33/zoom, 269/zoom, 269/zoom, assets.textures[15], 0, 0, 0, tocolor(255,255,255,a > 150 and 150 or a))
                end
    
                dxDrawText(k.name, 552/zoom+v.sX+17/zoom, 86/zoom+v.sY+434/zoom-77/zoom, 296/zoom, 434/zoom, tocolor(200,200,200,a), 1, assets.fonts[4], "left", "top")
                dxDrawRectangle(552/zoom+v.sX+17/zoom, 86/zoom+v.sY+434/zoom-42/zoom, 46/zoom, 1, tocolor(86,86,86,a))
                dxDrawText(k.desc, 552/zoom+v.sX+17/zoom, 86/zoom+v.sY+434/zoom-35/zoom, 296/zoom, 434/zoom, tocolor(200,200,200,a), 1, assets.fonts[5], "left", "top")
    
                onClick(552/zoom+v.sX, 86/zoom+v.sY, 296/zoom, 434/zoom, function()
                    if(SPAM.getSpam())then return end

                    ui.destroy(ui.login, k.pos)
                end)
            end
        end
    end
end