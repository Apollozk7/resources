--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

DUTY={}

db=exports.px_connect
noti=exports.px_noti
achievements=exports.px_achievements

DUTY.createMarkers=function()
    db=exports.px_connect
    
    local r=db:query("select * from groups_fractions")
    for i,v in pairs(r) do
        local pos=split(v.pos, ",")
        local marker=createMarker(pos[1], pos[2], pos[3]-1, "cylinder", 1.2, 0, 100, 200)

        setElementData(marker, "text", {text="Służba "..v.tag,desc="Rozpoczynanie służby"})
        setElementData(marker, "icon", ":px_factions/assets/images/markerStart.png")
        setElementData(marker, "duty", v.tag, false)

        setElementDimension(marker, v.dim)
    end
end
DUTY.createMarkers()

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        db=exports.px_connect
        noti=exports.px_noti

        local data=getElementData(source, "duty")
        local tag=ADMIN.isPlayerInFaction(getPlayerName(hit), data)
        if(data and tag and data == tag)then
            local access=ADMIN.isPlayerHaveAccess(getPlayerName(hit), "Wejście na służbę")
            if(access)then
                local rank=ADMIN.getPlayerRank(getPlayerName(hit), tag)
                local payment=ADMIN.getPayment(rank,tag)
                local faction=getElementData(hit, "user:faction")

                triggerClientEvent(hit, "open:duty_gui", resourceRoot, data, {rank=rank,payment=payment})
            else
                noti:noti("Nie posiadasz takich uprawnień.", hit, "error")
            end
        else
            noti:noti("Nie należysz do frakcji "..data..".", hit, "error")
        end
    end
end)

addEvent("start.duty", true)
addEventHandler("start.duty", resourceRoot, function(tag)
    achievements=exports.px_achievements

    if(tag == "SAPD")then
        giveWeapon(client, 43, 9999)
    end
    
    for _, stat in ipairs({69, 70, 71, 72, 73, 74, 76, 77, 78, 79}) do
        setPedStat(client, stat, 1000)
    end

    if(not achievements:isPlayerHaveAchievement(client, "Służysz społeczeństwu"))then
        achievements:getAchievement(client, "Służysz społeczeństwu")
    end

    setElementData(client, "user:skin", getElementModel(client))

    db:query("update groups_fractions_players set lastduty=now() where uid=?", getElementData(client, "user:uid"))
end)

addEvent("stop.duty", true)
addEventHandler("stop.duty", resourceRoot, function(name)
    setElementData(client, "custom_name", false)

    setTimer(function(client)
        if(client and isElement(client) and getElementData(client, "user:skin"))then
            setElementModel(client, getElementData(client, "user:skin"))
            setElementData(client, "user:skin", false)
        end    
    end, 500, 1, client)

    takeAllWeapons(client)

    for _, stat in ipairs({69, 70, 71, 72, 73, 74, 76, 77, 78, 79}) do
        setPedStat(client, stat, 0)
    end

    if(name == 'SAPD')then
        setPedArmor(client, 0)
    end

    setElementData(client, "user:factionAFK", false)
end)

-- 

local core=exports.px_core
local dc=exports.px_discord

addCommandHandler("megafon", function(player, _, ...)
    if(getElementData(player, "user:faction") == "SAPD")then
        if(not getElementData(player, "user:uid") or getElementData(player, "user:bw"))then return end

        core=exports.px_core
        if(core:isPlayerHaveMute(player))then
            noti:noti("Jesteś wyciszony i nie możesz korzystać z czatu.", player)
            return
        end

        if(...)then
            dc=exports.px_discord

            local text = table.concat({...}, " ")
            local x,y,z = getElementPosition(player)
            local inShape = getElementsWithinRange(x, y, z, 50, "player")
            for i,v in pairs(inShape) do
                if(getElementDimension(player) == getElementDimension(v) and getElementInterior(player) == getElementInterior(v))then
                    outputChatBox("#ff0000MEGAFON #0000ff(("..getPlayerName(player)..")) #939393"..text, v, 255, 255, 255, true)
        
                    dc:sendDiscordLogs("/megafon "..text, "chat", player)
                end
            end
        end
    end
end)