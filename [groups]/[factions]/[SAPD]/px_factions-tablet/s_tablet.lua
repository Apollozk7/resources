--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local maxMandates=5 -- i moze tylko wolno jezdzic fura!

function giveMandate(player, reason, cost)
    if(isElement(player))then
        local uid=getElementData(player, "user:uid")
        if(not uid)then return end

        local q=exports.px_connect:query('insert into accounts_mandates (uid,money,name,date) values(?,?,?,now())', uid, cost, reason)
        if(q)then
            local r=exports.px_connect:query('select * from accounts_mandates where uid=?', uid)
            if(r and #r > 0)then
                local stars=getPlayerMandates(player,r)
                if(math.floor(stars) == maxMandates and not exports.px_achievements:isPlayerHaveAchievement(player, "Bandzior"))then
                    exports.px_achievements:getAchievement(player, "Bandzior")
                end

                local org=getElementData(player, "user:organization")
                if(org)then
                    exports.px_organizations:updateOrganizationTask(org, "addFromMandate", 1)
                end
            end
            return true
        end
    else
        local q=exports.px_connect:query('insert into accounts_mandates (uid,money,name,date) values(?,?,?,?,now())', player.id, cost, reason)
        return q
    end
    return false
end

function getPlayerMandates(player, mandates)
    if(isElement(player) and mandates)then
        local max=5000
        local mandat=0
        for i,v in pairs(mandates) do
            mandat=mandat+v.money
        end

        local stars=5*(mandat/max)
        setElementData(player, "user:maxMandates", {
            stars=stars,
            maxStars=maxMandates
        })

        return stars,maxMandates
    end
end

-- triggers

addEvent("load.tablet.date", true)
addEventHandler("load.tablet.date", resourceRoot, function()
    local tickets=exports.px_connect:query("select * from groups_fractions_tickets where faction=?", "SAPD")

    local wanted=exports.px_connect:query("select login,wanted,skin,police_stars from accounts where LENGTH(wanted)>0 order by rand() limit 1")
        
    local units={}
    for i,v in pairs(getElementsByType("vehicle")) do
        if(getElementData(v, "vehicle:group_owner") == "SAPD" and getVehicleController(v))then
            units[#units+1]="LV "..getElementData(v, "vehicle:group_id")
        end
    end

    local pos={getElementPosition(client)}
    local range_vehs=getElementsWithinRange(pos[1], pos[2], pos[3], 10, "vehicle")
    local range_players=getElementsWithinRange(pos[1], pos[2], pos[3], 10, "player")

    triggerClientEvent(client, "load.tablet.date", resourceRoot, 
    {
        tickets=tickets,
        wanted=wanted[1],
        units=units,
        range_vehs=range_vehs,
        range_players=range_players
    })
end)

addEvent("get.vehicle", true)
addEventHandler("get.vehicle", resourceRoot, function(id)
    local q=exports.px_connect:query("select * from vehicles where id=? limit 1", id)
    if(q and #q > 0)then
        triggerClientEvent(client, "get.vehicle", resourceRoot, q[1])
    end
end)

addEvent("get.player", true)
addEventHandler("get.player", resourceRoot, function(login)
    local q=exports.px_connect:query("select * from accounts where login=? limit 1", login)
    local q_vehs=exports.px_connect:query("select * from vehicles where ownerName=?", login)
    local q_punish=exports.px_connect:query("select * from misc_punish where nick=? and active=1", login)
    if(q and #q > 0)then
        triggerClientEvent(client, "get.player", resourceRoot, q[1], q_vehs, q_punish)
    end
end)

addEvent("delete.ticket", true)
addEventHandler("delete.ticket", resourceRoot, function(id)
    exports.px_connect:query("delete from groups_fractions_tickets where id=? and faction=?", id, "SAPD")
end)

addEvent("take.mandate", true)
addEventHandler("take.mandate", resourceRoot, function(player, reason, cost)
    if(not isElement(player) and player.login)then
        player=getPlayerFromName(player.login) or player.login
    end
    
    local mandate=giveMandate(player, reason, cost)
    if(mandate)then
        exports.px_noti:noti("Pomyślnie wystawiono mandat dla "..(isElement(player) and getPlayerName(player) or player.login)..", z powodu: "..reason..", za: $"..cost, client, "success")
        if(isElement(player))then
            exports.px_noti:noti("Otrzymałeś mandat od "..getPlayerName(client)..", z powodu: "..reason..", za: $"..cost, player, "info")
        end
    end
end)

addEvent("set.wanted", true)
addEventHandler("set.wanted", resourceRoot, function(uid, reason, location)
    local wanted={}
    if(reason and location)then
        wanted={
            location=location,
            reason=reason
        }
    end

    local q=exports.px_connect:query("update accounts set wanted=? where id=?", toJSON(wanted), uid)
    if(q)then
        exports.px_noti:noti("Pomyślnie nadano/zdjęto status poszukiwanego.", client, "success")
    end
end)

addEvent("set.notebook", true)
addEventHandler("set.notebook", resourceRoot, function(uid, text)
    local q=exports.px_connect:query("update accounts set sapd_notebook=? where id=?", text, uid)
    if(q)then
        exports.px_noti:noti("Pomyślnie zaaktulizowano notatki.", client, "success")
    end
end)

-- useful

function showtime()
	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minute
	local seconds = time.second

    local monthday = time.monthday
	local month = time.month
	local year = time.year

    local formattedTime = string.format("%04d-%02d-%02d %02d:%02d", year+1900, month + 1, monthday, hours, minutes)
	return formattedTime
end