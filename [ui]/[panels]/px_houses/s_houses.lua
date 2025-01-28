--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

loadstring(exports.px_connect:dbGetClass())()

ui={}

ui.positions={
    [1]={
        exitPos={-7.4198,1531.5023,-91.4141},
        enterTeleport={-6.3983,1531.6974,-91.4141},
        intPos={-1.8877,1530.2102,-92.4766},

        id=3902,
        garage=3919,
    },

    [2]={
        exitPos={-1.0215,1531.7366,-91.4532},
        enterTeleport={0.3873,1530.3687,-91.4532},
        intPos={-1.8877,1530.2102,-92.4766},

        id=3907,
        garage=3906,
    },
}

-- load

ui.houses={}

-- rents

ui.getRentsFromHouse=function(house_id)
    local q=exports.px_connect:query("SELECT houses_rents.*, accounts.login, accounts.lastlogin FROM houses_rents LEFT JOIN accounts ON (accounts.id = houses_rents.uid) WHERE house_id=?", house_id)
    for i,v in pairs(q) do
        if(v.lastlogin)then
            v.lastlogin=string.sub(q[1].lastlogin, 0, #q[1].lastlogin-9)
        end
    end
    return q
end

ui.isPlayerInRents=function(player, house_id)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return false end

    local q=exports.px_connect:query("select * from houses_rents where uid=? and house_id=? limit 1", uid, house_id)
    return #q > 0 and "rent" or false
end

ui.addPlayerToRents=function(uid, login, house_id, maxRents)
    if(#ui.getRentsFromHouse(house_id) < maxRents)then
        local s=exports.px_connect:query("select * from houses_rents where uid=? and house_id=? limit 1", uid, house_id)
        if(not s or (s and #s < 1))then
            local q=exports.px_connect:query("insert into houses_rents (uid,house_id,rentDate) values(?,?,now()+interval 1 day)", uid, house_id)
            if(q)then
                ui.reloadHouse(house_id)
                return q
            end
        end
    end
    return false
end

ui.removePlayerFromRents=function(uid, house_id)
    local q=exports.px_connect:query("delete from houses_rents where uid=? and house_id=?", uid, house_id)
    if(q)then
        ui.reloadHouse(house_id)
        return q
    end
    return false
end

ui.loadHouse=function(id)
    local v=id
    if(tonumber(id))then
        v=exports.px_connect:query("SELECT houses.*, accounts.login as ownerName, accounts2.login as lastOwnerName FROM houses LEFT JOIN accounts ON (accounts.id = houses.owner) LEFT JOIN accounts AS accounts2 ON (accounts2.id = houses.lastOwner) where houses.id=? limit 1", id)
        if(v and #v == 1)then
            v=v[1]
        else
            return
        end
    else
        id=v.id
    end

    if(v)then
        v.rents=ui.getRentsFromHouse(id)

        local garage=#exports.px_connect:query("select * from houses_garages where house_id=?", v.id) > 0 and true or false

        local color=v.owner and {255,50,30} or {0,255,132}

        local enterPos=split(v.position, ", ")
        local positions = ui.positions[v.level]
        local exitPos={-7.4198,1531.5023,-91.4141}
        if(enterPos and exitPos)then
            ui.houses[v.id]={
                enterMarker=createMarker(enterPos[1], enterPos[2], enterPos[3]-1, "cylinder", 1.1, unpack(color)),
                exitMarker=createMarker(exitPos[1], exitPos[2], exitPos[3], "cylinder", 1.1, 255, 0, 0),
                houseElement=createElement("house"),
                dim=v.id+999,
                data=v,
                garage=garage,
                level=v.level,
                id=v.id
            }

            v.garage=garage

            setElementPosition(ui.houses[v.id].houseElement, enterPos[1], enterPos[2], enterPos[3])
            setElementData(ui.houses[v.id].houseElement, "info", v)

            setElementData(ui.houses[v.id].enterMarker, "info", v)
            setElementData(ui.houses[v.id].enterMarker, "text", {text=v.type.." ["..id.."]",desc=v.owner and v.ownerName or "Do wynajęcia"})
            setElementData(ui.houses[v.id].enterMarker, "icon", ":px_houses/textures/houseMarker.png")
            setElementData(ui.houses[v.id].enterMarker, "settings", {
                ["offBackground"]=true,
                ["offPlace"]=true,
                ["mainColor"]=true,
                ["holderAvatar"]=v.owner ~= 0 and v.ownerName or false
            })

            setElementData(ui.houses[v.id].exitMarker, "icon", ":px_houses/textures/outMarker.png")
            setElementDimension(ui.houses[v.id].exitMarker, ui.houses[v.id].dim)
            setElementData(ui.houses[v.id].exitMarker, "pos", enterPos, false)

            setElementData(ui.houses[v.id].enterMarker,"pos:z",enterPos[3]-0.9)
        end
    end
end

ui.destroyHouse=function(id)
    local v=ui.houses[id]
    if(v)then
        for i,v in pairs(v) do
            if(v and isElement(v))then
                destroyElement(v)
            end
        end
        v=nil
    end
end

ui.reloadHouse=function(id)
    local h=ui.houses[id]
    if(h and h.enterMarker and isElement(h.enterMarker))then
        local v=exports.px_connect:query("SELECT houses.*, accounts.login as ownerName, accounts2.login as lastOwnerName FROM houses LEFT JOIN accounts ON (accounts.id = houses.owner) LEFT JOIN accounts AS accounts2 ON (accounts2.id = houses.lastOwner) where houses.id=? limit 1", id)
        if(v and #v == 1 and v[1])then
            v=v[1]

            local data=getElementData(h.enterMarker, "info")
            if(data and data.owner)then
                v.rents=ui.getRentsFromHouse(v.id)
            end

            v.garage=#exports.px_connect:query("select * from houses_garages where house_id=?", v.id) > 0 and true or false

            local color=v.owner and {255,50,30,0} or {0,255,132,0}
            local c={getMarkerColor(h.enterMarker)}
            if(c[1] ~= color[1] or c[2] ~= color[2] or c[3] ~= color[3])then
                setMarkerColor(h.enterMarker, unpack(color))
            end
            setElementData(h.enterMarker, "info", v)
            setElementData(h.enterMarker, "text", {text=v.type.." ["..id.."]",desc=v.owner and v.ownerName or "Do wynajęcia"})

            local players=getElementsWithinMarker(h.enterMarker)
            for _,player in pairs(players) do
                v.access=ui.getPlayerHouseAccess(v.id, player, "rent")
                triggerClientEvent(player, "refresh.house.info", resourceRoot, v)
            end

            local datas=getElementData(h.enterMarker, "settings")
            datas.holderAvatar=v.owner and v.ownerName or false
            setElementData(h.enterMarker, "settings", datas)

            data.castle=v.castle

            ui.houses[id].level=v.level
            ui.houses[id].data=data

            local pos={getElementPosition(h.enterMarker)}
            triggerClientEvent("reload.blip", resourceRoot, v.id, pos[1], pos[2], pos[3], v.owner)

            g.updateGarage(id)
        end
    end
end

ui.createHouse=function(positions, type, cost)
    if(positions and type)then
        local pos = {positions[1], positions[2], positions[3]}
        local q,_,id=exports.px_connect:query("insert into houses (type,position,cost) values(?,?,?)", type, table.concat(pos, ", "), cost)

        if(q)then
            ui.loadHouse(id)
            return true
        end
    end
    return false
end

ui.refresh=function()
	local q=exports.px_connect:query("select rentDate,id,owner,level,type,cost from houses where rentDate<NOW() AND owner IS NOT NULL")
	if(q and #q > 0)then
		for i,v in pairs(q) do
            if(v.type == "Baza organizacji")then
                local info=exports.px_connect:query("select * from groups_organizations where id=? limit 1", v.owner)
                if(info and #info > 0)then
                    if(tonumber(info[1].money) >= tonumber(v.cost))then
                        exports.px_connect:query("update groups_organizations set money=money-? where id=? limit 1", tonumber(v.cost), v.owner)
                        exports.px_connect:query("update houses set rentDate=rentDate+interval 1 day where id=?", v.id)
                    else
                        for _,k in pairs(exports.px_connect:query("select id,owner from vehicles where h_garage=?", v.id)) do
                            local parking_id=exports.px_connect:query("select * from vehicles_garages where playerID=?", k.owner)
                            exports.px_connect:query("update vehicles set position=NULL,parking=?,h_garage=0 where id=?", parking_id[1].id or 0, k.id)
                        end
            
                        exports.px_connect:query("update houses set owner=NULL,lastOwner=owner,level=1,castle=0,organization=0,rentDate=? where id=?", "", v.id)
                        ui.reloadHouse(v.id)
                    end
                end
            else
                for _,k in pairs(exports.px_connect:query("select id,owner from vehicles where h_garage=?", v.id)) do
                    local parking_id=exports.px_connect:query("select * from vehicles_garages where playerID=?", k.owner)
                    exports.px_connect:query("update vehicles set position=NULL,parking=?,h_garage=0 where id=?", parking_id[1].id or 0, k.id)
                end
    
                exports.px_connect:query("update houses set owner=NULL,lastOwner=owner,level=1,castle=0,organization=0,rentDate=? where id=?", "", v.id)
                ui.reloadHouse(v.id)
            end
		end
	end

    local q=exports.px_connect:query("select rentDate,id,house_id from houses_rents where rentDate<NOW()")
	if(q and #q > 0)then
		for i,v in pairs(q) do
			exports.px_connect:query("delete from houses_rents where id=?", v.id)
            ui.reloadHouse(v.house_id)
		end
	end
end
ui.refresh()
setTimer(ui.refresh, 3600000, 0)

ui.getPlayerHouseAccess=function(id, player, type)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return false end

    local r=exports.px_connect:query("select owner,type from houses where id=? limit 1", id)
    if(r and #r > 0 and r[1].type == "Baza organizacji")then
        --TODO
        local q=exports.px_connect:query("select * from groups_organizations_players where uid=? and org=? limit 1", uid, r[1].ownerName)
        if(q and #q > 0)then
            return "rent"
        end
    else
        if(type == "rent")then
            local q=exports.px_connect:query("select owner from houses where owner=? and id=? limit 1", uid, id)
            if(q[1] and #q == 1)then
                return "owner"
            else
                return ui.isPlayerInRents(player, id)
            end
        else
            local q=exports.px_connect:query("select owner from houses where owner=? and id=? limit 1", uid, id)
            return q[1] and "owner" or false
        end
    end

    return false
end

ui.interiors={}
ui.createInterior=function(dim, player, garage, exitMarker, id)
    local r=exports.px_connect:query('select level from houses where id=? limit 1', id)
    if(r and #r == 1)then
        local level=r[1].level or 1
        level=tonumber(level) or 1

        if(ui.interiors[dim])then 
            ui.interiors[dim].players=ui.interiors[dim].players+1
            return true 
        end

        ui.interiors[dim]={}
        
        local info=ui.positions[level]
        if(info)then
            ui.interiors[dim].obj=createObject(garage and info.garage or info.id, unpack(info.intPos))
            setElementDimension(ui.interiors[dim].obj, dim)
            setElementData(ui.interiors[dim].obj, "custom_name", info.garage or info.id)

            setElementPosition(exitMarker, unpack(info.exitPos))

            ui.interiors[dim].players=1

            if(garage)then
                g.loadVehicles(dim, level)
            end

            return ui.interiors[dim]
        end
    end
end

ui.destroyInterior=function(dim, veh)
    if(ui.interiors[dim])then
        ui.interiors[dim].players=ui.interiors[dim].players-1
        if(ui.interiors[dim].players < 1)then
            destroyElement(ui.interiors[dim].obj)
            ui.interiors[dim]=nil

            g.destroyVehicles(dim, veh)
            return true
        end
    end
    return false
end

-- triggers

addEvent("buy.house", true)
addEventHandler("buy.house", resourceRoot, function(days, v)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    if(days and v)then
        local q=exports.px_connect:query("select * from houses where id=? limit 1", v.id)
        if(q and #q == 1 and q[1] and not q[1].owner)then
            local cost=math.floor(days*q[1].cost)
            if(getPlayerMoney(client) >= cost)then
                takePlayerMoney(client, cost)

                exports.px_connect:query("update houses set owner=?,rentDate=(now()+interval ? day) where id=?", uid, days, v.id)

                ui.reloadHouse(v.id)

                exports.px_noti:noti("Pomyślnie zakupiłeś domek na "..days.." dni.", client, "success")

                exports.px_discord:sendDiscordLogs("[DOMKI] Kupiono domek "..v.id.." na "..days.." dni za "..cost.."$", "hajs", client)

                if(not exports.px_achievements:isPlayerHaveAchievement(client, "Własne 4 kąty"))then
                    exports.px_achievements:getAchievement(client, "Własne 4 kąty")
                end
            else
                exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
            end
        else
            exports.px_noti:noti("Wystąpił błąd z domkiem.", client, "error")
        end
    end
end)

addEvent("house.addRent", true)
addEventHandler("house.addRent", resourceRoot, function(target, id, maxRents)
    if(target and isElement(target) and ui.getPlayerHouseAccess(id, client))then
        local uid=getElementData(target, "user:uid")
        local myUID=getElementData(client, "user:uid")
        if(not uid)then return end
        
        if((uid == myUID))then 
            exports.px_noti:noti("Nie możesz dodać samego siebie jako lokatora.", client, "error")
            return 
        end

        ui.addPlayerToRents(uid, getPlayerName(target), id, maxRents)
    end
end)

addEvent("house.removeRent", true)
addEventHandler("house.removeRent", resourceRoot, function(info, id)
    if(info and ui.getPlayerHouseAccess(id, client))then
        ui.removePlayerFromRents(info.uid, id)
    end
end)

addEvent("house.setRentCost", true)
addEventHandler("house.setRentCost", resourceRoot, function(info, cost)
    if(ui.getPlayerHouseAccess(info.id, client) and info.cost and info.rents and type(info.rents) == "table")then
        local myCost=info.cost
        local rents=#info.rents
        rents=rents < 2 and 2 or rents

        local maxRentCost=math.floor(myCost/rents)

        cost=tonumber(cost)
        maxRentCost=tonumber(maxRentCost)
        cost=math.floor(cost)
        if(cost > 0 and cost < maxRentCost)then
            exports.px_discord:sendDiscordLogs("[DOMKI] Ustawiono dla "..info.id.." czynsz na "..cost.."$", "hajs", client)
            exports.px_connect:query("update houses set rentCost=? where id=? limit 1", cost, info.id)

            ui.reloadHouse(info.id)

            exports.px_noti:noti("Pomyślnie zmieniono cene wynajmu na $"..cost, client, "success")
        else
            exports.px_noti:noti("Wprowadź prawidłową cene od $0 do $"..maxRentCost, client, "error")
        end
    end
end)

addEvent("house.payForHouse", true)
addEventHandler("house.payForHouse", resourceRoot, function(v, days, access)
    local max_days=30
    if(v.access == "owner")then
        if(ui.getPlayerHouseAccess(v.id, client) and days)then
            local cost=math.floor(days*v.cost)
            if(getPlayerMoney(client) >= cost)then
                local q=exports.px_connect:query("select (now()+interval ? day)<(rentDate+interval ? day) as rentSuccess from houses where id=? limit 1", max_days+1, days, v.id)
                if(#q == 1 and q[1].rentSuccess == 0)then
                    takePlayerMoney(client, cost)

                    exports.px_connect:query("update houses set rentDate=(rentDate+interval ? day) where id=? limit 1", days, v.id)
        
                    ui.reloadHouse(v.id)

                    exports.px_noti:noti("Pomyślnie opłaciłeś domek na "..days.." dni.", client, "success")

                    exports.px_discord:sendDiscordLogs("[DOMKI] Opłacono domek "..v.id.." na "..days.." dni za "..cost.."$", "hajs", client)
                else
                    exports.px_noti:noti("Domek możesz opłacić na maksymalnie 30 dni.", client, "error")
                end
            else
                exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
            end
        end
    elseif(v.access == "rent")then
        if(ui.getPlayerHouseAccess(v.id, client, "rent") and days)then
            local cost=math.floor(days*v.rentCost)
            if(getPlayerMoney(client) >= cost)then
                local uid=getElementData(client, "user:uid")
                if(not uid)then return end

                local q=exports.px_connect:query("select (now()+interval ? day)<(rentDate+interval ? day) as rentSuccess from houses_rents where uid=? and house_id=? limit 1", max_days+1, days, uid, v.id)
                if(#q == 1 and q[1].rentSuccess == 0)then
                    takePlayerMoney(client, cost)

                    exports.px_connect:query("update houses_rents set rentDate=(rentDate+interval ? day) where uid=? and house_id limit 1", days, uid, v.id)
        
                    ui.reloadHouse(v.id)

                    exports.px_noti:noti("Pomyślnie opłaciłeś domek na "..days.." dni.", client, "success")

                    exports.px_discord:sendDiscordLogs("[DOMKI] Opłacono domek "..v.id.." na "..days.." dni za "..cost.."$", "hajs", client)
                else
                    exports.px_noti:noti("Domek możesz opłacić na maksymalnie 30 dni.", client, "error")
                end
            else
                exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
            end
        end
    end
end)

addEvent("house.setLevel", true)
addEventHandler("house.setLevel", resourceRoot, function(v, cost)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    if(ui.getPlayerHouseAccess(v.id, client) and uid)then
        if(v.level+1 <= 2)then
            if(getPlayerMoney(client) >= cost)then
                local vehs=exports.px_connect:query("select id,owner from vehicles where h_garage=?", v.id)
                if(vehs and #vehs > 0)then
                    exports.px_noti:noti("Najpierw wyprowadź pojazdy z garażu.", client, "error")
                else
                    takePlayerMoney(client, cost)
                    exports.px_noti:noti("Pomyślnie ulepszono dom na poziom "..(v.level+1)..".", client, "success")
                    exports.px_connect:query("update houses set level=level+1 where id=? limit 1", v.id)
                    ui.reloadHouse(v.id)
                end
            else
                exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
            end
        else
            exports.px_noti:noti("Twój dom posiada maksymalny poziom ulepszenia.", client, "error")
        end
    end
end)

addEvent("house.castle", true)
addEventHandler("house.castle", resourceRoot, function(v)
    if(ui.getPlayerHouseAccess(v.id, client, "rent"))then
        local q=exports.px_connect:query("select castle from houses where id=? limit 1", v.id)
        if(q and #q == 1)then
            exports.px_connect:query("update houses set castle=? where id=?", q[1].castle == 1 and 0 or 1, v.id)
            exports.px_noti:noti(q[1].castle == 1 and "Pomyślnie otworzono zamek." or "Pomyślnie zamknięto zamek.", client, "success")
            ui.reloadHouse(v.id)

            if(q[1].castle == 1)then
                triggerClientEvent(client, "playSound", resourceRoot, "sounds/door_close.wav")
            else
                triggerClientEvent(client, "playSound", resourceRoot, "sounds/door_open.wav")
            end
        end
    end
end)

addEvent("house.teleport", true)
addEventHandler("house.teleport", resourceRoot, function(v)
    local h=ui.houses[v.id]
    if(h)then
        local create=ui.createInterior(h.dim,client,h.garage,h.exitMarker,v.id)
        if(create)then
            setElementFrozen(client, true)
            exports.px_loading:createLoadingScreen(client, true, false, 5000)
            setTimer(function(client)
                local r=exports.px_connect:query('select level from houses where id=? limit 1', h.id)
                if(r and #r == 1)then
                    local info=ui.positions[r[1].level]
                    if(info)then
                        setElementPosition(client, unpack(info.enterTeleport))
                        setElementDimension(client, h.dim)
                        setElementFrozen(client, false)
                        setElementData(client, "in:house", h.dim, false)
                    end
                end
            end, 3000, 1, client)

            if(create ~= true)then
                g.loadVehicles(v.id)
            end
        end
    end
end)

addEvent("house.out", true)
addEventHandler("house.out", resourceRoot, function(v, type)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local h=ui.houses[v.id]
    if(h)then
        if(type == 1)then
            -- wyprowadzka
            if(ui.getPlayerHouseAccess(v.id, client, "rent") == "rent")then
                ui.removePlayerFromRents(uid, v.id)
                exports.px_noti:noti("Pomyślnie wyprowadziłeś się z domu.", client, "success")
            else
                exports.px_noti:noti("Ta funkcja jest dostępna tylko dla lokatorów.", client, "error")
            end
        elseif(type == 2)then
            -- sprzedaz
            if(ui.getPlayerHouseAccess(v.id, client) == "owner")then
                for _,k in pairs(exports.px_connect:query("select id,owner from vehicles where h_garage=?", v.id)) do
                    local parking_id=exports.px_connect:query("select * from vehicles_garages where playerID=?", k.owner)
                    exports.px_connect:query("update vehicles set position=NULL,parking=?,h_garage=0 where id=?", parking_id[1].id or 0, k.id)
                end

                exports.px_connect:query("update houses set owner=NULL,lastOwner=?,rentDate=?,level=1 where id=?", uid, "", v.id)

                exports.px_noti:noti("Pomyślnie sprzedałeś posiadłość.", client, "success")

                --usunięcie lokatorów
                exports.px_connect:query("delete from houses_rents where house_id=?", v.id)

                ui.reloadHouse(v.id)
            else
                exports.px_noti:noti("Ta funkcja jest dostępna tylko dla właściciela.", client, "error")
            end
        end
    end
end)

addEvent("house.setOrganization", true)
addEventHandler("house.setOrganization", resourceRoot, function(v, org)
    if(ui.getPlayerHouseAccess(v.id, client) == "owner")then
        local q=exports.px_connect:query("select organization from houses where id=? limit 1", v.id)
        if(q and #q == 1)then
            exports.px_connect:query("update houses set organization=? where id=?", org or 0, v.id)
            exports.px_noti:noti(org and "Pomyślnie przepisano domek na organizacje: "..org or "Pomyślnie wypisano domek z organizacji.", client, "success")
            ui.reloadHouse(v.id)
        end
    end
end)

-- events

ui.onLeave=function(hit, key, keyState, pos)
    setElementFrozen(hit, true)
    exports.px_loading:createLoadingScreen(hit, true, false, 5000)
    setTimer(function()
        local destroy=ui.destroyInterior(getElementDimension(hit))
        if(destroy)then
            g.destroyVehicles(getElementDimension(hit))
        end

        setElementPosition(hit, unpack(pos))
        setElementDimension(hit, 0)
        setElementFrozen(hit, false)
        
        removeElementData(hit, "in:house")
    end, 3000, 1)

    unbindKey(hit, "X", "down", ui.onLeave)
end

ui.onHit=function(hit, key, keyState, h)
    if(ui.createInterior(h.dim,hit,h.garage,h.exitMarker,h.id))then
        setElementFrozen(hit, true)
        exports.px_loading:createLoadingScreen(hit, true, false, 5000)
        setTimer(function(client)
            local r=exports.px_connect:query('select level from houses where id=? limit 1', h.id)
            if(r and #r == 1)then
                local info=ui.positions[r[1].level]
                if(info)then
                    local pos=info.enterTeleport
                    setElementPosition(client, unpack(pos))
                    setElementDimension(client, h.dim)
                    setElementFrozen(client, false)
                    setElementData(client, "in:house", h.dim, false)
                end
            end
        end, 3000, 1, hit)
    end

    unbindKey(hit, "X", "down", ui.onHit)
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim and not isPedInVehicle(hit))then
        local info=getElementData(source, "info")
        local pos=getElementData(source, "pos")
        if(info)then
            if(not info.owner)then
                triggerClientEvent(hit, "open.house.ui", resourceRoot, 1, info)
            else
                local access=ui.getPlayerHouseAccess(info.id, hit, "rent")
                if(access)then
                    triggerClientEvent(hit, "open.house.ui", resourceRoot, 2, info, access)
                else
                    if(info.castle == 0)then
                        local h=ui.houses[info.id]
                        if(h)then
                            bindKey(hit, "X", "down", ui.onHit, h)
                            exports.px_noti:noti("Kliknij klawisz 'X' aby wejść do domu.", hit, "info")
                        end
                    else
                        exports.px_noti:noti("Drzwi do domu są zamknięte.", hit, "error")
                    end
                end
            end
        elseif(pos)then
            bindKey(hit, "X", "down", ui.onLeave, pos)
            exports.px_noti:noti("Kliknij klawisz 'X' aby wyjść z domu.", hit, "info")
        end
    end
end)

addEventHandler("onMarkerLeave", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player")then
        triggerClientEvent(hit, "close.house.ui", resourceRoot)
        unbindKey(hit, "X", "down", ui.onLeave)
        unbindKey(hit, "X", "down", ui.onHit)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    local data=getElementData(source, "in:house")
    if(data)then
        ui.destroyInterior(data)
    end
end)

-- on start

ui.loadAllHouses = function()
    local start_tick = getTickCount()

    DBQuery:new({"SELECT houses.*, accounts.login as ownerName, accounts2.login as lastOwnerName FROM houses LEFT JOIN accounts ON (accounts.id = houses.owner) LEFT JOIN accounts AS accounts2 ON (accounts2.id = houses.lastOwner)"}):execute(function(result)
        local i=0
        for _,v in pairs(result) do
            if math.random(0,100) <= 100 then
                i=i+1
        
                --[[if(i%20 == 0)then
                    setTimer(function() coroutine.resume(coroutine.load_houses) end, 250, 1)
                    coroutine.yield()
                end]]
        
                ui.loadHouse(v)
                g.loadGarage(v.id)

                if(i == #result) then
                    print("[px_houses] Loaded "..#result.." houses in "..(getTickCount() - start_tick).." ms.")
                    triggerClientEvent('reloadBlips', resourceRoot)
                end
            end
        end
    end)
end
ui.loadAllHouses()
--[[setTimer(function()
    coroutine.load_houses=coroutine.create(ui.loadAllHouses)
    coroutine.resume(coroutine.load_houses)
end, 500, 1)]]

-- commands

addCommandHandler("add.house", function(player, _, cost, ...)
    if(cost and ... and tonumber(cost) and getElementData(player, "user:admin") >= 4)then
        local name=table.concat({...}, " ")
        local pos={getElementPosition(player)}
        ui.createHouse(pos, name, cost)
    end
end)

-- convert

function formatMoney(money)
	while true do
		money, i = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1,%2")
		if i == 0 then
			break
		end
	end
	return money
end

-- useful

function getElementsWithinMarker(marker)
	if (not isElement(marker) or getElementType(marker) ~= "marker") then
		return false
	end
	local markerColShape = getElementColShape(marker)
	local elements = getElementsWithinColShape(markerColShape)
	return elements
end