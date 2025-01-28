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

	SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 300, 1)

	return block
end

-- exports

local blur=exports.blur
local edit=exports.px_editbox
local buttons=exports.px_buttons
local noti=exports.px_noti
local preview=exports.object_preview
local avatars=exports.px_avatars
local scroll=exports.px_scroll

-- variables

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 10},
        {":px_assets/fonts/Font-Bold.ttf", 13},
        {":px_assets/fonts/Font-Bold.ttf", 17},
        {":px_assets/fonts/Font-Regular.ttf", 16},
    },

    textures={},
    textures_paths={
        "textures/tablet.png",

        "textures/logo.png",

        "textures/row.png",

        "textures/star_black.png",
        "textures/star.png",

        "textures/gridlist.png",
        "textures/list.png",

        "textures/button_right.png",

        "textures/checkbox.png",
        "textures/checkbox_selected.png",

        "textures/header.png",
        "textures/player_skin_bg.png",
    },
}

--

local ui={}

ui.edits={}
ui.btns={}
ui.scroll=false
ui.scroll_2=false

ui.selected=1
ui.border=false

ui.vehsTbl={}
for i=1,3 do
    local sX=(170/zoom)*(i-1)
    local sX2=(111/zoom)*(i-1)
    for i=1,4 do
        local sY=(37/zoom)*(i-1)
        local sY2=(28/zoom)*(i-1)
        ui.vehsTbl[#ui.vehsTbl+1]={sX=sX,sY=sY,sX2=sX2,sY2=sY2}
    end
end

ui.tariff=false
ui.selectedReport=false
ui.searchPlayer=false
ui.searchVehicle=false

ui.listSelectedVehicle=false
ui.listSelectedPlayer=false

ui.memoElement=false

ui.sqlData={}

ui.mandates={
    {name="Spowodowanie zagrożenia w ruchu lądowym", cost=750},
    {name="Spowodowanie kolizji drogowej", cost=1000},
    {name="Spowodowanie wypadku drogowego", cost=1500},
    {name="Jazda pod prąd", cost=500},
    {name="Jazda po terenie do tego nieprzystosowanym", cost=750},
    {name="Przekroczenie prędkości w terenie zabudowanym", cost=750},
    {name="Przekroczenie prędkości w terenie niezabudowanym", cost=500},
    {name="Zawracanie w miejscu do tego nieprzystosowanym", cost=300},
    {name="Wyprzedzanie w miejscu do tego nieprzystosowanym", cost=300},
    {name="Niezastosowanie się do znaku STOP", cost=500},
    {name="Niezastosowanie się do znaków nakazu i zakazów", cost=300},
    {name="Nieustąpienie pierwszeństwa pojazdowi uprzywilejowanymi", cost=750},
    {name="Nieustąpienie pierwszeństwa innemu uczestnikowi ruchu drogowego", cost=500},
    {name="Przewożenie osób w sposób niewłaściwy", cost=750},
    {name="Zakłócanie porządku publicznego", cost=300},
    {name="Zniewaga funkcjonariusza publicznego", cost=600},
    {name="Niestosowanie się do poleceń funkcjonariusza", cost=900},
    {name="Utrudnianie pracy funkcjonariuszowi publicznemu", cost=1200},
    {name="Posługiwanie się fałszywymi dokumentami", cost=1000},
    {name="Nieumiejętne posługiwanie się numerem alarmowym", cost=1500},
    {name="Próba wręczenia łapówki funkcjonariuszowi publicznemu", cost=1000},
    {name="Niestosowanie się do zasad RP", cost=1500},
    {name="Ucieczka przed departamentem policji do 10 minut, lub po dobrowolnym poddaniu się uciekiniera", cost=1500},
    {name="Wejście na teren zamknięty", cost=300},
    {name="Organizacja, lub branie udziału w proteście, wydarzeniu lub innego rodzaju zbiorowiska o charakterze masowym, niezatwierdzonym przez administrację RCON, lub inne służby mundurowe", cost=1250},
}

ui.options={
    {name="Ogólne", draw=function()
        if(ui.selectedReport)then
            -- destroy
            if(ui.ped)then
                destroyElement(ui.ped)
                ui.ped=false

                preview:destroyObjectPreview(ui.preview)
                ui.preview=false
            end

            if(ui.veh)then
                destroyElement(ui.veh)
                ui.veh=false

                preview:destroyObjectPreview(ui.preview)
                ui.preview=false
            end

            for i=1,2 do
                if(ui.edits[i])then
                    edit:dxDestroyEdit(ui.edits[i])
                    ui.edits[i]=nil
                end
            end

            if(ui.btns[1])then
                buttons:destroyButton(ui.btns[1])
                ui.btns[1]=nil
            end

            if(ui.memoElement)then
                destroyElement(ui.memoElement)
                ui.memoElement=nil
            end
            --

            dxDrawText("ZGŁOSZENIE", sw/2-1138/2/zoom+54/zoom, sh/2-707/2/zoom+89/zoom, 1138/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "top")
            dxDrawText(ui.selectedReport.date, sw/2-1138/2/zoom+54/zoom, sh/2-707/2/zoom+89/zoom, sw/2-1138/2/zoom+54/zoom+1026/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[4], "right", "top")
            dxDrawRectangle(sw/2-1138/2/zoom+54/zoom, sh/2-707/2/zoom+128/zoom, 1026/zoom, 1, tocolor(80,80,80))

            dxDrawText("#909090Lokalizacja: #d9d9d9"..ui.selectedReport.location, sw/2-1138/2/zoom+54/zoom, sh/2-707/2/zoom+150/zoom, 1138/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top", false, false, false, true)
            dxDrawText("#909090Zgłaszający: #d9d9d9"..ui.selectedReport.player, sw/2-1138/2/zoom+54/zoom, sh/2-707/2/zoom+185/zoom, 1138/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top", false, false, false, true)
            dxDrawText("#909090Treść zgłoszenia:", sw/2-1138/2/zoom+54/zoom, sh/2-707/2/zoom+220/zoom, 1138/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top", false, false, false, true)
            dxDrawText(ui.selectedReport.text, sw/2-1138/2/zoom+54/zoom, sh/2-707/2/zoom+255/zoom, sw/2-1138/2/zoom+54/zoom+1026/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top", false, true)
        
            if(not ui.btns[2] and not ui.btns[3] and not ui.btns[4])then
                ui.btns[2]=buttons:createButton(sw/2-1138/2/zoom+54/zoom, sh/2-707/2/zoom+569/zoom, 148/zoom, 39/zoom, "WRÓĆ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_back.png", {154,130,34})
                ui.btns[3]=buttons:createButton(sw/2-1138/2/zoom+221/zoom, sh/2-707/2/zoom+569/zoom, 148/zoom, 39/zoom, "PRZYJMIJ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_icon.png")
                ui.btns[4]=buttons:createButton(sw/2-1138/2/zoom+389/zoom, sh/2-707/2/zoom+569/zoom, 148/zoom, 39/zoom, "USUŃ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_close.png", {160,53,56})
            end

            onClick(sw/2-1138/2/zoom+221/zoom, sh/2-707/2/zoom+569/zoom, 148/zoom, 39/zoom, function()
                local pos=fromJSON(ui.selectedReport.pos) or {0,0,0}
                exports.px_map:setGPSPos(unpack(pos))

                triggerServerEvent("delete.ticket", resourceRoot, ui.selectedReport.id)
                triggerServerEvent("load.tablet.date", resourceRoot)

                ui.selectedReport=false

                for i=2,4 do
                    if(ui.btns[i])then
                        buttons:destroyButton(ui.btns[i])
                        ui.btns[i]=nil
                    end
                end

                if(ui.scroll)then
                    scroll:dxDestroyScroll(ui.scroll)
                    ui.scroll=false
                end

                if(ui.memoElement)then
                    destroyElement(ui.memoElement)
                    ui.memoElement=nil
                end
            end)

            onClick(sw/2-1138/2/zoom+389/zoom, sh/2-707/2/zoom+569/zoom, 148/zoom, 39/zoom, function()
                

                triggerServerEvent("delete.ticket", resourceRoot, ui.selectedReport.id)
                triggerServerEvent("load.tablet.date", resourceRoot)

                ui.selectedReport=false

                for i=2,4 do
                    if(ui.btns[i])then
                        buttons:destroyButton(ui.btns[i])
                        ui.btns[i]=nil
                    end
                end

                if(ui.scroll)then
                    scroll:dxDestroyScroll(ui.scroll)
                    ui.scroll=false
                end

                if(ui.memoElement)then
                    destroyElement(ui.memoElement)
                    ui.memoElement=nil
                end
            end)

            onClick(sw/2-1138/2/zoom+54/zoom, sh/2-707/2/zoom+569/zoom, 148/zoom, 39/zoom, function()
                ui.selectedReport=false

                for i=2,4 do
                    if(ui.btns[i])then
                        buttons:destroyButton(ui.btns[i])
                        ui.btns[i]=nil
                    end
                end

                if(ui.scroll)then
                    scroll:dxDestroyScroll(ui.scroll)
                    ui.scroll=false
                end

                if(ui.memoElement)then
                    destroyElement(ui.memoElement)
                    ui.memoElement=nil
                end
            end)
        else
            -- zgloszenia
            local tickets=ui.sqlData["tickets"]
            if(tickets)then
                if(not ui.scroll)then
                    ui.scroll=scroll:dxCreateScroll(sw/2-1138/2/zoom+67/zoom+412/zoom, sh/2-707/2/zoom+197/zoom, 4/zoom, 4/zoom, 0, 7, tickets, (58*7)/zoom, 255)
                end

                dxDrawText("Zgłoszenia", sw/2-1138/2/zoom+67/zoom, sh/2-707/2/zoom+150/zoom, 1138/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
                dxDrawText(#tickets, sw/2-1138/2/zoom+67/zoom, sh/2-707/2/zoom+150/zoom, sw/2-1138/2/zoom+67/zoom+412/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "right", "top")
                dxDrawRectangle(sw/2-1138/2/zoom+67/zoom, sh/2-707/2/zoom+182/zoom, 412/zoom, 1, tocolor(80,80,80))

                local row=math.floor(scroll:dxScrollGetPosition(ui.scroll))+1
                local k=0
                for i=row,row+6 do
                    local v=tickets[i]
                    if(v)then
                        k=k+1

                        local sY=(58/zoom)*(k-1)
                        dxDrawImage(sw/2-1138/2/zoom+67/zoom, sh/2-707/2/zoom+197/zoom+sY, 412/zoom, 56/zoom, assets.textures[3])
                        dxDrawText("od: "..v.from, sw/2-1138/2/zoom+67/zoom+17/zoom, sh/2-707/2/zoom+197/zoom+sY, 412/zoom, 56/zoom+sh/2-707/2/zoom+197/zoom+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
                        dxDrawText(v.date, sw/2-1138/2/zoom+67/zoom, sh/2-707/2/zoom+197/zoom+sY, sw/2-1138/2/zoom+67/zoom+412/zoom-17/zoom, 56/zoom+sh/2-707/2/zoom+197/zoom+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "right", "center")
                    
                        onClick(sw/2-1138/2/zoom+67/zoom, sh/2-707/2/zoom+197/zoom+sY, 412/zoom, 56/zoom, function()
                            ui.selectedReport={location=v.location, player=v.from, text=v.text, date=v.date, id=v.id, pos=v.pos}

                            if(ui.scroll)then
                                scroll:dxDestroyScroll(ui.scroll)
                                ui.scroll=false
                            end
                        end)
                    end
                end
            end

            -- pojazdy
            local units=ui.sqlData["units"]
            if(units)then
                dxDrawText("Dostepne jednostki", sw/2-1138/2/zoom+570/zoom, sh/2-707/2/zoom+150/zoom, 1138/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
                dxDrawText(#units, sw/2-1138/2/zoom+570/zoom, sh/2-707/2/zoom+150/zoom, sw/2-1138/2/zoom+570/zoom+500/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "right", "top")
                dxDrawRectangle(sw/2-1138/2/zoom+570/zoom, sh/2-707/2/zoom+182/zoom, 500/zoom, 1, tocolor(80,80,80))

                for i,v in pairs(ui.vehsTbl) do
                    local vv=units[i]
                    if(vv)then
                        dxDrawImage(sw/2-1138/2/zoom+570/zoom+v.sX, sh/2-707/2/zoom+197/zoom+v.sY, 165/zoom, 32/zoom, assets.textures[3])
                        dxDrawText(vv, sw/2-1138/2/zoom+570/zoom+v.sX, sh/2-707/2/zoom+197/zoom+v.sY, 165/zoom+sw/2-1138/2/zoom+570/zoom+v.sX, 32/zoom+sh/2-707/2/zoom+197/zoom+v.sY, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")
                    end
                end
            end

            -- poszukiwany
            dxDrawText("Poszukiwany", sw/2-1138/2/zoom+570/zoom, sh/2-707/2/zoom+150/zoom+215/zoom, 1138/zoom, 707/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
            dxDrawRectangle(sw/2-1138/2/zoom+570/zoom, sh/2-707/2/zoom+182/zoom+215/zoom, 500/zoom, 1, tocolor(80,80,80))

            local sql=ui.sqlData["wanted"]
            if(sql)then
                if(not ui.ped)then
                    ui.ped=createPed(sql.skin, 0, 0, 0)
                end

                if(not ui.preview and ui.ped)then
                    ui.preview=preview:createObjectPreview(ui.ped, 0, 0, 210, sw/2-1138/2/zoom+570/zoom, sh/2-707/2/zoom+182/zoom+215/zoom+30/zoom, 150/zoom, 150/zoom, false, true, true)
                end

                local av=avatars:getPlayerAvatar(sql.login)
                if(av)then
                    dxDrawImage(sw/2-1138/2/zoom+570/zoom+183/zoom, sh/2-707/2/zoom+182/zoom+215/zoom+22/zoom, 21/zoom, 21/zoom, av)
                end

                dxDrawText(sql.login, sw/2-1138/2/zoom+570/zoom+183/zoom+31/zoom, sh/2-707/2/zoom+182/zoom+215/zoom+22/zoom, 21/zoom, 21/zoom+sh/2-707/2/zoom+182/zoom+215/zoom+22/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            
                for i=1,5 do
                    local sX=(25/zoom)*(i-1)
                    dxDrawImage(sw/2-1138/2/zoom+570/zoom+183/zoom+sX, sh/2-707/2/zoom+182/zoom+215/zoom+22/zoom+32/zoom, 20/zoom, 20/zoom, i > sql.police_stars and assets.textures[4] or assets.textures[5])
                end

                local wanted=fromJSON(sql.wanted) or {}
                if(wanted.reason and wanted.location)then
                    dxDrawText("Ostatnia lokalizacja: "..wanted.location.."\nPowód: "..wanted.reason, sw/2-1138/2/zoom+570/zoom+183/zoom, sh/2-707/2/zoom+182/zoom+215/zoom+22/zoom+78/zoom, sw/2-1138/2/zoom+570/zoom+183/zoom+31/zoom+280/zoom, 21/zoom+sh/2-707/2/zoom+182/zoom+215/zoom+22/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top", false, true)
                end
            end
        end
    end},

    {name="Pojazdy", draw=function()
        dxDrawText("Pojazdy w pobliżu", sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+153/zoom, 432/zoom+sw/2-1138/2/zoom+86/zoom, 22/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom, sh/2-707/2/zoom+185/zoom-1, 400/zoom, 1, tocolor(80,80,80))

        local sql=ui.sqlData["range_vehs"]
        if(sql)then
            if(not ui.scroll)then
                ui.scroll=scroll:dxCreateScroll(sw/2-1138/2/zoom+86/zoom+433/zoom, sh/2-707/2/zoom+185/zoom, 4/zoom, 4/zoom, 0, 6, sql, (59*6)/zoom+22/zoom, 255)
            end

            dxDrawImage(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 373/zoom, assets.textures[6])
            dxDrawImage(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom, 432/zoom, 22/zoom, assets.textures[7])
            dxDrawText("Model", sw/2-1138/2/zoom+86/zoom+30/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 22/zoom+sh/2-707/2/zoom+185/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            dxDrawText("ID", sw/2-1138/2/zoom+86/zoom+360/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 22/zoom+sh/2-707/2/zoom+185/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            
            local k=0
            local row=math.floor(scroll:dxScrollGetPosition(ui.scroll))+1
            for i=row,row+5 do
                local veh=sql[i]
                if(veh and getElementData(veh, "vehicle:id"))then
                    k=k+1

                    local sY=(59/zoom)*(k-1)
                    dxDrawImage(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 432/zoom, 57/zoom, assets.textures[3])

                    if(ui.listSelectedVehicle == sql[i])then
                        dxDrawRectangle(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom-1, 432/zoom, 1, tocolor(33,147,176))
                    else
                        dxDrawRectangle(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom-1, 432/zoom, 1, tocolor(80,80,80))
                    end

                    dxDrawText(getVehicleName(sql[i]), sw/2-1138/2/zoom+86/zoom+30/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
                    dxDrawText((getElementData(sql[i], "vehicle:id") or 0), sw/2-1138/2/zoom+86/zoom+360/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
                
                    onClick(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 432/zoom, 57/zoom, function()
                        ui.listSelectedVehicle=sql[i]
                    end)
                end
            end
        end

        if(ui.listSelectedVehicle and isElement(ui.listSelectedVehicle))then
            local v=ui.listSelectedVehicle

            dxDrawText("Informacje", sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom, sh/2-707/2/zoom+153/zoom, sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom+400/zoom, 22/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "top")
            dxDrawRectangle(sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom, sh/2-707/2/zoom+185/zoom-1, 400/zoom, 1, tocolor(80,80,80))

            local info={
                {"ID", getElementData(v, "vehicle:id") or 0},
                {"Model", getVehicleName(v)},
                {"Właściciel", getElementData(v, "vehicle:ownerName") or "brak"},
            }
            for i,v in pairs(info) do
                local sY=(61/zoom)*(i-1)
                dxDrawText(v[1], sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom, sh/2-707/2/zoom+200/zoom+sY, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
                dxDrawText(v[2], sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom, sh/2-707/2/zoom+200/zoom+20/zoom+sY, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
            end
        end
    end},

    {name="Mandaty", draw=function()
        dxDrawText("Gracze w pobliżu", sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+153/zoom, 432/zoom+sw/2-1138/2/zoom+86/zoom, 22/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom, sh/2-707/2/zoom+185/zoom-1, 400/zoom, 1, tocolor(80,80,80))

        local s_player=false
        local sql=ui.sqlData["range_players"]
        if(sql)then
            if(not ui.scroll)then
                ui.scroll=scroll:dxCreateScroll(sw/2-1138/2/zoom+86/zoom+433/zoom, sh/2-707/2/zoom+185/zoom, 4/zoom, 4/zoom, 0, 6, sql, (59*6)/zoom+22/zoom, 255)
            end
            
            dxDrawImage(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 373/zoom, assets.textures[6])
            dxDrawImage(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom, 432/zoom, 22/zoom, assets.textures[7])
            dxDrawText("Nick", sw/2-1138/2/zoom+86/zoom+30/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 22/zoom+sh/2-707/2/zoom+185/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            dxDrawText("ID", sw/2-1138/2/zoom+86/zoom+360/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 22/zoom+sh/2-707/2/zoom+185/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            
            local k=0
            local row=math.floor(scroll:dxScrollGetPosition(ui.scroll))+1
            for i=row,row+5 do
                local player=sql[i]
                if(player and player ~= localPlayer)then
                    k=k+1

                    local sY=(59/zoom)*(k-1)
                    dxDrawImage(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 432/zoom, 57/zoom, assets.textures[3])
                    if(ui.listSelectedPlayer == player)then
                        dxDrawRectangle(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom-1, 432/zoom, 1, tocolor(33,147,176))
                        s_player=player
                    else
                        dxDrawRectangle(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom-1, 432/zoom, 1, tocolor(80,80,80))
                    end

                    dxDrawText(getPlayerName(player), sw/2-1138/2/zoom+86/zoom+30/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
                    dxDrawText(getElementData(player, "user:id"), sw/2-1138/2/zoom+86/zoom+360/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
                
                    onClick(sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 432/zoom, 57/zoom, function()
                        ui.listSelectedPlayer=player
                    end)
                end
            end
        end

        -- right
        dxDrawText("Taryfikator", sw/2-1138/2/zoom+86/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+153/zoom, 432/zoom+sw/2-1138/2/zoom+86/zoom+57/zoom+433/zoom, 22/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+185/zoom-1, 400/zoom, 1, tocolor(80,80,80))

        if(not ui.scroll_2)then
            ui.scroll_2=scroll:dxCreateScroll(sw/2-1138/2/zoom+86/zoom+57/zoom+433/zoom+433/zoom, sh/2-707/2/zoom+185/zoom, 4/zoom, 4/zoom, 0, 6, ui.mandates, (59*6)/zoom+22/zoom, 255)
        end

        dxDrawImage(sw/2-1138/2/zoom+86/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 373/zoom, assets.textures[6])
        dxDrawImage(sw/2-1138/2/zoom+86/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+185/zoom, 432/zoom, 22/zoom, assets.textures[7])
        dxDrawText("Powód", sw/2-1138/2/zoom+86/zoom+54/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 22/zoom+sh/2-707/2/zoom+185/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
        dxDrawText("Kwota", sw/2-1138/2/zoom+86/zoom+360/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 22/zoom+sh/2-707/2/zoom+185/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
        
        local reason=""
        local cost=0

        local k=0
        local row=math.floor(scroll:dxScrollGetPosition(ui.scroll_2))+1
        for i=row,row+5 do
            local v=ui.mandates[i]
            if(v)then
                k=k+1

                local sY=(59/zoom)*(k-1)
                dxDrawImage(sw/2-1138/2/zoom+86/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 432/zoom, 57/zoom, assets.textures[3])
                dxDrawRectangle(sw/2-1138/2/zoom+86/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom-1, 432/zoom, 1, tocolor(80, 80, 80))
                dxDrawImage(sw/2-1138/2/zoom+86/zoom+57/zoom+433/zoom+5/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+(57-42)/2/zoom, 42/zoom, 42/zoom, v.selected and assets.textures[10] or assets.textures[9])
                dxDrawText(v.name, sw/2-1138/2/zoom+86/zoom+54/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, sw/2-1138/2/zoom+86/zoom+54/zoom+57/zoom+433/zoom+280/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center", false, true)
                dxDrawText(v.cost.."$", sw/2-1138/2/zoom+86/zoom+360/zoom+57/zoom+433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            
                onClick(sw/2-1138/2/zoom+86/zoom+57/zoom+433/zoom+5/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+(57-42)/2/zoom, 42/zoom, 42/zoom, function()
                    v.selected=not v.selected
                end)

                if(v.selected)then
                    reason=#reason > 0 and reason..", "..v.name or v.name
                    cost=cost+v.cost
                end
            end
        end

        if(not ui.btns[1])then
            ui.btns[1]=buttons:createButton(sw/2-200/2/zoom, sh/2-707/2/zoom+585/zoom, 200/zoom, 39/zoom, "WYSTAW MANDAT", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_icon.png")
        end

        onClick(sw/2-148/2/zoom, sh/2-707/2/zoom+585/zoom, 148/zoom, 39/zoom, function()
            if(#reason > 0 and cost > 0 and s_player)then
                

                triggerServerEvent("take.mandate", resourceRoot, s_player, reason, cost)
            end
        end)
    end},
}

--

ui.onRender=function()
    dxDrawImage(sw/2-1138/2/zoom, sh/2-707/2/zoom, 1138/zoom, 707/zoom, assets.textures[1])

    -- taryfikator
    if(ui.tariff)then
        dxDrawText("Taryfikator", sw/2-1138/2/zoom, sh/2-707/2/zoom+140/zoom, sw/2-1138/2/zoom+1138/zoom, 22/zoom, tocolor(200, 200, 200), 1, assets.fonts[4], "center", "top")
        dxDrawRectangle(sw/2-400/2/zoom, sh/2-707/2/zoom+185/zoom-1, 400/zoom, 1, tocolor(80,80,80))

        if(not ui.scroll)then
            ui.scroll=scroll:dxCreateScroll(sw/2-433/2/zoom+433/zoom, sh/2-707/2/zoom+185/zoom, 4/zoom, 4/zoom, 0, 6, ui.mandates, (59*6)/zoom+22/zoom, 255)
        end

        dxDrawImage(sw/2-433/2/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 373/zoom, assets.textures[6])
        dxDrawImage(sw/2-433/2/zoom, sh/2-707/2/zoom+185/zoom, 432/zoom, 22/zoom, assets.textures[7])
        dxDrawText("Powód", sw/2-433/2/zoom+57/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 22/zoom+sh/2-707/2/zoom+185/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
        dxDrawText("Kwota", sw/2-433/2/zoom+57/zoom+300/zoom, sh/2-707/2/zoom+185/zoom, 433/zoom, 22/zoom+sh/2-707/2/zoom+185/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
        
        local reason=""
        local cost=0

        local k=0
        local row=math.floor(scroll:dxScrollGetPosition(ui.scroll))+1
        for i=row,row+5 do
            local v=ui.mandates[i]
            if(v)then
                k=k+1

                local sY=(59/zoom)*(k-1)
                dxDrawImage(sw/2-433/2/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 432/zoom, 57/zoom, assets.textures[3])
                dxDrawRectangle(sw/2-433/2/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom-1, 432/zoom, 1, tocolor(80, 80, 80))
                dxDrawImage(sw/2-433/2/zoom+5/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+(57-42)/2/zoom, 42/zoom, 42/zoom, v.selected and assets.textures[10] or assets.textures[9])
                dxDrawText(v.name, sw/2-433/2/zoom+57/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
                dxDrawText(v.cost.."$", sw/2-433/2/zoom+57/zoom+300/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY, 433/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+57/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            
                onClick(sw/2-433/2/zoom+5/zoom, sh/2-707/2/zoom+185/zoom+22/zoom+sY+(57-42)/2/zoom, 42/zoom, 42/zoom, function()
                    v.selected=not v.selected
                end)

                if(v.selected)then
                    reason=#reason > 0 and reason..", "..v.name or v.name
                    cost=cost+v.cost
                end
            end
        end

        if(not ui.btns[1] and not ui.btns[2])then
            ui.btns[1]=buttons:createButton(sw/2-148/zoom-10/zoom, sh/2-707/2/zoom+585/zoom, 148/zoom, 39/zoom, "WRÓĆ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_back.png", {154,130,34})
            ui.btns[2]=buttons:createButton(sw/2+10/zoom, sh/2-707/2/zoom+585/zoom, 148/zoom, 39/zoom, "WYSTAW", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_icon.png")
        end

        onClick(sw/2-148/zoom-10/zoom, sh/2-707/2/zoom+585/zoom, 148/zoom, 39/zoom, function()
            ui.searchPlayer=ui.tariff
            ui.tariff=false

            for i,v in pairs(ui.btns) do
                buttons:destroyButton(v)
                ui.btns[i]=nil
            end

            if(ui.scroll)then
                scroll:dxDestroyScroll(ui.scroll)
                ui.scroll=false
            end

            if(ui.memoElement)then
                destroyElement(ui.memoElement)
                ui.memoElement=nil
            end
        end)
        onClick(sw/2+10/zoom, sh/2-707/2/zoom+585/zoom, 148/zoom, 39/zoom, function()
            if(#reason > 0 and cost > 0)then
                
                triggerServerEvent("take.mandate", resourceRoot, ui.tariff, reason, cost)
            end
        end)
    elseif(ui.searchPlayer)then
        dxDrawRectangle(sw/2-1138/2/zoom+(1138-1026)/2/zoom, sh/2-707/2/zoom+134/zoom, 1026/zoom, 1, tocolor(80,80,80))
        dxDrawImage(sw/2-1138/2/zoom+(1138-1026)/2/zoom, sh/2-707/2/zoom+134/zoom, 1026/zoom, 56/zoom, assets.textures[11])
        dxDrawText("Akta gracza "..ui.searchPlayer.login, sw/2-1138/2/zoom+(1138-1026)/2/zoom, sh/2-707/2/zoom+134/zoom, 1026/zoom+sw/2-1138/2/zoom+(1138-1026)/2/zoom, 56/zoom+sh/2-707/2/zoom+134/zoom, tocolor(200, 200, 200), 1, assets.fonts[4], "center", "center")
   
        dxDrawImage(sw/2-1138/2/zoom+(1138-1026)/2/zoom, sh/2-707/2/zoom+220/zoom, 127/zoom, 148/zoom, assets.textures[12])
        
        if(not ui.ped)then
            ui.ped=createPed(ui.searchPlayer.skin, 0, 0, 0)
        end

        if(not ui.preview and ui.ped)then
            ui.preview=preview:createObjectPreview(ui.ped, 0, 0, 210, sw/2-1138/2/zoom+(1138-1026)/2/zoom, sh/2-707/2/zoom+220/zoom, 127/zoom, 148/zoom, false, true, true)
        end

        -- lewo
        dxDrawText("Podstawowe informacje", sw/2-1138/2/zoom+212/zoom, sh/2-707/2/zoom+220/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+212/zoom, sh/2-707/2/zoom+250/zoom, 317/zoom, 1, tocolor(80,80,80))
        
        local player=getPlayerFromName(ui.searchPlayer.login)
        local licenses=fromJSON(ui.searchPlayer.licenses) or {}
        local lic=""
        for i,v in pairs(licenses) do
            if(v == 2)then
                lic=#lic > 0 and lic..", "..i or i
            elseif(i == 'broń palna')then
                lic=#lic > 0 and lic..", "..i or i
            end
        end

        local wanted=fromJSON(ui.searchPlayer.wanted) or {}
        local info={
            {"Nick", ui.searchPlayer.login},
            {"ID", player and getElementData(player, "user:id") or "OFFLINE"},
            {"Licencje", #lic > 0 and lic or "brak"},
            {"Ostatnio online", player and "teraz" or ui.searchPlayer.lastlogin},
            {"Stopień poszukiwania", "stars"},
            {"Poszukiwany", (wanted and wanted.reason and wanted.reason) or "Brak"},
        }
        for i,v in pairs(info) do
            local sY=(23/zoom)*(i-1)
            if(v[2] == "stars")then
                dxDrawText("#909090"..v[1]..":", sw/2-1138/2/zoom+212/zoom, sh/2-707/2/zoom+255/zoom+sY, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top", false, false, false, true)
                for i=1,5 do
                    local sX=(25/zoom)*(i-1)
                    dxDrawImage(sw/2-1138/2/zoom+212/zoom+sX+dxGetTextWidth(v[1]..":", 1, assets.fonts[1])+10/zoom, sh/2-707/2/zoom+255/zoom+sY, 20/zoom, 20/zoom, i > ui.searchPlayer.police_stars and assets.textures[4] or assets.textures[5])
                end
            else
                dxDrawText("#909090"..v[1]..":#d9d9d9 "..v[2], sw/2-1138/2/zoom+212/zoom, sh/2-707/2/zoom+255/zoom+sY, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top", false, false, false, true)
            end
        end

        -- prawo
        dxDrawText("Posiadane pojazdy", sw/2-1138/2/zoom+212/zoom+400/zoom, sh/2-707/2/zoom+220/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+212/zoom+400/zoom, sh/2-707/2/zoom+250/zoom, 317/zoom, 1, tocolor(80,80,80))
        
        local x=0
        for i=1,12 do
            local v=ui.searchPlayer.vehs[i]
            if(v)then
                x=x+1

                local k=ui.vehsTbl[x]
                dxDrawText("#909090"..v.id.." #d9d9d9"..getVehicleNameFromModel(v.model), sw/2-1138/2/zoom+212/zoom+400/zoom+k.sX2, sh/2-707/2/zoom+250/zoom+14/zoom+k.sY2, 93/zoom+sw/2-1138/2/zoom+212/zoom+400/zoom+k.sX2, 25/zoom+sh/2-707/2/zoom+250/zoom+14/zoom+k.sY2, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center", false, false, false, true)
            end
        end

        dxDrawText("Nadaj status poszukiwanego", sw/2-1138/2/zoom+212/zoom+400/zoom, sh/2-707/2/zoom+220/zoom+170/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+212/zoom+400/zoom, sh/2-707/2/zoom+250/zoom+170/zoom, 317/zoom, 1, tocolor(80,80,80))
        if(not ui.edits[3])then
            ui.edits[3]=edit:dxCreateEdit("Wprowadź powód", sw/2-1138/2/zoom+212/zoom+400/zoom, sh/2-707/2/zoom+250/zoom+170/zoom+20/zoom, 261/zoom, 30/zoom, false, 11/zoom, 255, false, false)
        end
        if(not ui.btns[1])then
            ui.btns[1]=buttons:createButton(sw/2-1138/2/zoom+212/zoom+400/zoom, sh/2-707/2/zoom+250/zoom+170/zoom+20/zoom+50/zoom, 148/zoom, 39/zoom, "NADAJ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_icon.png")
        end
        if(not ui.btns[5])then
            ui.btns[5]=buttons:createButton(sw/2-1138/2/zoom+212/zoom+400/zoom+170/zoom, sh/2-707/2/zoom+250/zoom+170/zoom+20/zoom+50/zoom, 148/zoom, 39/zoom, "ZDEJMIJ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_icon.png")
        end

        -- dol
        dxDrawText("Notatki", sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+401/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+431/zoom, 317/zoom, 1, tocolor(80,80,80))

        dxDrawRectangle(sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+437/zoom, 500/zoom, 120/zoom, tocolor(30,30,30,200))
        dxDrawRectangle(sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+437/zoom+120/zoom-1, 500/zoom, 1, tocolor(90,90,90))

        if(not ui.memoElement)then
            local desc=#ui.searchPlayer.sapd_notebook > 0 and ui.searchPlayer.sapd_notebook or 'brak notatki'
            ui.memoElement=exports['dgs-master']:dgsCreateMemo(sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+437/zoom, 500/zoom, 120/zoom, desc, false, false, tocolor(150,150,150,255), 1, 1, false, tocolor(0,0,0,0))
            exports['dgs-master']:dgsSetPostGUI(ui.memoElement,true)     
            exports['dgs-master']:dgsSetFont(ui.memoElement,assets.fonts[1])
            exports['dgs-master']:dgsMemoSetWordWrapState(ui.memoElement,1)
            exports['dgs-master']:dgsMemoSetMaxLength(ui.memoElement,300)
        end

        if(not ui.btns[6])then
            ui.btns[6]=buttons:createButton(sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+578/zoom, 148/zoom, 39/zoom, "ZAPISZ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_icon.png")
        else
            onClick(sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+578/zoom, 148/zoom, 39/zoom, function()
                local text=exports['dgs-master']:dgsGetText(ui.memoElement) or ''
                if(#text > 0)then
                    triggerServerEvent("set.notebook", resourceRoot, ui.searchPlayer.id, text)
                end
            end)
        end
        --[[dxDrawText("Aktywne kary", sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+401/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+431/zoom, 317/zoom, 1, tocolor(80,80,80))
        
        local k=0
        local punish=ui.searchPlayer.punish
        for i=1,8 do
            local v=punish[i]
            if(v)then
                k=k+1

                local sY=(23/zoom)*(k-1)
                dxDrawText(v.reason, sw/2-1138/2/zoom+57/zoom, sh/2-707/2/zoom+437/zoom+sY, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top", false, false, false, true)
            end
        end]]

        -- center
        if(not ui.btns[2])then
            ui.btns[2]=buttons:createButton(sw/2-167/zoom-100/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, "WRÓĆ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_back.png", {154,130,34})
        end

        if(not ui.btns[3])then
            ui.btns[3]=buttons:createButton(sw/2-167/2/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, "ZLOKALIZUJ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_icon.png")
        end
        if(not ui.btns[4])then
            ui.btns[4]=buttons:createButton(sw/2+100/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, "WYSTAW MANDAT", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_icon.png")
        end

        onClick(sw/2-1138/2/zoom+212/zoom+400/zoom, sh/2-707/2/zoom+250/zoom+170/zoom+20/zoom+50/zoom, 148/zoom, 39/zoom, function()
            local text=edit:dxGetEditText(ui.edits[3]) or ""
            if(#text > 0)then
                local location="offline"
                if(player)then
                    local pos={getElementPosition(player)}
                    location=getZoneName(pos[1],pos[2],pos[3],true)..", "..getZoneName(pos[1],pos[2],pos[3],false)
                end
                triggerServerEvent("set.wanted", resourceRoot, ui.searchPlayer.id, text, location)
            end
        end)

        onClick(sw/2-1138/2/zoom+212/zoom+400/zoom+170/zoom, sh/2-707/2/zoom+250/zoom+170/zoom+20/zoom+50/zoom, 148/zoom, 39/zoom, function()
            triggerServerEvent("set.wanted", resourceRoot, ui.searchPlayer.id)
        end)

        onClick(sw/2-167/zoom-100/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, function()
            ui.searchPlayer=false

            if(ui.ped)then
                destroyElement(ui.ped)
                ui.ped=false

                preview:destroyObjectPreview(ui.preview)
                ui.preview=false
            end

            for i,v in pairs(ui.btns) do
                buttons:destroyButton(v)
                ui.btns[i]=nil
            end

            if(ui.edits[3])then
                edit:dxDestroyEdit(ui.edits[3])
                ui.edits[3]=nil
            end

            if(ui.memoElement)then
                destroyElement(ui.memoElement)
                ui.memoElement=nil
            end
        end)

        onClick(sw/2-167/2/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, function()
            if(player)then
                local x,y,z=getElementPosition(player)
                exports.px_map:setGPSPos(x,y,z)
                noti:noti("Pomyślnie namierzono gracza.", "success")
            else
                noti:noti("Podany gracz nie jest aktualnie na serwerze.", "error")
            end
        end)

        onClick(sw/2+100/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, function()
            ui.tariff=ui.searchPlayer
            ui.searchPlayer=false

            if(ui.ped)then
                destroyElement(ui.ped)
                ui.ped=false

                preview:destroyObjectPreview(ui.preview)
                ui.preview=false
            end

            for i,v in pairs(ui.btns) do
                buttons:destroyButton(v)
                ui.btns[i]=nil
            end

            if(ui.edits[3])then
                edit:dxDestroyEdit(ui.edits[3])
                ui.edits[3]=nil
            end

            if(ui.memoElement)then
                destroyElement(ui.memoElement)
                ui.memoElement=nil
            end
        end)
        --
    elseif(ui.searchVehicle)then
        if(not ui.veh)then
            ui.veh=createVehicle(ui.searchVehicle.model, 0, 0, 0)
        end

        if(not ui.preview and ui.veh)then
            ui.preview=preview:createObjectPreview(ui.veh, 0, 0, 210, sw/2-1138/2/zoom+(1138-1026)/2/zoom, sh/2-707/2/zoom+100/zoom, 400/zoom, 400/zoom, false, true, true)
        end

        dxDrawText("Pojazd", sw/2-1138/2/zoom+86/zoom, sh/2-707/2/zoom+153/zoom, 432/zoom+sw/2-1138/2/zoom+86/zoom, 22/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom, sh/2-707/2/zoom+185/zoom-1, 400/zoom, 1, tocolor(80,80,80))

        dxDrawText("Informacje", sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom, sh/2-707/2/zoom+153/zoom, sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom+400/zoom, 22/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "top")
        dxDrawRectangle(sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom, sh/2-707/2/zoom+185/zoom-1, 400/zoom, 1, tocolor(80,80,80))

        local info={
            {"ID", ui.searchVehicle.id},
            {"Model", getVehicleNameFromModel(ui.searchVehicle.model)},
            {"Właściciel", ui.searchVehicle.ownerName},
        }
        for i,v in pairs(info) do
            local sY=(61/zoom)*(i-1)
            dxDrawText(v[1], sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom, sh/2-707/2/zoom+200/zoom+sY, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
            dxDrawText(v[2], sw/2-1138/2/zoom+86/zoom+(433-400)/2/zoom+540/zoom, sh/2-707/2/zoom+200/zoom+20/zoom+sY, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
        end

        dxDrawImage(sw/2-1138/2/zoom+1138/zoom-326/zoom+261/zoom-30/zoom, sh/2-707/2/zoom+69/zoom, 30/zoom, 30/zoom, assets.textures[8])
        dxDrawImage(sw/2-1138/2/zoom+1138/zoom-326/zoom-294/zoom+261/zoom-30/zoom, sh/2-707/2/zoom+69/zoom, 30/zoom, 30/zoom, assets.textures[8])
    
        -- center
        if(not ui.btns[1])then
            ui.btns[1]=buttons:createButton(sw/2-167/zoom-5/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, "WRÓĆ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_back.png", {154,130,34})
        end
        
        if(not ui.btns[2])then
            ui.btns[2]=buttons:createButton(sw/2+5/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, "ZLOKALIZUJ", 255, 10/zoom, false, false, ":px_factions-tablet/textures/button_icon.png")
        end
        --

        onClick(sw/2-167/zoom-5/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, function()
            ui.searchVehicle=false

            for i,v in pairs(ui.btns) do
                buttons:destroyButton(v)
                ui.btns[i]=nil
            end

            if(ui.veh)then
                destroyElement(ui.veh)
                ui.veh=false

                preview:destroyObjectPreview(ui.preview)
                ui.preview=false
            end

            if(ui.memoElement)then
                destroyElement(ui.memoElement)
                ui.memoElement=nil
            end
        end)
        
        onClick(sw/2+5/zoom, sh/2-707/2/zoom+578/zoom, 167/zoom, 40/zoom, function()
            local exist=false
            for i,v in pairs(getElementsByType("vehicle")) do
                if(getElementData(v, "vehicle:id") == ui.searchVehicle.id)then
                    local x,y,z=getElementPosition(v)
                    exports.px_map:setGPSPos(x,y,z)
                    noti:noti("Pomyślnie namierzono pojazd.", "success")

                    exist=true
                    break
                end
            end

            if(not exist)then
                noti:noti("Nie znaleziono podanego pojazdu na mapie.", "error")
            end

            ui.searchVehicle=false

            for i,v in pairs(ui.btns) do
                buttons:destroyButton(v)
                ui.btns[i]=nil
            end

            if(ui.veh)then
                destroyElement(ui.veh)
                ui.veh=false

                preview:destroyObjectPreview(ui.preview)
                ui.preview=false
            end

            if(ui.memoElement)then
                destroyElement(ui.memoElement)
                ui.memoElement=nil
            end
        end)
    end
    --

    if(not ui.selectedReport)then
        if(not ui.edits[1])then
            ui.edits[1]=edit:dxCreateEdit("Wyszukaj gracza", sw/2-1138/2/zoom+1138/zoom-326/zoom, sh/2-707/2/zoom+69/zoom, 261/zoom, 30/zoom, false, 11/zoom, 255, false, false, ":px_factions-tablet/textures/search_icon.png")
        end
        
        if(not ui.edits[2])then
            ui.edits[2]=edit:dxCreateEdit("Wyszukaj pojazd", sw/2-1138/2/zoom+1138/zoom-326/zoom-294/zoom, sh/2-707/2/zoom+69/zoom, 261/zoom, 30/zoom, false, 11/zoom, 255, false, false, ":px_factions-tablet/textures/search_icon.png")
        end

        dxDrawImage(sw/2-1138/2/zoom+1138/zoom-326/zoom+261/zoom-30/zoom, sh/2-707/2/zoom+69/zoom, 30/zoom, 30/zoom, assets.textures[8])
        dxDrawImage(sw/2-1138/2/zoom+1138/zoom-326/zoom-294/zoom+261/zoom-30/zoom, sh/2-707/2/zoom+69/zoom, 30/zoom, 30/zoom, assets.textures[8])
        onClick(sw/2-1138/2/zoom+1138/zoom-326/zoom+261/zoom-30/zoom, sh/2-707/2/zoom+69/zoom, 30/zoom, 30/zoom, function()
            

            local text=edit:dxGetEditText(ui.edits[1]) or ""
            if(#text > 0 and not ui.searchPlayer)then
                triggerServerEvent("get.player", resourceRoot, text)
            end
        end)
        onClick(sw/2-1138/2/zoom+1138/zoom-326/zoom-294/zoom+261/zoom-30/zoom, sh/2-707/2/zoom+69/zoom, 30/zoom, 30/zoom, function()
            

            local text=edit:dxGetEditText(ui.edits[2]) or ""
            if(#text > 0 and not ui.searchVehicle)then
                triggerServerEvent("get.vehicle", resourceRoot, text)
            end
        end)

        dxDrawImage(sw/2-1138/2/zoom+66/zoom, sh/2-707/2/zoom+66/zoom, 50/zoom, 50/zoom, assets.textures[2])

        local lW=0
        for i,v in pairs(ui.options) do
            local w=dxGetTextWidth(v.name, 1, assets.fonts[1])
            dxDrawText(v.name, sw/2-1138/2/zoom+66/zoom+50/zoom+35/zoom+lW, sh/2-707/2/zoom+66/zoom, sw/2-1138/2/zoom+66/zoom+50/zoom+35/zoom+w+lW, 50/zoom+sh/2-707/2/zoom+66/zoom, tocolor(150, 150, 150), 1, assets.fonts[1], "center", "center")
            
            if(not ui.border)then
                ui.border={sw/2-1138/2/zoom+66/zoom+50/zoom+35/zoom+lW-5/zoom,w+10/zoom}
            end

            onClick(sw/2-1138/2/zoom+66/zoom+50/zoom+35/zoom+lW-5/zoom, sh/2-707/2/zoom+66/zoom, w+10/zoom, 42/zoom, function()
                if(ui.animate or ui.searchPlayer or ui.searchVehicle or ui.tariff)then return end

                ui.animate=true
                animate(ui.border[1], (sw/2-1138/2/zoom+66/zoom+50/zoom+35/zoom+lW-5/zoom), "Linear", 200, function(a)
                    ui.border[1]=a
                end, function()
                    if(ui.ped)then
                        destroyElement(ui.ped)
                        ui.ped=false

                        preview:destroyObjectPreview(ui.preview)
                        ui.preview=false
                    end

                    if(ui.veh)then
                        destroyElement(ui.veh)
                        ui.veh=false

                        preview:destroyObjectPreview(ui.preview)
                        ui.preview=false
                    end

                    for i,v in pairs(ui.btns) do
                        buttons:destroyButton(ui.btns[i])
                        ui.btns[i]=false
                    end

                    if(ui.scroll)then
                        scroll:dxDestroyScroll(ui.scroll)
                        ui.scroll=false
                    end

                    if(ui.scroll_2)then
                        scroll:dxDestroyScroll(ui.scroll_2)
                        ui.scroll_2=false
                    end

                    if(ui.memoElement)then
                        destroyElement(ui.memoElement)
                        ui.memoElement=nil
                    end

                    ui.selected=i
                    ui.animate=false
                end)
                animate(ui.border[2], (w+10/zoom), "Linear", 200, function(a)
                    ui.border[2]=a
                end)
            end)

            lW=lW+w+50/zoom
        end

        dxDrawRectangle(ui.border[1], 42/zoom+sh/2-707/2/zoom+66/zoom, ui.border[2], 1, tocolor(33,147,176))
    end

    if(not ui.searchVehicle and not ui.searchPlayer and not ui.tariff)then
        ui.options[ui.selected].draw()
    end
end

bindKey("F5", "down", function()
    if(getElementData(localPlayer, "user:gui_showed") == resourceRoot)then
        blur=exports.blur
        edit=exports.px_editbox
        buttons=exports.px_buttons
        noti=exports.px_noti
        preview=exports.object_preview
        avatars=exports.px_avatars
        scroll=exports.px_scroll

        assets.destroy()
    
        removeEventHandler("onClientRender",root,ui.onRender)
    
        showCursor(false)
    
        setElementData(localPlayer, "user:gui_showed", false, false)

        if(ui.ped)then
            destroyElement(ui.ped)
            ui.ped=false

            preview:destroyObjectPreview(ui.preview)
            ui.preview=false
        end

        if(ui.veh)then
            destroyElement(ui.veh)
            ui.veh=false

            preview:destroyObjectPreview(ui.preview)
            ui.preview=false
        end

        for i,v in pairs(ui.edits) do
            edit:dxDestroyEdit(ui.edits[i])
            ui.edits[i]=false
        end

        for i,v in pairs(ui.btns) do
            buttons:destroyButton(ui.btns[i])
            ui.btns[i]=false
        end

        if(ui.scroll)then
            scroll:dxDestroyScroll(ui.scroll)
            ui.scroll=false
        end

        if(ui.scroll_2)then
            scroll:dxDestroyScroll(ui.scroll_2)
            ui.scroll_2=false
        end

        if(ui.memoElement)then
            destroyElement(ui.memoElement)
            ui.memoElement=nil
        end

        guiSetInputEnabled(false)
    else
        if(getElementData(localPlayer, "user:gui_showed"))then return end

        if(getElementData(localPlayer, "user:faction") == "SAPD")then
            assets.create()
        
            addEventHandler("onClientRender",root,ui.onRender)
        
            showCursor(true)
        
            setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
        
            ui.selected=1
            ui.border=false
        
            ui.sqlData={}

            
            triggerServerEvent("load.tablet.date", resourceRoot)

            guiSetInputEnabled(true)
        end
    end
end)

-- triggers

addEvent("get.vehicle", true)
addEventHandler("get.vehicle", resourceRoot, function(q)
    ui.searchVehicle=q

    if(ui.ped)then
        destroyElement(ui.ped)
        ui.ped=false

        preview:destroyObjectPreview(ui.preview)
        ui.preview=false
    end

    if(ui.veh)then
        destroyElement(ui.veh)
        ui.veh=false

        preview:destroyObjectPreview(ui.preview)
        ui.preview=false
    end

    for i,v in pairs(ui.btns) do
        buttons:destroyButton(ui.btns[i])
        ui.btns[i]=false
    end

    if(ui.scroll)then
        scroll:dxDestroyScroll(ui.scroll)
        ui.scroll=false
    end

    if(ui.scroll_2)then
        scroll:dxDestroyScroll(ui.scroll_2)
        ui.scroll_2=false
    end

    if(ui.memoElement)then
        destroyElement(ui.memoElement)
        ui.memoElement=nil
    end
end)

addEvent("get.player", true)
addEventHandler("get.player", resourceRoot, function(q, q_vehs, q_punish)
    q.punish=q_punish
    q.vehs=q_vehs
    ui.searchPlayer=q

    if(ui.ped)then
        destroyElement(ui.ped)
        ui.ped=false

        preview:destroyObjectPreview(ui.preview)
        ui.preview=false
    end

    if(ui.veh)then
        destroyElement(ui.veh)
        ui.veh=false

        preview:destroyObjectPreview(ui.preview)
        ui.preview=false
    end

    for i,v in pairs(ui.btns) do
        buttons:destroyButton(ui.btns[i])
        ui.btns[i]=false
    end

    if(ui.scroll)then
        scroll:dxDestroyScroll(ui.scroll)
        ui.scroll=false
    end

    if(ui.scroll_2)then
        scroll:dxDestroyScroll(ui.scroll_2)
        ui.scroll_2=false
    end

    if(ui.memoElement)then
        destroyElement(ui.memoElement)
        ui.memoElement=nil
    end
end)

addEvent("load.tablet.date", true)
addEventHandler("load.tablet.date", resourceRoot, function(q)
    ui.sqlData=q
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
            if(SPAM.getSpam())then return end

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