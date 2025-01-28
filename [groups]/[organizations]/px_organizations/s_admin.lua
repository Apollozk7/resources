--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ADMIN={}

ADMIN.lvlUp=1000

ADMIN.defaultRanks={
    {name="Lider"},
    {name="V-Lider"},
    {name="Nowy"},
}

ADMIN.setDefaultRanks=function()
    db=exports.px_connect

    local r=db:query("select * from groups_organizations")
    for i,v in pairs(r) do
        if(#v.ranks < 1)then
            db:query("update groups_organizations set ranks=? where id=?", toJSON(ADMIN.defaultRanks), v.id)
        end
    end
end
ADMIN.setDefaultRanks()

ADMIN.isPlayerInOrganization=function(playerName)
    db=exports.px_connect

    local r=db:query("select org from groups_organizations_players where login=? limit 1", playerName)
    if(r and #r > 0)then
        return r[1].org
    end
    return false
end

ADMIN.getPlayerRank=function(playerName)
    db=exports.px_connect

    local r=db:query("select `rank` from groups_organizations_players where login=? limit 1", playerName)
    if(r and #r > 0)then
        return r[1].rank
    end
    return false
end

ADMIN.getPlayerRankID=function(playerName)
    db=exports.px_connect

    local r=db:query("select `rank`,org from groups_organizations_players where login=? limit 1", playerName)
    if(r and #r > 0)then
        local q=db:query("select ranks from groups_organizations where org=? limit 1", r[1].org)
        if(q and #q > 0)then
            local ranks=fromJSON(q[1].ranks) or {}
            local index=0
            for i,v in ipairs(ranks) do
                if(v.name == r[1].rank)then
                    index=i
                    break
                end
            end
            return index ~= 0 and index or false
        end
    end
    return false
end

ADMIN.lvlUpOrganization=function(org)
    local q=db:query("select * from groups_organizations where org=? limit 1", org)
    if(q and #q > 0)then
        local lvl=q[1].level
        local xp=q[1].exp
        if(xp >= (ADMIN.lvlUp*lvl))then
            db:query("update groups_organizations set level=level+1, exp=0 where org=? limit 1", org)
        end
    end
end

ADMIN.updateOrganizationLevel=function(player, money)
    if(player and isElement(player) and money and tonumber(money))then
        local tag=getElementData(player, "user:organization")
        local uid=getElementData(player, "user:uid")
        if(tag and uid)then
            local xp=money/40
            local saldo=math.percent(10,money)
            db:query("update groups_organizations set money=money+?, exp=exp+? where org=? limit 1", saldo, xp, tag)
            db:query("update groups_organizations_players set earn_money=earn_money+?, earn_exp=earn_exp+? where uid=? limit 1", saldo, xp, uid)
            ADMIN.lvlUpOrganization(tag)
        end
    end
end

ADMIN.getOrganizationMoney=function(org)
    if(org)then
        local r=db:query("select money from groups_organizations where org=? limit 1", org)
        if(r and #r > 0)then
            return r[1].money or 0
        else
            return 0
        end
    end
    return 0
end

ADMIN.giveOrganizationMoney=function(org, money)
    if(org)then
        db:query("update groups_organizations set money=money+? where org=? limit 1", money, org)
    end
end

ADMIN.takeOrganizationMoney=function(org, money)
    if(org)then
        db:query("update groups_organizations set money=money-? where org=? limit 1", money, org)
    end
end

-- exports

function isPlayerInOrganization(...) return ADMIN.isPlayerInOrganization(...) end
function getPlayerRank(...) return ADMIN.getPlayerRank(...) end
function getPlayerRankID(...) return ADMIN.getPlayerRankID(...) end
function updateOrganizationLevel(...) return ADMIN.updateOrganizationLevel(...) end
function getOrganizationLevelUP() return ADMIN.lvlUp end
function getOrganizationMoney(...) return ADMIN.getOrganizationMoney(...) end
function giveOrganizationMoney(...) return ADMIN.giveOrganizationMoney(...) end
function takeOrganizationMoney(...) return ADMIN.takeOrganizationMoney(...) end

-- useful

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end