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
local zoom = 1920/sw

local progress=0
local lastTick=getTickCount()
local pojazdfix=false
local tickCancel=getTickCount()
local timer=false

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 15},
    },

    textures={},
    textures_paths={
        "assets/images/car.png",
        "assets/images/progress.png",

        "assets/images/icon.png",
        "assets/images/icon_hover.png",
    },
}

--

function draw()
    local speed = 500

    -- mouse
    if(getKeyState("mouse1"))then
        dxDrawImage(sw - 380/zoom, sh/2-441/2/zoom+300/zoom, 67/zoom, 73/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, alpha))
    else
        dxDrawImage(sw - 380/zoom, sh/2-441/2/zoom+300/zoom, 67/zoom, 73/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, alpha))
    end

    dxDrawImage(sw-300/zoom, sh/2-441/2/zoom, 228/zoom, 441/zoom, assets.textures[1])
    dxDrawImageSection(sw-300/zoom, sh/2-441/2/zoom+441/zoom, 228/zoom, -(progress/100)*441/zoom, 0, 0, 228, -(progress/100)*441, "assets/images/progress.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)

    dxDrawText("Klawiszologia:\nLPM - podnoś pojazd", sw - 120/zoom+1, sh-320/zoom+1, 63/zoom+sw - 140/zoom+1, 112/zoom+sh-280/zoom+30/zoom+1, tocolor(0,0,0, alpha), 1, assets.fonts[1], "right", "top", false)
    dxDrawText("Klawiszologia:\nLPM - podnoś pojazd", sw - 120/zoom, sh-320/zoom, 63/zoom+sw - 140/zoom, 112/zoom+sh-280/zoom+30/zoom, tocolor(198,197,199, alpha), 1, assets.fonts[1], "right", "top", false)

    dxDrawText("Pozostały czas:\n"..math.floor(20-(getTickCount()-tickCancel)/1000).." sekund", sw - 120/zoom+1, 250/zoom+1, 63/zoom+sw - 140/zoom+1, 112/zoom+sh-280/zoom+30/zoom+1, tocolor(0,0,0, alpha), 1, assets.fonts[1], "right", "top", false)
    dxDrawText("Pozostały czas:\n"..math.floor(20-(getTickCount()-tickCancel)/1000).." sekund", sw - 120/zoom, 250/zoom, 63/zoom+sw - 140/zoom, 112/zoom+sh-280/zoom+30/zoom, tocolor(198,197,199, alpha), 1, assets.fonts[1], "right", "top", false)

    if((getTickCount()-lastTick) > 250 and progress > 0)then
        progress=progress-1
        lastTick = getTickCount()
    end

    if(progress == 100)then
        koniec()
    end

    if((getTickCount()-tickCancel) > 20000)then
        if(SPAM.getSpam())then return end

        showCursor(false)
        removeEventHandler("onClientRender",root,draw)
        triggerServerEvent("client->cancel",resourceRoot)
        assets.destroy()
    end
end

function addProgress()
    if progress < 100 then
        progress=progress+1.5
        lastTick = getTickCount()
    end
end
bindKey("mouse1","down",addProgress)


addEvent("client>obroc_pojazd",true)
addEventHandler("client>obroc_pojazd",resourceRoot,function(pojazd)
    progress=0
    pojazdfix = pojazd
    tickCancel=getTickCount()

    showCursor(true)
    addEventHandler("onClientRender",root,draw)
    assets.create()

    exports.px_noti:noti("Rozpoczęto obracanie pojazdu. Masz 15 sekund aby zapełnić pasek.")

    setElementFrozen(localPlayer, true)
end)

function akceptuj()
    if(SPAM.getSpam())then return end

    triggerServerEvent("client->akceptuj", resourceRoot,pojazdFix)

    unbindKey("X", "down", anuluj)
    unbindKey("K", "down", akceptuj)

    if(timer and isTimer(timer))then
        killTimer(timer)
        timer=false
    end
end

function anuluj()
    if(SPAM.getSpam())then return end

    triggerServerEvent("client->anuluj", resourceRoot)

    unbindKey("X", "down", anuluj)
    unbindKey("K", "down", akceptuj)

    if(timer and isTimer(timer))then
        killTimer(timer)
        timer=false
    end
end

addEvent("client>oferta",true)
addEventHandler("client>oferta",resourceRoot,function(pojazd, pomocnik)
    bindKey("X", "down", anuluj)
    bindKey("K", "down", akceptuj)

    exports.px_noti:noti("Otrzymałeś prośbę o pomoc w obróceniu pojazdu. Kliknij K aby akceptować lub X aby anulować.")

    pojazdFix=pojazd

    timer=setTimer(function()
        exports.px_noti:noti("Prośba o pomoc została przedawiona.")

        triggerServerEvent("client->anuluj", resourceRoot)

        unbindKey("X", "down", anuluj)
        unbindKey("K", "down", akceptuj)
    end, 15000, 1)
end)

function koniec()
    if(SPAM.getSpam())then return end

    showCursor(false)
    removeEventHandler("onClientRender",root,draw)
    triggerServerEvent("server>obroc_pojazd",resourceRoot,pojazdfix)
    assets.destroy()
end


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

-- useful

function dxDrawLinedRectangle( x, y, width, height, color, _width, postGUI )
	_width = _width or 1
	dxDrawLine ( x, y, x+width, y, color, _width, postGUI ) -- Top
	dxDrawLine ( x, y, x, y+height, color, _width, postGUI ) -- Left
	dxDrawLine ( x, y+height, x+width, y+height, color, _width, postGUI ) -- Bottom
	return dxDrawLine ( x+width, y, x+width, y+height, color, _width, postGUI ) -- Right
end