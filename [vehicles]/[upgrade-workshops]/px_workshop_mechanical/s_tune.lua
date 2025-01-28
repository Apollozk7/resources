--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

ui.places={
    {2397.1699,1051.3713,10.8203},
}

for i,v in pairs(ui.places) do
    local marker=createMarker(v[1], v[2], v[3], "cylinder", 2.5, 0, 255, 255, 100)
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

addEvent("buy.lpg", true)
addEventHandler("buy.lpg", resourceRoot, function(vehicle, cost)
    local id=getElementData(vehicle, "vehicle:id")
    if(not id)then return end
    
    local myMoney=getPlayerMoney(client)
    if(myMoney >= cost)then
        local r=exports.px_connect:query("select fuelTank,fuelType from vehicles where id=? limit 1", id)
        if(r and #r > 0)then
            if(r[1].fuelType == "Petrol")then
                if(r[1].fuelType == "LPG")then
                    exports.px_noti:noti("Posiadasz już zainstalowaną butle LPG.", client, "error")
                else
                    takePlayerMoney(client, cost)

                    exports.px_connect:query("update vehicles set fuelType=?, gas=? where id=? limit 1", "LPG", r[1].fuelTank, id)

                    setElementData(vehicle, "vehicle:fuelType", "LPG")
                    setElementData(vehicle, "vehicle:gas", r[1].fuelTank)

                    exports.px_noti:noti("Pomyślnie zakupiono butle LPG za "..cost.."$.", client, "success")

                    triggerClientEvent(client, "destroy.ui", resourceRoot, true)

                    exports.px_vehicles:saveVehicle(vehicle)

                    exports.px_admin:addTuningLogs(client,vehicle,cost,"Pomyślnie zakupiono butle LPG za "..cost.."$.")
                end
            else
                exports.px_noti:noti("Instalacje LPG możesz zainstalować tylko do pojazdu z silnikiem benzynowym.", client, "error")
                triggerClientEvent(client, 'trigger.unblock', resourceRoot)
            end
        end
    else
        exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
        triggerClientEvent(client, 'trigger.unblock', resourceRoot)
    end
end)

addEvent("buy.engine", true)
addEventHandler("buy.engine", resourceRoot, function(vehicle, engine, cost)
    local id=getElementData(vehicle, "vehicle:id")
    if(not id)then return end

    local myMoney=getPlayerMoney(client)
    if(myMoney >= cost)then
        takePlayerMoney(client, cost)

        exports.px_connect:query("update vehicles set engine=? where id=? limit 1", engine, id)
        exports.px_vehicles:reloadVehicleMechanicalUpgrades(vehicle)
        exports.px_vehicles:saveVehicle(vehicle)

        exports.px_admin:addTuningLogs(client,vehicle,cost,"Pomyślnie zakupiono pojemność "..string.format("%.1f", engine).." L za cene "..cost.."$.")

        exports.px_noti:noti("Pomyślnie zakupiono pojemność "..string.format("%.1f", engine).." L za cene "..cost.."$.", client, "success")

        triggerClientEvent(client, "destroy.ui", resourceRoot, true)
    else
        exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
        triggerClientEvent(client, 'trigger.unblock', resourceRoot)
    end
end)

addEvent("buy.tank", true)
addEventHandler("buy.tank", resourceRoot, function(vehicle, tank, cost)
    local id=getElementData(vehicle, "vehicle:id")
    if(not id)then return end

    local myMoney=getPlayerMoney(client)
    if(myMoney >= cost)then
        takePlayerMoney(client, cost)

        exports.px_connect:query("update vehicles set fuelTank=? where id=? limit 1", tank, id)

        setElementData(vehicle, "vehicle:fuelTank", tank)

        exports.px_noti:noti("Pomyślnie zakupiono pojemność baku "..string.format("%.1f", tank).." L za cene "..cost.."$.", client, "success")

        triggerClientEvent(client, "destroy.ui", resourceRoot, true)

        exports.px_vehicles:saveVehicle(vehicle)

        exports.px_admin:addTuningLogs(client,vehicle,cost,"Pomyślnie zakupiono pojemność baku "..string.format("%.1f", tank).." L za cene "..cost.."$.")
    else
        exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
        triggerClientEvent(client, 'trigger.unblock', resourceRoot)
    end
end)

-- functions

function addToMechanicTuning(id,tbl,name,value)
    tbl[#tbl+1]=value and name..'_'..value or name
    exports.px_connect:query('update vehicles set mechanicTuning=? where id=? limit 1', table.concat(tbl, ','), id)
end

function removeFromMechanicTuning(id,tbl,name,value)
    local vv=value and name..'_'..value or name
    for i,v in pairs(tbl) do
        if(v == vv)then
            table.remove(tbl,i)
            break
        end
    end
    exports.px_connect:query('update vehicles set mechanicTuning=? where id=? limit 1', table.concat(tbl, ','), id)
end

addEvent("buy.mk", true)
addEventHandler("buy.mk", resourceRoot, function(vehicle, mk, cost, type)
    local id=getElementData(vehicle, "vehicle:id")
    if(not id)then return end

    local q=exports.px_connect:query("select mechanicTuning,handling from vehicles where id=? limit 1", id)
    if(q and #q > 0)then
        if(type == "buy")then
            if(getPlayerMoney(client) >= cost)then
                takePlayerMoney(client, cost)

                addToMechanicTuning(id,split(q[1].mechanicTuning,',') or {},mk)
                exports.px_vehicles:reloadVehicleMechanicalUpgrades(vehicle)
        
                exports.px_noti:noti("Pomyślnie zakupiono "..mk.." za cene "..cost.."$.", client, "success")
        
                triggerClientEvent(client, "destroy.ui", resourceRoot, true)

                exports.px_vehicles:saveVehicle(vehicle)

                exports.px_admin:addTuningLogs(client,vehicle,cost,"Pomyślnie zakupiono "..mk.." za cene "..cost.."$.")
            else
                exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
                triggerClientEvent(client, 'trigger.unblock', resourceRoot)
            end
        elseif(type == "sell")then
            removeFromMechanicTuning(id,split(q[1].mechanicTuning,',') or {},mk)
        
            local handling=fromJSON(q[1].handling) or {}
            if(mk == "MK1")then
                handling["turnMass"]=nil
                handling["mass"]=nil
                handling["driveType"]=nil
                handling["steeringLock"]=nil
            elseif(mk == "MK2")then
                handling["maxVelocity"]=nil
                handling["engineAcceleration"]=nil

                handling["saveVelocity"]=nil
                handling["saveAcceleration"]=nil
            end
            exports.px_connect:query("update vehicles set handling=? where id=? limit 1", toJSON(handling), id)

            exports.px_vehicles:reloadVehicleMechanicalUpgrades(vehicle)

            givePlayerMoney(client, cost)
            exports.px_noti:noti("Pomyślnie zdemontowano "..mk.." za cene "..cost.."$.", client, "success")

            exports.px_admin:addTuningLogs(client,vehicle,cost,"Pomyślnie zdemontowano "..mk.." za cene "..cost.."$.")
        
            triggerClientEvent(client, "destroy.ui", resourceRoot, true)

            exports.px_vehicles:saveVehicle(vehicle)
        end
    end
end)

addEvent("buy.misc", true)
addEventHandler("buy.misc", resourceRoot, function(vehicle, misc, name, cost, type)
    local id=getElementData(vehicle, "vehicle:id")
    if(not id)then return end
        
    local q=exports.px_connect:query("select mechanicTuning from vehicles where id=? limit 1", id)
    if(q and #q > 0)then
        if(type == "buy")then
            if(getPlayerMoney(client) >= cost)then
                if(misc == 'suspension')then
                    local hydra=getVehicleUpgradeOnSlot(vehicle, 9)
                    if(hydra == 1087)then
                        exports.px_noti:noti('Aby zamontować zawieszenie najpierw wymontuj hydraulike!', client, 'error')
                        triggerClientEvent(client, "destroy.ui", resourceRoot, true)
                        return
                    end
                end

                takePlayerMoney(client, cost)
        
                addToMechanicTuning(id,split(q[1].mechanicTuning,',') or {},misc,name)
        
                exports.px_vehicles:reloadVehicleMechanicalUpgrades(vehicle)
        
                exports.px_noti:noti("Pomyślnie zakupiono "..name.." za cene "..cost.."$.", client, "success")
        
                triggerClientEvent(client, "destroy.ui", resourceRoot, true)

                exports.px_vehicles:saveVehicle(vehicle)

                exports.px_admin:addTuningLogs(client,vehicle,cost,"Pomyślnie zakupiono "..name.." za cene "..cost.."$.")
            else
                exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
                triggerClientEvent(client, 'trigger.unblock', resourceRoot)
            end
        elseif(type == "sell")then
            givePlayerMoney(client, cost)
        
            removeFromMechanicTuning(id,split(q[1].mechanicTuning,',') or {},misc,name)
        
            exports.px_vehicles:reloadVehicleMechanicalUpgrades(vehicle)
        
            exports.px_noti:noti("Pomyślnie zdemontowano "..misc.." ("..name..") za cene "..cost.."$.", client, "success")
        
            triggerClientEvent(client, "destroy.ui", resourceRoot, true)

            exports.px_vehicles:saveVehicle(vehicle)

            exports.px_admin:addTuningLogs(client,vehicle,cost,"Pomyślnie zdemontowano "..misc.." ("..name..") za cene "..cost.."$.")
        end
    end
end)