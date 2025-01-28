--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- markers
local access=false

local marker=createMarker(-23.0966,1877.8004,18.4535, "cylinder", 1.2, 255, 200, 0)
local zone=createColCuboid(-28.45054, 1864.55396, 17.45354, 6.901029586792, 14.90283203125, 1.9)
setElementData(marker, "icon", ":px_gold_mk2/textures/mk2.png")
setElementData(marker, "text", {text="Regulacja MK2",desc=""})

function findHandlingIndex(handling, name)
    local find
    local value
    for i,v in pairs(handling) do
        local s1,s2=utf8.find(v, name)
        if(s1 and s2 and utf8.sub(v,s1,s2)==name)then
            find=i
            value=utf8.sub(v,s2+2,#v)
            break
        end
    end
    return find,value
end

addEventHandler("onMarkerHit", marker, function(plr, dim)
    if(plr and isElement(plr) and dim and getElementType(plr) == "player" and not isPedInVehicle(plr))then
        if(not access or getElementData(plr, access))then
            local elements=getElementsWithinColShape(zone, "vehicle")
            if(elements and #elements == 1)then
                local id=getElementData(elements[1], "vehicle:id")
                local data=getElementData(elements[1], "vehicle:mk2")
                if(id and data)then
                    local r=exports.px_connect:query("select handling from vehicles where id=? limit 1", id)
                    if(r and #r > 0)then
                        local handling=split((r[1].handling or ""),',') or {}
                        local _,sacc=findHandlingIndex(handling, "saveAcceleration")
                        local _,svel=findHandlingIndex(handling, "saveVelocity")
                        triggerClientEvent(plr, "ui.toggleUI", resourceRoot, true, elements[1], sacc or 0, svel or 0)
                    end
                else
                    exports.px_noti:noti("Pojazd nie posiada zainstalowanego układu MK2.", plr, "error")
                end
            else
                exports.px_noti:noti("Na stanowisku powinien znajdować się pojazd.", plr, "error")
            end
        else
            exports.px_noti:noti("Ta usługa jest dostępna tylko dla graczy GOLD.", plr, "error")
        end
    end
end)

addEventHandler("onMarkerLeave", marker, function(plr, dim)
    if(plr and isElement(plr) and dim and getElementType(plr) == "player" and not isPedInVehicle(plr))then
        triggerClientEvent(plr, "ui.toggleUI", resourceRoot)
    end
end)
--

-- triggers

addEvent("set.mk2", true)
addEventHandler("set.mk2", resourceRoot, function(vehicle, progress)
    local id=getElementData(vehicle, "vehicle:id")
    if(id)then
        local r=exports.px_connect:query("select handling from vehicles where id=? limit 1", id)
        if(r and #r == 1)then
            local handling=split((r[1].handling or ""),',') or {}
            local hand=getOriginalHandling(getElementModel(vehicle))
            local newHand=exports.px_custom_vehicles:getVehicleDefaultVelocity(vehicle)
            if(newHand and newHand > 0)then
                local id=findHandlingIndex(handling, 'maxVelocity')
                if(not id)then id=#handling+1 end

                handling[id]='maxVelocity_'..newHand
            end

            local e_hand=exports.px_vehicles:getVehicleHandlingWithEngine(vehicle) or {0,0}
            local vel,acc=unpack(e_hand)

            local maxHandling={
                ["engineAcceleration"]={add=5*(progress[1]/100), my=hand.engineAcceleration, engine=acc},
                ["maxVelocity"]={add=40*(progress[2]/100), my=hand.maxVelocity, engine=vel}
            }

            local sacc=findHandlingIndex(handling, 'saveAcceleration')
            handling[sacc or (#handling+1)]='saveAcceleration_'..progress[1]

            local sacc=findHandlingIndex(handling, 'saveVelocity')
            handling[sacc or (#handling+1)]='saveVelocity_'..progress[2]

            for i,v in pairs(maxHandling) do
                setVehicleHandling(vehicle, i, v.my+v.add+v.engine)

                local s=findHandlingIndex(handling, i)
                handling[s or (#handling+1)]=i..'_'..v.my+v.add
            end

            exports.px_connect:query("update vehicles set handling=? where id=? limit 1", table.concat(handling, ','), id)

            exports.px_noti:noti("Pomyślnie zapisano zmiany.", client, "success")
        else
            exports.px_noti:noti("Wystąpił błąd.", client, "error")
        end
    end
end)