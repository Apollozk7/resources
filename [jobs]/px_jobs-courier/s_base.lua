--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

ui.vehicles={}
ui.boxes={}
ui.vehBoxes={}

ui.randomRespawns={
    {2822.9480,978.8315,10.8061,179.9255},
    {2827.4321,978.5888,10.8009,179.9894},
    {2806.5342,978.8044,10.7984,180.1865},
    {2802.0620,979.0686,10.7960,181.4573},
}

ui.boxsPositions={
    ["Rumpo"]={
        ["normal"]={
            {-0.5,0.2,0},
            {-0.05,0.2,0},
            {0.4,0.2,0},
            {-0.5,-0.25,0},
            {-0.05,-0.25,0},
            {0.4,-0.25,0},
            {-0.5,-0.7,0},
            {-0.05,-0.7,0},
            {0.4,-0.7,0},
            {-0.5,0.1,0.45},
            {-0.05,0.1,0.45},
            {0.4,0.1,0.45},
            {-0.5,-0.35,0.45},
            {-0.05,-0.35,0.45},
            {0.4,-0.35,0.45},
            {-0.5,-0.8,0.45},
            {-0.05,-0.8,0.45},
            {0.4,-0.8,0.45},
            {-0.5,0.1,0.9},
            {-0.05,0.1,0.9},
            {0.4,0.1,0.9},
            {-0.5,-0.35,0.9},
            {-0.05,-0.35,0.9},
            {0.4,-0.35,0.9},
            {-0.5,-0.8,0.9},
            {-0.05,-0.8,0.9},
            {0.4,-0.8,0.9},
        },

        ["big"]={
            {-0.4,0.1,0.1},
            {0.4,0.1,0.1},
            {-0.4,-0.42,0.1},
            {0.4,-0.42,0.1},
            {-0.4,0.1,0.61},
            {0.4,0.1,0.61},
            {-0.4,-0.42,0.61},
            {0.4,-0.42,0.61},
            {0,-0.95,0.1},
            {0,-1.47,0.1},
            {0,-2,0.1},
            {0,-0.95,0.61},
            {0,-1.47,0.61},
            {0,-2,0.61},
        }
    },

    ["Pony"]={
        ["normal"]={
            {-0.5,0.2,-0.04},
            {-0.05,0.2,-0.04},
            {0.4,0.2,-0.04},
            {-0.5,-0.25,-0.04},
            {-0.05,-0.25,-0.04},
            {0.4,-0.25,-0.04},
            {-0.5,-0.7,-0.04},
            {-0.05,-0.7,-0.04},
            {0.4,-0.7,-0.04},
            {-0.5,0.2,0.41},
            {-0.05,0.2,0.41},
            {0.4,0.2,0.41},
            {-0.5,-0.25,0.41},
            {-0.05,-0.25,0.41},
            {0.4,-0.25,0.41},
            {-0.5,-0.7,0.41},
            {-0.05,-0.7,0.41},
            {0.4,-0.7,0.41},
        },

        ["big"]={
            {-0.4,0.1,0},
            {0.4,0.1,0},
            {-0.4,-0.42,0},
            {0.4,-0.42,0},
            {-0.4,0.1,0.51},
            {0.4,0.1,0.51},
            {-0.4,-0.42,0.51},
            {0.4,-0.42,0.51},
            {0,-0.95,0},
            {0,-1.47,0},
            {0,-2,0},
            {0,-0.95,0.51},
            {0,-1.47,0.51},
            {0,-2,0.51},
        }
    },

    ["Boxville"]={
        ["normal"]={
            {-0.5,0.45,0},
            {-0.05,0.45,0},
            {0.4,0.45,0},
            {-0.5,0,0},
            {-0.05,0,0},
            {0.4,0,0},
            {-0.5,-0.45,0},
            {-0.05,-0.45,0},
            {0.4,-0.45,0},
            {-0.5,0.35,0.45},
            {-0.05,0.35,0.45},
            {0.4,0.35,0.45},
            {-0.5,-0.1,0.45},
            {-0.05,-0.1,0.45},
            {0.4,-0.1,0.45},
            {-0.5,-0.55,0.45},
            {-0.05,-0.55,0.45},
            {0.4,-0.55,0.45},
            {-0.5,0.35,0.9},
            {-0.05,0.35,0.9},
            {0.4,0.35,0.9},
            {-0.5,-0.1,0.9},
            {-0.05,-0.1,0.9},
            {0.4,-0.1,0.9},
            {-0.5,-0.55,0.9},
            {-0.05,-0.55,0.9},
            {0.4,-0.55,0.9},
        },

        ["big"]={
            {-0.4,0.1,0},
            {0.4,0.1,0},
            {-0.4,-0.42,0},
            {0.4,-0.42,0},
            {-0.4,0.1,0.51},
            {0.4,0.1,0.51},
            {-0.4,-0.42,0.51},
            {0.4,-0.42,0.51},
            {0,-0.95,0},
            {0,-1.47,0},
            {0,-2,0},
            {0,-0.95,0.51},
            {0,-1.47,0.51},
            {0,-2,0.51},
        }
    },

    ["Newsvan"]={
        ["normal"]={
            {-0.5,0.2,-0.1},
            {-0.05,0.2,-0.1},
            {0.4,0.2,-0.1},
            {-0.5,-0.25,-0.1},
            {-0.05,-0.25,-0.1},
            {0.4,-0.25,-0.1},
            {-0.5,-0.7,-0.1},
            {-0.05,-0.7,-0.1},
            {0.4,-0.7,-0.1},
            {-0.5,0.2,0.45-0.1},
            {-0.05,0.2,0.45-0.1},
            {0.4,0.2,0.45-0.1},
            {-0.5,-0.25,0.45-0.1},
            {-0.05,-0.25,0.45-0.1},
            {0.4,-0.25,0.45-0.1},
            {-0.5,-0.7,0.45-0.1},
            {-0.05,-0.7,0.45-0.1},
            {0.4,-0.7,0.45-0.1},
            {-0.5,0.2,0.9-0.1},
            {-0.05,0.2,0.9-0.1},
            {0.4,0.2,0.9-0.1},
            {-0.5,-0.25,0.9-0.1},
            {-0.05,-0.25,0.9-0.1},
            {0.4,-0.25,0.9-0.1},
            {-0.5,-0.7,0.9-0.1},
            {-0.05,-0.7,0.9-0.1},
            {0.4,-0.7,0.9-0.1},
        },

        ["big"]={
            {-0.4,0.1,0.1-0.35},
            {0.4,0.1,0.1-0.35},
            {-0.4,-0.42,0.1-0.35},
            {0.4,-0.42,0.1-0.35},
            {-0.4,0.1,0.61-0.35},
            {0.4,0.1,0.61-0.35},
            {-0.4,-0.42,0.61-0.35},
            {0.4,-0.42,0.61-0.35},
            {0,-0.95,0.1-0.35},
            {0,-1.47,0.1-0.35},
            {0,-2,0.1-0.35},
            {0,-0.95,0.61-0.35},
            {0,-1.47,0.61-0.35},
            {0,-2,0.61-0.35},
            {0,-2,0.77},
        }
    },
}

