--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

local noti=exports.px_noti
local jobs=exports.px_jobs_settings
local line3d=exports.px_3dline

ui.respawnVehicles={
    {250.8176,1457.2512,11.2781},
    {243.4111,1457.6909,11.2751},
    {236.0926,1457.6407,11.2751},
    {219.4556,1458.2700,11.2751},
    {212.0818,1458.4631,11.2751},
    {204.6426,1458.9728,11.2751},
}

ui.stations=exports.px_fuel_stations:getDistributorsPositions()

ui.upgrades={
    ["Cysterna 3"]={id=433,level=10000,points=6},
    ["Cysterna 2"]={id=578,level=7500,points=4},
    ["Cysterna 1"]={id=573,level=5000,points=2},
}

ui.offsets={
    [433]={0.83,-4.7,-0.27,0.83,-6,-1.5},
    [578]={0.55,-3.75,0.1,0.5,-5.5,-1.5},
    [573]={0.43,-3.25,-0.1,0.45,-4.2,-1.5},
}

ui.vehicles={}

function startJob(player, info, reverse)
    info.upgrades=fromJSON(info.upgrades) or {}

    local vehicle=ui.upgrades["Cysterna 1"]
    if(info.upgrades["Cysterna 10.000L"])then
        vehicle=ui.upgrades["Cysterna 3"]
    elseif(info.upgrades["Cysterna 7.500L"])then
        vehicle=ui.upgrades["Cysterna 2"]
    end

    local rnd=math.random(1,#ui.respawnVehicles)
    ui.vehicles[player]=createVehicle(vehicle.id, unpack(ui.respawnVehicles[rnd]))
    warpPedIntoVehicle(player, ui.vehicles[player])
    setElementData(ui.vehicles[player], "interaction", {options={
        {name="Wyciągnij wąż", alpha=150, animate=false, tex=":px_jobs-refinery/textures/hose_icon.png"},
    }, scriptName="px_jobs-refinery", dist=5, type="server"})
    setElementData(ui.vehicles[player], "interaction:only", player)

    setVehicleColor(ui.vehicles[player], 242,151,37,28,28,28,28,28,28)
    setVehiclePlateText(ui.vehicles[player], "RAFINERIA")
    setElementData(ui.vehicles[player], "vehicle:components", {"Rafineria"})

    triggerLatentClientEvent(player, "start.job", resourceRoot, info, vehicle.level, ui.stations, ui.vehicles[player], vehicle.points)
end

function stopJob(player, reverse)
    if(player and isElement(player))then
        local job=getElementData(player, "user:job")
        if(job == "Rafineria")then
            triggerLatentClientEvent(player, "stop.job", resourceRoot)

            setElementData(player, "user:job_settings", false)

            if(not reverse)then
                checkAndDestroy(ui.vehicles[player])
                ui.vehicles[player]=nil

                setElementData(player, "user:job", false)
            end
        end
    end
end
addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, stopJob)

function reverseJob(player)
    jobs:getPayment(player)

    triggerLatentClientEvent(player, "stop.job", resourceRoot, true)
    triggerLatentClientEvent(player, "start.job", resourceRoot, false, false, ui.stations)
end
addEvent("reverse.job", true)
addEventHandler("reverse.job", resourceRoot, reverseJob)

addEventHandler("onVehicleStartEnter", resourceRoot, function(player, seat)
    if(seat ~= 0)then return end

    if(line3d:isPlayerHaveLine(player))then return cancelEvent() end

    if(not ui.vehicles[player] or (ui.vehicles[player] and ui.vehicles[player] ~= source))then
        cancelEvent()
        noti:noti("Ten pojazd nie należy do Ciebie i nie posiadasz uprawnień aby go kierować.", player, "error")
    end
end)

addEvent("get.tank", true)
addEventHandler("get.tank", resourceRoot, function()
    local veh=ui.vehicles[client]
    if(veh and isElement(veh))then
        line3d:destroy3dLine(client)

        setElementData(veh, "interaction", {options={
            {name="Wyciągnij wąż", alpha=150, animate=false, tex=":px_jobs-refinery/textures/hose_icon.png"},
        }, scriptName="px_jobs-refinery", dist=5, type="server"})

        setElementFrozen(veh, false)
    end
end)

-- exports

function action(id, vehicle, player, name)
    if(name == "Wyciągnij wąż" and vehicle == ui.vehicles[player])then
        setElementData(vehicle, "interaction", {options={
            {name="Schowaj wąż", alpha=150, animate=false, tex=":px_jobs-refinery/textures/hose_icon.png"},
        }, scriptName="px_jobs-refinery", dist=5, type="server"})

        setElementFrozen(vehicle, true)

        local offset=ui.offsets[getElementModel(vehicle)]
        line3d:create3dLine(player, {getPositionFromElementOffset(vehicle, offset[1], offset[2], offset[3])}, {getPositionFromElementOffset(vehicle, offset[4], offset[5], offset[6])})
    elseif(name == "Schowaj wąż" and vehicle == ui.vehicles[player])then
        setElementData(vehicle, "interaction", {options={
            {name="Wyciągnij wąż", alpha=150, animate=false, tex=":px_jobs-refinery/textures/hose_icon.png"},
        }, scriptName="px_jobs-refinery", dist=5, type="server"})

        setElementFrozen(vehicle, false)

        line3d:destroy3dLine(player)
    end
end

function destroyLine(player)
    local vehicle=ui.vehicles[player]
    if(vehicle and isElement(vehicle))then
        setElementData(vehicle, "interaction", {options={
            {name="Wyciągnij wąż", alpha=150, animate=false, tex=":px_jobs-refinery/textures/hose_icon.png"},
        }, scriptName="px_jobs-refinery", dist=5, type="server"})

        setElementFrozen(vehicle, false)
    end
end

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

function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix(element)
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x,y,z
end

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end

-- koguty

local sirens={
    objects={},

    [573]={
        {-0.9,2.7,1.6},
        {0.9,2.7,1.6},

        {0.45, -3, 1.5},
    },

    [578]={
        {-0.9,2.9,1.4},
        {0.9,2.9,1.4},

        {0.5, -3.4, 1.6},
    },

    [433]={
        {-0.8,3.2,1.2},
        {0.8,3.2,1.2},
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

addEventHandler("onVehicleEnter", resourceRoot, function(plr,seat)
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