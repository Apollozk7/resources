--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local selected=0

ui.rendering["ranks"]=function(execute, a)
    local texs=ui.getTextures(execute)
    if(not texs)then return false end

    dxDrawImage(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom, (730-42)/zoom, 27/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawText("Stopień", sw/2-730/2/zoom+42/zoom+19/zoom, sh/2-581/2/zoom+42/zoom, (730-42)/zoom, 27/zoom+sh/2-581/2/zoom+42/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "center")

    local row=math.floor(scroll.export:dxScrollGetPosition(scroll.objects[1]))+1
    local r=fromJSON(ui.sql.org.ranks) or {}
    local x=0
    for i=row,row+8 do
        local v=r[i]
        if(v)then
            x=x+1

            local sY=(50/zoom)*(x-1)

            dxDrawImage(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY, 342/zoom, 49/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, a))
            dxDrawText(v.name, sw/2-730/2/zoom+42/zoom+19/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY, (730-42)/zoom, 49/zoom+sh/2-581/2/zoom+42/zoom+27/zoom+sY, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "center")
            
            if(selected == i)then
                dxDrawRectangle(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY+49/zoom-1, 342/zoom, 1, tocolor(62, 118, 101,a))
            else
                dxDrawRectangle(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY+49/zoom-1, 342/zoom, 1, tocolor(75,75,75,a))
            end
        
            onClick(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY, 342/zoom, 49/zoom, function()
                selected=i
            end)
        end
    end
    if(not scroll.objects[1])then
        scroll.objects[1]=scroll.export:dxCreateScroll(sw/2-730/2/zoom+42/zoom+342/zoom-4/zoom, sh/2-581/2/zoom+42/zoom+27/zoom, 4/zoom, 4/zoom, 0, 9, r, 581/zoom-27/zoom-42/zoom-65/zoom, a)
    end

    if(not buttons.objects[1] and not buttons.objects[2])then
        buttons.objects[1]=buttons.export:createButton(sw/2-730/2/zoom+59/zoom, sh/2-581/2/zoom+529/zoom, 147/zoom, 38/zoom, "USUŃ", a, 10, false, false, ":px_factions_management/textures/close.png", {164,51,51})
        buttons.objects[2]=buttons.export:createButton(sw/2-730/2/zoom+59/zoom+163/zoom, sh/2-581/2/zoom+529/zoom, 147/zoom, 38/zoom, "STWÓRZ", a, 10, false, false, ":px_factions_management/textures/bars/ranks/button_add.png")
    else
        onClick(sw/2-730/2/zoom+59/zoom, sh/2-581/2/zoom+529/zoom, 147/zoom, 38/zoom, function()
            if(selected and r[selected])then
                if(SPAM.getSpam())then return end

                triggerServerEvent("remove.rank", resourceRoot, selected, ui.sql.org.tag)
            end
        end)

        onClick(sw/2-730/2/zoom+59/zoom+163/zoom, sh/2-581/2/zoom+529/zoom, 147/zoom, 38/zoom, function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("add.rank", resourceRoot, ui.sql.org.tag)
        end)
    end

    dxDrawRectangle(sw/2-730/2/zoom+42/zoom+342/zoom, sh/2-581/2/zoom+42/zoom+27/zoom, 1, 581/zoom-27/zoom-42/zoom, tocolor(75,75,75,a))

    if(selected and r[selected])then
        dxDrawText("Nazwa:", sw/2-730/2/zoom+415/zoom, sh/2-581/2/zoom+90/zoom+140/zoom, 730/zoom, 581/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "top")
        dxDrawText(r[selected].name, sw/2-730/2/zoom+415/zoom, sh/2-581/2/zoom+90/zoom+20/zoom+140/zoom, 730/zoom, 581/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[4], "left", "top")
        if(not buttons.objects[3])then
            buttons.objects[3]=buttons.export:createButton(sw/2-730/2/zoom+560/zoom, sh/2-581/2/zoom+97/zoom+140/zoom, 105/zoom, 27/zoom, "ZMIEŃ", a, 10, false, false)
        else
            onClick(sw/2-730/2/zoom+560/zoom, sh/2-581/2/zoom+97/zoom+140/zoom, 105/zoom, 27/zoom, function()
                local edit=edits.export:dxGetEditText(edits.objects[1]) or ""
                if(#edit > 0)then
                    if(SPAM.getSpam())then return end

                    triggerServerEvent("edit.rank.name", resourceRoot, selected, edit, ui.sql.org.tag)
                end
            end)
        end
        if(not edits.objects[1])then
            edits.objects[1]=edits.export:dxCreateEdit("Nowa nazwa", sw/2-730/2/zoom+415/zoom, sh/2-581/2/zoom+154/zoom+140/zoom, 250/zoom, 30/zoom, false, 11/zoom, a, false, false, ":px_factions_management/textures/bars/ranks/edit_name.png")
        end
    end

    dxDrawText("Legenda:", sw/2-730/2/zoom+415/zoom, sh/2-581/2/zoom+90/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[4], "left", "top")
    dxDrawText("#ff0000*#c8c8c8 - Lider\n#3a32a8*#c8c8c8 - Zarząd\n#32a834*#c8c8c8 - vLider\n#fcf400*#c8c8c8 - Zaproszenia", sw/2-730/2/zoom+415/zoom, sh/2-581/2/zoom+90/zoom+30/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "top", false, false, false, true)
end