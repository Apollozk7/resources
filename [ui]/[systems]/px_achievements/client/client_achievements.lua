--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local sw,sh = guiGetScreenSize()
local zoom=1920/sw

local blur=exports.blur
local tick=getTickCount()

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Bold.ttf", 12},
        {":px_assets/fonts/Font-Medium.ttf", 11},
    },

    textures={},
    textures_paths={
        "assets/images/bg.png",
        "assets/images/badge.png",
        "assets/images/row.png",
    },
}

assets.create = function()
    for k,t in pairs(assets) do
        if(k=="fonts_paths")then
            for i,v in pairs(t) do
                assets.fonts[i] = dxCreateFont(v[1], v[2]/zoom)
            end
        elseif(k=="textures_paths")then
            for i,v in pairs(t) do
                assets.textures[i] = dxCreateTexture(v, "argb", false, "clamp")
            end
        end
    end
end

assets.destroy = function()
    for k,t in pairs(assets) do
        if(k == "textures" or k == "fonts")then
            for i,v in pairs(t) do
                if(v and isElement(v))then
                    destroyElement(v)
                end
            end
            assets.fonts={}
            assets.textures={}
        end
    end
end

--

local UI = {}

function getAchievementsList(sort)
    if(sort)then
        local list={}
        local k=0
        for i,v in pairs(UI.list) do
            k=k+1

            v.name=i
            v.id=isPlayerHaveAchievement(i) and 2 or 1
            list[k]=v
        end
        table.sort(list,function(a,b) return a.id > b.id end)
        return list
    else
        local list={}
        local k=0
        for i,v in pairs(UI.list) do
            k=k+1

            v.name=i
            list[k]=v
        end
        return list
    end
end

UI.text=false

-- render

UI.onRender=function()
    local a=0
    if UI.text[5] == "join" then
        a = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount()-UI.text[4])/500, "Linear")
    elseif UI.text[5] == "quit" then
        a = interpolateBetween(255, 0, 0, 0, 0, 0, (getTickCount()-UI.text[4])/500, "Linear")

        if((getTickCount()-UI.text[4]) > 500)then
            UI.text=false

            removeEventHandler("onClientRender", root, UI.onRender)

            assets.destroy()
            return
        end
    end

    if (getTickCount()-UI.text[4]) > 10000 then
        UI.text[5] = "quit"
        UI.text[4] = getTickCount()
    end

    local aa=interpolateBetween(150,0,0,200,0,0,(getTickCount()-tick)/5000,"SineCurve")
    local rot=interpolateBetween(-15,0,0,15,0,0,(getTickCount()-tick)/5000,"SineCurve")

    aa=aa > a and a or aa
    dxDrawImage(sw/2-389/2/zoom, 89/zoom, 389/zoom, 389/zoom, assets.textures[1], -rot, 0, 0, tocolor(255, 255, 255, aa))
    dxDrawImage(sw/2-54/2/zoom, 250/zoom, 54/zoom, 63/zoom, assets.textures[2], rot, 0, 0, tocolor(255, 255, 255, a))

    local text=UI.text[1]
    local w=dxGetTextWidth(text, 1, assets.fonts[1])+200/zoom
    dxDrawImage(sw/2-w/2, 320/zoom, w, 24/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawText(text, sw/2-w/2+1, 320/zoom+1, w+sw/2-w/2+1, 24/zoom+320/zoom+1, tocolor(0, 0, 0, a), 1, assets.fonts[1], "center", "center")
    dxDrawText(text, sw/2-w/2, 320/zoom, w+sw/2-w/2, 24/zoom+320/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "center")

    local text2=UI.text[2].." (+"..UI.text[3].."RP)"
    dxDrawText(text2, sw/2-w/2+1, 320/zoom+1, w+sw/2-w/2+1, 24/zoom+320/zoom+1+60/zoom, tocolor(0, 0, 0, a), 1, assets.fonts[2], "center", "center")
    dxDrawText(text2, sw/2-w/2, 320/zoom, w+sw/2-w/2, 24/zoom+320/zoom+60/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[2], "center", "center")
end

-- functions

UI.isPlayerHaveAchievement=function(name)
    local list=getElementData(localPlayer, "user:achievements")
    if(getElementData(localPlayer, "user:uid") and list)then
        return list[name]
    end
    return true
end

UI.addPlayerAchievement=function(name)
    triggerServerEvent("addAchievement", resourceRoot, name)
end

setElementData(localPlayer, "user:achievements", {})

UI.getAchievement=function(name)
    UI.addPlayerAchievement(name)
end
addEvent("getAchievement",true)
addEventHandler("getAchievement",resourceRoot,UI.getAchievement)

UI.showAchievement = function(achievementData)
    if(not UI.text)then
        assets.create()
        blur=exports.blur
        addEventHandler("onClientRender", root, UI.onRender)
        playSound("assets/sounds/achievement.mp3")
    end

    UI.text = {achievementData.title, achievementData.description, achievementData.moneyPrize, getTickCount(), "join"}
end
addEvent("showAchievement",true)
addEventHandler("showAchievement",resourceRoot,UI.showAchievement)

function isPlayerHaveAchievement(...) return UI.isPlayerHaveAchievement(...) end
function getAchievement(...) return UI.getAchievement(...) end

UI.getMoneyAchievements=function()
    if(UI.text)then return end
    
    local money=getPlayerMoney(localPlayer)
    if(money >= 1000 and not UI.isPlayerHaveAchievement("Pierwsze pieniądze"))then
        UI.getAchievement("Pierwsze pieniądze")
    elseif(money >= 10000 and not UI.isPlayerHaveAchievement("Rozkręcasz się!"))then
        UI.getAchievement("Rozkręcasz się!")
    elseif(money >= 100000 and not UI.isPlayerHaveAchievement("Biznesmen"))then
        UI.getAchievement("Biznesmen")
    elseif(money >= 1000000 and not UI.isPlayerHaveAchievement("Bogacz"))then
        UI.getAchievement("Bogacz")
    end
end

-- milionerzy

local time=5000 -- czas co ile ma odswiezac osiagniecie z kasa :)
setTimer(function()
    UI.getMoneyAchievements()
end, time, 0)
UI.getMoneyAchievements()

-- useful

function getTime()
    local real = getRealTime()

    local year = real.year + 1900
    local month = real.month + 1
    local day = real.monthday
    local hour = real.hour
    local minute = real.minute

    return string.format("%04d", year).."."..string.format("%02d", month).."."..string.format("%02d", day).." "..string.format("%02d", hour)..":"..string.format("%02d", minute)
end
