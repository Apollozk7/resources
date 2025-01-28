--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local P={}

P.peds={
    {2175.7671,2478.3293,10.8203,88.3021},
    {1692.1160,2088.0115,10.7991,166.9387},
    {1857.1113,2379.5356,10.9799,98.8552},
    {955.2017,2022.5665,10.8455,258.7911},
    {2198.8264,2063.0454,10.8203,324.5363},
    {1339.2930,2352.3049,10.8203,54.6982},
    {2107.1377,2649.1331,10.8130,11.6710},
    {2229.3259,1413.4248,11.0625,323.1700},
    {2099.7341,889.2855,10.8130,325.5872},
    {1681.3849,1162.1453,10.8203,143.5729},
    {1975.3148,2097.5471,10.8203,40.5982},
    {2197.9797,1436.0214,11.0547,111.4143},
    {1581.3353,2217.2161,11.0625,204.7204},
    {-154.9950,1067.7755,19.7500,52.7543},
    {-138.3843,1240.6957,19.2827,220.5897},
    {116.4798,1110.7413,13.6094,254.0271},
    {-877.0364,1525.5819,25.9141,21.3311},
    {-819.6160,1504.3529,19.8486,134.6224},
    {-634.9661,1452.9584,13.6172,313.3350},
    {-2548.4587,2369.5947,5.0006,212.8980},
    {-2247.0925,2363.1301,4.9891,128.9452},
    {-2462.4771,2509.6919,16.8697,170.8427},
    {-1527.8873,2688.5796,55.8359,238.7685},
    {-1476.9552,2612.5198,58.7812,38.9495},
    {-186.8688,-318.5338,1.4219,188.8137},
    {153.5013,-185.3277,1.5781,2.8497},
    {309.2831,-56.6300,1.5781,237.1570},
    {1513.3707,15.1449,24.1406,55.0639},
    {2156.9885,-107.2840,2.6839,90.7608},
    {2276.2283,-68.7672,26.5687,288.3203},
    {2268.8071,65.9525,26.4844,115.8958},
    {1248.5648,244.5178,19.5547,16.1440},
    {1292.0873,162.6598,20.4609,87.8532},
    {-1858.6184,-180.7539,18.9105,270},
}

P.descs={
    "Poratuj groszem",
    "Rzuć groszem",
    "Daj na piwo",
    "Daj na fajki",
    "Daj na jedzenie",
}

P.skins={
    78,
    79,
    134,
    135,
    136,
    137,
    160,
    200,
    230,
    239,
}

P.respawn = (1000*60)*60 -- czas w ms do respawnu :p

P.create=function(i)
    local v=P.peds[i]
    if(v)then
        local desc=P.descs[math.random(1,#P.descs)]
        local skin=P.skins[math.random(1,#P.skins)]
        v.ped=createPed(skin, v[1], v[2], v[3], v[4])
        setElementFrozen(v.ped,true)
        setElementData(v.ped, "ped:desc", {name="Pobliski żebrak",desc=desc})

        v.shape=createColSphere(v[1], v[2], v[3], 5)
        setElementData(v.shape, "index", i, false)

        setElementData(v.ped, "interaction", {options={
            {name="Przekaż pieniądze", alpha=150, animate=false, tex=":px_beggars/assets/images/hajs.png"},
        }, scriptName="px_beggars", dist=2, info=i})

        setTimer(function()
            triggerClientEvent(root, "update", resourceRoot, v.ped)
        end, 500, 1)
    end
end

for i,v in pairs(P.peds) do
    P.create(i)
end

P.destroy=function(i)
    local v=P.peds[i]
    if(v)then
        checkAndDestroy(v.ped)
        checkAndDestroy(v.shape)

        setTimer(function()
            P.create(i)
        end, P.respawn, 1)
    end
end

function takeRandomItem(player,eq)
    local items={}
    for i,v in pairs(eq) do
        if(v)then
            items[#items+1]=v
        end
    end

    local rnd=#items > 1 and math.random(1,#items) or 1
    for i,v in pairs(eq) do
        if(v and v.name == items[rnd].name)then
            v.value=v.value-1
            if(v.value < 1)then
                eq[i]=nil
            end
        end
    end

    setElementData(player, "user:eq", eq)

    return string.lower(items[rnd].name)
end

P.cmd=function(player, money, i)
    if(P.peds[i] and P.peds[i].ped and isElement(P.peds[i].ped))then
        if(i and money > 0 and getPlayerMoney(player) >= money)then
            local rnd = math.random(1,5)

            local eq=getElementData(player, "user:eq") or {}
            if(#eq < 1 and rnd == 4)then
                rnd=1
            end

            if(money >= 1000)then
                if(not exports.px_achievements:isPlayerHaveAchievement(player, "Wielkie serce"))then
                    exports.px_achievements:getAchievement(player, "Wielkie serce")
                end
            end

            exports.px_quests:updateQuest(player, "Znajdź żebraka i poratuj go 10$", money)

            if(rnd == 1)then
                exports.px_noti:noti("Żebrak zabrał "..money.."$ i uciekł.", player)

                takePlayerMoney(player, money)
                exports.px_discord:sendDiscordLogs("[ZEBRAKI] Dano "..money.."$", "hajs", player)

                P.destroy(i)
            elseif(rnd == 2 or rnd == 3 or rnd == 5)then
                local exp=math.random(1,3)

                exports.px_noti:noti("Przekazałeś "..money.."$ dla żebraka. Za dobry uczynek otrzymujesz "..exp.."RP.", player)

                takePlayerMoney(player, money)
                exports.px_discord:sendDiscordLogs("[ZEBRAKI] Dano "..money.."$", "hajs", player)

                local xp=getElementData(player, "user:reputation") or 0
                setElementData(player, "user:reputation", xp+exp)

                P.destroy(i)
            elseif(rnd == 4)then
                local item=takeRandomItem(player,eq)
                exports.px_noti:noti("Żebrak zabrał "..item.." i uciekł.", player)

                P.destroy(i)
            end
        end
    end
end

addEvent("get", true)
addEventHandler("get", resourceRoot, function(money, id)
    if(not id or not tonumber(id))then return end

    P.cmd(client, money, id)
end)

addEventHandler("onColShapeHit",resourceRoot,function(hit,dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and not isPedInVehicle(hit) and dim)then
        local x,y,z=getElementPosition(source)
        triggerClientEvent(hit, "sound", resourceRoot, x, y,z)
    end
end)

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end
