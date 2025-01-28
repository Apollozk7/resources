--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local developer = {
	x,y,z = 0,0,0,
	speed = 1,
	air = 0,
}

bindKey("0", "down", function()
	if getElementData(localPlayer, "user:admin") and getElementData(localPlayer, "user:admin") >= 2 then
		local player = getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicle(localPlayer) or localPlayer

		if developer.air == 1 then
			removeEventHandler("onClientRender", root, render)

			setElementFrozen(player, false)
			setElementCollisionsEnabled(player, true)

			developer.air = 0
		else
			if((getElementData(localPlayer, "user:job") or getElementData(localPlayer, "user:faction")) and (not getElementData(localPlayer, "user:admin") or (getElementData(localPlayer, "user:admin") and getElementData(localPlayer, "user:admin") < 5)))then return end

			addEventHandler("onClientRender", root, render)
			
			setElementFrozen(player, true)
			setElementCollisionsEnabled(player, false)

			developer["x"],developer["y"],developer["z"] = getElementPosition(player)
			developer.air = 1
		end
	end
end)

function render()
	if(not getElementData(localPlayer, "user:admin") or isChatBoxInputActive() or (getElementData(localPlayer, "user:job") or getElementData(localPlayer, "user:faction")) and (not getElementData(localPlayer, "user:admin") or (getElementData(localPlayer, "user:admin") and getElementData(localPlayer, "user:admin") < 5)))then return end
	
	local player = getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicle(localPlayer) or localPlayer

	local x,y,z = getElementPosition(player)
	x,y,z = string.format("%.2f", x),string.format("%.2f", y),string.format("%.2f", z)

    local c_x,c_y,c_z,c2_x,c2_y,c2_z = getCameraMatrix()
    c2_x,c2_y,c2_z = c2_x-c_x,c2_y-c_y,c2_z-c_z
    local m = developer["speed"]/math.sqrt(c2_x*c2_x+c2_y*c2_y)

    if getKeyState("lctrl") then
    	developer["speed"] = 10
    elseif getKeyState("lalt") then
    	developer["speed"] = 0.03
    else
    	developer["speed"] = 1
    end

    c2_x,c2_y = c2_x*m,c2_y*m

    if getKeyState("w") then
    	developer["x"],developer["y"] = developer["x"]+c2_x,developer["y"]+c2_y
    end
    if getKeyState("s") then
    	developer["x"],developer["y"] = developer["x"]-c2_x,developer["y"]-c2_y
    end
    if getKeyState("a") then
    	developer["x"],developer["y"] = developer["x"]-c2_y,developer["y"]+c2_x
    end
    if getKeyState("d") then
    	developer["x"],developer["y"] = developer["x"]+c2_y,developer["y"]-c2_x
    end
    if getKeyState("space") then
    	developer["z"] = developer["z"]+developer["speed"]
    end
    if getKeyState("lshift") then
    	developer["z"] = developer["z"]-developer["speed"]
    end

    setElementPosition(player, developer["x"], developer["y"], developer["z"])
    setElementRotation(player, 0, 0, getElementType(player) == "player" and getPedCameraRotation(localPlayer) or -getPedCameraRotation(localPlayer))
end
