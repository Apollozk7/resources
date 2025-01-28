--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- markers
local access="user:gold"

local marker=createMarker(-9.6580,1877.6335,18.4535, "cylinder", 1.2, 255, 200, 0)
local zone=createColCuboid(-13.05107, 1864.65405, 17.45354, 6.9029026031494, 14.9013671875, 1.9)
setElementData(marker, "icon", ":px_gold_repairs/textures/marker_fix.png")
setElementData(marker, "text", {text="Naprawa pojazdów",desc=""})

addEventHandler("onMarkerHit", marker, function(plr, dim)
    if(plr and isElement(plr) and dim and getElementType(plr) == "player" and not isPedInVehicle(plr))then
        if(getElementData(plr, access))then
            local elements=getElementsWithinColShape(zone, "vehicle")
            if(elements and #elements == 1)then
                local parts=exports.px_workshop_mechanic:fillVehicleData(elements[1]) or {}
                if(#parts > 0)then
                    triggerClientEvent(plr, "FIX.toggleUI", resourceRoot, true, elements[1], parts)
                else
                    exports.px_noti:noti("Pojazd jest w pełni sprawny.", plr, "error")
                end
            else
                exports.px_noti:noti("Na stanowisku powinien znajdować się pojazd.", plr, "error")
            end
        else
            exports.px_noti:noti("Ta usługa jest dostępna tylko dla graczy GOLD.", plr, "error")
        end
    end
end)
--

-- functions

function repair(veh, part)
    if(part == 30)then
        setVehicleWheelStates(veh, 0, 0, 0, 0)
    elseif(part == -1)then
        setElementHealth(veh, 1000)
    elseif(part >= 0 and part < 10)then
        setVehiclePanelState(veh, part, 0)
    elseif(part >= 10 and part < 20)then
        local drzwi = part-10
        setVehicleDoorState(veh, drzwi, 0)
    elseif(part >= 20)then
        local swiatlo = part-20
        setVehicleLightState(veh, swiatlo, 0)
    end
end

-- triggers

addEvent("fix.vehicle", true)
addEventHandler("fix.vehicle", resourceRoot, function(veh, cost, panels)
    for i,v in pairs(panels) do
        repair(veh, v.id)
    end

    takePlayerMoney(client, cost)

    exports.px_noti:noti("Pomyślnie naprawiono pojazd "..getVehicleName(veh).." za kwotę $"..cost, client, "success")
end)