--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local avatars=exports.px_avatars
local clicks={}
local selected=0

ui.updateUsersRenderTarget=function(texs)
    local max=0

    clicks={}
    ui.updateRenderTarget(
        function()
            local last=-scroll.pos or 0
            for i,v in pairs(ui.sql.users) do
                dxDrawImage(0, last, (730-42)/zoom, 49/zoom, texs[2])

                if(selected == i)then
                    dxDrawRectangle(0, last+49/zoom-1, (730-42)/zoom, 1, tocolor(56,164,214))
                else
                    dxDrawRectangle(0, last+49/zoom-1, (730-42)/zoom, 1, tocolor(100,100,100))
                end
                
                local av=avatars:getPlayerAvatar(v.login)
                dxDrawImage(17/zoom, (49-21)/2/zoom+last, 21/zoom, 21/zoom, av)

                local ranks=fromJSON(ui.sql.org.ranks) or {}
                local rank=v.rank
                if(ranks[1].name == rank)then
                    rank=rank.." #ff0000*"
                elseif(v.access == 1)then
                    rank=rank.." #3a32a8*"
                elseif(ranks[2].name == rank)then
                    rank=rank.." #32a834*"
                elseif(ranks[3].name == rank)then
                    rank=rank.." #fcf400*"
                end
                dxDrawText(v.login, 58/zoom, last, (730-42)/zoom, 49/zoom+last, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
                dxDrawText(rank, 208/zoom, last, (730-42)/zoom, 49/zoom+last, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center", false, false, false, true)
                dxDrawText(getPlayerFromName(v.login) and "teraz" or v.lastlogin, 400/zoom, last, (730-42)/zoom, 49/zoom+last, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")

                dxDrawImage((730-42)/zoom-17/zoom-(49-17)/2/zoom, last+(49-17)/2/zoom, 17/zoom, 17/zoom, v.hide and texs[4] or texs[3])

                -- variables
                if((last+(49-17)/2/zoom) <= math.floor(400/zoom))then
                    clicks[#clicks+1]={(730-42)/zoom-17/zoom-(49-17)/2/zoom, last+(49-17)/2/zoom, 17/zoom, 17/zoom, function()
                        v.hide=not v.hide
                        ui.updateUsersRenderTarget(texs)
                    end}

                    clicks[#clicks+1]={0, last, (730-42)/zoom, 49/zoom, function()
                        selected=i
                        ui.updateUsersRenderTarget(texs)
                    end}
                end

                if(v.hide)then
                    -- left
                    dxDrawText("Ostatni raz online:", 18/zoom, last+49/zoom+24/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
                    dxDrawText(v.lastlogin, 18/zoom, last+49/zoom+24/zoom+24/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")

                    local hours,minutes=convertMinutes(v.online)
                    dxDrawText("Przegrany czas:", 18/zoom, last+49/zoom+24/zoom+60/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
                    dxDrawText(hours.."h "..minutes.."m", 18/zoom, last+49/zoom+24/zoom+24/zoom+60/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")

                    dxDrawText("Dodany:", 18/zoom, last+49/zoom+24/zoom+60/zoom+60/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
                    dxDrawText(v.added, 18/zoom, last+49/zoom+24/zoom+24/zoom+60/zoom+60/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")

                    dxDrawText("Ranga:", 18/zoom, last+49/zoom+24/zoom+60/zoom+60/zoom+60/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
                    dxDrawText(v.rank, 18/zoom, last+49/zoom+24/zoom+24/zoom+60/zoom+60/zoom+60/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")

                    -- right
                    dxDrawText("Zarobiona gotówka:", 18/zoom+335/zoom, last+49/zoom+24/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
                    dxDrawText("$"..v.earn_money, 18/zoom+335/zoom, last+49/zoom+24/zoom+24/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")

                    dxDrawText("Zdobyty EXP:", 18/zoom+335/zoom, last+49/zoom+24/zoom+60/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
                    dxDrawText(v.earn_exp, 18/zoom+335/zoom, last+49/zoom+24/zoom+24/zoom+60/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[4], "left", "top")

                    dxDrawText("Uprawnienia:", 18/zoom+335/zoom, last+49/zoom+24/zoom+60/zoom+60/zoom, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
                    dxDrawImage(18/zoom+335/zoom, last+49/zoom+24/zoom+25/zoom+60/zoom+60/zoom, 19/zoom, 19/zoom, v.access == 1 and texs[6] or texs[5])
                    dxDrawText("Zarząd", 18/zoom+335/zoom+35/zoom, last+49/zoom+24/zoom+25/zoom+60/zoom+60/zoom, 19/zoom, 19/zoom+last+49/zoom+24/zoom+25/zoom+60/zoom+60/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
                    clicks[#clicks+1]={18/zoom+335/zoom, last+49/zoom+24/zoom+25/zoom+60/zoom+60/zoom, 19/zoom, 19/zoom, function()
                        if(SPAM.getSpam())then return end

                        triggerServerEvent("update.user.access", resourceRoot, {
                            uid=v.uid,
                            login=v.login,
                            org=v.org
                        })
                    end}


                    last=last+270/zoom
                    max=max+270/zoom
                end
                
                last=last+51/zoom
                max=max+51/zoom
            end
        end
    )

    scroll.export:dxScrollUpdateRTSize(scroll.objects[1], max)
end

ui.rendering["users"]=function(execute, a)
    local texs=ui.getTextures(execute)
    if(not texs)then return false end

    if(not ui.renderTarget)then
        ui.renderTarget=dxCreateRenderTarget(math.floor((730-42)/zoom), math.floor(400/zoom), true)
        ui.updateUsersRenderTarget(texs)  
    else
        -- update rt lista pracownikow
        local pos=scroll.export:dxScrollGetRTPosition(scroll.objects[1]) or 0
        if(scroll.pos ~= pos)then
            scroll.pos=pos
            ui.updateUsersRenderTarget(texs)
        end
        --

        -- top
        dxDrawImage(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom, (730-42)/zoom, 27/zoom, texs[1], 0, 0, 0, tocolor(255, 255,255,a))
        dxDrawText("Nick", sw/2-730/2/zoom+42/zoom+17/zoom, sh/2-581/2/zoom+42/zoom, (730-42)/zoom, 27/zoom+sh/2-581/2/zoom+42/zoom, tocolor(200, 200, 200,a), 1, assets.fonts[3], "left", "center")
        dxDrawText("Ranga", sw/2-730/2/zoom+42/zoom+208/zoom, sh/2-581/2/zoom+42/zoom, (730-42)/zoom, 27/zoom+sh/2-581/2/zoom+42/zoom, tocolor(200, 200, 200,a), 1, assets.fonts[3], "left", "center")
        dxDrawText("Ostatnio dostępny", sw/2-730/2/zoom+42/zoom+400/zoom, sh/2-581/2/zoom+42/zoom, (730-42)/zoom, 27/zoom+sh/2-581/2/zoom+42/zoom, tocolor(200, 200, 200,a), 1, assets.fonts[3], "left", "center")

        -- rt
        dxDrawImage(math.floor(sw/2-730/2/zoom+42/zoom), math.floor(sh/2-581/2/zoom+42/zoom+27/zoom), math.floor((730-42)/zoom), math.floor(400/zoom), ui.renderTarget, 0, 0, 0, tocolor(255, 255,255,a))
        for i,v in pairs(clicks) do
            onClick(math.floor(sw/2-730/2/zoom+42/zoom)+v[1], math.floor(sh/2-581/2/zoom+42/zoom+27/zoom)+v[2],v[3],v[4],function()
                v[5]()
            end)
        end

        -- scroll
        if(not scroll.objects[1])then
            scroll.objects[1]=scroll.export:dxCreateScroll(sw/2-730/2/zoom+42/zoom+(730-42)/zoom-4, math.floor(sh/2-581/2/zoom+42/zoom+27/zoom), 4, 400/zoom, 0, 1, false, 400/zoom, a, 0, false, true, 500/zoom, 400/zoom, 50/zoom) 
        end

        -- bottom edit
        dxDrawImage(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+430/zoom, (730-42)/zoom, 49/zoom, texs[2], 0, 0, 0, tocolor(255, 255,255,a))
        dxDrawRectangle(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+49/zoom, (730-42)/zoom, 1, tocolor(100,100,100,a))
        if(not edits.objects[1])then
            edits.objects[1]=edits.export:dxCreateEdit("Nazwa użytkownika", sw/2-730/2/zoom+42/zoom+20/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+(49-30)/2/zoom, 327/zoom, 30/zoom, false, 11/zoom, a, false, false, ":px_factions_management/textures/bars/users/user_icon.png")
        end

        -- bottom button
        if(not buttons.objects[1])then
            buttons.objects[1]=buttons.export:createButton(sw/2-730/2/zoom+42/zoom+(730-42)/zoom-105/zoom-(49-27)/2/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+(49-27)/2/zoom, 105/zoom, 27/zoom, "DODAJ", a, 10, false, false)
        else
            onClick(sw/2-730/2/zoom+42/zoom+(730-42)/zoom-105/zoom-(49-27)/2/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+(49-27)/2/zoom, 105/zoom, 27/zoom, function()
                local edit=edits.export:dxGetEditText(edits.objects[1]) or ""
                if(#edit > 0)then
                    triggerServerEvent("add.user", resourceRoot, edit, ui.sql.org.tag)
                else
                    exports.px_noti:noti("Najpierw wprowadź login.", "error")
                end
            end)
        end

        -- bottoms buttonS!
        if(not buttons.objects[2] and not buttons.objects[3] and not buttons.objects[4])then
            buttons.objects[2]=buttons.export:createButton(sw/2-730/2/zoom+42/zoom+55/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+60/zoom, 160/zoom, 38/zoom, "AWANSUJ", a, 10, false, false, ":px_factions_management/textures/bars/users/awansuj.png")
            buttons.objects[3]=buttons.export:createButton(sw/2-730/2/zoom+42/zoom+55/zoom+185/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+60/zoom, 160/zoom, 38/zoom, "DEGRADUJ", a, 10, false, false, ":px_factions_management/textures/bars/users/degraduj.png", {164,51,51})
            buttons.objects[4]=buttons.export:createButton(sw/2-730/2/zoom+42/zoom+55/zoom+185/zoom+185/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+60/zoom, 160/zoom, 38/zoom, "WYRZUĆ", a, 10, false, false, ":px_factions_management/textures/bars/users/wyrzuc.png", {164,51,51})
        else
            onClick(sw/2-730/2/zoom+42/zoom+55/zoom+185/zoom+185/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+60/zoom, 160/zoom, 38/zoom, function()
                if(selected and ui.sql.users[selected] and not SPAM.getSpam())then
                    local s=ui.sql.users[selected]
                    triggerServerEvent("remove.user", resourceRoot, s)
                end
            end)

            onClick(sw/2-730/2/zoom+42/zoom+55/zoom+185/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+60/zoom, 160/zoom, 38/zoom, function()
                if(selected and ui.sql.users[selected] and not SPAM.getSpam())then
                    local s=ui.sql.users[selected]
                    triggerServerEvent("rank.down.user", resourceRoot, s)
                end
            end)

            onClick(sw/2-730/2/zoom+42/zoom+55/zoom, sh/2-581/2/zoom+42/zoom+430/zoom+60/zoom, 160/zoom, 38/zoom, function()
                if(selected and ui.sql.users[selected] and not SPAM.getSpam())then
                    local s=ui.sql.users[selected]
                    triggerServerEvent("rank.up.user", resourceRoot, s)
                end            
            end)
        end
    end
end