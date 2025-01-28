--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local marker=createMarker(2338.9353,2468.4712,14.9844-1, "cylinder", 1.1, 0, 125, 255)
setElementData(marker, "icon", ":px_factions_mandates/textures/marker.png")
setElementData(marker, "text", {text="Mandaty",desc="Tutaj opłacisz mandaty"})

addEventHandler("onMarkerHit", marker, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local uid=getElementData(hit, "user:uid")
        if(not uid)then return end

        local q=exports.px_connect:query('select * from accounts_mandates where uid=?', uid)
        if(q and #q > 0)then
            triggerClientEvent(hit, "G.openInterface", resourceRoot, q)
        else
            exports.px_noti:noti("Nie posiadasz mandatów do opłacenia.", hit, "error")
        end
    end
end)

addEvent("G.payMandate", true)
addEventHandler("G.payMandate", resourceRoot, function(v, id)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    if(v and id)then
        local r=exports.px_connect:query('select * from accounts_mandates where id=?', v.id)
        if(r and #r == 1)then
            takePlayerMoney(client, tonumber(v.money))
        
            exports.px_connect:query("delete from accounts_mandates where id=?", v.id)
            exports.px_noti:noti("Pomyślnie opłacono mandat za $"..v.money, client, "success")

            local mandates=exports.px_connect:query('select * from accounts_mandates where uid=?', uid)
            exports["px_factions-tablet"]:getPlayerMandates(client, mandates)
        end
    else
        local mandates=exports.px_connect:query('select * from accounts_mandates where uid=?', uid)
        if(mandates and #mandates > 0)then
            local money=0
            for i,v in pairs(mandates) do
                money=money+v.money
            end

            if(getPlayerMoney(client) >= tonumber(money))then
                takePlayerMoney(client, tonumber(money))

                exports.px_connect:query("delete from accounts_mandates where uid=?", uid)
                exports.px_noti:noti("Pomyślnie opłacono mandaty za $"..money, client, "success")

                local mandates=exports.px_connect:query('select * from accounts_mandates where uid=?', uid)
                exports["px_factions-tablet"]:getPlayerMandates(client, mandates)
            else
                exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
            end
        else
            exports.px_noti:noti("Nie posiadasz żadnych mandatów do opłacenia.", client, "info")
        end
    end
end)