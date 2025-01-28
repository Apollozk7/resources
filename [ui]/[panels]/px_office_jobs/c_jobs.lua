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
local scroll=exports.px_scroll
local buttons=exports.px_buttons
local noti=exports.px_noti

-- assets

local assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/header_icon.png",
        "textures/close.png",
        "textures/row.png",
        "textures/places.png",
        "textures/icon-1.png",
        "textures/icon-2.png",
    },

    fonts={
        {"Medium", 17},
        {"Regular", 11},
        {"Regular", 13},
        {"Medium", 13},
        {"SemiBold", 13},
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

local ui={}

ui.mainAlpha=0
ui.centerAlpha=0
ui.selectedVeh=0
ui.scroll=false

ui.btns={}
ui.edits={}
ui.places={}

ui.tick=5000

-- functions

ui.updateButton=function(users)
    users=users or {}

    local exist=false
    for i,v in pairs(users) do
        if(v.name == getPlayerName(localPlayer))then
            buttons:destroyButton(ui.btns[1])
            ui.btns[1]=buttons:createButton(sw/2-761/2/zoom+340/zoom+(420-147)/2/zoom, sh/2-399/2/zoom+55/zoom+285/zoom, 147/zoom, 38/zoom, "ZWOLNIJ", ui.centerAlpha, 9, false, false, ":px_office_jobs/textures/button_icon.png", {132,39,39})
            exist=true
            break
        end
    end

    if(not exist)then
        buttons:destroyButton(ui.btns[1])
        ui.btns[1]=buttons:createButton(sw/2-761/2/zoom+340/zoom+(420-147)/2/zoom, sh/2-399/2/zoom+55/zoom+285/zoom, 147/zoom, 38/zoom, "ZATRUDNIJ", ui.centerAlpha, 9, false, false, ":px_office_jobs/textures/button_icon.png")
    end
end

ui.onRender=function()
    blur:dxDrawBlur(sw/2-761/2/zoom, sh/2-399/2/zoom, 761/zoom, 399/zoom, tocolor(255, 255, 255, ui.mainAlpha))
    dxDrawImage(sw/2-761/2/zoom, sh/2-399/2/zoom, 761/zoom, 399/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    dxDrawText("Prace urzędowe", sw/2-761/2/zoom, sh/2-399/2/zoom, 761/zoom+sw/2-761/2/zoom, sh/2-399/2/zoom+55/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[1], "center", "center")
    dxDrawImage(sw/2-761/2/zoom+(761/2)/zoom+dxGetTextWidth("Prace urzędowe", 1, assets.fonts[1])/2+10/zoom, sh/2-399/2/zoom+(55-18)/2/zoom, 18/zoom, 18/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    dxDrawImage(sw/2-761/2/zoom+761/zoom-10/zoom-(55-10)/2/zoom, sh/2-399/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    dxDrawRectangle(sw/2-760/2/zoom, sh/2-399/2/zoom+55/zoom, 760/zoom, 1, tocolor(85, 85, 85, ui.mainAlpha))
    dxDrawRectangle(sw/2-760/2/zoom+336/zoom, sh/2-399/2/zoom+55/zoom, 1, 399/zoom-55/zoom, tocolor(85, 85, 85, ui.mainAlpha))

    -- srodek
    local row=math.floor(scroll:dxScrollGetPosition(ui.scroll)+1)
    local x=0
    for i=row,row+3 do
        local v=ui.places[i]
        if(v)then
            v.hoverAlpha=v.hoverAlpha or 0

            x=x+1

            local sY=(60/zoom)*(x-1)

            if(isMouseInPosition(sw/2-761/2/zoom, sh/2-399/2/zoom+55/zoom+1+sY, 336/zoom, 57/zoom) and not v.animate and v.hoverAlpha < 100)then
                v.animate=true
                animate(0, 255, "Linear", 250, function(a)
                    v.hoverAlpha=a
                end, function()
                    v.animate=false
                end)
            elseif(v.hoverAlpha and not isMouseInPosition(sw/2-761/2/zoom, sh/2-399/2/zoom+55/zoom+1+sY, 336/zoom, 57/zoom) and not v.animate and v.hoverAlpha > 0)then
                v.animate=true
                animate(255, 0, "Linear", 250, function(a)
                    v.hoverAlpha=a
                end, function()
                    v.animate=false
                end)
            end

            onClick(sw/2-761/2/zoom, sh/2-399/2/zoom+55/zoom+1+sY, 336/zoom, 57/zoom, function()
                if(ui.animate)then return end

                ui.animate=true
                animate(255, 0, "Linear", 250, function(a)
                    ui.centerAlpha=a
                    buttons:buttonSetAlpha(ui.btns[1], a)
                end, function()
                    ui.selected=i

                    ui.updateButton(ui.places[ui.selected].users)

                    setTimer(function()
                        animate(0, 255, "Linear", 250, function(a)
                            ui.centerAlpha=a
                            buttons:buttonSetAlpha(ui.btns[1], a)
                        end, function()
                            ui.animate=false
                        end)
                    end, 100, 1)
                end)
            end)

            dxDrawImage(sw/2-761/2/zoom, sh/2-399/2/zoom+55/zoom+1+sY, 336/zoom, 57/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))
            dxDrawRectangle(sw/2-761/2/zoom, sh/2-399/2/zoom+55/zoom+1+sY+56/zoom, 336/zoom, 1, tocolor(85, 85, 85, ui.mainAlpha))
            dxDrawRectangle(sw/2-761/2/zoom, sh/2-399/2/zoom+55/zoom+1+sY+56/zoom, 336/zoom, 1, tocolor(39, 169, 119, v.hoverAlpha > ui.mainAlpha and ui.mainAlpha or v.hoverAlpha))   
            if(ui.selected == i)then
                dxDrawRectangle(sw/2-761/2/zoom, sh/2-399/2/zoom+55/zoom+1+sY+56/zoom, 336/zoom, 1, tocolor(39, 169, 119, ui.mainAlpha))
            end

            local id=string.find(v.name, "Tuner") and 6 or 7
            local w,h=dxGetMaterialSize(assets.textures[id])
            dxDrawImage(sw/2-761/2/zoom+24/zoom, sh/2-399/2/zoom+55/zoom+1+sY+(57-h/zoom)/2/zoom, w/zoom, h/zoom, assets.textures[id], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

            dxDrawText(v.name, sw/2-761/2/zoom+70/zoom, sh/2-399/2/zoom+55/zoom+1+sY-17/zoom, 336/zoom, 57/zoom+sh/2-399/2/zoom+55/zoom+1+sY, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[3], "left", "center")
            
            local type=string.find(v.name, "LV") and "Las Venturas" or string.find(v.name, "SF") and "San Fierro" or "(?)"
            dxDrawText(type, sw/2-761/2/zoom+70/zoom, sh/2-399/2/zoom+55/zoom+1+sY+17/zoom, 336/zoom, 57/zoom+sh/2-399/2/zoom+55/zoom+1+sY, tocolor(150, 150, 150, ui.mainAlpha), 1, assets.fonts[2], "left", "center")
        
            local users=v.users or {}
            local text=#users == v.places and "#c93e2f"..#users.."#b3b3b3/"..v.places or "#2fc970"..#users.."#b3b3b3/"..v.places
            dxDrawText(text, 0, sh/2-399/2/zoom+55/zoom+1+sY, sw/2-761/2/zoom+280/zoom, 57/zoom+sh/2-399/2/zoom+55/zoom+1+sY, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[3], "right", "center", false, false, false, true) 
            
            local w,h=dxGetMaterialSize(assets.textures[5])
            dxDrawImage(sw/2-761/2/zoom+290/zoom, sh/2-399/2/zoom+55/zoom+1+sY+(57-h/zoom)/2/zoom, w/zoom, h/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))
        end
    end

    local select=ui.places[ui.selected]
    if(select)then
        dxDrawText("Stanowisko:", sw/2-761/2/zoom+336/zoom, sh/2-399/2/zoom+55/zoom+25/zoom, sw/2-761/2/zoom+761/zoom, sh/2-399/2/zoom+399/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[5], "center", "top")
        dxDrawRectangle(sw/2-761/2/zoom+336/zoom+(420-140)/2/zoom, sh/2-399/2/zoom+55/zoom+50/zoom, 140/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
        
        local id=string.find(select.name, "Tuner") and 6 or 7
        local w,h=dxGetMaterialSize(assets.textures[id])
        w,h=w/1.3,h/1.3
        dxDrawImage(sw/2-761/2/zoom+336/zoom+(420/zoom-dxGetTextWidth(select.name, 1, assets.fonts[4]))/2-w/zoom-10/zoom, sh/2-399/2/zoom+55/zoom+60/zoom, w/zoom, h/zoom, assets.textures[id], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
        dxDrawText(select.name, sw/2-761/2/zoom+336/zoom, sh/2-399/2/zoom+55/zoom+60/zoom, sw/2-761/2/zoom+761/zoom, sh/2-399/2/zoom+55/zoom+60/zoom+h/zoom, tocolor(180, 180, 180, ui.centerAlpha), 1, assets.fonts[4], "center", "top")

        dxDrawText("Wymaga aktywności:", sw/2-761/2/zoom+336/zoom, sh/2-399/2/zoom+55/zoom+98/zoom, sw/2-761/2/zoom+761/zoom, sh/2-399/2/zoom+399/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[5], "center", "top")
        dxDrawRectangle(sw/2-761/2/zoom+336/zoom+(420-140)/2/zoom, sh/2-399/2/zoom+55/zoom+125/zoom, 140/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
        dxDrawText("Co 24 godziny", sw/2-761/2/zoom+336/zoom, sh/2-399/2/zoom+55/zoom+130/zoom, sw/2-761/2/zoom+761/zoom, sh/2-399/2/zoom+399/zoom, tocolor(180, 180, 180, ui.centerAlpha), 1, assets.fonts[4], "center", "top")

        local type=string.find(select.name, "LV") and "Las Venturas" or string.find(select.name, "SF") and "San Fierro" or "(?)"
        dxDrawText("Lokalizacja:", sw/2-761/2/zoom+336/zoom, sh/2-399/2/zoom+55/zoom+171/zoom, sw/2-761/2/zoom+761/zoom, sh/2-399/2/zoom+399/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[5], "center", "top")
        dxDrawRectangle(sw/2-761/2/zoom+336/zoom+(420-140)/2/zoom, sh/2-399/2/zoom+55/zoom+199/zoom, 140/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
        dxDrawText(type, sw/2-761/2/zoom+336/zoom, sh/2-399/2/zoom+55/zoom+205/zoom, sw/2-761/2/zoom+761/zoom, sh/2-399/2/zoom+399/zoom, tocolor(180, 180, 180, ui.centerAlpha), 1, assets.fonts[4], "center", "top")
    
        local users=select.users or {}
        local text=#users == select.places and "#c93e2f"..#users.."#b3b3b3/"..select.places or "#2fc970"..#users.."#b3b3b3/"..select.places
        dxDrawText("Miejsca: "..text, sw/2-761/2/zoom+336/zoom, sh/2-399/2/zoom+55/zoom+254/zoom, sw/2-761/2/zoom+761/zoom, sh/2-399/2/zoom+399/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[4], "center", "top", false, false, false, true)
    
        onClick(sw/2-761/2/zoom+340/zoom+(420-147)/2/zoom, sh/2-399/2/zoom+55/zoom+285/zoom, 147/zoom, 38/zoom, function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("get.job", resourceRoot, select.name, ui.city)
        end)
    end

    onClick(sw/2-761/2/zoom+761/zoom-10/zoom-(55-10)/2/zoom, sh/2-399/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, function()
        ui.destroy()
    end)
end

ui.create=function()
    if(ui.animate)then return end

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)
    showCursor(true)

    ui.selected=1

    ui.scroll=scroll:dxCreateScroll(sw/2-761/2/zoom+(761/2)/zoom-4, sh/2-399/2/zoom+55/zoom+20/zoom, 4/zoom, 4/zoom, 0, 4, ui.places, 244/zoom, 0, 1)
    ui.updateButton(ui.places[ui.selected].users)

    ui.animate=true
    animate(0, 255, "Linear", 250, function(a)
        ui.mainAlpha=a
        ui.centerAlpha=a

        scroll:dxScrollSetAlpha(ui.scroll, a)
        buttons:buttonSetAlpha(ui.btns[1], a)
    end, function()
        ui.animate=false
    end)
end

ui.destroy=function()
    if(ui.animate)then return end

    showCursor(false)

    ui.animate=true
    animate(255, 0, "Linear", 250, function(a)
        ui.mainAlpha=a
        ui.centerAlpha=a

        scroll:dxScrollSetAlpha(ui.scroll, a)
        buttons:buttonSetAlpha(ui.btns[1], a)
    end, function()
        assets.destroy()

        removeEventHandler("onClientRender", root, ui.onRender)

        ui.animate=false

        scroll:dxDestroyScroll(ui.scroll)
        buttons:destroyButton(ui.btns[1])

        ui.places={}
    end)
end

ui.refresh=function(places)
    ui.places=places
    ui.updateButton(ui.places[ui.selected].users)
end
addEvent("refresh.ui", true)
addEventHandler("refresh.ui", resourceRoot, ui.refresh)

-- triggers

addEvent("open.ui", true)
addEventHandler("open.ui", resourceRoot, function(places,city)
    blur=exports.blur
    scroll=exports.px_scroll
    buttons=exports.px_buttons
    noti=exports.px_noti

    ui.places=places
    ui.city=city

    ui.create()
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