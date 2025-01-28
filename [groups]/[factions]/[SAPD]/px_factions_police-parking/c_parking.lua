--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local blur=exports.blur

-- variables

local sw,sh = guiGetScreenSize()
local baseX = 1920
local zoom = 1
local minZoom = 2

if sw < baseX then
    zoom = math.min(minZoom, baseX/sw)
end


local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Regular.ttf", 14},
        {":px_assets/fonts/Font-Medium.ttf", 17},
    },

    textures={},
    textures_paths={
        "textures/get/header.png",
        "textures/get/row.png",
        "textures/get/choose.png",
        "textures/get/window.png",
    },
}

--

local UI={}

UI.vehs={}

--

UI.onRender=function()
    blur:dxDrawBlur(60/zoom, 56/zoom, 366/zoom, 67/zoom, tocolor(255, 255, 255))
    dxDrawImage(60/zoom, 56/zoom, 366/zoom, 67/zoom, assets.textures[1])

    for i,v in pairs(UI.vehs) do
        local sY=(51/zoom)*(i-1)
        blur:dxDrawBlur(60/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom, tocolor(255, 255, 255))
        dxDrawImage(60/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom, assets.textures[2])

        if(isMouseInPosition(60/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom))then
            dxDrawRectangle(60/zoom, 56/zoom+67/zoom+2+sY+49/zoom-1, 366/zoom, 1, tocolor(53, 130, 74))
            dxDrawImage(60/zoom+18/zoom, 56/zoom+67/zoom+2+sY+(49-12)/2/zoom, 12/zoom, 12/zoom, assets.textures[3])
            dxDrawText("["..v.id.."] "..getVehicleNameFromModel(v.model), 60/zoom+41/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom+56/zoom+67/zoom+2+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
        
            -- prawo
            blur:dxDrawBlur(60/zoom+366/zoom+5/zoom, 56/zoom, 406/zoom, 266/zoom, tocolor(255, 255, 255))
            dxDrawImage(60/zoom+366/zoom+5/zoom, 56/zoom, 406/zoom, 266/zoom, assets.textures[4])
            
            dxDrawText(getVehicleNameFromModel(v.model), 60/zoom+366/zoom+5/zoom+30/zoom, 56/zoom+15/zoom, 406/zoom, 266/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
            dxDrawText("ID "..v.id, 60/zoom+366/zoom+5/zoom+30/zoom, 56/zoom+43/zoom, 406/zoom, 266/zoom, tocolor(150, 150, 150), 1, assets.fonts[1], "left", "top")

            dxDrawRectangle(60/zoom+366/zoom+5/zoom+(406-342)/2/zoom, 56/zoom+80/zoom, 342/zoom, 1, tocolor(81, 81, 81))

            local drivers=split(v.lastDrivers,',') or {}
            local info={
                {"Ostatni kierowca", drivers[1] or "brak"},
                {"Policjant", v.policeman},
                {"Powód", v.reason},
                {"Data", v.date},
                {"Koszt", v.cost.."$"},
            }
            for i,v in pairs(info) do
                local sY=(33/zoom)*(i-1)
                dxDrawText(v[1], 60/zoom+366/zoom+5/zoom+(406-342)/2/zoom, 56/zoom+80/zoom+20/zoom+sY, 342/zoom, 13/zoom+56/zoom+80/zoom+20/zoom+sY, tocolor(150, 150, 150), 1, assets.fonts[1], "left", "center")
                dxDrawText(v[2], 60/zoom+366/zoom+5/zoom+(406-342)/2/zoom, 56/zoom+80/zoom+20/zoom+sY, 342/zoom+60/zoom+366/zoom+5/zoom+(406-342)/2/zoom, 13/zoom+56/zoom+80/zoom+20/zoom+sY, tocolor(150, 150, 150), 1, assets.fonts[1], "right", "center")
            end
        else
            dxDrawRectangle(60/zoom, 56/zoom+67/zoom+2+sY+49/zoom-1, 366/zoom, 1, tocolor(81, 81, 81))
            dxDrawText("["..v.id.."] "..getVehicleNameFromModel(v.model), 60/zoom+17/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom+56/zoom+67/zoom+2+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
        end

        onClick(60/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom, function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("get.vehicle", resourceRoot, v.id, v)

            removeEventHandler("onClientRender",root,UI.onRender)
            showChat(true)
    
            assets.destroy()
    
            showCursor(false)

            setElementData(localPlayer, "user:gui_showed", false, false)
        end)
    end
end

addEvent("get.vehicles", true)
addEventHandler("get.vehicles", resourceRoot, function(vehs)
    if(vehs)then
        if(getElementData(localPlayer, "user:gui_showed"))then return end

        blur=exports.blur
        
        assets.create()

        addEventHandler("onClientRender",root,UI.onRender)
        showChat(false)

        showCursor(true,false)

        UI.vehs=vehs

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
        setElementData(localPlayer, "user:chat_showed", true, false)
    else
        removeEventHandler("onClientRender",root,UI.onRender)
        showChat(true)

        assets.destroy()

        showCursor(false)

        setElementData(localPlayer, "user:gui_showed", false, false)
        setElementData(localPlayer, "user:chat_showed", false, false)
    end
end)

-- by asper

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

-- useful function created by Asper

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

-- useful

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)