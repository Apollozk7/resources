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

sw,sh=guiGetScreenSize()
zoom=1920/sw

-- exports

local blur=exports.blur
local scroll = exports.px_scroll
local buttons = exports.px_buttons

-- assets

assets={}
assets.list={
    texs={
        "textures/bg.png",
        "textures/kajdanki.png",
        "textures/close.png",
        "textures/row.png",
        "textures/checkbox.png",
        "textures/checkbox_selected.png",
        "textures/list.png",
    },

    fonts={
        {"Regular", 17},
        {"Medium", 13},
        {"Regular", 11},
        {"Regular", 13},
        {"Regular", 15},
    },
}

assets.textures={}
assets.fonts={}
assets.create=function()
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

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

local ui={}

ui.tbl={
    {name="Stwarzanie zagrożenia w ruchu drogowym", time=15},
    {name="Zawracanie w miejscu niedozwolonym", time=6},
    {name="Przekroczenie prędkości od 10-30km/h", time=6},
    {name="Przekroczenie prędkości od 30-50km/h", time=15},
    {name="Przekroczenie prędkości od 50km/h", time=20},
    {name="Niestosowanie się do poleceń funkcjonariusza", time=12},
    {name="Utrudnianie pracy funkcjonariusza", time=15},
    {name="Obraza funkcjonariusza ", time=20},
    {name="Jazda pod prąd", time=10},
    {name="Posługiwanie się fałszywymi dokumentami", time=10},
    {name="Próba wręczenia łapówki funkcjonariuszowi", time=20},
    {name="Zakłócanie porządku publicznego", time=12},
    {name="Ucieczka przed departamentem", time=30}, 
    {name="Niestosowanie się do zasad RP ", time=30},
    {name="Wtargnięcie pod jadący pojazd", time=12}, 
    {name="Jazda po chodniku", time=10},
    {name="Spowodowanie kolizji", time=7},
    {name="Spodowowanie wypadku", time=14},
    {name="Wejście na teren zamknięty", time=6},
    {name="Zły stan techniczny pojazdu", time=10},
    {name="Przewożenie osób w sposób niewłaściwy", time=15},
}

ui.row=1
ui.button=false
ui.scroll=false
ui.target=false

-- draw

