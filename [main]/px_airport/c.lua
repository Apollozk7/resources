--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent("setObjectPosition", true)
addEventHandler("setObjectPosition", resourceRoot, function(obj, pos)
    if(obj and isElement(obj))then
        moveObject(obj, 1000, pos[1], pos[2], pos[3])
    end
end)