--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local markers={
    {2808.8203,1244.3159,10.8279},
    {928.2156,1713.6036,8.8516},
}

for i,v in pairs(markers) do
    local marker=createMarker(v[1], v[2], v[3]-0.9, "cylinder", 1.2, 50, 150, 200)
    setElementData(marker, "icon", ":px_stock_vehicles/textures/sell/carsellMarker.png")
    setElementData(marker, "text", {text="Wymiana pojazdów",desc="Tutaj wymienisz pojazdy"})
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local uid=getElementData(hit, "user:uid")
        if(not uid)then return end

        local q=exports.px_connect:query("select * from vehicles where owner=?", uid)
        if(q and #q > 0)then
            triggerClientEvent(hit, "exchange.open.ui", resourceRoot, 1)
        else
            exports.px_noti:noti("Nie posiadasz żadnych pojazdów.", hit)
        end
    end
end)

-- triggers

addEvent("exchange.send.offer", true)
addEventHandler("exchange.send.offer", resourceRoot, function(myInfo, playerInfo)
    if(getElementData(client, "exchange_vehs:offer") or getElementData(client, 'sell_vehs:offer'))then 
        exports.px_noti:noti(getPlayerName(playerInfo.element).." posiada aktualnie aktualną ofertę wymiany.", client, "error")
        return 
    end

    if(not myInfo or not playerInfo)then return end

    if(playerInfo.element and isElement(playerInfo.element))then
        if(getElementData(playerInfo.element, "exchange_vehs:offer") or getElementData(playerInfo.element, 'sell_vehs:offer'))then
            iprint('na nic !', getElementData(playerInfo.element, "exchange_vehs:offer"), getElementData(playerInfo.element, 'sell_vehs:offer'))
            return 
        end

        exports.px_noti:noti("Pomyślnie wysłano oferte wymiany pojazdu dla gracza "..getPlayerName(playerInfo.element), client, "success")

        triggerClientEvent(playerInfo.element, "get.exchange.info", resourceRoot, 3, myInfo, playerInfo)

        setElementData(client, "exchange_vehs:offer", true)
        setElementData(playerInfo.element, "exchange_vehs:offer", true)
    end
end)

addEvent('off.data', true)
addEventHandler('off.data', resourceRoot, function(player)
    setElementData(player, 'exchange_vehs:offer', false)
end)

addEvent("exchange.cancel.offer", true)
addEventHandler("exchange.cancel.offer", resourceRoot, function(player)
    setElementData(client, "exchange_vehs:offer", false)
    exports.px_noti:noti("Pomyślnie anulowano oferte wymiany.", client, "success")

    if(player and isElement(player))then
        setElementData(player, "exchange_vehs:offer", false)
        exports.px_noti:noti(getPlayerName(client).." anulował twoją oferte wymiany.", player, "error")
    end
end)

function getVehicleFromID(id)
    return getElementByID("px_vehicles_id:"..id)
end

