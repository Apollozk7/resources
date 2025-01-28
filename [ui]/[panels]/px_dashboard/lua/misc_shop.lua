--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local rot=0
local tick=0
local time=0
local random=false

ui.backTrigger=true

function getAward(r)
    r=math.abs(r)

    local t={
        {name="exp", action=function() return (r >= 0 and r <= 22) end},
        {name="kick", action=function() return (r >= 23 and r <= 45) end},
        {name="pp", action=function() return (r >= 46 and r <= 67) end},
        {name="money", action=function() return (r >= 68 and r <= 90) end},
        {name="kick", action=function() return (r >= 91 and r <= 112) end},
        {name="pp", action=function() return (r >= 113 and r <= 135) end},
        {name="money", action=function() return (r >= 136 and r <= 157) end},
        {name="exp", action=function() return (r >= 158 and r <= 180) end},
        {name="pp", action=function() return (r >= 181 and r <= 202) end},
        {name="money", action=function() return (r >= 203 and r <= 225) end},
        {name="kick", action=function() return (r >= 226 and r <= 247) end},
        {name="pp", action=function() return (r >= 248 and r <= 270) end},
        {name="money", action=function() return (r >= 271 and r <= 292) end},
        {name="exp", action=function() return (r >= 293 and r <= 315) end},
        {name="pp", action=function() return (r >= 316 and r <= 337) end},
        {name="money", action=function() return (r >= 338 and r <= 360) end},
    }
    for i,v in pairs(t) do
        if(v.action())then
            triggerServerEvent("dashboard.getElipseAward", resourceRoot, v.name)
            break
        end
    end
end

