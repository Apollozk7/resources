--[[
	@author: psychol.
]]

function addVehicleEngine(vehicle)
	local type = getElementData(vehicle, "bengines:info")
	if type then
		local x,y,z=getElementPosition(vehicle)
		local col=getElementsWithinRange(x,y,z,20,"player")
		for k, v in pairs(col) do 
			triggerClientEvent(v, "onClientRefreshEngineSounds", v)
		end 
	end
end 

function onResourceStart()
	for k, v in ipairs(getElementsByType("vehicle")) do 		
		local type = getElementData(v, "bengines:info") or getVehicleSoundPack(v)
		if(type)then
			setElementData(v, "bengines:info", type)
			addVehicleEngine(v)
		end 
	end
end 
addEventHandler("onResourceStart", resourceRoot, onResourceStart)

function onVehicleEnter(player, seat, jacked)
	if seat == 0 and source and isElement(source) then 
		local type = getElementData(source, "bengines:info") or getVehicleSoundPack(source)
		if(type)then
			setElementData(source, "bengines:info", type)
			addVehicleEngine(source)
		end 
	end
end
addEventHandler("onVehicleEnter", root, onVehicleEnter)
