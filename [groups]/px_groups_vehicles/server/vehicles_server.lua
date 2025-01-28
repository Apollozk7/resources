--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local VEH = {}

Async:setPriority("medium")

VEH.objects={}
VEH.taxiPos={
	["Sultan"]=0.78,
	["Premier"]=0.8,
	["Stafford"]=1,
	["Washington"]=0.65,
	["Cabbie"]=0.74,
	["Admiral"]=0.78,
	["Elegant"]=0.74,
	["Sentinel"]=0.7,
	["Huntley"]=1.18,
	["Landstalker"]=0.77,
}

VEH.createNewVehicle = function(id, warp, purchase)
	export=exports.px_custom_vehicles

	local load = VEH.loadVehicle(id, purchase)
	if(load)then
		for i,v in pairs(load) do
			if(not v.position)then v.position=toJSON({0,0,0,0,0,0}) end

            local position = fromJSON(v.position) or {0,0,0,0,0,0}
			local vehicle = createVehicle(v.model, unpack(position))
            if(vehicle and isElement(vehicle))then
                local color = fromJSON(v.color) or {255,255,255,255,255,255}
                local lightColor = fromJSON(v.lightColor) or {255,255,255}
                local tuning = fromJSON(v.tuning) or {}
                local panelState = fromJSON(v.panelState) or {}
				local doorState = fromJSON(v.doorState) or {}
				local wheelState=fromJSON(v.wheelState) or {0,0,0,0}

				setElementFrozen(vehicle, true)
				setElementData(vehicle, "vehicle:handbrake", true)

                setVehicleColor(vehicle, unpack(color))
                setVehicleHeadLightColor(vehicle, unpack(lightColor))

				if(#v.plateText > 0)then
                	setVehiclePlateText(vehicle, v.plateText)
				else
					if(v.type == "organization")then
						local tag=exports.px_connect:query("select tag,ranks from groups_organizations where org=? limit 1", v.owner)
						if(tag and #tag > 0)then
							local ranks=fromJSON(tag[1].ranks) or {}
							if(ranks[1] and ranks[1].name)then
								local lider=exports.px_connect:query("select login,uid from groups_organizations_players where `rank`=? and org=? limit 1", ranks[1].name, v.owner)
								if(lider and #lider == 1)then
									setElementData(vehicle, "vehicle:liderName", lider[1].login)
									setElementData(vehicle, "vehicle:liderUID", lider[1].uid)
								end

								if(tonumber(v.orgRank) == 0)then
									exports.px_connect:query("update groups_vehicles set orgRank=? where id=? limit 1", #ranks, v.id)
									v.orgRank=#ranks
								end
							end

							setVehiclePlateText(vehicle, tag[1].tag.."-"..v.id)
						else
							setVehiclePlateText(vehicle, "ORG-"..v.id)
						end
					else
						local faction=v.ownerName == "SAPD" and "SAPD" or v.ownerName == "SACC" and "SACC" or v.ownerName == "SARA" and "SARA" or v.ownerName == "PSP" and "PSP" or "WYPO"
						setVehiclePlateText(vehicle, faction.."-"..v.id)
					end
				end

				setElementHealth(vehicle, v.health)

                for i,v in pairs(panelState) do
                    i = i - 1
                    setVehiclePanelState(vehicle, i, tonumber(v))
                end

                for i,v in pairs(doorState) do
                    i = i - 1
                    setVehicleDoorState(vehicle, i, tonumber(v))
                end

				setVehicleWheelStates(vehicle, unpack(wheelState))

                setElementData(vehicle, "vehicle:group_owner", v.owner)
                setElementData(vehicle, "vehicle:group_ownerName", v.ownerName)
                setElementData(vehicle, "vehicle:group_id", v.id)
                setElementData(vehicle, "vehicle:distance", v.distance)

				setElementID(vehicle, "px_groups_vehicles_id:"..v.id)

				-- wheels
				if(v.wheelSettings)then
					setElementData(vehicle, "vehicle:wheelsSettings", fromJSON(v.wheelSettings) or false)
				end
				--

				-- dirt
				setElementData(vehicle, "vehicle:dirt", tonumber(v.dirtSettings) or 1)
				--

				-- components
				local components=split(v.components, ',')
				if(#components > 0)then
					setElementData(vehicle, "vehicle:components", components)
				end
				--

				-- plates
				local plate=fromJSON(v.plateColor) or {}
				if(#plate == 3)then
					setElementData(vehicle, "vehicle:plateColor", plate)
				end
				--

				-- safe
				setElementData(vehicle, "element:safe", fromJSON(v.safe) or {})
				--

				v.fuelType=#v.fuelType < 0 and "Petrol" or v.fuelType
				setElementData(vehicle, "vehicle:fuel", v.fuel)
                setElementData(vehicle, "vehicle:fuelType", v.fuelType)
				setElementData(vehicle, "vehicle:actualFuelType", (v.fuelType == "LPG" and "Petrol" or v.fuelType))
                if v.fuelType == "LPG" then
                    setElementData(vehicle, "vehicle:gas", v.gas)
                end

                setElementData(vehicle, "vehicle:fuelTank", v.fuelTank)

				v.lastDrivers=#v.lastDrivers < 1 and "[[]]" or v.lastDrivers
				setElementData(vehicle, "vehicle:lastDrivers", fromJSON(v.lastDrivers))

				exports.px_blips:createBlipAttachedVehicle(v.id)

				-- upgrades
				for i,v in pairs(tuning) do
                    addVehicleUpgrade(vehicle, tonumber(v))
				end
				--

				VEH.reloadVehicleMechanicalUpgrades(vehicle)

				if(warp)then
					warpPedIntoVehicle(warp, vehicle)
				end

				if(v.owner == "SACC")then
					local z=VEH.taxiPos[getVehicleNameFromModel(v.model)] or 0.8
					VEH.objects[vehicle]={
						createObject(1876,0,0,0),
						createMarker(0,0,0,"corona",0.1,255,150,0,100),
						createMarker(0,0,0,"corona",0.1,255,150,0,100),
					}
					attachElements(VEH.objects[vehicle][1],vehicle,0,0,z)
					attachElements(VEH.objects[vehicle][2],vehicle,-0.23,0,z+0.05)
					attachElements(VEH.objects[vehicle][3],vehicle,0.23,0,z+0.05)
				end
			
				setElementData(vehicle, "vehicle:roleAccess", v.access)
				if(v.orgRank)then
					setElementData(vehicle, "vehicle:orgRank", v.orgRank)
				end

				if(getVehicleNameFromModel(v.model) == "Pony")then
					local data=getElementData(vehicle, "vehicle:components") or {"Podstawowe"}
					data[#data+1]="Drzwi zamknięte"
					data[#data+1]="Głośniki JGL"
					setElementData(vehicle, "vehicle:components", data)
				end

				if(v.kryptonim)then
					setElementData(vehicle,"vehicle:kryptonim",v.kryptonim)
				end

                return vehicle
            end
        end
        return false
    end
    return false
end

VEH.saveVehicle = function(vehicle, action)
    if(vehicle and isElement(vehicle))then
		local id = getElementData(vehicle, "vehicle:group_id")
		if(not id)then return end

		local q=exports.px_connect:query("select * from groups_vehicles where id=? limit 1", id)
		if(not q or (q and not q[1]))then return false end

		local x,y,z=getElementPosition(vehicle)
		local rx,ry,rz=getElementRotation(vehicle)
		local color = {getVehicleColor(vehicle, true)} or {0,0,0,0,0,0}
		local lightColor = {getVehicleHeadLightColor(vehicle)} or {255,255,255}
		local panelState = {0,0,0,0,0,0,0}
		local doorState = {0,0,0,0,0,0}
		local health = getElementHealth(vehicle)
		local distance = getElementData(vehicle, "vehicle:distance") or 0
		local fuel = getElementData(vehicle, "vehicle:fuel") or 0
		local gas = getElementData(vehicle, "vehicle:gas") or 0
		local lastDrivers = getElementData(vehicle, "vehicle:lastDrivers") or {}
		local position={x,y,z,rx,ry,rz}
		local wheelState={getVehicleWheelStates(vehicle)}
		local plateColor=getElementData(vehicle, "vehicle:plateColor") or {}
		local dirt=getElementData(vehicle, "vehicle:dirt") or 1
		local safe=getElementData(vehicle, "element:safe") or {}
		local multiLED=getElementData(vehicle, "vehicle:multiLED") and 1 or false
		local speedoType=getElementData(vehicle, "vehicle:speedoType")
		local wheels=getElementData(vehicle, "vehicle:wheelsSettings") or {}
	
		local mech=fromJSON(q[1].mechanicTuning) or {}
		if(speedoType)then
			mech["speedoType"]=speedoType
		end
		if(multiLED)then
			mech["multiLED"]=multiLED
		end

		for i = 1,7 do
			panelState[i] = getVehiclePanelState(vehicle, (i - 1))
		end

		for i = 1,6 do
			doorState[i] = getVehicleDoorState(vehicle, (i - 1))
		end

		local query = exports.px_connect:query(
			[[update groups_vehicles set 

				position=?, 
				color=?, 
				lightColor=?, 
				panelState=?, 
				doorState=?, 
				health=?, 
				distance=?, 
				fuel=?, 
				gas=?, 
				lastDrivers=?, 
				safe=?, 
				wheelState=?, 
				dirtSettings=?, 
				plateColor=?,
				mechanicTuning=?,
				wheelSettings=?

			where id=? limit 1]], 

			toJSON(position), 
			toJSON(color), 
			toJSON(lightColor), 
			toJSON(panelState), 
			toJSON(doorState), 
			health, 
			distance, 
			fuel, 
			gas, 
			toJSON(lastDrivers), 
			toJSON(safe), 
			toJSON(wheelState), 
			toJSON(dirt), 
			toJSON(plateColor), 
			toJSON(mech),
			toJSON(wheels),
			id
		)

		if(query)then
			if(action == "destroy")then
				destroyElement(vehicle)
			end
			return true
        end
		saveVehicle(vehicle,action)
        return false
    end
	saveVehicle(vehicle,action)
    return false
end

VEH.loadVehicle = function(id)
	local result = exports.px_connect:query("select * from groups_vehicles where id=? and parking=0", id)
    if(result and #result > 0)then
        return result
    end
    return false
end

VEH.loadAllVehicles = function()
	local result = exports.px_connect:query("select * from groups_vehicles where parking=0")
	Async:foreach(result, function(v)
		VEH.createNewVehicle(v.id)
	end)
end

VEH.saveAllVehicles = function()
	for i,v in pairs(getElementsByType("vehicle", resourceRoot)) do
		VEH.saveVehicle(v)
	end
end

VEH.addNewVehicle = function(create, warp, model, position, rotation, owner, ownerName, distance, fuel, fuelTank, fuelType, color, tune, wheel, lightColor, panelState, doorState, wheelState, health, engine, type, components)
	position={position[1], position[2], position[3], rotation[1], rotation[2], rotation[3]}
	wheel=wheel or {1,255,255,255}
	lightColor=lightColor or {255,255,255}
	tune=tune or {}
	panelState=panelState or {}
	doorState=doorState or {}
	wheelState=wheelState or {0,0,0,0}
	health=health or 1000
	engine=engine or nil
	color=color or {255,255,255,255,255,255}
	fuel=fuel or 25
	fuelTank=fuelTank or 25
	components=components or {}
	components=table.concat(components,',')

	local query, _, id = exports.px_connect:query("insert into groups_vehicles (model, position, owner, ownerName, color, lightColor, panelState, doorState, distance, fuel, fuelTank, fuelType, tuning, health, wheelState, engine, type, components) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", model or 411, toJSON(position), owner or 0, ownerName or "", toJSON(color), toJSON(lightColor), toJSON(panelState), toJSON(doorState), distance or 0, fuel or 25, fuelTank or 25, fuelType or "Diesel", toJSON(tune), health, toJSON(wheelState), engine, type or nil, components or {})
	if(query)then
		if(create)then
			local vehicle=VEH.createNewVehicle(id, warp)
			setElementFrozen(vehicle, false)
		end
		return id
	end
	return false
end

VEH.mechanicTuning={
	'mk1',
	'mk2',
	'speedoType',
	'multiLED',
	'actualHydraulicState',
	'hydraulicControl',
	'turbo',
	'suspension',
	'brakes',
	'nitro'
}

VEH.reloadVehicleMechanicalUpgrades=function(vehicle)
	local id=getElementData(vehicle, "vehicle:group_id")
	if(not id)then return false end

	local q=exports.px_connect:query("select * from groups_vehicles where id=? limit 1", id)
	if(not q or (q and not q[1]))then return false end

	local v=q[1]

	for k,h in pairs(getOriginalHandling(v.model)) do
		setVehicleHandling(vehicle, k, h)
	end

	exports.px_custom_vehicles:setVehicleDefaultHandling(vehicle)

	-- updates
	local hand=q[1].handling and fromJSON(q[1].handling) or {}
	for i,v in pairs(hand) do
		if(string.sub(i, 1, 4) ~= "save")then
			setVehicleHandling(vehicle, i, v)
		end
	end
	--

	-- engines
	local default_engine=exports.px_custom_vehicles:getVehicleEngineFromModel(v.model)
	local engine=v.engine or default_engine
	engine=(v.engine and string.len(v.engine) > 0) and string.format("%.1f", v.engine) or default_engine
	if(v.engine and (string.len(v.engine) < 1 or tonumber(v.engine) < 0.1))then
		engine=default_engine
	end

	if(engine and engine ~= default_engine and tonumber(engine) > 0)then
		local add=(engine-default_engine)
		local hand=getVehicleHandling(vehicle)
		local velocity=(add/0.2)*5
		local acceleration=(add/0.2)*0.7
		setVehicleHandling(vehicle, "maxVelocity", hand.maxVelocity+velocity)
		setVehicleHandling(vehicle, "engineAcceleration", hand.engineAcceleration+acceleration)
	end
	setElementData(vehicle, "vehicle:engine", engine and engine or default_engine)
	--

	-- mechanic tuning
	for i,v in pairs(VEH.mechanicTuning) do
		removeElementData(vehicle, "vehicle:"..v)
	end

	local suspensions={
		["Terenowe H2"]=function(v) setVehicleHandling(v, "suspensionLowerLimit", -0.3) end,
		["Drogowe H1"]=function(v) setVehicleHandling(v, "suspensionLowerLimit", -0.1) end,
		["Sportowe H-1"]=function(v) setVehicleHandling(v, "suspensionLowerLimit", -0.075) end,
		["Wyścigowe H-2"]=function(v) setVehicleHandling(v, "suspensionLowerLimit", -0.001) end,
		["Regulowane HR"]=function(v) setElementData(v, "vehicle:actualHydraulicState", 2); setElementData(vehicle, "vehicle:hydraulicControl", true) end,
	}

	local mech=fromJSON(v.mechanicTuning) or {}
	if(table.size(mech) > 0)then
		for i,v in pairs(mech) do
			if(i == "driveType")then
				setVehicleHandling(vehicle, "driveType", v)
			elseif(i == "multiLED")then
				setElementData(vehicle, "vehicle:multiLED", v == 1)
			elseif(i == "speedoType")then
				setElementData(vehicle, "vehicle:speedoType", v)
			elseif(i == "MK1")then
				setElementData(vehicle, "vehicle:mk1", true)
			elseif(i == "MK2")then
				setElementData(vehicle, "vehicle:mk2", true)
			elseif(i == "suspension")then
				local data=suspensions[v]
				if(data)then
					data(vehicle)
				end
				setElementData(vehicle, "vehicle:suspension", v)
			elseif(i == "nitro")then
				setElementData(vehicle, "vehicle:"..i, v)
				if(v == "Nitro x2" or v == "Atrapa x2")then
					addVehicleUpgrade(vehicle, 1009)
				elseif(v == "Nitro x5" or v == "Atrapa x5")then
					addVehicleUpgrade(vehicle, 1008)
				elseif(v == "Nitro x10" or v == "Atrapa x10")then
					addVehicleUpgrade(vehicle, 1010)
				elseif(v == "Pulsacyjne")then
					addVehicleUpgrade(vehicle, 1010)
				end
			else
				setElementData(vehicle, "vehicle:"..i, v)
			end
		end
	end
	--

	return true
end

function reloadVehicleMechanicalUpgrades(...) return VEH.reloadVehicleMechanicalUpgrades(...) end

-- on start enter

addEventHandler("onVehicleEnter", resourceRoot, function(player, seat)
	if(seat ~= 0 or getElementData(player, "user:admin") and getElementData(player, "user:admin") >= 3)then return end

	local uid=getElementData(player, "user:uid")
	local owner=getElementData(source, "vehicle:owner")

	if(not exports.px_vehicles:isPlayerHavePJ(player, getElementModel(source)))then
		setElementFrozen(source, true)
		cancelEvent()
		setControlState(player, "enter_exit", true)
		setTimer(function(veh)
			if(player and isElement(player))then
				setControlState(player, "enter_exit", false)
			end

			if(veh and isElement(veh))then
				setElementFrozen(veh, false)
			end
		end, 1000, 1, source)
	end
end)

addEventHandler("onVehicleStartEnter", resourceRoot, function(player, seat)
	if(seat ~= 0)then return end

	if(getElementData(player, "user:admin") == 6)then return end

	local uid=getElementData(player, "user:uid")
	local faction=getElementData(player, "user:faction")
	local org=getElementData(player, "user:organization")

	local owner=getElementData(source, "vehicle:group_owner")
	local access=getElementData(source, "vehicle:roleAccess")

	local orgRank=getElementData(source, "vehicle:orgRank")

	if(owner == faction and access)then 
		if(exports.px_factions:isPlayerHaveRole(getPlayerName(player),access))then return end
	end

	if(tonumber(owner) == tonumber(uid))then
		if(exports.px_rental_vehs:isVehicleRentByPlayer(source, player))then return end
	end

	if(owner == org)then
		local rank_id=exports.px_organizations:getPlayerRankID(getPlayerName(player))
		if(rank_id and rank_id > 0 and rank_id <= orgRank)then return end
	end

	exports.px_noti:noti("Nie posiadasz uprawnień do kierowania tym pojazdem.", player)
	cancelEvent()
end)

-- on destroy

addEventHandler("onElementDestroy", resourceRoot, function()
	if(VEH.objects[source])then
		for i,v in pairs(VEH.objects[source]) do
			destroyElement(v)
		end
		VEH.objects[source]=nil
	end
end)

-- exports

function saveVehicle(...)
	VEH.saveVehicle(...)
end

function addNewVehicle(...)
	return VEH.addNewVehicle(...)
end

function createNewVehicle(...)
	return VEH.createNewVehicle(...)
end

-- useful

function table.size(t)
	local x=0
	for i,v in pairs(t) do
		x=x+1
	end
	return x
end

-- start / stop

VEH.loadAllVehicles() -- load vehicles

addEventHandler("onResourceStop", resourceRoot, function()
	VEH.saveAllVehicles()
end)