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

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

noti = exports.px_noti
blur=exports.blur
export=exports.px_custom_vehicles

local UI = {}

-- main variables

local assets={
    fonts={},
    fonts2={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 17},
        {":px_assets/fonts/Font-Regular.ttf", 13},
        {":px_assets/fonts/Font-Medium.ttf", 15},

        {":px_assets/fonts/Font-Medium.ttf", 22},
        {":px_assets/fonts/Font-Regular.ttf", 15},

        {":px_assets/fonts/Font-SemiBold.ttf", 20},
        {":px_assets/fonts/Font-SemiBold.ttf", 15},
        {":px_assets/fonts/Font-Medium.ttf", 15},
        {":px_assets/fonts/Font-Regular.ttf", 13},

        {":px_assets/fonts/Font-Medium.ttf", 11},
        {":px_assets/fonts/Font-Regular.ttf", 8},
        {":px_assets/fonts/Font-Medium.ttf", 10},

        {":px_assets/fonts/Font-Bold.ttf", 11},
    },

    textures={},
    textures_paths={
        "textures/window.png",
        "textures/car_drive.png",

        "textures/background.png",
        "textures/car_buy.png",
        "textures/color.png",

        "textures/o_bg.png",
        "textures/text_bg.png",
    },
}

assets.create = function()
    for k,t in pairs(assets) do
        if(k=="fonts_paths")then
            for i,v in pairs(t) do
                assets.fonts[i] = dxCreateFont(v[1], v[2]/zoom)
                assets.fonts2[i] = dxCreateFont(v[1], v[2])
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

--

-- variables

UI.info = {}
UI.alpha = 0
UI.tickTime=getTickCount()
UI.time=120

-- test drive

UI.onRender=function()
    local times=(getTickCount()-UI.tickTime)/1000

    local w,h = 386,137
    blur:dxDrawBlur(sw/2-w/2/zoom, 30/zoom, w/zoom, h/zoom, tocolor(255, 255, 255))
    dxDrawImage(sw/2-w/2/zoom, 30/zoom, w/zoom, h/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255), false)

    dxDrawText("Jazda testowa", sw/2-w/2/zoom-20/zoom, 40/zoom, w/zoom+sw/2-w/2/zoom, h/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "center", "top", false)
    dxDrawImage(sw/2-w/2/zoom+(w-22)/2/zoom+80/zoom, 45/zoom, 22/zoom, 22/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255), false)

    dxDrawRectangle(sw/2-339/2/zoom, 80/zoom, 339/zoom, 1, tocolor(121, 121, 121))

    local time_2=math.floor(UI.time-times)
    local minutes = math.floor(time_2/60)
    local seconds = math.floor(time_2-(minutes*60))
    time_2="#6ba0b5"..minutes.." #c7c9c9minut #6ba0b5"..seconds.." #c7c9c9sekund"

    dxDrawText("Do końca jazdy testowej pozostało:", sw/2-w/2/zoom, 95/zoom, w/zoom+sw/2-w/2/zoom, h/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[2], "center", "top", false)
    dxDrawText(time_2, sw/2-w/2/zoom, 120/zoom, w/zoom+sw/2-w/2/zoom, h/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[3], "center", "top", false, false, false, true)

    if(math.floor(UI.time-times) <= 0)then
        assets.destroy()

        removeEventHandler("onClientRender", root, UI.onRender)

        triggerServerEvent("stop.testDrive", resourceRoot)

        exports.px_noti:noti("Czas na jazde testową się skończył.")

        setPedCanBeKnockedOffBike(localPlayer, true)
    end
end

addEvent("start.testDrive", true)
addEventHandler("start.testDrive", resourceRoot, function()
    noti = exports.px_noti
    blur=exports.blur
    export=exports.px_custom_vehicles

    UI.tickTime=getTickCount()
    UI.time=120

    addEventHandler("onClientRender", root, UI.onRender)

    assets.create()

    setPedCanBeKnockedOffBike(localPlayer, false)
end)

function action(id, vehicle, name)
    if(name == "Zakup pojazd")then
        local info=getElementData(vehicle, "salon:data")
        if(info)then
            triggerServerEvent("buy:veh", resourceRoot, getVehicleName(vehicle), info.info.distance, info.info.cost, vehicle, info.info.id, info.info)
        end
    elseif(name == "Jazda testowa")then
        local info=getElementData(vehicle, "salon:data")
        if(info)then
            triggerServerEvent("create.testDrive", resourceRoot, info.info, vehicle)
        end
    end
end

addEvent("stop.testDrive", true)
addEventHandler("stop.testDrive", resourceRoot, function()
    assets.destroy()

    removeEventHandler("onClientRender", root, UI.onRender)

    triggerServerEvent("stop.testDrive", resourceRoot)

    setPedCanBeKnockedOffBike(localPlayer, true)
end)

-- buy gui camera

local BUY={}

