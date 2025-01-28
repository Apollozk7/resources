--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local avatarsCache = {}

function loadPlayerAvatar(avatar, errors, player, login)
    if errors == 0 then
        if(player and isElement(player))then
            setElementData(player, "user:avatarIMG", avatar)
            avatarsCache[login] = {responseData = avatar, expireData = getTickCount() + (60000 * 5)};
        end
    end
end

function getAvatar(login, client, data)
    local isCached = avatarsCache[login]

    if(isCached)then
        if(isCached.expireData < getTickCount()) then
            fetchRemote(data, loadPlayerAvatar, "", false, client, login)
        else
            setElementData(client, "user:avatarIMG", isCached.responseData)
        end
    else
        fetchRemote(data, loadPlayerAvatar, "", false, client, login)
    end
end

for i,v in pairs(getElementsByType("player")) do
    setTimer(function()
        getAvatar(getPlayerName(v),v)
    end, 100 * i, 1)
end