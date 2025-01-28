--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local markers={
    {930.3065,1718.7980,8.8516},
}

for i,v in pairs(markers) do
    local marker=createMarker(v[1], v[2], v[3]-1, "cylinder", 1.2, 0, 200, 100)
    setElementData(marker, "icon", ":px_change_plates/textures/platesMarker.png")
    setElementData(marker, "text", {text="Zmiana rejestracji",desc="Tutaj zmienisz rejestracje w pojeździe"})
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local uid=getElementData(hit, "user:uid")
        if(not uid)then return end

        local premium=getElementData(hit, "user:premium")
        local gold=getElementData(hit, "user:gold")
        if(premium or gold)then
            local q=exports.px_connect:query("select * from vehicles where owner=?", uid)
            if(q and #q > 0)then
                triggerClientEvent(hit, "open.plate.ui", resourceRoot, q)
            else
                exports.px_noti:noti("Nie posiadasz żadnych pojazdów.", hit)
            end
        else
            exports.px_noti:noti("Ta usługa jest tylko dla graczy PREMIUM oraz GOLD.", hit, "error")
        end
    end
end)

addEvent("set.veh.plate", true)
addEventHandler("set.veh.plate", resourceRoot, function(text, vehID)
    local r=exports.px_connect:query("select plateText from vehicles where plateText=? limit 1", text)
    if(r and #r > 0)then
        exports.px_noti:noti("Podana rejestracja jest już zajęta.", client, "error")
    else
        local q=exports.px_connect:query("update vehicles set plateText=? where id=?", text, vehID)
        if(q)then
            exports.px_noti:noti("Pomyślnie zmieniono rejestracje w pojeździe.", client, "success")

            exports.px_discord:sendDiscordLogs("[ZMIANA REJESTRACJI] Auto "..vehID.." na "..text, "hajs", client)
        end
    end
end)