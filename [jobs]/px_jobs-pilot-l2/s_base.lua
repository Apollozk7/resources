--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

local noti=exports.px_noti
local jobs=exports.px_jobs_settings

ui.respawnVehicles={
    {1581.4713,1464.5000,11.2973,0,0,90.4344},
    {1581.9285,1430.5127,11.2985,0,0,90.3038},
}

ui.vehicles={}

function startJob(player, info, reverse)
    info.upgrades=fromJSON(info.upgrades) or {}

    local rnd=math.random(1,#ui.respawnVehicles)
    ui.vehicles[player]=createVehicle(512, unpack(ui.respawnVehicles[rnd]))

    triggerClientEvent(player, "start.job", resourceRoot, info, ui.vehicles[player])

    local tank=info.upgrades["Jakościowy Oprysk + Bak 75L"] and 75 or info.upgrades["Jakościowy Oprysk + Bak 50L"] and 50 or 25
    setElementData(ui.vehicles[player], "vehicle:fuel", 1)
    setElementData(ui.vehicles[player], "vehicle:fuelTank", tank)
end

function stopJob(player, reverse)
    if(player and isElement(player))then
        local job=getElementData(player, "user:job")
        if(job == "Oprysk samolotem")then
            triggerClientEvent(player, "stop.job", resourceRoot)

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
    triggerClientEvent(player, "stop.job", resourceRoot, true)
    triggerClientEvent(player, "start.job", resourceRoot)
end
addEvent("reverse.job", true)
addEventHandler("reverse.job", resourceRoot, reverseJob)

addEventHandler("onVehicleStartEnter", resourceRoot, function(player, seat)
    if(seat ~= 0)then return end

    if(not ui.vehicles[player] or (ui.vehicles[player] and ui.vehicles[player] ~= source))then
        cancelEvent()
        noti:noti("Ten pojazd nie należy do Ciebie i nie posiadasz uprawnień aby go kierować.", player, "error")
    end
end)

addEventHandler("onVehicleEnter", resourceRoot, function(player, seat)
    if(seat ~= 0)then return end

    if(ui.vehicles[player] and ui.vehicles[player] == source)then
        triggerClientEvent(player, "destroy.veh.blip", resourceRoot)
    end
end)

addEventHandler("onVehicleExit", resourceRoot, function(player, seat)
    if(seat ~= 0)then return end

    if(ui.vehicles[player] and ui.vehicles[player] == source)then
        stopJob(player)
    end
end)

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

addEvent("get.payment", true)
addEventHandler("get.payment", resourceRoot, function()
    jobs:getPayment(client)
end)

-- useful

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end