ui.addVehicleBox=function(player, boxID, data, id, boxes)
    local veh=ui.vehicles[player]
    if(not veh or (veh and not isElement(veh)))then return end

    local pos=ui.boxsPositions[getVehicleName(veh)]
    if(pos)then pos=boxID == 3006 and pos["normal"] or pos["big"] else return end

    if(not ui.vehBoxes[veh])then
        ui.vehBoxes[veh]={}
    end

    if(ui.vehBoxes[veh][id])then return end

    ui.vehBoxes[veh][id]=createObject(boxID, 0, 0, 0)
    setElementData(ui.vehBoxes[veh][id], "box_shader", data)
    setElementCollisionsEnabled(ui.vehBoxes[veh][id], false)

    local x,y,z=unpack(pos[(boxes-id)+1])
    if(x and y and z)then
        attachElements(ui.vehBoxes[veh][id], veh, x, y, z)
    else
        attachElements(ui.vehBoxes[veh][id], veh, 0, 0, 0)
    end
end

ui.getBoxes=function(player)
    if(not ui.boxes[player])then return false end

    local have=false
    for i,v in pairs(ui.boxes[player]) do
        if(getElementAttachedTo(v) == player)then
            have=true
            break
        end
    end
    return have
end

function startJob(player, info, _, _, privateVehicle)
    info.upgrades=fromJSON(info.upgrades) or {}

    if(privateVehicle)then
        ui.vehicles[player]=privateVehicle
    else
        local vehName="pony"
        if(info.upgrades["Speedo"])then
            vehName="newsvan"
        elseif(info.upgrades["Boxville"])then
            vehName="boxville"
        end

        local rnd=math.random(1,#ui.randomRespawns)
        ui.vehicles[player]=createVehicle(getVehicleModelFromName(vehName), ui.randomRespawns[rnd][1], ui.randomRespawns[rnd][2], ui.randomRespawns[rnd][3], 0, 0, ui.randomRespawns[rnd][4])
        setVehicleColor(ui.vehicles[player], 255,255,255,255,255,255,0,100,200)

        setElementData(ui.vehicles[player], "vehicle:fuelTank", 75)
        setElementData(ui.vehicles[player], "vehicle:fuel", 75)
    end

    setElementFrozen(ui.vehicles[player], true)

    -- dors
    addComponent(ui.vehicles[player],"Drzwi otworzone")
    addComponent(ui.vehicles[player],"GOPostal")

    setVehicleDoorOpenRatio(ui.vehicles[player], 4, 1, 500)
    setVehicleDoorOpenRatio(ui.vehicles[player], 5, 1, 500)
    --

    exports.px_noti:noti("Udaj się po paczkę na taśmę.", player, "info")

    triggerClientEvent(player, "start.job", resourceRoot, ui.vehicles[player], info)
end

function stopJob(player)
    if(player and isElement(player))then
        local job=getElementData(player, "user:job")
        if(job == "Kurier")then
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

            local vehBoxes=ui.vehBoxes[ui.vehicles[player]]
            if(vehBoxes)then
                for i,v in pairs(vehBoxes) do
                    checkAndDestroy(v)
                end
                vehBoxes=nil
            end

            if(isElement(ui.vehicles[player]) and not getElementData(ui.vehicles[player], "vehicle:id"))then
                checkAndDestroy(ui.vehicles[player])
            end
            ui.vehicles[player]=nil

            local skin=getElementData(player, "save:skin")
            if(skin)then
                setElementModel(player, skin)
                setElementData(player, "save:skin", false)
            end
        end
    end
end
addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, stopJob)

