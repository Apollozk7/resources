--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local CL={}

CL.places={
    {get={2200.3691,2788.0859,10.8203},respawn={2200.2183,2788.9570,10.4453,181.6323}},
}

CL.getMarkers=function()
    for i,v in pairs(CL.places) do
        v.markerGet=createMarker(v.get[1], v.get[2], v.get[3], "cylinder", 2, 12, 251, 160)
        setElementData(v.markerGet,"marker:get",v.respawn,false)
        setElementData(v.markerGet, "text", {text="Parking policyjny", desc="Odbiór pojazdów"})
        setElementData(v.markerGet, "icon", ":px_parking/textures/garageMarker.png")

        v.blipGet=createBlipAttachedTo(v.markerGet,43)
        setBlipVisibleDistance(v.blipGet, 500)

        if(v.offPlace)then
            setElementData(v.markerGet,"out:place",true)
        end
    end
end
CL.getMarkers()

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local data=getElementData(source,"marker:get")
        if(data)then
            local veh=getPedOccupiedVehicle(hit)
            if(veh)then
                if(getVehicleController(veh) == hit)then
                    if(getElementData(veh, "vehicle:group_owner") == "SAPD" or getElementData(veh, "vehicle:group_owner") == "SARA")then
                        local towing=exports['px_factions-towing']:isVehicleTow(veh) or getVehicleTowedByVehicle(veh)
                        if(towing)then
                            local id=getElementData(towing, "vehicle:id")
                            local group_id=getElementData(towing, "vehicle:group_id")
                            local group_owner=getElementData(towing, "vehicle:group_owner")
                            if(id)then
                                triggerClientEvent(hit, "get.vehicle", resourceRoot, id, towing)
                            elseif(group_id and tonumber(group_owner))then
                                triggerClientEvent(hit, "get.vehicle", resourceRoot, group_id, towing)
                            end
                        end
                    end
                end
            else
                local vehs=exports.px_connect:query('select * from vehicles_policeParking, vehicles where vehicles_policeParking.id=vehicles.id')
                if(vehs and #vehs > 0)then
                    triggerClientEvent(hit, "get.vehicles", resourceRoot, vehs)
                    setElementData(hit,"marker:get",data,false)
                else
                    exports.px_noti:noti("Nie posiadasz żadnych pojazdów na parkingu policyjnym.", hit)
                end
            end
        end
    end
end)

addEventHandler("onMarkerLeave", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local data=getElementData(source,"marker:get")
        if(data)then
            triggerClientEvent(hit, "get.vehicles", resourceRoot)
            setElementData(hit,"marker:get",false,false)
        end
    end
end)

-- triggers

addEvent("get.vehicle", true)
addEventHandler("get.vehicle", resourceRoot, function(id, info)
    local uid=getElementData(client,"user:uid")
    if(not uid)then return end

    local data=getElementData(client,"marker:get")
    if(not data or not info or not id)then return end

    if(getPlayerMoney(client) >= info.cost)then
        local q=exports.px_connect:query('select * from vehicles_policeParking where id=? limit 1', id)
        if(q and #q > 0)then
            exports.px_connect:query("delete from vehicles_policeParking where id=? limit 1", id)

            local veh=exports.px_vehicles:createNewVehicle(id,client)
            if(veh and isElement(veh))then
                setElementPosition(veh, data[1],data[2],data[3])
                setElementRotation(veh, 0,0,data[4])

                setElementData(veh,"respawned",true,false)
                setTimer(function()
                    setElementData(veh,"respawned",false,false)
                end,150,1)

                takePlayerMoney(client, info.cost)

                exports.px_noti:noti("Pomyślnie wyciągnięto pojazd z parkingu policyjnego za "..info.cost.."$.", client)

                local wheels=getElementData(veh, 'vehicle:wheelsSettings') or {}
                setElementData(veh, 'vehicle:wheelsSettings', false)
                setElementData(veh, 'vehicle:wheelsSettings', wheels)
            end
        end
    end
end)

addEvent("add.vehicle", true)
addEventHandler("add.vehicle", resourceRoot, function(info, cost, reason)
    local veh=getPedOccupiedVehicle(client)
    if(not veh)then return end

    if(not info or not cost or not reason)then return end

    if(info[2] and isElement(info[2]))then
        local id=getElementData(info[2], "vehicle:id")
        if(not id)then return end

        exports.px_noti:noti("Pomyślnie oddano pojazd "..getVehicleName(info[2]).." ["..id.."] na parking policyjny z powodu "..reason.." za "..cost.."$.", client, "success")

        exports.px_connect:query('insert into vehicles_policeParking (id, policeman, reason, cost, date) values(?,?,?,?,now())', id, getPlayerName(client), reason, cost)

        exports.px_vehicles:saveVehicle(info[2],'destroy')

        setElementData(veh, "tow:haveVehicle", false)

        if(cost > 25)then
            givePlayerMoney(client, 25)
            exports.px_noti:noti("Otrzymujesz dodatkowe $25!", client, 'success')
        end
    end
end)

addEvent("add.vehicle->przecho", true)
addEventHandler("add.vehicle->przecho", resourceRoot, function(info)
    local veh=getPedOccupiedVehicle(client)
    if(not veh)then return end

    if(not info)then return end

    if(info[2] and isElement(info[2]))then
        local id=getElementData(info[2], "vehicle:id")
        if(not id)then return end

        local owner_uid = getElementData(info[2], "vehicle:owner")
        if(not owner_uid)then return end

        local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", owner_uid)
        if(parking_id and #parking_id == 1)then
            setElementData(veh, "tow:haveVehicle", false)

            exports.px_noti:noti("Pomyślnie oddano pojazd "..getVehicleName(info[2]).." ["..id.."] do przechowalni.", client, "success")

            exports.px_vehicles:saveVehicle(info[2],'destroy')

            exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, id)
        else
            exports.px_connect:query("INSERT INTO vehicles_garages SET playerID=?", owner_uid)

            local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", owner_uid)
            if(parking_id and #parking_id == 1)then
                setElementData(veh, "tow:haveVehicle", false)

                exports.px_noti:noti("Pomyślnie oddano pojazd "..getVehicleName(info[2]).." ["..id.."] do przechowalni.", client, "success")

                exports.px_vehicles:saveVehicle(info[2],'destroy')

                exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, id)
            end
        end
    end
end)