--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local BW = {}

local blur=exports.blur

BW.rot = 0
BW.time = 0
BW.tick = getTickCount()
BW.rotCam = 0
BW.times=0
BW.ticked=getTickCount()
BW.alpha=0
BW.defTime=60

BW.onRender = function()
    -- variables
    local time=(BW.times*1000)+7000
    BW.alpha=interpolateBetween(255, 0, 0, 0, 0, 0, (getTickCount()-BW.ticked)/time, "Linear")

    local a2=BW.alpha > 150 and 150 or BW.alpha
    local r,g,b=interpolateBetween(200, 0, 0, 30, 30, 30, (getTickCount()-BW.ticked)/time, "Linear")

    BW.rotCam = BW.rotCam+0.15

    local pos = {getElementPosition(localPlayer)}
	pos[3] = pos[3]+5
    --

    -- camera
	cPos = {getPointFromDistanceRotation(pos[1], pos[2], 2, BW.rotCam)}
	setCameraMatrix(cPos[1], cPos[2], pos[3], pos[1], pos[2], pos[3]-5)
    --

    -- rendering
    blur:dxDrawBlur(0, 0, sw, sh, tocolor(255, 255, 255, BW.alpha))
    dxDrawRectangle(0, 0, sw, sh, tocolor(r,g,b, a2))
    --

    -- functions
    if((getTickCount()-BW.tick) > 1000)then
        BW.time = BW.time-1
        BW.tick = getTickCount()
        setElementData(localPlayer, "user:bw", BW.time)
    end

    if(BW.time == 0 or getElementHealth(localPlayer) > 0 or not getElementData(localPlayer, "user:bw"))then
        triggerServerEvent("bw.spawn", resourceRoot)
        setElementData(localPlayer, "user:hud_disabled", false)

        showChat(true)

        removeEventHandler("onClientRender", root, BW.onRender)

        setElementData(localPlayer, "user:bw", false)
    end
end

addEvent('stopBW', true)
addEventHandler('stopBW', resourceRoot, function()
    removeEventHandler("onClientRender", root, BW.onRender)

    setElementData(localPlayer, "user:hud_disabled", false)

    showChat(true)

    setElementData(localPlayer, "user:bw", false)
end)

addEventHandler("onClientPlayerWasted", getLocalPlayer(), function()
    blur=exports.blur
    
    addEventHandler("onClientRender", root, BW.onRender)

    BW.times=BW.defTime
    BW.time=BW.times

    BW.tick = getTickCount()
    BW.ticked=getTickCount()

    showChat(false)
    setElementData(localPlayer, "user:hud_disabled", true, false)
    setElementData(localPlayer, "user:bw", BW.times)
end)

-- useful

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end
