--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local s={}

s.tasks={
    ["Zaróbcie $100.000 na dowolnych pracach"]={fnc="addFromJob", icon="dollar", progress=0, maxProgress=100000, money=10000},
    ["Przegrajcie 50 godzin"]={fnc="addFromTime", icon="hours", progress=0, maxProgress=50, money=15000},
    ["Przewieź 30 naczep na pracy: Tiry"]={fnc="addFromJob_Truck", icon="job", progress=0, maxProgress=30, money=20000},
    ["Nabijcie łącznie 20 mandatów"]={fnc="addFromMandate", icon="mandate", progress=0, maxProgress=20, money=10000},
    ["Zatankujcie 500 litrów dowolnego paliwa"]={fnc="addFromFuelStation", icon="fuel", progress=0, maxProgress=500, money=10000},
    ["Przewieź 1000 paczek na pracy: Kurier"]={fnc="addFromJob_Courier", icon="job", progress=0, maxProgress=1000, money=15000},
}

s.getOrganizationTasks=function(org)
    local q=exports.px_connect:query("select task from groups_organizations where org=? limit 1", org)
    if(q and #q == 1)then
        return (fromJSON(q[1].task) or {}),s.tasks
    end
    return {},s.tasks
end

s.updateOrganizationTask=function(org, fnc, plus)
    local task=false
    for i,v in pairs(s.tasks) do
        if(v.fnc == fnc)then
            task=i
        end
    end
    if(not task)then return false end

    local t=s.tasks[task]
    if(t)then
        local q=exports.px_connect:query("select * from groups_organizations where org=? limit 1", org)
        if(q and #q == 1)then
            local tasks=fromJSON(q[1].task)
            if(tasks and tasks[task])then
                tasks[task].progress=tasks[task].progress+plus

                if(tasks[task].progress >= t.maxProgress)then
                    if(not tasks[task].done)then
                        tasks[task].done=true
                        exports.px_connect:query("update groups_organizations set task=?, money=money+? where org=? limit 1", toJSON(tasks), tasks[task].money, org)
                        return true
                    end
                else
                    if(tasks[task].progress < t.maxProgress and not tasks[task].done)then
                        exports.px_connect:query("update groups_organizations set task=? where org=? limit 1", toJSON(tasks), org)
                    end
                    return true
                end
            end
        end
    end
    return false
end

s.setOrganizationTasks=function(org)
    local q=exports.px_connect:query("select task from groups_organizations where org=? limit 1", org)
    if(q and #q == 1)then
        local tasks=fromJSON(q[1].task) or {}
        if(table.size(tasks) < 1)then
            local t=table.random(s.tasks)
            exports.px_connect:query("update groups_organizations set task=? where org=? limit 1", toJSON(t), org)
        end
    end

    local r=exports.px_connect:query("select * from groups_organizations where taskDate<curdate() and org=? limit 1", org)
    if(r and #r == 1)then
        local t=table.random(s.tasks)
        exports.px_connect:query("update groups_organizations set task=?, taskDate=curdate() where org=? limit 1", toJSON(t), org)
    end
end

-- exports

function updateOrganizationTask(...) return s.updateOrganizationTask(...) end
function getOrganizationTasks(...) return s.getOrganizationTasks(...) end
function setOrganizationTasks(...) return s.setOrganizationTasks(...) end

-- useful

function table.random(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end

    local rnd=math.random(1,length)
    local item={}
    local i=0
    for name,value in pairs(tab) do
        i=i+1

        if(i == rnd)then
            item[name]=value
            break
        end
    end

    return item
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

-- events

addEventHandler("onElementDataChange", root, function(data, old, new)
    if(data and source and isElement(source) and data == "user:online_time" and new)then
        if(new%60 == 0)then
            local org=getElementData(source, "user:organization")
            if(org)then
                updateOrganizationTask(org, "addFromTime", 1)
            end
        end
    end
end)