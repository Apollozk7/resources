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

-- main variables

local assets={
    fonts={},
    fonts2={},
    fonts_paths={
        {":px_assets/fonts/Font-Regular.ttf", 15},
        {":px_assets/fonts/Font-Regular.ttf", 11},
        {":px_assets/fonts/Font-Regular.ttf", 10},
        {":px_assets/fonts/Font-Regular.ttf", 14},
        {":px_assets/fonts/Font-Regular.ttf", 14},
        {":px_assets/fonts/Font-Regular.ttf", 13},
    },

    textures={},
    textures_paths={
        "textures/sell/window.png",
        "textures/sell/header_icon.png",
        "textures/sell/close.png",

        "textures/sell/vehs_icon.png",
        "textures/sell/players_icon.png",

        "textures/sell/row.png",

        "textures/sell/car_icon.png",

        "textures/sell/row.png",
        "textures/sell/color.png",
        "textures/sell/podpis.png",
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

local UI={}

UI.vehs={}
UI.scroll=false
UI.row=0
UI.edits={}
UI.btns={}
UI.alpha=0
UI.selectedVehicle=false
UI.vehInfo=false

UI.players={}

UI.selected_veh=false
UI.selected_player=false
UI.podpis=false
UI.podpisTarget=false

UI.prvX,UI.prvY=0,0

UI.onRender=function()
    blur:dxDrawBlur(sw/2-872/2/zoom, sh/2-629/2/zoom, 872/zoom, 629/zoom, tocolor(255,255,255,UI.alpha))
    dxDrawImage(sw/2-872/2/zoom, sh/2-629/2/zoom, 872/zoom, 629/zoom, assets.textures[1], 0, 0, 0, tocolor(255,255,255,UI.alpha))

    dxDrawText("Panel sprzedaży", sw/2-872/2/zoom, sh/2-629/2/zoom, sw/2-872/2/zoom+872/zoom, sh/2-629/2/zoom+54/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[1], "center", "center")
    dxDrawImage(sw/2-872/2/zoom+872/2/zoom+dxGetTextWidth("Panel sprzedaży", 1, assets.fonts[1])/2+10/zoom, sh/2-629/2/zoom+(54-19)/2/zoom, 19/zoom, 19/zoom, assets.textures[2], 0, 0, 0, tocolor(255,255,255,UI.alpha))

    dxDrawImage(sw/2-872/2/zoom+872/zoom-10/zoom-(54-10)/2/zoom, sh/2-629/2/zoom+(54-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255,255,255,UI.alpha))

    dxDrawRectangle(sw/2-870/2/zoom, sh/2-629/2/zoom+54/zoom, 870/zoom, 1, tocolor(86,86,86,UI.alpha))

    -- lewo
    dxDrawRectangle(sw/2-870/2/zoom+21/zoom, sh/2-629/2/zoom+54/zoom+23/zoom, 392/zoom, 1, tocolor(86,86,86,UI.alpha))
    dxDrawText("Twoje pojazdy", sw/2-870/2/zoom+21/zoom, sh/2-629/2/zoom+54/zoom, sw/2-870/2/zoom+21/zoom+392/zoom, sh/2-629/2/zoom+54/zoom+23/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[2], "center", "center")
    dxDrawImage(sw/2-870/2/zoom+21/zoom+(392/2/zoom)-dxGetTextWidth("Twoje pojazdy", 1, assets.fonts[2])/2-20/zoom, sh/2-629/2/zoom+54/zoom+(23-13)/2/zoom, 13/zoom, 13/zoom, assets.textures[4], 0, 0, 0, tocolor(255,255,255,UI.alpha))

    -- lista
    UI.row=math.floor(exports.px_scroll:dxScrollGetPosition(UI.scroll)+1)

    dxDrawText("ID", sw/2-870/2/zoom+21/zoom+42/zoom, sh/2-629/2/zoom+54/zoom+23/zoom+1/zoom, 0, 0, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[3], "left", "top")
    dxDrawText("Pojazd", sw/2-870/2/zoom+21/zoom+108/zoom, sh/2-629/2/zoom+54/zoom+23/zoom+1/zoom, 0, 0, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[3], "left", "top")
    dxDrawText("Przebieg", sw/2-870/2/zoom+21/zoom+278/zoom, sh/2-629/2/zoom+54/zoom+23/zoom+1/zoom, 0, 0, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[3], "left", "top")
    local x=0
    for i = UI.row,UI.row+7 do
        local v=UI.vehs[i]
        if(v)then
            x=x+1
            local sY=(59/zoom)*(x-1)
            
            dxDrawImage(sw/2-870/2/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY, 435/zoom, 57/zoom, assets.textures[6], 0, 0, 0, tocolor(255,255,255,UI.alpha))

            if(UI.selected_veh == v)then
                dxDrawRectangle(sw/2-870/2/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY+57/zoom-1, 435/zoom, 1, tocolor(33,147,176,UI.alpha))
            else
                dxDrawRectangle(sw/2-870/2/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY+57/zoom-1, 435/zoom, 1, tocolor(86,86,86,UI.alpha))
            end

            onClick(sw/2-870/2/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY, 435/zoom, 57/zoom, function()
                UI.selected_veh=v
            end)
            
            dxDrawImage(sw/2-870/2/zoom+21/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY+(57-12)/2/zoom, 26/zoom, 12/zoom, assets.textures[7], 0, 0, 0, tocolor(255,255,255,UI.alpha))
            dxDrawText(v.id, sw/2-870/2/zoom+21/zoom+42/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY, 0, sh/2-629/2/zoom+54/zoom+44/zoom+sY+57/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(getVehicleNameFromModel(v.model), sw/2-870/2/zoom+21/zoom+108/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY, 0, sh/2-629/2/zoom+54/zoom+44/zoom+sY+57/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "left", "center")
            dxDrawText(string.format("%.1f", v.distance).." #2193b0km", sw/2-870/2/zoom+21/zoom+278/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY, 0, sh/2-629/2/zoom+54/zoom+44/zoom+sY+57/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[4], "left", "center", false, false, false, true)
        end
    end

    -- prawo
    UI.row2=math.floor(exports.px_scroll:dxScrollGetPosition(UI.scroll2)+1)

    dxDrawRectangle(sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom, sh/2-629/2/zoom+54/zoom+23/zoom, 392/zoom, 1, tocolor(86,86,86,UI.alpha))
    dxDrawText("Gracze w pobliżu", sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom, sh/2-629/2/zoom+54/zoom, sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom+392/zoom, sh/2-629/2/zoom+54/zoom+23/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[2], "center", "center")
    dxDrawImage(sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom+(392/2/zoom)-dxGetTextWidth("Gracze w pobliżu", 1, assets.fonts[2])/2-20/zoom, sh/2-629/2/zoom+54/zoom+(23-13)/2/zoom, 10/zoom, 13/zoom, assets.textures[5], 0, 0, 0, tocolor(255,255,255,UI.alpha))

    -- lista
    dxDrawText("Gracz", sw/2-870/2/zoom+870/zoom-21/zoom-346/zoom, sh/2-629/2/zoom+54/zoom+23/zoom+1/zoom, 0, 0, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[3], "left", "top")
    dxDrawText("ID", sw/2-870/2/zoom+870/zoom-21/zoom-60/zoom, sh/2-629/2/zoom+54/zoom+23/zoom+1/zoom, 0, 0, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[3], "left", "top")
    local x=0
    for i = UI.row2,UI.row2+7 do
        local v=UI.players[i]
        if(v and v ~= localPlayer)then
            x=x+1
            local sY=(59/zoom)*(x-1)

            dxDrawImage(sw/2-870/2/zoom+870/zoom-435/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY, 435/zoom, 57/zoom, assets.textures[6], 0, 0, 0, tocolor(255,255,255,UI.alpha))

            if(UI.selected_player == v)then
                dxDrawRectangle(sw/2-870/2/zoom+870/zoom-435/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY+57/zoom-1, 435/zoom, 1, tocolor(33,147,176,UI.alpha))
            else
                dxDrawRectangle(sw/2-870/2/zoom+870/zoom-435/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY+57/zoom-1, 435/zoom, 1, tocolor(86,86,86,UI.alpha))
            end

            onClick(sw/2-870/2/zoom+870/zoom-435/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY, 435/zoom, 57/zoom, function()
                UI.selected_player=v
            end)

            local av=avatars:getPlayerAvatar(v)
            dxDrawImage(sw/2-870/2/zoom+870/zoom-435/zoom-(32-57)/2/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY-(32-57)/2/zoom, 32/zoom, 32/zoom, av, 0, 0, 0, tocolor(255,255,255,UI.alpha))
            dxDrawText(getPlayerName(v), sw/2-870/2/zoom+870/zoom-21/zoom-346/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY, 0, sh/2-629/2/zoom+54/zoom+44/zoom+sY+57/zoom, tocolor(210,204,29,UI.alpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(getElementData(v, "user:id"), sw/2-870/2/zoom+870/zoom-21/zoom-60/zoom, sh/2-629/2/zoom+54/zoom+44/zoom+sY, 0, sh/2-629/2/zoom+54/zoom+44/zoom+sY+57/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "left", "center")    
        end
    end

    -- dol
    dxDrawRectangle(sw/2-867/2/zoom, sh/2-629/2/zoom+629/zoom-58/zoom-2, 867/zoom, 58/zoom, tocolor(24,24,24,UI.alpha > 120 and 120 or UI.alpha))
    dxDrawText(UI.selected_veh and "Oferta: "..getVehicleNameFromModel(UI.selected_veh.model).." [#2193b0"..UI.selected_veh.id.."#c8c8c8]" or "Wybierz pojazd z listy", sw/2-867/2/zoom+22/zoom, sh/2-629/2/zoom+629/zoom-58/zoom-2, 867/zoom, 58/zoom+sh/2-629/2/zoom+629/zoom-58/zoom-2, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[6], "left", "center", false, false, false, true)
    dxDrawText(UI.selected_player and "Dla gracza: ["..getElementData(UI.selected_player, "user:id").."] #d2cc1d"..getPlayerName(UI.selected_player) or "Wybierz gracza z listy", sw/2-867/2/zoom+453/zoom, sh/2-629/2/zoom+629/zoom-58/zoom-2, 867/zoom, 58/zoom+sh/2-629/2/zoom+629/zoom-58/zoom-2, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[6], "left", "center", false, false, false, true)

    -- srodek
    dxDrawRectangle(sw/2, sh/2-629/2/zoom+54/zoom, 1, 629/zoom-54/zoom, tocolor(86,86,86,UI.alpha))

    onClick(sw/2-872/2/zoom+872/zoom-10/zoom-(54-10)/2/zoom, sh/2-629/2/zoom+(54-10)/2/zoom, 10/zoom, 10/zoom, function()
        showCursor(false)
        animate(UI.alpha, 0, "Linear", 250, function(a)
            UI.alpha=a

            exports.px_scroll:dxScrollSetAlpha(UI.scroll, a)
            exports.px_scroll:dxScrollSetAlpha(UI.scroll2, a)
            exports.px_buttons:buttonSetAlpha(UI.btns[1], a)
            exports.px_editbox:dxSetEditAlpha(UI.edits[1], a)

        end, function()
            assets.destroy()
            removeEventHandler("onClientRender", root, UI.onRender)

            exports.px_scroll:dxDestroyScroll(UI.scroll)
            exports.px_scroll:dxDestroyScroll(UI.scroll2)
            exports.px_buttons:destroyButton(UI.btns[1])
            exports.px_editbox:dxDestroyEdit(UI.edits[1])

            setElementData(localPlayer, "user:gui_showed", false, false)

            UI.selected_veh=false
            UI.selected_player=false

            UI.vehInfo=false
        end)
    end)

    if(UI.selected_veh)then
        onClick(sw/2-867/2/zoom+867/zoom-147/zoom-(58-37)/2/zoom, sh/2-629/2/zoom+629/zoom-58/zoom-2+(58-37)/2/zoom, 147/zoom, 37/zoom, function()
            local cena=exports.px_editbox:dxGetEditText(UI.edits[1])
            if(#cena >= 3 and #cena < 10 and tonumber(cena))then
                cena = tonumber(cena)
                cena = math.floor(cena)
                if(cena < 100 or cena > 1000000)then
                    noti:noti("Wprowadziłeś błędną wartość.", "error")
                    return
                end

                local player=UI.selected_player
                if(not tonumber(cena) and #cena < 1)then
                    noti:noti("Najpierw wprowadź cene.")
                elseif(cena < 1)then
                    noti:noti("Cena jest nieprawidłowa.")
                elseif(not player)then
                    noti:noti("Nie znaleziono podanego gracza.")
                elseif(player == localPlayer)then
                    noti:noti("Nie możesz sobie sprzedać pojazdu.")
                elseif(getElementData(player, "sell_vehs:offer") or getElementData(player, 'exchange_vehs:offer'))then
                    noti:noti("Ten gracz ma aktualnie otwartą ofertę sprzedaży pojazdu.")
                elseif(getElementData(localPlayer, "sell_vehs:offer") or getElementData(localPlayer, 'exchange_vehs:offer'))then
                    noti:noti("Poczekaj aż twoja pierwsza oferta zostanie zaakceptowana/anulowana.")
                else
                    local x1,y1,z1 = getElementPosition(localPlayer)
                    local x2,y2,z2 = getElementPosition(player)
                    local dist = getDistanceBetweenPoints3D(x1,y1,z1, x2,y2,z2)
                    if(dist > 10)then
                        noti:noti("Podany gracz znajduje się zbyt daleko.")
                    else
                        if(SPAM.getSpam())then return end

                        triggerServerEvent("send.offer", resourceRoot, player, UI.selected_veh, cena)
                        setElementData(localPlayer, "sell_vehs:offer", true)

                        showCursor(false)
                        animate(UI.alpha, 0, "Linear", 500, function(a)
                            UI.alpha=a

                            exports.px_scroll:dxScrollSetAlpha(UI.scroll, a)
                            exports.px_buttons:buttonSetAlpha(UI.btns[1], a)
                            exports.px_editbox:dxSetEditAlpha(UI.edits[1], a)
                            exports.px_editbox:dxSetEditAlpha(UI.edits[2], a)
                        end, function()
                            assets.destroy()
                            removeEventHandler("onClientRender", root, UI.onRender)

                            exports.px_scroll:dxDestroyScroll(UI.scroll)
                            exports.px_buttons:destroyButton(UI.btns[1])
                            exports.px_editbox:dxDestroyEdit(UI.edits[1])
                            exports.px_editbox:dxDestroyEdit(UI.edits[2])

                            setElementData(localPlayer, "user:gui_showed", false, false)
                        end)
                    end
                end
            else
                noti:noti("Cena jest nieprawidłowa.")
            end
        end)
    end
end

UI.offerRender=function()
    local v=UI.vehInfo
    if(not v.player)then return end

    local myPos={getElementPosition(localPlayer)}
    local tPos={getElementPosition(v.player)}
    local dist=getDistanceBetweenPoints3D(myPos[1],myPos[2],myPos[3],tPos[1],tPos[2],tPos[3])
    if(dist > 10)then
        triggerServerEvent("cancel.offer", resourceRoot, "Gracz "..getPlayerName(localPlayer).." anulował oferte kupna pojazdu "..getVehicleNameFromModel(v.model)..".", v.player)
        noti:noti("Anulowano ofertę kupna pojazdu.")

        assets.destroy()
        removeEventHandler("onClientRender", root, UI.offerRender)

        exports.px_buttons:destroyButton(UI.btns[1])
        exports.px_buttons:destroyButton(UI.btns[2])

        setElementData(localPlayer, "user:gui_showed", false, false)

        UI.vehInfo=false

        exports.px_scroll:dxDestroyScroll(UI.scroll)

        showCursor(false)
        return
    end

    local cx, cy=getCursorPosition()
    cx=(cx or 0)*sw
    cy=(cy or 0)*sh

    local color=split(v.color, ',')
    local light=split(v.lightColor, ',')
    local hand=getOriginalHandling(v.model)
    local driveType=hand.driveType

    local export=exports.px_custom_vehicles

    blur:dxDrawBlur(sw/2-695/2/zoom, sh/2-736/2/zoom, 695/zoom, 736/zoom, tocolor(255,255,255,UI.alpha))
    dxDrawImage(sw/2-695/2/zoom, sh/2-736/2/zoom, 695/zoom, 736/zoom, assets.textures[1], 0, 0, 0, tocolor(255,255,255,UI.alpha))

    dxDrawText("Oferta kupna", sw/2-695/2/zoom, sh/2-736/2/zoom, sw/2-695/2/zoom+695/zoom, sh/2-736/2/zoom+54/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[1], "center", "center")
    dxDrawImage(sw/2-695/2/zoom+695/2/zoom+dxGetTextWidth("Oferta kupna", 1, assets.fonts[1])/2+10/zoom, sh/2-736/2/zoom+(55-19)/2/zoom, 19/zoom, 19/zoom, assets.textures[2], 0, 0, 0, tocolor(255,255,255,UI.alpha))

    dxDrawRectangle(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+55/zoom, (695-17-17)/zoom, 1, tocolor(86,86,86,UI.alpha))

    dxDrawText("Otrzymałeś ofertę kupna pojazdu za $"..convertNumber(v.cost), sw/2-695/2/zoom, sh/2-736/2/zoom+75/zoom, sw/2-695/2/zoom+695/zoom, sh/2-736/2/zoom+54/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "center", "top")
    
    local av=avatars:getPlayerAvatar(v.player)
    dxDrawImage(sw/2-695/2/zoom+(695-32)/2/zoom-(dxGetTextWidth("["..getElementData(v.player, "user:id").."] "..getPlayerName(v.player), 1, assets.fonts[5]))/2-25/zoom, sh/2-736/2/zoom+107/zoom, 32/zoom, 32/zoom, av, 0, 0, 0, tocolor(255,255,255,UI.alpha))
    dxDrawText("["..getElementData(v.player, "user:id").."] #d2cc1d"..getPlayerName(v.player), sw/2-695/2/zoom, sh/2-736/2/zoom+107/zoom, sw/2-695/2/zoom+695/zoom, sh/2-736/2/zoom+54/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "center", "top", false, false, false, true)

    -- lewo
    local default_engine=exports.px_custom_vehicles:getVehicleEngineFromModel(v.model)
	local engine=(v.engine and string.len(v.engine) > 0) and string.format("%.1f", v.engine) or default_engine
	if(string.len(v.engine) < 1 or tonumber(v.engine) < 0.1)then
		engine=default_engine
	end

    dxDrawText("Główne informacje", sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+151/zoom, 0, 0, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "left", "top")
    dxDrawRectangle(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+178/zoom, 311/zoom, 1, tocolor(86,86,86,UI.alpha))
    local infos={
        {"Marka", getVehicleNameFromModel(v.model)},
        {"Przebieg", v.distance.."km"},
        {"ID", v.id},
        {"Bak", v.fuel.."l/"..v.fuelTank.."l"},
        {"Silnik", string.format("%.1f", engine).." dm³"},
        {"Rodzaj paliwa", v.fuelType},
        {"Napęd", string.upper(driveType)},
    }
    for i,v in pairs(infos) do
        local sY=(43/zoom)*(i-1)
        dxDrawImage(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+178/zoom+11/zoom+sY, 311/zoom, 41/zoom, assets.textures[8], 0, 0, 0, tocolor(255,255,255,UI.alpha))
        dxDrawText(v[1], sw/2-695/2/zoom+17/zoom+12/zoom, sh/2-736/2/zoom+178/zoom+11/zoom+sY-2, 311/zoom+sw/2-695/2/zoom+17/zoom, 41/zoom+sh/2-736/2/zoom+178/zoom+11/zoom+sY, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "left", "center")
        dxDrawText(v[2], sw/2-695/2/zoom+17/zoom+12/zoom, sh/2-736/2/zoom+178/zoom+11/zoom+sY-2, 311/zoom+sw/2-695/2/zoom+17/zoom-12/zoom, 41/zoom+sh/2-736/2/zoom+178/zoom+11/zoom+sY, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "right", "center")
    end

    -- prawo
    dxDrawText("Informacje mechaniczne", sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom, sh/2-736/2/zoom+151/zoom, 0, 0, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "left", "top")
    dxDrawRectangle(sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom, sh/2-736/2/zoom+178/zoom, 311/zoom, 1, tocolor(86,86,86,UI.alpha))

    local mech=fromJSON(v.mechanicTuning) or {}

    local info_1={
        {"MK1", mech.MK1 and "tak" or "nie"},
        {"MK2", mech.MK2 and "tak" or "nie"},
        {"MultiLED", mech.multiLED and "tak" or "nie"},
        {"Zawieszenie", mech.suspension or "brak"},
        {"Turbosprężarka", mech.turbo or "brak"},
        {"Hamulce", mech.brakes or "brak"},
        {"Nitro", mech.nitro or "brak"},
        {"ASR OFF", mech['vehicle:ASR'] and 'tak' or 'brak'},
        {"ALS", mech['vehicle:ALS'] and 'tak' or 'brak'},
        {"Wykrywacz radarów", mech['vehicle:radarDetector'] and 'tak' or 'brak'},
        {"CB-Radio", mech['vehicle:cbRadio'] and 'tak' or 'brak'},
        {"Kolor licznika", mech['vehicle:speedoColor'] or 'brak'},
        {"Maskowanie szyb", mech['vehicle:tint'] and mech['vehicle:tint'].."%" or 'brak'},
    }
    local row=math.floor(exports.px_scroll:dxScrollGetPosition(UI.scroll)+1)
    local x=0
    for i=row,row+6 do
        local v=info_1[i]
        if(v)then
            x=x+1

            local sY=(43/zoom)*(x-1)
            dxDrawImage(sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom, sh/2-736/2/zoom+178/zoom+sY+11/zoom, 311/zoom, 41/zoom, assets.textures[8], 0, 0, 0, tocolor(255,255,255,UI.alpha))
            dxDrawText(v[1], sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom+12/zoom, sh/2-736/2/zoom+178/zoom+sY+11/zoom-2, 311/zoom+sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom, 41/zoom+sh/2-736/2/zoom+178/zoom+sY+11/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "left", "center")
            dxDrawText(v[2], sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom+12/zoom, sh/2-736/2/zoom+178/zoom+sY+11/zoom-2, 311/zoom+sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom-12/zoom, 41/zoom+sh/2-736/2/zoom+178/zoom+sY+11/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "right", "center")
        end
    end

    -- dol
    dxDrawText("Pozostałe informacje", sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+507/zoom, 0, 0, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[5], "left", "top")
    dxDrawRectangle(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+532/zoom, 311/zoom, 1, tocolor(86,86,86,UI.alpha))

    local tune=split(v.tuning, ",") or {}
    local infos={
        {"Tuning wizualny", #tune < 1 and "brak" or tune},
        {"Kolor karoserii", "karo", color},
        {"Kolor świateł", "light", light},
    }
    local last=0
    for i,v in pairs(infos) do
        local sY=last+(25/zoom)*(i-1)
        if(v[2] == "karo")then
            dxDrawText(v[1]..":", sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+540/zoom+sY, 0, 0, tocolor(165,165,165,UI.alpha), 1, assets.fonts[6], "left", "top", false, false, false, true)
            dxDrawImage(sw/2-695/2/zoom+17/zoom+dxGetTextWidth(v[1]..":", 1, assets.fonts[6])+14/2/zoom, sh/2-736/2/zoom+540/zoom+sY+5/zoom, 14/zoom, 14/zoom, assets.textures[9], 0, 0, 0, tocolor(v[3][1],v[3][2],v[3][3],UI.alpha))
            dxDrawImage(sw/2-695/2/zoom+17/zoom+dxGetTextWidth(v[1]..":", 1, assets.fonts[6])+14/2/zoom+20/zoom, sh/2-736/2/zoom+540/zoom+sY+5/zoom, 14/zoom, 14/zoom, assets.textures[9], 0, 0, 0, tocolor(v[3][4],v[3][5],v[3][6],UI.alpha))
        elseif(v[2] == "light")then
            dxDrawText(v[1]..":", sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+540/zoom+sY, 0, 0, tocolor(165,165,165,UI.alpha), 1, assets.fonts[6], "left", "top", false, false, false, true)
            dxDrawImage(sw/2-695/2/zoom+17/zoom+dxGetTextWidth(v[1]..":", 1, assets.fonts[6])+14/2/zoom, sh/2-736/2/zoom+540/zoom+sY+5/zoom, 14/zoom, 14/zoom, assets.textures[9], 0, 0, 0, tocolor(v[3][1],v[3][2],v[3][3],UI.alpha))
        else
            dxDrawText(v[1]..": "..v[2], sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+540/zoom+sY, sw/2-695/2/zoom+650/zoom, 0, tocolor(165,165,165,UI.alpha), 1, assets.fonts[6], "left", "top", false, true)
            if(dxGetTextWidth(v[1]..": "..v[2], 1, assets.fonts[6]) > 650/zoom)then
                last=20/zoom
            end
        end
    end

    -- podpis
    dxDrawImage(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+647/zoom, 312/zoom, 66/zoom, assets.textures[8], 0, 0, 0, tocolor(255,255,255,UI.alpha))
    if(not UI.podpis)then
        dxDrawText("Twój podpis", sw/2-695/2/zoom+17/zoom+10/zoom, sh/2-736/2/zoom+647/zoom+10/zoom, 0, 0, tocolor(100,100,100,UI.alpha), 1, assets.fonts[6], "left", "top")
    end

    if(isCursorShowing() and getKeyState("mouse1") and isMouseInPosition(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+647/zoom, 312/zoom, 66/zoom))then
        local px,py=sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+647/zoom
        dxSetRenderTarget(UI.podpisTarget)
            local finalX1, finalY1 = UI.prvX - px, UI.prvY - py
            local finalX2, finalY2 = cx - px, cy - py
            dxDrawLine(finalX1, finalY1, finalX2, finalY2, black, 2)
            UI.podpis=true
        dxSetRenderTarget()
    end
    
    dxDrawImage(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+647/zoom, 312/zoom, 66/zoom,UI.podpisTarget, 0, 0, 0, tocolor(255,255,255,UI.alpha))

    onClick(sw/2-695/2/zoom+695/zoom-154/zoom-181/zoom, sh/2-736/2/zoom+736/zoom-45/zoom-18/zoom, 154/zoom, 45/zoom, function()
        if(SPAM.getSpam())then return end

        triggerServerEvent("cancel.offer", resourceRoot, "Gracz "..getPlayerName(localPlayer).." anulował oferte kupna pojazdu "..getVehicleNameFromModel(v.model)..".", v.player)
        noti:noti("Pomyślnie anulowano ofertę kupna pojazdu.")

        showCursor(false)
        animate(UI.alpha, 0, "Linear", 500, function(a)
            UI.alpha=a

            exports.px_buttons:buttonSetAlpha(UI.btns[1], a)
            exports.px_buttons:buttonSetAlpha(UI.btns[2], a)

            exports.px_scroll:dxScrollSetAlpha(UI.scroll, a)
        end, function()
            assets.destroy()
            removeEventHandler("onClientRender", root, UI.offerRender)

            exports.px_buttons:destroyButton(UI.btns[1])
            exports.px_buttons:destroyButton(UI.btns[2])

            setElementData(localPlayer, "user:gui_showed", false, false)

            UI.vehInfo=false

            exports.px_scroll:dxDestroyScroll(UI.scroll)
        end)
    end)

    onClick(sw/2-695/2/zoom+695/zoom-154/zoom-17/zoom, sh/2-736/2/zoom+736/zoom-45/zoom-18/zoom, 154/zoom, 45/zoom, function()
        if(getPlayerMoney(localPlayer) >= v.cost)then
            if(SPAM.getSpam())then return end

            triggerServerEvent("buy.vehicle", resourceRoot, v)

            showCursor(false)
            animate(UI.alpha, 0, "Linear", 500, function(a)
                UI.alpha=a

                exports.px_buttons:buttonSetAlpha(UI.btns[1], a)
                exports.px_buttons:buttonSetAlpha(UI.btns[2], a)

                exports.px_scroll:dxScrollSetAlpha(UI.scroll, a)
            end, function()
                assets.destroy()
                removeEventHandler("onClientRender", root, UI.offerRender)


                exports.px_buttons:destroyButton(UI.btns[1])
                exports.px_buttons:destroyButton(UI.btns[2])

                UI.vehInfo=false

                setElementData(localPlayer, "user:gui_showed", false, false)

                exports.px_scroll:dxDestroyScroll(UI.scroll)
            end)
        else
            noti:noti("Nie stać cię na zakup tego pojazdu.")
        end
    end)

    UI.prvX,UI.prvY=cx,cy
end

-- triggers

addEvent("sell.openUI", true)
addEventHandler("sell.openUI", resourceRoot, function(vehs)
    if(getElementData(localPlayer, "user:gui_showed"))then return end

    editbox=exports.px_editbox
    buttons=exports.px_buttons
    noti=exports.px_noti
    blur=exports.blur
    scroll=exports.px_scroll
    avatars=exports.px_avatars

    UI.vehs=vehs

    assets.create()

    showCursor(true)
    addEventHandler("onClientRender", root, UI.onRender)

    UI.scroll=exports.px_scroll:dxCreateScroll(sw/2-872/2/zoom+435/zoom-3, sh/2-629/2/zoom+54/zoom+44/zoom, 4, 4, 0, 8, UI.vehs, 470/zoom, 0, 1)

    UI.btns[1]=exports.px_buttons:createButton(sw/2-867/2/zoom+867/zoom-147/zoom-(58-37)/2/zoom, sh/2-629/2/zoom+629/zoom-58/zoom-2+(58-37)/2/zoom, 147/zoom, 37/zoom, "WYŚLIJ OFERTE", 0, 9, false, false, ":px_stock_vehicles/textures/sell/button_icon.png")

    UI.edits[1] = editbox:dxCreateEdit("Kwota", sw/2-867/2/zoom+250/zoom, sh/2-629/2/zoom+629/zoom-58/zoom-2+(58-25)/2/zoom, 169/zoom, 25/zoom, false, 10/zoom, 0, true, false, ":px_stock_vehicles/textures/sell/edit_icon.png")

    UI.alpha=0
    animate(UI.alpha, 255, "Linear", 250, function(a)
        UI.alpha=a

        exports.px_scroll:dxScrollSetAlpha(UI.scroll, a)
        exports.px_buttons:buttonSetAlpha(UI.btns[1], a)
        exports.px_editbox:dxSetEditAlpha(UI.edits[1], a)
    end)

    UI.selectedVehicle=false

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    local x,y,z=getElementPosition(localPlayer)
    UI.players=getElementsWithinRange(x, y, z, 10, "player")
end)

local t={}
for i=1,13 do
    t[i]=i
end

addEvent("send.offer", true)
addEventHandler("send.offer", resourceRoot, function(player, info, cost)
    if(getElementData(localPlayer, "user:gui_showed"))then 
        setElementData(localPlayer, 'sell_vehs:offer', false)
        triggerServerEvent('off.data', resourceRoot, player)
        return 
    end

    if(UI.vehInfo)then 
        setElementData(localPlayer, 'sell_vehs:offer', false)
        triggerServerEvent('off.data', resourceRoot, player)
        return 
    end

    editbox=exports.px_editbox
    buttons=exports.px_buttons
    noti=exports.px_noti
    blur=exports.blur
    scroll=exports.px_scroll
    avatars=exports.px_avatars

    info.cost=cost
    info.from=getPlayerName(player)
    info.player=player
    UI.vehInfo=info

    assets.create()

    showCursor(true)
    addEventHandler("onClientRender", root, UI.offerRender)
    
    UI.podpis=false
    UI.podpisTarget=dxCreateRenderTarget(312/zoom, 66/zoom, true)
    UI.prvX,UI.prvY=0,0
    
    UI.btns[1]=exports.px_buttons:createButton(sw/2-695/2/zoom+695/zoom-154/zoom-17/zoom, sh/2-736/2/zoom+736/zoom-45/zoom-18/zoom, 154/zoom, 45/zoom, "ZAKUP", 0, 9, false, false, ":px_stock_vehicles/textures/sell/tak_button.png")
    UI.btns[2]=exports.px_buttons:createButton(sw/2-695/2/zoom+695/zoom-154/zoom-181/zoom, sh/2-736/2/zoom+736/zoom-45/zoom-18/zoom, 154/zoom, 45/zoom, "ANULUJ", 0, 9, false, false, ":px_stock_vehicles/textures/sell/nie_button.png", {132,39,39})
    
    UI.scroll=exports.px_scroll:dxCreateScroll(sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom+315/zoom, sh/2-736/2/zoom+178/zoom+11/zoom, 4, 4, 0, 7, t, 300/zoom, 0, 1)

    UI.alpha=0
    animate(UI.alpha, 255, "Linear", 500, function(a)
        UI.alpha=a

        exports.px_buttons:buttonSetAlpha(UI.btns[1], a)
        exports.px_buttons:buttonSetAlpha(UI.btns[2], a)

        exports.px_scroll:dxScrollSetAlpha(UI.scroll, a)
    end)

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    setElementData(localPlayer, "sell_vehs:offer", true)
end)

setElementData(localPlayer, "sell_vehs:offer", false)