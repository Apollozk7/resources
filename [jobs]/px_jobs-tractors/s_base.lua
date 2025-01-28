--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local ui={}

ui.vehicles={}
ui.tractors={}

ui.colors={
    {78,13,11,98,20,20},
    {90,33,16,112,45,22},
    {80,47,12,108,65,19},
    {117,92,15,146,118,31},
    {105,110,13,147,154,38},
    {70,100,15,100,140,30},
    {23,66,6,39,90,19},
    {40,112,12,64,140,35},
    {10,117,48,36,143,74},
    {7,85,64,17,104,80},
    {10,140,106,42,172,137},
    {20,125,125,43,150,150},
    {15,70,90,25,85,105},
    {15,55,95,25,72,115},
    {12,79,142,24,90,155},
    {11,50,125,21,64,143},
    {13,30,100,20,40,120},
    {43,57,118,54,70,132},
    {45,35,90,55,45,108},
    {20,10,70,25,15,85},
    {45,15,85,50,18,95},
    {56,8,86,68,14,103},
    {63,8,70,75,13,84},
    {74,10,65,85,13,74},
    {88,10,52,101,17,62},
    {83,12,41,92,16,47},
    {87,9,31,107,13,40},
    {90,10,10,110,17,17},
    {20,20,20,34,34,34},
}

ui.tractorsPos={
    {pos={-1079.2212,-1097.3595,129.1992,178.7643},col={-1080.72888, -1109.45642, 128.23561, 2.941650390625, 15.527954101562, 5.4763397216797}},
    {pos={-1075.6281,-1141.8246,129.2009,1.8336},col={-1076.99426, -1144.74329, 128.23561, 3.13818359375, 15.350341796875, 5.8831390380859}},
    {pos={-1129.7880,-1097.7460,129.2019,181.0683},col={-1131.86609, -1108.79602, 128.23561, 3.490966796875, 14.365234375, 5.3913787841797}},
    {pos={-1070.3374,-1164.5817,129.1990,269.5831},col={-1072.89490, -1166.07349, 128.23561, 13.736694335938, 3.1968994140625, 5.8831390380859}},
}

