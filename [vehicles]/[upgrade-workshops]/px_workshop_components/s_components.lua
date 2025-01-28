--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

ui.places={
    {-87.6579,1116.8003,19.7797},
}

for i,v in pairs(ui.places) do
    local marker=createMarker(v[1], v[2], v[3], "cylinder", 3, 0, 100, 255)
    setElementData(marker, "settings", {offIcon=true})
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and dim and isElement(hit) and getElementType(hit) == "player" and isPedInVehicle(hit) and getVehicleController(getPedOccupiedVehicle(hit)) == hit)then
        if(getVehicleType(getPedOccupiedVehicle(hit)) ~= "Automobile")then return end

        triggerClientEvent(hit, "open.ui", resourceRoot)
    end
end)

addEventHandler("onMarkerLeave", resourceRoot, function(hit, dim)
    if(hit and dim and isElement(hit) and getElementType(hit) == "player")then
        triggerClientEvent(hit, "destroy.ui", resourceRoot)
    end
end)

-- triggers

addEvent("buy.component", true)
addEventHandler("buy.component", resourceRoot, function(info, vehicle)
    if(not info)then return end

    local id=getElementData(vehicle, 'vehicle:id')
    if(not id)then return end

    local myMoney=getPlayerMoney(client)
    if(myMoney >= tonumber(info.cost))then
        exports.px_connect:query("insert into logs_workshop_components (uid, vehicleID, name, cost) VALUES(?,?,?,?)", getElementData(client, "user:uid"), (getElementData(vehicle, "vehicle:id") or getElementData(vehicle, "vehicle:group_id")), org and info.name.." (ORG)" or info.name, info.cost)
        
        exports.px_noti:noti("Pomyślnie zakupiono "..info.name.." za kwotę $"..info.cost..".", client, "success")
        triggerClientEvent(client, "buy.component", resourceRoot, info)

        if(org)then
            exports.px_organizations:takeOrganizationMoney(org, info.cost)
        else
            takePlayerMoney(client, info.cost)
        end

        exports.px_admin:addTuningLogs(client,vehicle,info.cost,"Pomyślnie zakupiono "..info.name.." za kwotę $"..info.cost..".")
    else
        exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
    end
end)

addEvent("update.components", true)
addEventHandler("update.components", resourceRoot, function(veh, components)
    if(veh and isElement(veh) and components)then
        local id=getElementData(veh, "vehicle:id")
        if(not id)then return end

        exports.px_connect:query("update vehicles set components=? where id=? limit 1", table.concat(components, ","), id)
    end
end)