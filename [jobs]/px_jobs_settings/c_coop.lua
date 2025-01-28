--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui.pos["coop"]={
    -- main
    ["start_img"]={sw/2-689/2/zoom+622/zoom-(77-38)/2/zoom, sh/2-595/2/zoom+595/zoom-58/zoom-25/zoom, 77/zoom, 77/zoom},
    ["start_text"]={sw/2-689/2/zoom+622/zoom-(77-38)/2/zoom, sh/2-595/2/zoom+595/zoom-58/zoom-25/zoom, sw/2-689/2/zoom+622/zoom-(77-38)/2/zoom, sh/2-595/2/zoom+595/zoom-58/zoom-25/zoom+77/zoom},
    ["start_line"]={sw/2-689/2/zoom+2, sh/2-595/2/zoom+585/zoom-75/zoom, 684/zoom, 1},
    ["start_editPass"]={sw/2-689/2/zoom+24/zoom, sh/2-595/2/zoom+585/zoom-75/zoom+(83-38)/2/zoom, 300/zoom, 38/zoom},
    ["start_scroll"]={sw/2-689/2/zoom+689/zoom-4, sh/2-595/2/zoom+42/zoom, 595/zoom-75/zoom-51/zoom},

    ["tbl_sY"]=92/zoom,
    ["tbl_line"]={sw/2-689/2/zoom+2, sh/2-595/2/zoom+42/zoom+91/zoom-1, 684/zoom, 1},
    ["tbl_text_1"]={sw/2-689/2/zoom+25/zoom, sh/2-595/2/zoom+42/zoom+20/zoom, 0, 0},
    ["tbl_text_2"]={sw/2-689/2/zoom+25/zoom, sh/2-595/2/zoom+42/zoom+45/zoom, 0, 0},
    ["tbl_pass"]={sw/2-689/2/zoom+388/zoom, sh/2-595/2/zoom+42/zoom+(91-15)/2/zoom, 11/zoom, 15/zoom},
    ["tbl_button"]={sw/2-689/2/zoom+517/zoom, sh/2-595/2/zoom+42/zoom+(91-38)/2/zoom, 137/zoom, 38/zoom},
    ["tbl_text_3"]={sw/2-689/2/zoom+440/zoom, sh/2-595/2/zoom+42/zoom, 0, sh/2-595/2/zoom+42/zoom+91/zoom},

    -- in lobby
    ["il_desc"]={sw/2-689/2/zoom+26/zoom, sh/2-595/2/zoom+42/zoom+26/zoom, 0, 0},
    ["il_info"]={sw/2-689/2/zoom+26/zoom, sh/2-595/2/zoom+42/zoom+26/zoom, sw/2-689/2/zoom+26/zoom+630/zoom, 0},
    ["il_sY"]=49/zoom,
    ["il_row"]={sw/2-689/2/zoom+2, sh/2-595/2/zoom+42/zoom+70/zoom, 684/zoom, 48/zoom},
    ["il_av"]={sw/2-689/2/zoom+2+24/zoom, sh/2-595/2/zoom+42/zoom+70/zoom+(48-30)/2/zoom, 30/zoom, 30/zoom},
    ["il_name"]={sw/2-689/2/zoom+2+70/zoom, sh/2-595/2/zoom+42/zoom+70/zoom, 684/zoom, sh/2-595/2/zoom+42/zoom+70/zoom+48/zoom},
    ["il_icon"]={sw/2-689/2/zoom+2+70/zoom, sh/2-595/2/zoom+42/zoom+70/zoom+(48-20)/2/zoom, 20/zoom, 20/zoom},
    ["il_del"]={sw/2-689/2/zoom+2+650/zoom, sh/2-595/2/zoom+42/zoom+70/zoom+(48-17)/2/zoom, 13/zoom, 17/zoom},
    ["il_quit"]={sw/2-689/2/zoom+24/zoom, sh/2-595/2/zoom+595/zoom-60/zoom, 148/zoom, 38/zoom},
    ["il_pass"]={sw/2-689/2/zoom+188/zoom, sh/2-595/2/zoom+595/zoom-60/zoom, 148/zoom, sh/2-595/2/zoom+595/zoom-60/zoom+38/zoom},
    ["il_margin"]=5/zoom,
}

