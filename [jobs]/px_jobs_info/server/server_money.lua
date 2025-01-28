--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function getMoney(money, data, player)
    client=player or client
    
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    exports.px_connect:query("update accounts set faction_money=faction_money+?, faction_time=faction_time+? where id=?", math.floor(money), data or 1, uid)

    local r=exports.px_connect:query("select week_time from groups_fractions_players where uid=? limit 1", uid)
    if(r and #r == 1)then
        exports.px_connect:query("update groups_fractions_players set week_time=week_time+? where uid=?", data or 1, uid)
    end

    local org=getElementData(client, "user:organization")
    if(org)then
        exports.px_organizations:updateOrganizationTask(org, "addFromJob", tonumber(money))
        exports.px_organizations:updateOrganizationLevel(client, money)
    end
end
addEvent("add.job.money", true)
addEventHandler("add.job.money", resourceRoot, getMoney)

addEvent("add.job.money_2", true)
addEventHandler("add.job.money_2", resourceRoot, function(money)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    givePlayerMoney(client, money)
    --exports.px_connect:query("update accounts set faction_money=faction_money+? where id=?", math.floor(money), uid)
end)

-- useful

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end