function setVehicleGarage(id,owner)
    local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", owner)
    if(parking_id and #parking_id == 1)then
        exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=? limit 1", parking_id[1].id, id)
    else
        exports.px_connect:query("INSERT INTO vehicles_garages SET playerID=?", owner)

        local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", owner)
        if(parking_id and #parking_id == 1)then
            exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=? limit 1", parking_id[1].id, id)
        end
    end
end

addEvent("exchange.accept.offer", true)
addEventHandler("exchange.accept.offer", resourceRoot, function(myInfo, playerInfo)
    if(not getElementData(client, "exchange_vehs:offer"))then return end
    if(not myInfo or not playerInfo)then return end

    if(playerInfo.element and isElement(playerInfo.element))then
        setElementData(client, "exchange_vehs:offer", false)
        setElementData(playerInfo.element, "exchange_vehs:offer", false)

        myInfo.doplata=tonumber(myInfo.doplata) or false
        playerInfo.doplata=tonumber(playerInfo.doplata) or false
        if(myInfo.doplata and playerInfo.doplata and getPlayerMoney(client) >= myInfo.doplata and getPlayerMoney(playerInfo.element) >= playerInfo.doplata)then
            local myVeh=myInfo.vehs[myInfo.selected_veh]
            local playerVeh=playerInfo.vehs[playerInfo.selected_veh]
            if(myVeh and playerVeh)then
                local my_q=exports.px_connect:query("select * from vehicles where id=? and owner=? limit 1", myVeh.id, getElementData(client, "user:uid"))
                local player_q=exports.px_connect:query("select * from vehicles where id=? and owner=? limit 1", playerVeh.id, getElementData(playerInfo.element, "user:uid"))
                if(my_q and #my_q == 1 and player_q and #player_q == 1)then
                    my_q=my_q[1]
                    player_q=player_q[1]

                    if(myInfo.doplata > 0)then
                        takePlayerMoney(client, myInfo.doplata)
                        givePlayerMoney(playerInfo.element, myInfo.doplata)
                    end

                    if(playerInfo.doplata > 0)then
                        takePlayerMoney(playerInfo.element, playerInfo.doplata)
                        givePlayerMoney(client, playerInfo.doplata)
                    end

                    exports.px_connect:query("update vehicles set owner=?, ownerName=?, orgRank=0, organization=? where id=?", getElementData(playerInfo.element, "user:uid"), getPlayerName(playerInfo.element), "", my_q.id)
                    exports.px_connect:query("update vehicles set owner=?, ownerName=?, orgRank=0, organization=? where id=?", getElementData(client, "user:uid"), getPlayerName(client), "", player_q.id)

                    local mVeh=getVehicleFromID(my_q.id)
                    if(mVeh and isElement(mVeh))then
                        setElementData(mVeh, "vehicle:owner", getElementData(playerInfo.element, "user:uid"))
                        setElementData(mVeh, "vehicle:ownerName", getPlayerName(playerInfo.element))

                        if(getElementInterior(mVeh) ~= 0 or getElementDimension(mVeh) ~= 0)then
                            local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", getPlayerName(playerInfo.element))
                            if(parking_id and #parking_id == 1)then
                                exports.px_vehicles:saveVehicle(mVeh)
                                destroyElement(mVeh)
        
                                exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, my_q.id)
                            else
                                exports.px_connect:query("INSERT INTO vehicles_garages SET playerID=?", getPlayerName(playerInfo.element))
        
                                local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", getPlayerName(playerInfo.element))
                                if(parking_id and #parking_id == 1)then
                                    exports.px_vehicles:saveVehicle(mVeh)
                                    destroyElement(mVeh)
                
                                    exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, my_q.id)
                                end
                            end
                         end
                    else
                        if(tonumber(my_q.parking) ~= 0 or tonumber(my_q.h_garage) ~= 0)then
                            setVehicleGarage(my_q.id,getElementData(playerInfo.element, "user:uid"))
                        end
                    end

                    local pVeh=getVehicleFromID(player_q.id)
                    if(pVeh and isElement(pVeh))then
                        setElementData(pVeh, "vehicle:owner", getElementData(client, "user:uid"))
                        setElementData(pVeh, "vehicle:ownerName", getPlayerName(client))

                        if(getElementInterior(pVeh) ~= 0 or getElementDimension(pVeh) ~= 0)then
                           local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", getPlayerName(client))
                           if(parking_id and #parking_id == 1)then
                               exports.px_vehicles:saveVehicle(pVeh)
                               destroyElement(pVeh)
       
                               exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, player_q.id)
                           else
                               exports.px_connect:query("INSERT INTO vehicles_garages SET playerID=?", getPlayerName(client))
       
                               local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", getPlayerName(client))
                               if(parking_id and #parking_id == 1)then
                                   exports.px_vehicles:saveVehicle(pVeh)
                                   destroyElement(pVeh)
               
                                   exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, player_q.id)
                               end
                           end
                        end
                    else
                        if(tonumber(player_q.parking) ~= 0 or tonumber(player_q.h_garage) ~= 0)then
                            setVehicleGarage(player_q.id,getElementData(client, "user:uid"))
                        end
                    end

                    exports.px_noti:noti("Wymiana zakończona pomyślnie. ( Pojazd "..getVehicleNameFromModel(my_q.model).." ("..my_q.id..") za pojazd "..getVehicleNameFromModel(player_q.model).." ("..player_q.id.."), dopłata z twojej strony: "..myInfo.doplata.."$, dopłata od gracza: "..playerInfo.doplata.."$ )", client)
                    exports.px_noti:noti("Wymiana zakończona pomyślnie. ( Pojazd "..getVehicleNameFromModel(my_q.model).." ("..my_q.id..") za pojazd "..getVehicleNameFromModel(player_q.model).." ("..player_q.id.."), dopłata z twojej strony: "..playerInfo.doplata.."$, dopłata od gracza: "..myInfo.doplata.."$ )", playerInfo.element)
                
                    exports.px_discord:sendDiscordLogs("Pojazd "..getVehicleNameFromModel(my_q.model).." ("..my_q.id..") za pojazd "..getVehicleNameFromModel(player_q.model).." ("..player_q.id.."), dopłata z twojej strony: "..myInfo.doplata.."$, dopłata od gracza: "..playerInfo.doplata.."$", "wymiany", client)
                    exports.px_discord:sendDiscordLogs("Pojazd "..getVehicleNameFromModel(my_q.model).." ("..my_q.id..") za pojazd "..getVehicleNameFromModel(player_q.model).." ("..player_q.id.."), dopłata z twojej strony: "..playerInfo.doplata.."$, dopłata od gracza: "..myInfo.doplata.."$", "wymiany", playerInfo.element)
                    exports.px_discord:sendDiscordLogs("Pojazd "..getVehicleNameFromModel(my_q.model).." ("..my_q.id..") za pojazd "..getVehicleNameFromModel(player_q.model).." ("..player_q.id.."), dopłata z twojej strony: "..myInfo.doplata.."$, dopłata od gracza: "..playerInfo.doplata.."$", "hajs", client)
                    exports.px_discord:sendDiscordLogs("Pojazd "..getVehicleNameFromModel(my_q.model).." ("..my_q.id..") za pojazd "..getVehicleNameFromModel(player_q.model).." ("..player_q.id.."), dopłata z twojej strony: "..playerInfo.doplata.."$, dopłata od gracza: "..myInfo.doplata.."$", "hajs", playerInfo.element)
                else
                    exports.px_noti:noti("Wystąpił błąd przy wymianie: pojazd nie jest własnością.", client, "error")
                    exports.px_noti:noti("Wystąpił błąd przy wymianie: pojazd nie jest własnością.", playerInfo.element, "error")
                end
            end
        else
            exports.px_noti:noti("Wystąpił błąd przy wymianie: brak wystarczających funduszy.", client, "error")
            exports.px_noti:noti("Wystąpił błąd przy wymianie: brak wystarczających funduszy.", playerInfo.element, "error")
        end
    end
end)

addEvent("get.player.vehicles", true)
addEventHandler("get.player.vehicles", resourceRoot, function(id)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local vehs=exports.px_connect:query("select * from vehicles where owner=?", uid)
    if(vehs and #vehs > 0)then
        triggerClientEvent(client, "get.player.vehicles", resourceRoot, id, vehs)
    end
end)

addEvent("get.players.vehicles", true)
addEventHandler("get.players.vehicles", resourceRoot, function(players, id)
    local tbl={}
    local max=3

    for i=1,max do
        if(players[i] and isElement(players[i]) and players[i] ~= client)then
            local uid=getElementData(players[i], "user:uid")
            if(uid)then
                local vehs=exports.px_connect:query("select * from vehicles where owner=?", uid)
                tbl[#tbl+1]={
                    player=players[i],
                    vehs=vehs
                }
            end
        end
    end
    
    triggerClientEvent(client, "get.players.vehicles", resourceRoot, id, tbl)
end)

addEvent("get.exchange.info", true)
addEventHandler("get.exchange.info", resourceRoot, function(id, target)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    -- my info
    local myInfo={
        doplata=0,
        element=client,
        selected_veh=0,
        vehs={}
    }

    local vehs=exports.px_connect:query("select * from vehicles where owner=?", uid)
    if(vehs and #vehs > 0)then
        myInfo.vehs=vehs
    end

    -- target info
    local uid=getElementData(target, "user:uid")
    if(not uid)then return end

    -- my info
    local playerInfo={
        doplata=0,
        element=target,
        selected_veh=0,
        vehs={}
    }

    local vehs=exports.px_connect:query("select * from vehicles where owner=?", uid)
    if(vehs and #vehs > 0)then
        playerInfo.vehs=vehs
    end

    -- triggered
    triggerClientEvent(client, "get.exchange.info", resourceRoot, id, myInfo, playerInfo)
end)

-- convert

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end
