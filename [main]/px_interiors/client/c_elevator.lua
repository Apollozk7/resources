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

-- variables

local load = exports.px_loading
local blur=exports.blur

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local UI={}

UI.posZ=false

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-ExtraBold.ttf", 40},
    },

    textures={},
    textures_paths={
        "assets/images/bg.png",
        "assets/images/button.png",
        "assets/images/button_hover.png",
    },
}

-- functions

UI.onRender=function()
    blur:dxDrawBlur(sw-215/zoom, sh/2-400/2/zoom, 157/zoom, 400/zoom)
    dxDrawImage(sw-215/zoom, sh/2-400/2/zoom, 157/zoom, 400/zoom, assets.textures[1])

    for i=1,3 do
        local sY=(121/zoom)*(i-1)
        dxDrawImage(sw-215/zoom+(157-94)/2/zoom, sh/2-400/2/zoom+32/zoom+sY, 94/zoom, 94/zoom, isMouseInPosition(sw-215/zoom+(157-94)/2/zoom, sh/2-400/2/zoom+32/zoom+sY, 94/zoom, 94/zoom) and assets.textures[3] or assets.textures[2])
        dxDrawText((i-1), sw-215/zoom+(157-94)/2/zoom, sh/2-400/2/zoom+32/zoom+sY, 94/zoom+sw-215/zoom+(157-94)/2/zoom, 94/zoom+sh/2-400/2/zoom+32/zoom+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")
    
        onClick(sw-215/zoom+(157-94)/2/zoom, sh/2-400/2/zoom+32/zoom+sY, 94/zoom, 94/zoom, function()
            local z=UI.posZ[i]
            if(z)then
                removeEventHandler("onClientRender", root, UI.onRender)
                assets.destroy()
        
                showCursor(false)
        
                setElementFrozen(localPlayer, true)
        
                load:createLoadingScreen(true, false, 3000)
        
                setTimer(function()
                    if(SPAM.getSpam())then return end
        
                    triggerServerEvent("teleport.player", resourceRoot, z)
        
                    setTimer(function()
                        setElementFrozen(localPlayer, false)
        
                        UI.posZ=false
                        UI.marker=false
                    end, 3000, 1)
                end, 550, 1)
            end
        end)
    end

    if(not UI.marker or (UI.marker and not isElement(UI.marker)) or not isElementWithinMarker(localPlayer, UI.marker))then
        removeEventHandler("onClientRender", root, UI.onRender)
        assets.destroy()

        UI.posZ=false
        UI.marker=false

        showCursor(false)
    end
end

-- triggers

addEvent("open.elevator", true)
addEventHandler("open.elevator", resourceRoot, function(marker, posZ)
    load = exports.px_loading
    blur=exports.blur

    UI.posZ=posZ
    UI.marker=marker
    
    addEventHandler("onClientRender", root, UI.onRender)

    assets.create()

    showCursor(true, false)
end)

-- main variables

assets.create = function()
    for k,t in pairs(assets) do
        if(k=="fonts_paths")then
            for i,v in pairs(t) do
                assets.fonts[i] = dxCreateFont(v[1], v[2]/zoom)
            end
        elseif(k=="textures_paths")then
            for i,v in pairs(t) do
                assets.textures[i] = dxCreateTexture(v, "argb", false, "clamp")
            end
        end
    end
end

assets.destroy = function()
    for k,t in pairs(assets) do
        if(k == "textures" or k == "fonts")then
            for i,v in pairs(t) do
                if(v and isElement(v))then
                    destroyElement(v)
                end
            end
            assets.fonts={}
            assets.textures={}
        end
    end
end

-- useful

function isMouseInPosition(x, y, w, h)
	if(not isCursorShowing())then return end

	local cx,cy=getCursorPosition()
	cx,cy=cx*sw,cy*sh
	
    if(isCursorShowing() and (cx >= x and cx <= (x + w)) and (cy >= y and cy <= (y + h)))then
        return true
    end
    return false
end

function getPosition(myX, myY, x, y, w, h)
    if(isCursorShowing() and (myX >= x and myX <= (x + w)) and (myY >= y and myY <= (y + h)))then
        return true
    end
    return false
end

local mouseState=false
local mouseTick=getTickCount()
local mouseClicks=0
local mouseClick=false
function onClick(x, y, w, h, fnc)
	if(not isCursorShowing())then return end

	if((getTickCount()-mouseTick) > 1000 and mouseClicks > 0)then
		mouseClicks=mouseClicks-1
	end

	if(not mouseState and getKeyState("mouse1"))then
		local cursor={getCursorPosition()}
        mouseState=cursor
    elseif(not getKeyState("mouse1") and (mouseClick or mouseState))then
        mouseClick=false
        mouseState=false
    end

    if(mouseState and mouseClicks < 10 and not mouseClick)then
		local cx,cy=unpack(mouseState)
        cx,cy=cx*sw,cy*sh

        if(getPosition(cx, cy, x, y, w, h))then
			fnc()

			mouseClicks=mouseClicks+1
            mouseTick=getTickCount()
            mouseClick=true
        end
	end
end