BUY.vehs={}
BUY.veh=1
BUY.last=1
BUY.tick=getTickCount()
BUY.index=false

BUY.button=false

BUY.onRender=function()
    local last=BUY.vehs[BUY.last]
    local new=BUY.vehs[BUY.veh]
    if(new and last and isElement(new) and isElement(last))then
        -- camera
        if((getTickCount()-BUY.tick) > 500)then
            local cam={getStraightPosition(new, 7)}
            cam[3]=cam[3]+1

            local rnd=interpolateBetween(-1, 0, 0, 1, 0, 0, (getTickCount()-BUY.tick)/3000, "SineCurve")
            setCameraMatrix(cam[1]+rnd/10, cam[2]+rnd/10, cam[3], cam[4]-rnd/10, cam[5]+rnd/10, cam[6])
        else
            local pos_1={getStraightPosition(last, 7)}
            pos_1[3]=pos_1[3]+1

            local pos_2={getStraightPosition(new, 7)}
            pos_2[3]=pos_2[3]+1

            local cam={interpolateBetween(pos_1[1], pos_1[2], pos_1[3], pos_2[1], pos_2[2], pos_2[3], (getTickCount()-BUY.tick)/500, "Linear")}
            local cam2={interpolateBetween(pos_1[4], pos_1[5], pos_1[6], pos_2[4], pos_2[5], pos_2[6], (getTickCount()-BUY.tick)/500, "Linear")}
            setCameraMatrix(cam[1], cam[2], cam[3], cam2[1], cam2[2], cam2[3])
        end

        -- gui
        blur:dxDrawBlur(100/zoom, 100/zoom, 387/zoom, 600/zoom, tocolor(255, 255, 255, 255))
        dxDrawImage(100/zoom, 100/zoom, 387/zoom, 600/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, 255), false)

        dxDrawText("Kupno pojazdu", 100/zoom, 100/zoom+15/zoom, 387/zoom+100/zoom, 1, tocolor(180, 180, 180, 255), 1, assets.fonts[6], "center", "top")
        dxDrawImage(395/zoom, 125/zoom, 23/zoom, 23/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, 255), false)
        dxDrawRectangle(100/zoom+(387-339)/2/zoom, 165/zoom, 339/zoom, 1, tocolor(90, 90, 90, 255), false)

        local data=getElementData(new, "salon:data")
        if(not data)then return end

        local name=getVehicleName(new)
        local bak=data.info.bak
        local fuel=data.info.fuel
        local type=data.info.type
        local engine=export:getVehicleEngineFromName(name) or "1.0"
        local fuel_usage=export:getFuelUsage(engine)
        local naped=getVehicleHandling(new).driveType
        local value=data.info.value
        local cost=data.info.cost
        type=type == "Petrol" and "Benzyna" or type

        local infos={
            {"Marka",name},
            {"Paliwo",type},
            {"Bak",bak.."L"},
            {"Ilość",value},
            {"Napęd",string.upper(naped)},
            {"Silnik",engine},
            {"Spalanie",fuel_usage.."l/100km"},
            {"Cena",convertNumber(cost).."$"},
            {"Kolor",{getVehicleColor(new,true)}},
        }

        for i,v in pairs(infos) do
            local sY=(40/zoom)*(i-1)
            dxDrawText(v[1], 100/zoom+65/zoom, 100/zoom+90/zoom+sY, 387/zoom+100/zoom, 1, tocolor(200, 200, 200, 255), 1, assets.fonts[8], "left", "top")

            if(v[1] == "Kolor")then
                dxDrawImage(387/zoom-10/zoom, 100/zoom+90/zoom+sY+2/zoom, 20/zoom, 20/zoom, assets.textures[5], 0, 0, 0, tocolor(v[2][1], v[2][2], v[2][3], 255))
                dxDrawImage(387/zoom+15/zoom, 100/zoom+90/zoom+sY+2/zoom, 20/zoom, 20/zoom, assets.textures[5], 0, 0, 0, tocolor(v[2][4], v[2][5], v[2][6], 255))
            else
                dxDrawText(v[2], 100/zoom+65/zoom, 100/zoom+90/zoom+sY, 100/zoom+387/zoom-67/zoom, 1, tocolor(200, 200, 200, 255), 1, assets.fonts[8], "right", "top")
            end
        end

        dxDrawRectangle(100/zoom+(387-339)/2/zoom, 552/zoom, 339/zoom, 1, tocolor(90, 90, 90, 255), false)
        dxDrawText("Klawiszologia:", 100/zoom, 550/zoom+15/zoom, 387/zoom+100/zoom, 1, tocolor(180, 180, 180, 255), 1, assets.fonts[7], "center", "top")
        dxDrawText("Enter - kupno pojazdu\nSpacja - jazda testowa\nStrzałki - poruszanie się\nESC - wyjście", 100/zoom, 550/zoom+45/zoom, 387/zoom+100/zoom, 1, tocolor(150, 150, 150, 255), 1, assets.fonts[9], "center", "top")
    else
        BUY.last=1
        BUY.veh=1
        
        cancelEvent()

        BUY.vehs={}

        removeEventHandler("onClientRender", root, BUY.onRender)
        removeEventHandler("onClientKey", root, BUY.onKey)

        setElementData(localPlayer, "user:hud_disabled", false, false)
        showChat(true)
        setElementFrozen(localPlayer, false)

        assets.destroy()

        setCameraTarget(localPlayer)

        showCursor(false)

        exports.px_buttons:destroyButton(BUY.button)
    end
