--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- screen variables

local sw,sh=guiGetScreenSize()
local zoom=1

local baseX=1920
local maxZoom=2
if(baseX > sw)then
    zoom=math.min(baseX/sw,maxZoom)
end

-- variables

local blur=exports.blur

local FUEL={}

FUEL.vehicle=false
FUEL.marker=false

FUEL.alpha=0
FUEL.animate=false

FUEL.types={
    {name='LPG',price=3},
    {name='ON',price=5},
    {name='PB98',price=6},
    {name='PB95',price=8},
}

FUEL.selected=#FUEL.types

FUEL.price=0
FUEL.addFuel=0

-- assets

local assets={}
assets.list={
    texs={
        'textures/bg.png',
        'textures/header_left.png',
        'textures/header_icon.png',

        'textures/lpg.png',
        'textures/on.png',
        'textures/pb98.png',
        'textures/pb95.png',

        'textures/cost_bg.png',
        'textures/arrow.png',
        'textures/space.png',
    },

    fonts={
        {"Bold", 14},
        {"Regular", 10},
        {"Bold", 12},
        {"Medium", 14},
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

-- functions

FUEL.destroyWindow=function()
    if(FUEL.alpha == 0)then return end
    if(FUEL.animate)then return setTimer(FUEL.destroyWindow,500,1) end

    FUEL.animate=true
    animate(255, 0, 'Linear', 500, function(a)
        FUEL.alpha=a
    end, function()
        local selectedType=FUEL.types[FUEL.selected]
        if(FUEL.addFuel > 1)then    
            triggerServerEvent("fuel.add", resourceRoot, FUEL.vehicle, FUEL.addFuel, FUEL.price, selectedType.name)
            FUEL.addFuel=0
        end

        FUEL.animate=false

        FUEL.vehicle=nil
        removeEventHandler('onClientRender', root, FUEL.render)
        removeEventHandler('onClientKey', root, FUEL.key)
        assets.destroy()

        setElementData(localPlayer, 'user:tank_showed', false, false)
    end)
end

FUEL.key=function(key, press)
    if(press)then
        if(key == 'arrow_r' and FUEL.selected > 1)then
            FUEL.selected=FUEL.selected-1

            FUEL.price=0
            FUEL.addFuel=0
        elseif(key == 'arrow_l' and FUEL.selected < #FUEL.types)then
            FUEL.selected=FUEL.selected+1

            FUEL.price=0
            FUEL.addFuel=0
        end
    end
end

FUEL.render=function()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(FUEL.marker and FUEL.vehicle and veh and veh == FUEL.vehicle and isElementWithinMarker(localPlayer, FUEL.marker) and getVehicleController(FUEL.vehicle) == localPlayer)then
    else
        FUEL.destroyWindow()
    end

    if(FUEL.alpha > 0)then
        -- variables
        local selectedType=FUEL.types[FUEL.selected]

        local veh_fuel=getElementData(FUEL.vehicle, "vehicle:fuel") or 25
        local veh_bak=getElementData(FUEL.vehicle, "vehicle:fuelTank") or 25
        local veh_type=getElementData(FUEL.vehicle, "vehicle:fuelType") or "Petrol"
        if(veh_type == "LPG" and selectedType.name == "LPG")then
            veh_fuel=getElementData(FUEL.vehicle, "vehicle:gas") or 25
        end

        if(getKeyState('space') and not getElementData(localPlayer, 'user:interaction_showed'))then
            if(not getVehicleEngineState(FUEL.vehicle) and getElementData(FUEL.vehicle, 'vehicle:handbrake'))then
                local add=FUEL.addFuel+0.025
                if((veh_fuel+add) <= veh_bak)then
                    local allow
                    if(selectedType.name == 'LPG' and veh_type == 'LPG')then
                        allow=true
                    elseif((selectedType.name == 'PB95' or selectedType.name == 'PB98') and (veh_type == 'Petrol' or veh_type == 'LPG'))then
                        allow=true
                    elseif(selectedType.name == 'ON' and veh_type == 'Diesel')then
                        allow=true
                    end

                    if(allow)then
                        FUEL.price=FUEL.price+(selectedType.price*0.025)
                        FUEL.addFuel=add
                    else
                        exports.px_noti:noti('Twój pojazd nie obsługuje tego typu paliwa.', 'error')
                    end
                else
                    exports.px_noti:noti('W twoim baku nie zmieści się większa ilość paliwa.', 'error')
                end
            else
                exports.px_noti:noti('Najpierw zgaś silnik oraz zaciągnij hamulec ręczny w pojeździe!', 'error')
            end
        end

        -- bg
        blur:dxDrawBlur(sw/2-790/2/zoom, sh-228/zoom, 790/zoom, 156/zoom, tocolor(255,255,255,FUEL.alpha))
        dxDrawImage(sw/2-790/2/zoom, sh-228/zoom, 790/zoom, 156/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, FUEL.alpha))

        -- header
        dxDrawImage(sw/2-790/2/zoom, sh-228/zoom, 55/zoom, 55/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, FUEL.alpha))
        dxDrawImage(sw/2-790/2/zoom+(55-25)/2/zoom, sh-228/zoom+(55-25)/2/zoom, 25/zoom, 25/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, FUEL.alpha))
        dxDrawText('STACJA PALIW', sw/2-790/2/zoom+71/zoom, sh-228/zoom, 55/zoom, sh-228/zoom+55/zoom, tocolor(222,222,222,FUEL.alpha), 1, assets.fonts[1], 'left', 'center')
        dxDrawText('Wybierz odpowiedni rodzaj paliwa do twojego\npojazdu, a następnie użyj spacji do tankowania.', sw/2-790/2/zoom+234/zoom, sh-228/zoom, 55/zoom, sh-228/zoom+55/zoom, tocolor(165,165,165,FUEL.alpha), 1, assets.fonts[2], 'left', 'center')
    
        -- right types
        for i,v in pairs(FUEL.types) do
            local sX=(55/zoom)*i
            dxDrawImage(sw/2-790/2/zoom+790/zoom-sX, sh-228/zoom, 55/zoom, 55/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, FUEL.alpha))

            local w,h=dxGetMaterialSize(assets.textures[3+i])
            dxDrawImage(sw/2-790/2/zoom+790/zoom-sX+(55-w)/2/zoom, sh-228/zoom+(55-h)/2/zoom, w/zoom, h/zoom, assets.textures[3+i], 0, 0, 0, tocolor(255, 255, 255, FUEL.alpha))

            -- price
            local color=FUEL.selected == i and tocolor(49,112,173,FUEL.alpha) or tocolor(222,222,222,FUEL.alpha)
            dxDrawImage(sw/2-790/2/zoom+790/zoom-sX, sh-228/zoom+55/zoom, 55/zoom, 30/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, FUEL.alpha))
            dxDrawText(v.price..'.00', sw/2-790/2/zoom+790/zoom-sX, sh-228/zoom+55/zoom, sw/2-790/2/zoom+790/zoom-sX+55/zoom, sh-228/zoom+55/zoom+30/zoom, color, 1, assets.fonts[2], 'center', 'center')

            if(FUEL.selected == i)then
                dxDrawRectangle(sw/2-790/2/zoom+790/zoom-sX, sh-228/zoom+55/zoom+30/zoom, 55/zoom, 1, tocolor(49,112,173,FUEL.alpha))

                dxDrawImage(sw/2-790/2/zoom+790/zoom-sX+14/zoom, sh-228/zoom+55/zoom+30/zoom+8/zoom, 11/zoom, 10/zoom, assets.textures[9], 180, 0, 0, getKeyState('arrow_l') and tocolor(49,112,173,FUEL.alpha) or tocolor(255,255,255,FUEL.alpha))
                dxDrawImage(sw/2-790/2/zoom+790/zoom-sX+28/zoom, sh-228/zoom+55/zoom+30/zoom+8/zoom, 11/zoom, 10/zoom, assets.textures[9], 0, 0, 0, getKeyState('arrow_r') and tocolor(49,112,173,FUEL.alpha) or tocolor(255,255,255,FUEL.alpha))
            end
        end

        -- header line
        dxDrawRectangle(sw/2-790/2/zoom, sh-228/zoom+55/zoom, 790/zoom, 1, tocolor(80,80,80,FUEL.alpha))

        -- right info
        dxDrawText('Całkowity koszt wynosi:', 0, sh-228/zoom+156/zoom-45/zoom, sw/2-790/2/zoom+790/zoom-7/zoom, 0, tocolor(222,222,222,FUEL.alpha), 1, assets.fonts[2], 'right', 'top')
        dxDrawText('$ '..math.floor(FUEL.price), 0, sh-228/zoom+156/zoom-25/zoom, sw/2-790/2/zoom+790/zoom-7/zoom, 0, tocolor(49,112,173,FUEL.alpha), 1, assets.fonts[3], 'right', 'top')

        -- left progress
        dxDrawText('Tankowanie', sw/2-790/2/zoom+15/zoom, sh-228/zoom+74/zoom, 0, 0, tocolor(222,222,222,FUEL.alpha), 1, assets.fonts[4], 'left', 'top')
        
        dxDrawRectangle(sw/2-790/2/zoom+15/zoom, sh-228/zoom+74/zoom+32/zoom, 526/zoom, 4/zoom, tocolor(91,91,90,FUEL.alpha))
        dxDrawRectangle(sw/2-790/2/zoom+15/zoom, sh-228/zoom+74/zoom+32/zoom, (526/zoom)*((veh_fuel+FUEL.addFuel)/veh_bak), 4/zoom, tocolor(49,112,173,FUEL.alpha))

        dxDrawText('0', sw/2-790/2/zoom+15/zoom, sh-228/zoom+74/zoom+27/zoom+17/zoom, 526/zoom, 4/zoom, tocolor(222,222,222,FUEL.alpha), 1, assets.fonts[2], 'left', 'top')
        dxDrawText(string.format('%.1f', (veh_fuel+FUEL.addFuel))..' l', sw/2-790/2/zoom+15/zoom, sh-228/zoom+74/zoom+27/zoom+15/zoom, sw/2-790/2/zoom+15/zoom+526/zoom, 4/zoom, tocolor(222,222,222,FUEL.alpha), 1, assets.fonts[5], 'center', 'top')
        dxDrawText(veh_bak, sw/2-790/2/zoom+15/zoom, sh-228/zoom+74/zoom+27/zoom+17/zoom, sw/2-790/2/zoom+15/zoom+526/zoom, 4/zoom, tocolor(222,222,222,FUEL.alpha), 1, assets.fonts[2], 'right', 'top')

        dxDrawImage(sw/2-790/2/zoom+15/zoom+(526-28)/2/zoom, sh-228/zoom+74/zoom+65/zoom, 28/zoom, 8/zoom, assets.textures[10], 0, 0, 0, tocolor(255,255,255,FUEL.alpha))
    end
end

-- triggers

addEvent('fuelStation:createTankUI', true)
addEventHandler('fuelStation:createTankUI', resourceRoot, function(veh, marker)
    if(FUEL.animate)then return end

    FUEL.vehicle=veh
    FUEL.marker=marker

    FUEL.price=0
    FUEL.addFuel=0

    assets.create()
    addEventHandler('onClientRender', root, FUEL.render)
    addEventHandler('onClientKey', root, FUEL.key)

    setElementData(localPlayer, 'user:tank_showed', true, false)

    FUEL.animate=true
    animate(0, 255, 'Linear', 500, function(a)
        FUEL.alpha=a
    end, function()
        FUEL.animate=false
    end)

    exports.px_noti:noti('Pamiętaj aby przed rozpoczęciem tankowania, zaciągnąć hamulec ręczny oraz zgasić silnik w pojeździe.', 'info')
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