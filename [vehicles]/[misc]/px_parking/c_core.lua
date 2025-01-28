--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

parking = {}
    parking.last = {}

parking.tryRemoveRentPlayer = function(ownerID, playerID)
    if not ownerID or not playerID then return false end

    if parking.last.removeRent and getTickCount()-parking.last.removeRent < 5000 then
        local time = string.format("%.1f", ((parking.last.removeRent+5000)-getTickCount())/1000)
        sendNotification("Poczekaj "..time.." s, aby ponownie wyrzucić jednego z użytkowników.")
        return false
    end
    parking.last.removeRent = getTickCount()
    triggerServerEvent("px_parking:removeRentFromGarage", resourceRoot, ownerID, playerID)
end

parking.tryAddRentPlayer = function(ownerID, findValue)
    if not ownerID or not findValue then return false end

    local player = findPlayer(findValue)
    if not player then
        sendNotification("Nie odnaleziono użytkownika o nickname/id: "..findValue.." :(")
        return false
    end

    if player == localPlayer then
        sendNotification("Chcesz dodać samego siebie? Dziwne.")
        return false
    end
    
    local playerID = getPlayerUID(player)
    if not playerID then return false end

    if parking.last.addRent and getTickCount()-parking.last.addRent < 5000 then
        local time = string.format("%.1f", ((parking.last.addRent+5000)-getTickCount())/1000)
        sendNotification("Poczekaj "..time.." s, aby ponownie dodać jednego z użytkowników.")
        return false
    end

    parking.last.addRent = getTickCount()
    triggerServerEvent("px_parking:addRentToGarage", resourceRoot, ownerID, playerID, getPlayerName(player))
end

parking.tryEnterGarage = function(ownerID)
    if not ownerID then return false end

    if parking.last.enterGarage and getTickCount()-parking.last.enterGarage < 5000 then
        local time = string.format("%.1f", ((parking.last.enterGarage+5000)-getTickCount())/1000)
        sendNotification("Poczekaj "..time.." s, aby ponownie wejść do garażu.")
        return false
    end

    parking.last.enterGarage = getTickCount()
    triggerServerEvent("px_parking:enterGarage", resourceRoot, ownerID)
end

addEvent("px_parking:onEnterParking", true)
addEventHandler("px_parking:onEnterParking", getResourceRootElement(), function(ownerID)
    parking.garage = {}
    parking.ownerID = ownerID

    parking.garage.exitWithVehicle = createMarker(2402.2402,1514.0732,876.3228-1, 'cylinder', 2, 235, 97, 52)
    setElementData(parking.garage.exitWithVehicle, "icon", ":px_parking/textures/outMarker.png", false)
    setElementData(parking.garage.exitWithVehicle, "pos:z", 876.3228-0.97)
    setElementDimension(parking.garage.exitWithVehicle, getElementDimension(localPlayer))
    setElementData(parking.garage.exitWithVehicle, "text", {text="Wyjazd", desc="Wyjazd na zewnątrz"})

    parking.garage.exit = createMarker(2399.0107,1511.5546,876.3696, "cylinder", 1.1, 254, 123, 123)
    setElementData(parking.garage.exit, "icon", ":px_parking/textures/outMarker.png", false)
    setElementData(parking.garage.exit, "pos:z", 876.3228-0.9)
    setElementDimension(parking.garage.exit, getElementDimension(localPlayer))
    setElementData(parking.garage.exit, "text", {text="Wyjście", desc="Wyjście na zewnątrz"})

    addEventHandler("onClientMarkerHit", parking.garage.exitWithVehicle, parking.tryExitGarageWithVehicle)
    addEventHandler("onClientMarkerHit", parking.garage.exit, parking.tryExitGarage)
end)

local controls = {"accelerate", "brake_reverse", "enter_exit", "vehicle_left", "vehicle_right"}

parking.tryExitGarageWithVehicle = function(hit, md)
    if not hit or not md or hit ~= localPlayer then return false end
    if isTimer(parking.exitGarageTimer) then return false end

    local vehicle = getPedOccupiedVehicle(hit)
    if not vehicle then return false end

    local ownerID = parking.ownerID
    local vehicleID = getElementData(vehicle, "vehicle:id")
    if not ownerID or not vehicleID then return false end

    fadeCamera(false)
    toggleAllControls(false)
    setElementFrozen(vehicle, true)
    exports.px_loading:createLoadingScreen(true, false, 7000)

    parking.exitGarageTimer=setTimer(function(vehicle, ownerID)
        triggerServerEvent("px_parking:getVehicleFromParking", getResourceRootElement(), vehicle, ownerID)

        parking.exitGarageTimer = setTimer(function(vehicle, ownerID)
            for i, v in ipairs(controls) do toggleControl(v, true) end
    
            fadeCamera(true)
        
            if isElement(parking.garage.exit) then destroyElement(parking.garage.exit) end
            if isElement(parking.garage.exitWithVehicle) then destroyElement(parking.garage.exitWithVehicle) end
    
            parking.ownerID = nil
    
            setElementFrozen(vehicle, false)
    
            toggleAllControls(true)
            toggleControl("radar",false)
        end, 6000, 1, vehicle, ownerID)
    end, 1000, 1, vehicle, ownerID)
end

parking.tryExitGarage = function(hit, md)
    if not hit or not md or hit ~= localPlayer or getPedOccupiedVehicle(localPlayer) then return false end

    local ownerID = parking.ownerID
    if not ownerID then return false end

    triggerServerEvent("px_parking:exitGarage", resourceRoot, ownerID)

    if isElement(parking.garage.exit) then destroyElement(parking.garage.exit) end
    if isElement(parking.garage.exitWithVehicle) then destroyElement(parking.garage.exitWithVehicle) end

    parking.ownerID = nil
end

parking.tryRemoveVehicleFromGarage = function(ownerID, vehicleID)
    if not ownerID or not vehicleID then return false end

    if parking.last.removeVehicleFromGarage and getTickCount()-parking.last.removeVehicleFromGarage < 5000 then
        local time = string.format("%.1f", ((parking.last.removeVehicleFromGarage+5000)-getTickCount())/1000)
        sendNotification("Poczekaj "..time.." s, aby ponownie dodać jednego z użytkowników.")
        return false
    end

    parking.last.removeVehicleFromGarage = getTickCount()
    triggerServerEvent("px_parking:removeVehicleFromParking", resourceRoot, ownerID, vehicleID)
end