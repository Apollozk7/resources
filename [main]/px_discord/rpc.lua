--[[

    author: psychol.
    for: Pixel REMAKE
    (c) 2024

]]

local app_id = "797475342222753802"

function ConnectRPC()
    local uid=getElementData(localPlayer, 'user:uid')
    if(not uid)then return end

    if(setDiscordApplicationID(app_id))then
        if(isDiscordRichPresenceConnected())then
            local name=getPlayerName(localPlayer)
            setDiscordRichPresenceAsset("botavatar", 'Pixel REMAKE!')
            setDiscordRichPresenceDetails(name..' (UID: '..uid..') (1 z '..#getElementsByType('player')..')')
            setDiscordRichPresenceState('discord.gg/mtapixel')
            setDiscordRichPresenceStartTime(1)
            setDiscordRichPresenceButton(1, "Dołącz do nas!", "https://discord.com/invite/mtapixel")
            setDiscordRichPresenceButton(2, "Wejdź na serwer!", "mtasa://146.59.4.27:20996")
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, ConnectRPC)

addEventHandler('onClientElementDataChange', localPlayer, function(data, old, new)
    if(data == 'user:uid' and not old)then
        ConnectRPC()
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    resetDiscordRichPresenceData()
end)