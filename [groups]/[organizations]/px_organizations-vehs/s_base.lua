--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local G={}

G.points={
    {928.2292,1718.7819,8.8516},
}

for i,v in pairs(G.points) do
    marker=createMarker(v[1], v[2], v[3]-1, "cylinder", 1.1, 0, 255, 255)
    setElementData(marker, "icon", ":px_organizations-vehs/textures/marker_key.png")
    setElementData(marker, "text", {text="Przepisywanie pojazdów",desc="Na graczy i organizacje"})
end

function getVariables(hit, uid)
    local o=getElementData(hit, "user:organization")
    local f=exports.px_connect:query('select accounts.id,accounts.login,accounts_friends.* from accounts_friends left join accounts on (accounts_friends.uid=accounts.id or accounts_friends.uid_target=accounts.id) where (accounts_friends.uid=? or accounts_friends.uid_target=?) and accounts_friends.accept=1 and not accounts.id=?', uid, uid, uid)
    local v=exports.px_connect:query("select * from vehicles where owner=?", uid)
    for i,v in pairs(v) do
        local keys=exports.px_connect:query('select * from vehicles_share where vehID=?', v.id)
        v.keys=keys and keys or {}
    end
    return o,f,v
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local uid=getElementData(hit, "user:uid")
        if(not uid)then return end

        local o,f,v=getVariables(hit, uid)
        if(#v > 0)then
            if(f or o)then
                triggerClientEvent(hit, "open.interface", resourceRoot, o, f, v)
            else
                exports.px_noti:noti("Nie posiadasz znajomych ani organizacji.", hit, "error")
            end
        else
            exports.px_noti:noti("Nie posiadasz żadnych pojazdów.", hit, "error")
        end
    end
end)

function loadClubAvatarFromIPS(player, avatar)
    triggerClientEvent(player, "load.avatar", resourceRoot, avatar)
end

-- triggers

addEvent("set.organization", true)
addEventHandler("set.organization", resourceRoot, function(id, org)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query("select id from vehicles where owner=? and id=? limit 1", uid, id)
    if(r and #r == 1)then
        if(org)then
            local max=exports.px_organizations:isOrganizationHaveUpgrade(name, "Bez limitowe sloty na pojazdy") and 0 or exports.px_organizations:isOrganizationHaveUpgrade(name, "50 slotów na pojazdy") and 50 or exports.px_organizations:isOrganizationHaveUpgrade(org, "20 slotów na pojazdy") and 20 or 10
            local vehs=exports.px_connect:query("select id from vehicles where organization=?", name)
            if(max == 0 or (#vehs < max))then
                exports.px_connect:query("update vehicles set organization=? where id=? limit 1", org, id)
                exports.px_noti:noti("Pomyślnie przepisano pojazd na organizacje.", client, "success")

                local o,f,v=getVariables(client, uid)
                triggerClientEvent(client, "update.interface", resourceRoot, o, f, v)

                local veh=getElementByID("px_vehicles_id:"..id)
                if(veh and isElement(veh))then
                    setElementData(veh, "vehicle:organization", org)
                end
            else
                exports.px_noti:noti("Twoja organizacja posiada maksymalnie "..max.." slotów na pojazdy.", client, "error")
            end
        else
            exports.px_connect:query("update vehicles set organization=? where id=? limit 1", "", id)
            exports.px_noti:noti("Pomyślnie wypisano pojazd z organizacji.", client, "success")

            local o,f,v=getVariables(client, uid)
            triggerClientEvent(client, "update.interface", resourceRoot, o, f, v)

            local veh=getElementByID("px_vehicles_id:"..id)
            if(veh and isElement(veh))then
                setElementData(veh, "vehicle:organization", false)
            end
        end
    end
end)

addEvent("set.keys", true)
addEventHandler("set.keys", resourceRoot, function(id, type, target_uid, login)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query('select * from vehicles_share where vehID=? and uid=? limit 1', id, target_uid)
    if(r and #r > 0)then
        if(type == 'remove')then
            local q=exports.px_connect:query('delete from vehicles_share where vehID=? and uid=? limit 1', id, target_uid)
            if(q)then
                exports.px_noti:noti("Pomyślnie zabrano klucze graczu "..login..".", client, "success")
    
                local veh=getElementByID("px_vehicles_id:"..id)
                if(veh and isElement(veh))then
                    local r=exports.px_connect:query('select * from vehicles_share where vehID=?', id)
                    setElementData(veh, "vehicle:keys", r)
                end

                local o,f,v=getVariables(client, uid)
                triggerClientEvent(client, "update.interface", resourceRoot, o, f, v)
            end
        end
    else
        if(type == 'add')then
            local q=exports.px_connect:query('insert into vehicles_share (vehID,uid) values(?,?)', id, target_uid)
            if(q)then
                exports.px_noti:noti("Pomyślnie udostępniono klucze graczu "..login..".", client, "success")
    
                local veh=getElementByID("px_vehicles_id:"..id)
                if(veh and isElement(veh))then
                    local r=exports.px_connect:query('select * from vehicles_share where vehID=?', id)
                    setElementData(veh, "vehicle:keys", r)
                end

                local o,f,v=getVariables(client, uid)
                triggerClientEvent(client, "update.interface", resourceRoot, o, f, v)
            end
        end
    end
end)