function startJob(player, info)
    info.upgrades=fromJSON(info.upgrades) or {}

    local rnd=math.random(1,#ui.tractorsPos)
    local pos,col=ui.tractorsPos[rnd].pos,ui.tractorsPos[rnd].col

    ui.vehicles[player]=createVehicle(getVehicleModelFromName("Yankee"), -1120.7028,-1132.1245,129.8057,0,0,322.9780)
    ui.tractors[player]=createVehicle(531, pos[1],pos[2],pos[3],0,0,pos[4])
    setElementData(ui.vehicles[player], "vehicle:offroad", true)
    setElementData(ui.tractors[player], "vehicle:offroad", true)

    local tank=75
    setElementData(ui.vehicles[player], "vehicle:fuel", tank)
    setElementData(ui.vehicles[player], "vehicle:fuelTank", tank)
    setElementData(ui.tractors[player], "vehicle:fuel", tank)
    setElementData(ui.tractors[player], "vehicle:fuelTank", tank)
    setElementData(ui.vehicles[player],"vehicle:components", {"Laweta"})

    setElementFrozen(ui.tractors[player], true)
    setElementData(ui.tractors[player], "vehicle:handbrake", true)

    local rnd=math.random(1,#ui.colors)
    local r,g,b,r2,g2,b2=unpack(ui.colors[rnd])
    setVehicleColor(ui.vehicles[player], r,g,b)
    setVehicleColor(ui.tractors[player], r2,g2,b2)

    warpPedIntoVehicle(player, ui.vehicles[player])

    triggerClientEvent(player, "start.job", resourceRoot, ui.vehicles[player], ui.tractors[player], info.upgrades, col)
end

addEvent("attach.tractor", true)
addEventHandler("attach.tractor", resourceRoot, function()
    local veh=ui.vehicles[client]
    local tractor=ui.tractors[client]
    if(veh and isElement(veh) and tractor and isElement(tractor))then
        attachElements(tractor,veh,0,-1.3,1)
        triggerClientEvent(client, "stop.action", resourceRoot, "spawn.points")
        setElementCollisionsEnabled(tractor,false)
    end
end)

addEvent("detach.tractor", true)
addEventHandler("detach.tractor", resourceRoot, function(pos)
    local veh=ui.vehicles[client]
    local tractor=ui.tractors[client]
    if(veh and isElement(veh) and tractor and isElement(tractor))then
        pos=pos or {getElementPosition(veh)}
        
        detachElements(tractor,veh)
        setElementPosition(tractor,unpack(pos))

        local rx,ry,rz=getElementRotation(veh)
        setElementRotation(tractor,rx,ry,rz)

        triggerClientEvent(client, "stop.action", resourceRoot)
        setElementCollisionsEnabled(tractor,true)

        exports.px_noti:noti("Pamiętaj, aby zacząć usuwać pień możesz poruszać się z maksymalną predkością: 25km/h.", client, "info")
    end
end)

function stopJob(player)
    if(player and isElement(player))then
        local job=getElementData(player, "user:job")
        if(job == "Usuwanie pni")then
            triggerClientEvent(player, "stop.job", resourceRoot)

            setElementData(player, "user:job", false)
            setElementData(player, "user:job_settings", false)

            checkAndDestroy(ui.vehicles[player])
            ui.vehicles[player]=nil

            checkAndDestroy(ui.tractors[player])
            ui.tractors[player]=nil
        end
    end
end
addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, stopJob)

addEvent("get.payment", true)
addEventHandler("get.payment", resourceRoot, function()
    -- exports.px_easter:getEasterQuest(client, "Pniaki", 1)
    exports.px_jobs_settings:getPayment(client)
end)

addEventHandler("onVehicleEnter", resourceRoot, function(player, seat)
    if(seat ~= 0)then return end
    
    if(source == ui.tractors[player] or source == ui.vehicles[player])then
        if(getElementData(source, "vehicle:handbrake"))then
            setElementFrozen(source, false)
            setElementData(source, "vehicle:handbrake", false)
        end
    end
end)

addEventHandler("onVehicleExit", resourceRoot, function(player, seat)
    if(seat ~= 0)then return end
    
    if(source == ui.tractors[player] or source == ui.vehicles[player])then
        if(not getElementData(source, "vehicle:handbrake"))then
            setElementFrozen(source, true)
            setElementData(source, "vehicle:handbrake", true)
        end
    end
end)

addEventHandler("onVehicleStartEnter", resourceRoot, function(player, seat)
    if(ui.tractors[player] and ui.vehicles[player])then
        if(source == ui.tractors[player] or source == ui.vehicles[player])then else
            cancelEvent()
        end
    else
        if(not ui.tractors[player] or not ui.vehicles[player])then
            cancelEvent()
        end
    end
end)

addEventHandler("onVehicleStartEnter", root, function(player, seat)
    if(ui.tractors[player] and ui.vehicles[player])then
        if(source == ui.tractors[player] or source == ui.vehicles[player])then else
            cancelEvent()
        end
    end
end)

addEventHandler("onVehicleDamage", resourceRoot, function(loss)
    local player=getVehicleController(source)
    if(player and isElement(player) and ui.vehicles[player] and ui.tractors[player] and (ui.vehicles[player] == source or ui.tractors[player] == source))then
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

function detachVehicle(theTruck, trailer)
    if (isElement(theTruck) and isElement(trailer)) then
        detachTrailerFromVehicle(theTruck, trailer)
    end
end
addEventHandler("onTrailerAttach", root, function(truck)
    if(getVehicleName(truck) == "Tractor")then
        setTimer(detachVehicle, 50, 1, truck, source)
    end
end)