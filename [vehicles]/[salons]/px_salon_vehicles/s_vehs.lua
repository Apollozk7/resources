--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

ui={}

ui.nextRespawnTime=60 -- ilosc minutek ;)

ui.vehicles={
    -- doki sf
    --[[['Doki SF']={
        respawn={-1767.0072,-181.9725,3.1789,357.5692},
        respawnTime=(60*24), -- 24 godziny, respi sie jeden pojazd!
        distance={310000,320000},
        allValue=true,

        vehiclesModels={
            {model='Huntley', cost=180000, type='Diesel'},
            {model='Banshee', cost=365000, type='Diesel'},
            {model='Comet', cost=250000, type='Diesel'},
            {model='Elegy', cost=240000, type='Diesel'},
            {model='Super', cost=350000, type='Diesel'},
            {model='ZR-350', cost=190000, type='Diesel'},
            {model='Sandking', cost=220000, type='Diesel'},
        },

        vehicles={
            {pos={-1706.0450,11.9952,3.1195,331.7142},obj=3.5547,tex='info'},
        },
    },]]
    --

    -- cygany
    ["CYGAN LV - 1"]={
        ped={43,781.2653,1952.7396,5.3359,85.2395},
        pedDesc={name="Luigi", desc="Cena i przebieg do ustalenia!"},
        respawn={757.25500488281,1929.8029785156,5.3181548118591,210.87084960938},

        vehicles={
            {pos={778.8975,1944.1670,5.0472,77.3954}, model=getVehicleModelFromName("Club"), value=math.random(2,4), tex="info", obj=5.3359375, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={783.8879,1969.0458,5.1521,91.3823}, model=getVehicleModelFromName("Sunrise"), value=math.random(2,4), tex="info", obj=5.3359375, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={776.8854,1938.2450,5.2512,62.3258}, model=getVehicleModelFromName("Previon"), value=math.random(2,4), tex="info", obj=5.3359375, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={768.0012,1988.7107,5.0312,205.6808}, model=getVehicleModelFromName("Tampa"), value=math.random(2,4), tex="info", obj=5.3359375, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={757.4372,1957.6495,5.4421,275.6829}, model=getVehicleModelFromName("Mesa"), value=math.random(2,4), tex="info", obj=5.3359375, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={758.7040,1966.0970,5.0543,250.7458}, model=getVehicleModelFromName("Blista Compact"), value=math.random(2,4), tex="info", obj=5.3359375, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={782.3459,1962.1851,5.1958,104.0745}, model=getVehicleModelFromName("Vincent"), value=math.random(2,4), tex="info", obj=5.3359375, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={784.7816,1976.4557,5.0603,108.6338}, model=getVehicleModelFromName("Intruder"), value=math.random(2,4), tex="info", obj=5.3359375, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
        }
    },

    ["CYGAN LV - 2"]={
        ped={133,-881.4356,1552.2485,25.9141,90.4264},
        pedDesc={name="Alfred", desc="Mam złom idealny dla Ciebie"},
        respawn={-884.3948,1564.1517,25.6916,56.0789},

        vehicles={
            {pos={-905.1460,1540.8405,25.6364,242.8849}, model=getVehicleModelFromName("Perennial"), value=math.random(20,30), tex="info", obj=25.85, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={-906.6830,1518.0635,26.0081,285.9104}, model=getVehicleModelFromName("Moonbeam"), value=math.random(20,30), tex="info", obj=25.85, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={-883.9417,1543.9062,25.9083,117.4388}, model=getVehicleModelFromName("Walton"), value=math.random(20,30), tex="info", obj=25.85, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={-886.5333,1516.7128,25.5674,65.0455}, model=getVehicleModelFromName("Manana"), value=math.random(20,30), tex="info", obj=25.85, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
            {pos={-884.5023,1528.0419,25.6426,97.3591}, model=getVehicleModelFromName("Picador"), value=math.random(20,30), tex="info", obj=25.85, shit=true, distance=math.random(250000,300000), cost=500, type='Diesel'},
        }
    },

    -- salony
    ["SALON LV - 1"]={
        marker={2220.3596191406,1413.794921875,11.0625},
        ped={17,2223.9562988281,1414.2231445313,11.0625,95.632972717285},
        pedDesc={name="Zygfryd", desc="Mam same szybkie bryki"},
        respawn={2215.7043457031,1420.8977050781,10.478344917297,90.226440429688},
        
        vehicles={
            {pos={2180.2292480469,1400.6092529297,10.795796394348,0}, model=getVehicleModelFromName("Flash"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={2180.1442871094,1412.4409179688,10.795848846436,180.41583251953}, model=getVehicleModelFromName("Sultan"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={2187.6245117188,1412.3973388672,10.797167778015,179.86499023438}, model=getVehicleModelFromName("Uranus"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={2187.5974121094,1400.4074707031,10.796698570251,0}, model=getVehicleModelFromName("Buffalo"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={2197.6335449219,1412.2580566406,10.796974182129,182.04602050781}, model=getVehicleModelFromName("Jester"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={2205.3913574219,1412.7410888672,10.796976089478,180.63024902344}, model=getVehicleModelFromName("Huntley"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={2213.3618164063,1401.0451660156,10.803251266479,0}, model=getVehicleModelFromName("Phoenix"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={2221.2858886719,1400.8968505859,10.80616569519,0}, model=getVehicleModelFromName("Euros"), value=math.random(3,5), cost=500000, type='Petrol'},
        }
    },

    ["SALON LV - 2"]={
        marker={1967.9855957031,2048.2236328125,11.0625,183.70252990723},
        ped={15,1967.9554443359,2045.8725585938,11.0625,3.0129101276398},
        pedDesc={name="Franciszek", desc="W tej cenie nie znajdziesz nic lepszego"},
        respawn={1974.5047607422,2052.6557617188,10.499996185303,180.61706542969},
        
        vehicles={
            {pos={1954.3927001953,2089.5888671875,11.011228561401,270.99615478516}, model=getVehicleModelFromName("Stratum"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={1967.3237304688,2089.5756835938,11.011228561401,89.225219726563}, model=getVehicleModelFromName("Sabre"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={1966.9632568359,2081.5837402344,11.011228561401,87.42041015625}, model=getVehicleModelFromName("Stallion"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={1954.0865478516,2081.9201660156,11.011228561401,268.48577880859}, model=getVehicleModelFromName("Sentinel"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={1967.0443115234,2071.7124023438,11.011228561401,87.488403320313}, model=getVehicleModelFromName("Premier"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={1966.6083984375,2063.8286132813,11.011228561401,88.261901855469}, model=getVehicleModelFromName("Admiral"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={1954.1538085938,2056.0979003906,11.011228561401,270.29052734375}, model=getVehicleModelFromName("Fortune"), value=math.random(3,5), cost=500000, type='Petrol'},
            {pos={1954.0399169922,2048.4541015625,11.011228561401,269.51696777344}, model=getVehicleModelFromName("Feltzer"), value=math.random(3,5), cost=500000, type='Petrol'},
        }
    },
}

-- functions

ui.setRandomShitVehicle=function(veh)
    for i=1,4 do
        setVehicleDoorState(veh, i, math.random(0,4))
    end

    for i=0,6 do
        setVehiclePanelState(veh, i, math.random(1,3))
    end

    local states={math.random(0,3),0,math.random(0,3),0}
    setVehicleWheelStates(veh, unpack(states))

    setElementHealth(veh, math.random(350,1000))
end

ui.createVehicle=function(class, id, lastModel)
    local t=ui.vehicles[class]
    if(not t)then return false end

    local last_t=t
    t=t.vehicles[id]

    if(not t)then return false end

    checkAndDestroy(t.vehicle)
    checkAndDestroy(t.object)

    if((not t.model or lastModel) and last_t.vehiclesModels)then
        local rnd=math.random(1,#last_t.vehiclesModels)
        if(lastModel and lastModel == last_t.vehiclesModels[rnd].model)then
            while(true)do
                rnd=math.random(1,#last_t.vehiclesModels)
                if(lastModel ~= last_t.vehiclesModels[rnd].model)then
                    break
                end
            end
        end

        local tbl=last_t.vehiclesModels[rnd]
        if(tbl)then
            t.model=getVehicleModelFromName(tbl.model)
            t.cost=tbl.cost
            t.value=1
            t.type=tbl.type
            t.distance=math.random(last_t.distance[1],last_t.distance[2])
        else
            return false
        end
    end

    t.vehicle=createVehicle(t.model, t.pos[1], t.pos[2], t.pos[3], 0, 0, t.pos[4])
    setElementData(t.vehicle, 'vehicle:components', t.components)

    local r,g,b=math.random(0,255), math.random(0,255), math.random(0,255)
    setTimer(function()
        if(t.vehicle and isElement(t.vehicle))then
            setElementFrozen(t.vehicle, true)    
        end
    end, 100,1)
    setElementData(t.vehicle, "ghost", true)
    setVehicleColor(t.vehicle, r,g,b,r,g,b,r,g,b,r,g,b)

    -- variables
    t.bak=25
    t.fuel=5
    t.type=t.type or last_t.type
    t.respawn=last_t.respawn
    t.distance=t.distance or math.random(50,200)
    --

    if(not last_t.marker)then
        setElementData(t.vehicle, "interaction", {options={
            {name="Jazda testowa", alpha=150, animate=false, tex=":px_salon_vehicles/textures/car_drive.png"},
            {name="Zakup pojazd", alpha=150, animate=false, tex=":px_salon_vehicles/textures/car_buy.png"},
        }, scriptName="px_salon_vehicles", dist=5})
    else
        setElementData(last_t.markerElement, "vehs", last_t.vehicles)
    end

    if(t.obj)then
        local x,y,z=getRightPosition(t.vehicle, 1.5, 3)
        local _,_,rz=getElementRotation(t.vehicle)
        t.object=createObject(961, x, y, t.obj-0.5, 0, 0, rz)
        setElementCollisionsEnabled(t.object, false)
    end

    if(t.shit)then
        ui.setRandomShitVehicle(t.vehicle)
        t.fuel=5
    end

    setElementData(t.vehicle, "salon:data", {
        class=class,
        id=id,
        info=t,
        object=t.object,
    })
end

-- on start

ui.createVehicles=function()
    for name,v in pairs(ui.vehicles) do
        outputDebugString("[px_salon_vehicles] Tworze pojazdy w: "..name)

        -- ped
        if(v.ped)then
            local ped=createPed(unpack(v.ped))
            setElementData(ped, "ped:desc", v.pedDesc)
            setElementFrozen(ped, true)
            setElementData(ped, "ghost", "all")
        end
        --

        -- marker
        if(v.marker)then
            v.markerElement=createMarker(v.marker[1], v.marker[2], v.marker[3], "cylinder", 1.2, 255, 0, 255)
            setElementData(v.markerElement, "icon", ":px_salon_vehicles/textures/icon.png")
            setElementData(v.markerElement, "vehs", v.vehicles)
            setElementData(v.markerElement, "text", {text="Kupno pojazdu", desc="Tutaj zobaczysz ofertę salonu"})
        end
        --

        -- vehs
        for id,vehicle in pairs(v.vehicles) do
            ui.createVehicle(name, id)
        end
        --
    end
end
setTimer(ui.createVehicles, 500, 1)

-- test drive


ui.testVehicles={}
addEvent("create.testDrive", true)
addEventHandler("create.testDrive", resourceRoot, function(info, vehicle)
    if(not exports.px_vehicles:isPlayerHavePJ(client, getElementModel(vehicle)))then return end

    local pos = {getElementPosition(vehicle)}
    local rotation = {getElementRotation(vehicle)}
    local color = {getVehicleColor(vehicle, true)}

    if(info.respawn)then
        pos={info.respawn[1],info.respawn[2],info.respawn[3]}
        rotation={0,0,info.respawn[4]}
    end

    ui.testVehicles[client]=createVehicle(info.model, pos[1], pos[2], pos[3], rotation[1], rotation[2], rotation[3])
    setElementData(ui.testVehicles[client], 'vehicle:components', info.components)

    setVehicleColor(ui.testVehicles[client], unpack(color))
    exports.px_custom_vehicles:setVehicleDefaultHandling(ui.testVehicles[client])

    warpPedIntoVehicle(client, ui.testVehicles[client])

    setElementData(client, "default:pos", {getElementPosition(client)}, false)
    setElementData(ui.testVehicles[client], "ghost", true)

    triggerClientEvent(client, "start.testDrive", resourceRoot)

    -- shit parts
    for i = 0,6 do
        local s=getVehiclePanelState(vehicle, i)
        setVehiclePanelState(ui.testVehicles[client], i, s)
    end

    for i = 1,4 do
        local s=getVehicleDoorState(vehicle, i)
        setVehicleDoorState(ui.testVehicles[client], i, s)
    end

    setElementHealth(ui.testVehicles[client], getElementHealth(vehicle))
    --
end)

addEvent("stop.testDrive", true)
addEventHandler("stop.testDrive", resourceRoot, function()
    if(ui.testVehicles[client])then
        if(isElement(ui.testVehicles[client]))then
            destroyElement(ui.testVehicles[client])
        end
        ui.testVehicles[client]=nil
    end

    local controller=client
    setTimer(function()
        local pos=getElementData(controller, "default:pos")
        if(pos)then
            setElementPosition(controller, unpack(pos))
            removeElementData(controller, "default:pos")
        end
    end, 100, 1)
end)

addEventHandler("onVehicleStartExit", resourceRoot, function(player, seat)
    if(seat ~= 0)then return end

    if(ui.testVehicles[player])then
        if(isElement(ui.testVehicles[player]))then
            destroyElement(ui.testVehicles[player])
        end
        ui.testVehicles[player]=nil

        triggerClientEvent(player, "stop.testDrive", resourceRoot)

        setTimer(function()
            local pos=getElementData(player, "default:pos")
            if(pos)then
                setElementPosition(player, unpack(pos))
                removeElementData(player, "default:pos")
            end
        end, 100, 1)
    end
end)

addEventHandler("onElementDestroy", resourceRoot, function()
    if(getElementType(source) ~= "vehicle")then return end

    local controller=getVehicleController(source)
    if(ui.testVehicles[controller])then
        ui.testVehicles[controller]=nil

        triggerClientEvent(controller, "stop.testDrive", resourceRoot)

        setTimer(function()
            local pos=getElementData(controller, "default:pos")
            if(pos)then
                setElementPosition(controller, unpack(pos))
                removeElementData(controller, "default:pos")
            end
        end, 100, 1)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if(ui.testVehicles[source])then
        if(isElement(ui.testVehicles[source]))then
            destroyElement(ui.testVehicles[source])
        end
        ui.testVehicles[source]=nil
    end
end)

-- buy vehicle

addEvent("buy:veh", true)
addEventHandler("buy:veh", resourceRoot, function(name, distance, cost, vehicle, id, info, color_)
    if(vehicle and isElement(vehicle))then
        if(not exports.px_vehicles:isPlayerHavePJ(client, getElementModel(vehicle)))then return end

        local getFree,have,slots=exports.px_vehicles:getPlayerFreeVehicleSlot(client)
        if(getFree)then
            if(getPlayerMoney(client) >= cost)then
                local data=getElementData(vehicle, "salon:data")
                if(not data)then return end

                local t_1=ui.vehicles[data.class]
                if(not t_1)then return end
            
                local t_2=t_1.vehicles[data.id]
                if(not t_2)then return end

                local pos = {getElementPosition(vehicle)}
                local color = color_ or {getVehicleColor(vehicle, true)}
                local rotation = {getElementRotation(vehicle)}

                if(info.respawn)then
                    pos={info.respawn[1],info.respawn[2],info.respawn[3]}
                    rotation={0,0,info.respawn[4]}
                end

                takePlayerMoney(client, cost)

                local owner = getElementData(client, "user:uid")
                local ownerName = getPlayerName(client)

                local panelState,doorState,wheelState,health={},{},{getVehicleWheelStates(vehicle)},getElementHealth(vehicle)
                -- shit parts
                for i = 0,6 do
                    local s=getVehiclePanelState(vehicle, i)
                    panelState[#panelState+1]=s
                end

                for i = 1,4 do
                    local s=getVehicleDoorState(vehicle, i)
                    doorState[#doorState+1]=s
                end
                --

                local v_id=exports.px_vehicles:addNewVehicle(true, client, getVehicleModelFromName(name), pos, rotation, owner, ownerName, distance, info.fuel, info.bak, info.type, color, false, false, false, panelState, doorState, wheelState, health, info.engine or 0, info.components)
                v_id=v_id or 0

                local get=exports.px_achievements:isPlayerHaveAchievement(client,"Pierwszy pojazd")
                if(not get)then
                    exports.px_achievements:getAchievement(client,"Pierwszy pojazd")
                end

                exports.px_noti:noti("Zakupiłeś pojazd "..name.." za cene "..convertNumber(cost).."$", client)

                exports.px_admin:addLogs("vehicles", "Kupno pojazdu "..name.." [ID: "..v_id.."] za "..convertNumber(cost).."$", client, "buy")
                exports.px_discord:sendDiscordLogs("[SALON] Kupno pojazdu "..name.." [ID: "..v_id.."] za "..convertNumber(cost).."$", "wymiany", client)
                exports.px_discord:sendDiscordLogs("[SALON] Kupno pojazdu "..name.." [ID: "..v_id.."] za "..convertNumber(cost).."$", "hajs", client)

                if(not exports.px_achievements:isPlayerHaveAchievement(client, "Własny pojazd"))then
                    exports.px_achievements:getAchievement(client, "Własny pojazd")
                end

                -- respawn
                checkAndDestroy(data.info.vehicle)
                checkAndDestroy(data.info.object)

                if(not t_1.allValue)then
                    t_2.value=t_2.value-1

                    if(t_2.value >= 1)then
                        setTimer(function()
                            ui.createVehicle(data.class, data.id)
                        end, (1000*60)*ui.nextRespawnTime, 1)
                    end
                else
                    setTimer(function()
                        ui.createVehicle(data.class, data.id, name)
                    end, (1000*60)*t_1.respawnTime, 1)
                end
                --
            else
                exports.px_noti:noti("Nie stać Cię na zakup tego pojazdu.", client)
            end
        else
            exports.px_noti:noti("Posiadasz już maksymalną ilość pojazdów: "..math.floor(have or 0).."/"..math.floor(slots or 0)..".", client, "error")
        end
    end
end)

-- on hit

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    local vehs=getElementData(source, "vehs")
    if(vehs)then
        triggerClientEvent(hit, "show.buy", resourceRoot, vehs)
    end
end)

-- utilits

addEventHandler("onVehicleStartEnter", resourceRoot, function()
    cancelEvent()
end)

-- useful

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
        element=nil
        return true
    end
    return false
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function getRightPosition(element, plus1, plus2)
    local x,y,z = getElementPosition(element)
    local _,_,rot = getElementRotation(element)

    local cx, cy = getPointFromDistanceRotation(x, y, (plus1 or 0), (-(rot+90)))
    local cx2, cy2 = getPointFromDistanceRotation(x, y, (plus2 or 0), (-(rot)))
    cx2=cx2-cx
    cy2=cy2-cy
    x,y=x+cx2,y+cy2

    return x,y,z
end

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end