--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function destroyPlayerBlip(player)
end

function createBlipAttachedVehicle(id)
	triggerClientEvent(root, "createBlipAttachedVehicle", resourceRoot, id)
end