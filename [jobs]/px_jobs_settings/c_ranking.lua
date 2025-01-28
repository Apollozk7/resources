--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local bonus={
    [1]=10,
    [2]=7,
    [3]=5,
}

ui.rankingBorder={
    [1]={
        alpha=255,
    },

    [2]={
        alpha=150,
    },

    selected=1,
    alpha=255
}

ui.rendering["ranking"]=function(execute, a)
    if(not ui.rankingBorder.x or not ui.rankingBorder.w)then
        ui.rankingBorder.x=sw/2-83/zoom-40/zoom
        ui.rankingBorder.w=dxGetTextWidth("Tygodniowy", 1, assets.fonts[1])
    end

    -- menu
    local a_1=a > 75 and 75 or a

    local alpha_1=ui.rankingBorder[1].alpha
    local alpha_2=ui.rankingBorder[2].alpha

    alpha_1=a > alpha_1 and alpha_1 or a
    alpha_2=a > alpha_2 and alpha_2 or a

    dxDrawRectangle(sw/2-689/2/zoom, sh/2-595/2/zoom+42/zoom, 689/zoom, 50/zoom, tocolor(30,30,30,a_1))
    dxDrawText("Tygodniowy", sw/2-83/zoom-40/zoom, sh/2-595/2/zoom+42/zoom+(50-24)/2/zoom, 83/zoom+sw/2-83/zoom-40/zoom, 24/zoom+sh/2-595/2/zoom+42/zoom+(50-24)/2/zoom, tocolor(200, 200, 200, alpha_1), 1, assets.fonts[1], "left", "top")
    dxDrawText("Ogólny", sw/2+40/zoom, sh/2-595/2/zoom+42/zoom+(50-24)/2/zoom, 55/zoom+sw/2+40/zoom, 24/zoom+sh/2-595/2/zoom+42/zoom+(50-24)/2/zoom, tocolor(200, 200, 200, alpha_2), 1, assets.fonts[1], "left", "top")
    dxDrawRectangle(ui.rankingBorder.x, sh/2-595/2/zoom+42/zoom+15/zoom+24/zoom, ui.rankingBorder.w, 1, tocolor(33,147,176,a))
    onClick(sw/2-83/zoom-40/zoom, sh/2-595/2/zoom+55/zoom, 93/zoom, 24/zoom, function()
        if(not ui.animate and ui.rankingBorder.selected ~= 1)then
            ui.animate=animate(ui.rankingBorder.x, sw/2-83/zoom-40/zoom, "Linear", 250, function(a)
                ui.rankingBorder.x=a
            end,function()
                ui.animate=nil
                ui.rankingBorder.selected=1
            end)

            animate(ui.rankingBorder[1].alpha, 255, "Linear", 250, function(a)
                ui.rankingBorder[1].alpha=a
            end)

            animate(ui.rankingBorder[2].alpha, 150, "Linear", 250, function(a)
                ui.rankingBorder[2].alpha=a
            end)

            animate(ui.rankingBorder.alpha, 0, "Linear", 100, function(a)
                ui.rankingBorder.alpha=a
            end, function()
                ui.rankingBorder.selected=1
                setTimer(function()
                    animate(ui.rankingBorder.alpha, 255, "Linear", 100, function(a)
                        ui.rankingBorder.alpha=a
                    end)
                end, 50, 1)
            end)

            animate(ui.rankingBorder.w, dxGetTextWidth("Tygodniowy", 1, assets.fonts[1]), "Linear", 250, function(a)
                ui.rankingBorder.w=a
            end)
        end
    end)
    onClick(sw/2+40/zoom, sh/2-595/2/zoom+55/zoom, 55/zoom, 24/zoom, function()
        if(not ui.animate and ui.rankingBorder.selected ~= 2)then
            ui.animate=animate(ui.rankingBorder.x, sw/2+40/zoom, "Linear", 250, function(a)
                ui.rankingBorder.x=a
            end,function()
                ui.animate=nil
            end)

            animate(ui.rankingBorder[1].alpha, 150, "Linear", 250, function(a)
                ui.rankingBorder[1].alpha=a
            end)

            animate(ui.rankingBorder[2].alpha, 255, "Linear", 250, function(a)
                ui.rankingBorder[2].alpha=a
            end)

            animate(ui.rankingBorder.alpha, 0, "Linear", 100, function(a)
                ui.rankingBorder.alpha=a
            end, function()
                ui.rankingBorder.selected=2
                setTimer(function()
                    animate(ui.rankingBorder.alpha, 255, "Linear", 100, function(a)
                        ui.rankingBorder.alpha=a
                    end)
                end, 50, 1)
            end)

            animate(ui.rankingBorder.w, dxGetTextWidth("Ogólny", 1, assets.fonts[1]), "Linear", 250, function(a)
                ui.rankingBorder.w=a
            end)
        end
    end)
    --

    a=a > ui.rankingBorder.alpha and ui.rankingBorder.alpha  or a

    local ranking_table=ui.rankingBorder.selected == 1 and ui.info.rankings or ui.info.rankingsAll
    local points=ui.rankingBorder.selected == 1 and "week_points" or "ranking_points"

    local top_1=ranking_table[1]
    if(top_1)then
        local avatar=avatars:getPlayerAvatar(top_1.login)
        dxDrawImage(sw/2-689/2/zoom+(689-86)/2/zoom+2, sh/2-595/2/zoom+141/zoom-2, 86/zoom, 86/zoom, avatar, 0, 0, 0, tocolor(255,255,255,a))
        dxDrawImage(sw/2-689/2/zoom+(689-157)/2/zoom, sh/2-595/2/zoom+110/zoom, 157/zoom, 114/zoom, assets.textures[14], 0, 0, 0, tocolor(255,255,255,a))
        dxDrawText("1", sw/2-689/2/zoom+(689-157)/2/zoom+1, sh/2-595/2/zoom+110/zoom+14/zoom, 157/zoom+sw/2-689/2/zoom+(689-157)/2/zoom, 114/zoom, tocolor(0, 0, 0, a), 1, assets.fonts[9], "center", "top")
        dxDrawText(top_1.login, sw/2-689/2/zoom+(689-157)/2/zoom+1, sh/2-595/2/zoom+110/zoom+123/zoom, 157/zoom+sw/2-689/2/zoom+(689-157)/2/zoom, 114/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
        dxDrawText(top_1[points].." pkt.", sw/2-689/2/zoom+(689-157)/2/zoom+1, sh/2-595/2/zoom+110/zoom+145/zoom, 157/zoom+sw/2-689/2/zoom+(689-157)/2/zoom, 114/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[1], "center", "top")
    
        if(ui.rankingBorder.selected == 1)then
            dxDrawText("( + "..bonus[1].."% w następnym tygodniu )", sw/2-689/2/zoom+(689-157)/2/zoom+1, sh/2-595/2/zoom+110/zoom+145/zoom+20/zoom, 157/zoom+sw/2-689/2/zoom+(689-157)/2/zoom, 114/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[5], "center", "top")
        end
    end

    local top_2=ranking_table[2]
    if(top_2)then
        local avatar=avatars:getPlayerAvatar(top_2.login)
        dxDrawImage(sw/2-689/2/zoom+96/zoom, sh/2-595/2/zoom+132/zoom, 67/zoom, 67/zoom, avatar, 0, 0, 0, tocolor(255,255,255,a))
        dxDrawText("2 nd", sw/2-689/2/zoom+96/zoom, sh/2-595/2/zoom+132/zoom-25/zoom, 67/zoom+sw/2-689/2/zoom+96/zoom, 67/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[9], "center", "top")
        dxDrawText(top_2.login, sw/2-689/2/zoom+96/zoom, sh/2-595/2/zoom+132/zoom+76/zoom, 67/zoom+sw/2-689/2/zoom+96/zoom, 67/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
        dxDrawText(top_2[points].." pkt.", sw/2-689/2/zoom+96/zoom, sh/2-595/2/zoom+132/zoom+97/zoom, 67/zoom+sw/2-689/2/zoom+96/zoom, 67/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[1], "center", "top")
    
        if(ui.rankingBorder.selected == 1)then
            dxDrawText("( + "..bonus[2].."% w następnym tygodniu )", sw/2-689/2/zoom+96/zoom, sh/2-595/2/zoom+132/zoom+97/zoom+20/zoom, 67/zoom+sw/2-689/2/zoom+96/zoom, 67/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[5], "center", "top")
        end
    end

    local top_3=ranking_table[3]
    if(top_3)then
        local avatar=avatars:getPlayerAvatar(top_3.login)
        dxDrawImage(sw/2-689/2/zoom+96/zoom+423/zoom, sh/2-595/2/zoom+132/zoom, 67/zoom, 67/zoom, avatar, 0, 0, 0, tocolor(255,255,255,a))
        dxDrawText("3 rd", sw/2-689/2/zoom+96/zoom+423/zoom, sh/2-595/2/zoom+132/zoom-25/zoom, 67/zoom+sw/2-689/2/zoom+96/zoom+423/zoom, 67/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[9], "center", "top")
        dxDrawText(top_3.login, sw/2-689/2/zoom+96/zoom+423/zoom, sh/2-595/2/zoom+132/zoom+76/zoom, 67/zoom+sw/2-689/2/zoom+96/zoom+423/zoom, 67/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
        dxDrawText(top_3[points].." pkt.", sw/2-689/2/zoom+96/zoom+423/zoom, sh/2-595/2/zoom+132/zoom+97/zoom, 67/zoom+sw/2-689/2/zoom+96/zoom+423/zoom, 67/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[1], "center", "top")
    
        if(ui.rankingBorder.selected == 1)then
            dxDrawText("( + "..bonus[3].."% w następnym tygodniu )", sw/2-689/2/zoom+96/zoom+423/zoom, sh/2-595/2/zoom+132/zoom+97/zoom+20/zoom, 67/zoom+sw/2-689/2/zoom+96/zoom+423/zoom, 67/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[5], "center", "top")
        end
    end

    local k=0
    for i=4,8 do
        local v=ranking_table[i]
        if(v)then
            k=k+1

            local sY=(50/zoom)*(k-1)
            local avatar=avatars:getPlayerAvatar(v.login)
            dxDrawImage(sw/2-689/2/zoom+73/zoom, sh/2-595/2/zoom+306/zoom+sY, 565/zoom, 36/zoom, assets.textures[13], 0, 0, 0, tocolor(255,255,255,a))
            dxDrawImage(sw/2-689/2/zoom+46/zoom, sh/2-595/2/zoom+300/zoom+sY, 46/zoom, 46/zoom, avatar, 0, 0, 0, tocolor(255,255,255,a))

            dxDrawText(i..". "..v.login, sw/2-689/2/zoom+73/zoom+30/zoom, sh/2-595/2/zoom+306/zoom+sY, 565/zoom, 36/zoom+sh/2-595/2/zoom+306/zoom+sY, tocolor(200, 200, 200, a), 1, assets.fonts[1], "left", "center")
            dxDrawText(v[points].." punktów", sw/2-689/2/zoom+73/zoom+250/zoom, sh/2-595/2/zoom+306/zoom+sY, 565/zoom, 36/zoom+sh/2-595/2/zoom+306/zoom+sY, tocolor(200, 200, 200, a), 1, assets.fonts[1], "left", "center")
        end
    end

    dxDrawText("Twój wynik w danym rankingu wynosi "..ui.info.myRanking[points].." punktów.", sw/2-689/2/zoom+2, sh/2-595/2/zoom+42/zoom+500/zoom, 684/zoom+sw/2-689/2/zoom+2, sh/2-595/2/zoom+42/zoom+500/zoom+40/zoom, tocolor(200, 200, 200, a>150 and 150 or a), 1, assets.fonts[5], "center", "center")
end