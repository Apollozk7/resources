--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPEEDO.isVehicleHaveNitro=function(v)
    return getElementData(v, "vehicle:nitro") == "Pulsacyjne"
end

SPEEDO.getRenderNitro=function(vehicle)
    if(SPEEDO.isVehicleHaveNitro(vehicle) and getVehicleUpgradeOnSlot(vehicle, 8) and getVehicleController(vehicle) == localPlayer)then        
        if((getKeyState("lctrl") or getKeyState("lalt")))then         
            local nitro=getElementData(vehicle, "vehicle:nitroLevel") or 100
            if(nitro > 10)then
                nitro=nitro-0.05
                setElementData(vehicle, "vehicle:nitroLevel", nitro)
                setVehicleNitroLevel(vehicle, 1)
                setVehicleNitroActivated(vehicle, true)
            else
                if(isVehicleNitroActivated(vehicle))then
                    setVehicleNitroActivated(vehicle, false)
                end
            end
        else
            if(isVehicleNitroActivated(vehicle))then
                setVehicleNitroActivated(vehicle, false)
            end
        end
    end

    -- off atrapa
    if(not getElementData(vehicle, "vehicle:nitro") or (getElementData(vehicle, "vehicle:nitro") and string.find(getElementData(vehicle, "vehicle:nitro"),"Atrapa") and isVehicleNitroActivated(vehicle)))then
        setVehicleNitroActivated(vehicle, false)
    end
    --
end

SPEEDO.addNitro=function(vehicle,value)
    local nitro=getElementData(vehicle, "vehicle:nitroLevel") or 100
    if(SPEEDO.isVehicleHaveNitro(vehicle) and (nitro+value) <= 100 and getVehicleUpgradeOnSlot(vehicle, 8))then
        setElementData(vehicle, "vehicle:nitroLevel", nitro+value)
    end
end

addCommandHandler("nitro", function()
    if(getPlayerSerial(localPlayer) == "6B5048F9C35CA15C06F792A55C85F153")then
        local v=getPedOccupiedVehicle(localPlayer)
        if(v)then
            setElementData(v, "vehicle:nitroLevel", 100)
        end
    end
end)