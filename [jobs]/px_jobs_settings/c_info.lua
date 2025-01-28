--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui.rendering["info"]=function(execute, a)
    local screen_path=":"..ui.info.sql.scriptName.."/textures/job_screen.png"
    if(fileExists(screen_path))then
        dxDrawImage(sw/2-689/2/zoom, sh/2-595/2/zoom+42/zoom, 689/zoom, 317/zoom, assets.textures[#assets.textures], 0, 0, 0, tocolor(255,255,255,a))
    end

    local text="Rozpocznij prace"
    local job=getElementData(localPlayer, "user:job")
    if(job == ui.info.sql.name)then
        text="Zakończ pracę"
    elseif(ui.info.sql["co-op"] > 0)then
        text="Przejdź do poczekalni"
    end

    dxDrawText(text, sw/2-689/2/zoom+622/zoom+1, sh/2-595/2/zoom+66/zoom+1, sw/2-689/2/zoom+622/zoom-17/zoom+1, 38/zoom+sh/2-595/2/zoom+66/zoom+1, tocolor(0,0,0,a), 1, assets.fonts[1], "right", "center")
    dxDrawText(text, sw/2-689/2/zoom+622/zoom, sh/2-595/2/zoom+66/zoom, sw/2-689/2/zoom+622/zoom-17/zoom, 38/zoom+sh/2-595/2/zoom+66/zoom, tocolor(200,200,200,a), 1, assets.fonts[1], "right", "center")
    dxDrawImage(sw/2-689/2/zoom+622/zoom-(77-38)/2/zoom, sh/2-595/2/zoom+66/zoom-(77-38)/2/zoom, 77/zoom, 77/zoom, assets.textures[11], 0, 0, 0, tocolor(255,255,255,a))
    onClick(sw/2-689/2/zoom+622/zoom, sh/2-595/2/zoom+66/zoom, 38/zoom, 38/zoom, function()
        if(SPAM.getSpam())then return end

        if(job == ui.info.sql.name)then
            triggerLatentServerEvent("stop.job", resourceRoot, ui.info.sql.name)
            setElementData(localPlayer, "user:jobs_todo", false, false)
        elseif(ui.info.sql["co-op"] > 0)then
            ui.selectPage(4)
        elseif(job and job ~= ui.info.sql.name or getElementData(localPlayer, "user:faction"))then
            noti:noti("Najpierw zakończ pracę.", "error")
        else
            if(not getPedAnimation(localPlayer))then
                triggerLatentServerEvent("start.job", resourceRoot, ui.info.sql.name)
            end
        end
    end)

    dxDrawText(string.upper(ui.info.sql.name), sw/2-689/2/zoom+27/zoom, sh/2-595/2/zoom+345/zoom, 0, 0, tocolor(200,200,200,a), 1, assets.fonts[6], "left", "top")
    dxDrawRectangle(sw/2-689/2/zoom, sh/2-595/2/zoom+390/zoom, 689/zoom, 1, tocolor(86,86,86,a))
    dxDrawText(ui.info.sql.desc, sw/2-689/2/zoom+27/zoom, sh/2-595/2/zoom+400/zoom, sw/2-689/2/zoom+27/zoom+635/zoom, 0, tocolor(200,200,200,a>150 and 150 or a), 1, assets.fonts[3], "left", "top", false, true)

    dxDrawImage(sw/2-689/2/zoom+28/zoom, sh/2-595/2/zoom+42/zoom+465/zoom, 46/zoom, 46/zoom, assets.textures[9], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawImage(sw/2-689/2/zoom+28/zoom+(46-24)/2/zoom, sh/2-595/2/zoom+42/zoom+465/zoom+(46-21)/2/zoom, 24/zoom, 21/zoom, assets.textures[10], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawText(ui.info.sql.name, sw/2-689/2/zoom+28/zoom+14/zoom+46/zoom, sh/2-595/2/zoom+42/zoom+465/zoom, 46/zoom, 46/zoom+sh/2-595/2/zoom+42/zoom+465/zoom, tocolor(200,200,200,a), 1, assets.fonts[1], "left", "center")

    dxDrawImage(sw/2-689/2/zoom+28/zoom+185/zoom+40/zoom, sh/2-595/2/zoom+42/zoom+465/zoom, 46/zoom, 46/zoom, assets.textures[9], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawText(ui.info.sql.level, sw/2-689/2/zoom+28/zoom+185/zoom+40/zoom, sh/2-595/2/zoom+42/zoom+465/zoom, 46/zoom+sw/2-689/2/zoom+28/zoom+185/zoom+40/zoom, 46/zoom+sh/2-595/2/zoom+42/zoom+465/zoom, tocolor(200,200,200,a), 1, assets.fonts[4], "center", "center")
    dxDrawText("Reputacja", sw/2-689/2/zoom+28/zoom+185/zoom+14/zoom+46/zoom+40/zoom, sh/2-595/2/zoom+42/zoom+465/zoom, 46/zoom, 46/zoom+sh/2-595/2/zoom+42/zoom+465/zoom, tocolor(200,200,200,a), 1, assets.fonts[1], "left", "center")

    if(#ui.info.sql.requirements > 0)then
        local name=(ui.info.sql.requirements == "L1" or ui.info.sql.requirements == "L2") and "Licencja" or "Prawo jazdy"
        dxDrawImage(sw/2-689/2/zoom+28/zoom+185/zoom+40/zoom+185/zoom+40/zoom, sh/2-595/2/zoom+42/zoom+465/zoom, 46/zoom, 46/zoom, assets.textures[9], 0, 0, 0, tocolor(255,255,255,a))
        dxDrawText(ui.info.sql.requirements, sw/2-689/2/zoom+28/zoom+185/zoom+40/zoom+185/zoom+40/zoom, sh/2-595/2/zoom+42/zoom+465/zoom, 46/zoom+sw/2-689/2/zoom+28/zoom+185/zoom+40/zoom+185/zoom+40/zoom, 46/zoom+sh/2-595/2/zoom+42/zoom+465/zoom, tocolor(200,200,200,a), 1, assets.fonts[4], "center", "center")
        dxDrawText(name, sw/2-689/2/zoom+28/zoom+185/zoom+14/zoom+46/zoom+40/zoom+185/zoom+40/zoom, sh/2-595/2/zoom+42/zoom+465/zoom, 46/zoom, 46/zoom+sh/2-595/2/zoom+42/zoom+465/zoom, tocolor(200,200,200,a), 1, assets.fonts[1], "left", "center")
    end
end