end

BUY.onKey=function(key, press)
    if(press and (getTickCount()-BUY.tick) > 500)then
        if(key == "arrow_l")then
            if(BUY.veh > 1)then
                BUY.last=BUY.veh
                BUY.tick=getTickCount()
                BUY.veh=BUY.veh-1
            else
                BUY.last=BUY.veh
                BUY.tick=getTickCount()
                BUY.veh=#BUY.vehs
            end
        elseif(key == "arrow_r")then
            if(BUY.veh < #BUY.vehs)then
                BUY.last=BUY.veh
                BUY.tick=getTickCount()
                BUY.veh=BUY.veh+1
            else
                BUY.last=BUY.veh
                BUY.tick=getTickCount()
                BUY.veh=1
            end
        elseif(key == "escape")then
            cancelEvent()

            BUY.vehs={}

            removeEventHandler("onClientRender", root, BUY.onRender)
            removeEventHandler("onClientKey", root, BUY.onKey)

            setElementData(localPlayer, "user:hud_disabled", false, false)
            showChat(true)
            setElementFrozen(localPlayer, false)

            assets.destroy()

            setCameraTarget(localPlayer)

            showCursor(false)

            exports.px_buttons:destroyButton(BUY.button)
        elseif(key == "enter")then
            local info=getElementData(BUY.vehs[BUY.veh], "salon:data")
            if(info)then
                if(SPAM.getSpam())then return end

                triggerServerEvent("buy:veh", resourceRoot, getVehicleName(BUY.vehs[BUY.veh]), info.info.distance, info.info.cost, BUY.vehs[BUY.veh], info.info.id, info.info)

                BUY.vehs={}

                removeEventHandler("onClientRender", root, BUY.onRender)
                removeEventHandler("onClientKey", root, BUY.onKey)

                setElementData(localPlayer, "user:hud_disabled", false, false)
                setElementFrozen(localPlayer, false)

                assets.destroy()

                setCameraTarget(localPlayer)

                showCursor(false)
                showChat(true)

                exports.px_buttons:destroyButton(BUY.button)
            end
        elseif(key == "space")then
            local info=getElementData(BUY.vehs[BUY.veh], "salon:data")
            if(info)then
                if(SPAM.getSpam())then return end

                triggerServerEvent("create.testDrive", resourceRoot, info.info, BUY.vehs[BUY.veh])

                BUY.vehs={}

                removeEventHandler("onClientRender", root, BUY.onRender)
                removeEventHandler("onClientKey", root, BUY.onKey)

                setElementData(localPlayer, "user:hud_disabled", false, false)
                setElementFrozen(localPlayer, false)

                assets.destroy()

                setCameraTarget(localPlayer)

                showCursor(false)

                exports.px_buttons:destroyButton(BUY.button)
            end
        end
    end
end

addEvent("show.buy", true)
addEventHandler("show.buy", resourceRoot, function(list)
    BUY.vehs={}
    local k=0
    for i,v in pairs(list) do
        if(v and isElement(v.vehicle))then
            k=k+1
            BUY.vehs[k]=v.vehicle
        end
    end
    if(#BUY.vehs > 0)then
        noti = exports.px_noti
        blur=exports.blur
        export=exports.px_custom_vehicles

        addEventHandler("onClientRender", root, BUY.onRender)
        addEventHandler("onClientKey", root, BUY.onKey)

        setElementData(localPlayer, "user:hud_disabled", true, false)
        showChat(false)
        setElementFrozen(localPlayer, true)

        assets.create()
    else
        exports['px_noti']:noti('Brak pojazdów na stanie.', 'error')
    end
end)

-- useful

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end

function getStraightPosition(element)
    local plus1=0
    local plus2=50

    local x,y,z = getElementPosition(element)
    local _,_,rot = getElementRotation(element)

    rot=rot+190

    local cx, cy = getPointFromDistanceRotation(x, y, (plus1 or 0), (-(rot+90)))
    local cx2, cy2 = getPointFromDistanceRotation(x, y, (plus2 or 0), (-(rot)))
    cx2=cx2-cx
    cy2=cy2-cy
    cx2,cy2=x+cx2,y+cy2

    local cxx, cyx = getPointFromDistanceRotation(x, y, -7, (-(rot)))
    x,y=cxx,cyx

    return x,y,z,cx2,cy2,z
end

-- usefull function created by Asper

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