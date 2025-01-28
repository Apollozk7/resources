--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function noti(data, player, type, timeoff, from)
    if(player and isElement(player) and getElementType(player) == "player")then
	    triggerClientEvent(player, "notka", resourceRoot, data, type, timeoff, from)
    end
end
