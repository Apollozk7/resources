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
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 200, 1)

    return block
end

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- assets

local assets={}
assets.list={
    texs={
        "textures/bg.png",
        "textures/header_icon.png",
        "textures/close.png",
        "textures/info.png",
        "textures/stereo.png",
    },

    fonts={
        {"Regular", 15},
        {"Regular", 10},
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

ui.btns={}
ui.edits={}

ui.volume=0
ui.volumeTick=getTickCount()

ui.scrollClick=false
ui.vehicle=false

-- functions

ui.onRender=function()
    if(isPedInVehicle(localPlayer))then return ui.destroy() end
    if(not ui.vehicle or (ui.vehicle and not isElement(ui.vehicle)))then return ui.destroy() end

    blur:dxDrawBlur(sw/2-748/2/zoom, sh/2-292/2/zoom, 748/zoom, 292/zoom, tocolor(255, 255, 255, ui.mainAlpha))
    dxDrawImage(sw/2-748/2/zoom, sh/2-292/2/zoom, 748/zoom, 292/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    dxDrawText("Graj muzykę", sw/2-748/2/zoom, sh/2-292/2/zoom, 748/zoom+sw/2-748/2/zoom, sh/2-292/2/zoom+55/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[1], "center", "center")
    dxDrawImage(sw/2-748/2/zoom+(748/2)/zoom+dxGetTextWidth("Graj muzykę", 1, assets.fonts[1])/2+10/zoom, sh/2-292/2/zoom+(55-22)/2/zoom, 22/zoom, 22/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    dxDrawImage(sw/2-748/2/zoom+748/zoom-22/zoom-(55-10)/2/zoom, sh/2-292/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    dxDrawRectangle(sw/2-748/2/zoom, sh/2-292/2/zoom+55/zoom, 748/zoom, 1, tocolor(80,80,80,ui.mainAlpha))

    dxDrawImage(sw/2-748/2/zoom, sh/2-292/2/zoom+55/zoom, 748/zoom, 29/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))
    dxDrawText("Link do muzyki powinien mieć rozszerzenie .mp3    |   Możesz również użyć bezpośredniego linku do stacji radiowej", sw/2-741/2/zoom, sh/2-292/2/zoom+55/zoom, sw/2-741/2/zoom+741/zoom, sh/2-292/2/zoom+55/zoom+29/zoom, tocolor(150, 150, 150, ui.mainAlpha), 1, assets.fonts[2], "center", "center")

    dxDrawImage(sw/2-748/2/zoom, sh/2-292/2/zoom+292/zoom-32/zoom, 748/zoom, 32/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    local x=sw/2-748/2/zoom+(748-352)/2/zoom
    dxDrawRectangle(x, sh/2-292/2/zoom+292/zoom-32/zoom+(32-5)/2, 352/zoom, 5/zoom, tocolor(60, 60, 60))
    dxDrawRectangle(x, sh/2-292/2/zoom+292/zoom-32/zoom+(32-5)/2, (352/zoom)*(ui.volume/1), 5/zoom, tocolor(130,130,130))
    if(getKeyState("mouse1") and isMouseInPosition(x, sh/2-292/2/zoom+292/zoom-32/zoom+(32-5)/2, 352/zoom, 5/zoom))then
        local sx,sy=getCursorPosition()
        sx,sy=sx*sw,sy*sh

        sx=sx-x
        sx=sx/(352/zoom)

        if(sx ~= ui.volume)then
            if(not SPAM.getSpam())then
                local doors=false
                local data=getElementData(ui.vehicle, "vehicle:components") or {}
                for i,v in pairs(data) do
                    if(v == "Drzwi otworzone")then
                        doors=true
                        break
                    end
                end

                if(not doors and sx > 0.1)then
                    sx=0.1
                end

                ui.volume=sx

                local music=getElementData(ui.vehicle, "vehicle:stereo_music")
                if(music)then
                    music.volume=ui.volume
                    setElementData(ui.vehicle, "vehicle:stereo_music", music)
                end
            end
        end
    end

    dxDrawImage(sw/2-748/2/zoom+(748-352)/2/zoom-25/zoom-6/zoom, sh/2-292/2/zoom+292/zoom-20/zoom-(32-20)/2/zoom, 25/zoom, 20/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))

    onClick(sw/2-748/2/zoom+(748-147)/2/zoom, sh/2-292/2/zoom+200/zoom, 147/zoom, 38/zoom, function()
        local music=getElementData(ui.vehicle, "vehicle:stereo_music")
        if(music)then
            if(SPAM.getSpam())then return end

            setElementData(ui.vehicle, "vehicle:stereo_music", false)

            buttons:destroyButton(ui.btns[1])
            ui.btns[1]=buttons:createButton(sw/2-748/2/zoom+(748-147)/2/zoom, sh/2-292/2/zoom+200/zoom, 147/zoom, 38/zoom, "GRAJ", 255, 9, false, false, ":px_audio_vehs/textures/play-button.png")
        else
            if(SPAM.getSpam())then return end

            local url=editbox:dxGetEditText(ui.edits[1]) or {}
            if(url and #url > 0)then
                local find,stop=string.find(url,'https://www.youtube.com/watch?v=',1,true)
                if(find)then
                    url=string.sub(url,stop+1,#url)
                    url='https://ytapi.pixelmta.pl/ytdl/'..url
                end

                setElementData(ui.vehicle, "vehicle:stereo_music", {
                    url=url,
                    volume=ui.volume
                })

                buttons:destroyButton(ui.btns[1])
                ui.btns[1]=buttons:createButton(sw/2-748/2/zoom+(748-147)/2/zoom, sh/2-292/2/zoom+200/zoom, 147/zoom, 38/zoom, "STOP", 255, 9, false, false, ":px_audio_vehs/textures/play-button.png", {105,48,48})
            
                ui.destroy()
            end
        end
    end)

    onClick(sw/2-748/2/zoom+748/zoom-22/zoom-(55-10)/2/zoom, sh/2-292/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, function()
        ui.destroy()
    end)
end

ui.create=function(vehicle)
    if(ui.animate or not vehicle or (vehicle and not isElement(vehicle)))then return end

    blur=exports.blur
    buttons=exports.px_buttons
    editbox=exports.px_editbox

    ui.vehicle=vehicle
    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)
    showCursor(true)

    local music=getElementData(ui.vehicle, "vehicle:stereo_music")
    if(music)then
        ui.btns[1]=buttons:createButton(sw/2-748/2/zoom+(748-147)/2/zoom, sh/2-292/2/zoom+200/zoom, 147/zoom, 38/zoom, "STOP", 255, 9, false, false, ":px_audio_vehs/textures/play-button.png", {105,48,48})
    else
        ui.btns[1]=buttons:createButton(sw/2-748/2/zoom+(748-147)/2/zoom, sh/2-292/2/zoom+200/zoom, 147/zoom, 38/zoom, "GRAJ", 255, 9, false, false, ":px_audio_vehs/textures/play-button.png")
    end

    ui.edits[1] = editbox:dxCreateEdit("Wklej URL do piosenki lub stacji radiowej", sw/2-748/2/zoom+(748-394)/2/zoom, sh/2-292/2/zoom+131/zoom, 394/zoom, 35/zoom, false, 11/zoom, 255, false, false)
end

ui.destroy=function()
    if(ui.animate)then return end

    showCursor(false)

    assets.destroy()

    removeEventHandler("onClientRender", root, ui.onRender)

    ui.animate=false

    editbox:dxDestroyEdit(ui.edits[1])
    buttons:destroyButton(ui.btns[1])
end

-- triggers

function action(id,veh,name)
    if(getVehicleName(veh) == "Pony" and name == "Stereo")then
        local data=getElementData(veh, "vehicle:components") or {}
        for i,v in pairs(data) do
            if(string.find(v,"Głośniki"))then
                ui.create(veh)
                break
            end
        end
    end
end

-- sound system

ui.musics={}

ui.createMusic=function(element, data)
    if(ui.musics[element])then 
        setSoundVolume(ui.musics[element], data.volume)
    else
        ui.destroyMusic(element)

        ui.musics[element]=playSound3D(data.url, 0, 0, 0, true)
        attachElements(ui.musics[element], element)
        setSoundVolume(ui.musics[element], data.volume)
        setSoundMaxDistance(ui.musics[element],150)

        local data=getElementData(element, "vehicle:components") or {}
        for i,v in pairs(data) do
            if(v == "Drzwi zamknięte")then
                setSoundEffectEnabled(ui.musics[element], "reverb", true)
                break
            end
        end
    end
end

ui.destroyMusic=function(element)
    if(ui.musics[element])then
        if(isElement(ui.musics[element]))then
            destroyElement(ui.musics[element])
        end
        ui.musics[element]=nil
    end
end

addEventHandler("onClientElementDataChange", root, function(data, old, new)
    if(data == "vehicle:stereo_music")then
        if(new)then
            ui.createMusic(source, new)
        else
            ui.destroyMusic(source)
        end
    end
end)

addEventHandler("onClientElementStreamIn", root, function()
    local data=getElementData(source, "vehicle:stereo_music")
    if(data)then
        ui.createMusic(source, data)
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    ui.destroyMusic(source)
end)

addEventHandler("onClientElementDestroy", root, function()
    ui.destroyMusic(source)
end)

addEventHandler("onClientVehicleEnter", root, function(player, seat)
    if(seat == 0)then
        ui.destroyMusic(source)
    end
end)

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