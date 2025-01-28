--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local pos={
    {sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+122/zoom, 344/zoom, 138/zoom, 2},
    {sw/2-730/2/zoom+42/zoom+344/zoom, sh/2-581/2/zoom+42/zoom+122/zoom, 344/zoom, 138/zoom, 3},
    {sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+122/zoom+139/zoom, 344/zoom, 138/zoom, 3},
    {sw/2-730/2/zoom+42/zoom+344/zoom, sh/2-581/2/zoom+42/zoom+122/zoom+139/zoom, 344/zoom, 138/zoom, 2},
    {sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+122/zoom+139/zoom+139/zoom, 344/zoom, 138/zoom, 2},
    {sw/2-730/2/zoom+42/zoom+344/zoom, sh/2-581/2/zoom+42/zoom+122/zoom+139/zoom+139/zoom, 344/zoom, 138/zoom, 3},
}

ui.rendering["tasks"]=function(execute, a)
    local texs,icons=ui.getTextures(execute)
    if(not texs or not icons)then return false end

    dxDrawText("Zadania dzienne", sw/2-730/2/zoom+42/zoom+35/zoom, sh/2-581/2/zoom+42/zoom+35/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "top")
    dxDrawText("Wykonuj zadania dzienne i ulepszaj organizację", sw/2-730/2/zoom+42/zoom+35/zoom, sh/2-581/2/zoom+42/zoom+65/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[6], "left", "top")

    dxDrawRectangle(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+121/zoom, (730-42)/zoom, 1, tocolor(80, 80, 80, a))

    local i=0
    for n,k in pairs(ui.sql.tasks or {}) do
        i=i+1

        local v=pos[i]
        if(v)then
            if(ui.sql.task[n])then
                k=ui.sql.task[n]
            end

            local aa=(not ui.sql.task[n] or v.done) and (a > 20 and 20 or a) or a
    
            dxDrawImage(v[1], v[2], v[3], v[4], texs[v[5]], 0, 0, 0, tocolor(255, 255, 255, aa))
            
            if(icons[k.icon])then
                dxDrawImage(v[1]+37/zoom, v[2]+36/zoom, 67/zoom, 67/zoom, icons[k.icon], 0, 0, 0, tocolor(255, 255, 255, aa))
            end
    
            dxDrawText(n, v[1]+67/zoom+37/zoom+22/zoom, v[2]+36/zoom, v[1]+67/zoom+37/zoom+22/zoom+180/zoom, 0, tocolor(200, 200, 200, aa), 1, assets.fonts[1], "left", "top", false, true)
    
            dxDrawImage(v[1]+67/zoom+37/zoom+22/zoom, v[2]+36/zoom+67/zoom-23/zoom, 63/zoom, 23/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, aa))
            dxDrawText(math.floor(k.progress).."/"..math.floor(k.maxProgress), v[1]+67/zoom+37/zoom+22/zoom, v[2]+36/zoom+67/zoom-23/zoom, 63/zoom+v[1]+67/zoom+37/zoom+22/zoom, 23/zoom+v[2]+36/zoom+67/zoom-23/zoom, tocolor(200, 200, 200, aa), 1, assets.fonts[8], "center", "center", false, true)
        
            dxDrawText("#4eb451$ #b9babb"..formatNumber(k.money), 0, v[2], v[1]+v[3]-38/zoom, v[2]+v[4]+50/zoom, tocolor(200, 200, 200, aa), 1, assets.fonts[6], "right", "center", false, false, false, true)
        
            if(v.done)then
                dxDrawRectangle(v[1], v[2], v[3], v[4], tocolor(30, 35, 35, a > 50 and 50 or 50))
                dxDrawText("ZALICZONE", v[1], v[2], v[3]+v[1], v[4]+v[2], tocolor(200, 200, 200, a), 1, assets.fonts[7], "center", "center")
                dxDrawImage(v[1]+(v[3]-dxGetTextWidth("ZALICZONE", 1, assets.fonts[7]))/2-40/zoom, v[2]+(v[4]-30)/2/zoom, 30/zoom, 22/zoom, texs[4], 0, 0, 0, tocolor(255, 255, 255, a))
            elseif(not ui.sql.task[n])then
                dxDrawRectangle(v[1], v[2], v[3], v[4], tocolor(30, 35, 35, a > 50 and 50 or 50))
                dxDrawText("NIEAKTYWNE", v[1], v[2], v[3]+v[1], v[4]+v[2], tocolor(200, 200, 200, a), 1, assets.fonts[7], "center", "center")
                dxDrawImage(v[1]+(v[3]-dxGetTextWidth("NIEAKTYWNE", 1, assets.fonts[7]))/2-40/zoom, v[2]+(v[4]-31)/2/zoom, 31/zoom, 31/zoom, texs[5], 0, 0, 0, tocolor(255, 255, 255, a))
            end
        end
    end

    local hour,minute=getRealTime().hour,getRealTime().minute
    dxDrawText((23-hour).."h "..(60-minute).."m", 0, sh/2-581/2/zoom+42/zoom+48/zoom, sw/2-730/2/zoom+730/zoom-40/zoom, 0, tocolor(200, 200, 200, a), 1, assets.fonts[7], "right", "top")
end

function findFreeValue(value, t)
    for i=1,value do
        if(not t[i])then
            t[i]=true
        end
    end
    t[value+1]=true
    return t
end