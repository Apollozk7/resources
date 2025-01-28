--[[
    @author: psychol., Xyrusek
    @mail: nezym69@gmail.com, xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local interiors={}

local settings = {}
    settings.maxRents = 3
    settings.maxVehiclesInGarage = 14

local parkingPositions = {
    {2393.6526,1508.0720,876.1923,270},
    {2393.6526,1504.2339,876.1917,270},
    {2393.6526,1499.2622,876.1943,270},
    {2393.6526,1495.3007,876.1962,270},
    {2393.6526,1491.4141,876.1893,270},
    {2393.6526,1486.4717,876.2212,270},
    {2393.6526,1482.5020,876.1942,270},

    {2411.5020,1508.0027,876.1915,90},
    {2411.5020,1504.1874,876.1907,90},
    {2411.5020,1499.1416,876.1959,90},
    {2411.5020,1495.2412,876.1938,90},
    {2411.5020,1491.3359,876.1903,90},
    {2411.5020,1486.4254,876.1942,90},
    {2411.5020,1482.4606,876.1945,90},
}

local parking={}

parking.list={}

-- first functions

function table.size(tbl)
    local k=0
    for i,v in pairs(tbl) do
        k=k+1
    end
    return k
end

function createParking(id)
    if isParkingExists(id) then return false end

    parking.list[id] = {}
end

function getParking(id)
    return parking.list[id]
end

function isParkingExists(id)
    return parking.list[id]
end

function setParkingEnterVehicle(id, x, y, z, rz, int, dim)
    if not isParkingExists(id) then return false end

    if not parking.list[id].enterVehicle then
        parking.list[id].enterVehicle = createMarker(0, 0, 0, "cylinder", 2, 0, 200, 100)
        setElementID(parking.list[id].enterVehicle, "parking_colenter:"..id)
        setElementData(parking.list[id].enterVehicle, "icon", ":px_parking/textures/garageMarker.png")
        setElementData(parking.list[id].enterVehicle, "text", {text="Parking podziemny", desc="Tutaj schowasz swój pojazd"})
    end

    parking.list[id].inPosition = {x, y, z, (rz or 0), (int or 0), (dim or 0)}
    setElementPosition(parking.list[id].enterVehicle, x, y, z)
    setElementInterior(parking.list[id].enterVehicle, (int or 0))
    setElementDimension(parking.list[id].enterVehicle, (dim or 0))
end

function setParkingEnter(id, x, y, z, int, dim)
    if not isParkingExists(id) then return false end

    if not parking.list[id].enter then
        parking.list[id].enter = createMarker(0, 0, 0, "cylinder", 1.5, 0, 100, 200)
        setElementID(parking.list[id].enter, "parking_enter:"..id)
        setElementData(parking.list[id].enter, "icon", ":px_parking/textures/garageMarker.png")
        setElementData(parking.list[id].enter, "text", {text="Parking podziemny", desc="Tutaj przechowasz swoje pojazdy"})
    end

    parking.list[id].enterPosition = {x, y, z, (int or 0), (dim or 0)}
    setElementPosition(parking.list[id].enter, x, y, z)
    setElementInterior(parking.list[id].enter, (int or 0))
    setElementDimension(parking.list[id].enter, (dim or 0))
end

-- parking functions

parking.garages={}
parking.playerData={}

function getPlayerParking(player)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return false end

    local q=exports.px_connect:query("select * from vehicles_garages where playerID=? limit 1", uid)
    return q[1] or false
end

function enterPlayerToGarage(player, id)
    local garage=parking.garages[id]
    if(garage)then
        exports.px_loading:createLoadingScreen(player, true, false, 5000)
        setElementFrozen(player, true)
        setTimer(function()
            if(player and isElement(player))then
                garage.players[player]=true
                setElementPosition(player, 2400.3752,1511.5901,876.3228)
                setElementRotation(player, 0, 0, 270)
                setElementDimension(player, garage.dim)
        
                triggerClientEvent(player, "px_parking:onEnterParking", getResourceRootElement(), garage.owner)

                setTimer(function() if player and isElement(player) then setElementFrozen(player, false) end end, 2000, 1)
            end
        end, 3000, 1)
    end
end

function exitPlayerFromGarage(player, id)
    local garage=parking.garages[id]
    if(garage)then
        exports.px_loading:createLoadingScreen(player, true, false, 5000)
        setElementFrozen(player, true)
        setTimer(function()
            if(player and isElement(player))then
                if(garage.players[player])then
                    garage.players[player]=nil
                end
        
                setElementPosition(player, 2389.7375,1509.5201,10.8203)
                setElementDimension(player, 0)
        
                if(table.size(garage.players) == 0)then
                    for i,v in pairs(garage.vehicles) do
                        if(i and isElement(i))then
                            local vehID=getElementData(i, "vehicle:id")
                            exports.px_vehicles:saveVehicle(i,'destroy')
                            exports.px_connect:query("update vehicles set parking=? where id=?", id, vehID)
                        end
                    end
        
                    destroyElement(parking.garages[id].interior)
                    parking.garages[id]=nil
                end
        
                parking.playerData[player]=nil

                setTimer(function() if player and isElement(player) then setElementFrozen(player, false) end end, 2000, 1)
            end
        end, 3000, 1)
    end
end

addEvent('getVehicleFromParkingButton', true)
addEventHandler('getVehicleFromParkingButton', resourceRoot, function(vehicleID, ownerID)
    local uid=getElementData(client, 'user:uid')
    if(not uid)then return end

    if(tonumber(uid) ~= tonumber(ownerID))then return end

    local q=exports.px_connect:query("select * from vehicles_garages where playerID=? limit 1", ownerID)
    if(q and #q == 1)then
        local r=exports.px_connect:query("select * from vehicles where parking=? and id=? limit 1", q[1].id, vehicleID)
        if(r and #r == 1)then
            local pos={2407.1023,1516.9087,10.8,0,0,179.2263}
            exports.px_connect:query("update vehicles set parking=0,position=? where id=? limit 1", table.concat(pos, ','), vehicleID)

            local veh=exports.px_vehicles:createNewVehicle(vehicleID)
            if(veh and isElement(veh))then
                setElementPosition(veh, pos[1], pos[2], pos[3])
                setElementRotation(veh, pos[4], pos[5], pos[6])
                setElementFrozen(veh, true)
                setTimer(function(player)
                    if(player and isElement(player))then
                        warpPedIntoVehicle(player, veh)
                    end
                end, 100, 1, client)
            end
        end
    end
end)

function enterParking(player, id)
    local q=exports.px_connect:query("select * from vehicles_garages where id=? limit 1", id)
    if(q and #q > 0)then
        if(not parking.garages[id])then
            parking.garages[id]={
                owner=q[1].playerID,

                interior=createObject(1337, 2402.4490,1499.5519,876.479),
                dim=(id+69),

                vehicles={},
                players={}
            }

            setElementData(parking.garages[id].interior, 'custom_name', 'garaz_przecho')
            setElementDimension(parking.garages[id].interior, parking.garages[id].dim)

            local q=exports.px_connect:query("select * from vehicles where parking=?", id)
            if(q and #q > 0)then
                local k=0
                for i,v in pairs(q) do
                    loadParkingVehicle(v.id, v.position and split(v.position, ',') or false, id)
                    k=k+1
                end
                if(k == #q)then
                    for i,v in pairs(parking.garages[id].vehicles) do
                        local pos={getElementPosition(i)}
                        local el=(#getElementsWithinRange(pos[1], pos[2], pos[3]+0.2, 2, "vehicle", 0, dim) > 0)
                        if(el)then
                            pos=getFreePosition(parking.garages[id].dim)
                            if(pos)then
                                setElementPosition(i, pos[1], pos[2], pos[3])
                                setElementRotation(i, pos[4], pos[5], pos[6])
                            end
                        end
                    end
                end
            end
        end

        enterPlayerToGarage(player, id)
        parking.playerData[player]=id
    end
end

function getFreePosition(dim)
    local max=100 -- w razie wu, stopujemy tabele aby nie zlagowac serwera
    local i=0

    local pos=false
    while(true)do
        i=i+1

        for _,v in ipairs(parkingPositions) do
            local el=(#getElementsWithinRange(v[1], v[2], v[3], 1, "vehicle", 0, dim) > 0)
            if(not el)then
                pos={v[1],v[2],v[3],0,0,v[4]}
                break
            end
        end

        if(pos or i >= max)then break end
    end
    return pos
end

function loadParkingVehicle(id, pos, garage)
    if(not id or not garage)then return end

    local garage=parking.garages[garage]
    if(garage and garage.dim ~= 0)then
        if(not pos)then
            pos=getFreePosition(garage.dim)
        else
            local dist=getDistanceBetweenPoints3D(2396.9399,1498.4055,875.4790, pos[1], pos[2], pos[3])
            if(dist >= 50)then
                pos=getFreePosition(garage.dim)
            end
        end

        if(pos and #pos > 0)then
            exports.px_connect:query("update vehicles set parking=0,position=? where id=? limit 1", table.concat(pos, ','), id)

            local veh=exports.px_vehicles:createNewVehicle(id)
            if(veh and isElement(veh))then
                setElementDimension(veh, garage.dim)
                setElementPosition(veh, pos[1], pos[2], pos[3])
                setElementRotation(veh, pos[4], pos[5], pos[6])
                setElementFrozen(veh, true)

                garage.vehicles[veh]=true
            end
        else
            exports.px_noti:noti("Zabrakło miejsca na któryś z Twoich pojazdów, zwolnij miejsce aby się on pokazał.", client, "info")
        end
    end
end

function getVehicleFromParking(vehicle, ownerID, player)
    if not vehicle or not ownerID or not player then return false end

    local garageData = getPlayerOwnedGarages(ownerID)[1]
    if not garageData then return false end

    local vehicleID = getElementData(vehicle, "vehicle:id")
    if not vehicleID then return false end

    local garage=parking.garages[garageData.id]
    if(garage and garage.vehicles[vehicle])then
        local x, y, z, rz = 2407.1023,1516.9087,10.8,179.2263
        setElementPosition(vehicle, x, y, z+1.2)
        setElementRotation(vehicle, 0, 0, rz)
        setElementDimension(vehicle, 0)

        setElementFrozen(vehicle, false)

        garage.vehicles[vehicle]=nil
        garage.players[player]=nil

        if(table.size(garage.players) == 0)then
            for i,v in pairs(garage.vehicles) do
                if(i and isElement(i))then
                    local vehID=getElementData(i, "vehicle:id")
                    
                    exports.px_vehicles:saveVehicle(i,'destroy')
                    exports.px_connect:query("update vehicles set parking=? where id=?", garageData.id, vehID)
                end
            end

            destroyElement(parking.garages[garageData.id].interior)
            parking.garages[garageData.id]=nil
        end

        return vehicle
    end
    return false
end

function sendVehicleToParking(player, vehicle, id)
    local garageID=1
    if(not player or not vehicle or not id)then return end
    if(not isElement(vehicle))then return end

    local uid=getElementData(player, 'user:uid')
    if(not uid)then return end

    local owner=getElementData(vehicle, 'vehicle:owner')
    if(not owner)then return end

    local vehID=getElementData(vehicle, "vehicle:id")
    if(not vehID)then return end

    local info=getPlayerParking(player)
    if(not info)then return end

    if(owner ~= uid)then
        sendNotification(player, 'Na parking możesz wysłać tylko swoje prywatne pojazdy.', 'error')
        return
    end

    for i, v in pairs(getVehicleOccupants(vehicle)) do removePedFromVehicle(v) end        

    -- send
    exports.px_vehicles:saveVehicle(vehicle,'destroy')
    exports.px_connect:query("update vehicles set parking=?, position=NULL where id=? limit 1", id, vehID)

    -- update
    local garage=parking.garages[id]
    if(garage)then
        loadParkingVehicle(vehID, false, id)
    end
    --
end

-- on quit

addEventHandler("onPlayerQuit", root, function()
    local player=source
    local id=parking.playerData[player]
    if(id)then
        local garage=parking.garages[id]
        if(garage and garage.players[player])then
            garage.players[player]=nil

            if(table.size(garage.players) < 1)then
                for i,v in pairs(garage.vehicles) do
                    if(i and isElement(i))then
                        local vehID=getElementData(i, "vehicle:id")
                        
                        exports.px_vehicles:saveVehicle(i,'destroy')
        
                        exports.px_connect:query("update vehicles set parking=? where id=?", id, vehID)
                    end
                end

                destroyElement(parking.garages[id].interior)
                parking.garages[id]=nil
            end
        end

        parking.playerData[player]=nil
    end
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for id,v in pairs(parking.garages) do
        for i,v in pairs(v.vehicles) do
            if(i and isElement(i))then
                local vehID=getElementData(i, "vehicle:id")
                
                exports.px_vehicles:saveVehicle(i,'destroy')

                exports.px_connect:query("update vehicles set parking=? where id=?", id, vehID)
            end
        end

        for i,v in pairs(v.players) do
            setElementPosition(i, 2389.7375,1509.5201,10.8203)
            setElementDimension(i, 0)
        end
    end
end)

function removeVehicleFromParking(ownerID, vehicleID)
    if not ownerID or not vehicleID then return false end

    local garageData = getPlayerOwnedGarages(ownerID)[1]
    if not garageData then return false end

    local q=exports.px_connect:query("select * from vehicles where id=? and parking=? limit 1", vehicleID, garageData.id)
    if(q and #q > 0)then
        local owner=q[1].owner
        local rentData=getPlayerOwnedGarages(owner)[1]
        if(rentData)then
            exports.px_connect:query("update vehicles set parking=?, position=NULL where id=? limit 1", rentData.id, vehicleID)
        end
    end
    return #q > 0 and true or false
end

function getPlayerOwnedGarages(playerID)
    if not playerID then return false end

    local ownedGarages = exports.px_connect:query("SELECT * from vehicles_garages WHERE playerID=? LIMIT 1", playerID)

    if #ownedGarages <= 0 then
        exports.px_connect:query("INSERT INTO vehicles_garages SET playerID=?", playerID)
        ownedGarages = exports.px_connect:query("SELECT * from vehicles_garages WHERE playerID=? LIMIT 1", playerID)
    end
 
    for i, v in ipairs(ownedGarages) do
        v.isOwner = true
        v.ownerName = getPlayerLoginByUID(v.playerID)
        v.rents=exports.px_connect:query('select vehicles_garages_share.playerUID as playerID,accounts.lastlogin as playerLastOnline,accounts.login as playerName from vehicles_garages_share left join accounts on accounts.id=vehicles_garages_share.playerUID where vehicles_garages_share.garageID=?', v.id)
        v.vehiclesIn={}

        local q=exports.px_connect:query("select id,model,owner,position,ownerName from vehicles where parking=?", v.id)
        for i, v2 in ipairs(q) do
            v.vehiclesIn[#v.vehiclesIn+1] = {
                vehicleID = v2.id,
                vehicleData = {
                    model = getVehicleNameFromModel(v2.model),
                    modelID = v2.model,
                    ownerName = v2.ownerName,
                    isOwner = (tonumber(playerID) == tonumber(v2.owner)),
                    position = v2.position,
                },
            }
        end
    end

    return ownedGarages
end

function getPlayerRentedGarages(playerID)
    if not playerID then return false end

    local rentGarages=exports.px_connect:query('select vehicles_garages.playerID, vehicles_garages.id,vehicles_garages_share.playerUID as rentUID, accounts.lastlogin as playerLastOnline, accounts.login as ownerName from vehicles_garages_share left join vehicles_garages on vehicles_garages.id=vehicles_garages_share.garageID left join accounts on accounts.id=vehicles_garages.playerID where vehicles_garages_share.playerUID=?', playerID)
    for i,v in pairs(rentGarages) do
        v.isOwner=false
        v.rents=exports.px_connect:query('select vehicles_garages_share.playerUID,accounts.lastlogin as playerLastOnline,accounts.login as playerName from vehicles_garages_share left join accounts on accounts.id=vehicles_garages_share.playerUID where vehicles_garages_share.garageID=?', v.id)
    end
    return rentGarages
end

function addRentToGarage(ownerID, playerID)
    if not ownerID or not playerID or (ownerID == playerID) then return false end

    local garageData = getPlayerOwnedGarages(ownerID)[1]
    if not garageData then return false end

    local actualRents=exports.px_connect:query('select * from vehicles_garages_share where garageID=?', garageData.id)
    if actualRents and #actualRents >= settings.maxRents then return false end

    exports.px_connect:query('insert into vehicles_garages_share (garageID,playerUID) values(?,?)', garageData.id, playerID)

    return true
end

function removeRentFromGarage(ownerID, playerID)
    if not ownerID or not playerID then return false end

    local garageData = getPlayerOwnedGarages(ownerID)[1]
    if not garageData then return false end

    local actualRents=exports.px_connect:query('select * from vehicles_garages_share where garageID=? and playerUID=?', garageData.id, playerID)
    for i, v in ipairs(actualRents) do
        local rentData=getPlayerOwnedGarages(playerID)[1]
        if(rentData)then
            exports.px_connect:query("update vehicles set parking=?,position=NULL where id=? and owner=? and parking=? limit 1", rentData.id, v.id, playerID, garageData.id)
        end
    end

    local q=exports.px_connect:query('delete from vehicles_garages_share where playerUID=? and garageID=?', playerID, garageData.id)
    return q
end

function refreshPlayerInfo(player)
    if not player then return false end

    local playerID = getPlayerUID(player)
    if not playerID then return false end

    local ownedGarages = getPlayerOwnedGarages(playerID)
    local rentGarages = getPlayerRentedGarages(playerID)

    triggerClientEvent(player, "px_parking:respondGetPlayerGarages", getResourceRootElement(), ownedGarages, rentGarages)
end

-- triggers

addEvent("px_parking:getPlayerGarages", true)
addEventHandler("px_parking:getPlayerGarages", getResourceRootElement(), function()
    refreshPlayerInfo(client)
end)

addEvent("px_parking:removeVehicleFromParking", true)
addEventHandler("px_parking:removeVehicleFromParking", getResourceRootElement(), function(ownerID, vehicleID)
    if not client then return false end

    local status = removeVehicleFromParking(ownerID, vehicleID)
    if status then 
        sendNotification(client, "Pomyślnie usunięto pojazd ID "..vehicleID.." z parkingu.", "success")
        refreshPlayerInfo(client) 
    end
end)

addEvent("px_parking:removeRentFromGarage", true)
addEventHandler("px_parking:removeRentFromGarage", resourceRoot, function(ownerID, playerID)
    if not client then return false end

    local status = removeRentFromGarage(ownerID, playerID)
    if status then 
        refreshPlayerInfo(client) 
        sendNotification(client, "Pomyślnie usunięto gracza z udostępnień.", "success")
    end
end)

addEvent("px_parking:addRentToGarage", true)
addEventHandler("px_parking:addRentToGarage", getResourceRootElement(), function(ownerID, playerID, playerName)
    if not client then return false end

    local status = addRentToGarage(ownerID, playerID)
    if status then 
        refreshPlayerInfo(client) 
        sendNotification(client, "Pomyślnie udostępniono parking dla gracza "..playerName..".", "success")
    end
end)

addEvent("px_parking:exitGarage", true)
addEventHandler("px_parking:exitGarage", getResourceRootElement(), function(ownerID)
    local q=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", ownerID)
    if(q and #q > 0)then
        exitPlayerFromGarage(client, q[1].id)
    end
end)

addEvent("px_parking:enterGarage", true)
addEventHandler("px_parking:enterGarage", getResourceRootElement(), function(ownerID)
    local q=exports.px_connect:query("select * from vehicles_garages where playerID=? limit 1", ownerID)
    if(q and #q > 0)then
        enterParking(client, q[1].id)
    end
end)

addEvent("px_parking:getVehicleFromParking", true)
addEventHandler("px_parking:getVehicleFromParking", getResourceRootElement(), function(vehicle, ownerID)
    if(not isElement(vehicle))then 
        local vehicle = getVehicleFromParking(vehicle, ownerID, client)
        setVehicleEngineState(vehicle, true)
        return 
    end
    
    local controller=getVehicleController(vehicle)
    if(controller == client)then
        local vehicle = getVehicleFromParking(vehicle, ownerID, client)
        setVehicleEngineState(vehicle, true)
    else
        local q=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", ownerID)
        if(q and #q == 1 and parking.garages[q[1].id])then
            local garage=parking.garages[q[1].id]

            garage.players[client]=nil

            if(table.size(garage.players) == 0)then
                for i,v in pairs(garage.vehicles) do
                    if(i and isElement(i))then
                        local vehID=getElementData(i, "vehicle:id")
                        
                        exports.px_vehicles:saveVehicle(i,'destroy')
        
                        exports.px_connect:query("update vehicles set parking=? where id=?", q[1].id, vehID)
                    end
                end
    
                destroyElement(parking.garages[q[1].id].interior)
                parking.garages[q[1].id]=nil
            end
        end
    end
end)

addEvent("px_parking:trySendVehicleToParking", true)
addEventHandler("px_parking:trySendVehicleToParking", getResourceRootElement(), function(vehicle, ownerID)
    local q=exports.px_connect:query("select * from vehicles_garages where playerID=? limit 1", ownerID)
    if(q and #q > 0)then
        sendVehicleToParking(client, vehicle, q[1].id)
    end
end)

-- start

addEventHandler("onResourceStart", getResourceRootElement(), function()
    createParking(1)
    setParkingEnterVehicle(1, 2399.9978,1516.9840,10.8203)
    setParkingEnter(1, 2394.1929,1510.0886,10.8203)
end)