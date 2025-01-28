--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

ui.places={
    {-24.0759,1813.9259,18.3844},
}

for i,v in pairs(ui.places) do
    local marker=createMarker(v[1], v[2], v[3], "cylinder", 2, 0, 100, 255)
    setElementData(marker, "settings", {offIcon=true})
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and dim and isElement(hit) and getElementType(hit) == "player" and isPedInVehicle(hit) and getVehicleController(getPedOccupiedVehicle(hit)) == hit)then
        if(getElementData(hit, "user:premium") or getElementData(hit, "user:gold"))then
            triggerClientEvent(hit, "open.ui", resourceRoot)
        else
            exports.px_noti:noti("Ten warsztat jest tylko dla graczy PREMIUM oraz GOLD.", hit, "error")
        end
    end
end)

addEventHandler("onMarkerLeave", resourceRoot, function(hit, dim)
    if(hit and dim and isElement(hit) and getElementType(hit) == "player")then
        triggerClientEvent(hit, "destroy.ui", resourceRoot)
    end
end)

addEvent("buy.wheels", true)
addEventHandler("buy.wheels", resourceRoot, function(veh, cost, data)
    local id=getElementData(veh, "vehicle:id")
    if(not id)then return end

    local myMoney=getPlayerMoney(client)
    if(myMoney >= cost)then
        setElementData(veh, "vehicle:wheelsSettings", data)
        
        exports.px_noti:noti("Pomyślnie zapisano zmiany w konfiguracji felg. Koszt wyniósł: $"..cost..".", client, "success")
        exports.px_admin:addTuningLogs(client,veh,cost,"Pomyślnie zapisano zmiany w konfiguracji felg. Koszt wyniósł: $"..cost..".")

        exports.px_vehicles:saveVehicle(veh)

        triggerClientEvent(client, "saveData", resourceRoot, veh)

        takePlayerMoney(client, cost)
    else
        exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
    end
end)