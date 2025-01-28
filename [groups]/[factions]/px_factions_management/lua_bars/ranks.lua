--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local selected=0

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

ui.rendering["ranks"]=function(execute, a)
    local texs=ui.getTextures(execute)
    if(not texs)then return false end

    dxDrawImage(sw/2-689/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom, (689-42)/zoom, 27/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawText("Stopień", sw/2-689/2/zoom+42/zoom+19/zoom, sh/2-581/2/zoom+42/zoom, (689-42)/zoom, 27/zoom+sh/2-581/2/zoom+42/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "center")
    dxDrawText("Wypłata", sw/2-689/2/zoom+42/zoom+19/zoom+225/zoom, sh/2-581/2/zoom+42/zoom, (689-42)/zoom, 27/zoom+sh/2-581/2/zoom+42/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "center")

    local row=math.floor(scroll.export:dxScrollGetPosition(scroll.objects[1]))+1
    local r=fromJSON(ui.sql.fraction.ranks) or {}
    local x=0
    for i=row,row+8 do
        local v=r[i]
        if(v)then
            x=x+1

            local sY=(50/zoom)*(x-1)

            dxDrawImage(sw/2-689/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY, 342/zoom, 49/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, a))
            dxDrawText(v.name, sw/2-689/2/zoom+42/zoom+19/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY, (689-42)/zoom, 49/zoom+sh/2-581/2/zoom+42/zoom+27/zoom+sY, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "center")
            dxDrawText("$ "..v.money, sw/2-689/2/zoom+42/zoom+19/zoom+225/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY, (689-42)/zoom, 49/zoom+sh/2-581/2/zoom+42/zoom+27/zoom+sY, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "center")    
            
            if(selected == i)then
                dxDrawRectangle(sw/2-689/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY+49/zoom-1, 342/zoom, 1, tocolor(62, 118, 101,a))
            else
                dxDrawRectangle(sw/2-689/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY+49/zoom-1, 342/zoom, 1, tocolor(75,75,75,a))
            end
        
            onClick(sw/2-689/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+27/zoom+sY, 342/zoom, 49/zoom, function()
                selected=i
            end)
        end
    end
    if(not scroll.objects[1])then
        scroll.objects[1]=scroll.export:dxCreateScroll(sw/2-689/2/zoom+42/zoom+342/zoom-4/zoom, sh/2-581/2/zoom+42/zoom+27/zoom, 4/zoom, 4/zoom, 0, 9, r, 581/zoom-27/zoom-42/zoom-65/zoom, a)
    end

    if(not buttons.objects[1] and not buttons.objects[2])then
        buttons.objects[1]=buttons.export:createButton(sw/2-689/2/zoom+59/zoom, sh/2-581/2/zoom+529/zoom, 147/zoom, 38/zoom, "USUŃ", a, 10, false, false, ":px_factions_management/textures/close.png", {164,51,51})
        buttons.objects[2]=buttons.export:createButton(sw/2-689/2/zoom+59/zoom+163/zoom, sh/2-581/2/zoom+529/zoom, 147/zoom, 38/zoom, "STWÓRZ", a, 10, false, false, ":px_factions_management/textures/bars/ranks/button_add.png")
    else
        onClick(sw/2-689/2/zoom+59/zoom, sh/2-581/2/zoom+529/zoom, 147/zoom, 38/zoom, function()
            if(selected and r[selected])then
                if(SPAM.getSpam())then return end

                triggerServerEvent("remove.rank", resourceRoot, selected, ui.sql.fraction.tag)
            end
        end)

        onClick(sw/2-689/2/zoom+59/zoom+163/zoom, sh/2-581/2/zoom+529/zoom, 147/zoom, 38/zoom, function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("add.rank", resourceRoot, ui.sql.fraction.tag)
        end)
    end

    dxDrawRectangle(sw/2-689/2/zoom+42/zoom+342/zoom, sh/2-581/2/zoom+42/zoom+27/zoom, 1, 581/zoom-27/zoom-42/zoom, tocolor(75,75,75,a))

    if(selected and r[selected])then
        dxDrawText("Nazwa:", sw/2-689/2/zoom+415/zoom, sh/2-581/2/zoom+90/zoom, 689/zoom, 581/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "top")
        dxDrawText(r[selected].name, sw/2-689/2/zoom+415/zoom, sh/2-581/2/zoom+90/zoom+20/zoom, 689/zoom, 581/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[4], "left", "top")
        if(not buttons.objects[3])then
            buttons.objects[3]=buttons.export:createButton(sw/2-689/2/zoom+560/zoom, sh/2-581/2/zoom+97/zoom, 105/zoom, 27/zoom, "ZMIEŃ", a, 10, false, false)
        else
            onClick(sw/2-689/2/zoom+560/zoom, sh/2-581/2/zoom+97/zoom, 105/zoom, 27/zoom, function()
                local edit=edits.export:dxGetEditText(edits.objects[1]) or ""
                if(#edit > 0)then
                    if(SPAM.getSpam())then return end

                    triggerServerEvent("edit.rank.name", resourceRoot, selected, edit, ui.sql.fraction.tag)
                end
            end)
        end
        if(not edits.objects[1])then
            edits.objects[1]=edits.export:dxCreateEdit("Nowa nazwa", sw/2-689/2/zoom+415/zoom, sh/2-581/2/zoom+154/zoom, 250/zoom, 30/zoom, false, 11/zoom, a, false, false, ":px_factions_management/textures/bars/ranks/edit_name.png")
        end

        dxDrawText("Wypłata:", sw/2-689/2/zoom+415/zoom, sh/2-581/2/zoom+90/zoom+120/zoom, 689/zoom, 581/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "top")
        dxDrawText("#3fc896$#dedede "..r[selected].money, sw/2-689/2/zoom+415/zoom, sh/2-581/2/zoom+90/zoom+20/zoom+120/zoom, 689/zoom, 581/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[4], "left", "top", false, false, false, true)
        if(not buttons.objects[4])then
            buttons.objects[4]=buttons.export:createButton(sw/2-689/2/zoom+560/zoom, sh/2-581/2/zoom+97/zoom+120/zoom, 105/zoom, 27/zoom, "ZMIEŃ", a, 10, false, false)
        else
            onClick(sw/2-689/2/zoom+560/zoom, sh/2-581/2/zoom+97/zoom+120/zoom, 105/zoom, 27/zoom, function()
                local edit=edits.export:dxGetEditText(edits.objects[2]) or ""
                if(#edit > 0)then
                    if(SPAM.getSpam())then return end

                    triggerServerEvent("edit.rank.money", resourceRoot, selected, edit, ui.sql.fraction.tag)
                end
            end)
        end
        if(not edits.objects[2])then
            edits.objects[2]=edits.export:dxCreateEdit("Kwota", sw/2-689/2/zoom+415/zoom, sh/2-581/2/zoom+144/zoom+130/zoom, 250/zoom, 30/zoom, false, 11/zoom, a, false, false, ":px_factions_management/textures/bars/ranks/edit_money.png")
        end
    end
end