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

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- exports

local blur=exports.blur

-- assets

local assets={}
assets.list={
    texs={
        "textures/bg.png",
        "textures/logo.png",
        "textures/close.png",
        "textures/button.png",
        "textures/button_red.png",
        "textures/button_green.png",
        "textures/row.png",
    },

    fonts={
        {"digital-7.ttf", 40},
        {":px_assets/fonts/Font-Bold.ttf", 12},
        {":px_assets/fonts/Font-Medium.ttf", 12},
        {"digital-7.ttf", 25},
        {":px_assets/fonts/Font-Bold.ttf", 7},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts={}
    for i,v in pairs(assets.list.fonts) do
        assets.fonts[i]=dxCreateFont(v[1], v[2]/zoom)
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

local ui={}

ui.programs={
    {text="Mycie podstawowe (woda)", time=20, cost=63},
    {text="Mycie zasadnicze (woda, piana)", time=40, cost=88},
    {text="Mycie zasadnicze + polerowanie", time=80, cost=97},
    {text="Mycie zasadnicze + konserwacja polimerem", time=100, cost=122},
    {text="Mycie zasadnicze + nabłyszczanie + osuszanie", time=120, cost=150},
}

ui.program=0
ui.washing=false

ui.places={
    ["Las Venturas obok SAPD"]={
        {2163.2502441406,2473.0478515625,10.8203125},
    },

    ["Na górze LV"]={
        {2147.0192871094,2713.7546386719,10.8203125},
    },

    ['Wioska 51']={
        {194.2747,1846.9440,18.6375},
    }
}

for i,v in pairs(ui.places) do
    outputDebugString("(px_carwash) ✓ Pomyślnie stworzono myjnie w "..i..".")
    for i,v in pairs(v) do
        local marker=createMarker(v[1], v[2], v[3]-1, "cylinder", 3, 134, 152, 188)
        setElementData(marker, "icon", ":px_carwash/textures/carwashMarker.png", false)
        setElementData(marker, "pos:z", v[3]-0.97, false)
        setElementData(marker, "text", {text="Myjnia",desc="Wjedź aby umyć pojazd"})

        local shape=createColSphere(v[1], v[2], v[3], 1)

        local blip = createBlip(v[1], v[2], v[3], 28)
        setBlipVisibleDistance(blip, 500)
    end
end

-- events

addEventHandler("onClientColShapeHit", resourceRoot, function(hit, dim)
    if(hit ~= localPlayer or not dim or not isPedInVehicle(hit))then return end

    local v=getPedOccupiedVehicle(hit)
    if(getVehicleController(v) ~= hit)then return end
    
    setElementFrozen(v, true)

    ui.create()
end)

-- functions

ui.onRender=function()
    if(not isPedInVehicle(localPlayer))then
        return ui.destroy()
    end

    blur:dxDrawBlur(sw/2-562/2/zoom, sh/2-669/2/zoom, 562/zoom, 669/zoom)
    dxDrawImage(sw/2-562/2/zoom, sh/2-669/2/zoom, 562/zoom, 669/zoom, assets.textures[1])
    dxDrawImage(sw/2-562/2/zoom+(562-219)/2/zoom, sh/2-669/2/zoom+(90-39)/2/zoom, 219/zoom, 39/zoom, assets.textures[2])
    dxDrawImage(sw/2-562/2/zoom+562/zoom-10/zoom-20/zoom, sh/2-669/2/zoom+20/zoom, 10/zoom, 10/zoom, assets.textures[3])
    dxDrawRectangle(sw/2-495/2/zoom, sh/2-669/2/zoom+90/zoom, 495/zoom, 1, tocolor(85,85,85))

    -- dol
    local time=ui.programs[ui.program] and ui.programs[ui.program].time or 0
    if(ui.washing)then
        time=time-(getTickCount()-ui.washing)/1000
    end

    local hours = math.floor(time/60)
    local minutes = math.floor(time-(hours*60))
    time=string.format("%02d", hours)..":"..string.format("%02d", minutes)

    dxDrawRectangle(sw/2-495/2/zoom, sh/2-669/2/zoom+115/zoom, 160/zoom, 66/zoom, tocolor(0,0,0))
    for i=1,5 do
        local x=i == 1 and 10 or i == 2 and 80 or i == 3 and 130 or i == 4 and 180 or i == 5 and 250
        local sX=x/zoom-128/zoom
        dxDrawText(i == 3 and ":" or "0", sw/2-495/2/zoom+sX, sh/2-669/2/zoom+115/zoom, 160/zoom+sw/2-495/2/zoom, 66/zoom+sh/2-669/2/zoom+115/zoom, tocolor(20,20,20), 1, assets.fonts[1], "center", "center")
        
        if(string.sub(time, i,i) == "1")then
            dxDrawText(i == 3 and ":" or string.sub(time, i,i), sw/2-495/2/zoom+sX+19/zoom, sh/2-669/2/zoom+115/zoom, 160/zoom+sw/2-495/2/zoom, 66/zoom+sh/2-669/2/zoom+115/zoom, tocolor(226,55,55), 1, assets.fonts[1], "center", "center")
        else
            dxDrawText(i == 3 and ":" or string.sub(time, i,i), sw/2-495/2/zoom+sX, sh/2-669/2/zoom+115/zoom, 160/zoom+sw/2-495/2/zoom, 66/zoom+sh/2-669/2/zoom+115/zoom, tocolor(226,55,55), 1, assets.fonts[1], "center", "center")
        end
    end

    -- prawo
    dxDrawText("Przewidywany czas oczekiwania", sw/2-495/2/zoom+192/zoom, sh/2-669/2/zoom+115/zoom-40/zoom, 160/zoom, 66/zoom+sh/2-669/2/zoom+115/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "center")
    dxDrawText("Długość tego czasu zależy od wybranego\nprogramu mycia.", sw/2-495/2/zoom+192/zoom, sh/2-669/2/zoom+115/zoom+20/zoom, 160/zoom, 66/zoom+sh/2-669/2/zoom+115/zoom, tocolor(110, 110, 110), 1, assets.fonts[3], "left", "center")

    -- przyciski
    for i,v in pairs(ui.programs) do
        local sY=(70/zoom)*(i-1)
        dxDrawImage(sw/2-495/2/zoom, sh/2-669/2/zoom+115/zoom+66/zoom+sY, 91/zoom, 91/zoom, ui.program == i and assets.textures[5] or assets.textures[4])
        dxDrawImage(sw/2-495/2/zoom+118/zoom, sh/2-669/2/zoom+115/zoom+66/zoom+sY+16/zoom, 407/zoom, 61/zoom, assets.textures[7])

        dxDrawText("Program "..i, sw/2-495/2/zoom+118/zoom+14/zoom, sh/2-669/2/zoom+115/zoom+66/zoom+sY+16/zoom-20/zoom, 407/zoom, 61/zoom+sh/2-669/2/zoom+115/zoom+66/zoom+sY+16/zoom, tocolor(220, 220, 220), 1, assets.fonts[2], "left", "center")
        dxDrawText(v.text, sw/2-495/2/zoom+118/zoom+14/zoom, sh/2-669/2/zoom+115/zoom+66/zoom+sY+16/zoom+20/zoom, 407/zoom, 61/zoom+sh/2-669/2/zoom+115/zoom+66/zoom+sY+16/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "center")
    
        onClick(sw/2-495/2/zoom, sh/2-669/2/zoom+115/zoom+66/zoom+sY, 91/zoom, 91/zoom, function()
            if(not ui.washing)then
                ui.program=i
            end
        end)
    end

    -- dol lewo
    local money=ui.programs[ui.program] and ui.programs[ui.program].cost or 0
    money=string.format("%04d", money)

    dxDrawRectangle(sw/2-495/2/zoom, sh/2-669/2/zoom+581/zoom, 96/zoom, 41/zoom, tocolor(0,0,0))
    for i=1,4 do
        local x=i == 1 and 30 or i == 2 and 70 or i == 3 and 110 or i == 4 and 150
        local sX=x/zoom-90/zoom
        dxDrawText("0", sw/2-495/2/zoom+sX, sh/2-669/2/zoom+581/zoom, 96/zoom+sw/2-495/2/zoom, 41/zoom+sh/2-669/2/zoom+581/zoom, tocolor(20,20,20), 1, assets.fonts[4], "center", "center")
        
        if(string.sub(money, i,i) == "1")then
            dxDrawText(string.sub(money, i,i), sw/2-495/2/zoom+sX+12/zoom, sh/2-669/2/zoom+581/zoom, 96/zoom+sw/2-495/2/zoom, 41/zoom+sh/2-669/2/zoom+581/zoom, tocolor(226,55,55), 1, assets.fonts[4], "center", "center")
        else
            dxDrawText(string.sub(money, i,i), sw/2-495/2/zoom+sX, sh/2-669/2/zoom+581/zoom, 96/zoom+sw/2-495/2/zoom, 41/zoom+sh/2-669/2/zoom+581/zoom, tocolor(226,55,55), 1, assets.fonts[4], "center", "center")
        end
    end

    dxDrawText("Cena końcowa", sw/2-495/2/zoom+111/zoom, sh/2-669/2/zoom+581/zoom-20/zoom, 96/zoom+sw/2-495/2/zoom, 41/zoom+sh/2-669/2/zoom+581/zoom, tocolor(200,200,200), 1, assets.fonts[2], "left", "center")
    dxDrawText("($)", sw/2-495/2/zoom+111/zoom, sh/2-669/2/zoom+581/zoom+20/zoom, 96/zoom+sw/2-495/2/zoom, 41/zoom+sh/2-669/2/zoom+581/zoom, tocolor(150,150,150), 1, assets.fonts[2], "left", "center")
    
    -- dol prawo
    dxDrawImage(sw/2-495/2/zoom+390/zoom-50/zoom, sh/2-669/2/zoom+572/zoom-15/zoom, 91/zoom, 91/zoom, assets.textures[5])
    dxDrawText("STOP", sw/2-495/2/zoom+390/zoom-50/zoom+2, sh/2-669/2/zoom+572/zoom-15/zoom+2, 91/zoom+sw/2-495/2/zoom+390/zoom-50/zoom, 91/zoom+sh/2-669/2/zoom+572/zoom-15/zoom, tocolor(200, 200, 200), 1, assets.fonts[5], "center", "center")
    dxDrawImage(sw/2-495/2/zoom+390/zoom+20/zoom, sh/2-669/2/zoom+572/zoom-15/zoom, 91/zoom, 91/zoom, assets.textures[6])
    dxDrawText("START", sw/2-495/2/zoom+390/zoom+20/zoom+2, sh/2-669/2/zoom+572/zoom-15/zoom+2, 91/zoom+sw/2-495/2/zoom+390/zoom+20/zoom, 91/zoom+sh/2-669/2/zoom+572/zoom-15/zoom, tocolor(200, 200, 200), 1, assets.fonts[5], "center", "center")

    onClick(sw/2-495/2/zoom+390/zoom+20/zoom, sh/2-669/2/zoom+572/zoom-15/zoom, 91/zoom, 91/zoom, function()
        if(not ui.washing and ui.program ~= 0)then
            local v=getPedOccupiedVehicle(localPlayer)
            if(SPAM.getSpam())then return end

            triggerServerEvent("take.money", resourceRoot, v, ui.programs[ui.program].cost, time, ui.programs[ui.program].time, ui.program)
        end
    end)

    onClick(sw/2-495/2/zoom+390/zoom-50/zoom, sh/2-669/2/zoom+572/zoom-15/zoom, 91/zoom, 91/zoom, function()
        if(ui.washing)then
            if(SPAM.getSpam())then return end

            local v=getPedOccupiedVehicle(localPlayer)
            triggerServerEvent("destroy.water", resourceRoot, v)
            ui.washing=false

            toggleAllControls(true)
            toggleControl("radar", false)
        end
    end)

    onClick(sw/2-562/2/zoom+562/zoom-10/zoom-20/zoom, sh/2-669/2/zoom+20/zoom, 10/zoom, 10/zoom, function()
        if(not ui.washing)then
            ui.destroy()
        end
    end)
end

ui.create=function()
    ui.program=0

    blur=exports.blur

    addEventHandler("onClientRender", root, ui.onRender)

    assets.create()

    showCursor(true)
end

ui.destroy=function()
    removeEventHandler("onClientRender", root, ui.onRender)

    assets.destroy()

    showCursor(false)

    local v=getPedOccupiedVehicle(localPlayer)
    setElementFrozen(v, false)
end

-- triggers

ui.effect={}
addEvent("create.water", true)
addEventHandler("create.water", resourceRoot, function(veh, player, time, id)
    if(player == localPlayer)then
        local v=getPedOccupiedVehicle(localPlayer)
        ui.washing=getTickCount()

        toggleAllControls(false)

        setTimer(function()
            triggerServerEvent("destroy.water", resourceRoot, v)
            ui.washing=false

            toggleAllControls(true)
            toggleControl("radar", false)

            local data=getElementData(v, "vehicle:dirt") or 1
            local next=data-id
            next=next < 1 and 1 or next

            setElementData(v, "vehicle:dirt", next)
        end, (time*1000), 1)
    end

    if(veh and isElement(veh))then
        local x,y,z=getElementPosition(veh)
        ui.effect[veh]=createEffect("carwashspray", x, y, z, 0, 0, 0, 0, true)
    end
end)

addEvent("destroy.water", true)
addEventHandler("destroy.water", resourceRoot, function(veh)
    if(ui.effect[veh] and isElement(ui.effect[veh]))then
        destroyElement(ui.effect[veh])
    end
end)

-- useful

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