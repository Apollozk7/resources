--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local helmets={}

function helmet(player, type)
    if(type == "create" and not helmets[player])then
        local x,y,z=getElementPosition(player)
        helmets[player]=createObject(1248, x,y,z+1)
        exports.pAttach:attachElementToBone(helmets[player], player,1,0,0,-0.05,0,0,90)
    elseif(type == "destroy" and helmets[player])then
        if(isElement(helmets[player]))then
            destroyElement(helmets[player])
            helmets[player]=nil
        end
    end
end

addEvent("helmet", true)
addEventHandler("helmet", resourceRoot, function()
    setPedAnimation(client, "goggles", "goggles_put_on")
    setTimer(function(plr)
        setPedAnimation(plr, nil)
    end, 500,1, client)

    helmet(client, helmets[client] and "destroy" or "create")
end)

addEventHandler("onVehicleExit", root, function(player)
    helmet(player, "destroy")
end)

addEventHandler("onPlayerQuit", root, function()
    helmet(source, "destroy")
end)