ui.onRender=function()
    if(not ui.target or (ui.target and not isElement(ui.target)))then
        ui.destroy()
        return
    end

    blur:dxDrawBlur(sw/2-695/2/zoom, sh/2-608/2/zoom, 695/zoom, 608/zoom, tocolor(255, 255, 255, 255))
    dxDrawImage(sw/2-695/2/zoom, sh/2-608/2/zoom, 695/zoom, 608/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, 255))

    -- header
    dxDrawText("Więzienie", sw/2-695/2/zoom, sh/2-608/2/zoom, 695/zoom+sw/2-695/2/zoom, sh/2-608/2/zoom+55/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "center", "center")
    local w=dxGetTextWidth("Więzienie", 1, assets.fonts[1])
    dxDrawImage(sw/2-695/2/zoom+695/2/zoom-20/2+w/2+20/zoom, sh/2-608/2/zoom+(60-20)/2/zoom, 20/zoom, 20/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, 255))

    -- close
    dxDrawImage(sw/2-695/2/zoom+695/zoom-10/zoom-(55-10)/2/zoom, sh/2-608/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, 255))
    --
    dxDrawRectangle(sw/2-654/2/zoom, sh/2-608/2/zoom+55/zoom-1, 654/zoom, 1, tocolor(85,85,85,255))

    -- list
    dxDrawImage(sw/2-695/2/zoom, sh/2-608/2/zoom+55/zoom, 695/zoom, 22/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, 255))

    dxDrawText("Nazwa wykroczenia", sw/2-695/2/zoom+65/zoom, sh/2-608/2/zoom+55/zoom, 695/zoom, 22/zoom+sh/2-608/2/zoom+55/zoom, tocolor(170, 170, 170,255), 1, assets.fonts[3])
    dxDrawText("Długość kary", sw/2-695/2/zoom+500/zoom, sh/2-608/2/zoom+55/zoom, sw/2-695/2/zoom+500/zoom+140/zoom, 22/zoom+sh/2-608/2/zoom+55/zoom, tocolor(170, 170, 170,255), 1, assets.fonts[3])

    ui.row = math.floor(scroll:dxScrollGetPosition(ui.scroll)+1)

    local selected=0
    local time=0

    local k=0
    for i=ui.row,ui.row+7 do
        local v=ui.tbl[i]
        if(v)then
            k=k+1
            local sY=(59/zoom)*(k-1)

            v.alpha=v.alpha or 255
            v.hoverAlpha=v.hoverAlpha or 0

            if(v.selected)then
                selected=selected+1
                time=time+v.time
            end

            if(isMouseInPosition(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, 693/zoom, 57/zoom) and not v.animate and v.hoverAlpha < 100)then
                v.animate=true
                animate(0, 100, "Linear", 250, function(a)
                    v.hoverAlpha=a
                    v.alpha=100-a
                end, function()
                    v.animate=false
                end)
            elseif(v.hoverAlpha and not isMouseInPosition(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, 693/zoom, 57/zoom) and not v.animate and v.hoverAlpha > 0)then
                v.animate=true
                animate(100, 0, "Linear", 250, function(a)
                    v.hoverAlpha=a
                    v.alpha=100-a
                end, function()
                    v.animate=false
                end)
            end

            dxDrawImage(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, 693/zoom, 57/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, 255))
            dxDrawRectangle(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom-1, 693/zoom, 1, tocolor(85, 85, 85,v.alpha))
            dxDrawRectangle(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom-1, 693/zoom, 1, tocolor(0,255,200,v.hoverAlpha))

            dxDrawImage(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+(57-42)/2/zoom+55/zoom+20/zoom+2+sY, 42/zoom, 42/zoom, not v.selected and assets.textures[5] or assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, 255))
            onClick(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+(57-42)/2/zoom+55/zoom+20/zoom+2+sY, 42/zoom, 42/zoom, function()
                v.selected=not v.selected
            end)

            dxDrawText(v.name, sw/2-695/2/zoom+65/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, 695/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom, tocolor(220, 220, 220,255), 1, assets.fonts[4], "left", "center")
            dxDrawText(v.time.." minut", sw/2-695/2/zoom+500/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, sw/2-695/2/zoom+500/zoom+140/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom, tocolor(220, 220, 220,255), 1, assets.fonts[2], "left", "center", false, false, false, true)
        end
    end

    dxDrawImage(sw/2-695/2/zoom, sh/2-608/2/zoom+608/zoom-57/zoom, 695/zoom, 57/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Wybrano "..selected.." zarzutów", sw/2-695/2/zoom+15/zoom, sh/2-608/2/zoom+608/zoom-57/zoom, 695/zoom, 57/zoom+sh/2-608/2/zoom+608/zoom-57/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "center")
    dxDrawText("Łączny czas "..time.." minut", sw/2-695/2/zoom, sh/2-608/2/zoom+608/zoom-57/zoom, 695/zoom+sw/2-695/2/zoom, 57/zoom+sh/2-608/2/zoom+608/zoom-57/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "center")

    onClick(sw/2-695/2/zoom+695/zoom-10/zoom-(55-10)/2/zoom, sh/2-608/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, function()
        ui.destroy()
    end)

    onClick(sw/2-694/2/zoom+524/zoom, sh/2-608/2/zoom+608/zoom-50/zoom, 148/zoom, 39/zoom, function()
        if(SPAM.getSpam())then return end

        local reason=""
        local time=0
        for i,v in pairs(ui.tbl) do
            if(v.selected)then
                time=time+v.time
                reason=#reason > 0 and reason..", "..v.name or v.name
            end
        end
        triggerServerEvent("start.jail", resourceRoot, ui.target, reason, time)
        ui.destroy()
    end)
end

-- functions

ui.create=function(target)
    blur=exports.blur
    scroll = exports.px_scroll
    buttons = exports.px_buttons

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)

    showCursor(true)

    ui.scroll=scroll:dxCreateScroll(sw/2-695/2/zoom+695/zoom-4/zoom, sh/2-608/2/zoom+55/zoom+22/zoom, 4/zoom, 4/zoom, 0, 8, ui.tbl, 470/zoom, 255)

    ui.button=buttons:createButton(sw/2-694/2/zoom+524/zoom, sh/2-608/2/zoom+608/zoom-50/zoom, 148/zoom, 39/zoom, "AKCEPTUJ", 255, 10/zoom, false, false, ":px_factions-jail/textures/kontynuuj.png")

    ui.target=target

    for i,v in pairs(ui.tbl) do
        v.selected=false
    end
end

ui.destroy=function()
    assets.destroy()

    removeEventHandler("onClientRender", root, ui.onRender)

    showCursor(false)

    scroll:dxDestroyScroll(ui.scroll)
    ui.scroll = false

    buttons:destroyButton(ui.button)
    ui.button=false
end

-- export

function action(id,target,name)
    if(name == "Wsadź do więzienia")then
        ui.create(target)
    end
end

-- useful by asper

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