--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

local noti=exports.px_noti
local jobs=exports.px_jobs_settings
local quests=exports.px_quests

ui.pallets={}
ui.boxes={}

ui.respawnPosition={
    veh={1608.9109,1010.5569,10.7263,0.2532},
    object={1606.2551,1015.0016,10.8203,272.3535}
}

ui.staticVehicle=createVehicle(530, 1610.8612,1010.5504,10.7254)
setVehicleLocked(ui.staticVehicle,true)
setElementFrozen(ui.staticVehicle,true)
setVehicleColor(ui.staticVehicle,255,255,0,255,255,0)

ui.cs=createColCuboid(1589.22705, 1003.48279, 9.82031, 34.88134765625, 56.377563476562, 8.509375)

addEventHandler("onColShapeLeave", ui.cs, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim and getElementData(hit, "user:job") == "Magazynier")then
        stopJob(hit)
    end
end)

ui.getBoxes=function(player)
    if(not ui.boxes[player])then return false end

    local have=false
    for i,v in pairs(ui.boxes[player]) do
        if(exports.pAttach:getElementBoneAttachmentDetails(v) == player)then
            have=true
            break
        end
    end
    return have
end

ui.getPallet=function(player, get)
    if(ui.pallets[player] and isElement(ui.pallets[player]) and not ui.getBoxes(player))then
        if(getElementAttachedTo(ui.pallets[player]) == player)then
            if(not get)then
                detachElements(ui.pallets[player],player)
                
                local rx,ry,rz=getElementRotation(player)
                setElementRotation(ui.pallets[player],rx,ry,rz-180)

                setPedAnimation(player, "CARRY", "liftup", 0.0, false, false, false, false)

                setElementData(player, "px_warehouse:havePallet", false)

                triggerClientEvent(player, "triggerClient", resourceRoot)
            end
        else
            if(get)then
                local myPos={getElementPosition(player)}
                local hisPos={getElementPosition(ui.pallets[player])}
                local dist=getDistanceBetweenPoints3D(myPos[1],myPos[2],myPos[3],hisPos[1],hisPos[2],hisPos[3])
                if(dist < 2)then
                    attachElements(ui.pallets[player],player,-0.05,1,-1,0,0,180)

                    setPedAnimation(player, "CARRY", "crry_prtial", 4.1, true, true)

                    setElementData(player, "px_warehouse:havePallet", true)

                    triggerClientEvent(player, "triggerClient", resourceRoot)
                end
            end
        end
    end
end
addEvent("get.pallet", true)
addEventHandler("get.pallet", resourceRoot, ui.getPallet)

function reverseJob(player)
    jobs:getPayment(player)

    triggerClientEvent(player, "stop.job", resourceRoot, true)
    triggerClientEvent(player, "start.job", resourceRoot, ui.pallets[player], false, true)
end
addEvent("reverse.job", true)
addEventHandler("reverse.job", resourceRoot, reverseJob)

function startJob(player, info, reverse)
    info.upgrades=fromJSON(info.upgrades) or {}

    if(info.upgrades["Wózek widłowy"])then
        ui.pallets[player]=createVehicle(530, unpack(ui.respawnPosition.veh))
        setVehicleColor(ui.pallets[player], 255, 255, 0, 255, 255, 0)
        warpPedIntoVehicle(player, ui.pallets[player])
        setVehicleHandling(ui.pallets[player], "maxVelocity", 40)
        setElementData(ui.pallets[player], "ghost", "all")

        noti:noti("Podjedź pod auto a następnie weź paczkę na widły.", player, "info")
    else
        ui.pallets[player]=createObject(1866, ui.respawnPosition.object[1], ui.respawnPosition.object[2], ui.respawnPosition.object[3]-1)
        setElementCollisionsEnabled(ui.pallets[player], false)
    
        noti:noti("Podejdź do paleciaka i użyj 'Q' aby go złapać. Następnie udaj się załadować paczki.", player, "info")
    end

    setElementData(player, "ghost", "all")

    triggerClientEvent(player, "start.job", resourceRoot, ui.pallets[player], info, reverse)
end

function stopJob(player)
    if(player and isElement(player))then
        local job=getElementData(player, "user:job")
        if(job == "Magazynier")then
            checkAndDestroy(ui.pallets[player])
            ui.pallets[player]=nil

            setPedAnimation(player, "CARRY", "liftup", 0.0, false, false, false, false)

            triggerClientEvent(player, "stop.job", resourceRoot)

            setElementData(player, "user:job", false)
            setElementData(player, "user:job_settings", false)

            if(ui.boxes[player])then
                for i,v in pairs(ui.boxes[player]) do
                    checkAndDestroy(v)
                end
                ui.boxes[player]=nil
            end

            setElementData(player, "px_warehouse:havePallet", false)

            setElementData(player, "ghost", false)
        end
    end
end

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end

