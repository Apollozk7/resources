--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local noti = exports.px_noti

local VIP={}
local GOLD={}

-- money for 1 hour

VIP.time=0
GOLD.time=0

setTimer(function()
    if(getElementData(localPlayer, "user:afk"))then return end

    if(getElementData(localPlayer, "user:premium"))then
        VIP.time=VIP.time+1
        if(VIP.time == 60)then
            noti = exports.px_noti
            
            VIP.time=0

            local xp = math.random(1,2)
            noti:noti("Otrzymujesz 450$ oraz "..xp.."RP za pełną godzine gry.")
            triggerServerEvent("premium:give", resourceRoot, 450, xp)
        end
    end

    if(getElementData(localPlayer, "user:gold"))then
        GOLD.time=GOLD.time+1
        if(GOLD.time == 30)then
            noti = exports.px_noti

            GOLD.time=0

            local xp = math.random(1,3)
            noti:noti("Otrzymujesz 300$ oraz "..xp.."RP za pół godziny gry.")
            triggerServerEvent("premium:give", resourceRoot, 300, xp)
        end
    end
end, (1000*60), 0)