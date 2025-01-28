function applyVehicleSirens(veh)
    if(getElementModel(veh) == 443)then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 4, 2, true, false, false, true)
        setVehicleSirens(veh, 1, 0.6, 4, 1.4, 229.5, 147.9, 5.1, 255, 255)
        setVehicleSirens(veh, 2, -0.7, 4, 1.4, 224.4, 147.9, 5.1, 255, 255)
        setVehicleSirens(veh, 3, -0.7, 4.5, -0.3, 224.4, 142.8, 5.1, 255, 255)
        setVehicleSirens(veh, 4, 0.8, 4.5, -0.3, 224.4, 147.9, 5.1, 255, 255)
    elseif(getElementModel(veh) == 596)then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 6, 2, false, false, false, true)
        setVehicleSirens(veh, 1, 0.5, -0.3, 0.9, 0, 30.6, 255, 255, 255)
        setVehicleSirens(veh, 2, -0.5, -0.3, 0.9, 255, 0, 0, 255, 255)
        setVehicleSirens(veh, 3, 0.6, -1.4, 0.6, 255, 0, 0, 255, 255)
        setVehicleSirens(veh, 4, -0.6, -1.4, 0.6, 0, 25.5, 255, 198.9, 198.9)
        setVehicleSirens(veh, 5, -0.2, 2.4, 0, 0, 40.8, 255, 198.9, 198.9)
        setVehicleSirens(veh, 6, 0.2, 2.4, 0, 255, 0, 0, 255, 255)
    elseif(getElementModel(veh) == 554)then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 6, 2, true, false, false, true)
        setVehicleSirens(veh, 1, -0.5, -3, 0.8, 0, 35.7, 255, 255, 255)
        setVehicleSirens(veh, 2, 0.5, -3, 0.8, 255, 0, 0, 255, 255)
        setVehicleSirens(veh, 3, 0.2, 2.7, 0, 0, 35.7, 255, 255, 255)
        setVehicleSirens(veh, 4, -0.2, 2.7, 0, 255, 0, 0, 255, 255)
        setVehicleSirens(veh, 5, -0.4, -0.3, 1.1, 255, 0, 0, 255, 255)
        setVehicleSirens(veh, 6, 0.4, -0.3, 1.1, 0, 35.7, 255, 198.9, 198.9)
    elseif(getElementModel(veh) == 599)then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 6, 2, true, false, false, true)
        setVehicleSirens(veh, 1, -0.7, -0.1, 1.1, 255, 0, 0, 255, 255)
        setVehicleSirens(veh, 2, 0.7, -0.1, 1.1, 0, 35.7, 255, 255, 255)
        setVehicleSirens(veh, 3, 0.3, 2.7, 0, 255, 0, 0, 255, 255)
        setVehicleSirens(veh, 4, -0.3, 2.7, 0, 0, 35.7, 255, 255, 255)
        setVehicleSirens(veh, 5, -0.5, -2.3, 0.8, 0, 35.7, 255, 255, 255)
        setVehicleSirens(veh, 6, 0.5, -2.3, 0.8, 255, 0, 0, 255, 255)
    elseif(getElementModel(veh) == 597)then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 6, 2, true, false, false, true)
        setVehicleSirens(veh, 1, -0.6, 0, 0.8, 255, 0, 0, 255, 255)
        setVehicleSirens(veh, 2, 0.6, 0, 0.8, 0, 35.7, 255, 255, 255)
        setVehicleSirens(veh, 3, 0, 0.8, 0.4, 255, 0, 0, 255, 255)
        setVehicleSirens(veh, 4, 0, 0.8, 0.4, 0, 35.7, 255, 255, 255)
        setVehicleSirens(veh, 5, -0.5, -0.9, 0.6, 0, 35.7, 255, 255, 255)
        setVehicleSirens(veh, 6, 0.5, -0.9, 0.6, 255, 0, 0, 255, 255)
    elseif(getElementModel(veh) == 459)then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 2, 2, true, false, false, true)
        setVehicleSirens(veh, 1, 0.5, 0.7, 1.1, 229.5, 147.9, 5.1, 255, 255)
        setVehicleSirens(veh, 2, -0.5, 0.7, 1.1, 229.5, 142.8, 5.1, 255, 255)
    elseif(getVehicleName(veh) == "DFT-30" and getElementData(veh, "vehicle:group_owner") == "PSP")then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 6, 2, true, false, false, true)
        setVehicleSirens(veh, 1, -0.4, 3.4, 0, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 2, 0.4, 3.4, 0, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 3, 0.9, 2.9, 1.4, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 4, -0.9, 2.9, 1.4, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 5, -1.1, -3.7, 1.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 6, 1.1, -3.7, 1.3, 0, 127.5, 255, 255, 255)
    elseif(getElementModel(veh) == 598 and getElementData(veh, "vehicle:group_owner") == "PSP")then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 2, 2, true, false, false, true)
        setVehicleSirens(veh, 1, -0.5, -0.2, 0.8, 0, 127.5, 255, 198.9, 198.9)
        setVehicleSirens(veh, 2, 0.5, -0.2, 0.8, 0, 127.5, 255, 200, 200)
    elseif(getElementModel(veh) == 407 and getElementData(veh, "vehicle:group_owner") == "PSP")then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 6, 2, true, false, false, true)
        setVehicleSirens(veh, 1, 1, 3.1, 1.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 2, -1, 3.1, 1.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 3, -0.4, 3.6, -0.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 4, 0.4, 3.6, -0.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 5, -1.1, -3.4, 1.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 6, 1.1, -3.4, 1.3, 0, 127.5, 255, 255, 255)
    elseif(getElementModel(veh) == 455 and getElementData(veh, "vehicle:group_owner") == "PSP")then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 6, 2, true, false, false, true)
        setVehicleSirens(veh, 1, 0.8, 2.9, 1.4, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 2, -0.8, 2.9, 1.4, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 3, -0.4, 3.4, -0.2, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 4, 0.4, 3.4, -0.2, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 5, -1.1, -3.8, 0.6, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 6, 1.1, -3.8, 0.6, 0, 127.5, 255, 255, 255)
    elseif(getElementModel(veh) == 416 and getElementData(veh, "vehicle:group_owner") == "PSP")then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 6, 2, true, false, false, true)
        setVehicleSirens(veh, 1, 0.4, 0.8, 1.5, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 2, -0.4, 0.8, 1.5, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 3, 0.4, 2.7, 0, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 4, -0.4, 2.7, 0, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 5, -0.5, -2.3, 1.6, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 6, 0.5, -2.3, 1.6, 0, 127.5, 255, 255, 255)
    elseif(getElementModel(veh) == 433 and getElementData(veh, "vehicle:group_owner") == "PSP")then
        removeVehicleSirens(veh)
        addVehicleSirens(veh, 6, 2, true, false, false, true)
        setVehicleSirens(veh, 1, 1, 3.1, 1.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 2, -1, 3.1, 1.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 3, -0.4, 3.6, -0.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 4, 0.4, 3.6, -0.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 5, -1.1, -3.4, 1.3, 0, 127.5, 255, 255, 255)
        setVehicleSirens(veh, 6, 1.1, -3.4, 1.3, 0, 127.5, 255, 255, 255)
    end
