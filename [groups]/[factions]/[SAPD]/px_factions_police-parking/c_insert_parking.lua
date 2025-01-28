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
        {":px_assets/fonts/Font-Medium.ttf", 16},
        {":px_assets/fonts/Font-Regular.ttf", 12},
    },

    textures={},
    textures_paths={
        "textures/bg.png",
        "textures/header.png",
        "textures/row.png",
        "textures/checkbox.png",
        "textures/checkbox_selected.png",
    },
}

--

local UI={}

UI.info={}
UI.edits={}
UI.btns={}

UI.tbl={
    {name="Pojazd po pościgu przed departamentem policji"},
    {name="Pojazd niepoprawnie zaparkowany"},
    {name="Pojazd porzucony/utrudniający ruch publiczny"},
    {name="Pojazd utrudniający przejazd"},
    {name="Pojazd utrudniający pracę frakcji"},
    {name="Pojazd zastawiający wjazd"},
}
--

UI.onRender=function()
    blur:dxDrawBlur(sw/2-434/2/zoom, sh/2-623/2/zoom, 434/zoom, 623/zoom, tocolor(255, 255, 255))
    dxDrawImage(sw/2-434/2/zoom, sh/2-623/2/zoom, 434/zoom, 623/zoom, assets.textures[1])

    dxDrawText("Parking policyjny", sw/2-434/2/zoom, sh/2-623/2/zoom, 434/zoom+sw/2-434/2/zoom, sh/2-623/2/zoom+55/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")

    dxDrawRectangle(sw/2-400/2/zoom, sh/2-623/2/zoom+55/zoom, 400/zoom, 1, tocolor(80, 80, 80))

    dxDrawText("Wybierz #2193b0powód#dcdcdc, dla którego oddajesz pojazd.", sw/2-434/2/zoom, sh/2-623/2/zoom+55/zoom, 434/zoom+sw/2-434/2/zoom, sh/2-623/2/zoom+55/zoom+48/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "center", false, false, false, true)

    dxDrawImage(sw/2-434/2/zoom, sh/2-623/2/zoom+55/zoom+48/zoom, 434/zoom, 32/zoom, assets.textures[2])
    dxDrawText("Powód", sw/2-434/2/zoom+54/zoom, sh/2-623/2/zoom+55/zoom+48/zoom, 434/zoom, 32/zoom+sh/2-623/2/zoom+55/zoom+48/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "center", false, false, false, true)

    local reason=""
    for i,v in pairs(UI.tbl) do
        local sY=(59/zoom)*(i-1)
        dxDrawImage(sw/2-427/2/zoom, sh/2-623/2/zoom+55/zoom+48/zoom+33/zoom+sY, 427/zoom, 57/zoom, assets.textures[3])
        dxDrawRectangle(sw/2-427/2/zoom, sh/2-623/2/zoom+55/zoom+48/zoom+33/zoom+sY+57/zoom-1, 427/zoom, 1, tocolor(85, 85, 85))
        dxDrawImage(sw/2-427/2/zoom+(57-42)/2/zoom, sh/2-623/2/zoom+55/zoom+48/zoom+33/zoom+sY+(57-42)/2/zoom, 42/zoom, 42/zoom, v.selected and assets.textures[5] or assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawText(v.name, sw/2-434/2/zoom+54/zoom, sh/2-623/2/zoom+55/zoom+48/zoom+33/zoom+sY, 434/zoom, sh/2-623/2/zoom+55/zoom+48/zoom+33/zoom+sY+57/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "center", false, false, false, true)
    
        onClick(sw/2-427/2/zoom+(57-42)/2/zoom, sh/2-623/2/zoom+55/zoom+48/zoom+33/zoom+sY+(57-42)/2/zoom, 42/zoom, 42/zoom, function()
            v.selected=not v.selected
        end)

        if(v.selected)then
            reason=#reason > 0 and reason..", "..v.name or v.name
        end
    end

    dxDrawImage(sw/2-427/2/zoom, sh/2-623/2/zoom+623/zoom-57/zoom-62/zoom, 427/zoom, 57/zoom, assets.textures[3])
    dxDrawRectangle(sw/2-427/2/zoom, sh/2-623/2/zoom+623/zoom-57/zoom-62/zoom+57/zoom-1, 427/zoom, 1, tocolor(80, 80, 80))

    onClick(sw/2+88/zoom, sh/2-623/2/zoom+623/zoom-39/zoom-(57-39)/2/zoom, 118/zoom, 39/zoom, function() --do przecho
        triggerServerEvent("add.vehicle->przecho", resourceRoot, UI.info)

        removeEventHandler("onClientRender",root,UI.onRender)

        assets.destroy()

        showCursor(false)

        setElementData(localPlayer, "user:gui_showed", false, false)

        edit:dxDestroyEdit(UI.edits[1])

        buttons:destroyButton(UI.btns[1])
        buttons:destroyButton(UI.btns[2])
        buttons:destroyButton(UI.btns[3])

        UI.btns={}

        setElementFrozen(getPedOccupiedVehicle(localPlayer),false)
    end)

    onClick(sw/2-72.5/zoom, sh/2-623/2/zoom+623/zoom-39/zoom-(57-39)/2/zoom, 148/zoom, 39/zoom, function() -- zatwierdź
        local cost=edit:dxGetEditText(UI.edits[1]) or ""
        if(#reason > 0)then
            if(utf8.len(cost) > 0 and tonumber(cost) > 0 and tonumber(cost) < 1300)then
                if(SPAM.getSpam())then return end

                cost=math.floor(cost)
                cost=tonumber(cost)
                
                triggerServerEvent("add.vehicle", resourceRoot, UI.info, cost, reason)

                removeEventHandler("onClientRender",root,UI.onRender)
        
                assets.destroy()
        
                showCursor(false)
        
                setElementData(localPlayer, "user:gui_showed", false, false)
        
                edit:dxDestroyEdit(UI.edits[1])
        
                buttons:destroyButton(UI.btns[1])
                buttons:destroyButton(UI.btns[2])
                buttons:destroyButton(UI.btns[3])

                UI.btns={}

                setElementFrozen(getPedOccupiedVehicle(localPlayer),false)
            else
                noti:noti("Wprowadź koszt. (max: 1.300$)", "error")
            end
        else
            noti:noti("Wybierz powód.", "error")
        end
    end)

    onClick(sw/2-148/zoom-55/zoom, sh/2-623/2/zoom+623/zoom-39/zoom-(57-39)/2/zoom, 118/zoom, 39/zoom, function() --anuluj
        removeEventHandler("onClientRender",root,UI.onRender)

        assets.destroy()

        showCursor(false)

        setElementData(localPlayer, "user:gui_showed", false, false)

        edit:dxDestroyEdit(UI.edits[1])

        buttons:destroyButton(UI.btns[1])
        buttons:destroyButton(UI.btns[2])
        buttons:destroyButton(UI.btns[3])

        UI.btns={}

        setElementFrozen(getPedOccupiedVehicle(localPlayer),false)
    end)
end

addEvent("get.vehicle", true)
addEventHandler("get.vehicle", resourceRoot, function(id,towing)
    if(id and towing)then
        if(getElementData(localPlayer, "user:gui_showed"))then return end

        blur=exports.blur
        edit=exports.px_editbox
        buttons = exports.px_buttons
        noti=exports.px_noti

        assets.create()

        addEventHandler("onClientRender",root,UI.onRender)

        showCursor(true)

        UI.info={id,towing}

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

        UI.edits[1]=edit:dxCreateEdit("Kwota mandatu", sw/2-434/2/zoom+(57-30)/2/zoom, sh/2-623/2/zoom+623/zoom-57/zoom-62/zoom+(57-30)/2/zoom, 294/zoom, 30/zoom, false, 11/zoom, 255, true, false, ":px_factions_police-parking/textures/editbox-icon-$.png")

        UI.btns[1]=buttons:createButton(sw/2-148/zoom-55/zoom, sh/2-623/2/zoom+623/zoom-39/zoom-(57-39)/2/zoom, 118/zoom, 39/zoom, "ANULUJ", 255, 10/zoom, false, false, ":px_factions_police-parking/textures/button-icon-x.png", {156,40,40})
        UI.btns[2]=buttons:createButton(sw/2-72.5/zoom, sh/2-623/2/zoom+623/zoom-39/zoom-(57-39)/2/zoom, 148/zoom, 39/zoom, "ZATWIERDŹ", 255, 10/zoom, false, false, ":px_factions_police-parking/textures/button-icon-play.png")
        UI.btns[3]=buttons:createButton(sw/2+88/zoom, sh/2-623/2/zoom+623/zoom-39/zoom-(57-39)/2/zoom, 118/zoom, 39/zoom, "ODDAJ\nDO PRZECHO", 255, 8/zoom, false, false, false, {58,104,127})
        
        setElementFrozen(getPedOccupiedVehicle(localPlayer),true)
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