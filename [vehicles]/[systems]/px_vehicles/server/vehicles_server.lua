--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- load

VEH.createNewVehicle=function(id,warp,t_pos,garage)
	if(id)then
		local q=exports.px_connect:query("select vehicles.* from vehicles left join vehicles_policeParking on vehicles_policeParking.id=vehicles.id where (vehicles.parking=0 and vehicles.h_garage=?) and vehicles_policeParking.id is null and vehicles.id=? limit 1", garage or 0, id)
		if(q and #q == 1)then
			return VEH.createVehicle(q[1],warp,t_pos), 'next'
		end
		return false, 'error sql'
	end
	return false, 'not id'
end

VEH.createVehicle=function(v,warp,t_pos)
	local vehElementID=getElementByID("px_vehicles_id:"..v.id)
	if(vehElementID and isElement(vehElementID))then return false, 'on map' end

	if(not v.position)then v.position='0,0,0,0,0,0' end

	local position = split(v.position,',') or {0,0,0,0,0,0}
	if(t_pos)then
		position=t_pos
	end

	if(#position > 0)then
		local vehicle = createVehicle(v.model, unpack(position))
		if(vehicle and isElement(vehicle))then
			local color = split(v.color,',') or {255,255,255,255,255,255}
			local lightColor = split(v.lightColor,',') or {255,255,255}
			local tuning = split(v.tuning,',') or {}
			local panelState = split(v.panelState,',') or {}
			local doorState = split(v.doorState,',') or {}
			local wheelState=split(v.wheelState,',') or {0,0,0,0}

			setElementFrozen(vehicle, true)
			setElementData(vehicle, "vehicle:handbrake", true)

			setVehicleColor(vehicle, unpack(color))

			if(#v.plateText > 0)then
				setVehiclePlateText(vehicle, v.plateText)
			else
				setVehiclePlateText(vehicle, "LV-"..v.id)
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

			setElementData(vehicle, "vehicle:owner", v.owner)
			setElementData(vehicle, "vehicle:ownerName", v.ownerName)
			setElementData(vehicle, "vehicle:id", v.id)
			setElementData(vehicle, "vehicle:distance", v.distance)
			setElementData(vehicle, "vehicle:infos", {v.buy_date,v.first_owner})

			setElementID(vehicle, "px_vehicles_id:"..v.id)

			if(v.lights > 0)then
				setElementData(vehicle, "vehicle:lights", v.lights)		
				setVehicleHeadLightColor(vehicle, unpack(lightColor))
			else
				setVehicleHeadLightColor(vehicle, 0,0,0)
			end

			-- wheels settings
			local colors=split(v.wheelsColor,',') or {255,255,255,255,255,255,255,255,255,255,255,255,}
			local wheelsSettings={
				axis=split(v.wheelsAxis, ',') or {},
				rot=split(v.wheelsRot, ',') or {},
				size=split(v.wheelsSize, ',') or {},
				tire=split(v.wheelsTire, ',') or {},
				color={
					felga={colors[1],colors[2],colors[3]},
					hamulec={colors[4],colors[5],colors[6]},
					szprycha={colors[7],colors[8],colors[9]},
					tarcza={colors[10],colors[11],colors[12]}
				}
			}
			setElementData(vehicle, "vehicle:wheelsSettings", wheelsSettings)
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
			local plate=split(v.plateColor,',') or {}
			if(#plate == 3)then
				setElementData(vehicle, "vehicle:plateColor", plate)
			end
			--

			v.fuelType=#v.fuelType < 0 and "Petrol" or v.fuelType
			setElementData(vehicle, "vehicle:fuel", v.fuel)
			setElementData(vehicle, "vehicle:fuelType", v.fuelType)
			setElementData(vehicle, "vehicle:actualFuelType", (v.fuelType == "LPG" and "Petrol" or v.fuelType))
			if v.fuelType == "LPG" then
				setElementData(vehicle, "vehicle:gas", v.gas)
			end

			setElementData(vehicle, "vehicle:fuelTank", v.fuelTank)
			setElementData(vehicle, "vehicle:lastDrivers", split(v.lastDrivers,','))

			exports.px_blips:createBlipAttachedVehicle(v.id)

			-- upgrades
			for i,v in pairs(tuning) do
				addVehicleUpgrade(vehicle, tonumber(v))
			end
			--

			if(#v.organization > 0)then
				setElementData(vehicle, "vehicle:organization", v.organization)
			end
			if(v.orgRank)then
				setElementData(vehicle, "vehicle:orgRank", v.orgRank)
			end
			
			local keys=exports.px_connect:query('select * from vehicles_share where vehID=? limit 1', v.id)
			if(keys and #keys > 0)then
				for i,v in pairs(keys) do
					local haveFriend=false

					local f1=exports.px_connect:query('select * from accounts_friends where (uid=? or uid_target=?) and accept=1', v.owner, v.uid)
					local f2=exports.px_connect:query('select * from accounts_friends where (uid=? or uid_target=?) and accept=1', v.uid, v.owner)
					if((f1 and #f1 > 0) or (f2 and #f2 > 0))then
						haveFriend=true
					end

					if(not haveFriend)then
						keys[i]=nil
						exports.px_connect:query('delete from vehicles_share where id=? limit 1', v.id)
					end
				end
				setElementData(vehicle, "vehicle:keys", keys)
			end

			VEH.reloadVehicleMechanicalUpgrades(vehicle)

			if(warp)then
				warpPedIntoVehicle(warp, vehicle)
			end

			return vehicle, 'success create'
		else
			return false, 'error with create'
		end
	else
		local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", v.owner)
		if(parking_id and #parking_id == 1)then
			exports.px_connect:query("update vehicles set parking=?,position=NULL where id=?", parking_id[1].id, v.id)
			return false, 'go to parking'
		end
		return false, 'go to parking (error)'
	end
end

VEH.loadAllVehicles = function()
	local q=exports.px_connect:query("select vehicles.* from vehicles left join vehicles_policeParking on vehicles_policeParking.id=vehicles.id where (vehicles.parking=0 and vehicles.h_garage=0) and vehicles_policeParking.id is null")

	local i=0
	for _,v in pairs(q) do
		i=i+1

		if(i%20 == 0)then
			setTimer(function() coroutine.resume(coroutine.load_vehicles) end, 150, 1)
			coroutine.yield()
		end

		VEH.createVehicle(v)

		if(i == #q)then
			exports.px_stock_vehicles:loadStockVehicles()
		end
	end
end

-- save

VEH.saveVehicle = function(vehicle, action)
    if(vehicle and isElement(vehicle))then
		local id = getElementData(vehicle, "vehicle:id")
		if(not id)then return false end

		local q=exports.px_connect:query("select * from vehicles where id=? limit 1", id)
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

		-- wheels settings
		local wheels=getElementData(vehicle, "vehicle:wheelsSettings")
		local wheelsAxis="0,0,0,0"
		local wheelsRot="0,0,0,0"
		local wheelsSize="0,0,0,0"
		local wheelsTire="0,0,0,0"
		if(wheels)then
			wheels.color=wheels.color or {}
			wheelsAxis=table.concat(wheels.axis or {}, ',')
			wheelsRot=table.concat(wheels.rot or {}, ',')
			wheelsSize=table.concat(wheels.size or {}, ',')
			wheelsTire=table.concat(wheels.tire or {}, ',')
			wheelsColor=
			{
				wheels.color.felga and wheels.color.felga[1] or 255,wheels.color.felga and wheels.color.felga[2] or 255,wheels.color.felga and wheels.color.felga[3] or 255,
				wheels.color.hamulec and wheels.color.hamulec[1] or 255,wheels.color.hamulec and wheels.color.hamulec[2] or 255,wheels.color.hamulec and wheels.color.hamulec[3] or 255,
				wheels.color.szprycha and wheels.color.szprycha[1] or 255,wheels.color.szprycha and wheels.color.szprycha[2] or 255,wheels.color.szprycha and wheels.color.szprycha[3] or 255,
				wheels.color.tarcza and wheels.color.tarcza[1] or 255,wheels.color.tarcza and wheels.color.tarcza[2] or 255,wheels.color.tarcza and wheels.color.tarcza[3] or 255,
			}
			wheelsColor=table.concat(wheelsColor,',')
		end
		--

		for i = 1,7 do
			panelState[i] = getVehiclePanelState(vehicle, (i - 1))
		end

		for i = 1,6 do
			doorState[i] = getVehicleDoorState(vehicle, (i - 1))
		end

		local query=exports.px_connect:query(
			[[update vehicles set 

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
				wheelState=?, 
				dirtSettings=?, 
				plateColor=?,
				lights=?,
				wheelsAxis=?,
				wheelsRot=?,
				wheelsSize=?,
				wheelsColor=?,
				wheelsTire=?

			where id=? limit 1]], 

			table.concat(position,','), 
			table.concat(color,','), 
			table.concat(lightColor,','), 
			table.concat(panelState,','), 
			table.concat(doorState,','), 
			health, 
			distance, 
			fuel, 
			gas, 
			table.concat(lastDrivers,','), 
			table.concat(wheelState,','), 
			dirt, 
			table.concat(plateColor,','), 
			lights,
			wheelsAxis,
			wheelsRot,
			wheelsSize,
			wheelsColor,
			wheelsTire,
			id
		)

		if(query)then
			if(action == "destroy")then
				return true, destroyElement(vehicle)
			end
			return true
        end
        return false
    end
    return false
end

VEH.saveAllVehicles = function()
	for i,v in pairs(getElementsByType("vehicle", resourceRoot)) do
		VEH.saveVehicle(v)
	end
end

-- add new

VEH.addNewVehicle = function(create, warp, model, position, rotation, owner, ownerName, distance, fuel, fuelTank, type, color, tune, wheel, lightColor, panelState, doorState, wheelState, health, engine, components)
	position={position[1], position[2], position[3], rotation[1], rotation[2], rotation[3]}
	wheel=wheel or {1,255,255,255}
	lightColor=lightColor or {255,255,255}
	tune=tune or {}
	panelState=panelState or {}
	doorState=doorState or {}
	wheelState=wheelState or {0,0,0,0}
	health=health or 1000
	engine=engine or 0
	fuel=fuel or 5
	components=components or {}
	components=table.concat(components,',')
	if(string.len(engine) < 1 or tonumber(engine) < 0.1)then
		engine=exports.px_custom_vehicles:getVehicleEngineFromModel(model)
	end

	local query, _, id = exports.px_connect:query(
	[[
		insert into vehicles 
		(model, position, owner, ownerName, color, lightColor, panelState, doorState, distance, fuel, fuelTank, fuelType, buy_date, first_owner, tuning, health, wheelState, engine, components) 
		values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, now(), ?, ?, ?, ?, ?, ?)
	]], 
		model or 411, 
		table.concat(position,','), 
		owner or 0, 
		ownerName or "", 
		table.concat(color,','), 
		table.concat(lightColor,','), 
		table.concat(panelState,','), 
		table.concat(doorState,','), 
		distance or 0, fuel 
		or 5, 
		fuelTank or 25, 
		type or "Diesel", 
		ownerName, 
		table.concat(tune,','), 
		health, 
		table.concat(wheelState,','), 
		engine, 
		components
	)

	if(query)then
		if(create)then
			local vehicle=VEH.createNewVehicle(id, warp)
			if(vehicle and isElement(vehicle))then
				setElementFrozen(vehicle, false)
			end
		end
		return id
	end
	return false
end

-- engine and water, rents

local timers={}
function checkVehicles()
	for i,v in pairs(getElementsByType("vehicle")) do
		-- engine
		if(getElementHealth(v) <= 300)then
			setElementHealth(v, 325)
		end

		if(getVehicleName(v) ~= "Rhino")then
			if(isElementFrozen(v) == true and not getVehicleController(v) and isVehicleDamageProof(v) ~= true)then
				setVehicleDamageProof(v, true)
			elseif(isElementFrozen(v) ~= true and getVehicleController(v) and isVehicleDamageProof(v) == true)then
				setVehicleDamageProof(v, false)
			end
		else
			setVehicleDamageProof(v, false)
		end

		-- water
		if(isElementInWater(v) and not timers[v] and getVehicleType(v) ~= "Boat")then
			v=v
			timers[v]=setTimer(function()
				if(v and isElement(v) and isElementInWater(v))then
					local health=getElementHealth(v)
					if(health > 400)then
						health=math.random(325,395)
						setElementHealth(v, health)
					end

					local type=getElementData(v, "vehicle:group_id") and "group" or "owner"
					local id=getElementData(v, "vehicle:group_id") or getElementData(v, "vehicle:id")
					if(type == "group")then
						exports.px_groups_vehicles:saveVehicle(v, "destroy")
						exports.px_connect:query("groups_vehicles set parking=1 where id=? limit 1", id)
					else
						if(id)then
							VEH.saveVehicle(v, "destroy")
							exports.px_connect:query('insert into vehicles_policeParking (id, policeman, reason, cost, date) values(?,?,?,?,now())', id, 'SAPD', 'Zaśmiecanie wody', 200)
						end
					end
				end
				timers[v]=nil
			end, (1000*40), 1) -- 40 s
		end
	end
end
setTimer(checkVehicles, 500, 0)

-- on start / stop

coroutine.load_vehicles=coroutine.create(VEH.loadAllVehicles)
coroutine.resume(coroutine.load_vehicles)

addEventHandler("onResourceStop", resourceRoot, function()
	VEH.saveAllVehicles()
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

-- slots

function getPlayerHousesSlots(uid)
    local r=exports.px_connect:query("select * from houses where owner=?", uid)
    local slots=0
    if(r and #r > 0)then
        for i,v in pairs(r) do
            slots=slots+v.level
        end
    end
    return slots
end

--[[
function getPlayerBusiness(uid)
    local r=exports.px_connect:query("select id from groups_business where owner=?", uid)
    local slots=0
    if(r and #r > 0)then
        for i,v in pairs(r) do
            slots=slots+3
        end
    end
    return slots
end]]

function getPlayerFreeVehicleSlot(player)
	local uid=getElementData(player, "user:uid")
	if(not uid)then return false end

	local data=getElementData(player, "user:vehiclesSlots") or 2	
	local q=exports.px_connect:query("select * from vehicles where owner=?", uid)
	
	local addSlots=getPlayerHousesSlots(uid)
	data=data+addSlots

	--local addSlots=getPlayerBusiness(uid)
	--data=data+addSlots
	
	if(q and #q > 0)then
		if(#q >= data)then
			return false, #q, data
		else
			return true, #q, data
		end
	else
		return true, 0, data
	end

	return false
end

addEventHandler("onResourceStop", resourceRoot, function()
	exports.px_stock_vehicles:saveStockVehicles()
end)