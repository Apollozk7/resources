--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local bonusTrigger=false

local bonus={
    [1]={type="rp", value=2},
    [2]={type="money", value=200},
    [3]={type="money", value=300},
    [4]={type="rp", value=4},
    [5]={type="money", value=400},
    [6]={type="pp", value=5},
    [7]={type="rp", value=6},
    [8]={type="money", value=500},
    [9]={type="money", value=600},
    [10]={type="rp", value=8},
    [11]={type="money", value=700},
    [12]={type="pp", value=10},
    [13]={type="rp", value=10},
    [14]={type="money", value=800},
    [15]={type="money", value=900},
    [16]={type="rp", value=12},
    [17]={type="money", value=1000},
    [18]={type="pp", value=15},
    [19]={type="rp", value=14},
    [20]={type="money", value=1100},
    [21]={type="money", value=1200},
    [22]={type="rp", value=16},
    [23]={type="money", value=1300},
    [24]={type="pp", value=20},
    [25]={type="rp", value=18},
    [26]={type="money", value=1400},
    [27]={type="money", value=1500},
    [28]={type="rp", value=20},
    [29]={type="money", value=1600},
    [30]={type="pp", value=25},
}

-- table

local t={}
for i=1,5 do
    local sY=(182/zoom)*(i-1)
    for i=1,6 do
        local sX=(237/zoom)*(i-1)
        t[#t+1]={sX=sX,sY=sY}
    end
end

--

ui.rendering["Dzienny bonus"], desc=function(a, mainA)
    local uid=getElementData(localPlayer, "user:uid")
    if(not uid)then return end

    a=a > mainA and mainA or a

    local texs=assets.textures["Dzienny bonus"]
    if(not texs or (texs and #texs < 1))then return false end

    -- header
    dxDrawText("Dzienny bonus", 426/zoom, 63/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText("Otrzymuj nagrody za codzienną rozgrywkę!", 426/zoom, 93/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")
    
    -- body

    -- info
    local online=getElementData(localPlayer, "user:sesion_time") or 0
    local getBonus=online >= 30
    local elapsedMinutes=math.floor(30-online)
    local day=ui.info.user.bonus_day
    --

    local k=0
    for i=(day == 1 and 1 or day-1),(day == 1 and 3 or day+1) do
        k=k+1

        local sX=(310/zoom)*(k-1)
        dxDrawImage(381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 310/zoom, 290/zoom, 450/zoom, texs[1], 0, 0, 0, tocolor(255,255,255,a))
        if((day == 1 and i == 1) or (day ~= 1 and day == i))then
            dxDrawImage(381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX+(290-217)/2/zoom, 310/zoom, 217/zoom, 109/zoom, texs[2], 0, 0, 0, tocolor(255,255,255,a))
        end
        dxDrawRectangle(381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 310/zoom, 290/zoom, 1, tocolor(80,80,80,a))

        dxDrawText("Dzień", 381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 310/zoom+40/zoom, 290/zoom+381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 450/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[6], "center", "top")
        dxDrawText(i, 381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 310/zoom+70/zoom, 290/zoom+381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 450/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[6], "center", "top")
    
        -- award
        if(i > day)then
            dxDrawImage(381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX+(290-60)/2/zoom, 310/zoom+123/zoom, 60/zoom, 80/zoom, texs[6], 0, 0, 0, tocolor(255,255,255,a))

            dxDrawText("Zawartość\nukryta", 381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 310/zoom+244/zoom, 290/zoom+381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 450/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
        
            dxDrawText(((day-i) == -1) and "Zaloguj się jutro\naby odebrać bonus" or "Zaloguj się pojutrze\naby odebrać bonus", 381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 310/zoom+373/zoom, 290/zoom+381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 450/zoom, tocolor(150, 150,150, a), 1, assets.fonts[7], "center", "top")
        else
            local endDay=i
            local bonusAward=1
            local percent=math.floor(i/30)
            if(percent > 0)then
                for i=1,percent do
                    bonusAward=bonusAward+1
                    endDay=endDay-30
                end
            end

            if(endDay == 0)then
                endDay=30
                bonusAward=bonusAward-1
            end
    
            local b=bonus[endDay]
            if(b)then
                dxDrawImage(381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX+(290-80)/2/zoom, 310/zoom+123/zoom, 80/zoom, 80/zoom, texs[b.type == "money" and 4 or b.type == "rp" and 3 or b.type == "pp" and 5], 0, 0, 0, tocolor(255,255,255,a))

                local text=b.type == "money" and "Gotówka" or b.type == "rp" and "Reputacja" or b.type == "pp" and "Punkty premium"
                local text_2=b.type == "money" and "#b3b23f$ #b1b1b1"..(b.value*bonusAward) or b.type == "rp" and (b.value*bonusAward) or b.type == "pp" and (b.value*bonusAward)
                dxDrawText(text.."\n"..text_2, 381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 310/zoom+244/zoom, 290/zoom+381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 450/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top", false, false, false, true)
            
                if(ui.info.user.getBonusDay == 1 or day > i)then
                    dxDrawText("Nagroda została już\nodebrana", 381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 310/zoom+373/zoom, 290/zoom+381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 450/zoom, tocolor(150, 150,150, a), 1, assets.fonts[7], "center", "top")
                elseif(getBonus)then
                    dxDrawText("Odbierz", 381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX+(290-75)/2/zoom, 310/zoom+373/zoom, 75/zoom+381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX+(290-75)/2/zoom, 30/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[5], "center", "top")
                    onClick(381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX+(290-75)/2/zoom, 310/zoom+373/zoom, 75/zoom, 30/zoom, function()
                        if(not bonusTrigger)then
                            bonusTrigger=true
                            triggerServerEvent("get.bonus.award", resourceRoot, b.type, (b.value*bonusAward))
                        end
                    end)
                else
                    dxDrawText("Do odebrania pozostało:\n"..elapsedMinutes.." minut", 381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 310/zoom+373/zoom, 290/zoom+381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX, 450/zoom, tocolor(150, 150,150, a), 1, assets.fonts[7], "center", "top")
                end
            end
        end
        --

        dxDrawRectangle(381/zoom+((sw-381/zoom)/2-290/2/zoom)-310/zoom+sX+(290-20)/2/zoom, 310/zoom+324/zoom, 20/zoom, 1, tocolor(80,80,80,a))
    end
end

addEvent("bonusTrigger", true)
addEventHandler("bonusTrigger", resourceRoot, function()
    bonusTrigger=false
end)