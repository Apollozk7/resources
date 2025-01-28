--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent("tank.pilot", true)
addEventHandler("tank.pilot", resourceRoot, function(vehicle, newFuel, cost)
    cost=tonumber(cost)
    cost=math.floor(cost)

    newFuel=tonumber(newFuel)
    newFuel=math.floor(newFuel)
    
    cost=math.floor(newFuel*cost)

    if(getPlayerMoney(client) >= cost)then
        takePlayerMoney(client, cost)

        local lastFuel = getElementData(vehicle, "vehicle:fuel") or 0
        setElementData(vehicle, "vehicle:fuel", lastFuel+newFuel) -- tank vehicle

        exports.px_noti:noti("Dodałeś "..math.floor(newFuel).."L paliwa, do pojazdu "..getVehicleName(vehicle)..", za cene "..cost.."$", client, "success") -- get info

        local org=getElementData(client, "user:organization")
        if(org)then
            exports.px_organizations:updateOrganizationTask(org, "addFromFuelStation", newFuel)
        end
    else
        exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
    end
end)