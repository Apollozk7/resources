--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui.rendering["upgrades"]=function(execute, a)
    local myRanking=ui.info.myRanking
    if(myRanking)then
        local myUpgrades=fromJSON(myRanking.upgrades) or {}

        dxDrawText("Posiadasz "..myRanking.points.." pkt.", sw/2-689/2/zoom+2, sh/2-595/2/zoom, sw/2-689/2/zoom+2+689/zoom-50/zoom, sh/2-595/2/zoom+42/zoom, tocolor(150,150,150, a), 1, assets.fonts[1], "right", "center")

        local tbl=fromJSON(ui.info.sql.upgrades) or {}
        for i,v in pairs(tbl) do
            local upg=myUpgrades[v.name]

            local sY=(92/zoom)*(i-1)
            dxDrawImage(sw/2-689/2/zoom+2, sh/2-595/2/zoom+42/zoom+sY, 684/zoom, 91/zoom, assets.textures[12], 0, 0, 0, tocolor(255,255,255,a))

            if(assets.upgrades[v.icon])then
                dxDrawImage(sw/2-689/2/zoom+2+23/zoom, sh/2-595/2/zoom+42/zoom+sY+(91-58)/2/zoom, 58/zoom, 58/zoom, assets.upgrades[v.icon], 0, 0, 0, tocolor(255,255,255,a))
            end

            dxDrawText(v.name, sw/2-689/2/zoom+2+105/zoom, sh/2-595/2/zoom+42/zoom+sY, 684/zoom, 91/zoom+sh/2-595/2/zoom+42/zoom+sY-40/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "left", "center")
            dxDrawText(v.desc, sw/2-689/2/zoom+2+105/zoom, sh/2-595/2/zoom+42/zoom+sY, 684/zoom, 91/zoom+sh/2-595/2/zoom+42/zoom+sY, tocolor(120, 120, 120, a), 1, assets.fonts[8], "left", "center")
            dxDrawText(v.points.." pkt.", sw/2-689/2/zoom+2+105/zoom, sh/2-595/2/zoom+42/zoom+sY, 684/zoom, 91/zoom+sh/2-595/2/zoom+42/zoom+sY+40/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "center")

            local color={86,86,86}
            dxDrawRectangle(sw/2-689/2/zoom+2, sh/2-595/2/zoom+42/zoom+sY+91/zoom-1, 684/zoom, 1, tocolor(color[1],color[2],color[3],a))

            if(not buttons.objects[i])then
                buttons.objects[i]=buttons.export:createButton(sw/2-689/2/zoom+2+514/zoom, sh/2-595/2/zoom+42/zoom+sY+(91-38)/2/zoom, 147/zoom, 38/zoom, upg == true and "WYŁĄCZ" or not upg and "ZAKUP" or "WŁĄCZ", a, 10, false, false, ":px_jobs_settings/textures/button_icon.png", (upg == true) and {132,39,39})
            else
                onClick(sw/2-689/2/zoom+2+514/zoom, sh/2-595/2/zoom+42/zoom+sY+(91-38)/2/zoom, 147/zoom, 38/zoom, function()
                    if(SPAM.getSpam())then return end

                    if(not myUpgrades[v.name])then
                        if(myRanking.points >= v.points)then
                            triggerLatentServerEvent("buy.upgrade", resourceRoot, {
                                job=ui.info.name,
                                upgrade=v,
                            })
                        else
                            noti:noti("Nie posiadasz wystarczającej ilości punktów.", "error")
                        end
                    else
                        if(not getElementData(localPlayer, "user:job"))then
                            triggerLatentServerEvent("upgrade.set.state", resourceRoot, {
                                job=ui.info.name,
                                upgrade=v,
                            })
                        else
                            noti:noti("Najpierw zakończ pracę.", "error")
                        end
                    end
                end)
            end
        end
    end
end