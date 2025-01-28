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
local btns=exports.px_buttons
local noti=exports.px_noti

-- assets

local assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/row.png",
        "textures/close.png",
    },

    fonts={
        {"Medium", 13},
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

ui.mandates={}

ui.trigger=0

ui.btns={}

-- functions

floor=math.floor

ui.onRender=function()
    -- 850x300
    blur:dxDrawBlur(sw/2-850/2/zoom, sh/2-300/2/zoom, 850/zoom, 400/zoom)
    dxDrawImage(sw/2-850/2/zoom, sh/2-300/2/zoom, 850/zoom, 400/zoom, assets.textures[1])

    dxDrawText("Opłacanie mandatów", sw/2-850/2/zoom, sh/2-300/2/zoom, sw/2-850/2/zoom+850/zoom, sh/2-300/2/zoom+55/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "center", "center")

    dxDrawRectangle(sw/2-800/2/zoom, sh/2-300/2/zoom+55/zoom, 800/zoom, 1, tocolor(85, 85, 85, 255))

    dxDrawImage(sw/2-800/2/zoom+800/zoom-10/zoom, sh/2-300/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, 255))

    dxDrawText("Posiadasz "..#ui.mandates.." mandatów, opłać wszystkie lub wykonaj przelew.", sw/2-800/2/zoom, sh/2-300/2/zoom+65/zoom, sw/2-850/2/zoom+850/zoom, sh/2-300/2/zoom+55/zoom, tocolor(150, 150, 150, 255), 1, assets.fonts[1], "left", "top")

    -- mandaty
    local row=1
    local x=0
    local tbl=ui.mandates
    for i=row,row+3 do
        local v=tbl[i]
        if(v)then
            x=x+1
            local sY=(70/zoom)*(x-1)

            dxDrawImage(sw/2-800/2/zoom, sh/2-300/2/zoom+100/zoom+sY, 800/zoom, 68/zoom, assets.textures[2])

            if(v)then
                if(dxGetTextWidth(v.name,1,assets.fonts[1]) >= 620/zoom)then
                    dxDrawText(v.name, floor(sw/2-800/2/zoom+15/zoom), floor(sh/2-300/2/zoom+100/zoom+sY), floor(sw/2-800/2/zoom+15/zoom)+floor(620/zoom), floor(sh/2-300/2/zoom+100/zoom+sY+46/zoom), tocolor(185, 185, 185, 255), 1, assets.fonts[1], "left", "top", false, true)
                    dxDrawText("$"..convertNumber(v.money).." ("..v.date..")", sw/2-800/2/zoom+15/zoom, sh/2-300/2/zoom+100/zoom+sY, 800/zoom, sh/2-300/2/zoom+100/zoom+sY+68/zoom-5/zoom, tocolor(140, 140, 140, 255), 1, assets.fonts[1], "left", "bottom")    
                else
                    dxDrawText(v.name, floor(sw/2-800/2/zoom+15/zoom), floor(sh/2-300/2/zoom+100/zoom+sY+10/zoom), floor(800/zoom), floor(sh/2-300/2/zoom+100/zoom+sY+46/zoom), tocolor(185, 185, 185, 255), 1, assets.fonts[1], "left", "top")
                    dxDrawText("$"..convertNumber(v.money).." ("..v.date..")", sw/2-800/2/zoom+15/zoom, sh/2-300/2/zoom+100/zoom+sY, 800/zoom, sh/2-300/2/zoom+100/zoom+sY+46/zoom+10/zoom, tocolor(140, 140, 140, 255), 1, assets.fonts[1], "left", "bottom")    
                end

                onClick(sw/2-800/2/zoom+800/zoom-130/zoom-10/zoom, sh/2-300/2/zoom+100/zoom+sY+(46-31)/2/zoom, 130/zoom, 31/zoom, function()
                    if(SPAM.getSpam())then return end

                    triggerServerEvent("G.payMandate", resourceRoot, v, i)

                    ui.destroy()
                end)
            else
                dxDrawText("----", sw/2-800/2/zoom+15/zoom, sh/2-300/2/zoom+100/zoom+sY+10/zoom, 800/zoom, sh/2-300/2/zoom+100/zoom+sY+46/zoom, tocolor(185, 185, 185, 255), 1, assets.fonts[1], "left", "top")
                dxDrawText("----", sw/2-800/2/zoom+15/zoom, sh/2-300/2/zoom+100/zoom+sY, 800/zoom, sh/2-300/2/zoom+100/zoom+sY+46/zoom+10/zoom, tocolor(140, 140, 140, 255), 1, assets.fonts[1], "left", "bottom")
            end
        end
    end

    onClick(sw/2-800/2/zoom+800/zoom-130/zoom, sh/2-300/2/zoom+61/zoom, 130/zoom, 31/zoom, function()
        if(SPAM.getSpam())then return end

        triggerServerEvent("G.payMandate", resourceRoot)

        ui.destroy()
    end)

    onClick(sw/2-800/2/zoom+800/zoom-10/zoom, sh/2-300/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, function()
        ui.destroy()
    end)
end

ui.create=function(mandates)
    if(getElementData(localPlayer, "user:gui_showed"))then return end

    blur=exports.blur
    btns=exports.px_buttons
    noti=exports.px_noti

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)

    showCursor(true)

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    ui.mandates=mandates

    ui.btns[1]=btns:createButton(sw/2-800/2/zoom+800/zoom-150/zoom, sh/2-300/2/zoom+62/zoom, 150/zoom, 31/zoom, "OPŁAĆ WSZYSTKO", 255, 9/zoom, false, false, ":px_factions_mandates/textures/button.png", {44,128,192})
    for i=1,(#ui.mandates < 4 and #ui.mandates or 4) do
        local sY=(70/zoom)*(i-1)
        ui.btns[i+1]=btns:createButton(sw/2-800/2/zoom+800/zoom-130/zoom-10/zoom, sh/2-300/2/zoom+100/zoom+sY+(68-31)/2/zoom, 130/zoom, 31/zoom, "WYŚLIJ PRZELEW", 255, 7/zoom, false, false, ":px_factions_mandates/textures/button.png")
    end
end
addEvent("G.openInterface", true)
addEventHandler("G.openInterface", resourceRoot, ui.create)

ui.destroy=function()
    showCursor(false)

    removeEventHandler("onClientRender", root, ui.onRender)

    assets.destroy()

    for i,v in pairs(ui.btns) do
        btns:destroyButton(v)
    end
    ui.btns={}

    setElementData(localPlayer, "user:gui_showed", false, false)
end

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)

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
function onClick(x, y, w, h, fnc, key)
	if(not isCursorShowing())then return end

	if((getTickCount()-mouseTick) > 1000 and mouseClicks > 0)then
		mouseClicks=mouseClicks-1
	end

	if(not mouseState and getKeyState(key or "mouse1"))then
		local cursor={getCursorPosition()}
        mouseState=cursor
    elseif(not getKeyState(key or "mouse1") and (mouseClick or mouseState))then
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

function convertNumber(money)
	for i = 1, tostring(money):len()/3 do
		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1,%2")
	end
	return money
end