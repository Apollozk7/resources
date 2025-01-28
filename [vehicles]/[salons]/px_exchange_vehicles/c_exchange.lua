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

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local showed=false

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
        "textures/background.png",
        "textures/header_icon.png",

        "textures/mycars-icon.png",
        "textures/user-icon.png",

        "textures/list.png",

        "textures/row.png",
        "textures/row_hover.png",

        "textures/car-icon.png",
        "textures/info-icon.png",

        "textures/window-info.png",

        "textures/arrow.png",

        "textures/color.png",

        "textures/level.png",
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

--

local ui={}

local t={}
for i=1,13 do
    t[i]=i
end

ui.panels={
    drawPanel=1,
    alpha=0,
    animate=false,

    scroll={},
    btns={},
    edits={},

    row=0,
    row2=0,

    getPlayerAvatar=function(ui,nick)
       return avatars:getPlayerAvatar(nick)
    end,

    [1]={
        vehicles={},
        players={},

        selected_vehicle=0,
        selected_player_vehicle=0,
        selected_player=false,

        refreshVehs=function(ui)
            ui[1].selected_player_vehicle=0

            local vehs=ui[1].players[ui[1].selected_player] and ui[1].players[ui[1].selected_player].vehs or false
            if(vehs)then
                if(ui.scroll[2])then
                    scroll:dxDestroyScroll(ui.scroll[2])
                end

                ui.scroll[2]=scroll:dxCreateScroll(sw/2-870/2/zoom+435/zoom+435/zoom-4, sh/2-694/2/zoom+54/zoom+44/zoom+15/zoom, 4/zoom, 4/zoom, 0, 6, vehs, 352/zoom, 0, 1, {sw/2, 0, sw, sh})
            end
        end,

        render=function(ui)
            -- update players
            if(not ui[1].players[ui[1].selected_player])then
                ui[1].selected_player=false
            end
            --

            blur:dxDrawBlur(sw/2-872/2/zoom, sh/2-694/2/zoom, 872/zoom, 694/zoom, tocolor(255,255,255,ui.alpha))
            dxDrawImage(sw/2-872/2/zoom, sh/2-694/2/zoom, 872/zoom, 694/zoom, assets.textures[1], 0, 0, 0, tocolor(255,255,255,ui.alpha))
        
            dxDrawText("Wymiana pojazdów", sw/2-872/2/zoom, sh/2-694/2/zoom, sw/2-872/2/zoom+872/zoom, sh/2-694/2/zoom+54/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[1], "center", "center")
            dxDrawImage(sw/2-872/2/zoom+872/2/zoom+dxGetTextWidth("Wymiana pojazdów", 1, assets.fonts[1])/2+10/zoom, sh/2-694/2/zoom+(54-19)/2/zoom, 19/zoom, 19/zoom, assets.textures[2], 0, 0, 0, tocolor(255,255,255,ui.alpha))
        
            dxDrawRectangle(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom, 870/zoom, 1, tocolor(86,86,86,ui.alpha))
        
            local plus=15/zoom
        
            -- lewo
            dxDrawText("Twoje pojazdy", sw/2-870/2/zoom+21/zoom, sh/2-694/2/zoom+54/zoom+(15/2)/zoom, sw/2-870/2/zoom+21/zoom+392/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+(15/2)/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[2], "center", "center")
            dxDrawImage(sw/2-870/2/zoom+21/zoom+(392/2/zoom)-dxGetTextWidth("Twoje pojazdy", 1, assets.fonts[2])/2-20/zoom, sh/2-694/2/zoom+54/zoom+(23-13)/2/zoom+(15/2)/zoom, 13/zoom, 13/zoom, assets.textures[3], 0, 0, 0, tocolor(255,255,255,ui.alpha))
        
            -- lista
        
            ui.row=math.floor(exports.px_scroll:dxScrollGetPosition(ui.scroll[1])+1)
        
            dxDrawImage(sw/2-870/2/zoom+(435-432)/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom, 432/zoom, 22/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawText("ID", sw/2-870/2/zoom+21/zoom+42/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            dxDrawText("Pojazd", sw/2-870/2/zoom+21/zoom+108/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            dxDrawText("Przebieg", sw/2-870/2/zoom+21/zoom+278/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            
            local x=0
            for i = ui.row,ui.row+6 do
                local v=ui[1].vehicles[i]
                if(v)then
                    x=x+1
                    local sY=(59/zoom)*(x-1)
                    
                    if(ui[1].selected_vehicle == i)then
                        dxDrawImage(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 435/zoom, 57/zoom, assets.textures[7], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                        dxDrawRectangle(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom-1+15/zoom, 435/zoom, 1, tocolor(33,147,176,ui.alpha))
                    else
                        dxDrawImage(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 435/zoom, 57/zoom, assets.textures[6], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                        dxDrawRectangle(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom-1+15/zoom, 435/zoom, 1, tocolor(86,86,86,ui.alpha))
                    end
        
                    onClick(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 435/zoom, 57/zoom, function()
                        ui[1].selected_vehicle=i
                        if(isMouseInPosition(sw/2-870/2/zoom+435/zoom-18/zoom-(57-18)/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-18)/2/zoom+15/zoom, 18/zoom, 18/zoom) and not ui.animate)then
                            ui[2].info_veh=v
                            ui[1].visible(true)
                            setTimer(function()
                                ui[2].create()
                                ui.drawPanel=2
                            end, 300, 1)
                        end
                    end)
                    
                    dxDrawImage(sw/2-870/2/zoom+21/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-12)/2/zoom+15/zoom, 26/zoom, 12/zoom, assets.textures[8], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                    dxDrawText(v.id, sw/2-870/2/zoom+21/zoom+42/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[4], "left", "center")
                    dxDrawText(getVehicleNameFromModel(v.model), sw/2-870/2/zoom+21/zoom+108/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "left", "center")
                    dxDrawText(string.format("%.1f", v.distance).." #2193b0km", sw/2-870/2/zoom+21/zoom+250/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[4], "left", "center", false, false, false, true)
                    dxDrawImage(sw/2-870/2/zoom+435/zoom-18/zoom-(57-18)/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-18)/2/zoom+15/zoom, 18/zoom, 18/zoom, assets.textures[9], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                end
            end
        
            -- prawo
            ui.row2=math.floor(exports.px_scroll:dxScrollGetPosition(ui.scroll[2])+1)
        
            local text="Pojazdy gracza"
            dxDrawText(text, sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom, sh/2-694/2/zoom+54/zoom+(15/2)/zoom, sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom+392/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+(15/2)/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[2], "center", "center")
            dxDrawImage(sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom+(392/2/zoom)-dxGetTextWidth(text, 1, assets.fonts[2])/2-20/zoom, sh/2-694/2/zoom+54/zoom+(23-12)/2/zoom+(15/2)/zoom, 10/zoom, 12/zoom, assets.textures[4], 0, 0, 0, tocolor(255,255,255,ui.alpha))
        
            -- lista
            dxDrawImage(sw/2-870/2/zoom+(435-432)/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom, 432/zoom, 22/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawText("ID", sw/2-870/2/zoom+21/zoom+42/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            dxDrawText("Pojazd", sw/2-870/2/zoom+21/zoom+108/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            dxDrawText("Przebieg", sw/2-870/2/zoom+21/zoom+278/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            
            local vehs=ui[1].players[ui[1].selected_player] and ui[1].players[ui[1].selected_player].vehs or false
            if(vehs)then
                local x=0
                for i = ui.row2,ui.row2+5 do
                    local v=vehs[i]
                    if(v)then
                        x=x+1
                        local sY=(59/zoom)*(x-1)
                        
                        if(ui[1].selected_player_vehicle == i)then
                            dxDrawImage(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 435/zoom, 57/zoom, assets.textures[7], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                            dxDrawRectangle(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom-1+15/zoom, 435/zoom, 1, tocolor(33,147,176,ui.alpha))
                        else
                            dxDrawImage(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 435/zoom, 57/zoom, assets.textures[6], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                            dxDrawRectangle(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom-1+15/zoom, 435/zoom, 1, tocolor(86,86,86,ui.alpha))
                        end
            
                        onClick(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 435/zoom, 57/zoom, function()
                            ui[1].selected_player_vehicle=i
                            if(isMouseInPosition(sw/2-870/2/zoom+435/zoom-18/zoom-(57-18)/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-18)/2/zoom+15/zoom, 18/zoom, 18/zoom) and not ui.animate)then
                                ui[2].info_veh=v
                                ui[1].visible(true)
                                setTimer(function()
                                    ui[2].create()
                                    ui.drawPanel=2
                                end, 300, 1)
                            end
                        end)
                        
                        dxDrawImage(sw/2-870/2/zoom+21/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-12)/2/zoom+15/zoom, 26/zoom, 12/zoom, assets.textures[8], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                        dxDrawText(v.id, sw/2-870/2/zoom+21/zoom+42/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[4], "left", "center")
                        dxDrawText(getVehicleNameFromModel(v.model), sw/2-870/2/zoom+21/zoom+108/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "left", "center")
                        dxDrawText(string.format("%.1f", v.distance).." #2193b0km", sw/2-870/2/zoom+21/zoom+250/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[4], "left", "center", false, false, false, true)
                        dxDrawImage(sw/2-870/2/zoom+435/zoom-18/zoom-(57-18)/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-18)/2/zoom+15/zoom, 18/zoom, 18/zoom, assets.textures[9], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                    end
                end
            end

            -- players
            local text=ui[1].selected_player and getPlayerName(ui[1].players[ui[1].selected_player].player) or "Wybierz gracza"
            dxDrawImage(sw/2-872/2/zoom+872/2/zoom, sh/2-694/2/zoom+541/zoom-58/zoom, 872/2/zoom-1, 58/zoom, assets.textures[10], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            
            dxDrawText("Gracz w pobliżu", sw/2-872/2/zoom+872/2/zoom, sh/2-694/2/zoom+541/zoom-58/zoom, 872/2/zoom-1+sw/2-872/2/zoom+872/2/zoom, 58/zoom+sh/2-694/2/zoom+541/zoom-58/zoom-25/zoom, tocolor(33, 147, 176, ui.alpha), 1, assets.fonts[6], "center", "center")
            dxDrawText(text, sw/2-872/2/zoom+872/2/zoom, sh/2-694/2/zoom+541/zoom-58/zoom, 872/2/zoom-1+sw/2-872/2/zoom+872/2/zoom, 58/zoom+sh/2-694/2/zoom+541/zoom-58/zoom+20/zoom, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[6], "center", "center")
            
            dxDrawImage(sw/2-872/2/zoom+872/2/zoom+(872/2)/2/zoom-26/2/zoom-150/zoom+26/zoom, sh/2-694/2/zoom+541/zoom-58/zoom+(58-12)/2/zoom, 26/zoom, 12/zoom, assets.textures[11], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawImage(sw/2-872/2/zoom+872/2/zoom+(872/2)/2/zoom+26/2/zoom+100/zoom, sh/2-694/2/zoom+541/zoom-58/zoom+(58-12)/2/zoom, 26/zoom, 12/zoom, assets.textures[11], 180, 0, 0, tocolor(255, 255, 255, ui.alpha))

            onClick(sw/2-872/2/zoom+872/2/zoom+(872/2)/2/zoom-26/2/zoom-150/zoom+26/zoom, sh/2-694/2/zoom+541/zoom-58/zoom+(58-12)/2/zoom, 26/zoom, 12/zoom, function()
                if(text == "Wybierz gracza")then
                    if(ui[1].players[1])then
                        ui[1].selected_player=1
                        ui[1].refreshVehs(ui)
                    end
                else
                    if(ui[1].players[ui[1].selected_player-1])then
                        ui[1].selected_player=ui[1].selected_player-1
                        ui[1].refreshVehs(ui)
                    end
                end
            end)
            onClick(sw/2-872/2/zoom+872/2/zoom+(872/2)/2/zoom+26/2/zoom+100/zoom, sh/2-694/2/zoom+541/zoom-58/zoom+(58-12)/2/zoom, 26/zoom, 12/zoom, function()
                if(text == "Wybierz gracza")then
                    if(ui[1].players[1])then
                        ui[1].selected_player=1
                        ui[1].refreshVehs(ui)
                    end
                else
                    if(ui[1].players[ui[1].selected_player+1])then
                        ui[1].selected_player=ui[1].selected_player+1
                        ui[1].refreshVehs(ui)
                    end
                end
            end)
            --
        
            -- srodek
            dxDrawRectangle(sw/2, sh/2-694/2/zoom+54/zoom, 1, 694/zoom-54/zoom-68/zoom, tocolor(86,86,86,ui.alpha))
        
            -- doplaty
            dxDrawRectangle(sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom, 872/zoom, 1, tocolor(86,86,86,ui.alpha))
            dxDrawText("Opcjonalna dopłata", sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+13/zoom, 872/2/zoom+sw/2-872/2/zoom, 1, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[4], "center", "top")
            dxDrawText("Opcjonalna dopłata", sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+13/zoom, 872/zoom+872/2/zoom+sw/2-872/2/zoom, 1, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[4], "center", "top")
        
            -- przyciski
            dxDrawRectangle(sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+84/zoom, 872/zoom, 1, tocolor(86,86,86,ui.alpha))    
            
            -- close
            onClick(sw/2-147/zoom-10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, function()
                ui.destroy(ui)
            end)

            -- send offer
            onClick(sw/2+10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, function()
                local myMoney=editbox:dxGetEditText(ui.edits[1]) or 0
                local playerMoney=editbox:dxGetEditText(ui.edits[2]) or 0
                myMoney=#myMoney < 1 and 0 or myMoney
                playerMoney=#playerMoney < 1 and 0 or playerMoney
                myMoney=tonumber(myMoney)
                playerMoney=tonumber(playerMoney)
                if(tonumber(myMoney) and tonumber(playerMoney) and myMoney >= 0 and playerMoney >= 0 and text ~= "Wybierz gracza")then
                    if(myMoney > 1000000 or playerMoney > 1000000)then
                        noti:noti("Wprowadzono złą kwotę.", "error")
                        return
                    end

                    if(SPAM.getSpam())then return end

                    local player=ui[1].selected_player and ui[1].players[ui[1].selected_player].player or false
                    if(player)then
                        local vehs=ui[1].players[ui[1].selected_player] and ui[1].players[ui[1].selected_player].vehs or false
                        if(vehs)then
                            local myVeh=ui[1].selected_vehicle
                            local playerVeh=ui[1].selected_player_vehicle
                            if(ui[1].vehicles[myVeh] and vehs[playerVeh])then
                                local myInfo={
                                    doplata=myMoney,
                                    element=localPlayer,
                                    selected_veh=myVeh,
                                    vehs=ui[1].vehicles,
                                }

                                local playerInfo={
                                    doplata=playerMoney,
                                    element=player,
                                    selected_veh=playerVeh,
                                    vehs=vehs,
                                }
                                
                                triggerServerEvent("exchange.send.offer", resourceRoot, myInfo, playerInfo)

                                ui.destroy(ui)
                            else
                                noti:noti("Najpierw wybierz odpowiednie pojazdy.", "error")
                            end
                        else
                            noti:noti("Najpierw wybierz odpowiednie pojazdy.", "error")
                        end
                    else
                        noti:noti("Najpierw wybierz gracza.", "error")
                    end
                else
                    noti:noti("Najpierw wybierz gracza i wprowadź odpowednią sume.", "error")
                end
            end)
        end,

        create=function()
            if(ui.panels.animate or getElementData(localPlayer, 'user:gui_showed'))then return end

            local ui=ui.panels

            ui.animate=true
    
            ui.btns[1]=buttons:createButton(sw/2+10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, "WYŚLIJ OFERTE", 0, 9, false, false, ":px_exchange_vehicles/textures/button-accept.png")
            ui.btns[2]=buttons:createButton(sw/2-147/zoom-10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, "ANULUJ", 0, 9, false, false, ":px_exchange_vehicles/textures/button-close.png", {132,39,39})
        
            ui.edits[1] = editbox:dxCreateEdit("Kwota", sw/2-872/2/zoom+((872/2)-270)/2/zoom, sh/2+240/zoom, 270/zoom, 25/zoom, false, 10/zoom, 0, true, false, ":px_exchange_vehicles/textures/edit-icon.png")
            ui.edits[2] = editbox:dxCreateEdit("Kwota", sw/2-872/2/zoom+((872/2)-270)/2/zoom+872/2/zoom, sh/2+240/zoom, 270/zoom, 25/zoom, false, 10/zoom, 0, true, false, ":px_exchange_vehicles/textures/edit-icon.png")
        
            ui.alpha=0
            animate(ui.alpha, 255, "Linear", 250, function(a)
                ui.alpha=a

                for i,v in pairs(ui.scroll) do
                    scroll:dxScrollSetAlpha(v, a)
                end

                for i,v in pairs(ui.btns) do
                    buttons:buttonSetAlpha(v, a)
                end

                for i,v in pairs(ui.edits) do
                    editbox:dxSetEditAlpha(v, a)
                end
            end, function()
                ui.animate=false
            end)

            -- get players
            local x,y,z=getElementPosition(localPlayer)
            local players=getElementsWithinRange(x,y,z,5,"player")
            if(SPAM.getSpam())then return end
            triggerServerEvent("get.players.vehicles", resourceRoot, players, 1) -- tabela z graczami i gdzie ma zwrocic
            triggerServerEvent("get.player.vehicles", resourceRoot, 1)

            setElementData(localPlayer, 'user:gui_showed', resourceRoot, true)
        end,

        visible=function(toggle)
            if(ui.panels.animate)then return end

            local ui=ui.panels

            if(toggle)then
                ui.animate=true
                ui.alpha=255
                animate(255, 0, "Linear", 250, function(a)
                    ui.alpha=a

                    for i,v in pairs(ui.scroll) do
                        scroll:dxScrollSetAlpha(v, a)
                    end
    
                    for i,v in pairs(ui.btns) do
                        buttons:buttonSetAlpha(v, a)
                    end
    
                    for i,v in pairs(ui.edits) do
                        editbox:dxSetEditAlpha(v, a)
                    end
                end, function()
                    for i,v in pairs(ui.scroll) do
                        scroll:dxDestroyScroll(v)
                    end
    
                    for i,v in pairs(ui.btns) do
                        buttons:destroyButton(v)
                    end
    
                    for i,v in pairs(ui.edits) do
                        editbox:dxDestroyEdit(v)
                    end
    
                    if(ui.drawPanel == 1)then
                        ui.drawPanel=false
                    end

                    ui.animate=false
                end)
            else
                ui.btns[1]=buttons:createButton(sw/2+10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, "WYŚLIJ OFERTE", 0, 9, false, false, ":px_exchange_vehicles/textures/button-accept.png")
                ui.btns[2]=buttons:createButton(sw/2-147/zoom-10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, "ANULUJ", 0, 9, false, false, ":px_exchange_vehicles/textures/button-close.png", {132,39,39})
            
                ui.edits[1] = editbox:dxCreateEdit("Kwota", sw/2-872/2/zoom+((872/2)-270)/2/zoom, sh/2+240/zoom, 270/zoom, 25/zoom, false, 10/zoom, 0, true, false, ":px_exchange_vehicles/textures/edit-icon.png")
                ui.edits[2] = editbox:dxCreateEdit("Kwota", sw/2-872/2/zoom+((872/2)-270)/2/zoom+872/2/zoom, sh/2+240/zoom, 270/zoom, 25/zoom, false, 10/zoom, 0, true, false, ":px_exchange_vehicles/textures/edit-icon.png")    
                
                ui.scroll[1]=scroll:dxCreateScroll(sw/2-870/2/zoom+435/zoom-4, sh/2-694/2/zoom+54/zoom+44/zoom+15/zoom, 4/zoom, 4/zoom, 0, 7, ui[1].vehicles, 410/zoom, 0, 1, {0,0,sw/2,sh})
            
                ui[1].refreshVehs(ui)

                ui.animate=true
                ui.alpha=0
                animate(0, 255, "Linear", 250, function(a)
                    ui.alpha=a

                    for i,v in pairs(ui.scroll) do
                        scroll:dxScrollSetAlpha(v, a)
                    end
    
                    for i,v in pairs(ui.btns) do
                        buttons:buttonSetAlpha(v, a)
                    end
    
                    for i,v in pairs(ui.edits) do
                        editbox:dxSetEditAlpha(v, a)
                    end
                end, function()
                    ui.animate=false

                    if(ui.drawPanel ~= 1)then
                        ui.drawPanel=1
                    end
                end)
            end
        end,

        trigger=function(name, args1)
            if(name == "get.players.vehicles")then
                ui.panels[1].players=args1
            elseif(name == "get.player.vehicles")then
                ui.panels[1].vehicles=args1

                if(ui.panels.scroll[1])then
                    scroll:dxDestroyScroll(ui.panels.scroll[1])
                end

                ui.panels.scroll[1]=scroll:dxCreateScroll(sw/2-870/2/zoom+435/zoom-4, sh/2-694/2/zoom+54/zoom+44/zoom+15/zoom, 4/zoom, 4/zoom, 0, 7, ui.panels[1].vehicles, 410/zoom, 0, 1, {0,0,sw/2,sh})
            end
        end,
    },

    [2]={
        showed=false,
        info_veh={},

        render=function(ui)
            local color=fromJSON(v.color)
            local light=fromJSON(v.lightColor)
            local hand=getOriginalHandling(v.model)
            local driveType=hand.driveType
        
            blur:dxDrawBlur(sw/2-872/2/zoom, sh/2-694/2/zoom, 872/zoom, 694/zoom, tocolor(255,255,255,ui.alpha))
            dxDrawImage(sw/2-872/2/zoom, sh/2-694/2/zoom, 872/zoom, 694/zoom, assets.textures[1], 0, 0, 0, tocolor(255,255,255,ui.alpha))
        
            dxDrawText("Wymiana pojazdów", sw/2-872/2/zoom, sh/2-694/2/zoom, sw/2-872/2/zoom+872/zoom, sh/2-694/2/zoom+54/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[1], "center", "center")
            dxDrawImage(sw/2-872/2/zoom+872/2/zoom+dxGetTextWidth("Wymiana pojazdów", 1, assets.fonts[1])/2+10/zoom, sh/2-694/2/zoom+(54-19)/2/zoom, 19/zoom, 19/zoom, assets.textures[2], 0, 0, 0, tocolor(255,255,255,ui.alpha))
        
            dxDrawRectangle(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom, 870/zoom, 1, tocolor(86,86,86,ui.alpha))
        
            -- lewo
            local default_engine=export:getVehicleEngineFromModel(v.model)
            local engine=(v.engine and string.len(v.engine) > 0) and string.format("%.1f", v.engine) or default_engine
            if(string.len(v.engine) < 1 or tonumber(v.engine) < 0.1)then
                engine=default_engine
            end

            dxDrawText("Główne informacje", sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+151/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "left", "top")
            dxDrawRectangle(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+178/zoom, 311/zoom, 1, tocolor(86,86,86,ui.alpha))
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
                dxDrawImage(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+178/zoom+11/zoom+sY, 311/zoom, 41/zoom, assets.textures[10], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                dxDrawText(v[1], sw/2-695/2/zoom+17/zoom+12/zoom, sh/2-736/2/zoom+178/zoom+11/zoom+sY-2, 311/zoom+sw/2-695/2/zoom+17/zoom, 41/zoom+sh/2-736/2/zoom+178/zoom+11/zoom+sY, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "left", "center")
                dxDrawText(v[2], sw/2-695/2/zoom+17/zoom+12/zoom, sh/2-736/2/zoom+178/zoom+11/zoom+sY-2, 311/zoom+sw/2-695/2/zoom+17/zoom-12/zoom, 41/zoom+sh/2-736/2/zoom+178/zoom+11/zoom+sY, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "right", "center")
            end
        
            -- prawo
            dxDrawText("Informacje mechaniczne", sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom, sh/2-736/2/zoom+151/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "left", "top")
            dxDrawRectangle(sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom, sh/2-736/2/zoom+178/zoom, 311/zoom, 1, tocolor(86,86,86,ui.alpha))
            local mech=fromJSON(v.mechanicTuning) or {}
            local infos={
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
            local row=ui.scroll[1] and math.floor(exports.px_scroll:dxScrollGetPosition(ui.scroll[1])+1) or 1
            local x=0
            for i=row,row+6 do
                local v=infos[i]
                if(v)then
                    x=x+1
        
                    local sY=(43/zoom)*(x-1)
                    dxDrawImage(sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom, sh/2-736/2/zoom+178/zoom+sY+11/zoom, 311/zoom, 41/zoom, assets.textures[10], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                    dxDrawText(v[1], sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom+12/zoom, sh/2-736/2/zoom+178/zoom+sY+11/zoom-2, 311/zoom+sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom, 41/zoom+sh/2-736/2/zoom+178/zoom+sY+11/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "left", "center")
                    dxDrawText(v[2], sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom+12/zoom, sh/2-736/2/zoom+178/zoom+sY+11/zoom-2, 311/zoom+sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom-12/zoom, 41/zoom+sh/2-736/2/zoom+178/zoom+sY+11/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "right", "center")
                end
            end
        
            -- dol
            dxDrawText("Pozostałe informacje", sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+507/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "left", "top")
            dxDrawRectangle(sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+532/zoom, 311/zoom, 1, tocolor(86,86,86,ui.alpha))
        
            local tune=table.concat(fromJSON(v.tuning), ",")
            local infos={
                {"Tuning wizualny", #tune < 1 and "brak" or tune},
                {"Kolor karoserii", "karo", color},
                {"Kolor świateł", "light", light},
            }
            local last=0
            for i,v in pairs(infos) do
                local sY=last+(25/zoom)*(i-1)
                if(v[2] == "karo")then
                    dxDrawText(v[1]..":", sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+540/zoom+sY, 0, 0, tocolor(165,165,165,ui.alpha), 1, assets.fonts[6], "left", "top", false, false, false, true)
                    dxDrawImage(sw/2-695/2/zoom+17/zoom+dxGetTextWidth(v[1]..":", 1, assets.fonts[6])+14/2/zoom, sh/2-736/2/zoom+540/zoom+sY+5/zoom, 14/zoom, 14/zoom, assets.textures[12], 0, 0, 0, tocolor(v[3][1],v[3][2],v[3][3],ui.alpha))
                    dxDrawImage(sw/2-695/2/zoom+17/zoom+dxGetTextWidth(v[1]..":", 1, assets.fonts[6])+14/2/zoom+20/zoom, sh/2-736/2/zoom+540/zoom+sY+5/zoom, 14/zoom, 14/zoom, assets.textures[12], 0, 0, 0, tocolor(v[3][4],v[3][5],v[3][6],ui.alpha))
                elseif(v[2] == "light")then
                    dxDrawText(v[1]..":", sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+540/zoom+sY, 0, 0, tocolor(165,165,165,ui.alpha), 1, assets.fonts[6], "left", "top", false, false, false, true)
                    dxDrawImage(sw/2-695/2/zoom+17/zoom+dxGetTextWidth(v[1]..":", 1, assets.fonts[6])+14/2/zoom, sh/2-736/2/zoom+540/zoom+sY+5/zoom, 14/zoom, 14/zoom, assets.textures[12], 0, 0, 0, tocolor(v[3][1],v[3][2],v[3][3],ui.alpha))
                else
                    dxDrawText(v[1]..": "..v[2], sw/2-695/2/zoom+17/zoom, sh/2-736/2/zoom+540/zoom+sY, sw/2-695/2/zoom+650/zoom, 0, tocolor(165,165,165,ui.alpha), 1, assets.fonts[6], "left", "top", false, true)
                    if(dxGetTextWidth(v[1]..": "..v[2], 1, assets.fonts[6]) > 650/zoom)then
                        last=20/zoom
                    end
                end
            end

            onClick(sw/2-147/2/zoom, sh/2+275/zoom, 147/zoom, 38/zoom, function()
                ui[2].visible(true)
                setTimer(function()
                    ui[ui.backPanel or 1].visible()
                    ui.drawPanel=ui.backPanel or 1
                    ui[2].info_veh=false
                end, 300, 1)
            end)
        end,

        create=function(id)
            if(ui.panels.animate)then return end

            local ui=ui.panels

            ui.btns[1]=buttons:createButton(sw/2-147/2/zoom, sh/2+275/zoom, 147/zoom, 38/zoom, "WRÓĆ", 0, 9, false, false, ":px_exchange_vehicles/textures/button-back.png", {157,113,50})
            ui.scroll[1]=scroll:dxCreateScroll(sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom+315/zoom, sh/2-736/2/zoom+178/zoom+11/zoom, 4, 4, 0, 7, t, 300/zoom, 0, 1)

            ui.backPanel=id
            ui.animate=true
            ui.alpha=0
            animate(0, 255, "Linear", 250, function(a)
                ui.alpha=a

                buttons:buttonSetAlpha(ui.btns[1], a)
                scroll:dxScrollSetAlpha(ui.scroll[1], a)
            end, function()
                ui.animate=false
            end)
        end,

        visible=function(toggle)
            if(ui.panels.animate)then return end

            local ui=ui.panels
            if(toggle)then
                ui.animate=true
                ui.alpha=255
                animate(255, 0, "Linear", 250, function(a)
                    ui.alpha=a

                    buttons:buttonSetAlpha(ui.btns[1], a)
                    scroll:dxScrollSetAlpha(ui.scroll[1], a)
                end, function()
                    ui.animate=false

                    buttons:destroyButton(ui.btns[1])
                    scroll:dxDestroyScroll(ui.scroll[1])

                    if(ui.drawPanel == 2)then
                        ui.drawPanel=false
                    end
                end)
            else
                ui.animate=true
                ui.alpha=255
                animate(255, 0, "Linear", 250, function(a)
                    ui.alpha=a
                end, function()
                    ui.animate=false

                    ui.btns[1]=buttons:createButton(sw/2-147/2/zoom, sh/2+275/zoom, 147/zoom, 38/zoom, "WRÓĆ", 255, 9, false, false, ":px_exchange_vehicles/textures/button-back.png", {157,113,50})
                    ui.scroll[1]=scroll:dxCreateScroll(sw/2-695/2/zoom+695/zoom-311/zoom-17/zoom+315/zoom, sh/2-736/2/zoom+178/zoom+11/zoom, 4/zoom, 4/zoom, 0, 5, ui.t, 300/zoom, 0, 1)

                    if(ui.drawPanel ~= 2)then
                        ui.drawPanel=2
                    end
                end)
            end
        end,
    },

    [3]={
        myInfo={
            doplata=0,
            selected_veh=false,
            element=false,
        },

        playerInfo={
            doplata=0,
            selected_veh=false,
            element=false,
        },

        render=function(ui)
            if(not ui[3].playerInfo.element or not isElement(ui[3].playerInfo.element))then
                return
            end

            if(not ui[3].myInfo.element or not isElement(ui[3].myInfo.element))then
                return
            end

            local myInfo=ui[3].myInfo
            local playerInfo=ui[3].playerInfo

            local v=ui[2].info_veh

            local myPos={getElementPosition(myInfo.element)}
            local tPos={getElementPosition(playerInfo.element)}
            local dist=getDistanceBetweenPoints3D(myPos[1],myPos[2],myPos[3],tPos[1],tPos[2],tPos[3])
            if(dist > 10)then
                triggerServerEvent("exchange.cancel.offer", resourceRoot, ui[3].myInfo.element)
                ui.destroy_all(ui)
                return
            end

            blur:dxDrawBlur(sw/2-872/2/zoom, sh/2-694/2/zoom, 872/zoom, 694/zoom, tocolor(255,255,255,ui.alpha))
            dxDrawImage(sw/2-872/2/zoom, sh/2-694/2/zoom, 872/zoom, 694/zoom, assets.textures[1], 0, 0, 0, tocolor(255,255,255,ui.alpha))
        
            dxDrawText("Oferta wymiany", sw/2-872/2/zoom, sh/2-694/2/zoom, sw/2-872/2/zoom+872/zoom, sh/2-694/2/zoom+54/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[1], "center", "center")
            dxDrawImage(sw/2-872/2/zoom+872/2/zoom+dxGetTextWidth("Oferta wymiany", 1, assets.fonts[1])/2+10/zoom, sh/2-694/2/zoom+(54-19)/2/zoom, 19/zoom, 19/zoom, assets.textures[2], 0, 0, 0, tocolor(255,255,255,ui.alpha))
        
            dxDrawRectangle(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom, 870/zoom, 1, tocolor(86,86,86,ui.alpha))
        
            local plus=15/zoom
        
            -- lewo
            dxDrawText("Oferta gracza", sw/2-870/2/zoom+21/zoom, sh/2-694/2/zoom+54/zoom+(15/2)/zoom, sw/2-870/2/zoom+21/zoom+392/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+(15/2)/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[2], "center", "center")
            dxDrawImage(sw/2-870/2/zoom+21/zoom+(392/2/zoom)-dxGetTextWidth("Oferta gracza", 1, assets.fonts[2])/2-20/zoom, sh/2-694/2/zoom+54/zoom+(23-13)/2/zoom+(15/2)/zoom, 13/zoom, 13/zoom, assets.textures[3], 0, 0, 0, tocolor(255,255,255,ui.alpha))
            -- player info
            dxDrawImage(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom, 870/2/zoom, 56/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            local av=ui.getPlayerAvatar(ui, getPlayerName(myInfo.element))
            if(av)then
                dxDrawImage(sw/2-870/2/zoom+20/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+(56-32)/2/zoom, 32/zoom, 32/zoom, av, 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            end
            dxDrawText("["..getElementData(myInfo.element, "user:id").."] #d2cc1d"..getPlayerName(myInfo.element), sw/2-870/2/zoom+65/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom, 870/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+56/zoom, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[2], "left", "center", false, false, false, true)
            --dxDrawImage(sw/2-870/2/zoom+350/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+(56-36)/2/zoom, 36/zoom, 36/zoom, assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawText(getElementData(myInfo.element, "user:reputation"), sw/2-870/2/zoom+350/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+(56-36)/2/zoom, 36/zoom+sw/2-870/2/zoom+350/zoom, 36/zoom+sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+(56-36)/2/zoom, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[2], "center", "center")

            -- lista
            ui.row=ui.scroll[1] and math.floor(exports.px_scroll:dxScrollGetPosition(ui.scroll[1])+1) or 1
        
            dxDrawImage(sw/2-870/2/zoom+(435-432)/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+57/zoom, 432/zoom, 22/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawText("ID", sw/2-870/2/zoom+21/zoom+42/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom+57/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            dxDrawText("Pojazd", sw/2-870/2/zoom+21/zoom+108/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom+57/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            dxDrawText("Przebieg", sw/2-870/2/zoom+21/zoom+278/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom+57/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            
            local x=0
            for i = ui.row,ui.row+5 do
                local v=myInfo.vehs[i]
                if(v)then
                    x=x+1
                    local sY=(59/zoom)*(x-1)
                    
                    if(myInfo.selected_veh == i)then
                        dxDrawImage(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 435/zoom, 57/zoom, assets.textures[7], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                        dxDrawRectangle(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom-1+15/zoom+57/zoom, 435/zoom, 1, tocolor(33,147,176,ui.alpha))
                    else
                        dxDrawImage(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 435/zoom, 57/zoom, assets.textures[6], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                        dxDrawRectangle(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom-1+15/zoom, 435/zoom, 1, tocolor(86,86,86,ui.alpha))
                    end
        
                    onClick(sw/2-870/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 435/zoom, 57/zoom, function()
                        if(isMouseInPosition(sw/2-870/2/zoom+435/zoom-18/zoom-(57-18)/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-18)/2/zoom+15/zoom+57/zoom, 18/zoom, 18/zoom) and not ui.animate)then
                            ui[2].info_veh=v
                            ui[3].visible(true)
                            setTimer(function()
                                ui[2].create(3)
                                ui.drawPanel=2
                            end, 300, 1)
                        end
                    end)
                    
                    dxDrawImage(sw/2-870/2/zoom+21/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-12)/2/zoom+15/zoom+57/zoom, 26/zoom, 12/zoom, assets.textures[8], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                    dxDrawText(v.id, sw/2-870/2/zoom+21/zoom+42/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom+57/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[4], "left", "center")
                    dxDrawText(getVehicleNameFromModel(v.model), sw/2-870/2/zoom+21/zoom+108/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom+57/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "left", "center")
                    dxDrawText(string.format("%.1f", v.distance).." #2193b0km", sw/2-870/2/zoom+21/zoom+250/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom+57/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[4], "left", "center", false, false, false, true)
                    dxDrawImage(sw/2-870/2/zoom+435/zoom-18/zoom-(57-18)/2/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-18)/2/zoom+15/zoom+57/zoom, 18/zoom, 18/zoom, assets.textures[9], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                end
            end
        
            -- prawo
            ui.row2=ui.scroll[2] and math.floor(exports.px_scroll:dxScrollGetPosition(ui.scroll[2])+1) or 1
        
            local text="Za twoje"
            dxDrawText(text, sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom, sh/2-694/2/zoom+54/zoom+(15/2)/zoom, sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom+392/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+(15/2)/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[2], "center", "center")
            dxDrawImage(sw/2-870/2/zoom+870/zoom-392/zoom-21/zoom+(392/2/zoom)-dxGetTextWidth(text, 1, assets.fonts[2])/2-20/zoom, sh/2-694/2/zoom+54/zoom+(23-12)/2/zoom+(15/2)/zoom, 10/zoom, 12/zoom, assets.textures[4], 0, 0, 0, tocolor(255,255,255,ui.alpha))
             -- player info
            dxDrawImage(sw/2-870/2/zoom+870/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom, 870/2/zoom, 56/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            local av=ui.getPlayerAvatar(ui, getPlayerName(playerInfo.element))
            if(av)then
                dxDrawImage(sw/2-870/2/zoom+20/zoom+870/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+(56-32)/2/zoom, 32/zoom, 32/zoom, av, 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            end
            dxDrawText("["..getElementData(playerInfo.element, "user:id").."] #d2cc1d"..getPlayerName(playerInfo.element), sw/2-870/2/zoom+65/zoom+870/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom, 870/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+56/zoom, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[2], "left", "center", false, false, false, true)
            --dxDrawImage(sw/2-870/2/zoom+350/zoom+870/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+(56-36)/2/zoom, 36/zoom, 36/zoom, assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawText(getElementData(playerInfo.element, "user:reputation"), sw/2-870/2/zoom+350/zoom+870/2/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+(56-36)/2/zoom, 36/zoom+sw/2-870/2/zoom+350/zoom+870/2/zoom, 36/zoom+sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+(56-36)/2/zoom, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[2], "center", "center")

            -- lista
            dxDrawImage(sw/2-870/2/zoom+(435-432)/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+57/zoom, 432/zoom, 22/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawText("ID", sw/2-870/2/zoom+21/zoom+42/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom+57/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            dxDrawText("Pojazd", sw/2-870/2/zoom+21/zoom+108/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom+57/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            dxDrawText("Przebieg", sw/2-870/2/zoom+21/zoom+278/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+23/zoom+1/zoom+15/zoom+57/zoom, 0, 0, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[3], "left", "top")
            
            local x=0
            for i = ui.row2,ui.row2+5 do
                local v=playerInfo.vehs[i]
                if(v)then
                    x=x+1
                    local sY=(59/zoom)*(x-1)
                    
                    if(playerInfo.selected_veh == i)then
                        dxDrawImage(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 435/zoom, 57/zoom, assets.textures[7], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                        dxDrawRectangle(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom-1+15/zoom+57/zoom, 435/zoom, 1, tocolor(33,147,176,ui.alpha))
                    else
                        dxDrawImage(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 435/zoom, 57/zoom, assets.textures[6], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                        dxDrawRectangle(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom-1+15/zoom+57/zoom, 435/zoom, 1, tocolor(86,86,86,ui.alpha))
                    end
        
                    onClick(sw/2-870/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 435/zoom, 57/zoom, function()
                        if(isMouseInPosition(sw/2-870/2/zoom+435/zoom-18/zoom-(57-18)/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-18)/2/zoom+15/zoom+57/zoom, 18/zoom, 18/zoom) and not ui.animate)then
                            ui[2].info_veh=v
                            ui[3].visible(true)
                            setTimer(function()
                                ui[2].create(3)
                                ui.drawPanel=2
                            end, 300, 1)
                        end
                    end)
                    
                    dxDrawImage(sw/2-870/2/zoom+21/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-12)/2/zoom+15/zoom+57/zoom, 26/zoom, 12/zoom, assets.textures[8], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                    dxDrawText(v.id, sw/2-870/2/zoom+21/zoom+42/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom+57/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[4], "left", "center")
                    dxDrawText(getVehicleNameFromModel(v.model), sw/2-870/2/zoom+21/zoom+108/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom+57/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[5], "left", "center")
                    dxDrawText(string.format("%.1f", v.distance).." #2193b0km", sw/2-870/2/zoom+21/zoom+250/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+15/zoom+57/zoom, 0, sh/2-694/2/zoom+54/zoom+44/zoom+sY+57/zoom+15/zoom+57/zoom, tocolor(200, 200, 200,ui.alpha), 1, assets.fonts[4], "left", "center", false, false, false, true)
                    dxDrawImage(sw/2-870/2/zoom+435/zoom-18/zoom-(57-18)/2/zoom+ 870/zoom-435/zoom, sh/2-694/2/zoom+54/zoom+44/zoom+sY+(57-18)/2/zoom+15/zoom+57/zoom, 18/zoom, 18/zoom, assets.textures[9], 0, 0, 0, tocolor(255,255,255,ui.alpha))
                end
            end
        
            -- srodek
            dxDrawRectangle(sw/2, sh/2-694/2/zoom+54/zoom, 1, 694/zoom-54/zoom-68/zoom, tocolor(86,86,86,ui.alpha))
        
            -- doplaty
            dxDrawRectangle(sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom, 872/zoom, 1, tocolor(86,86,86,ui.alpha))
            dxDrawText("Opcjonalna dopłata", sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+13/zoom, 872/2/zoom+sw/2-872/2/zoom, 1, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[4], "center", "top")
            dxDrawText("Opcjonalna dopłata", sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+13/zoom, 872/zoom+872/2/zoom+sw/2-872/2/zoom, 1, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[4], "center", "top")
        
            local money_1=myInfo.doplata or 0
            local money_2=playerInfo.doplata or 0
            dxDrawText(money_1.."$", sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+25/zoom, 872/2/zoom+sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+13/zoom+68/zoom, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "center", "center")
            dxDrawText(money_2.."$", sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+25/zoom, 872/zoom+872/2/zoom+sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+13/zoom+68/zoom, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "center", "center")
            
            local w=dxGetTextWidth(money_1, 1, assets.fonts[1])+20/zoom
            dxDrawRectangle(sw/2-872/2/zoom+((872/2/zoom)-w)/2, sh/2-694/2/zoom+541/zoom+65/zoom, w, 1, tocolor(93,149,223,ui.alpha))

            local w2=dxGetTextWidth(money_2, 1, assets.fonts[1])+20/zoom
            dxDrawRectangle(sw/2-872/2/zoom+(872/2)/zoom+((872/2)/zoom-w2)/2, sh/2-694/2/zoom+541/zoom+65/zoom, w2, 1, tocolor(93,149,223,ui.alpha))

            -- przyciski
            dxDrawRectangle(sw/2-872/2/zoom, sh/2-694/2/zoom+541/zoom+84/zoom, 872/zoom, 1, tocolor(86,86,86,ui.alpha))     
            
            -- cancel
            onClick(sw/2-147/zoom-10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, function()
                if(SPAM.getSpam())then return end

                ui.destroy(ui)

                triggerServerEvent("exchange.cancel.offer", resourceRoot, ui[3].myInfo.element)
            end)

            -- accept
            onClick(sw/2+10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, function()
                if(SPAM.getSpam())then return end

                ui.destroy(ui)

                triggerServerEvent("exchange.accept.offer", resourceRoot, ui[3].playerInfo, ui[3].myInfo)
            end)
        end,

        visible=function(toggle)
            if(ui.panels.animate)then return end

            local ui=ui.panels

            if(toggle)then
                ui.animate=true
                ui.alpha=255
                animate(255, 0, "Linear", 250, function(a)
                    ui.alpha=a

                    for i,v in pairs(ui.scroll) do
                        scroll:dxScrollSetAlpha(v, a)
                    end
    
                    for i,v in pairs(ui.btns) do
                        buttons:buttonSetAlpha(v, a)
                    end
                end, function()
                    for i,v in pairs(ui.scroll) do
                        scroll:dxDestroyScroll(v)
                    end
    
                    for i,v in pairs(ui.btns) do
                        buttons:destroyButton(v)
                    end
    
                    if(ui.drawPanel == 3)then
                        ui.drawPanel=false
                    end

                    ui.animate=false
                end)
            else
                for i,v in pairs(ui.scroll) do
                    scroll:dxDestroyScroll(v)
                end

                ui.btns[1]=buttons:createButton(sw/2+10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, "ZAAKCEPTUJ", 0, 9, false, false, ":px_exchange_vehicles/textures/button-accept.png")
                ui.btns[2]=buttons:createButton(sw/2-147/zoom-10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, "ODRZUĆ", 0, 9, false, false, ":px_exchange_vehicles/textures/button-close.png", {132,39,39})
    
                ui.scroll[1]=scroll:dxCreateScroll(sw/2-870/2/zoom+435/zoom-4, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+57/zoom+22/zoom, 4/zoom, 4/zoom, 0, 6, ui[3].myInfo.vehs, 371/zoom, 0, 1, {0,0,sw/2,sh})
                ui.scroll[2]=scroll:dxCreateScroll(sw/2-870/2/zoom+435/zoom+435/zoom-4, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+57/zoom+22/zoom, 4/zoom, 4/zoom, 0, 6, ui[3].playerInfo.vehs, 371/zoom, 0, 1, {sw/2, 0, sw, sh})

                ui.animate=true
                ui.alpha=0
                animate(0, 255, "Linear", 250, function(a)
                    ui.alpha=a

                    for i,v in pairs(ui.scroll) do
                        scroll:dxScrollSetAlpha(v, a)
                    end
    
                    for i,v in pairs(ui.btns) do
                        buttons:buttonSetAlpha(v, a)
                    end
                end, function()
                    ui.animate=false

                    if(ui.drawPanel ~= 3)then
                        ui.drawPanel=3
                    end
                end)

                setElementData(localPlayer, 'user:gui_showed', resourceRoot, true)
            end
        end,

        create=function()
            local ui=ui.panels

            ui.animate=true
    
            ui.btns[1]=buttons:createButton(sw/2+10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, "ZAAKCEPTUJ", 0, 9, false, false, ":px_exchange_vehicles/textures/button-accept.png")
            ui.btns[2]=buttons:createButton(sw/2-147/zoom-10/zoom, sh/2+295/zoom, 147/zoom, 38/zoom, "ODRZUĆ", 0, 9, false, false, ":px_exchange_vehicles/textures/button-close.png", {132,39,39})

            ui.alpha=0
            animate(ui.alpha, 255, "Linear", 250, function(a)
                ui.alpha=a

                for i,v in pairs(ui.scroll) do
                    scroll:dxScrollSetAlpha(v, a)
                end

                for i,v in pairs(ui.btns) do
                    buttons:buttonSetAlpha(v, a)
                end
            end, function()
                ui.animate=false
            end)

            setElementData(localPlayer, 'user:gui_showed', resourceRoot, true)
        end,

        trigger=function(name, args1, args2)
            if(name == "get.exchange.info")then
                if(ui.panels.animate or getElementData(localPlayer, 'sell_vehs:offer') or showed or getElementData(args2.element, 'user:gui_showed'))then 
                    triggerServerEvent('off.data', resourceRoot, args1.element)
                    setElementData(localPlayer, 'exchange_vehs:offer', false)
                    return 
                end

                ui.panels.create(3,ui.panels)

                for i,v in pairs(ui.panels.scroll) do
                    scroll:dxDestroyScroll(v)
                end

                ui.panels[3].myInfo=args1
                ui.panels[3].playerInfo=args2

                ui.panels.scroll[1]=scroll:dxCreateScroll(sw/2-870/2/zoom+435/zoom-4, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+57/zoom+22/zoom, 4/zoom, 4/zoom, 0, 6, ui.panels[3].myInfo.vehs, 371/zoom, 0, 1, {0,0,sw/2,sh})
                ui.panels.scroll[2]=scroll:dxCreateScroll(sw/2-870/2/zoom+435/zoom+435/zoom-4, sh/2-694/2/zoom+54/zoom+22/zoom+15/zoom+57/zoom+22/zoom, 4/zoom, 4/zoom, 0, 6, ui.panels[3].playerInfo.vehs, 371/zoom, 0, 1, {sw/2, 0, sw, sh})
            end
        end,
    },

    create=function(id, uis)
        if(ui.panels.animate or getElementData(localPlayer, 'user:gui_showed') or getElementData(localPlayer, "exchange_vehs:offer") or getElementData(localPlayer, 'sell_vehs:offer') or showed)then 
            return 
        end

        editbox = exports.px_editbox
        buttons = exports.px_buttons
        scroll = exports.px_scroll
        avatars=exports.px_avatars
        export=exports.px_custom_vehicles
        noti = exports.px_noti
        blur=exports.blur

        assets.create()
        showCursor(true)
        addEventHandler("onClientRender", root, ui.onRender)
        
        uis.drawPanel=id
        uis[id].create()

        showed=true

        setElementData(localPlayer, 'user:gui_showed', resourceRoot, true)
    end,

    destroy=function(uis)
        if(uis.animate)then return end

        ui.animate=true
        ui.alpha=255
        animate(255, 0, "Linear", 250, function(a)
            uis.alpha=a

            for i,v in pairs(uis.scroll) do
                scroll:dxScrollSetAlpha(v, a)
            end

            for i,v in pairs(uis.btns) do
                buttons:buttonSetAlpha(v, a)
            end

            for i,v in pairs(uis.edits) do
                editbox:dxSetEditAlpha(v, a)
            end
        end, function()
            removeEventHandler("onClientRender", root, ui.onRender)
            assets.destroy()
            showCursor(false)

            ui.animate=false

            showed=false

            for i,v in pairs(uis.scroll) do
                scroll:dxDestroyScroll(v)
            end
    
            for i,v in pairs(uis.btns) do
                buttons:destroyButton(v)
            end
    
            for i,v in pairs(uis.edits) do
                editbox:dxDestroyEdit(v)
            end

            setElementData(localPlayer, 'user:gui_showed', false, false)
        end)
    end,

    destroy_all=function(uis)
        removeEventHandler("onClientRender", root, ui.onRender)
        assets.destroy()
        showCursor(false)

        ui.animate=false

        showed=false

        for i,v in pairs(uis.scroll) do
            scroll:dxDestroyScroll(v)
        end

        for i,v in pairs(uis.btns) do
            buttons:destroyButton(v)
        end

        for i,v in pairs(uis.edits) do
            editbox:dxDestroyEdit(v)
        end

        setElementData(localPlayer, 'user:gui_showed', false, false)
    end,
}

ui.onRender=function()
    local draw=ui.panels[ui.panels.drawPanel]
    if(draw)then
        draw.render(ui.panels)
    end
end

-- triggers

addEvent("exchange.open.ui", true)
addEventHandler("exchange.open.ui", resourceRoot, function(id)
    ui.panels.create(id, ui.panels)
end)

addEvent("get.players.vehicles", true)
addEventHandler("get.players.vehicles", resourceRoot, function(id, ...)
    ui.panels[id].trigger("get.players.vehicles", ...)
end)

addEvent("get.player.vehicles", true)
addEventHandler("get.player.vehicles", resourceRoot, function(id, ...)
    ui.panels[id].trigger("get.player.vehicles", ...)
end)

addEvent("get.exchange.info", true)
addEventHandler("get.exchange.info", resourceRoot, function(id, ...)
    ui.panels[id].trigger("get.exchange.info", ...)
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

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
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

setElementData(localPlayer, "exchange_vehs:offer", false)
setElementData(localPlayer, "user:gui_showed",false, false)