end

addEventHandler("onVehicleEnter", root, function(plr,seat)
    if(seat ~= 0 or getVehicleSirensOn(source))then return end

    applyVehicleSirens(source)
end)

--

Siren={}
Siren.Timers={}

Siren.Start=function(vehicle)
    Siren.Stop(vehicle)
    
    Siren.Timers[vehicle]=setTimer(function()
        if(vehicle and isElement(vehicle))then
            if(getVehicleLightState(vehicle, 0) == 1)then
                setVehicleLightState(vehicle,0,0)
                setVehicleLightState(vehicle,1,1)
                setVehicleLightState(vehicle,2,0)
                setVehicleLightState(vehicle,3,1)
            else
                setVehicleLightState(vehicle,0,1)
                setVehicleLightState(vehicle,1,0)
                setVehicleLightState(vehicle,2,1)
                setVehicleLightState(vehicle,3,0)
            end
        else
            Siren.Stop(vehicle)
        end
    end, 200, 0)
end

Siren.Stop=function(vehicle)
    if(Siren.Timers[vehicle])then
        killTimer(Siren.Timers[vehicle])
        Siren.Timers[vehicle]=nil

        if(vehicle and isElement(vehicle))then
            setVehicleLightState(vehicle,0,0)
            setVehicleLightState(vehicle,1,0)
            setVehicleLightState(vehicle,2,0)
            setVehicleLightState(vehicle,3,0)
        end
    end
end

addEventHandler('onElementDestroy', root, function()
    Siren.Stop(source)
end)

Siren.Factions={
    ["SAPD"]=true,
    ["SARA"]=true,
    ["PSP"]=true,
}

addEventHandler('onElementDataChange', root, function(data,old,new)
    if(data == "vehicle:components" and getElementData(source, "vehicle:group_ownerName") and Siren.Factions[getElementData(source, "vehicle:group_ownerName")])then
        if(new and new["siren_on"])then
            Siren.Start(source)
        else
            Siren.Stop(source)
        end
    end
end)