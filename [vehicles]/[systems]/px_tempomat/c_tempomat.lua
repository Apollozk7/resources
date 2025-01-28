--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local noti=exports.px_noti

local ui={}

ui.tempomat=false

ui.onRender=function()
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(ui.tempomat and vehicle and isVehicleOnGround(vehicle))then
        local speed=getElementSpeed(vehicle, "km/h")
        
        if(not getPedControlState(localPlayer, "accelerate"))then
            setPedControlState(localPlayer, "accelerate", true)
        end

        if(speed > ui.tempomat)then
            setElementSpeed(vehicle, "km/h", ui.tempomat)
        end
    else
        removeEventHandler("onClientRender", root, ui.onRender)
        setPedControlState(localPlayer, "accelerate", false)
        ui.tempomat=false
    end
end

bindKey("R", "down", function()
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(vehicle and getVehicleController(vehicle) == localPlayer and not isCursorShowing())then
        if(ui.tempomat)then
            removeEventHandler("onClientRender", root, ui.onRender)
            setPedControlState(localPlayer, "accelerate", false)
            ui.tempomat=false

            noti:noti("Wyłączono tempomat.", "success")
        else
            local speed=getElementSpeed(vehicle, "km/h")
            if(speed >= 30)then
                ui.tempomat=getElementSpeed(vehicle, "km/h")
                addEventHandler("onClientRender", root, ui.onRender)

                noti:noti("Tempomat został ustawiony na "..math.floor(ui.tempomat).."km/h.", "success")
            else
                noti:noti("Musisz się poruszać z minimalną prędkością 30km/h.", "error")
            end
        end
    end
end)

-- useful

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and "ignore" argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = getElementSpeed(element, unit)
	if acSpeed and acSpeed~=0 then -- if true - element is valid, no need to check again
		local diff = speed/acSpeed
		if diff ~= diff then return false end -- if the number is a 'NaN' return false.
        	local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end
	return false
end