--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local grass = {9,10,11,12,13,14,15,16,17,20,80,81,82,115,116,117,118,119,120,121,122,125,129,146,147,148,149,150,151,152,153,160,75,77,76,56,85,26,143,112,40,123,74,128,126,109,30,33,35,178}
local surface = 0
local maxSurface = 20 -- gdy napelni, opona sie przebija
local x2,y2,z2

function oponkiRender()
    local veh=getPedOccupiedVehicle(localPlayer)
    if not veh then 
        removeEventHandler("onClientRender", root, oponkiRender)
        return 
    end

	local x1,y1,z1 = getElementPosition(localPlayer)
	if not x2 or not y2 or not z2 then
		x2,y2,z2 = getElementPosition(localPlayer)
	end

	local dist=getDistanceBetweenPoints3D(x1,y1,z1, x2,y2,z2)
    local data=getElementData(veh, 'vehicle:wheelsSettings') or {tire=1}
    local haveOffroad=getElementData(veh, "vehicle:offroad") or data.tire == 5
	if dist > 10 and getElementSpeed(veh) > 30 and not haveOffroad and getVehicleName(veh) ~= "Mower" then
		local material = getSurfaceVehicleIsOn(veh)
		x2,y2,z2 = getElementPosition(localPlayer)
        if isPlayerOnGrass(material) then
            if(surface >= maxSurface)then
                surface=0

                local rnd=math.random(1,4)
                local s={getVehicleWheelStates(veh)}
                if(rnd == 1)then
                    setVehicleWheelStates(veh, 1, s[2], s[3], s[4])
                elseif(rnd == 2)then
                    setVehicleWheelStates(veh, s[1], 1, s[3], s[4])
                elseif(rnd == 3)then
                    setVehicleWheelStates(veh, s[1], s[2], 1, s[4])
                elseif(rnd == 4)then
                    setVehicleWheelStates(veh, s[1], s[2], s[3], 1)
                end
            else
                surface=surface+0.5
            end
        else
            surface=0
		end
	end
end

addEventHandler("onClientVehicleEnter", root, function(plr,seat)
    if(plr ~= localPlayer or seat ~= 0)then return end

    addEventHandler("onClientRender", root, oponkiRender)
end)
addEventHandler("onClientRender", root, oponkiRender)

-- useful

function getSurfaceVehicleIsOn(vehicle)
    if isElement(vehicle) and isVehicleOnGround(vehicle) then 
        local cx, cy, cz = getElementPosition(vehicle)
        local gz = getGroundPosition(cx, cy, cz) - 0.001
        local hit, _, _, _, _, _, _, _, material = processLineOfSight(cx, cy, cz, cx, cy, gz, true, false, false) 
        if hit then
            return material 
        end
    end
    return false 
end

function isPlayerOnGrass(material)
    for i,v in ipairs(grass) do
    if v == material then
        return true
    end
    end
    return false
end

function getElementSpeed(theElement, unit)
    local vx,vy,vz=getElementVelocity(theElement)
    local speed=math.sqrt(vx^2 + vy^2 + vz^2) * 180
    return speed
end