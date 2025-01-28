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

local ui={}

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- exports

local blur=exports.blur

-- assets

local assets={}
assets.textures={}
assets.fonts={}

assets.list={
    texs={
        "textures/bg.png",
        "textures/icon.png",
        "textures/progress.png",
    },

    fonts={
        {"Medium", 11},
        {"Bold", 10},
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
    if(assets.textures and #assets.textures > 0)then
        for i,v in pairs(assets.textures) do
            if(v and isElement(v))then
                destroyElement(v)
            end
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

ui.petrols={
    {1570.0980,1388.0770,10.8618,180},
    {1560.2920,1388.0770,10.8618,180}
}

local blip = createBlip(1570.0980,1388.0770,10.8618, 10)
setBlipVisibleDistance(blip, 500)

for i,v in pairs(ui.petrols) do
    local obj=createObject(1244, v[1], v[2], v[3]-0.2, 0, 0, 90-v[4])
    local col=createColSphere(v[1], v[2], v[3], 10)
end

ui.pos={
    [1]={sw/2-366/2/zoom, sh-350/zoom, 366/zoom, 115/zoom},
    [2]={sw/2-366/2/zoom+18/zoom, sh-350/zoom+9/zoom, 11/zoom, 13/zoom},
    [3]={sw/2-366/2/zoom+38/zoom, sh-350/zoom+9/zoom, 11/zoom, sh-350/zoom+9/zoom+13/zoom},
    [4]={0, sh-350/zoom+9/zoom, sw/2-366/2/zoom+38/zoom+313/zoom, sh-350/zoom+9/zoom+13/zoom},
    [5]={sw/2-366/2/zoom+14/zoom, sh-350/zoom+33/zoom, 339/zoom, 7/zoom},
    [6]={sw/2-366/2/zoom+14/zoom+2, sh-350/zoom+33/zoom+2, 335/zoom, 3},
    [7]={sw/2-366/2/zoom+14/zoom, sh-350/zoom+54/zoom, sw/2-366/2/zoom+14/zoom+339/zoom, 115/zoom},
    [8]={sw/2-366/2/zoom+1, sh-350/zoom+82/zoom, 366/zoom-2, 32/zoom}
}

ui.addedFuel=0
ui.addFuel=0.05

ui.cost=17

ui.shape=false

ui.onRender=function()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then ui.destroy() return end

    if(not ui.shape or not isElementWithinColShape(veh,ui.shape))then
        ui.destroy()
        return
    end

    local fuel=getElementData(veh, "vehicle:fuel") or 0
    local tank=getElementData(veh, "vehicle:fuelTank") or 25

    if(getKeyState("space"))then
        local add=ui.addedFuel+0.05
        if((fuel+add) < tank)then
            ui.addFuel=ui.addFuel+0.05
            ui.addedFuel=ui.addedFuel+0.05
        end
    else
        ui.addFuel=0.05
    end

    blur:dxDrawBlur(ui.pos[1][1], ui.pos[1][2], ui.pos[1][3], ui.pos[1][4])
    dxDrawImage(ui.pos[1][1], ui.pos[1][2], ui.pos[1][3], ui.pos[1][4], assets.textures[1])

    dxDrawImage(ui.pos[2][1], ui.pos[2][2], ui.pos[2][3], ui.pos[2][4], assets.textures[2])
    dxDrawText("Zapełnienie zbiornika", ui.pos[3][1], ui.pos[3][2], ui.pos[3][3], ui.pos[3][4], tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")

    dxDrawText(math.floor(fuel+ui.addedFuel).."l/"..math.floor(tank).."l", ui.pos[4][1], ui.pos[4][2], ui.pos[4][3], ui.pos[4][4], tocolor(150, 150, 150), 1, assets.fonts[1], "right", "center")

    dxDrawImage(ui.pos[5][1], ui.pos[5][2], ui.pos[5][3], ui.pos[5][4], assets.textures[3])
    dxDrawRectangle(ui.pos[6][1], ui.pos[6][2], ui.pos[6][3]*((fuel+ui.addedFuel)/tank), ui.pos[6][4], tocolor(52,129,68))

    dxDrawText("Aktualna cena za paliwo:", ui.pos[7][1], ui.pos[7][2], ui.pos[7][3], ui.pos[7][4], tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
    dxDrawText("$"..ui.cost.." / l", ui.pos[7][1], ui.pos[7][2], ui.pos[7][3], ui.pos[7][4], tocolor(150, 150, 150), 1, assets.fonts[1], "right", "top")

    local space=getKeyState("space") and tocolor(0, 200, 100) or tocolor(200, 200, 200)
    dxDrawRectangle(ui.pos[8][1], ui.pos[8][2], ui.pos[8][3], ui.pos[8][4], tocolor(200, 200, 200, 10))
    dxDrawText("SPACJA", ui.pos[8][1], ui.pos[8][2], ui.pos[8][3]+ui.pos[8][1], ui.pos[8][4]+ui.pos[8][2], space, 1, assets.fonts[2], "center", "center")
end

ui.create=function()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then return end

    exports.px_speedo:applyElementCustomDatas(veh)

    ui.destroy()
    
    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)

    ui.addedFuel=0
    ui.addFuel=0.05
end

ui.destroy=function()
    ui.shape=false

    assets.destroy()

    removeEventHandler("onClientRender", root, ui.onRender)

    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then return end

    if(ui.addedFuel > 1)then
        if(SPAM.getSpam())then return end

        triggerServerEvent("tank.pilot", resourceRoot, veh, ui.addedFuel, ui.cost)
        ui.addedFuel=0
        ui.addFuel=0.05
    end
end

addEventHandler("onClientColShapeHit", resourceRoot, function(hit, dim)
    if(hit == localPlayer and dim and isPedInVehicle(hit))then
        local veh=getPedOccupiedVehicle(hit)
        local type=exports.px_speedo:getVehicleSpeedoType(veh)
        if(type == 7 and not isElementInAir(veh))then
            ui.create()
            ui.shape=source
        end
    end
end)

addEventHandler("onClientColShapeLeave", resourceRoot, function(hit, dim)
    if(hit == localPlayer and dim and isPedInVehicle(hit))then
        ui.destroy()
    end
end)

function isElementInAir(element)
    local x, y, z = getElementPosition(element)
    local gZ = getGroundPosition(x, y, z)
    if element then 
		gZ=gZ+10
        return (z-gZ) > 0
    end
	return false
end