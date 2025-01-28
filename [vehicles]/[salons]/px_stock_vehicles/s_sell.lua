--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local markers={
    {2809.0510,1232.9546,10.8279},
    {930.4295,1713.6078,8.86},
}

for i,v in pairs(markers) do
    local marker=createMarker(v[1], v[2], v[3]-0.9, "cylinder", 1.2, 154, 121, 110)
    setElementData(marker, "icon", ":px_stock_vehicles/textures/sell/carsellMarker.png")
    setElementData(marker, "text", {text="Sprzedaż pojazdów",desc="Tutaj sprzedasz pojazdy"})
    setElementData(marker, "marker_sell", true, false)
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local uid=getElementData(hit, "user:uid")
        if(not uid)then return end

        if(not getElementData(source, "marker_sell"))then return end

        local q=exports.px_connect:query("select * from vehicles where owner=?", uid)
        if(q and #q > 0)then
            triggerClientEvent(hit, "sell.openUI", resourceRoot, q)
        else
            exports.px_noti:noti("Nie posiadasz żadnych pojazdów.", hit)
        end
    end
end)

-- offer

function sendBuyVehicleOffer(player, target, id, cost)
    local r=exports['px_connect']:query('select * from vehicles where id=? limit 1', id)
    if(r and #r == 1)then
        info=r[1]

        exports.px_noti:noti("Otrzymałeś ofertę kupna pojazdu od "..getPlayerName(player), target)
        exports.px_noti:noti("Pomyślnie wysłano oferte sprzedaży pojazdu dla gracza "..getPlayerName(target), player)
        triggerClientEvent(target, "send.offer", resourceRoot, player, info, cost)
    end
end
addEvent("send.offer", true)
addEventHandler("send.offer", resourceRoot, function(target, info, cost)
    sendBuyVehicleOffer(client, target, info.id, cost)
end)

function setVehicleGarage(id,owner)
    local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", owner)
    if(parking_id and #parking_id == 1)then
        exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0,water=0 where id=? limit 1", parking_id[1].id, id)
    else
        exports.px_connect:query("INSERT INTO vehicles_garages SET playerID=?", owner)

        local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", owner)
        if(parking_id and #parking_id == 1)then
            exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0,water=0 where id=? limit 1", parking_id[1].id, id)
        end
    end
end

addEvent("buy.vehicle", true)
addEventHandler("buy.vehicle", resourceRoot, function(info)
    local uid=getElementData(client, "user:uid")
    if(not uid or not info)then return end

    if(info.owner ~= uid)then
        local q=exports.px_connect:query("select * from vehicles where owner=? and id=? limit 1", info.owner, info.id)
        if(q and #q > 0)then
            local getFree,have,slots=exports.px_vehicles:getPlayerFreeVehicleSlot(client)
            if(getFree)then
                if(getPlayerMoney(client) >= tonumber(info.cost))then
                    takePlayerMoney(client, tonumber(info.cost))

                    local v=getVehicleFromID(tonumber(info.id))
                    if(v and isElement(v))then
                        setElementData(v, "vehicle:owner", uid)
                        setElementData(v, "vehicle:ownerName", getPlayerName(client))

                        destroySellOpis(v)

                        if(getElementInterior(v) ~= 0 or getElementDimension(v) ~= 0)then
                            local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", getPlayerName(client))
                            if(parking_id and #parking_id == 1)then
                                exports.px_vehicles:saveVehicle(v)
                                destroyElement(p)
        
                                exports.px_connect:query("update vehicles set parking=?,h_garage=0,water=0,position=NULL where id=?", parking_id[1].id, uid)
                            else
                                exports.px_connect:query("INSERT INTO vehicles_garages SET playerID=?", getPlayerName(client))
        
                                local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", getPlayerName(client))
                                if(parking_id and #parking_id == 1)then
                                    exports.px_vehicles:saveVehicle(v)
                                    destroyElement(v)
                
                                    exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0,water=0 where id=?", parking_id[1].id, uid)
                                end
                            end
                         end
                    else
                        if(tonumber(q[1].parking) ~= 0 or tonumber(q[1].h_garage) ~= 0)then
                            setVehicleGarage(info.id,uid)
                        end
                    end

                    exports.px_discord:sendDiscordLogs("[GIELDA] Kupiono pojazd "..getVehicleNameFromModel(info.model).." za cene "..convertNumber(info.cost).."$.", "wymiany", client)
                    exports.px_discord:sendDiscordLogs("[GIELDA] Kupiono pojazd "..getVehicleNameFromModel(info.model).." za cene "..convertNumber(info.cost).."$.", "hajs", client)

                    exports.px_connect:query("update vehicles set owner=?,ownerName=?, orgRank=0, organization=? where id=?", uid, getPlayerName(client), "", info.id)

                    exports.px_noti:noti("Pomyślnie zakupiłeś pojazd "..getVehicleNameFromModel(info.model).." za cene "..convertNumber(info.cost).."$.", client)

                    if(info.player and isElement(info.player))then
                        givePlayerMoney(info.player, tonumber(info.cost))
                        exports.px_noti:noti("Gracz "..getPlayerName(client).." zakupił twój pojazd "..getVehicleNameFromModel(info.model).." za cene "..convertNumber(info.cost).."$.", info.player)
                        setElementData(info.player, "sell_vehs:offer", false)

                        -- logi biznesow
                        local r=exports['px_connect']:query('select id from groups_business where owner=? limit 1', info.owner)
                        if(r and #r == 1)then
                            exports['px_business-main']:addBusinessLog(info.player,'Sprzedaż pojazdu', info.cost, r[1].id, getVehicleNameFromModel(info.model), getPlayerName(client))
                        end
                    else
                        exports.px_connect:query("update accounts set money=money+? where login=?", tonumber(info.cost), info.from)
                    end

                    if(not exports.px_achievements:isPlayerHaveAchievement(client, "Pierwszy pojazd"))then
                        exports.px_achievements:getAchievement(client, "Pierwszy pojazd")
                    end

                    setElementData(client, "sell_vehs:offer", false)
                    setElementData(info.player, "sell_vehs:offer", false)
                else
                    setElementData(client, "sell_vehs:offer", false)
                    setElementData(info.player, "sell_vehs:offer", false)
                    
                    exports.px_noti:noti("Nie stać cię na zakup tego pojazdu.", client)
                end
            else
                setElementData(client, "sell_vehs:offer", false)
                setElementData(info.player, "sell_vehs:offer", false)
                
                exports.px_noti:noti("Posiadasz już maksymalną ilość pojazdów: "..math.floor(have).."/"..math.floor(slots)..".", client, "error")
                exports.px_noti:noti(getPlayerName(client).." posiada już maksymalną ilość pojazdów: "..math.floor(have).."/"..math.floor(slots)..".", info.player, "error")
            end
        else
            setElementData(client, "sell_vehs:offer", false)
            setElementData(info.player, "sell_vehs:offer", false)
            
            exports.px_noti:noti("Dany pojazd został już sprzedany.", client)
        end
    else
        setElementData(info.player, "sell_vehs:offer", false)
        setElementData(client, "sell_vehs:offer", false)

        exports.px_noti:noti("Nie możesz zakupić swojego pojazdu.", client)
    end
end)

addEvent("cancel.offer", true)
addEventHandler("cancel.offer", resourceRoot, function(text, player)
    if(player and isElement(player))then
        exports.px_noti:noti(text, player)
        setElementData(player, "sell_vehs:offer", false)
    end

    setElementData(client, "sell_vehs:offer", false)
end)

function getVehicleFromID(id)
    return getElementByID("px_vehicles_id:"..id)
end

addEvent('off.data', true)
addEventHandler('off.data', resourceRoot, function(player)
    setElementData(player, 'sell_vehs:offer', false)
end)