--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ranks=exports.px_admin:getRanks() or {}

local chat={
    ["user:premium"]={
        "$", -- tag
        "PREMIUM", -- identificator
        "#f1ee92", -- color
        players={}, -- players with premium
        chatWebhook = "https://discord.com/api/webhooks/1099118810113519698/v13i57OoWWnxT4lQXCft4iXajwmy-sd0jKyJjDSJu2ZEkt3VBhQMEEQ075huGn_8OUkh"
    },
    ["user:gold"]={
        "!",
        "GOLD",
        "#d5ad4a",
        players={},
        chatWebhook = "https://discord.com/api/webhooks/1099119567890034708/4dtpmi6G1yyxzrFZW_kpgmJKqfER6mL7i7EXw7sJ72gRrovrvDs_BcnNZ2SqT7Q_t2lI"
    },
}

-- add

function newGold(player)
    chat["user:gold"].players[player]=player
end

function newPremium(player)
    chat["user:premium"].players[player]=player
end

function removePlayer(player)
    for i,v in pairs(chat) do
        if(v.players[player])then
            v.players[player]=nil
            break
        end
    end
end

addEventHandler("onPlayerQuit", root, function()
    removePlayer(player)
end)

for i,v in pairs(getElementsByType("player")) do
    if(getElementData(v, "user:premium"))then
        newPremium(v)
    end

    if(getElementData(v, "user:gold"))then
        newGold(v)
    end

    if(getElementData(v, "user:admin"))then
        newPremium(v)
        newGold(v)
    end
end

function discordEscape(text)
    text = string.gsub(text, "@", "@​")
    text = string.gsub(text, "`", "\\​")
    text = string.gsub(text, "*", "\\​")
    text = string.gsub(text, "_", "\\​")
    text = string.gsub(text, "~", "\\​")
    text = string.gsub(text, ">", "\\​")
    return text
end

-- chat premium

addEventHandler("onPlayerChat", root, function(text)
    if(getElementData(source, "user:mute") or #text < 2)then return end    
    local player=source
	local sub=string.sub(text, 1, 1)
	local text=string.sub(text, 2, #text)

    text=exports.px_core:stripColors(text)
    text=stripSpaces(text)

    if(#text < 1)then return end

    local rank=getElementData(player, "user:admin")
    local add=""
    if(rank and ranks[rank])then
        add = rank and ranks[rank].hex or ""
    end

    for data,tag in pairs(chat) do
        if(sub == tag[1] and #text > 1 and tag.players[source])then
            local sendOptions = {
                formFields = {
                    username = data == "user:premium" and "Chat premium" or "Chat gold",
                    content = "[ID: "..getElementData(player, "user:id").."] **"..discordEscape(getPlayerName(player)).."**: "..discordEscape(text),
                    avatar_url = "https://cdn.discordapp.com/icons/1029811558160805929/ab163c84fbdc51bab56f801ec3d44dd1.webp"
                },
                method = "POST",
            }
            fetchRemote(tag.chatWebhook, sendOptions, function() end)

            if(not exports.px_dashboard:getSettingState(source, tag[2].."_chat_off"))then
                for i,v in pairs(tag.players) do
                    if(v and isElement(v))then
                        if(not exports.px_dashboard:getSettingState(v, tag[2].."_chat_off"))then
                            outputChatBox(tag[3].."["..tag[1].."] ["..getElementData(player, "user:id").."] "..add..getPlayerName(player).."#ffffff: "..text, v, 255, 255, 255, true)
                        end
                    else
                        tag.players[i] = nil
                    end
                end

                --exports.px_discord:sendDiscordLogs(text, "chatpremium", player)
            else
                exports.px_noti:noti('Najpierw włącz czat w ustawieniach!', player, 'error')
            end

            break
        end
    end
end)

-- money and xp for 1 hour

addEvent("premium:give", true)
addEventHandler("premium:give", resourceRoot, function(money, rpx)
    givePlayerMoney(client, money)

    local rp=getElementData(client, 'user:reputation')
    setElementData(client, 'user:reputation', rp+rpx)
end)

-- give premium

local developers = {
    ["74AD615CFE02B293D95D63C9918358B3"] = true, -- psychol
}

addCommandHandler("daj.pp", function(player, _, target, points)
    if(developers[getPlayerSerial(player)])then
        if(target and points)then
            target = exports.px_core:findPlayer(target)
            if(target)then
                local uid=getElementData(target, "user:uid")
                if(uid)then
                    exports.px_connect:query("update accounts set premiumPoints=premiumPoints+? where id=? limit 1", points, uid)

                    exports.px_noti:noti("Otrzymałeś "..points.." PP od "..getPlayerName(player), target)
                    exports.px_noti:noti("Dałeś "..points.." PP dla "..getPlayerName(target)..".", player)
                end
            else
                exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
            end
        else
            exports.px_noti:noti("Poprawne użycie: /daj.pp <id/nick> <ilość pp>", player)
        end
    end
end)

-- give premium

function givePremium(player, days)
    setElementData(player, "user:premium", true)
    exports.px_connect:query("update accounts set premium=if(premium>now(), premium, now())+interval ? day where id=?", days, getElementData(player, "user:uid"))
    newPremium(player)
end

function giveGold(player, days)
    setElementData(player, "user:gold", true)
    exports.px_connect:query("update accounts set gold=if(gold>now(), gold, now())+interval ? day where id=?", days, getElementData(player, "user:uid"))
    newGold(player)
end

function stripSpaces(text)
	return utf8.gsub(text, " +", " ")
end