--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

ui['places']={
    {2384.7974,1051.3203,10.8203},
}

ui['tune']={
    'vehicle:ASR',
    'vehicle:ALS',
    'vehicle:radarDetector',
    'vehicle:cbRadio',
    'vehicle:speedoType',
    'vehicle:speedoColor',
    'vehicle:tint',
}

for i,v in pairs(ui['places']) do
    local marker=createMarker(v[1], v[2], v[3], 'cylinder', 2.5, 255, 0, 100)
    setElementData(marker, 'settings', {offIcon=true})
end

addEventHandler('onMarkerHit', resourceRoot, function(hit, dim)
    if(hit and dim and isElement(hit) and getElementType(hit) == 'player' and isPedInVehicle(hit) and getVehicleController(getPedOccupiedVehicle(hit)) == hit)then
        local veh=getPedOccupiedVehicle(hit)
        if(getVehicleType(veh) ~= 'Automobile')then return end

        local owner=getElementData(veh, 'vehicle:owner')
        local uid=getElementData(hit, 'user:uid')
        if(not uid or not owner)then return end
    
        if(uid ~= owner)then
            exports.px_noti:noti("Brak uprawnień.", hit, 'error')
            return
        end

        local datas={}
        for i,v in pairs(ui['tune']) do
            datas[v]=getElementData(veh, v)
        end

        triggerClientEvent(hit, 'open.ui', resourceRoot, datas)
        setElementFrozen(veh, true)

        datas=nil
    end
end)

addEventHandler('onMarkerLeave', resourceRoot, function(hit, dim)
    if(hit and dim and isElement(hit) and getElementType(hit) == 'player')then
        triggerClientEvent(hit, 'destroy.ui', resourceRoot)

        if(getPedOccupiedVehicle(hit))then
            setElementFrozen(getPedOccupiedVehicle(hit), false)
        end
    end
end)

-- triggers

ui['saveVehicleMechanicalTuning']=function(vehicle, name, value)
    local id=getElementData(vehicle, 'vehicle:id')
    if(not id)then return end

    local r=exports.px_connect:query('select mechanicTuning from vehicles where id=? limit 1', id)
    if(r and #r == 1)then
        local tune=split(r[1].mechanicTuning, ',') or {}
        local newName=utf8.gsub(name, 'vehicle:', '')
        if(value and value ~= true)then
            tune[#tune+1]=newName..'_'..value
            setElementData(vehicle, name, value)
        elseif(value)then
            tune[#tune+1]=newName
            setElementData(vehicle, name, true)
        else
            for i,v in pairs(tune) do
                if(utf8.find(v, newName))then
                    table.remove(tune, i)
                    setElementData(vehicle, 'vehicle:'..name, false)
                end
            end
        end
        exports.px_connect:query('update vehicles set mechanicTuning=? where id=? limit 1', table.concat(tune, ','), id)
    end
end

addEvent('add.illegal', true)
addEventHandler('add.illegal', resourceRoot, function(veh, name, cost, data, value)
    local id=getElementData(veh, "vehicle:id")
    if(not id)then return end

    local owner=getElementData(veh, 'vehicle:owner')
    local uid=getElementData(client, 'user:uid')
    if(not uid or not owner)then return end

    if(uid ~= owner)then
        exports.px_noti:noti("Brak uprawnień.", client, 'error')
        return
    end

    if(getPlayerMoney(client) >= cost)then
        setElementData(veh, data, value)
        ui['saveVehicleMechanicalTuning'](veh,data,value)

        takePlayerMoney(client, cost)
        exports.px_noti:noti('Pomyślnie zakupiono: '..name..' za kwotę $'..cost..'.', client, 'success')

        exports.px_admin:addTuningLogs(client,veh,cost,'Pomyślnie zakupiono: '..name..' za kwotę $'..cost..'.')
    else
        exports.px_noti:noti('Brak wystarczających funduszy.', client, 'error')
    end
end)

addEvent('remove.illegal', true)
addEventHandler('remove.illegal', resourceRoot, function(veh, name, cost, data)
    local id=getElementData(veh, "vehicle:id")
    if(not id)then return end

    local owner=getElementData(veh, 'vehicle:owner')
    local uid=getElementData(client, 'user:uid')
    if(not uid or not owner)then return end

    if(uid ~= owner)then
        exports.px_noti:noti("Brak uprawnień.", client, 'error')
        return
    end

    setElementData(veh, data, false)
    ui['saveVehicleMechanicalTuning'](veh,data,false)

    givePlayerMoney(client, cost/2)
    exports.px_noti:noti('Pomyślnie wymontowano: '..name..' za kwotę $'..(cost/2), client, 'success')

    exports.px_admin:addTuningLogs(client,veh,cost/2,'Pomyślnie wymontowano: '..name..' za kwotę $'..(cost/2))
end)