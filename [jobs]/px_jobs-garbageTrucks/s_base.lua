--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function startJob(player, info, reverse, players)
    info.upgrades=fromJSON(info.upgrades) or {}

    local job=ui.jobVehicles[1]
    if(info.upgrades["Śmieciarka 750KG"])then
        job=ui.jobVehicles[2]
    elseif(info.upgrades["Śmieciarka 1T"])then
        job=ui.jobVehicles[3]
    end

    local vehicle={id=getVehicleModelFromName(job.vehicle)}
    ui.vehicles[player]=createVehicle(vehicle.id, 635.3998,1253.0314,12.2582,0,0,299.7755)

    warpPedIntoVehicle(player, ui.vehicles[player])

    setVehicleColor(ui.vehicles[player], 200, 200, 200, 0, 50, 0)
    setElementData(ui.vehicles[player], "vehicle:components", {"Śmieciarka"})
    setElementData(ui.vehicles[player], "vehicle:job_value", {
        value=0,
        maxValue=job.max
    })

    local points=ui.getRandomPoints(35)
    for i,v in pairs(players) do
        triggerClientEvent(v, "start.job", resourceRoot, info, players, player, ui.vehicles[player], points)
    end
    triggerClientEvent(player, "start.job", resourceRoot, info, players, player, ui.vehicles[player], points)
end

function sendUpgrades(player, upgrades)
    upgrades=fromJSON(upgrades) or {}

    if(upgrades["Szybcior"])then
        triggerClientEvent(player, "set.upgrade", resourceRoot)
    end
end

function stopJob(player, reverse)
    if(player and isElement(player))then
        local job=getElementData(player, "user:job")
        if(job == "Śmieciarki")then
            triggerClientEvent(player, "stop.job", resourceRoot)
            triggerClientEvent("check.players", resourceRoot, player)

            setElementData(player, "user:job_settings", false)

            if(not reverse)then
                checkAndDestroy(ui.vehicles[player])
                ui.vehicles[player]=nil

                exports.px_jobs_settings:stopJob(player)
            end

            checkAndDestroy(ui.objects[player])
            ui.objects[player]=nil
        end
    end
end
addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, stopJob)

addEventHandler("onVehicleStartEnter", resourceRoot, function(player, seat)
    if(seat ~= 0)then cancelEvent() return end

    if(not ui.vehicles[player] or (ui.vehicles[player] and ui.vehicles[player] ~= source))then
        cancelEvent()
        exports.px_noti:noti("Ten pojazd nie należy do Ciebie i nie posiadasz uprawnień aby go kierować.", player, "error")
    end
end)

