--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent('setGPSPosition', true)
addEventHandler('setGPSPosition', resourceRoot, function(veh,x,y,z)
    if(veh and isElement(veh) and x and y and z)then
        local controller=getVehicleController(veh)
        if(controller and controller ~= client)then
            triggerClientEvent(controller, 'setGPSPosition', resourceRoot, x,y,z, true)
        else
            for i,v in pairs(getVehicleOccupants(veh)) do
                if(v ~= client)then
                    triggerClientEvent(v, 'setGPSPosition', resourceRoot, x,y,z, true)
                end
            end
        end
    end
end)