ui.rows["coop"]={
    min=1,
    act=1,
    max=4,
}

ui.quitLobby=function()
    if(SPAM.getSpam())then return end

    local selected=getElementData(localPlayer, "user:jobLobby")
    if(selected)then
        local lobby=getElementByID(selected)
        if(lobby and isElement(lobby))then
            local data=getElementData(lobby, "info")
            if(data)then
                if(data.lider == localPlayer)then
                    triggerServerEvent("destroy.lobby", resourceRoot)
                else
                    triggerServerEvent("quit.lobby", resourceRoot)
                end
            end
        end
    end
end

ui.refreshCoop=false
ui.lobbysConvert=false

ui.rendering["coop"]=function(execute, a)
    if(getElementData(localPlayer, "user:job"))then return end

    local p=ui.pos["coop"]
    if(not p)then return end

    local lobbys=getElementsByType("lobby")
    if(#lobbys ~= ui.refreshCoop)then
        ui.refreshCoop=#lobbys
        ui.destroyExports()

        ui.lobbysConvert={}
        for i,v in pairs(lobbys) do
            if(v and isElement(v))then
                local info=getElementData(v, "info")
                if(info)then
                    if(info.lider and isElement(info.lider) and getElementType(info.lider) == 'player')then
                        table.insert(ui.lobbysConvert, v)
                    else
                        destroyElement(v)
                    end
                else
                    destroyElement(v)
                end
            end
        end
    end

    local selected=getElementData(localPlayer, "user:jobLobby")
    if(selected)then
        local lobby=getElementByID(selected)
        if(lobby and isElement(lobby))then
            local data=getElementData(lobby, "info")
            if(data)then
                if(data.lider and isElement(data.lider))then
                    local players={{name=getPlayerName(data.lider),player=data.lider}}
                    for i,v in pairs(data.players) do
                        players[#players+1]={name=i,player=v}
                    end

                    dxDrawRectangle(p.start_line[1], p.start_line[2], p.start_line[3], p.start_line[4], tocolor(86,86,86,a))

                    dxDrawText("Grupa: ["..getElementData(data.lider, "user:id").."] "..getPlayerName(data.lider), p.il_desc[1], p.il_desc[2], p.il_desc[3], p.il_desc[4], tocolor(200,200,200,a), 1, assets.fonts[1], "left", "top")  
                    dxDrawText("Miejsca: "..#players.."/"..(ui.info.sql["co-op"]+1), p.il_info[1], p.il_info[2], p.il_info[3], p.il_info[4], tocolor(200,200,200,a), 1, assets.fonts[1], "right", "top")

                    for i,v in pairs(players) do
                        if(v.player and isElement(v.player))then
                            local sY=p.il_sY*(i-1)
                            dxDrawImage(p.il_row[1], p.il_row[2]+sY, p.il_row[3], p.il_row[4], assets.textures[12], 0, 0, 0, tocolor(255,255,255,a))
                            dxDrawRectangle(p.il_row[1], p.il_row[2]+sY+p.il_row[4]-1, p.il_row[3], 1, tocolor(86,86,86,a))
        
                            local av=avatars:getPlayerAvatar(v.player)
                            local text="["..getElementData(v.player,"user:id").."] "..getPlayerName(v.player)
                            dxDrawImage(p.il_av[1], p.il_av[2]+sY, p.il_av[3], p.il_av[4], av, 0, 0, 0, tocolor(255,255,255,a))
                            dxDrawText(text, p.il_name[1], p.il_name[2]+sY, p.il_name[3], p.il_name[4]+sY, tocolor(200, 200, 200,a), 1, assets.fonts[1], "left", "center")
                            dxDrawImage(p.il_icon[1]+dxGetTextWidth(text, 1, assets.fonts[1])+p.il_margin, p.il_icon[2]+sY, p.il_icon[3], p.il_icon[4], data.lider == v.player and assets.textures[17] or assets.textures[18], 0, 0, 0, tocolor(255,255,255,a))
        
                            if(data.lider == localPlayer and v.player ~= localPlayer)then
                                dxDrawImage(p.il_del[1], p.il_del[2]+sY, p.il_del[3], p.il_del[4], assets.textures[16], 0, 0, 0, tocolor(255,255,255,a))
                                onClick(p.il_del[1], p.il_del[2]+sY, p.il_del[3], p.il_del[4], function()
                                    if(SPAM.getSpam())then return end
        
                                    triggerServerEvent("remove.lobby", resourceRoot, v.name)
                                end)
                            end
                        end
                    end

                    if(not buttons.objects[1])then
                        buttons.objects[1]=buttons.export:createButton(p.il_quit[1], p.il_quit[2], p.il_quit[3], p.il_quit[4], data.lider == localPlayer and "USUŃ" or "WYJDŹ", a, 10, false, false, ":px_jobs_settings/textures/button_icon.png")
                    else
                        onClick(p.il_quit[1], p.il_quit[2], p.il_quit[3], p.il_quit[4], function()
                            if(SPAM.getSpam())then return end
        
                            if(data.lider == localPlayer)then
                                triggerServerEvent("destroy.lobby", resourceRoot)
                            else
                                triggerServerEvent("quit.lobby", resourceRoot)
                            end
                        end)
                    end
        
                    if(data.pass)then
                        dxDrawText("Hasło: "..((data.pass and #data.pass > 0) and data.pass or "brak"), p.il_pass[1], p.il_pass[2], p.il_pass[3], p.il_pass[4], tocolor(200,200,200,a), 1, assets.fonts[1], "left", "center")
                    end
        
                    if(data.lider == localPlayer)then
                        dxDrawText("Rozpocznij pracę", p.start_text[1]+1, p.start_text[2]+1, p.start_text[3]+1, p.start_text[4]+1, tocolor(0,0,0,a), 1, assets.fonts[1], "right", "center")
                        dxDrawText("Rozpocznij pracę", p.start_text[1], p.start_text[2], p.start_text[3], p.start_text[4], tocolor(200,200,200,a), 1, assets.fonts[1], "right", "center")
                        dxDrawImage(p.start_img[1], p.start_img[2], p.start_img[3], p.start_img[4], assets.textures[11], 0, 0, 0, tocolor(255,255,255,a))   
                        
                        onClick(p.start_img[1], p.start_img[2], p.start_img[3], p.start_img[4], function()
                            if(#players > 1)then
                                if(SPAM.getSpam())then return end
        
                                local p={}
                                for i,v in pairs(data.players) do
                                    p[#p+1]=v
                                end

                                if(job and job ~= ui.info.sql.name or getElementData(localPlayer, "user:faction"))then
                                    noti:noti("Najpierw zakończ pracę.", "error")
                                else
                                    if(not getPedAnimation(localPlayer))then
                                        triggerServerEvent("start.job", resourceRoot, ui.info.sql.name, p, selected, ui.info.sql.level)
                                    end
                                end
                            end
                        end)
                    end
                else
                    destroyElement(lobby)
                end
            else
                setElementData(localPlayer, "user:jobLobby", false)
            end
        else
            setElementData(localPlayer, "user:jobLobby", false)
        end
    else
        if(not edits.objects[1])then
            edits.objects[1]=edits.export:dxCreateEdit("Wprowadź hasło do poczekalni...", p.start_editPass[1], p.start_editPass[2], p.start_editPass[3], p.start_editPass[4], false, 10/zoom, a, false, false, ":px_jobs_settings/textures/edit_pass.png", true)
        end

        local row=ui.rows["coop"]
        if(not scroll.objects[1])then
            scroll.objects[1]=scroll.export:dxCreateScroll(p.start_scroll[1], p.start_scroll[2], 4, 4, 0, ui.rows["coop"].max+1, ui.lobbysConvert, p.start_scroll[3], a, 1)
        else
            row.act=math.floor(scroll.export:dxScrollGetPosition(scroll.objects[1])+1)
        end

        dxDrawRectangle(p.start_line[1], p.start_line[2], p.start_line[3], p.start_line[4], tocolor(86,86,86,a))
        dxDrawText("Stwórz poczekalnie", p.start_text[1]+1, p.start_text[2]+1, p.start_text[3]+1, p.start_text[4]+1, tocolor(0,0,0,a), 1, assets.fonts[1], "right", "center")
        dxDrawText("Stwórz poczekalnie", p.start_text[1], p.start_text[2], p.start_text[3], p.start_text[4], tocolor(200,200,200,a), 1, assets.fonts[1], "right", "center")
        dxDrawImage(p.start_img[1], p.start_img[2], p.start_img[3], p.start_img[4], assets.textures[11], 0, 0, 0, tocolor(255,255,255,a))   
        onClick(p.start_img[1], p.start_img[2], p.start_img[3], p.start_img[4], function()
            if(SPAM.getSpam())then return end

            local pass=edits.export:dxGetEditText(edits.objects[1]) or ""
            triggerServerEvent("create.lobby", resourceRoot, ui.info.name, pass, ui.info.level)
        end) 
    
        local x=0
        for i=row.act,(row.act+row.max) do
            local v=ui.lobbysConvert[i]
            if(v)then
                x=x+1

                local sY=(p.tbl_sY/zoom)*(x-1)

                local info=getElementData(v, "info")
                local players=getPlayerName(info.lider)
                local max=1
                for i,v in pairs(info.players) do
                    if(v and isElement(v))then
                        max=max+1
                        players=#players > 0 and players..", "..getPlayerName(v)
                    end
                end

                dxDrawText("Grupa ["..getElementData(info.lider, "user:id").."] "..getPlayerName(info.lider), p.tbl_text_1[1], p.tbl_text_1[2]+sY, p.tbl_text_1[3], p.tbl_text_1[4], tocolor(200,200,200,a), 1, assets.fonts[1], "left", "top")
                dxDrawText(players, p.tbl_text_2[1], p.tbl_text_2[2]+sY, p.tbl_text_2[3], p.tbl_text_2[4], tocolor(150,150,150,a), 1, assets.fonts[1], "left", "top")

                if(info.pass and #info.pass > 0)then
                    dxDrawImage(p.tbl_pass[1], p.tbl_pass[2]+sY, p.tbl_pass[3], p.tbl_pass[4], assets.textures[15], 0, 0, 0, tocolor(255,255,255,a))
                end

                dxDrawText(max.."/"..(ui.info.sql["co-op"]+1), p.tbl_text_3[1], p.tbl_text_3[2]+sY, p.tbl_text_3[3], p.tbl_text_3[4]+sY, tocolor(200,200,200,a), 1, assets.fonts[7], "left", "center")

                if(not buttons.objects[x])then
                    buttons.objects[x]=buttons.export:createButton(p.tbl_button[1], p.tbl_button[2]+sY, p.tbl_button[3], p.tbl_button[4], "DOŁĄCZ", a, 10, false, false, ":px_jobs_settings/textures/button_icon.png")
                else
                    onClick(p.tbl_button[1], p.tbl_button[2]+sY, p.tbl_button[3], p.tbl_button[4], function()
                        if(SPAM.getSpam())then return end
                        
                        if(max < (ui.info.sql["co-op"]+1))then
                            local pass=edits.export:dxGetEditText(edits.objects[1]) or ""
                            if((info.pass and #info.pass > 0 and info.pass == pass) or (not info.pass or #info.pass < 1))then
                                triggerServerEvent("join.lobby", resourceRoot, info.id)
                            end
                        else
                            noti:noti("Brak wolnych miejsc.", "error")
                        end
                    end)
                end

                dxDrawRectangle(p.tbl_line[1], p.tbl_line[2]+sY, p.tbl_line[3], p.tbl_line[4], tocolor(86,86,86,a))
            end
        end
    end
end

-- update

addEventHandler("onClientElementDataChange", resourceRoot, function(data,old,new)
    local lobby=getElementData(localPlayer, "user:jobLobby")
    if(lobby)then
        local element=getElementByID(lobby)
        if(data == "info" and element and isElement(element) and element == source)then
            ui.destroyExports()
        end
    end
end)

addEventHandler("onClientElementDataChange", localPlayer, function(data,old,new)
    if(data == "user:jobLobby")then
        ui.destroyExports()
    end
end)