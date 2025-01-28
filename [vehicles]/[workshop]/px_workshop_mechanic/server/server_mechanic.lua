--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

-- functions

function repair(veh, part)
    if(part == -1)then
        setElementHealth(veh, 1000)
    elseif(part >= 0 and part < 10)then
        setVehiclePanelState(veh, part, 0)
    elseif(part >= 10 and part < 20)then
        local drzwi = part-10
        setVehicleDoorState(veh, drzwi, 0)
    elseif(part >= 20)then
        local swiatlo = part-20
        setVehicleLightState(veh, swiatlo, 0)
    end
end

-- triggers

addEvent("send.offer", true)
addEventHandler("send.offer", resourceRoot, function(target, veh, rabat)
    if(target and isElement(target))then
        local parts=fillVehicleData(veh,rabat)
        triggerClientEvent(target, "send.offer", resourceRoot, veh, client, rabat, parts)
    end
end)

addEvent("send.offer.info", true)
addEventHandler("send.offer.info", resourceRoot, function(text, target, parts, cost)
    if(target and isElement(target))then
        exports.px_noti:noti(text, target)

        if(parts)then
            cost=math.floor(cost)
            if(getPlayerMoney(client) >= cost)then
                takePlayerMoney(client, tonumber(cost))
                triggerClientEvent(target, "fix.vehicle", resourceRoot, client, parts)

                toggleControl(client, 'accelerate', false)
                toggleControl(client, 'enter_exit', false)
                toggleControl(client, 'brake_reverse', false)
                toggleControl(client, 'forwards', false)
                toggleControl(client, 'backwards', false)
                toggleControl(client, 'left', false)
                toggleControl(client, 'right', false)
            end
        end
    end
end)

addEvent("fix.vehicle", true)
addEventHandler("fix.vehicle", resourceRoot, function(veh, id, target, cost, discount)
    discount=discount or 0
    if(id)then
        repair(veh, id)
    end
    
    if(target and isElement(target))then
        -- controller
        exports.px_noti:noti("Twój pojazd został pomyślnie naprawiony.", target, "success")
        triggerClientEvent(target, "cancel.offer", resourceRoot)

        toggleControl(target, 'accelerate', true)
        toggleControl(target, 'enter_exit', true)
        toggleControl(target, 'brake_reverse', true)
        toggleControl(target, 'forwards', true)
        toggleControl(target, 'backwards', true)
        toggleControl(target, 'left', true)
        toggleControl(target, 'right', true)
    end

    if(veh and (cost and cost > 0))then
        -- mechanic
        exports.px_noti:noti("Za naprawę auta "..getVehicleName(veh).." otrzymujesz "..tonumber(discount).."$.", client, "success")
        givePlayerMoney(client, tonumber(discount))

        local data=getElementData(client, "user:job_settings")
        if(data)then
            data.money=(data.money or 0)+tonumber(discount)
            setElementData(client, "user:job_settings", data)
        end
    end
end)

addEvent("back.money", true)
addEventHandler("back.money", resourceRoot, function(target, cost)
    if(target and isElement(target) and cost and cost > 0)then
        givePlayerMoney(target, tonumber(cost))
    end
end)

addEvent("playSound", true)
addEventHandler("playSound", resourceRoot, function(pos)
    triggerClientEvent("playSound", resourceRoot, pos)
end)

addEvent("animation", true)
addEventHandler("animation", resourceRoot, function(type)
    if(type)then
        setPedAnimation(client, "COP_AMBIENT", "Copbrowse_nod", -1, true, false)
    else
        setPedAnimation(client, false)
    end
end)
