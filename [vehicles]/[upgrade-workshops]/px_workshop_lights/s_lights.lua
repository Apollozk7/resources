--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

ui.places={
    {1064.7557,2356.3259,10.9609},
}

for i,v in pairs(ui.places) do
    local marker=createMarker(v[1], v[2], v[3], "cylinder", 3, 0, 100, 255)
    setElementData(marker, "settings", {offIcon=true})
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and dim and isElement(hit) and getElementType(hit) == "player" and isPedInVehicle(hit) and getVehicleController(getPedOccupiedVehicle(hit)) == hit)then
        triggerClientEvent(hit, "open.ui", resourceRoot)
    end
end)

addEventHandler("onMarkerLeave", resourceRoot, function(hit, dim)
    if(hit and dim and isElement(hit) and getElementType(hit) == "player")then
        triggerClientEvent(hit, "destroy.ui", resourceRoot)
    end
end)

-- triggers

addEvent("buy.lights", true)
addEventHandler("buy.lights", resourceRoot, function(info)
    local vehicle=getPedOccupiedVehicle(client)
    if(not vehicle)then return end

    local id=getElementData(vehicle, 'vehicle:id')
    if(not id)then return end

    local myMoney=getPlayerMoney(client)
    if(myMoney >= info.cost)then
        if(info[1] == "Biały")then
            triggerLatentClientEvent(client, "destroy.ui", resourceRoot, true)
            setVehicleHeadLightColor(vehicle, 255, 255, 255)
            setElementData(vehicle, "vehicle:lights", false)
            exports.px_noti:noti("Pomyślnie przywrócono domyślne światła.", client, "success")
            exports.px_vehicles:saveVehicle(vehicle)
        elseif(info.rgb)then
            exports.px_noti:noti("Pomyślnie zakupiono światła "..info[1].." za $"..info.cost, client, "success")
            setElementData(vehicle, "vehicle:lights", 100)
            setVehicleHeadLightColor(vehicle, unpack(info.rgb))
            triggerLatentClientEvent(client, "destroy.ui", resourceRoot, true)
            exports.px_vehicles:saveVehicle(vehicle)

            exports.px_admin:addTuningLogs(client,vehicle,info.cost,"Pomyślnie zakupiono światła "..info[1].." za $"..info.cost)

            takePlayerMoney(client, info.cost)
        else
            if(not getElementData(vehicle, "vehicle:multiLED"))then
                setElementData(vehicle, "vehicle:multiLED", true)
                exports.px_noti:noti("Pomyślnie zakupiono światła MultiLED za $"..info.cost..", do konfiguracji użyj interakcji pojazdu.", client, "success")
                setElementData(vehicle, "vehicle:lights", 100)
                setVehicleHeadLightColor(vehicle, 255, 255, 255)
                exports.px_vehicles:saveVehicle(vehicle, false, true)

                exports.px_admin:addTuningLogs(client,vehicle,info.cost,"Pomyślnie zakupiono światła MultiLED za $"..info.cost..", do konfiguracji użyj interakcji pojazdu.")

                takePlayerMoney(client, info.cost)

                local r=exports.px_connect:query('select mechanicTuning from vehicles where id=? limit 1', id)
                if(r and #r > 0)then
                    local mechTune=split(r[1].mechanicTuning, ',')
                    mechTune[#mechTune+1]='multiLED'
                    exports.px_connect:query('update vehicles set mechanicTuning=? where id=? limit 1', table.concat(mechTune, ','), id)
                end
            else
                exports.px_noti:noti("Posiadasz już zakupione światła MultiLED.", client, "error")
            end
        end
    else
        exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
    end
end)