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

local blur=exports.blur
local scroll=exports.px_scroll

-- variables

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Regular.ttf", 14},
        {":px_assets/fonts/Font-Medium.ttf", 17},
    },

    textures={},
    textures_paths={
        "textures/header.png",
        "textures/row.png",
        "textures/choose.png",
        "textures/window.png",
    },
}

--

local UI={}

UI.vehs={}
UI.scroll=false

UI.factions={
    ["SAPD"]=true,
    ["SARA"]=true,
    ["SACC"]=true,
    ["PSP"]=true
}

--

UI.onRender=function()
    blur:dxDrawBlur(60/zoom, 56/zoom, 366/zoom, 67/zoom, tocolor(255, 255, 255))
    dxDrawImage(60/zoom, 56/zoom, 366/zoom, 67/zoom, assets.textures[1])

    local row=math.floor(scroll:dxScrollGetPosition(UI.scroll))+1

    local x=0
    local k=0
    for i,v in pairs(UI.vehs) do
        x=x+1

        if((row+8) >= x and (row) <= x)then
            k=k+1  
            
            local sY=(51/zoom)*(k-1)
            blur:dxDrawBlur(60/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom, tocolor(255, 255, 255))
            dxDrawImage(60/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom, assets.textures[2])

            if(isMouseInPosition(60/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom))then
                dxDrawRectangle(60/zoom, 56/zoom+67/zoom+2+sY+49/zoom-1, 366/zoom, 1, tocolor(53, 130, 74))
                dxDrawImage(60/zoom+18/zoom, 56/zoom+67/zoom+2+sY+(49-12)/2/zoom, 12/zoom, 12/zoom, assets.textures[3])
                dxDrawText("["..v.id.."] "..(getVehicleNameFromModel(v.model) or "??"), 60/zoom+41/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom+56/zoom+67/zoom+2+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            
                -- prawo
                blur:dxDrawBlur(60/zoom+366/zoom+5/zoom, 56/zoom, 406/zoom, 266/zoom, tocolor(255, 255, 255))
                dxDrawImage(60/zoom+366/zoom+5/zoom, 56/zoom, 406/zoom, 266/zoom, assets.textures[4])
                
                dxDrawText(getVehicleNameFromModel(v.model), 60/zoom+366/zoom+5/zoom+30/zoom, 56/zoom+15/zoom, 406/zoom, 266/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
                dxDrawText("ID "..v.id, 60/zoom+366/zoom+5/zoom+30/zoom, 56/zoom+43/zoom, 406/zoom, 266/zoom, tocolor(150, 150, 150), 1, assets.fonts[1], "left", "top")

                dxDrawRectangle(60/zoom+366/zoom+5/zoom+(406-342)/2/zoom, 56/zoom+80/zoom, 342/zoom, 1, tocolor(81, 81, 81))

                local drivers=fromJSON(v.lastDrivers) or {"?"}
                local info={
                    {"Przebieg", math.floor(v.distance).."km"},
                    {"Bak", v.fuel.."/"..v.fuelTank.."L"},
                    {"Ostatni kierowca", drivers[#drivers]},
                    {"Stan pojazdu", math.floor(v.health/10).."%"},
                }

                if(v.type == "organization")then
                    info[#info+1]={"Organizacja", v.owner}
                elseif(UI.factions[v.owner])then
                    info[#info+1]={"Grupa", #v.access > 0 and v.access or "brak"}
                end

                for i,v in pairs(info) do
                    local sY=(33/zoom)*(i-1)
                    dxDrawText(v[1], 60/zoom+366/zoom+5/zoom+(406-342)/2/zoom, 56/zoom+80/zoom+20/zoom+sY, 342/zoom, 13/zoom+56/zoom+80/zoom+20/zoom+sY, tocolor(150, 150, 150), 1, assets.fonts[1], "left", "center")
                    dxDrawText(v[2], 60/zoom+366/zoom+5/zoom+(406-342)/2/zoom, 56/zoom+80/zoom+20/zoom+sY, 342/zoom+60/zoom+366/zoom+5/zoom+(406-342)/2/zoom, 13/zoom+56/zoom+80/zoom+20/zoom+sY, tocolor(150, 150, 150), 1, assets.fonts[1], "right", "center")
                end
            else
                dxDrawRectangle(60/zoom, 56/zoom+67/zoom+2+sY+49/zoom-1, 366/zoom, 1, tocolor(81, 81, 81))
                dxDrawText("["..v.id.."] "..(getVehicleNameFromModel(v.model) or "??"), 60/zoom+17/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom+56/zoom+67/zoom+2+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            end

            onClick(60/zoom, 56/zoom+67/zoom+2+sY, 366/zoom, 49/zoom, function()
                if(SPAM.getSpam())then return end

                triggerServerEvent("get.vehicle", resourceRoot, v.id)
    
                removeEventHandler("onClientRender",root,UI.onRender)
                showChat(true)
        
                assets.destroy()
        
                showCursor(false)
    
                setElementData(localPlayer, "user:gui_showed", false, false)

                scroll:dxDestroyScroll(UI.scroll)
            end)
        end
    end
end

addEvent("get.vehicles", true)
addEventHandler("get.vehicles", resourceRoot, function(vehs)
    scroll=exports.px_scroll

    if(vehs)then
        if(getElementData(localPlayer, "user:gui_showed"))then return end

        blur=exports.blur
        
        assets.create()

        addEventHandler("onClientRender",root,UI.onRender)

        showCursor(true,false)

        UI.vehs=vehs

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
        showChat(false)

        UI.scroll=scroll:dxCreateScroll(60/zoom+366/zoom, 56/zoom+67/zoom+2, 6/zoom, 6/zoom, 0, 9, UI.vehs, 459/zoom, 255)
    else
        removeEventHandler("onClientRender",root,UI.onRender)

        assets.destroy()

        showCursor(false)

        setElementData(localPlayer, "user:gui_showed", false, false)
        showChat(true)

        scroll:dxDestroyScroll(UI.scroll)
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

local shadow = tocolor(0,0,0,100)

function dxDrawTextShadow( text, x, y, w, h, color, fontSize, fontType, alignX, alignY )
	dxDrawText( text, x+1, y+1, w, h, shadow, fontSize, fontType, alignX, alignY )
	dxDrawText( text, x-1, y+1, w, h, shadow, fontSize, fontType, alignX, alignY )
	dxDrawText( text, x-1, y-1, w, h, shadow, fontSize, fontType, alignX, alignY )
 	dxDrawText( text, x+1, y-1, w, h, shadow, fontSize, fontType, alignX, alignY )

 	dxDrawText( text, x, y, w, h, color, fontSize, fontType, alignX, alignY )
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

-- animate

local anims = {}
local rendering = false 

local function renderAnimations()
    local now = getTickCount()
    for k,v in pairs(anims) do
        v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
        if(now >= v.start+v.duration)then
            table.remove(anims, k)
			if(type(v.onEnd) == "function")then
                v.onEnd()
            end
        end
    end

    if(#anims == 0)then 
        rendering = false
        removeEventHandler("onClientRender", root, renderAnimations)
    end
end

function animate(f, t, easing, duration, onChange, onEnd)
	if(#anims == 0 and not rendering)then 
		addEventHandler("onClientRender", root, renderAnimations)
		rendering = true
	end
	
    assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
    assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
    assert(type(easing) == "string", "Bad argument @ 'animate' [Invalid easing at argument 3]")
    assert(type(duration) == "number", "Bad argument @ 'animate' [expected number at argument 4, got "..type(duration).."]")
    assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
    table.insert(anims, {from = f, to = t, easing = easing, duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})

    return #anims
end

function destroyAnimation(id)
    if(anims[id])then
        anims[id] = nil
    end
end