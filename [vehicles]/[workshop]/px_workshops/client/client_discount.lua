--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- exports

local buttons=exports.px_buttons
local noti=exports.px_noti
local blur=exports.blur
local avatars=exports.px_avatars

local UI={}

-- assets

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 17},
        {":px_assets/fonts/Font-Regular.ttf", 11},
        {":px_assets/fonts/Font-Regular.ttf", 13},
    },

    textures={},
    textures_paths={
        "assets/images/window.png",

        "assets/images/checkbox.png",
        "assets/images/checkbox_selected.png",

        "assets/images/rabat_bg.png",
        "assets/images/rabat_circle.png",
    },
}

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

-- render

UI.animate=false
UI.mainAlpha=0
UI.player=localPlayer
UI.btns={}
UI.alpha=0
UI.checkbox=1
UI.scroll=0
UI.scrollNumber=0
UI.scriptName=""
UI.vehicle=false

UI.onRender=function()
    if(UI.player and isElement(UI.player))then
        blur:dxDrawBlur(sw/2-493/2/zoom, sh/2-230/2/zoom, 493/zoom, 230/zoom, tocolor(255, 255, 255, UI.alpha))
        dxDrawImage(sw/2-493/2/zoom, sh/2-230/2/zoom, 493/zoom, 230/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
        dxDrawText("Potwierdzenie oferty", sw/2-493/2/zoom, sh/2-230/2/zoom, 493/zoom+sw/2-493/2/zoom, sh/2-230/2/zoom+55/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[1], "center", "center")
        dxDrawRectangle(sw/2-458/2/zoom, sh/2-230/2/zoom+55/zoom, 458/zoom, 1, tocolor(85, 85, 85, UI.alpha))

        dxDrawText("Czy na pewno chcesz wysłać ofertę?", sw/2-493/2/zoom, sh/2-230/2/zoom+67/zoom, 493/zoom+sw/2-493/2/zoom, 230/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[3], "center", "top")

        local tex=avatars:getPlayerAvatar(UI.player)
        local w=dxGetTextWidth(getPlayerName(UI.player), 1, assets.fonts[3])
        dxDrawImage(sw/2-21/zoom-w/2-11/zoom, sh/2-230/2/zoom+95/zoom, 21/zoom, 21/zoom, tex, 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
        dxDrawText(getPlayerName(UI.player), sw/2-w/2, sh/2-230/2/zoom+95/zoom, 493/zoom+sw/2-493/2/zoom, sh/2-230/2/zoom+95/zoom+21/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[3], "left", "center")

        -- rabat
        local w=dxGetTextWidth("Rabat dla klienta", 1, assets.fonts[3])
        dxDrawImage(sw/2-30/zoom-w/2-13/zoom, sh/2-230/2/zoom+185/zoom-5/zoom, 42/zoom, 42/zoom, assets.textures[UI.checkbox+1], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
        dxDrawText("Rabat dla klienta", sw/2-w/2, sh/2-230/2/zoom+185/zoom-5/zoom, 493/zoom+sw/2-493/2/zoom, sh/2-230/2/zoom+185/zoom-5/zoom+42/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[3], "left", "center")
        onClick(sw/2-30/zoom-w/2-13/zoom, sh/2-230/2/zoom+185/zoom-5/zoom, 42/zoom, 42/zoom, function()
            UI.checkbox=UI.checkbox == 1 and 2 or 1
        end)

        onClick(sw/2+10/zoom, sh/2+90/zoom, 148/zoom, 39/zoom, function()
            UI.toggleUI(false)
        end)

        if(UI.checkbox == 2)then
            local pos=sw/2-254/2/zoom
            local w=254/zoom

            blur:dxDrawBlur(sw/2-493/2/zoom, sh/2-230/2/zoom+230/zoom+11/zoom, 493/zoom, 91/zoom, tocolor(255, 255, 255, UI.alpha))
            dxDrawImage(sw/2-493/2/zoom, sh/2-230/2/zoom+230/zoom+11/zoom, 493/zoom, 91/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))

            dxDrawText("Rabat przyznajesz z swojej wypłaty.", sw/2-493/2/zoom, sh/2-230/2/zoom+230/zoom+11/zoom+14/zoom, 493/zoom+sw/2-493/2/zoom, 230/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[3], "center", "top")
        
            dxDrawText("0%", pos-30/zoom, sh/2-230/2/zoom+230/zoom+11/zoom+45/zoom, 254/zoom, sh/2-230/2/zoom+230/zoom+11/zoom+45/zoom+14/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[2], "left", "center")
            dxDrawText("100%", 0, sh/2-230/2/zoom+230/zoom+11/zoom+45/zoom, pos+44/zoom+254/zoom, sh/2-230/2/zoom+230/zoom+11/zoom+45/zoom+14/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[2], "right", "center")

            dxDrawImage(pos, sh/2-230/2/zoom+230/zoom+11/zoom+45/zoom, 254/zoom, 14/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
            dxDrawImage(pos+w*UI.scroll, sh/2-230/2/zoom+230/zoom+11/zoom+45/zoom, 14/zoom, 14/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
            dxDrawText(string.format("%.0f", UI.scrollNumber).."%", pos+w*UI.scroll, sh/2-230/2/zoom+230/zoom+11/zoom+45/zoom+50/zoom, 254/zoom, sh/2-230/2/zoom+230/zoom+11/zoom+45/zoom+14/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[2], "left", "center")

            if(isMouseInPosition(pos, sh/2-230/2/zoom+230/zoom+11/zoom+45/zoom, w, 14/zoom) and getKeyState("mouse1"))then
                local sx,sy=getCursorPosition() or 0,0
                sx,sy=sx*sw,sy*sh
                sx=sx-pos
                UI.scrollNumber=100*(sx/w)
                sx=sx-14/2/zoom
                UI.scroll=1*(sx/w)
            end
        else
            UI.scrollNumber=0
            UI.scroll=0
        end

        onClick(sw/2-148/zoom-10/zoom, sh/2-230/2/zoom+130/zoom, 148/zoom, 39/zoom, function()
            local rabat=string.format("%.0f", UI.scrollNumber) or 0
            rabat=tonumber(rabat)
            rabat=rabat < 0 and 0 or rabat
            rabat=rabat > 100 and 100 or rabat

            for i,v in pairs(getElementsByType("colshape", resourceRoot, true)) do
                if(isElementWithinColShape(UI.vehicle, v))then
                    exports[UI.scriptName]:sendOffer(UI.player, UI.vehicle, rabat)
                    exports.px_noti:noti("Pomyślnie wysłano oferte do gracza "..getPlayerName(UI.player)..".", "success")
                    break
                end
            end

            UI.toggleUI(false)
        end)

        onClick(sw/2+10/zoom, sh/2-230/2/zoom+130/zoom, 148/zoom, 39/zoom, function()
            UI.toggleUI(false)
        end)
    else
        UI.toggleUI(false)
    end
end

UI.toggleUI=function(state, scriptName, player, vehicle)
    if(state and not getElementData(localPlayer, "user:gui_showed"))then
        buttons=exports.px_buttons
        noti=exports.px_noti
        blur=exports.blur
        avatars=exports.px_avatars

        assets.create()

        addEventHandler("onClientRender", root, UI.onRender)

        showCursor(true)

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

        UI.btns[1]=buttons:createButton(sw/2-148/zoom-10/zoom, sh/2-230/2/zoom+130/zoom, 148/zoom, 39/zoom, "WYŚLIJ", 0, 10/zoom, false, false, ":px_mechanic_duty/assets/images/button_start.png")
        UI.btns[2]=buttons:createButton(sw/2+10/zoom, sh/2-230/2/zoom+130/zoom, 148/zoom, 39/zoom, "ANULUJ", 0, 10/zoom, false, false, ":px_mechanic_duty/assets/images/button_close.png", {132,39,39})

        animate(UI.alpha, 255, "Linear", 200, function(a)
            UI.alpha=a

            buttons:buttonSetAlpha(UI.btns[1], a)
            buttons:buttonSetAlpha(UI.btns[2], a)
        end)

        UI.scriptName=scriptName
        UI.player=player
        UI.vehicle=vehicle
        UI.checkbox=1
        UI.scrollNumber=0
        UI.scroll=0
    else
        showCursor(false)

        animate(UI.alpha, 0, "Linear", 200, function(a)
            UI.alpha=a

            buttons:buttonSetAlpha(UI.btns[1], a)
            buttons:buttonSetAlpha(UI.btns[2], a)
        end, function()
            removeEventHandler("onClientRender", root, UI.onRender)

            buttons:destroyButton(UI.btns[1])
            buttons:destroyButton(UI.btns[2])

            assets.destroy()
        end)

        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end

function openDiscountUI(...)
    UI.toggleUI(true, ...)
end

-- offers

function sendOffer(player, vehicle, mechanic, type)
    if(type == "px_workshop_sprays")then
        for i,v in pairs(getElementsByType("colshape", resourceRoot, true)) do
            if(isElementWithinColShape(vehicle, v))then
                exports[type]:sendOffer(player, vehicle, mechanic)
                exports.px_noti:noti("Pomyślnie wysłano oferte do gracza "..getPlayerName(player)..".", "success")
                break
            end
        end
    else
        UI.toggleUI(true, type, player, vehicle)
    end
end