function reverseJob(player)
    exports.px_jobs_settings:getPayment(player)

    triggerClientEvent(player, "stop.job", resourceRoot, true)
    triggerClientEvent(player, "start.job", resourceRoot, ui.vehicles[player])
end
addEvent("reverse.job", true)
addEventHandler("reverse.job", resourceRoot, reverseJob)

addEvent("get.box", true)
addEventHandler("get.box", resourceRoot, function(id, index, attach, data)
    local veh=ui.vehicles[client]

    setPedAnimation(client, "CARRY", "liftup", 1.0, false, false, false, true, 250, true)

    toggleControl(client, "enter_exit", false)
    setTimer(function(client)
        if(client and isElement(client))then
            setPedAnimation(client, "CARRY", "crry_prtial", 4.1, true, true, false, true, 250, true)
            toggleControl(client, "enter_exit", true)

            if(not ui.boxes[client])then
                ui.boxes[client]={}
            end

            if(ui.boxes[client][index])then return end
        
            ui.boxes[client][index]=createObject(id,0,0,0)
            setElementCollisionsEnabled(ui.boxes[client][index], false)
            exports.pAttach:attachElementToBone(ui.boxes[client][index], client, 2, 0, 0.5, 0.45, 90, 0, 0)
            setElementData(ui.boxes[client][index], "box_shader", data)

            triggerClientEvent(client, 'back.get.box', resourceRoot)

            if(attach and veh)then
                local t=ui.vehBoxes[veh]
                if(t and t[index])then
                    checkAndDestroy(t[index])
                    t[index]=nil
                    if(#t < 1)then
                        t=nil
                    end
                end
            end
        end
    end, 1000, 1, client)
end)

addEvent("destroy.box", true)
addEventHandler("destroy.box", resourceRoot, function(attach, id, boxes)
    if(ui.boxes[client] and ui.boxes[client][id])then
        setPedAnimation(client, "CARRY", "putdwn", 1.0, false, false, false, true, 250, true)

        toggleControl(client, "enter_exit", false)
        setTimer(function(client)
            if(client and isElement(client) and ui.boxes[client][id] and isElement(ui.boxes[client][id]))then
                toggleControl(client, "enter_exit", true)

                setPedAnimation(client, "CARRY", "liftup", 0.0, false, false, false, false, 250, true)

                if(attach)then
                    ui.addVehicleBox(client,getElementModel(ui.boxes[client][id]),getElementData(ui.boxes[client][id],"box_shader"),id,boxes)
                end

                checkAndDestroy(ui.boxes[client][id])
                ui.boxes[client][id]=nil

                if(#ui.boxes[client] < 1)then
                    ui.boxes[client]=nil
                end
            end
        end, 1000, 1, client)
    end
end)

addEvent("get.payment", true)
addEventHandler("get.payment", resourceRoot, function()
    exports.px_jobs_settings:getPayment(client)

    local org=getElementData(client, "user:organization")
    if(org)then
        exports.px_organizations:updateOrganizationTask(org, "addFromJob_Courier", 1)
    end

    exports.px_quests:updateQuest(client, "Przekaż 20 paczek w pracy kuriera", 1)
end)

addEvent("warp.vehicle", true)
addEventHandler("warp.vehicle", resourceRoot, function()
    local player=client
    if(ui.vehicles[player] and isElement(ui.vehicles[player]))then
        warpPedIntoVehicle(player,ui.vehicles[player])
    end
end)

-- events

addEventHandler("onVehicleEnter", root, function(player)
    if(ui.vehicles[player] and isElement(ui.vehicles[player]) and ui.vehicles[player] == source)then
        removeComponent(ui.vehicles[player],"Drzwi otworzone")
        addComponent(ui.vehicles[player],"Drzwi zamknięte")

        setVehicleDoorOpenRatio(ui.vehicles[player], 4, 0, 500)
        setVehicleDoorOpenRatio(ui.vehicles[player], 5, 0, 500)

        setElementFrozen(source, false)

        triggerClientEvent(player, "door.state", resourceRoot, "close", source)
    end
end)

addEventHandler("onVehicleExit", root, function(player)
    if(ui.vehicles[player] and isElement(ui.vehicles[player]) and ui.vehicles[player] == source)then
        addComponent(ui.vehicles[player],"Drzwi otworzone")
        removeComponent(ui.vehicles[player],"Drzwi zamknięte")

        setVehicleDoorOpenRatio(ui.vehicles[player], 4, 1, 500)
        setVehicleDoorOpenRatio(ui.vehicles[player], 5, 1, 500)

        setElementFrozen(source, true)

        triggerClientEvent(player, "door.state", resourceRoot, "open", source)
    end
end)

addEventHandler("onVehicleStartEnter", resourceRoot, function(player, seat)
    if(not ui.vehicles[player])then
        cancelEvent()
    end
end)

addEventHandler("onVehicleStartEnter", root, function(player, seat)
    if((ui.vehicles[player] and ui.vehicles[player] ~= source) or (ui.boxes[player] and table.size(ui.boxes[player]) > 0))then
        cancelEvent()
    end
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

addEventHandler("onPlayerQuit", root, function()
    stopJob(source)
end)

-- useful

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end

table.size=function(t)
    local x=0; for i,v in pairs(t) do x=x+1; end; return x;
end

function addComponent(vehicle,name)
    local components=getElementData(vehicle, "vehicle:components") or {}
    components[#components+1]=name
    setElementData(vehicle, "vehicle:components", components)
end

function removeComponent(vehicle,name)
    local components=getElementData(vehicle, "vehicle:components") or {}
    for i,v in pairs(components) do
        if(v == name)then
            components[i]=nil
        end
    end
    setElementData(vehicle, "vehicle:components", components)
end