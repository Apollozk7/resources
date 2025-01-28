--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer)then
        killTimer(SPAM.blockSpamTimer)
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

local e_blur=exports.blur

local ui={}

-- assets

local assets={}
assets.list={
    texs={
        "textures/right_button.png",
        "textures/right_button_light.png",
        "textures/middle_bg.png",
        "textures/enter_button.png",
        "textures/x_button.png",
    
        "textures/elipse.png",
        "textures/elipse_border.png",
    
        "textures/bg.png",
    },

    fonts={
        {"Regular", 11},
        {"Bold", 15},
        {"Regular", 15},
        {"Regular", 13},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts={}
    for i,v in pairs(assets.list.fonts) do
        assets.fonts[i]=dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom)
    end
end

assets.destroy=function()
    for i,v in pairs(assets.textures) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.textures={}

    for i,v in pairs(assets.fonts) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.fonts={}
end

-- variables

ui.selected=1
ui.selectedMenu=1
ui.apply=false
ui.lights={}
ui.panel=false

ui.colors={
    {"Standardowe",rgb={255,255,255}, cost=100},

    {"Magenta",rgb={100,58,173}, cost=10200},
    {"Club",rgb={212,5,225}, cost=13080},
    {"Watercoral",rgb={89,191,142}, cost=15800},
    {"Rust",rgb={217,180,52}, cost=11800},
    {"Diablo",rgb={255,73,25}, cost=12200},
    {"Valentine",rgb={247,32,88}, cost=17200},
    {"Snot",rgb={25,255,127}, cost=19200},
    {"Fluo",rgb={166,242,37}, cost=21600},
    {"Plaster",rgb={213,97,66}, cost=21600},
    {"Dirt",rgb={180,124,99}, cost=8550},
    {"Matrix",rgb={103,100,225}, cost=7850},
    {"Tundra",rgb={9,175,40}, cost=9400},
    {"Weathered",rgb={180,85,96}, cost=8750},
    {"Sea",rgb={85,225,241}, cost=11250},
    {"Hit",rgb={225,17,17}, cost=19950},
}

ui.alphaTable={
    [1]=125,
    [2]=75,
    [3]=50,
    [4]=20,
}

ui.pos={
    center={sw/2-227/2/zoom, sh-83/zoom, 227/zoom, 49/zoom},
    color_text={sw/2-227/2/zoom-49/zoom, sh-83/zoom-49/zoom/2, 227/zoom+sw/2-227/2/zoom+49/zoom, 49/zoom},
    selectedColor={sw/2-227/2/zoom+(227/zoom-13/zoom)/2, sh-83/zoom+(49/zoom-13/zoom)/2, 13/zoom, 13/zoom},
    selectedColor_elipse={sw/2-227/2/zoom+(227/zoom-23/zoom)/2, sh-83/zoom+(49/zoom-23/zoom)/2, 23/zoom, 23/zoom},
    color={sw/2-227/2/zoom+(227/zoom-13/zoom)/2, sh-83/zoom+(49/zoom-13/zoom)/2, 13/zoom, 13/zoom},

    enter_button={sw/2-227/2/zoom+227/zoom+49/zoom+14/zoom, sh-83/zoom, 119/zoom, 49/zoom},
    enter_text={sw/2-227/2/zoom+227/zoom+49/zoom+14/zoom+9/zoom+119/zoom, sh-83/zoom, 119/zoom, sh-83/zoom+49/zoom},

    x_button={sw/2-227/2/zoom-49/zoom-49/zoom-14/zoom, sh-83/zoom, 49/zoom, 49/zoom},
    x_text={sw/2-227/2/zoom-49/zoom-49/zoom-14/zoom, sh-83/zoom, sw/2-227/2/zoom-49/zoom-49/zoom-14/zoom-14/zoom, sh-83/zoom+49/zoom},

    sX=24/zoom,

    ml_bg={sw/2-326/2/zoom, sh-83/zoom, 326/zoom, 49/zoom},
    ml_bg2={sw/2-326/2/zoom, sh-83/zoom-99/zoom+1, 326/zoom, 99/zoom},
}

ui.multiLed={
    cost=25000,

    colors={
        {"LED Biały", 255,255,255},
        {"LED Czerwony", 218,68,83},
        {"LED Pomarańczowy", 233,87,63},
        {"LED Żółty", 246,187,66},
        {"LED Zielony", 140,193,82},
        {"LED Morski", 55,188,155},
        {"LED Niebieski", 74,137,220},
        {"LED Fioletowy", 150,122,220},
        {"LED Różowy", 215,112,173}
    },

    desc=[[#da4453M#e9573fu#f6bb42l#8cc152t#37bc9bi#4a89dcL#967adcE#d770adD #7a7a7ato narzędzie, które w dowolnym
momencie z poziomu interakcji pojazdu 
pozwala na przełączanie koloru świateł. 
W zestawie znajdują się następujące kolory:]]
}

-- rendering, etc

ui.onRender=function()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then ui.destroy() return end

    local p=ui.pos
    
    if(ui.selectedMenu == 1)then
        dxDrawBlurImage(p.center[1]-p.center[4]+1, p.center[2], p.center[4], p.center[4], getKeyState("arrow_l") and assets.textures[2] or assets.textures[1], 180, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawBlurImage(p.center[1]+p.center[3]-1, p.center[2], p.center[4], p.center[4], getKeyState("arrow_r") and assets.textures[2] or assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawBlurImage(p.center[1], p.center[2], p.center[3], p.center[4], assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, 255))

        local x=0
        local k=0
        for i=ui.selected-4,ui.selected+4 do
            local v=ui.colors[i]
            if(v)then
                if(i == ui.selected)then
                    dxDrawImage(ui.pos.selectedColor[1], ui.pos.selectedColor[2], ui.pos.selectedColor[3], ui.pos.selectedColor[4], assets.textures[6], 0, 0, 0, tocolor(v.rgb[1], v.rgb[2], v.rgb[3], 255))
                    dxDrawImage(ui.pos.selectedColor_elipse[1], ui.pos.selectedColor_elipse[2], ui.pos.selectedColor_elipse[3], ui.pos.selectedColor_elipse[4], assets.textures[7], 0, 0, 0, tocolor(255,255,255,255))
                    
                    dxDrawShadowText("Kolor świateł", p.color_text[1], p.color_text[2], p.color_text[3], p.color_text[4], tocolor(200, 200, 200, 255), 1, assets.fonts[4], "left", "top")
                    dxDrawShadowText(v[1], p.color_text[1], p.color_text[2], p.color_text[3], p.color_text[4], tocolor(v.rgb[1], v.rgb[2], v.rgb[3], 255), 1, assets.fonts[4], "right", "top")
                elseif(i < ui.selected)then
                    local left=ui.selected-1
                    if(ui.selected > 4)then
                        left=4
                    end

                    local pos=ui.pos.color[1]-((p.sX)*left)

                    x=x+1
                    pos=pos+((p.sX)*(x-1))

                    local aa=ui.alphaTable[left+1-x] or 255
                    dxDrawImage(pos, ui.pos.color[2], ui.pos.color[3], ui.pos.color[4], assets.textures[6], 0, 0, 0, tocolor(v.rgb[1], v.rgb[2], v.rgb[3], aa))
                else
                    k=k+1

                    local sX=(p.sX)*(k)
                    local aa=ui.alphaTable[k] or 255
                    dxDrawImage(ui.pos.color[1]+sX, ui.pos.color[2], ui.pos.color[3], ui.pos.color[4], assets.textures[6], 0, 0, 0, tocolor(v.rgb[1], v.rgb[2], v.rgb[3], aa))
                end
            end
        end

        local value=ui.colors[ui.selected]
        if(value)then
            local cost=getElementData(veh, "vehicle:group_owner") and value.cost*2 or value.cost
            dxDrawBlurImage(p.enter_button[1], p.enter_button[2], p.enter_button[3], p.enter_button[4], assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, 255))
            dxDrawShadowText("KUP", p.enter_text[1], p.enter_text[2], p.enter_text[3], p.enter_text[4], tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
            dxDrawText("$"..cost, p.enter_text[1]+1, p.enter_text[2]+1, p.enter_text[3]+1, p.enter_text[4]+1, tocolor(0, 0, 0), 1, assets.fonts[3], "left", "bottom")
            dxDrawText("#65ad69$#cdcdcd"..cost, p.enter_text[1], p.enter_text[2], p.enter_text[3], p.enter_text[4], tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom", false, false, false, true)
        end

        dxDrawBlurImage(p.x_button[1], p.x_button[2], p.x_button[3], p.x_button[4], assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawShadowText("MultiLED", p.x_text[1], p.x_text[2], p.x_text[3], p.x_text[4], tocolor(200, 200, 200), 1, assets.fonts[2], "right", "top")
        dxDrawShadowText("Zobacz nowość", p.x_text[1], p.x_text[2], p.x_text[3], p.x_text[4], tocolor(200, 200, 200), 1, assets.fonts[3], "right", "bottom", false, false, false, true)
    elseif(ui.selectedMenu == 2)then
        dxDrawBlurImage(p.ml_bg[1], p.ml_bg[2], p.ml_bg[3], p.ml_bg[4], assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, 255))
        local colors_width=(25/zoom)*(#ui.multiLed.colors-1)
        for i,v in pairs(ui.multiLed.colors) do
            local sX=(p.sX)*(i-1)
            dxDrawImage(p.ml_bg[1]+(p.ml_bg[3]-colors_width)/2+sX, p.color[2], p.color[3], p.color[4], assets.textures[6], 0, 0, 0, tocolor(v[2], v[3], v[4], 255))
        end

        dxDrawBlurImage(p.ml_bg2[1], p.ml_bg2[2], p.ml_bg2[3], p.ml_bg2[4], assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawText(ui.multiLed.desc, p.ml_bg2[1], p.ml_bg2[2], p.ml_bg2[3]+p.ml_bg2[1], p.ml_bg2[4]+p.ml_bg2[2], tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center", false, true, false, true)

        local cost=getElementData(veh, "vehicle:group_owner") and ui.multiLed.cost*2 or ui.multiLed.cost
        dxDrawBlurImage(p.enter_button[1], p.enter_button[2], p.enter_button[3], p.enter_button[4], assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawShadowText("KUP", p.enter_text[1], p.enter_text[2], p.enter_text[3], p.enter_text[4], tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
        dxDrawText("$"..cost, p.enter_text[1]+1, p.enter_text[2]+1, p.enter_text[3]+1, p.enter_text[4]+1, tocolor(0, 0, 0), 1, assets.fonts[3], "left", "bottom")
        dxDrawText("#65ad69$#cdcdcd"..cost, p.enter_text[1], p.enter_text[2], p.enter_text[3], p.enter_text[4], tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom", false, false, false, true)

        dxDrawBlurImage(p.x_button[1], p.x_button[2], p.x_button[3], p.x_button[4], assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawShadowText("POWRÓT", p.x_text[1], p.x_text[2], p.x_text[3], p.x_text[4], tocolor(200, 200, 200), 1, assets.fonts[2], "right", "top")
        dxDrawShadowText("do kolorów", p.x_text[1], p.x_text[2], p.x_text[3], p.x_text[4], tocolor(200, 200, 200), 1, assets.fonts[3], "right", "bottom", false, false, false, true)
    end
end

ui.onKey=function(key, press)
    if(not press)then return end

    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then ui.destroy() return end

    if(key == "arrow_l")then
        if(ui.selected > 1)then
            ui.selected=ui.selected-1
            setVehicleHeadLightColor(veh, unpack(ui.colors[ui.selected].rgb))
        end
    elseif(key == "arrow_r")then
        if(ui.selected < #ui.colors)then
            ui.selected=ui.selected+1
            setVehicleHeadLightColor(veh, unpack(ui.colors[ui.selected].rgb))
        end
    elseif(key == "enter")then
        if(SPAM.getSpam())then return end

        triggerLatentServerEvent("buy.lights", resourceRoot, ui.selectedMenu == 2 and ui.multiLed or ui.colors[ui.selected])
    elseif(key == "x")then
        ui.selectedMenu=ui.selectedMenu == 1 and 2 or 1
    end
end

-- create

ui.create=function()
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(not vehicle or ui.panel)then return end

    if(getElementHealth(vehicle) < 1000)then
        noti:noti("Aby ulepszyć pojazd, musi on być sprawny.", "error")
        return
    end

    if(getElementData(localPlayer, "user:gui_showed"))then return end

    local uid=getElementData(localPlayer, "user:uid")    
    local owner=getElementData(vehicle, "vehicle:owner") or getElementData(vehicle, "vehicle:liderUID")
    if(not uid or not owner or (owner and owner ~= uid))then 
        noti:noti("Pojazd nie należy do Ciebie.", "error")
        return 
    end

    e_blur=exports.blur

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)
    addEventHandler("onClientKey", root, ui.onKey)

    ui.selected=1
    ui.selectedMenu=1

    toggleControl("enter_exit", false)

    ui.apply=false

    ui.lights={getVehicleHeadLightColor(vehicle)}

    ui.panel=true

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
end

ui.destroy=function(light)
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(not vehicle or not ui.panel)then return end

    if(getElementData(localPlayer, "user:gui_showed") ~= resourceRoot)then return end

    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientKey", root, ui.onKey)

    assets.destroy()

    toggleControl("enter_exit", true)

    if(not light)then
        setVehicleHeadLightColor(vehicle, unpack(ui.lights))
        ui.lights=false
    end

    ui.panel=false

    setElementData(localPlayer, "user:gui_showed", false, false)
end

-- triggers

addEvent("open.ui", true)
addEventHandler("open.ui", resourceRoot, function()
    ui.create()
end)

addEvent("destroy.ui", true)
addEventHandler("destroy.ui", resourceRoot, function(lights)
    ui.destroy(lights)
end)

-- useful

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function dxDrawShadowText(text,x,y,w,h,color,size,font,alignX,alignY)
    dxDrawText(text,x+1,y+1,w+1,h+1,tocolor(0,0,0),size,font,alignX,alignY)
    dxDrawText(text,x,y,w,h,color,size,font,alignX,alignY)
end

function dxDrawBlurImage(x,y,w,h,tex,rx,ry,rz,color)
    e_blur:dxDrawBlur(x,y,w,h,color)
    dxDrawImage(x,y,w,h,tex,rx,ry,rz,color)
end

-- exports

function getMultiLEDColors(color)
    return color and ui.multiLed.colors[color] or ui.multiLed.colors
end

-- on stop

addEventHandler("onClientResourceStop", resourceRoot, function()
    local data=getElementData(localPlayer, "user:gui_showed")
    if(data and data == resourceRoot)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)