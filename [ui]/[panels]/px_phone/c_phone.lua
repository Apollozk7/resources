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
local noti=exports.px_noti
local avatars=exports.px_avatars

-- assets

function table.size(tbl)
    local x=0
    for i,v in pairs(tbl) do
        x=x+1
    end
    return x
end

local assets={}
assets.list={
    texs={
        "textures/phone.png",
        "textures/phone2.png",

        "textures/phone_icon.png",

        "textures/row.png",

        "textures/cancel.png",
        "textures/accept.png",

        "textures/circle.png",

        -- zakladki
        "textures/fire.png",
        "textures/kontakty.png",
        "textures/sms.png"
    },

    fonts={
        {"Medium", 9},
        {"Regular", 9},
        {"Regular", 13},
        {"Bold", 15},
        {"Medium", 15},
        {"Regular", 14},
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

-- functions

ui.defPos={sw-312/zoom-40/zoom,sh-650/zoom}
ui.pos={ui.defPos[1],sh}
ui.players={}
ui.row=0

ui.alpha=0
ui.mainAlpha=0
ui.centerAlpha=0
ui.connect=false

ui.sms={}

ui.sounds={
    dzwonek=false,
    calloff=false,
}

ui.apps={
    {name="Kontakty", icon=9, draw=function()
        local x,y=unpack(ui.pos)

        dxDrawText("< Wróć", x+40/zoom, y+70/zoom, x, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "top")
        onClick(x+40/zoom, y+70/zoom, dxGetTextWidth("< Wróć", 1, assets.fonts[2]), 15/zoom, function()
            if(ui.animate)then return end

            ui.animate=true
            animate(ui.centerAlpha, 0, "Linear", 250, function(a)
                ui.centerAlpha=a
            end, function()
                ui.selectedApp=false

                removeEventHandler("onClientKey", root, ui.onKey)

                animate(ui.mainAlpha, 255, "Linear", 250, function(a)
                    ui.mainAlpha=a
                end, function()
                    ui.animate=false
                end)
            end)
        end)

        dxDrawImage(x+(312-76)/2/zoom, y+60/zoom, 76/zoom, 76/zoom, assets.textures[9], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
        dxDrawText("Kontakty", x+(312-76)/2/zoom, y+60/zoom, 76/zoom+x+(312-76)/2/zoom, y+60/zoom+85/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "center", "bottom")

        if(ui.row < 1)then
            ui.row=1
        elseif(ui.row > table.size(ui.players)-7)then
            ui.row=table.size(ui.players)-7
        end

        local xx=0
        local k=0 
        for i,v in pairs(ui.players) do
            xx=xx+1
            if(xx >= ui.row and xx <= (ui.row+7))then
                k=k+1

                local sY=(49/zoom)*(k-1)

                v.hoverAlpha=v.hoverAlpha or 0

                if(isMouseInPosition(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom) and not v.animate and v.hoverAlpha < 100)then
                    v.animate=true
                    animate(0, 255, "Linear", 250, function(a)
                        v.hoverAlpha=a
                    end, function()
                        v.animate=false
                    end)
                elseif(v.hoverAlpha and not isMouseInPosition(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom) and not v.animate and v.hoverAlpha > 0)then
                    v.animate=true
                    animate(255, 0, "Linear", 250, function(a)
                        v.hoverAlpha=a
                    end, function()
                        v.animate=false
                    end)
                end

                dxDrawImage(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))

                dxDrawRectangle(x+(312-271)/2/zoom, y+170/zoom+sY+46/zoom, 271/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
                dxDrawRectangle(x+(312-271)/2/zoom, y+170/zoom+sY+46/zoom, 271/zoom, 1, tocolor(67, 178, 127, v.hoverAlpha))

                local target=getPlayerFromName(v.login)
                local login=(target and isElement(target)) and getPlayerMaskName(target) or v.login

                local avatar=avatars:getPlayerAvatar(login)
                dxDrawImage(x+(312-275)/2/zoom+18/zoom, y+170/zoom+sY+(47-21)/2/zoom, 21/zoom, 21/zoom, avatar, 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
                dxDrawText(login, x+(312-275)/2/zoom+18/zoom+30/zoom, y+170/zoom+sY, 275/zoom, 47/zoom+y+170/zoom+sY, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[3], "left", "center")

                dxDrawImage(x+(312-275)/2/zoom+230/zoom, y+170/zoom+sY, 47/zoom, 47/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
                onClick(x+(312-275)/2/zoom+230/zoom, y+170/zoom+sY, 47/zoom, 47/zoom, function()
                    if(SPAM.getSpam())then return end

                    local player=getPlayerFromName(v.login)
                    if(player)then
                        v.connected=false
                        v.coming=false
                        v.tick=getTickCount()
                        ui.connect=v

                        triggerServerEvent("get.call", resourceRoot, player)

                        ui.sounds.signal=playSound("sounds/signal.mp3", true)
                    else
                        noti:noti("Podany gracz nie znajduje się na serwerze.", "error")
                    end
                end)
            end
        end
    end,

    create=function()
        removeEventHandler("onClientKey", root, ui.onKey)
        addEventHandler("onClientKey", root, ui.onKey)
    end,

    },

    {name="Wiadomości", icon=10, draw=function()
        local x,y=unpack(ui.pos)
        if(ui.getSMS)then
            local v=ui.getSMS

            dxDrawText("< Wróć", x+40/zoom, y+70/zoom, x, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "top")
            onClick(x+40/zoom, y+70/zoom, dxGetTextWidth("< Wróć", 1, assets.fonts[2]), 15/zoom, function()
                if(ui.animate)then return end

                ui.animate=true
                animate(ui.centerAlpha, 0, "Linear", 250, function(a)
                    ui.centerAlpha=a
                end, function()
                    ui.getSMS=false
        
                    animate(ui.centerAlpha, 255, "Linear", 250, function(a)
                        ui.centerAlpha=a
                    end, function()
                        ui.animate=false
                    end)
                end)
            end)

            dxDrawText("Od: "..v.from, x+40/zoom, y+100/zoom, x, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[2], "left", "top")
            dxDrawText("Temat: "..v.desc, x+40/zoom, y+120/zoom, x, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[3], "left", "top")

            dxDrawText(v.text, x+40/zoom, y+160/zoom, x+40/zoom+230/zoom, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "top", false, true)
        else
            dxDrawText("< Wróć", x+40/zoom, y+70/zoom, x, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "top")
            onClick(x+40/zoom, y+70/zoom, dxGetTextWidth("< Wróć", 1, assets.fonts[2]), 15/zoom, function()
                if(ui.animate)then return end

                ui.animate=true
                animate(ui.centerAlpha, 0, "Linear", 250, function(a)
                    ui.centerAlpha=a
                end, function()
                    ui.selectedApp=false

                    removeEventHandler("onClientKey", root, ui.onKey)

                    animate(ui.mainAlpha, 255, "Linear", 250, function(a)
                        ui.mainAlpha=a
                    end, function()
                        ui.animate=false
                    end)
                end)
            end)

            dxDrawImage(x+(312-76)/2/zoom, y+60/zoom, 76/zoom, 76/zoom, assets.textures[10], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
            dxDrawText("Wiadomości", x+(312-76)/2/zoom, y+60/zoom, 76/zoom+x+(312-76)/2/zoom, y+60/zoom+85/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "center", "bottom")

            if(ui.row < 1)then
                ui.row=1
            elseif(ui.row > table.size(ui.sms)-7)then
                ui.row=table.size(ui.sms)-7
            end

            local xx=0
            local k=0 
            for i,v in pairs(ui.sms) do
                xx=xx+1
                if(xx >= ui.row and xx <= (ui.row+7))then
                    k=k+1

                    local sY=(49/zoom)*(k-1)

                    v.hoverAlpha=v.hoverAlpha or 0

                    if(isMouseInPosition(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom) and not v.animate and v.hoverAlpha < 100)then
                        v.animate=true
                        animate(0, 255, "Linear", 250, function(a)
                            v.hoverAlpha=a
                        end, function()
                            v.animate=false
                        end)
                    elseif(v.hoverAlpha and not isMouseInPosition(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom) and not v.animate and v.hoverAlpha > 0)then
                        v.animate=true
                        animate(255, 0, "Linear", 250, function(a)
                            v.hoverAlpha=a
                        end, function()
                            v.animate=false
                        end)
                    end

                    dxDrawImage(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))

                    dxDrawRectangle(x+(312-271)/2/zoom, y+170/zoom+sY+46/zoom, 271/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
                    dxDrawRectangle(x+(312-271)/2/zoom, y+170/zoom+sY+46/zoom, 271/zoom, 1, tocolor(67, 178, 127, v.hoverAlpha))

                    dxDrawText(v.from, x+(312-275)/2/zoom+18/zoom, y+170/zoom+sY-25/zoom, 275/zoom, 47/zoom+y+170/zoom+sY, tocolor(100, 100, 100, ui.centerAlpha), 1, assets.fonts[1], "left", "center")
                    dxDrawText(v.desc, x+(312-275)/2/zoom+18/zoom, y+170/zoom+sY+15/zoom, 275/zoom, 47/zoom+y+170/zoom+sY, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[3], "left", "center")

                    onClick(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom, function()
                        if(ui.animate)then return end

                        ui.animate=true
                        animate(ui.centerAlpha, 0, "Linear", 250, function(a)
                            ui.centerAlpha=a
                        end, function()
                            ui.getSMS=v
                
                            animate(ui.centerAlpha, 255, "Linear", 250, function(a)
                                ui.centerAlpha=a
                            end, function()
                                ui.animate=false
                            end)
                        end)
                    end)
                end
            end
        end
    end,

    create=function()
        removeEventHandler("onClientKey", root, ui.onKey)
        addEventHandler("onClientKey", root, ui.onKey)
    end,

    },

    {name="Służby", icon=8, draw=function(uis)
        local x,y=unpack(ui.pos)

        dxDrawText("< Wróć", x+40/zoom, y+70/zoom, x, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "top")
        onClick(x+40/zoom, y+70/zoom, dxGetTextWidth("< Wróć", 1, assets.fonts[2]), 15/zoom, function()
            if(ui.animate)then return end

            ui.animate=true
            animate(ui.centerAlpha, 0, "Linear", 250, function(a)
                ui.centerAlpha=a
            end, function()
                ui.selectedApp=false

                animate(ui.mainAlpha, 255, "Linear", 250, function(a)
                    ui.mainAlpha=a
                end, function()
                    ui.animate=false
                end)
            end)
        end)

        dxDrawImage(x+(312-76)/2/zoom, y+60/zoom, 76/zoom, 76/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
        dxDrawText("Służby", x+(312-76)/2/zoom, y+60/zoom, 76/zoom+x+(312-76)/2/zoom, y+60/zoom+85/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "center", "bottom")

        local factions=uis.factions
        for i,v in pairs(factions) do
            local sY=(49/zoom)*(i-1)

            v.hoverAlpha=v.hoverAlpha or 0

            if(isMouseInPosition(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom) and not v.animate and v.hoverAlpha < 100)then
                v.animate=true
                animate(0, 255, "Linear", 250, function(a)
                    v.hoverAlpha=a
                end, function()
                    v.animate=false
                end)
            elseif(v.hoverAlpha and not isMouseInPosition(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom) and not v.animate and v.hoverAlpha > 0)then
                v.animate=true
                animate(255, 0, "Linear", 250, function(a)
                    v.hoverAlpha=a
                end, function()
                    v.animate=false
                end)
            end

            dxDrawImage(x+(312-275)/2/zoom, y+170/zoom+sY, 275/zoom, 47/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))

            dxDrawRectangle(x+(312-271)/2/zoom, y+170/zoom+sY+46/zoom, 271/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
            dxDrawRectangle(x+(312-271)/2/zoom, y+170/zoom+sY+46/zoom, 271/zoom, 1, tocolor(67, 178, 127, v.hoverAlpha))

            dxDrawText(v[1], x+(312-275)/2/zoom+18/zoom, y+170/zoom+sY, 275/zoom, 47/zoom+y+170/zoom+sY, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[3], "left", "center")

            dxDrawImage(x+(312-275)/2/zoom+230/zoom, y+170/zoom+sY, 47/zoom, 47/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))

            onClick(x+(312-275)/2/zoom+230/zoom, y+170/zoom+sY, 47/zoom, 47/zoom, function()
                if(getElementData(localPlayer, "phoneData"))then return end

                if(getElementDimension(localPlayer) == 0 and getElementInterior(localPlayer) == 0)then
                    ui.destroy()

                    noti:noti("Wprowadź treść zgłoszenia na czacie.", "info")

                    setElementData(localPlayer, "phoneData", v[1])
                else
                    exports.px_noti:noti("Nie możesz wysłać zgłoszenia będąc w interiorze.", "error")
                end
            end)
        end
    end,

    factions={
        {"SAPD"},
        {"SACC"},
        --{"SARA"},
        --{"PSP"}
    }

    },
}

ui.selectedApp=false

ui.onRender=function()
    local hour,minute=getTime()
    local x,y=unpack(ui.pos)

    dxDrawImage(x, y, 312/zoom, 629/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

    if(ui.connect)then
        local v=ui.connect
        
        if(v.coming)then
            local target=getPlayerFromName(v.login)
            local login=(target and isElement(target)) and getPlayerMaskName(target) or v.login

            dxDrawText(login, x, y+70/zoom, x+312/zoom, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[4], "center", "top")

            local player=getPlayerFromName(v.login)
            if(player)then
                local avatar=avatars:getPlayerAvatar(player)
                dxDrawImage(x+(312-112)/2/zoom, y+105/zoom, 112/zoom, 112/zoom, avatar, 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
            end

            dxDrawText("Połączenie", x, y+240/zoom, x+312/zoom, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[5], "center", "top")

            dxDrawImage(x+(312-52)/2/zoom-52/2/zoom-5/zoom, y+350/zoom, 52/zoom, 52/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
            dxDrawImage(x+(312-52)/2/zoom+52/2/zoom+5/zoom, y+350/zoom, 52/zoom, 52/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))

            onClick(x+(312-52)/2/zoom-52/2/zoom-5/zoom, y+350/zoom, 52/zoom, 52/zoom, function()
                if(SPAM.getSpam())then return end

                ui.connect=false

                triggerServerEvent("cancel.call", resourceRoot, v.coming, "sound")

                if(ui.sounds.dzwonek and isElement(ui.sounds.dzwonek))then
                    destroyElement(ui.sounds.dzwonek)
                    ui.sounds.dzwonek=false
                end

                ui.selectedApp=false
                ui.centerAlpha=0
                ui.mainAlpha=255
                ui.alpha=255

                if(ui.sounds.signal and isElement(ui.sounds.signal))then
                    destroyElement(ui.sounds.signal)
                    ui.sounds.signal=false
                end
            end)

            onClick(x+(312-52)/2/zoom+52/2/zoom+5/zoom, y+350/zoom, 52/zoom, 52/zoom, function()
                if(SPAM.getSpam())then return end

                v.playerCall=v.coming
                v.connected=getTickCount()

                triggerServerEvent("accept.call", resourceRoot, v.coming)

                v.coming=false

                if(ui.sounds.dzwonek and isElement(ui.sounds.dzwonek))then
                    destroyElement(ui.sounds.dzwonek)
                    ui.sounds.dzwonek=false
                end

                ui.selectedApp=false
                ui.centerAlpha=255
                ui.mainAlpha=0
                ui.alpha=255

                if(ui.sounds.signal and isElement(ui.sounds.signal))then
                    destroyElement(ui.sounds.signal)
                    ui.sounds.signal=false
                end
            end)
        elseif(v.connected)then
            local target=getPlayerFromName(v.login)
            local login=(target and isElement(target)) and getPlayerMaskName(target) or v.login

            dxDrawText(login, x, y+70/zoom, x+312/zoom, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[4], "center", "top")

            local player=getPlayerFromName(v.login)
            if(player)then
                local avatar=avatars:getPlayerAvatar(player)
                if(getElementData(v.playerCall, "voice:to_say"))then
                    local w=interpolateBetween(0, 0, 0, 10, 0, 0, (getTickCount()-v.connected)/500, "SineCurve")
                    w=w+112
                    dxDrawImage(x+(312-w)/2/zoom, y+105/zoom-(w-112)/2/zoom, w/zoom, w/zoom, assets.textures[9], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha > 100 and 100 or ui.centerAlpha))
                end
                dxDrawImage(x+(312-112)/2/zoom, y+105/zoom, 112/zoom, 112/zoom, avatar, 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
            end

            local time_1=(getTickCount()-v.connected)/1000
            local hours = math.floor(time_1/60)
            local minutes = math.floor(time_1-(hours*60))
            local time=(hours > 0 and hours.."m" or "").." "..(minutes > 0 and minutes.."s" or "0s")

            dxDrawText("Połączono", x, y+240/zoom, x+312/zoom, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[5], "center", "top")
            dxDrawText(time, x, y+265/zoom, x+312/zoom, 0, tocolor(100, 100, 100, ui.centerAlpha), 1, assets.fonts[6], "center", "top")

            dxDrawText(getElementData(localPlayer, "voice:to_say") and "Puść 'Z' aby przestać mówić" or "Przytrzymaj 'Z' aby mówić", x, y+300/zoom, x+312/zoom, 0, tocolor(100, 100, 100, ui.centerAlpha), 1, assets.fonts[6], "center", "top")

            dxDrawImage(x+(312-52)/2/zoom, y+350/zoom, 52/zoom, 52/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))

            onClick(x+(312-52)/2/zoom, y+350/zoom, 52/zoom, 52/zoom, function()
                if(SPAM.getSpam())then return end

                ui.connect=false

                triggerServerEvent("cancel.call", resourceRoot, v.playerCall)

                if(ui.sounds.dzwonek and isElement(ui.sounds.dzwonek))then
                    destroyElement(ui.sounds.dzwonek)
                    ui.sounds.dzwonek=false
                end

                ui.selectedApp=false
                ui.centerAlpha=0
                ui.mainAlpha=255
                ui.alpha=255

                if(ui.sounds.signal and isElement(ui.sounds.signal))then
                    destroyElement(ui.sounds.signal)
                    ui.sounds.signal=false
                end
            end)
        else
            if((getTickCount()-v.tick) > (15*1000))then -- 15 sekund
                if(SPAM.getSpam())then return end

                ui.sounds.calloff=playSound("sounds/zadzwonpozniej.mp3")

                ui.connect=false

                triggerServerEvent("cancel.call", resourceRoot, getPlayerFromName(v.login))

                if(ui.sounds.dzwonek and isElement(ui.sounds.dzwonek))then
                    destroyElement(ui.sounds.dzwonek)
                    ui.sounds.dzwonek=false
                end

                ui.selectedApp=false
                ui.centerAlpha=0
                ui.mainAlpha=255
                ui.alpha=255

                if(ui.sounds.signal and isElement(ui.sounds.signal))then
                    destroyElement(ui.sounds.signal)
                    ui.sounds.signal=false
                end
                return
            end

            local target=getPlayerFromName(v.login)
            local login=(target and isElement(target)) and getPlayerMaskName(target) or v.login

            dxDrawText(login, x, y+70/zoom, x+312/zoom, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[4], "center", "top")

            local player=getPlayerFromName(v.login)
            if(player)then
                local avatar=avatars:getPlayerAvatar(player)
                dxDrawImage(x+(312-112)/2/zoom, y+105/zoom, 112/zoom, 112/zoom, avatar, 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
            end

            dxDrawText("Trwa łączenie...", x, y+240/zoom, x+312/zoom, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[5], "center", "top")

            dxDrawImage(x+(312-52)/2/zoom, y+350/zoom, 52/zoom, 52/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))

            onClick(x+(312-52)/2/zoom, y+350/zoom, 52/zoom, 52/zoom, function()
                if(SPAM.getSpam())then return end

                ui.connect=false

                triggerServerEvent("cancel.call", resourceRoot, getPlayerFromName(v.login))

                if(ui.sounds.dzwonek and isElement(ui.sounds.dzwonek))then
                    destroyElement(ui.sounds.dzwonek)
                    ui.sounds.dzwonek=false
                end

                ui.selectedApp=false
                ui.centerAlpha=0
                ui.mainAlpha=255
                ui.alpha=255

                if(ui.sounds.signal and isElement(ui.sounds.signal))then
                    destroyElement(ui.sounds.signal)
                    ui.sounds.signal=false
                end
            end)
        end
    elseif(ui.selectedApp and ui.apps[ui.selectedApp])then
        dxDrawImage(x, y, 312/zoom, 629/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
    
        ui.apps[ui.selectedApp].draw(ui.apps[ui.selectedApp])
    else
        dxDrawImage(x, y, 312/zoom, 629/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))
    
        for i,v in pairs(ui.apps) do
            local sX=(76/zoom)*(i-1)
            dxDrawImage(x+sX+30/zoom, y+50/zoom, 76/zoom, 76/zoom, assets.textures[v.icon], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))
            dxDrawText(v.name, x+sX+30/zoom, y+50/zoom, 76/zoom+x+sX+30/zoom, 76/zoom+y+55/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[1], "center", "bottom")
    
            onClick(x+sX+30/zoom, y+50/zoom, 76/zoom, 76/zoom, function()
                if(ui.animate)then return end

                ui.animate=true
                animate(ui.mainAlpha, 0, "Linear", 250, function(a)
                    ui.mainAlpha=a
                end, function()
                    ui.selectedApp=i

                    if(ui.apps[ui.selectedApp].create)then
                        ui.apps[ui.selectedApp].create()
                    end
    
                    ui.centerAlpha=0
                    animate(ui.centerAlpha, 255, "Linear", 250, function(a)
                        ui.centerAlpha=a
                    end, function()
                        ui.animate=false
                    end)
                end)
            end)
        end
    end

    dxDrawText(string.format("%02d", hour)..":"..string.format("%02d", minute), x, y+25/zoom, x+110/zoom, 0, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[2], "center", "top")
end

ui.onKey=function(key,press)
    if(key and press)then
        if(key == "mouse_wheel_up")then
            ui.row=ui.row-1
        elseif(key == "mouse_wheel_down")then
            ui.row=ui.row+1
        end
    end
end

-- functions

ui.create=function()
    if(ui.animate)then return end
    if(ui.connect)then return end

    local gui=getElementData(localPlayer, "user:gui_showed")
    if(gui)then return end

    blur=exports.blur
    noti=exports.px_noti
    avatars=exports.px_avatars

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)
    showCursor(true)

    triggerServerEvent("get.friends", resourceRoot)
    triggerServerEvent("get.sms", resourceRoot)

    ui.selectedApp=false
    ui.row=0
    ui.centerAlpha=0
    ui.alpha=0
    ui.mainAlpha=0
    ui.toggle=true
    ui.connect=false
    ui.getSMS=false

    ui.animate=true
    animate(0, 255, "Linear", 250, function(a)
        ui.mainAlpha=a
        ui.alpha=a
    end, function()
        ui.animate=false
    end)

    animate(ui.pos[2], ui.defPos[2], "Linear", 250, function(v)
        ui.pos[2]=v
    end)

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
end

ui.destroy=function()
    if(ui.animate)then return end
    if(ui.connect)then return end

    showCursor(false)

    ui.animate=true
    animate(255, 0, "Linear", 250, function(a)
        ui.mainAlpha=a
        ui.centerAlpha=a
        ui.alpha=a
    end, function()
        assets.destroy()

        removeEventHandler("onClientRender", root, ui.onRender)
        removeEventHandler("onClientKey", root, ui.onKey)

        ui.animate=false
        ui.toggle=false

        setElementData(localPlayer, "user:gui_showed", false, false)
    end)

    animate(ui.pos[2], sh, "Linear", 250, function(v)
        ui.pos[2]=v
    end)
end

-- fnc

bindKey("f2", "down", function()
    if(not getElementData(localPlayer, "user:logged"))then return end
    
    if(ui.toggle)then
        ui.destroy()
    else
        ui.create()
    end
end)

-- triggers

addEvent("get.call", true)
addEventHandler("get.call", resourceRoot, function(player, info)
    if(player and isElement(player))then
        if(ui.connect or ui.coming)then return end
        
        info.coming=player

        if(not ui.toggle)then
            ui.create()
        end

        ui.centerAlpha=255
        ui.mainAlpha=0
        ui.alpha=255
        ui.connect=info

        ui.sounds.dzwonek=playSound("sounds/dzwonek.mp3", true)
    end
end)

addEvent("cancel.call", true)
addEventHandler("cancel.call", resourceRoot, function(player, sound, ended)
    if(sound)then
        ui.sounds.calloff=playSound("sounds/zadzwonpozniej.mp3")
    else
        ui.sounds.ended=playSound("sounds/end.mp3")
    end

    if(ui.sounds.signal and isElement(ui.sounds.signal))then
        destroyElement(ui.sounds.signal)
        ui.sounds.signal=false
    end

    ui.connect=false

    ui.selectedApp=false
    ui.centerAlpha=0
    ui.mainAlpha=255
    ui.alpha=255

    if(ui.sounds.dzwonek and isElement(ui.sounds.dzwonek))then
        destroyElement(ui.sounds.dzwonek)
        ui.sounds.dzwonek=false
    end
end)

addEvent("accept.call", true)
addEventHandler("accept.call", resourceRoot, function(player)
    if(ui.sounds.signal and isElement(ui.sounds.signal))then
        destroyElement(ui.sounds.signal)
        ui.sounds.signal=false
    end

    local v=ui.connect
    v.playerCall=player
    v.connected=getTickCount()
    v.coming=false

    ui.selectedApp=false
    ui.centerAlpha=255
    ui.mainAlpha=0
    ui.alpha=255

    if(ui.sounds.dzwonek and isElement(ui.sounds.dzwonek))then
        destroyElement(ui.sounds.dzwonek)
        ui.sounds.dzwonek=false
    end
end)

addEvent("load.friends", true)
addEventHandler("load.friends", resourceRoot, function(v)
    for i,v in pairs(v) do
        if(v.accept == 1 and v.login ~= getPlayerName(localPlayer))then
            ui.players[v.login]=v
        end
    end
end)

addEvent("load.sms", true)
addEventHandler("load.sms", resourceRoot, function(sms)
    ui.sms=sms
end)

-- useful

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)

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

function stripColors(text)
    local cnt=1
    while (cnt>0) do
      text,cnt=string.gsub(text,"#%x%x%x%x%x%x","")
    end
    return text
end

-- names

function getPlayerMaskName(player)
	return getElementData(player, "user:nameMask") or getPlayerName(player)
end