addEvent("get.trash", true)
addEventHandler("get.trash", resourceRoot, function(id, players, lider, obj_id, vehicle)
    if(ui.objects[client])then return end

    if(not id or not players or (players and #players < 1) or not lider or (lider and not isElement(lider)) or not obj_id or getElementByID("px_jobs-garbageTrucks:"..id))then 
        ui.getHaveTrash(client,id)
        return 
    end

    local job=getElementData(vehicle, "vehicle:job_value")
    if(job.value >= job.maxValue)then
        ui.getHaveTrash(client,id)    
        return 
    end

    for i,v in pairs(players) do
        if(v and isElement(v))then
            triggerClientEvent(v, "get.trash", resourceRoot, id)
        end
    end

    triggerClientEvent(lider, "get.trash", resourceRoot, id)
    triggerClientEvent(client, "create.vehicle.marker", resourceRoot, obj_id)

    ui.objects[client]=createObject(obj_id, 0, 0, 0)
    setPedAnimation(client, "CARRY", "crry_prtial", 4.1, true, true, true)

    setTimer(function(client)
        if(ui.objects[client] and isElement(ui.objects[client]) and client and isElement(client))then
            if(ui.ids[obj_id] == "Kosz")then
                exports.pAttach:attachElementToBone(ui.objects[client], client, 25, 0, -0.5, 0.2, 0, 250, 90)

                exports.px_noti:noti("Następnie rozładuj kosz do śmieciarki.", client, "info")
            else
                setObjectScale(ui.objects[client], 0.7)

                exports.pAttach:attachElementToBone(ui.objects[client], client, 25, 0.1, 0.2, -0.05, 0, 270, 0)

                exports.px_noti:noti("Następnie wyrzuć śmieci do śmieciarki.", client, "info")
            end
        else
            if(client and isElement(client))then
                ui.getHaveTrash(client,id)
            end
        end
    end, 50, 1, client)
    setElementID(ui.objects[client], "px_jobs-garbageTrucks:"..id)

    setElementCollisionsEnabled(ui.objects[client], false)
end)

ui.getHaveTrash=function(client,id)
    if(id)then
        local obj=getElementByID("px_jobs-garbageTrucks:"..id)
        if(not obj or (obj and not isElement(obj)))then
            if(not ui.objects[client] or (ui.objects[client] and not isElement(ui.objects[client])))then
                triggerClientEvent(client, "haveTrash", resourceRoot)
            end
        end
    else
        if(not ui.objects[client] or (ui.objects[client] and not isElement(ui.objects[client])))then
            triggerClientEvent(client, "haveTrash", resourceRoot)
        end
    end
end
addEvent("getHaveTrash", true)
addEventHandler("getHaveTrash", resourceRoot, ui.getHaveTrash)

addEvent("add.trash", true)
addEventHandler("add.trash", resourceRoot, function(vehicle,add)
    if(vehicle and isElement(vehicle))then
        local job=getElementData(vehicle, "vehicle:job_value")
        if(not job)then return end

        job.value=job.value+add
        job.value=job.value > job.maxValue and job.maxValue or job.value
        
        setElementData(vehicle, "vehicle:job_value", job)
    end
end)

addEvent("get.points", true)
addEventHandler("get.points", resourceRoot, function(names)
    local points=ui.getRandomPoints(35)

    for i,v in pairs(names) do
        local p=getPlayerFromName(v)
        if(p and isElement(p))then
            triggerClientEvent(p, "create.points", resourceRoot, points)
        end
    end
    triggerClientEvent(client, "create.points", resourceRoot, points)
end)

addEvent("take.trash", true)
addEventHandler("take.trash", resourceRoot, function(vehicle)
    local player=client
    local trash=ui.objects[client]
    if(trash and isElement(trash) and vehicle and isElement(vehicle))then
        ui.frozens[vehicle]=ui.frozens[vehicle] and ui.frozens[vehicle]+1 or 1
        setElementFrozen(vehicle, true)

        if(ui.ids[getElementModel(trash)] == "Kosz")then
            exports.pAttach:detachElementFromBone(trash)
        end

        setTimer(function()
            if(player and isElement(player) and trash and isElement(trash))then
                if(ui.ids[getElementModel(trash)] == "Kosz")then
                    setPedAnimation(player, "CARRY", "liftup", 0.0, false, false, false, false)

                    local id=getElementModel(trash)
                    checkAndDestroy(ui.objects[player])
                    ui.objects[player]=nil

                    trash=createObject(id,0,0,0)
                    setElementCollisionsEnabled(trash, false)
                    setElementAlpha(trash, 150)

                    local px,py,pz=getElementPosition(vehicle)
                    local rx, ry, rrz=getElementRotation(vehicle)
                    local px2,py2,pz2=getPositionFromElementOffset(vehicle,0,-3.8,-0.5)
                    local px5,py5,pz5=getPositionFromElementOffset(vehicle,0,-3.8,0.25)
                    local px3,py3,pz3=getPositionFromElementOffset(vehicle,0,-3.3,0.25)
                    local px4,py4,pz4=getPositionFromElementOffset(vehicle,0,-4,-0.25)
                    local rrz3=math.rad(rrz)
                    local rotacja=0
                    local rotacja2=rx
                    local mnoznik=-2
            
                    if (rx<360) and (rx>180) then
                        rotacja2=(360-rx)
                        mnoznik=2
                        rotacja=(rotacja2/12)
                    end
                    if (rx>0) and (rx<180) then
                        rotacja=rx
                        rotacja=(0-rotacja/15)
                    end
            
                    setElementPosition(trash, px2, py2, pz2)
                    setElementRotation(trash,rx,-ry,rrz+180)
            
                    moveObject(trash, 2000, px3, py3, pz3, 120+(mnoznik*rotacja2), 0, 0, "OutBounce")
            
                    setTimer(function()
                        if(trash and isElement(trash))then
                            moveObject(trash, 2000, px4, py4, pz4, -120, 0, 0, "OutBounce")
                
                            setTimer(function()
                                checkAndDestroy(trash)

                                if(not ui.objects[player] or (ui.objects[player] and not isElement(ui.objects[player])))then
                                    triggerClientEvent(player, "haveTrash", resourceRoot)
                                end

                                if(vehicle and isElement(vehicle))then
                                    ui.frozens[vehicle]=ui.frozens[vehicle]-1
                                    if(ui.frozens[vehicle] == 0)then
                                        setElementFrozen(vehicle, false)
                                        ui.frozens[vehicle]=nil
                                    end
                                end
                            end, 2000, 1)
                        else
                            checkAndDestroy(trash)
                        end
                    end, 3000, 1)
                else
                    setPedAnimation(player, "baseball", "bat_1", 1.0, false, false, false, true)
                    setTimer(function()
                        if(trash and isElement(trash) and player and isElement(player))then
                            exports.pAttach:detachElementFromBone(trash)
                            setElementCollisionsEnabled(trash, false)
            
                            checkAndDestroy(ui.objects[player])
                            ui.objects[player]=nil
                
                            ui.frozens[vehicle]=ui.frozens[vehicle]-1
                            if(ui.frozens[vehicle] == 0)then
                                setElementFrozen(vehicle, false)
                                ui.frozens[vehicle]=nil
                            end

                            setPedAnimation(player, "CARRY", "liftup", 0.0, false, false, false, false)

                            triggerClientEvent(player, "haveTrash", resourceRoot)
                        else
                        end
                    end, 500, 1)
                end
            end
        end, 100, 1)
    end
end)

addEvent("get.payment", true)
addEventHandler("get.payment", resourceRoot, function(players, lider, x)
    for i,v in pairs(players) do
        if(v and isElement(v))then
            exports.px_jobs_settings:getPayment(lider, x, false, false, v)
        end
    end

    if(lider and isElement(lider))then
        exports.px_jobs_settings:getPayment(lider, x, false)
    end

    local points=ui.getRandomPoints(35)
    triggerClientEvent(lider, "create.points", resourceRoot, points)
    for i,v in pairs(players) do
        if(v and isElement(v))then
            triggerClientEvent(v, "create.points", resourceRoot, points)
        end
    end
end)

-- events

addEventHandler("onPlayerQuit", root, function()
    stopJob(source)
end)

addEventHandler("onVehicleDamage", resourceRoot, function(loss)
    local player=getVehicleController(source)
    if(player and isElement(player) and ui.vehicles[player] and ui.vehicles[player] == source)then
        local data=getElementData(player, "user:job_settings")
        loss=loss/10

        if(not data.takeMoney or data.takeMoney < 20)then
            data.takeMoney=(data.takeMoney or 0)+loss
            data.takeMoney=math.floor(data.takeMoney)
            setElementData(player, "user:job_settings", data)
        end
    end
end)

-- useful

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

-- koguty

local sirens={
    objects={},

    [573]={
        {-0.9,2.7,1.6},
        {0.9,2.7,1.6},

        {0, -2.7, 1.7},
    },

    [408]={
        {-1.3,1.5,2},
        {1.3,1.5,2},

        {0, -3, 2},
    },

    [524]={
        {-0.92,3.2,1.4},
        {0.92,3.2,1.4},

        {0, -3, 2},
    },
}

function setSiren(vehicle)
    if(sirens.objects[vehicle])then
        for i,v in pairs(sirens.objects[vehicle].markers) do
            checkAndDestroy(v)
        end

        if(isTimer(sirens.objects[vehicle].timer))then
            killTimer(sirens.objects[vehicle].timer)
        end

        sirens.objects[vehicle]=nil
    else
        local pos=sirens[getElementModel(vehicle)]
        if(pos)then
            sirens.objects[vehicle]={
                timer=false,
                markers={}
            }

            for i,v in pairs(pos) do
                sirens.objects[vehicle].markers[i]=createMarker(0,0,0,"corona",0.3,255,100,0,100)
                attachElements(sirens.objects[vehicle].markers[i], vehicle, v[1], v[2], v[3])
            end

            local timer=setTimer(function()
                if(sirens.objects[vehicle])then
                    for i,v in pairs(sirens.objects[vehicle].markers) do
                        if(getElementAlpha(v) == 100)then
                            setElementAlpha(v, 0)
                        else
                            setElementAlpha(v, 100)
                        end
                    end
                else
                    killTimer(timer)
                end
            end, 300, 0)
            sirens.objects[vehicle].timer=timer
        end
    end
end

addEventHandler("onVehicleExit", resourceRoot, function(plr,seat)
    if(seat ~= 0)then return end

    if(sirens.objects[source])then
        for i,v in pairs(sirens.objects[source].markers) do
            checkAndDestroy(v)
        end

        if(isTimer(sirens.objects[source].timer))then
            killTimer(sirens.objects[source].timer)
        end

        sirens.objects[source]=nil
    end
end)

addEventHandler("onVehicleEnter", resourceRoot, function(plr,seat)
    if(seat ~= 0)then return end

    setSiren(source)
end)

addEventHandler("onElementDestroy", resourceRoot, function()
    if(sirens.objects[source])then
        for i,v in pairs(sirens.objects[source].markers) do
            checkAndDestroy(v)
        end

        if(isTimer(sirens.objects[source].timer))then
            killTimer(sirens.objects[source].timer)
        end

        sirens.objects[source]=nil
    end
end)