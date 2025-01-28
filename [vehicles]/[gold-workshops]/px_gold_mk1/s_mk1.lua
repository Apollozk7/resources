--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- markers
local access=false

local marker=createMarker(-27.0716,1877.7620,18.4535, "cylinder", 1.2, 255, 200, 0)
local zone=createColCuboid(-28.45054, 1864.55396, 17.45354, 6.901029586792, 14.90283203125, 1.9)
setElementData(marker, "icon", ":px_gold_mk1/textures/mk1.png")
setElementData(marker, "text", {text="Regulacja MK1",desc=""})

addEventHandler("onMarkerHit", marker, function(plr, dim)
    if(plr and isElement(plr) and dim and getElementType(plr) == "player" and not isPedInVehicle(plr))then
        if(not access or getElementData(plr, access))then
            local elements=getElementsWithinColShape(zone, "vehicle")
            if(elements and #elements == 1)then
                local data=getElementData(elements[1], "vehicle:mk1")
                if(data)then
                    local id=getElementData(elements[1], "vehicle:id")
                    if(id)then 
                        triggerClientEvent(plr, "ui.toggleUI", resourceRoot, true, elements[1])
                    end
                else
                    exports.px_noti:noti("Pojazd nie posiada zainstalowanego układu MK1.", plr, "error")
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
    if(plr and isElement(plr) and getElementType(plr) == "player" and dim and not isPedInVehicle(plr))then
        triggerClientEvent(plr, "ui.toggleUI", resourceRoot)
    end
end)
--

-- triggers

function findHandlingIndex(handling, name)
    local find
    for i,v in pairs(handling) do
        local s1,s2=utf8.find(v, name)
        if(s1 and s2 and utf8.sub(v,s1,s2)==name)then
            find=i
            break
        end
    end
    return find
end

addEvent("set.mk1", true)
addEventHandler("set.mk1", resourceRoot, function(vehicle, upgrades)
    local id=getElementData(vehicle, "vehicle:id")
    if(id)then
        local r=exports.px_connect:query("select handling from vehicles where id=? limit 1", id)
        if(r and #r > 0)then
            local handling=split((r[1].handling or ""),',') or {}
            for i,v in pairs(upgrades) do
                if(v.name == "Promień skrętu (stopnie)")then
                    local p=math.floor(v.from+(v.to-v.from)*(v.progress/100))

                    setVehicleHandling(vehicle, "steeringLock", p)

                    local id=findHandlingIndex(handling, 'steeringLock')
                    handling[id or (#handling+1)]='steeringLock_'..p
                elseif(v.name == "Masa pojazdu (kg)")then
                    local p=math.floor(v.from+(v.to-v.from)*(v.progress/100))

                    setVehicleHandling(vehicle, "mass", p)
                    setVehicleHandling(vehicle, "turnMass", p*2)
                    
                    local id=findHandlingIndex(handling, 'mass')
                    handling[id or (#handling+1)]='mass_'..p
                    
                    local id=findHandlingIndex(handling, 'turnMass')
                    handling[id or (#handling+1)]='turnMass_'..p*2
                elseif(v.name == "Napęd pojazdu")then
                    local type=v.types[v.selected]
                    if(type)then
                        type=type == "Przód" and "fwd" or type == "Tył" and "rwd" or type == "4x4" and "awd"

                        setVehicleHandling(vehicle, "driveType", type)

                        local id=findHandlingIndex(handling, 'driveType')
                        handling[id or (#handling+1)]='driveType_'..type
                    end
                end
            end

            exports.px_connect:query("update vehicles set handling=? where id=? limit 1", table.concat(handling, ','), id)

            exports.px_noti:noti("Pomyślnie zapisano zmiany.", client, "success")
        else
            exports.px_noti:noti("Wystąpił błąd.", client, "error")
        end
    end
end)

--