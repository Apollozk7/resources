--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

--do napisania na podstawie systemu pojazdow
function isVehiclePrivate(vehicle)
    return getElementData(vehicle, "vehicle:id")
end

function getVehicleUID(vehicle)
    return getElementData(vehicle, "vehicle:id")
end

function getVehiclesInGarage(parkingID)
    if not parkingID then return false end
    local q = exports.px_connect:query("SELECT * FROM vehicles WHERE parking=? LIMIT 12", parkingID)
    return (q or {})
end

function getPlayerVehicles(player)
    local playerUID = getPlayerUID(player)
    if not playerUID then return false end
    return exports.px_connect:query("select * from vehicles where owner=?", playerUID)
end

function getVehicleOwnerFromID(id)
    local q = exports.px_connect:query("SELECT owner FROM vehicles WHERE id=? LIMIT 1", id)
    return (q and #q > 0 and q[1].owner or false)
end

--do napisania na podstawie systemu graczy
function getPlayerUID(player)
    return getElementData(player, "user:uid")
end

function getPlayerID(player)
    return getElementData(player, "user:id")
end

function getPlayerLoginByUID(uid)
    local q = exports.px_connect:query("SELECT login FROM accounts WHERE id=? LIMIT 1", uid)
    return (q and #q > 0 and q[1].login or "(?)")
end

function getPlayerLastOnlineByUID(uid)
    local q = exports.px_connect:query("SELECT lastlogin FROM accounts WHERE id=? LIMIT 1", uid)
    return (q and #q > 0 and q[1].lastlogin or false)
end

function sendNotification(player, text, type)
    exports.px_noti:noti(text, player, type)
end

function table.size(tab)
    if(not tab)then return 0 end

    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    
    return length
end