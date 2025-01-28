--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

blur=exports.blur
scroll=exports.px_scroll

-- global variables

sw,sh=guiGetScreenSize()
zoom=1920/sw

ui={}

ui.items={}

ui.catchPos=false
ui.click=false

ui.places={}
for i=1,3 do
    local sY=(120/zoom)*(i-1)
    for i=1,5 do
        local sX=(136/zoom)*(i-1)
        ui.places[#ui.places+1]={sX=sX, sY=sY}
    end
end

-- assets

assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/item.png",
        "textures/close.png"
    },

    fonts={
        {"Medium", 25},
        {"Regular", 12},
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

-- mouse

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
	if(not isCursorShowing() or ui.animate)then return end

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

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

-- block

addEventHandler("onClientVehicleStartEnter", resourceRoot, function()
    cancelEvent()
end)

-- exports

function action(id,element,name)
    if(name == "Przeszukaj busa")then
        if(not getElementData(element, "block"))then
            bus.create()
            bus.vehicle=element

            setElementData(element, "block", localPlayer)
            setElementData(localPlayer, "block", element)
        end
    elseif(name == "Włącz licznik")then
        if(not getElementData(element, "block"))then
            setElementData(element, "block", localPlayer)
            setElementData(localPlayer, "block", element)

            c.startTimer(element)
        end
    elseif(name == "Otwórz sejf")then
        if(not getElementData(element, "block"))then
            safe.create()
            safe.object=element

            setElementData(element, "block", localPlayer)
            setElementData(localPlayer, "block", element)
        end
    end
end