--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

ui.rendering["upgrades"]=function(execute, a)
    local _,icons=ui.getTextures(execute)
    if(not icons)then return false end

    local row=math.floor(scroll.export:dxScrollGetPosition(scroll.objects[1]))+1
    local k=0
    for i=row,row+5 do
        local v=ui.sql.upgrades[i]
        if(v)then
            k=k+1

            local sY=(91/zoom)*(k-1)

            if(icons[v.icon])then
                dxDrawImage(sw/2-730/2/zoom+42/zoom+23/zoom, sh/2-595/2/zoom+42/zoom+sY+(91-58)/2/zoom, 58/zoom, 58/zoom, icons[v.icon], 0, 0, 0, tocolor(255,255,255,a))
            end

            dxDrawText(v.name, sw/2-730/2/zoom+42/zoom+23/zoom+58/zoom+24/zoom, sh/2-595/2/zoom+42/zoom+sY, (730-42)/zoom, 91/zoom+sh/2-595/2/zoom+42/zoom+sY-40/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "left", "center")
            dxDrawText(v.desc, sw/2-730/2/zoom+42/zoom+23/zoom+58/zoom+24/zoom, sh/2-595/2/zoom+42/zoom+sY, (730-42)/zoom, 91/zoom+sh/2-595/2/zoom+42/zoom+sY, tocolor(120, 120, 120, a), 1, assets.fonts[9], "left", "center")
            dxDrawText("#4eb451$ #b9babb"..v.cost, sw/2-730/2/zoom+42/zoom+23/zoom+58/zoom+24/zoom, sh/2-595/2/zoom+42/zoom+sY, (730-42)/zoom, 91/zoom+sh/2-595/2/zoom+42/zoom+sY+40/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[8], "left", "center", false, false, false, true)

            local color={86,86,86}
            dxDrawRectangle(sw/2-730/2/zoom+42/zoom, sh/2-595/2/zoom+42/zoom+sY+91/zoom-1, (730-42)/zoom, 1, tocolor(color[1],color[2],color[3],a))

            if(not buttons.objects[k])then
                buttons.objects[k]=buttons.export:createButton(sw/2-730/2/zoom+42/zoom+514/zoom, sh/2-595/2/zoom+42/zoom+sY+(91-38)/2/zoom, 147/zoom, 38/zoom, "ZAKUP", a, 10, false, false, ":px_jobs_settings/textures/button_icon.png")
            else
                if(v.have)then
                    buttons.export:buttonSetAlpha(buttons.objects[k], 0)
                else
                    buttons.export:buttonSetAlpha(buttons.objects[k], 255)
                    
                    onClick(sw/2-730/2/zoom+42/zoom+514/zoom, sh/2-595/2/zoom+42/zoom+sY+(91-38)/2/zoom, 147/zoom, 38/zoom, function()
                        if(ui.sql.org.money >= v.cost)then
                            if(SPAM.getSpam())then return end

                            triggerLatentServerEvent("buy.upgrade", resourceRoot, v, ui.sql.org.org)
                        else
                            exports.px_noti:noti("Organizacja nie posiada wystarczających funduszy.", "error")
                        end
                    end)
                end
            end
        end
    end

    if(not scroll.objects[1])then
        scroll.objects[1]=scroll.export:dxCreateScroll(sw/2-730/2/zoom+730/zoom-5, sh/2-581/2/zoom+42/zoom, 4/zoom, 4/zoom, 0, 6, ui.sql.upgrades, 581/zoom-42/zoom, a)
    end
end