addEvent("get.box", true)
addEventHandler("get.box", resourceRoot, function(id, case, forklift)
    if(forklift and ui.pallets[client] and isElement(ui.pallets[client]) and getPedOccupiedVehicle(client) == ui.pallets[client])then
        local index=1
        if(ui.boxes[client])then
            index=#ui.boxes[client]+1
        else
            ui.boxes[client]={}
        end
    
        local pos=id == 3005 and {0,0.5,0.21} or {0,0.5,0.17}
        ui.boxes[client][index]=createObject(id,0,0,0)
        attachElements(ui.boxes[client][index], ui.pallets[client], pos[1], pos[2], pos[3])
        setElementData(ui.boxes[client][index], "box_shader", case)
        setElementCollisionsEnabled(ui.boxes[client][index], false)
    else
        setPedAnimation(client, "CARRY", "liftup", 1.0, false, false, false, true)

        setTimer(function(client)
            if(client and isElement(client) and ui.pallets[client] and isElement(ui.pallets[client]))then
                setPedAnimation(client, "CARRY", "crry_prtial", 4.1, true, true)

                local index=1
                if(ui.boxes[client])then
                    index=#ui.boxes[client]+1
                else
                    ui.boxes[client]={}
                end
            
                ui.boxes[client][index]=createObject(id,0,0,0)
                exports.pAttach:attachElementToBone(ui.boxes[client][index], client, 2, 0, 0.5, 0.45, 90, 0, 0)
                setElementData(ui.boxes[client][index], "box_shader", case)
                setElementCollisionsEnabled(ui.boxes[client][index], false)
            end
        end, 1000, 1, client)
    end
end)

addEvent("set.box", true)
addEventHandler("set.box", resourceRoot, function()
    if(ui.boxes[client])then
        local id=#ui.boxes[client]
        if(ui.boxes[client][id])then
            setPedAnimation(client, "CARRY", "liftup", 1.0, false, false, false, true)

            setTimer(function(client)
                if(client and isElement(client) and ui.boxes[client] and ui.boxes[client][id] and isElement(ui.boxes[client][id]))then
                    setPedAnimation(client, "CARRY", "crry_prtial", 4.1, true, true)
                    exports.pAttach:attachElementToBone(ui.boxes[client][id], client, 2, 0, 0.5, 0.45, 90, 0, 0)
                end
            end, 1000, 1, client)
        end
    end
end)

addEvent("case.box", true)
addEventHandler("case.box", resourceRoot, function(forklift)
    if(forklift and ui.pallets[client] and isElement(ui.pallets[client]) and getPedOccupiedVehicle(client) == ui.pallets[client])then
        local id=#ui.boxes[client]
        if(ui.boxes[client][id])then
            checkAndDestroy(ui.boxes[client][id])
            ui.boxes[client][id]=nil

            quests:updateQuest(client, "Przenieś 20 paczek w pracy magazyniera", 1)
            --exports.px_easter:getEasterQuest(client, "Magazyn", 1)
        end
    else
        if(ui.boxes[client])then
            local id=#ui.boxes[client]
            if(ui.boxes[client][id])then
                setPedAnimation(client, "CARRY", "putdwn", 1.0, false, false, false, true)

                setTimer(function(client)
                    if(client and isElement(client) and ui.boxes[client] and ui.boxes[client][id] and isElement(ui.boxes[client][id]))then
                        setPedAnimation(client, "CARRY", "liftup", 0.0, false, false, false, false)

                        checkAndDestroy(ui.boxes[client][id])
                        ui.boxes[client][id]=nil

                        if(#ui.boxes[client] < 1)then
                            reverseJob(client)
                        end

                        quests:updateQuest(client, "Przenieś 20 paczek w pracy magazyniera", 1)
                        --exports.px_easter:getEasterQuest(client, "Magazyn", 1)
                    end
                end, 1000, 1, client)
            end
        end
    end
end)

local positions={
    [3006]={
        {-0.22,0,0.35},
        {0.22,0,0.35},
        {-0.22,-0.45,0.35},
        {0.22,-0.45,0.35},
    },

    [3005]={
        {0,0,0.4},
        {0,-0.51,0.4},
        {0,0,0.4+0.51},
        {0,-0.51,0.4+0.51},
    }
}

addEvent("attach.box", true)
addEventHandler("attach.box", resourceRoot, function(boxID)
    local veh=ui.pallets[client]
    if(veh and isElement(veh) and ui.boxes[client] and type(ui.boxes[client]) == "table" and #ui.boxes[client] > 0)then
        id=#ui.boxes[client] or 1

        local box=ui.boxes[client][id]
        if(box and isElement(box))then
            setPedAnimation(client, "CARRY", "putdwn", 1.0, false, false, false, true)
            setTimer(function(client)
                if(client and isElement(client) and box and isElement(box))then
                    setPedAnimation(client, "CARRY", "liftup", 0.0, false, false, false, false)
                    exports.pAttach:detachElementFromBone(box)

                    local pos=positions[boxID][id] or positions[boxID][id]
                    if(pos)then
                        attachElements(box,veh,unpack(pos))
                        setElementCollisionsEnabled(box, false)
                    end
                end
            end, 1000, 1, client)
        end
    end
end)

addEventHandler("onVehicleStartEnter", resourceRoot, function() cancelEvent() end)
addEventHandler("onVehicleStartExit", resourceRoot, function(plr) stopJob(plr) cancelEvent() end)

addEventHandler("onPlayerQuit", root, function()
    stopJob(source)
end)