--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local FIX={}

FIX.objects={}

-- triggers

addEvent("send.offer", true)
addEventHandler("send.offer", resourceRoot, function(target, veh, rabat)
    if(target and isElement(target))then
        triggerClientEvent(target, "send.offer", resourceRoot, veh, client, rabat)
    end
end)

addEvent("notis", true)
addEventHandler("notis", resourceRoot, function(text, target, parts, veh, cost, giveCost)
    noti = exports.px_noti

    if(target and isElement(target))then
        exports.px_noti:noti(text, target)
    end
end)

addEvent("start.tuning", true)
addEventHandler("start.tuning", resourceRoot, function(target, parts, veh, cost, giveCost)
    triggerClientEvent(target, "start.tuning", resourceRoot, client, parts, veh, cost, giveCost)
    exports.px_noti:noti("Zaczekaj aż tuner zakończy montaż/demontaż.", client)
    setElementFrozen(veh, true)
end)

function isVehicleUpgraded(theVehicle, upgrade)
	if not (isElement(theVehicle) and getElementType(theVehicle) == "vehicle") then return end
	if not (upgrade and type(upgrade) == "number") then return end
	for slot=0, 16 do
		local upgradeSlot = getVehicleUpgradeOnSlot(theVehicle, slot)
		if (upgradeSlot) and (upgradeSlot == upgrade) then
			return true
		end
	end
	return false
end

addEvent("update.tuning", true)
addEventHandler("update.tuning", resourceRoot, function(target, parts, veh, cost, giveCost)
    local id=getElementData(veh, "vehicle:id")
    if(not id)then return end

    local wheels_data=getElementData(veh, "vehicle:wheelsSettings") or {}
    local myMoney=getPlayerMoney(target)
    if(myMoney >= cost)then
        local error=false
        for i,v in pairs(parts) do
            if(v.demontaz and not isVehicleUpgraded(veh,v.id_czesci))then
                error=true
                break
            end
        end

        if(not error)then
            local upgrades={}
            if(id)then
                local r=exports['px_connect']:query('select tuning from vehicles where id=? limit 1', id)
                if(r and #r == 1)then
                    upgrades=split(r[1].tuning,',') or {}
                end
            elseif(group_id)then
                local r=exports['px_connect']:query('select tuning from groups_vehicles where id=? limit 1', id)
                if(r and #r == 1)then
                    upgrades=split(r[1].tuning,',') or {}
                end
            end

            toggleControl(target, 'accelerate', true)
            toggleControl(target, 'enter_exit', true)
            toggleControl(target, 'brake_reverse', true)
            toggleControl(target, 'forwards', true)
            toggleControl(target, 'backwards', true)
            toggleControl(target, 'left', true)
            toggleControl(target, 'right', true)

            if(cost > 0)then
                takePlayerMoney(target, cost)
            end
            if(giveCost > 0)then
                givePlayerMoney(target, giveCost)
            end

            if(cost > 0 and giveCost > 0)then
                exports.px_noti:noti("Tuning został zapisany. Koszt wyniósł: "..cost.."$, otrzymano: "..giveCost.."$ z demontażu.", target)
            elseif(cost > 0)then
                exports.px_noti:noti("Tuning został zapisany. Koszt wyniósł: "..cost.."$.", target)
            elseif(giveCost > 0)then
                exports.px_noti:noti("Tuning został zapisany. Otrzymano: "..giveCost.."$ z demontażu.", target)
            end

            local tune=''
            local zarobek=0
            for i,v in pairs(parts) do
                zarobek=zarobek+v.discount
        
                if(v.kategoria == "Tires" and not v.demontaz)then
                    wheels_data.tire=v.id
                    tune=tune..", montaz opony "..v.id
                else
                    if(v.demontaz)then
                        removeVehicleUpgrade(veh, v.id_czesci)
                        upgrades=removeFromTable(upgrades, v.id_czesci)
                        tune=tune..", demontaz "..v.id_czesci
                    else
                        addVehicleUpgrade(veh, v.id_czesci)
                        upgrades[#upgrades+1]=v.id_czesci
                        tune=tune..", montaz "..v.id_czesci
                    end
                end
            end
            exports.px_admin:addTuningLogs(client,veh,cost,tune)

            if(zarobek > 0)then
                givePlayerMoney(client, tonumber(zarobek))

                local data=getElementData(client, "user:job_settings")
                if(data)then
                    data.money=(data.money or 0)+tonumber(zarobek)
                    setElementData(client, "user:job_settings", data)
                end
            end

            local pos={getElementPosition(client)}
            triggerClientEvent("playSound", resourceRoot, pos)
            triggerClientEvent(target, "cancel.offer", resourceRoot)

            exports.px_noti:noti(getPlayerName(target).." przyjął oferte. Pomyślnie zapisano tuning.", client)

            setElementData(veh, "vehicle:wheelsSettings", false)
            if(not wheels_data.tire)then wheels_data.tire=1 end
            setElementData(veh, "vehicle:wheelsSettings", wheels_data)

            setElementFrozen(veh, false)

            if(id)then
                exports.px_connect:query("update vehicles set tuning=? where id=? limit 1", table.concat(upgrades,',') or '', id)
            elseif(group_id)then
                exports.px_connect:query("update groups_vehicles set tuning=? where id=? limit 1", table.concat(upgrades,',') or '', group_id)
            end

            if(not exports.px_achievements:isPlayerHaveAchievement(target, "Tuner"))then
                exports.px_achievements:getAchievement(target, "Tuner")
            end
        else
            exports.px_noti:noti("[BŁĄD] Twój pojazd nie posiada takich części.", client, "error")
        end
    else
        exports.px_noti:noti("Nie posiadasz wystarczających funduszy.", target)
        exports.px_noti:noti(getPlayerName(target).." nie posiada wystarczających funduszy.", client)

        setElementFrozen(veh, false)

        toggleControl(target, 'accelerate', true)
        toggleControl(target, 'enter_exit', true)
        toggleControl(target, 'brake_reverse', true)
        toggleControl(target, 'forwards', true)
        toggleControl(target, 'backwards', true)
        toggleControl(target, 'left', true)
        toggleControl(target, 'right', true)

        triggerClientEvent(target, "cancel.offer", resourceRoot)
    end
end)

addEvent("create.object", true)
addEventHandler("create.object", resourceRoot, function()
    FIX.objects[client]=createObject(3963, 0, 0, 0)
    exports.pAttach:attachElementToBone(FIX.objects[client], client, 25, 0, -0.1, -0.05, 0, 270, 0)    
    setElementCollisionsEnabled(FIX.objects[client], false)
end)

addEvent("destroy.object", true)
addEventHandler("destroy.object", resourceRoot, function()
    if(FIX.objects[client] and isElement(FIX.objects[client]))then
        destroyElement(FIX.objects[client])
        FIX.objects[client]=nil
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if(FIX.objects[source] and isElement(FIX.objects[source]))then
        destroyElement(FIX.objects[source])
        FIX.objects[source]=nil
    end
end)

addEvent("animation", true)
addEventHandler("animation", resourceRoot, function(type)
    if(type)then
        setPedAnimation(client, "COP_AMBIENT", "Copbrowse_nod", -1, true, false)  
    else
        setPedAnimation(client, false)
    end
end)

-- useful

function removeFromTable(t, value)
	for i,v in pairs(t) do
		if(tonumber(v) == tonumber(value))then
			table.remove(t,i)
			break
		end
	end
	return t
end