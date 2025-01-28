--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

url="https://pixelmta.pl/uploads/"

ips={}

ips.createClub=function(player, name, about)

end

ips.getClubLogo=function(player, name, script)

end

--[[local r=exports.px_connect:query_forum('select * from core_clubs')
for i,v in pairs(r) do
    local players=exports.px_connect:query_forum('select * from core_clubs_memberships where club_id=?', v.id)
    if(players)then
        exports.px_connect:query_forum('update core_clubs set members=? where id=? limit 1', #players, v.id)
    end
end]]

--[[ips.resultClub=function(player)
    if(tonumber(player))then
        uid=player
    else
        uid=getElementData(player, "user:uid")
    end

    if(not uid)then return end

    local r=exports.px_connect:query("select forum_id,login from accounts where id=? limit 1", uid) -- tylko jezeli ma konto na forum
    if(r and #r == 1 and r[1].forum_id ~= 0)then
        local q=exports.px_connect:query_forum("select club_id from core_clubs_memberships where member_id=?", r[1].forum_id)

        -- jezeli jest w innym klubie niz w organizacji
        local org=exports.px_connect:query('select * from groups_organizations_players where uid=? limit 1', uid)
        if(org and #org == 1)then
            local org_2=exports.px_connect:query('select forum_id from groups_organizations where org=? limit 1', org[1].org)

            if(org_2 and #org_2 == 1)then
                -- jak jest wiecej niz w 1 = wypierdol
                if(q and #q > 1)then
                    for i,v in pairs(q) do
                        if(v.club_id ~= org_2[1].forum_id)then
                            iprint(r[1].login,1)
                            exports.px_connect:query_forum('delete from core_clubs_memberships where member_id=? and club_id=? limit 1', r[1].forum_id, v.club_id)
                        end
                    end
                end
                --
            end

            if(org_2 and #org_2 == 1 and q and #q == 1 and tonumber(q[1].club_id) ~= tonumber(org_2[1].forum_id))then
                iprint(r[1].login,2)
                exports.px_connect:query_forum('update core_clubs_memberships set club_id=?, joined=UNIX_TIMESTAMP(), status=?, added_by=null, invited_by=null where member_id=? limit 1', org_2[1].forum_id, 'member', r[1].forum_id)
            end
        end

        -- jezeli jest w klubie a nie jest w organizacji
        if(q and #q == 1 and org and #org == 0)then
            iprint(r[1].login,3)
            exports.px_connect:query_forum('delete from core_clubs_memberships where member_id=? limit 1', r[1].forum_id)
        end

        -- jezeli jest w organizacji ale nie ma go w klubie
        if(org and #org == 1 and q and #q == 0)then
            local org_2=exports.px_connect:query('select forum_id from groups_organizations where org=? limit 1', org[1].org)
            if(org_2 and #org_2 == 1)then
                iprint(r[1].login,4)
                exports.px_connect:query_forum("insert into core_clubs_memberships (club_id,member_id,joined,status,rules_acknowledged) values(?,?,UNIX_TIMESTAMP(),?,1)", org_2[1].forum_id, r[1].forum_id, "member")
            end
        end
    end
end

local q=exports.px_connect:query_forum('select member_id from core_clubs_memberships')
for i,v in pairs(q) do
    local r=exports.px_connect:query("select id from accounts where forum_id=? limit 1",  v.member_id) -- tylko jezeli ma konto na forum
    if(r and #r == 1)then
        ips.resultClub(r[1].id)
    end
end]]

ips.addPlayer=function(player, name, target)

end

ips.removePlayer=function(player, name)

end

ips.destroyClub=function(name)

end

function ipsCreateClub(...) return ips.createClub(...) end
function ipsAddPlayer(...) return ips.addPlayer(...) end
function ipsDestroyClub(...) return ips.destroyClub(...) end
function ipsRemovePlayer(...) return ips.removePlayer(...) end
function ipsGetClubLogo(...) return ips.getClubLogo(...) end