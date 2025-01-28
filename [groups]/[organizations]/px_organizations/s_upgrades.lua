--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local s={}

s.tasks={
    ["+10% expa w pracach"]={desc="+10% punktów expa dla graczy.", icon="job", cost=1000000},
    ["+10% zarobków w pracach"]={desc="+10% pieniędzy w pracach dla graczy.", icon="job", cost=1000000},

    ["20 slotów na pojazdy"]={desc="Maksymalnie 20 przepisanych pojazdów.", icon="vehs", cost=50000},
    ["50 slotów na pojazdy"]={desc="Maksymalnie 50 przepisanych pojazdów.", icon="vehs", cost=200000},
    ["Bez limitowe sloty na pojazdy"]={desc="Bez limitowe sloty na przepisane pojazdy.", icon="vehs", cost=750000},

    ["20 slotów na graczy"]={desc="Maksymalnie 20 graczy w organizacji.", icon="users", cost=50000},
    ["50 slotów na graczy"]={desc="Maksymalnie 50 graczy w organizacji.", icon="users", cost=200000},
    ["Bez limitowe sloty na graczy"]={desc="Bez limitowe sloty na graczy w organizacji.", icon="users", cost=750000},
}

s.isOrganizationHaveUpgrade=function(org, name)
    local q=exports.px_connect:query("select upgrades from groups_organizations where org=? limit 1", org)
    if(q and #q == 1)then
        local upgrades=fromJSON(q[1].upgrades) or {}
        return upgrades[name]
    end
    return false
end

s.getOrganizationUpgrades=function(org)
    local upgrades={}
    local q=exports.px_connect:query("select upgrades from groups_organizations where org=? limit 1", org)
    if(q and #q == 1)then
        local q_upgrades=fromJSON(q[1].upgrades) or {}
        local k=0
        for i,v in pairs(s.tasks) do
            k=k+1

            upgrades[k]={desc=v.desc,icon=v.icon,cost=v.cost,have=q_upgrades[i],name=i}
        end
    end
    return upgrades
end

s.addOrganizationUpgrade=function(org, name)
    local q=exports.px_connect:query("select upgrades,money from groups_organizations where org=? limit 1", org)
    if(q and #q == 1)then
        local q_upgrades=fromJSON(q[1].upgrades) or {}
        if(not q_upgrades[name])then
            local t=s.tasks[name]
            if(t)then
                if(q[1].money >= t.money)then
                    q_upgrades[name]=true
                    exports.px_connect:query("update groups_organizations set upgrades=?, money=money-? where org=? limit 1", toJSON(q_upgrades), t.money, org)
                    return true
                end
            end
        end
    end
    return false
end

-- exports

function addOrganizationUpgrade(...) return s.addOrganizationUpgrade(...) end
function isOrganizationHaveUpgrade(...) return s.isOrganizationHaveUpgrade(...) end
function getOrganizationUpgrades(...) return s.getOrganizationUpgrades(...) end