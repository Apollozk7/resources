--[[
    @author: CrosRoad95, psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- koguty

local sirens={
    objects={},

    ["SAPD"]={
        [426]={-0.6,0,0.95},
        [541]={-0.45,0,0.75},
        [415]={-0.4,-0.1,0.68},
        [560]={-0.6,0.2,0.95},
    },

    ["SARA"]={
        [498]={-0.5,1,1.37},
        [400]={-0.4,0,0.95},
        [426]={-0.6,0,0.95},
        [413]={-0.5,0.7,1.25},
    },

    colors={
        ["SAPD"]={0,0,255},
        ["SARA"]={255,200,0},
    }
}

function setSiren(vehicle)
    local data=getElementData(vehicle, "vehicle:group_owner")
    if(data and sirens[data])then
        if(sirens.objects[vehicle])then
            checkAndDestroy(sirens.objects[vehicle].object)
            checkAndDestroy(sirens.objects[vehicle].marker)

            if(isTimer(sirens.objects[vehicle].timer))then
                killTimer(sirens.objects[vehicle].timer)
            end

            sirens.objects[vehicle]=nil

            setElementData(vehicle, "haveSiren", false)
        else
            local pos=sirens[data][getElementModel(vehicle)]
            if(pos)then
                local color=sirens.colors[data]
                if(color)then
                    sirens.objects[vehicle]={
                        object=createObject(1337, 0, 0, 0),
                        marker=createMarker(0,0,0,"corona",0.3,color[1],color[2],color[3],100),
                    }

                    sirens.objects[vehicle].timer=setTimer(function()
                        if(getElementAlpha(sirens.objects[vehicle].marker) == 100)then
                            setElementAlpha(sirens.objects[vehicle].marker, 0)
                        else
                            setElementAlpha(sirens.objects[vehicle].marker, 100)
                        end
                    end, 300, 0)

                    setElementData(sirens.objects[vehicle].object, "custom_name", "kogut_"..data)
                    attachElements(sirens.objects[vehicle].object, vehicle, unpack(pos))
                    attachElements(sirens.objects[vehicle].marker, vehicle, pos[1], pos[2], pos[3]-0.1)
                    setElementCollisionsEnabled(sirens.objects[vehicle].object, false)

                    setElementData(vehicle, "haveSiren", true)
                end
            end
        end
    end
end

addEventHandler("onElementDestroy", root, function()
    if(sirens.objects[source])then
        checkAndDestroy(sirens.objects[source].object)
        checkAndDestroy(sirens.objects[source].marker)
        if(isTimer(sirens.objects[source].timer))then
            killTimer(sirens.objects[source].timer)
        end
        sirens.objects[source]=nil
    end
end)

--

--

function getVehicleHandlingProperty ( element, property )
    if isElement ( element ) and getElementType ( element ) == "vehicle" and type ( property ) == "string" then
        local handlingTable = getVehicleHandling ( element )
        local value = handlingTable[property]

        if value then
            return value
        end
    end

    return false
end

--

local tick = {}

local noti = exports.px_noti
local core = exports.px_core
local achievements=exports.px_achievements

addEvent("hydraulic.regulation", true)
addEventHandler("hydraulic.regulation", resourceRoot, function(state)
    local veh = getPedOccupiedVehicle(client)
    if(not veh)then return end

    local max=6 -- najwyzej
    local min=state -- najnizej
    min=min-1

    local maxHand=-0.3
    local minHand=-0.03

    local hand=(maxHand-minHand)
    hand=hand*(min/max)
    hand=hand+minHand

    setVehicleHandling(veh, "suspensionLowerLimit", hand)
end)

local pops={
    ["Euros"]="Open Your Eyes",
    ["Cheetah"]="Otwierane Lampy",
}

addEvent("interaction.action", true)
addEventHandler("interaction.action", resourceRoot, function(selected, nick, speed)
    local veh = getPedOccupiedVehicle(client)
    if(not veh)then return end

    if(selected == 'asr')then
        if(getElementData(veh, 'vehicle:asrOFF'))then
            setElementData(veh, 'vehicle:asrOFF', false)

            local hand=getOriginalHandling(getElementModel(veh))
            setVehicleHandling(veh, "tractionLoss", hand.tractionLoss)
        else
            setElementData(veh, 'vehicle:asrOFF', true)

            local hand=getOriginalHandling(getElementModel(veh))
            setVehicleHandling(veh, "tractionLoss", hand.tractionLoss*0.7)
        end
    elseif(selected == "kogut")then
        setSiren(veh)
    elseif(selected == 'lights_back')then
        local data=getElementData(veh, "vehicle:components") or {}

        local list={
            'lewo',
            'prawo',
            'stop'
        }

        local have=false
        for id,component in ipairs(list) do
            for i,v in pairs(data) do
                if(v == component)then
                    have={id=id,component_id=i}
                    break
                end
            end
        end

        local c=list[1]
        if(have)then
            local new=list[have['id']+1]
            if(not new)then
                c=false
            else
                c=new
            end

            data[have['component_id']]=nil
        end

        if(c)then
            data['sara_up']='sara_up'
            data[#data+1]=c
        else
            data['sara_up']=nil
        end

        setElementData(veh, "vehicle:components", data)
    elseif(selected == "multiLED")then
        local lights=getElementData(veh, "vehicle:lights")
        if(lights and lights < 1)then
            noti:noti("Żarówki w twoim pojeździe się spaliły.", client, "error")
            setVehicleHeadLightColor(veh, 0, 0, 0)
            setElementData(veh, "vehicle:multiLED", false)
            setElementData(veh, "vehicle:lights", false)
        elseif(lights)then
            setVehicleHeadLightColor(veh, nick[2], nick[3], nick[4])
        end
    elseif(selected == 2)then
        local data=getElementData(veh, "vehicle:components") or {"Podstawowe"}
        if(getVehicleOverrideLights(veh) == 2)then
            setVehicleOverrideLights(veh, 1)

            local popName=pops[getVehicleName(veh)]
            if(popName)then
                local pop=false
                for i,v in pairs(data) do
                    if(v == popName)then
                        pop=true
                        break
                    end
                end

                if(pop)then
                    data["interaction_lights"]="lights_turnoff"
                    setElementData(veh, "vehicle:components", data)
                end
            end
        else
            setVehicleOverrideLights(veh, 2)

            local popName=pops[getVehicleName(veh)]
            if(popName)then
                local pop=false
                for i,v in pairs(data) do
                    if(v == popName)then
                        pop=true
                        break
                    end
                end

                if(pop)then
                    data["interaction_lights"]="lights_turnon"
                    setElementData(veh, "vehicle:components", data)
                end
            end
        end

        triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "swiatla")
    elseif(selected == 1)then
        if(getVehicleEngineState(veh) == true)then
            setVehicleEngineState(veh, false)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()

                local text = getVehicleEngineState(veh) ~= true and "gasi" or "odpala"
                core:outputChatWithDistance(client, text.." silnik w pojeździe "..getVehicleName(veh)..".", 5)
            end
        else
            local dist=getElementData(veh, "vehicle:distance") or 0
            if(dist > 300000 and dist < 320000)then
                local x=(dist > 300000 and dist < 305000) and 2 or (dist > 305000 and dist < 310000) and 3 or (dist > 315000 and dist < 320000) and 4
                local rnd=math.random(1,x)
                if(rnd ~= 2)then
                    noti:noti("Nie udało się odpalić silnika w pojeździe z powodu dużego przebiegu.", client)
                    triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "silnik_fail")
                    return
                end
            elseif(dist >= 320000)then
                noti:noti("Nie udało się odpalić silnika w pojeździe z powodu dużego przebiegu.", client)
                triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "silnik_fail")
                return
            end

            local health=getElementHealth(veh)
            if(health > 300 and health < 325)then
                local rnd=math.random(1,10)
                if(rnd ~= 5)then
                    noti:noti("Nie udało się odpalić silnika w pojeździe.", client)
                    triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "silnik_fail")
                    return
                end
            elseif(health > 325 and health < 350)then
                local rnd=math.random(1,7)
                if(rnd ~= 3)then
                    noti:noti("Nie udało się odpalić silnika w pojeździe.", client)
                    triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "silnik_fail")
                    return
                end
            elseif(health > 350 and health < 400)then
                local rnd=math.random(1,4)
                if(rnd ~= 2)then
                    noti:noti("Nie udało się odpalić silnika w pojeździe.", client)
                    triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "silnik_fail")
                    return
                end
            elseif(health > 400 and health < 500)then
                local rnd=math.random(1,2)
                if(rnd ~= 2)then
                    noti:noti("Nie udało się odpalić silnika w pojeździe.", client)
                    triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "silnik_fail")
                    return
                end
            end

            setVehicleEngineState(veh, true)

            triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "silnik")

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()

                local text = getVehicleEngineState(veh) ~= true and "gasi" or "odpala"
                core:outputChatWithDistance(client, text.." silnik w pojeździe "..getVehicleName(veh)..".", 5)
            end
        end
    elseif(selected == 3)then
        if(getElementData(veh, "vehicle:handbrake"))then
			setControlState(client, "handbrake", false)
			setElementData(veh, "vehicle:handbrake", false)
			setElementFrozen(veh, false)
            exports.px_stock_vehicles:setGhost(veh, true)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()

                core:outputChatWithDistance(client, "spuszcza hamulec ręczny w pojeździe "..getVehicleName(veh)..".", 5)
            end

            triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "reczny")
		else
            if(getElementData(client, "user:job"))then
                noti:noti("Nie możesz zaciągnąć ręcznego w tym pojeździe.", client)
                return
            end

            if(speed > 100)then
                local rnd=math.random(1,4)
                local s={getVehicleWheelStates(veh)}
                if(rnd == 1)then
                    setVehicleWheelStates(veh, 3, s[2], s[3], s[4])
                elseif(rnd == 2)then
                    setVehicleWheelStates(veh, s[1], 3, s[3], s[4])
                elseif(rnd == 3)then
                    setVehicleWheelStates(veh, s[1], s[2], 3, s[4])
                elseif(rnd == 4)then
                    setVehicleWheelStates(veh, s[1], s[2], s[3], 3)
                end

                if(not achievements:isPlayerHaveAchievement(client, "Hamulce awaryjne"))then
                    achievements:getAchievement(client, "Hamulce awaryjne")
                end
            end

			setControlState(client, "handbrake", true)
			setElementData(veh, "vehicle:handbrake", true)
            exports.px_stock_vehicles:setGhost(veh, false)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()

                core:outputChatWithDistance(client, "zaciąga hamulec ręczny w pojeździe "..getVehicleName(veh)..".", 5)
            end

            triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "reczny")
        end
    elseif(selected == "wyrzuc")then
        local occupants = getVehicleOccupants(veh)
        if(nick ~= "Wszyscy")then
            for i,v in pairs(occupants) do
                if(getPlayerName(v) == nick)then
                    occupants={}
                    occupants[1]=v
                end
            end
        end

        for i,v in pairs(occupants) do
            if v and isElement(v) and v ~= client and getElementType(v) == "player" then
                setControlState(v, "enter_exit", true)
                setTimer(function()
                    setControlState(v, "enter_exit", false)
                end, 200, 1)

                if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                    tick[client] = getTickCount()

                    core:outputChatWithDistance(client, "wysadza pasażerów z pojazdu "..getVehicleName(veh)..".", 5)
                end
            end
        end
    elseif(selected == 4)then
        if isVehicleLocked(veh) == true then
            setVehicleLocked(veh, false)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()

                core:outputChatWithDistance(client, "otwiera zamek w pojeździe "..getVehicleName(veh)..".", 5)
            end
        else
            for i = 0,5 do
                setVehicleDoorOpenRatio(veh, i, 0, 2500)
            end

            setVehicleLocked(veh, true)

            local data=getElementData(veh, "vehicle:components") or {"Podstawowe"}
            for i,v in pairs(data) do
                if(v == "Drzwi otworzone" or v == "Drzwi zamknięte")then
                    data[i]=nil
                end
            end
            data[#data+1]="Drzwi zamknięte"
            setElementData(veh, "vehicle:components", data)

            local music=getElementData(veh, "vehicle:stereo_music")
            if(music)then
                music.volume=0.1
                setElementData(veh, "vehicle:stereo_music", music)
            end

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()

                core:outputChatWithDistance(client, "zamyka zamek w pojeździe "..getVehicleName(veh)..".", 5)
            end
        end
        triggerClientEvent("playSound", resourceRoot, {getElementPosition(veh)}, "zamek")
    elseif(selected == 6)then
        if(getVehicleDoorOpenRatio(veh, 1) == 0)then
            setVehicleDoorOpenRatio(veh, 1, 1, 2500)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            core:outputChatWithDistance(client, "otwiera bagażnik w pojeździe "..getVehicleName(veh)..".", 5)
        else
            setVehicleDoorOpenRatio(veh, 1, 0, 2500)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            core:outputChatWithDistance(client, "zamyka bagażnik w pojeździe "..getVehicleName(veh)..".", 5)
        end
    elseif(selected == 7)then
        if(getVehicleDoorOpenRatio(veh, 0) == 0)then
            setVehicleDoorOpenRatio(veh, 0, 1, 2500)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            core:outputChatWithDistance(client, "otwiera maske w pojeździe "..getVehicleName(veh)..".", 5)
        else
            setVehicleDoorOpenRatio(veh, 0, 0, 2500)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            core:outputChatWithDistance(client, "zamyka maske w pojeździe "..getVehicleName(veh)..".", 5)
        end
    end
end)

