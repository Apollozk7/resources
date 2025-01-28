--[[
    @author: CrosRoad95, psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local speedo=exports.px_speedo

function getElementSpeed(theElement)
    return (Vector3(getElementVelocity(theElement)) * 180).length
end

bindKey("lshift", "both", function(key ,state)
    speedo=exports.px_speedo
    
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if(vehicle)then
        speedo=exports.px_speedo

        local type=speedo:getVehicleSpeedoType(vehicle)
        if(type ~= 7 and type ~= 8 and not getElementData(vehicle, "event"))then
            if(getVehicleController(vehicle) == localPlayer)then
                if(state == "down")then
                    if(not getElementData(localPlayer, "user:interaction_showed") and not getElementData(localPlayer, "user:gui_showed") and not getElementData(vehicle, "public:vehicle"))then
                        open(vehicle)
                        setElementData(localPlayer, "user:interaction_showed", true, false)
                    end
                elseif(state =="up")then
                    close()
                end
            end
        end
    end
end)

-- on stop

addEventHandler("onClientResourceStop", resourceRoot, function()
    setElementData(localPlayer, "user:interaction_showed", false, false)
end)