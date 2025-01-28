--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function isPlayerOnWhitelist(serial)
    local result = exports.px_connect:query("select * from misc_whitelist where serial=? limit 1", serial)
    if(result and #result > 0)then
        return true
    end
    return nil
end

addEventHandler("onPlayerConnect", root, function(nick, _, _, serial)
    local access = isPlayerOnWhitelist(serial)
    if(access and getPlayerFromName(nick))then
        outputChatBox("* Dostęp odnaleziony na whiteliscie.", getPlayerFromName(nick), 255, 255, 255, true)
    else
        cancelEvent(true, "✗ Brak dostępu.")
    end
end)
