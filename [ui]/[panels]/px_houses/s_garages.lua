--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

g={}

-- useful

function table.size(tbl)
    local x=0
    for i,v in pairs(tbl) do
        x=x+1
    end
    return x
end

--

-- create

g.positions={
    [1]={
        ["enterRot"]={0,0,270},
        ["enterTeleport"]={-4.6413,1538.4767,-91.7891},
        ["exit"]={-6.0067,1538.6456,-91.7891},
        ['veh_def']={-3.8620,1538.4758,-91.7891,0,0,88.9694},
    },

    [2]={
        ["enterRot"]={0,0,360},
        ["enterTeleport"]={-16.7319,1524.0383,-91.6813},
        ["exit"]={-16.9455,1521.1141,-91.4532},
        ['veh_def']={-16.6757,1529.9688,-91.8090,0,0,177.8566},
    },
}

g.garages={}

g.updateGarage=function(house_id)
    local q=exports.px_connect:query("select * from houses_garages where house_id=? limit 1", house_id)
    if(q and #q == 1)then
        local v=q[1]
        local h=ui.houses[house_id]
        if(h)then
            v.dim=h.dim

            local pos=g.positions[h.level].exit
            setElementPosition(g.garages[h.dim].exitMarker, unpack(pos))
        end
    end
end

g.loadGarage=function(house_id)
    local q=exports.px_connect:query("select * from houses_garages where house_id=? limit 1", house_id)
    if(q and #q == 1)then
        local v=q[1]
        local h=ui.houses[house_id]
        if(h)then
            v.dim=h.dim

            local pos=split(v.enterPos, ", ") or {0,0,0}
            
            g.garages[h.dim]={
                enterMarker=createMarker(pos[1], pos[2], pos[3], "cylinder", 2.5, 200, 200, 200),
                exitMarker=createMarker(g.positions[h.level].exit[1], g.positions[h.level].exit[2], g.positions[h.level].exit[3], "cylinder", 2, 255, 0, 0),

                vehicles={},
                id=house_id,
            }

            setElementData(g.garages[h.dim].enterMarker, "g_info", v, false)
            setElementData(g.garages[h.dim].enterMarker, "icon", ":px_houses/textures/garageMarker.png")

            local infos={
                pos=pos,
                rot=split(v.exitRot, ", ") or {0,0,0},
                id=house_id,
                dim=h.dim
            }
            setElementData(g.garages[h.dim].exitMarker, "exit", infos, false)
            setElementData(g.garages[h.dim].exitMarker, "icon", ":px_houses/textures/outMarker.png")
            setElementDimension(g.garages[h.dim].exitMarker, h.dim)
        end
    end
end

--

-- vehicles

g.loadVehicles=function(dim, level)
    local garage=g.garages[dim]
    if(garage)then
        local vehs=exports.px_connect:query("select id from vehicles where h_garage=?", garage.id)
        for i,v in pairs(vehs) do
            --exports.px_connect:query("update vehicles set h_garage=0 where id=?", v.id)
            
            local veh,error=getElementByID("px_vehicles_id:"..v.id),'(?) on map'
            if(not veh)then
                veh,error=exports.px_vehicles:createNewVehicle(v.id,false,false,garage.id)
            end

            if(veh)then
                setElementDimension(veh, dim)
                garage.vehicles[veh]=true

                local vehPos={getElementPosition(veh)}
                local def_pos=g.positions[level].veh_def
                if(def_pos)then
                    local dist=getDistanceBetweenPoints3D(vehPos[1], vehPos[2], vehPos[3], def_pos[1], def_pos[2], def_pos[3])
                    if(dist > 50)then
                        setElementPosition(veh, def_pos[1], def_pos[2], def_pos[3])                    
                        setElementRotation(veh, def_pos[4], def_pos[5], def_pos[6])
                    end
                end
            else
                iprint('[px_houses] Problem z utworzeniem pojazdu '..v.id, error)
            end
        end
    end
end

g.destroyVehicles=function(dim, veh)
    local garage=g.garages[dim]
    if(garage)then
        if(veh)then
            garage.vehicles[veh]=nil
        end

        for i,v in pairs(garage.vehicles) do
            if(i and isElement(i))then
                local ids=getElementData(i, "vehicle:id")
                exports.px_connect:query("update vehicles set h_garage=? where id=? limit 1", garage.id, ids)
                exports.px_vehicles:saveVehicle(i,'destroy')
            end
        end
    end
end

--

-- teleports

g.nextEnterGarage=function(player, house, garage, id, veh)
    local r=exports.px_connect:query('select level from houses where id=? limit 1', house.id)
    if(r and #r == 1)then
        triggerClientEvent(player, "playSound", resourceRoot, "sounds/enter_garage.wav")

        if(veh)then
            for i,v in pairs(getVehicleOccupants(veh)) do
                exports.px_loading:createLoadingScreen(v, true, false, 5000)
            end
        else
            exports.px_loading:createLoadingScreen(player, true, false, 5000)
        end

        ui.createInterior(house.dim, player, true, house.exitMarker, house.id)

        player=veh and veh or player
        setElementFrozen(player, true)
        setTimer(function()
            if(player and isElement(player))then
                setElementPosition(player, unpack(g.positions[r[1].level].enterTeleport))
                setElementRotation(player, unpack(g.positions[r[1].level].enterRot))
                setElementDimension(player, house.dim)
                setElementFrozen(player, false)
            end
        end, 3000, 1)
    end
end

local vehLimits = {
    [1] = 1,
    [2] = 4
}

g.enterGarage=function(id, player)
    local house=ui.houses[id]
    if(house)then    
        local garage=g.garages[house.dim]
        if(garage)then
            local enter=false

            local vehs=exports.px_connect:query("select id from vehicles where h_garage=?", id)
            for i,v in pairs(vehs) do
                local vehicleElement = getElementByID("px_vehicles_id:"..v.id);
                if(vehicleElement)then
                    setElementDimension(vehicleElement, house.dim)
                end
            end
            
            local veh=getPedOccupiedVehicle(player)
            if(veh and getElementData(veh, "vehicle:id"))then
                local vehs=exports.px_connect:query("select id from vehicles where h_garage=?", id)
                if(#vehs+1 <= vehLimits[house.level] and table.size(garage.vehicles) <= vehLimits[house.level])then
                    garage.vehicles[veh]=true
                    g.nextEnterGarage(player, house, garage, id, veh)
                else
                    exports.px_noti:noti("W tym garażu nie ma już miejsca.", player, "error")
                end
            elseif(not veh)then
                g.nextEnterGarage(player, house, garage, id)
            end
        end
    end
end

g.exitGarage=function(player, id, veh)
    local h=ui.houses[id]
    if(h)then
        local garage=g.garages[h.dim]
        if(garage)then
            ui.destroyInterior(h.dim, veh)
        end
    end
end

-- on hit

g.hitGarage=function(player, key, keyState, data)
    g.enterGarage(data.house_id, player)
    unbindKey(player, "X", "down", g.hitGarage)
end

g.leaveGarage=function(hit, key, keyState, exit)
    triggerClientEvent(hit, "playSound", resourceRoot, "sounds/enter_garage.wav")
    unbindKey(hit, "X", "down", g.leaveGarage)

    local player=hit
    local veh=getPedOccupiedVehicle(hit)

    if(veh)then
        if(getElementData(veh, "vehicle:id"))then
            exports.px_connect:query("update vehicles set h_garage=0 where id=?", getElementData(veh, "vehicle:id"))
        end
        player=veh

        for i,v in pairs(getVehicleOccupants(veh)) do
            exports.px_loading:createLoadingScreen(v, true, false, 5000)
        end
        setElementFrozen(veh, true)
    else
        setElementFrozen(player, true)
        exports.px_loading:createLoadingScreen(hit, true, false, 5000)
    end

    g.exitGarage(player, exit.id, veh)

    local x,y,z=unpack(exit.pos)
    x,y,z=getTopPosition(x,y,z,5,exit.rot[3])

    setElementPosition(player, x, y, z)
    setElementRotation(player, unpack(exit.rot))
    setElementDimension(player, 0)
    setElementFrozen(player, false)
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player")then
        local data=getElementData(source, "g_info")
        local exit=getElementData(source, "exit")

        local veh=getPedOccupiedVehicle(hit)
        if(data and g.garages[data.dim])then
            if(veh)then
                if(g.isPlayerHavePerms(hit, data.house_id, veh))then
                    bindKey(hit, "X", "down", g.hitGarage, data)
                    exports.px_noti:noti("Kliknij klawisz 'X' aby wejść do garażu.", hit, "info")
                    return
                end
            end

            if(ui.getPlayerHouseAccess(data.house_id, hit, "rent"))then
                bindKey(hit, "X", "down", g.hitGarage, data)
                exports.px_noti:noti("Kliknij klawisz 'X' aby wejść do garażu.", hit, "info")
            else
                if(ui.houses[data.house_id] and ui.houses[data.house_id].data.castle == 0 and not isPedInVehicle(hit))then
                    bindKey(hit, "X", "down", g.hitGarage, data)
                    exports.px_noti:noti("Kliknij klawisz 'X' aby wejść do garażu.", hit, "info")
                else
                    exports.px_noti:noti("Brak uprawnień do wejścia.", hit, "error")
                end
            end
        end

        if(exit)then
            bindKey(hit, "X", "down", g.leaveGarage, exit)
            exports.px_noti:noti("Kliknij klawisz 'X' aby wyjść z garażu.", hit, "info")
        end
    end
end)

addEventHandler("onMarkerLeave", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player")then
        unbindKey(hit, "X", "down", g.hitGarage)
        unbindKey(hit, "X", "down", g.leaveGarage)
    end
end)

-- create garage

g.createGarage=function(pos, id, rot)
    if(pos and id and rot)then
        exports.px_connect:query("insert into houses_garages (house_id,enterPos,exitRot) values(?,?,?)", id, table.concat(pos, ", "), "0,0,"..rot)
        setTimer(function()
            g.loadGarage(tonumber(id))
        end, 200, 1)
    end
end

addCommandHandler("add.garage", function(player, _, id)
    if(id and getElementData(player, "user:admin") >= 4)then
        local pos={getElementPosition(player)}
        local _,_,rot=getElementRotation(player)
        g.createGarage(pos, id, rot)
    end
end)

addEventHandler("onElementDestroy", root, function()
    if(source and getElementType(source) == "vehicle")then
        local dim=getElementDimension(source)
        if(dim > 0)then
            local garage=g.garages[dim]
            if(garage)then
                if(garage.vehicles and garage.vehicles[source])then
                    garage.vehicles[source]=nil
                end
            end
        end
    end
end)

--

-- useful

g.isPlayerHavePerms=function(player, hid, vehicle)
    local h=ui.houses[hid]
    if(h)then
        local myUID=getElementData(player, "user:uid")
        local vehOWNER=getElementData(vehicle, "vehicle:owner")

        if(not vehOWNER)then return false end

        local state = false;

        if(myUID == vehOWNER and vehOWNER == h.data.owner)then
            state = true;
        end

        local exist = false

        local rents=exports.px_connect:query("select * from houses_rents where house_id=?", hid)
        for i,v in pairs(rents) do
            if(vehOWNER == v.uid)then
                exist=true
                break
            end
        end

        return (exist or state)
    end
end

--

-- useful

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end

function getTopPosition(x, y, z, plus, rot)
    local cx, cy = getPointFromDistanceRotation(x, y, (plus or 0), (-(rot)))
    return cx,cy,z
end