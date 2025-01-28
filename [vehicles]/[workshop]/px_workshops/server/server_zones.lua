--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

-- variables

local timers={}

local places={
    ["Warsztat LV"]={
        ["Mechanik"]={
            {2649.07202, 1209.32153, 9.85000, 13.11865234375, 7.417236328125, 3, 2645.5657,1212.9246,13.33, 180},
            {2649.07251, 1200.73267, 9.85000, 13.11865234375, 7.417236328125, 3, 2645.5657,1204.4320,13.33, 180},
        },

        ["Tuner"]={
            {2649.07178, 1192.03333, 9.85000, 13.11865234375, 7.417236328125, 3, 2645.5657,1195.9047,13.33, 180, 2654.9382,1198.4041,10.8500},
        },

        ["Lakiernik"]={
            {2649.07104, 1183.79102, 9.85000, 13.11865234375, 7.417236328125, 3, 2645.5657,1187.3934,13.33, 180},
        },
    },
}

-- create

for _,k in pairs(places) do
    for i,v in pairs(k) do
        for __,v in pairs(v) do
            local cs=createColCuboid(unpack(v))
            local obj=createObject(8324,v[7],v[8],v[9],0,0,v[10])
            setElementData(cs, "zone:settings", {obj=obj,name=i,desc=_,take=false,tune_pos={v[11],v[12],v[13]}})
        end
    end
end

-- functions

function takeZone(player, zone)
    if(not player or not zone)then return false end

    local settings=getElementData(zone, "zone:settings")
    if(not settings)then return false end

    local data=getElementData(player, "user:job_settings")
    if(not data)then return false end

    if(data.job_tag == settings.desc and data.job_name == settings.name)then  
        if(timers[player] and settings.take == player)then
            killTimer(timers[player])
            timers[player]=nil

            exports.px_noti:noti("Pomyślnie wrócono stanowisko.", player, "info")

            triggerClientEvent(player, "zwolnij:stanowisko:off", resourceRoot)
        elseif(not getElementData(player, "workshop:zone") and not settings.take)then
            settings.take=player
            setElementData(zone, "zone:settings", settings)
            setElementData(player, "workshop:zone", {zone=zone,faction=data.job_name,duty=data.job_tag,tune_pos=settings.tune_pos})
    
            exports.px_noti:noti("Pomyślnie zajęto stanowisko.", player, "info")
        end
    end
    return false
end

function startLeaveZone(player, zone)
    if(not player or not zone)then return false end

    local settings=getElementData(zone, "zone:settings")
    if(not settings)then return false end

    if(settings.take and settings.take == player)then
        triggerClientEvent(player, "zwolnij:stanowisko", resourceRoot)

        timers[player]=setTimer(function(player, zone)
            leaveZone(player, zone)

            exports.px_noti:noti("Stanowisko zostało zwolnione.", player, "info")

            timers[player]=nil
        end, (15*1000), 1, player, zone)
    end
end

function leaveZone(player, zone)
    if(not player or not zone)then return false end

    local settings=getElementData(zone, "zone:settings")
    if(not settings)then return false end

    if(settings.take and settings.take == player)then
        settings.take=false
        setElementData(zone, "zone:settings", settings)

        if(player and isElement(player))then
            removeElementData(player, "workshop:zone")
        end

        local players=getElementsWithinColShape(zone, "player")
        for i,v in pairs(players) do
            triggerClientEvent(v, "anuluj.oferte", resourceRoot)
        end

        if(timers[player])then
            killTimer(timers[player])
            timers[player]=nil
        end

        triggerClientEvent(player, "zwolnij:stanowisko:off", resourceRoot)
        triggerClientEvent("workshop->leaveZone", root, player)
    end
    return false
end

-- events

addEventHandler("onColShapeHit", resourceRoot, function(hit, dim)
    if(not hit or hit and not isElement(hit) or hit and isElement(hit) and getElementType(hit) ~= "player" or not dim or isPedInVehicle(hit))then return end

    takeZone(hit, source)
end)

addEventHandler("onColShapeLeave", resourceRoot, function(hit, dim)
    if(not hit or hit and not isElement(hit) or hit and isElement(hit) and getElementType(hit) ~= "player" or not dim or isPedInVehicle(hit))then return end

    startLeaveZone(hit, source)
end)

addEventHandler("onPlayerQuit", root, function()
    local zone=getElementData(source, "workshop:zone")
    if(zone)then
        leaveZone(source, zone.zone)
    end
end)

addEventHandler("onElementDataChange", root, function(data, old, new)
    if(old and data == "user:job_settings" and old.job_tag and string.find(old.job_tag, "Warsztat") and not new)then
        local zone=getElementData(source, "workshop:zone")
        if(zone)then
            leaveZone(source, zone.zone)
        end
    end
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for i,v in pairs(getElementsByType("player")) do
        removeElementData(v, "workshop:zone")
    end
end)


addEventHandler("onVehicleStartEnter", root, function(plr)
    local zone=getElementData(plr, "workshop:zone")
    if(zone)then
        cancelEvent()
    end
end)