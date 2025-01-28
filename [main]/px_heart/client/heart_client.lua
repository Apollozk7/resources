--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh = guiGetScreenSize()

local HEART = {}

HEART.tick = getTickCount()
HEART.sound = false

HEART.onRender = function()
    if(getElementHealth(localPlayer) > 15)then
        removeEventHandler("onClientRender", root, HEART.onRender)

        if(HEART.sound and isElement(HEART.sound))then
            stopSound(HEART.sound)
            HEART.sound = false
        end
    end

    if(not getElementData(localPlayer, "user:hud_disabled"))then
        local a = interpolateBetween(0, 0, 0, 50, 0, 0, (getTickCount()-HEART.tick)/1500, "SineCurve")
        dxDrawRectangle(0, 0, sw, sh, tocolor(255, 0, 0, a), true)
    end
end

addEventHandler("onClientPlayerDamage", getLocalPlayer(), function()
    if(getElementHealth(localPlayer) < 15 and not HEART.sound)then
        addEventHandler("onClientRender", root, HEART.onRender)
        
        HEART.sound = playSound("assets/sound/heart.mp3", true)
    end
end)