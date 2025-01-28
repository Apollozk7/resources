--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local timed={}
local timed_sms={}

-- reports

addCommandHandler("taxi", function(player)
    exports.px_noti:noti("Aby wezwać taxi, uruchom telefon (F2) i przejdź w Służby.", player, "info")
end)

addEventHandler("onPlayerChat", root, function(text,msgType)
    if(msgType ~= 0)then return end

    local faction=getElementData(source, "phoneData")
    if(not faction)then return end

    if(#text < 1 or #faction < 1)then return end

    exports.px_noti:noti("Pomyślnie wysłano zgłoszenie do: "..faction, source, "success")

    if(faction ~= "SAPD")then
        if(getElementData(source, "faction_report->active")) then
            exports.px_noti:noti("Masz już aktywne zgłoszenie!", source, "error")
            setElementData(source, "phoneData", false)
            return
        end
        
        exports.px_faction_calls:addNewReport(source, faction, text)
    end

    local pos={getElementPosition(source)}
    local zone=getZoneName(pos[1],pos[2],pos[3],false)..", "..getZoneName(pos[1],pos[2],pos[3],true)
    for i,v in pairs(getElementsByType("player")) do
        if(getElementData(v,"user:faction") == "SACC" and faction == "SACC")then
            outputChatBox("Wezwanie od "..getPlayerName(source).." na ulicy: "..zone, v, 255, 255, 0)
        elseif(getElementData(v,"user:faction") == "SARA" and faction == "SARA")then
            outputChatBox("Wezwanie od "..getPlayerName(source).." na ulicy: "..zone, v, 255, 255, 0)
        elseif(getElementData(v,"user:faction") == "SAPD" and faction == "SAPD")then
            outputChatBox("Wezwanie od "..getPlayerName(source).." na ulicy: "..zone, v, 0, 0, 255)
        elseif(getElementData(v,"user:faction") == "PSP" and faction == "PSP")then
            outputChatBox("Wezwanie od "..getPlayerName(source).." na ulicy: "..zone, v, 255,0,0)
        end
    end

    if(faction == "SAPD")then
        local pos={getElementPosition(source)}
        local zone=getZoneName(pos[1],pos[2],pos[3],false)..", "..getZoneName(pos[1],pos[2],pos[3],true)
        exports.px_connect:query("insert into groups_fractions_tickets (location,text,date,faction,pos,`from`) values(?,?,now(),?,?,?)", zone, text, faction, toJSON(pos), getPlayerName(source))
    end

    setElementData(source, "phoneData", false)
end)

-- friends

addEvent("get.friends", true)
addEventHandler("get.friends", resourceRoot, function()
    if(timed[client])then 
        if((getTickCount()-timed[client]) < 3000)then return end
    end

    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local q=exports.px_connect:query('select accounts.id,accounts.login,accounts_friends.* from accounts_friends left join accounts on (accounts_friends.uid=accounts.id or accounts_friends.uid_target=accounts.id) where (accounts_friends.uid=? or accounts_friends.uid_target=?) and accept is not null', uid, uid)
    if(q and #q > 0)then
        triggerClientEvent(client, "load.friends", resourceRoot, q)
    end

    timed[client]=getTickCount()
end)

-- sms

addEvent("get.sms", true)
addEventHandler("get.sms", resourceRoot, function()
    if(timed_sms[client])then 
        if((getTickCount()-timed_sms[client]) < 60000)then return end
    end

    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local q=exports.px_connect:query('select * from accounts_sms where uid=?', uid)
    if(q and #q > 0)then
        triggerClientEvent(client, "load.sms", resourceRoot, q)
    end

    timed_sms[client]=getTickCount()
end)

function sendSMS(uid, desc, text, from)
    local q=exports.px_connect:query('insert into accounts_sms (uid,text,`from`,date,`desc`) values(?,?,?,now(),?)', uid, text, from, desc)
    return q
end

-- call

addEvent("get.call", true)
addEventHandler("get.call", resourceRoot, function(player)
    local target=client
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local q=exports.px_connect:query("select login from accounts where id=? limit 1", uid)
    if(q and #q == 1)then
        if(not isPedInVehicle(player))then
            triggerClientEvent(player, "get.call", resourceRoot, target, q[1])
        else
            exports['px_noti']:noti('Twój znajomy nie może obecnie rozmawiać, ponieważ prowadzi.', client, 'error')
        end
    end
end)

addEvent("cancel.call", true)
addEventHandler("cancel.call", resourceRoot, function(player, sound)
    if(player and isElement(player))then
        triggerClientEvent(player, "cancel.call", resourceRoot, client, sound)
    end

    setPlayerVoiceBroadcastTo(player, root)
    setPlayerVoiceBroadcastTo(client, root)
    
    removeElementData(player, "voice:to")
    removeElementData(client, "voice:to")

    setPedAnimation(player, "ped", "phone_out", 1000, false, true, false)
    setPedAnimation(client, "ped", "phone_out", 1000, false, true, false)
end)

addEvent("accept.call", true)
addEventHandler("accept.call", resourceRoot, function(player)
    if(player and isElement(player))then
        triggerClientEvent(player, "accept.call", resourceRoot, client)

        setPlayerVoiceBroadcastTo(player, client)
        setPlayerVoiceBroadcastTo(client, player)
        setElementData(player, "voice:to", client)
        setElementData(client, "voice:to", player)

        setPedAnimation(client, "ped", "phone_in", 1000, false, true, false)
        setPedAnimation(player, "ped", "phone_in", 1000, false, true, false)
    end
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for i,v in pairs(getElementsByType("player")) do
        if(getElementData(v, "voice:to"))then
            removeElementData(v, "voice:to")
            setPlayerVoiceBroadcastTo(v, root)
        end
    end
end)