addEventHandler("onVehicleEnter", root, function(player, seat)
	if(seat ~= 0)then return end

	if(getElementData(source, "vehicle:handbrake"))then
		setControlState(player, "handbrake", true)
		setElementFrozen(source, false)
    end

    if(getVehicleName(source) == "Bike" or getVehicleName(source) == "BMX" or getVehicleName(source) == "Mountain Bike" or getVehicleName(source) == "Faggio" or getVehicleName(source) == "Rhino")then
		setElementData(source, "vehicle:handbrake", false)
        setControlState(player, "handbrake", false)
        setVehicleEngineState(source, true)
    else
        setVehicleEngineState(source, false)
	end
end)

addEventHandler("onVehicleExit", root, function(player, seat)
    if(not isElement(source))then return end
    setVehicleDoorOpenRatio(source, 2+seat, 0, 1000)

    if(seat ~= 0)then return end

	if(getElementData(source, "vehicle:handbrake"))then
		setControlState(player, "handbrake", false)
		setElementFrozen(source, true)
    end

    setVehicleLocked(source, false)
end)

addEventHandler("onVehicleDamage", root, function(loss)
    if(loss > 200)then
        setVehicleEngineState(source, false)
    end
end)

function checkAndDestroy(element)
    if element and isElement(element) then
        destroyElement(element); element = nil

        return true
    else
        return false
    end
end