ui.rendering["Sklep z dodatkami"], desc=function(a, mainA)
    local uid=getElementData(localPlayer, "user:uid")
    if(not uid)then return end

    a=a > mainA and mainA or a

    local texs=assets.textures["Sklep z dodatkami"]
    if(not texs or (texs and #texs < 1))then return false end

    -- header
    dxDrawText("Sklep z dodatkami", 426/zoom, 63/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText("Wygraj świetne nagrody, co kolejny dzień otrzymasz darmowe losowanie.", 426/zoom, 93/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")

    -- right info
    dxDrawText("Stan konta:", sw-274/zoom, 63/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText(ui.info.user.premiumPoints, sw-160/zoom, 60/zoom, 0, 0, tocolor(193,205,78, a), 1, assets.fonts[9], "left", "top")
    dxDrawImage(sw-160/zoom+dxGetTextWidth(ui.info.user.premiumPoints,1, assets.fonts[9])+10/zoom,65/zoom,18/zoom,23/zoom,texs[1],0, 0, 0, tocolor(255, 255, 255, a))

    -- elipse
    if((getTickCount()-tick) < time and random)then
        local plus=(time-(getTickCount()-tick))/1000
        rot=rot+plus*3
        rot=rot+0.5
        if(rot > 360)then
            rot=0
        end
    end

    dxDrawImage(473/zoom, 184/zoom, 764/zoom, 764/zoom, texs[6], rot, 0, 0, tocolor(255, 255, 255, a))
    dxDrawImage(473/zoom+(764-250)/2/zoom-50/2/zoom, 184/zoom+(764-250)/2/zoom, 250/zoom, 250/zoom, texs[7], 0, 0, 0, tocolor(255, 255, 255, a))

    if(not ui.buttons["misc_shop_1"])then
        ui.buttons["misc_shop_1"]=buttons:createButton(473/zoom+(764-147)/2/zoom, 184/zoom+764/zoom-243/zoom, 147/zoom, 38/zoom, "LOSUJ", a, 9, false, false, ":px_dashboard/textures/7/button.png")
    else
        onClick(473/zoom+(764-147)/2/zoom, 184/zoom+764/zoom-243/zoom, 147/zoom, 38/zoom, function()
            if(SPAM.getSpam())then return end

            if(ui.info.user.randomElipse > 0)then
                if(not random and ui.backTrigger)then
                    triggerServerEvent("take.randomElipse", resourceRoot)

                    ui.backTrigger=false
                end
            else
                noti:noti("Nie masz czym losować!", "error")
            end
        end)
    end

    -- elipse right
    dxDrawText("Posiadasz "..ui.info.user.randomElipse.." losowań", sw-613/zoom, 402/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText("Nowe losowanie dostępne jutro", sw-613/zoom, 435/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")

    dxDrawImage(sw-611/zoom, sh-591/zoom, 213/zoom, 249/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawText("Losowanie", sw-611/zoom, sh-591/zoom+22/zoom, 213/zoom+sw-611/zoom, 249/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[5], "center", "top")
    dxDrawText("(1 raz)", sw-611/zoom, sh-591/zoom+46/zoom, 213/zoom+sw-611/zoom, 249/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[2], "center", "top")
    dxDrawText("20", sw-611/zoom, sh-591/zoom+170/zoom, 213/zoom+sw-611/zoom, 249/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[5], "center", "top")
    dxDrawImage(sw-611/zoom+(213)/2/zoom+dxGetTextWidth("20",1, assets.fonts[5])/2,sh-591/zoom+170/zoom+5/zoom,12/zoom,15/zoom,texs[1], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawImage(sw-611/zoom+(213-68)/2/zoom, sh-591/zoom+(249-68)/2/zoom, 68/zoom, 68/zoom, texs[4], 0, 0, 0, tocolor(255, 255, 255, a))
    if(not ui.buttons["misc_shop_2"])then
        ui.buttons["misc_shop_2"]=buttons:createButton(sw-611/zoom+(213-147)/2/zoom, sh-591/zoom+205/zoom, 147/zoom, 38/zoom, "ZAKUP", a, 9, false, false, ":px_dashboard/textures/7/button.png", {169,147,74})
    else
        onClick(sw-611/zoom+(213-147)/2/zoom, sh-591/zoom+205/zoom, 147/zoom, 38/zoom, function()
            if(SPAM.getSpam())then return end
            triggerServerEvent("dashboard.buyRandomElipse", resourceRoot, 1, 20)
        end)
    end

    dxDrawImage(sw-384/zoom, sh-591/zoom, 213/zoom, 249/zoom, texs[3], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawText("Losowanie", sw-384/zoom, sh-591/zoom+22/zoom, 213/zoom+sw-384/zoom, 249/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[5], "center", "top")
    dxDrawText("(10 razy)", sw-384/zoom, sh-591/zoom+46/zoom, 213/zoom+sw-384/zoom, 249/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[2], "center", "top")
    dxDrawText("200", sw-384/zoom, sh-591/zoom+170/zoom, 213/zoom+sw-384/zoom, 249/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[5], "center", "top")
    dxDrawImage(sw-384/zoom+(213)/2/zoom+dxGetTextWidth("200",1, assets.fonts[5])/2,sh-591/zoom+170/zoom+5/zoom,12/zoom,15/zoom,texs[1], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawImage(sw-384/zoom+(213-68)/2/zoom, sh-591/zoom+(249-68)/2/zoom, 68/zoom, 68/zoom, texs[4], 0, 0, 0, tocolor(255, 255, 255, a))
    if(not ui.buttons["misc_shop_3"])then
        ui.buttons["misc_shop_3"]=buttons:createButton(sw-384/zoom+(213-147)/2/zoom, sh-591/zoom+205/zoom, 147/zoom, 38/zoom, "ZAKUP", a, 9, false, false, ":px_dashboard/textures/7/button.png", {169,147,74})
    else
        onClick(sw-384/zoom+(213-147)/2/zoom, sh-591/zoom+205/zoom, 147/zoom, 38/zoom, function()
            if(SPAM.getSpam())then return end
            triggerServerEvent("dashboard.buyRandomElipse", resourceRoot, 10, 200)
        end)
    end
end

addEvent("losuj", true)
addEventHandler("losuj", resourceRoot, function()
    random=true
    time=math.random(1000,4000)
    tick=getTickCount()

    setTimer(function()
        getAward(math.floor(rot))
        random=false
    end, time, 1)
    
    ui.backTrigger=true
end)