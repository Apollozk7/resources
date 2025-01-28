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

-- assets

local assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/header_icon.png",

        "textures/row.png",
        "textures/row_selected.png",

        "textures/car_icon.png",

        "textures/accept_button.png",
        "textures/cancel_button.png",
    },

    fonts={
        {"Medium", 17},
        {"Regular", 11},
        {"Regular", 13},
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

local ui={}

ui.mainAlpha=0
ui.centerAlpha=0
ui.selectedVeh=0
ui.newPlate=false
ui.newPlateText=""
ui.plateColor={255,255,255}
ui.scroll=false

ui.btns={}
ui.edits={}
ui.vehs={}

ui.letters={
    'q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m','1','2','3','4','5','6','7','8','9','0','-'
}

ui.getLetter=function(text)
    local next=0
    for i=1,#text do
        local v=utf8.sub(text,i,i)
        for _,key in pairs(ui.letters) do
            if(utf8.lower(v) == utf8.lower(key))then
                next=next+1
                break
            end
        end
    end
    return next == #text
end

-- functions

ui.updatePlateTex=function(text, color)
    if(ui.newPlate and isElement(ui.newPlate))then
        destroyElement(ui.newPlate)
    end

    ui.newPlate=plates:getPlateRT(text, color or ui.plateColor)
end

ui.onRender=function()
    blur:dxDrawBlur(sw/2-726/2/zoom, sh/2-377/2/zoom, 726/zoom, 377/zoom, tocolor(255, 255, 255, ui.mainAlpha))
    dxDrawImage(sw/2-726/2/zoom, sh/2-377/2/zoom, 726/zoom, 377/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    dxDrawText("Zmiana tablic", sw/2-726/2/zoom, sh/2-377/2/zoom, 726/zoom+sw/2-726/2/zoom, sh/2-377/2/zoom+55/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[1], "center", "center")
    dxDrawImage(sw/2-726/2/zoom+(726/2)/zoom+dxGetTextWidth("Zmiana tablic", 1, assets.fonts[1])/2+10/zoom, sh/2-377/2/zoom+(55-18)/2/zoom, 18/zoom, 18/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    dxDrawRectangle(sw/2-694/2/zoom, sh/2-377/2/zoom+55/zoom, 694/zoom, 1, tocolor(85, 85, 85, ui.mainAlpha))
    dxDrawRectangle(sw/2, sh/2-377/2/zoom+55/zoom, 1, 377/zoom-55/zoom-58/zoom, tocolor(85, 85, 85, ui.mainAlpha))
    dxDrawRectangle(sw/2-726/2/zoom, sh/2-377/2/zoom+377/zoom-58/zoom, 726/zoom, 1, tocolor(85, 85, 85, ui.mainAlpha))

    -- list
    dxDrawText("Pojazd", sw/2-726/2/zoom+71/zoom, sh/2-377/2/zoom+55/zoom, 726/zoom, sh/2-377/2/zoom+55/zoom+22/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[2], "left", "center")
    dxDrawText("ID", sw/2-726/2/zoom+278/zoom, sh/2-377/2/zoom+55/zoom, 726/zoom, sh/2-377/2/zoom+55/zoom+22/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[2], "left", "center")

    -- srodek
    local row=math.floor(scroll:dxScrollGetPosition(ui.scroll)+1)
    local x=0
    for i=row,row+3 do
        local v=ui.vehs[i]
        if(v)then
            v.hoverAlpha=v.hoverAlpha or 0

            x=x+1

            local sY=(60/zoom)*(x-1)

            if(isMouseInPosition(sw/2-726/2/zoom+((726/2)-359)/2/zoom, sh/2-377/2/zoom+55/zoom+22/zoom+sY, 359/zoom, 57/zoom) and not v.animate and v.hoverAlpha < 100)then
                v.animate=true
                animate(0, 255, "Linear", 250, function(a)
                    v.hoverAlpha=a
                end, function()
                    v.animate=false
                end)
            elseif(v.hoverAlpha and not isMouseInPosition(sw/2-726/2/zoom+((726/2)-359)/2/zoom, sh/2-377/2/zoom+55/zoom+22/zoom+sY, 359/zoom, 57/zoom) and not v.animate and v.hoverAlpha > 0)then
                v.animate=true
                animate(255, 0, "Linear", 250, function(a)
                    v.hoverAlpha=a
                end, function()
                    v.animate=false
                end)
            end

            onClick(sw/2-726/2/zoom+((726/2)-359)/2/zoom, sh/2-377/2/zoom+55/zoom+22/zoom+sY, 359/zoom, 57/zoom, function()
                if(ui.animate)then return end

                ui.animate=true
                animate(255, 0, "Linear", 250, function(a)
                    ui.centerAlpha=a
                    editbox:dxSetEditAlpha(ui.edits[1], a)
                end, function()
                    ui.selectedVeh=ui.selectedVeh == i and 0 or i

                    if(ui.selectedVeh ~= 0 and not ui.edits[1])then
                        ui.edits[1] = editbox:dxCreateEdit("Nowa rejestracja", sw/2-726/2/zoom+(726/2)/zoom+((726/2)-215)/2/zoom, sh/2-377/2/zoom+200/zoom, 215/zoom, 30/zoom, false, 11/zoom, ui.mainAlpha, false, false)
                    end
    
                    if(ui.selectedVeh == 0)then
                        editbox:dxDestroyEdit(ui.edits[1])
                        ui.edits[1]=nil
                    end
    
                    ui.updatePlateTex(ui.newPlateText, fromJSON(v.plateColor))

                    setTimer(function()
                        animate(0, 255, "Linear", 250, function(a)
                            ui.centerAlpha=a
                            editbox:dxSetEditAlpha(ui.edits[1], a)
                        end, function()
                            ui.animate=false
                        end)
                    end, 100, 1)
                end)
            end)

            dxDrawImage(sw/2-726/2/zoom+((726/2)-359)/2/zoom, sh/2-377/2/zoom+55/zoom+22/zoom+sY, 359/zoom, 57/zoom, ui.selectedVeh == i and assets.textures[3] or assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))
            dxDrawRectangle(sw/2-726/2/zoom+((726/2)-359)/2/zoom, sh/2-377/2/zoom+55/zoom+22/zoom+sY+56/zoom, 359/zoom, 1, tocolor(85, 85, 85, ui.mainAlpha))
            dxDrawRectangle(sw/2-726/2/zoom+((726/2)-359)/2/zoom, sh/2-377/2/zoom+55/zoom+22/zoom+sY+56/zoom, 359/zoom, 1, tocolor(59, 135, 137, v.hoverAlpha > ui.mainAlpha and ui.mainAlpha or v.hoverAlpha))

            dxDrawImage(sw/2-726/2/zoom+((726/2)-359)/2/zoom+21/zoom, sh/2-377/2/zoom+55/zoom+22/zoom+sY+(57-12)/2/zoom, 26/zoom, 12/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

            dxDrawText(getVehicleNameFromModel(v.model), sw/2-726/2/zoom+((726/2)-359)/2/zoom+70/zoom, sh/2-377/2/zoom+55/zoom+22/zoom+sY, 359/zoom, 57/zoom+sh/2-377/2/zoom+55/zoom+22/zoom+sY, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[3], "left", "center")
            dxDrawText(v.id, sw/2-726/2/zoom+((726/2)-359)/2/zoom+278/zoom, sh/2-377/2/zoom+55/zoom+22/zoom+sY, 359/zoom, 57/zoom+sh/2-377/2/zoom+55/zoom+22/zoom+sY, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[3], "left", "center")
        end
    end

    local veh=ui.vehs[ui.selectedVeh]
    if(veh and veh.plateTex)then
        ui.plateColor=fromJSON(veh.plateColor)

        dxDrawText("Obecna rejestracja", sw/2-726/2/zoom+407/zoom, sh/2-377/2/zoom+70/zoom, 95/zoom+sw/2-726/2/zoom+407/zoom, 70/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[4], "center", "top")
        dxDrawImage(sw/2-726/2/zoom+407/zoom, sh/2-377/2/zoom+100/zoom, 95/zoom, 70/zoom, veh.plateTex, 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))

        dxDrawText("Nowa rejestracja", sw/2-726/2/zoom+407/zoom+70/zoom+95/zoom, sh/2-377/2/zoom+70/zoom, 95/zoom+sw/2-726/2/zoom+407/zoom+70/zoom+95/zoom, 70/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[4], "center", "top")
        dxDrawImage(sw/2-726/2/zoom+407/zoom+70/zoom+95/zoom, sh/2-377/2/zoom+100/zoom, 95/zoom, 70/zoom, ui.newPlate, 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))

        local text=editbox:dxGetEditText(ui.edits[1]) or ""
        if(ui.newPlateText ~= text)then
            ui.newPlateText=text
            ui.updatePlateTex(text)
        end

        onClick(sw/2+10/zoom, sh/2+140/zoom, 147/zoom, 38/zoom, function()
            if(ui.getLetter(text))then
                if(SPAM.getSpam())then return end

                triggerServerEvent("set.veh.plate", resourceRoot, text, veh.id)

                ui.destroy()
            else
                noti:noti("Podane znaki są nieprawidłowe.", "error")
            end
        end)
    else
        dxDrawText("WYBIERZ POJAZD", sw/2-726/2/zoom+(726/2)/zoom, sh/2-377/2/zoom+55/zoom, sw/2-726/2/zoom+726/zoom, sh/2-377/2/zoom+377/zoom-58/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "center", "center")
    end

    onClick(sw/2-147/zoom-10/zoom, sh/2+140/zoom, 147/zoom, 38/zoom, function()
        ui.destroy()
    end)
end

ui.create=function()
    if(ui.animate)then return end

    blur=exports.blur
    plates=exports.px_plates
    editbox=exports.px_editbox
    scroll=exports.px_scroll
    buttons=exports.px_buttons
    noti=exports.px_noti

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)
    showCursor(true)

    ui.selectedVeh=false

    for i,v in pairs(ui.vehs) do
        v.plateTex=plates:getPlateRT(#v.plateText < 1 and "LV "..v.id or v.plateText, fromJSON(v.plateColor))
    end

    ui.scroll=scroll:dxCreateScroll(sw/2-726/2/zoom+(726/2)/zoom-4, sh/2-377/2/zoom+55/zoom+20/zoom, 4/zoom, 4/zoom, 0, 4, ui.vehs, 244/zoom, 0, 1)

    ui.updatePlateTex("")

    ui.btns[1]=buttons:createButton(sw/2+10/zoom, sh/2+140/zoom, 147/zoom, 38/zoom, "AKCEPTUJ", 0, 9, false, false, ":px_exchange_vehicles/textures/button-accept.png")
    ui.btns[2]=buttons:createButton(sw/2-147/zoom-10/zoom, sh/2+140/zoom, 147/zoom, 38/zoom, "ANULUJ", 0, 9, false, false, ":px_exchange_vehicles/textures/button-close.png", {132,39,39})

    ui.animate=true
    animate(0, 255, "Linear", 250, function(a)
        ui.mainAlpha=a
        ui.centerAlpha=a

        editbox:dxSetEditAlpha(ui.edits[1], a)
        scroll:dxScrollSetAlpha(ui.scroll, a)
        buttons:buttonSetAlpha(ui.btns[1], a)
        buttons:buttonSetAlpha(ui.btns[2], a)
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

        editbox:dxSetEditAlpha(ui.edits[1], a)
        scroll:dxScrollSetAlpha(ui.scroll, a)
        buttons:buttonSetAlpha(ui.btns[1], a)
        buttons:buttonSetAlpha(ui.btns[2], a)
    end, function()
        assets.destroy()

        removeEventHandler("onClientRender", root, ui.onRender)

        ui.animate=false

        editbox:dxDestroyEdit(ui.edits[1])
        scroll:dxDestroyScroll(ui.scroll)
        buttons:destroyButton(ui.btns[1])
        buttons:destroyButton(ui.btns[2])

        ui.edits={}
        ui.btns={}
        ui.scroll=false

        if(ui.newPlate and isElement(ui.newPlate))then
            destroyElement(ui.newPlate)
        end
    
        for i,v in pairs(ui.vehs) do
            if(v.plateTex and isElement(v.plateTex))then
                destroyElement(v.plateTex)
            end
        end
        ui.vehs={}
    end)
end

-- triggers

addEvent("open.plate.ui", true)
addEventHandler("open.plate.ui", resourceRoot, function(vehs)
    ui.vehs=vehs
    ui.create()
end)

-- stop

addEventHandler("onClientResourceStop", resourceRoot, function()
    if(ui.newPlate and isElement(ui.newPlate))then
        destroyElement(ui.newPlate)
    end

    for i,v in pairs(ui.vehs) do
        if(v.plateTex and isElement(v.plateTex))then
            destroyElement(v.plateTex)
        end
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