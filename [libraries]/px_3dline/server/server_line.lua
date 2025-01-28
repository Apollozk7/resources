--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local LINES = {}

-- trigers

addEvent("3dline.expand", true)
addEventHandler("3dline.expand", resourceRoot, function(pos, block)
    triggerClientEvent(hit, "3dline.expand", resourceRoot, client, pos, block)
end)

addEvent("3dline.fold", true)
addEventHandler("3dline.fold", resourceRoot, function(id, all)
    if(all)then
        triggerClientEvent(hit, "3dline.fold", resourceRoot, client, id)
        return
    end

    triggerClientEvent(hit, "3dline.fold", resourceRoot, client, id)
end)

-- variables

function create3dLine(hit, pos, pos2, sourceResource)
    triggerClientEvent(hit, "3dline.create", resourceRoot, hit, pos, pos2)

    LINES[hit] = sourceResource
end

function destroy3dLine(hit)
    triggerClientEvent(hit, "3dline.destroy", resourceRoot, hit)

    if(LINES[hit])then
        exports[LINES[hit]]:destroyLine(hit)
        LINES[hit] = nil
    end
end
addEvent("3dline.destroy", true)
addEventHandler("3dline.destroy", resourceRoot, destroy3dLine)

function isPlayerHaveLine(player)
    if(LINES[player])then
        return true
    end
    return false
end