--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ADMIN={}

ADMIN.defaultRanks={
    {name="Lider",money=5000},
    {name="V-Lider",money=4000},
    {name="Nowy",money=3000},
}

ADMIN.setDefaultRanks=function()
    db=exports.px_connect

    local r=db:query("select * from groups_fractions")
    for i,v in pairs(r) do
        if(#v.ranks < 1)then
            db:query("update groups_fractions set ranks=? where id=?", toJSON(ADMIN.defaultRanks), v.id)
        end
    end
end
ADMIN.setDefaultRanks()

ADMIN.isPlayerInFaction=function(playerName)
    db=exports.px_connect

    local r=db:query("select * from groups_fractions_players where login=? limit 1", playerName)
    if(r and #r > 0)then
        return r[1].fraction
    end
    return false
end

ADMIN.isPlayerHaveAccess=function(playerName, accessName, fraction)
    db=exports.px_connect

    local r=db:query("select * from groups_fractions_players where login=? limit 1", playerName)
    if(fraction)then
        r=db:query("select * from groups_fractions_players where login=? and fraction=? limit 1", playerName, fraction)
    end
    
    if(r and #r > 0)then
        local access=fromJSON(r[1].access) or {}
        if(access[accessName])then
            return true
        end
        return false
    end
    return false
end

ADMIN.isPlayerHaveRole=function(playerName, roleName)
    db=exports.px_connect

    local r=db:query("select * from groups_fractions_players where login=? limit 1", playerName)
    if(r and #r > 0)then
        local roles=fromJSON(r[1].roles) or {}
        if(roles[roleName])then
            return true
        end
        return false
    end
    return false
end

ADMIN.getPlayerRank=function(playerName,tag)
    db=exports.px_connect

    local r=db:query("select * from groups_fractions_players where login=? and fraction=? limit 1", playerName, tag)
    if(r and #r > 0)then
        return r[1].rank
    end
    return false
end

ADMIN.getPayment=function(rankName,tag)
    db=exports.px_connect

    local payment=0
    local r=db:query("select * from groups_fractions where tag=?", tag)
    if(r and #r > 0)then
        local ranks=fromJSON(r[1].ranks) or {}
        for i,v in pairs(ranks) do
            if(v.name == rankName)then
                payment=v.money
                break
            end
        end
    end
    return payment
end

-- exports

function isPlayerInFaction(...) return ADMIN.isPlayerInFaction(...) end
function getPlayerRank(...) return ADMIN.getPlayerRank(...) end
function getPayment(...) return ADMIN.getPayment(...) end
function isPlayerHaveAccess(...) return ADMIN.isPlayerHaveAccess(...) end
function isPlayerHaveRole(...) return ADMIN.isPlayerHaveRole(...) end