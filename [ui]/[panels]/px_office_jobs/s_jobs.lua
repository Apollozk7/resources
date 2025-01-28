--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- create

local markers={
    {929.3926,1734.3292,8.8516,"LV"},
}

for i,v in pairs(markers) do
    local marker=createMarker(v[1], v[2], v[3]-1, "cylinder", 1.5, 255, 0, 255)
    setElementData(marker, "icon", ":px_office_jobs/textures/govMarker.png")
    setElementData(marker, "text", {text="Prace urzędowe",desc="Tutaj zatrudnisz się w pracach urzędowych"})
    setElementData(marker, "city", v[4], false)
end

-- functions

function updateJobs()
    local q=exports.px_connect:query("select * from office_jobs_users where date<now()-interval 24 hour")
    if(q and #q > 0)then
        for i,v in pairs(q) do
            exports.px_connect:query("delete from office_jobs_users where name=? and job=?", v.name, v.job)
        end
    end
end
setTimer(updateJobs, 3600000, 0)

function loadInfo(player, types, city)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return end

    local q=exports.px_connect:query("select * from office_jobs where name like ?", "%"..city.."%")
    for i,v in pairs(q) do
        v.users=exports.px_connect:query("select * from office_jobs_users where job=?", v.name)
    end
    
    if(q and #q > 0)then
        if(types)then
            triggerClientEvent(player, "refresh.ui", resourceRoot, q)
        else
            triggerClientEvent(player, "open.ui", resourceRoot, q, city)
        end
    end
end

-- events

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local city=getElementData(source, "city")
        if(not city)then return end

        updateJobs()
        loadInfo(hit,false,city)
    end
end)

addEvent("get.job", true)
addEventHandler("get.job", resourceRoot, function(name,city)
    local q=exports.px_connect:query("select * from office_jobs where name=? limit 1", name)
    if(q and #q > 0)then
        local exist=exports.px_connect:query("select * from office_jobs_users where name=? limit 1", getPlayerName(client))
        if(exist and #exist > 0)then
            if(exist[1].job ~= name)then
                exports.px_noti:noti("Możesz zatrudnić się w jednej pracy.", client, "error")
            else
                exports.px_noti:noti("Pomyślnie zwolniłeś się z pracy.", client, "success")
                exports.px_connect:query("delete from office_jobs_users where name=? and job=? limit 1", getPlayerName(client), name)
                loadInfo(client, true, city)
            end
        else
            local r=exports.px_connect:query("select * from office_jobs_users where job=?", name)
            if(#r < q[1].places)then
                exports.px_connect:query("insert into office_jobs_users (name,job,date) values(?,?,now())", getPlayerName(client), name)
                exports.px_noti:noti("Pomyślnie zatrudniłeś się w pracy urzędowej jako "..name, client, "success")
                loadInfo(client, true, city)
            else
                exports.px_noti:noti("W tej pracy nie ma wolnych miejsc.", client, "error") 
            end
        end
    end
end)