--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

VEH={}

VEH.mechanicTuning={
	'mk1',
	'mk2',
	'speedoType',
	'multiLED',
	'turbo',
	'suspension',
	'brakes',
	'nitro'
}

VEH.getVehicleHandlingWithEngine=function(vehicle)
	local engine=getElementData(vehicle, "vehicle:engine")
	local default_engine=exports.px_custom_vehicles:getVehicleEngineFromModel(getElementModel(vehicle))
	if(engine and default_engine and engine ~= default_engine and tonumber(engine) > 0)then
		local add=(engine-default_engine)
		local hand=getVehicleHandling(vehicle)
		local velocity=(add/0.2)*5
		local acceleration=(add/0.2)*0.7

		return {velocity,acceleration}
	end
end

VEH.reloadVehicleMechanicalUpgrades=function(vehicle)
	local id=getElementData(vehicle, "vehicle:id")
	if(not id)then return false end

	local q=exports.px_connect:query("select * from vehicles where id=? limit 1", id)
	if(not q or (q and not q[1]))then return false end

	local v=q[1]

	for k,h in pairs(getOriginalHandling(v.model)) do
		setVehicleHandling(vehicle, k, h)
	end

	exports.px_custom_vehicles:setVehicleDefaultHandling(vehicle)

	-- updates
	local hand=q[1].handling and split(q[1].handling, ',') or {}
	for i,v in pairs(hand) do
		local f=utf8.find(v, '_')
		local name,value=utf8.sub(v, 0, f-1),tonumber(utf8.sub(v, f+1, #v))
		if(not utf8.find(name, 'save'))then
			setVehicleHandling(vehicle, name, value)
		end
	end
	--

	-- engines
	local default_engine=exports.px_custom_vehicles:getVehicleEngineFromModel(v.model)
	local engine=(v.engine and string.len(v.engine) > 0) and string.format("%.1f", v.engine) or default_engine
	if(string.len(v.engine) < 1 or tonumber(v.engine) < 0.1)then
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
		["Regulowane HR"]=function(v) setElementData(v, "vehicle:actualHydraulicState", 2); setElementData(v, "vehicle:hydraulicControl", true) end,
	}

	local mech=split(v.mechanicTuning,',') or {}
	if(table.size(mech) > 0)then
		for id,i in pairs(mech) do
			local v
			local findValue=utf8.find(i, '_')
			if(findValue)then
				v=utf8.sub(i,findValue+1,#i)
				i=utf8.sub(i,0,findValue-1)

				if(tonumber(v))then
					v=tonumber(v)
				end
			else
				v=true
			end

			if(i == "driveType")then
				setVehicleHandling(vehicle, "driveType", v)
			elseif(i == "multiLED")then
				setElementData(vehicle, "vehicle:multiLED", true)
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
			elseif(i == 'nitro')then
				setElementData(vehicle, "vehicle:"..i, v)

				if(v == "Nitro x2")then
					removeVehicleUpgrade(vehicle, 1009)
					addVehicleUpgrade(vehicle, 1009)
				elseif(v == "Nitro x5")then
					removeVehicleUpgrade(vehicle, 1008)
					addVehicleUpgrade(vehicle, 1008)
				elseif(v == "Nitro x10")then
					removeVehicleUpgrade(vehicle, 1010)
					addVehicleUpgrade(vehicle, 1010)
				elseif(v == "Pulsacyjne")then
					removeVehicleUpgrade(vehicle, 1010)
					addVehicleUpgrade(vehicle, 1010)
				end
			else
				setElementData(vehicle, "vehicle:"..i, v)
			end
		end
	end

	setVehicleHandlingFlags(vehicle, 7, 1)
	
	--

	return true
end
function reloadVehicleMechanicalUpgrades(...) return VEH.reloadVehicleMechanicalUpgrades(...) end
function getVehicleHandlingWithEngine(...) return VEH.getVehicleHandlingWithEngine(...) end

-- set normal handling

function setVehicleHandlingFlags(vehicle, byte, value)
    if vehicle then
        local handlingFlags = string.format("%X", getVehicleHandling(vehicle)["handlingFlags"])
        local reversedFlags = string.reverse(handlingFlags) .. string.rep("0", 8 - string.len(handlingFlags))
        local currentByte, flags = 1, ""

        for values in string.gmatch(reversedFlags, ".") do
            if type(byte) == "table" then
                for _, v in ipairs(byte) do
                    if currentByte == v then
                        values = string.format("%X", tonumber(value))
                    end
                end
            else
                if currentByte == byte then
                    values = string.format("%X", tonumber(value))
                end
            end		
            flags = flags .. values
            currentByte = currentByte + 1
        end
        setVehicleHandling(vehicle, "handlingFlags", tonumber("0x" .. string.reverse(flags)), false)
    end
end

function setNormalHandling(vehicle)
    if(vehicle and isElement(vehicle))then
        setVehicleHandlingFlags(vehicle, 7, 1)

		-- winter
		local hand=getOriginalHandling(getElementModel(vehicle))
		setVehicleHandling(vehicle, "tractionLoss", hand.tractionLoss)
		--[[local data=getElementData(vehicle, "vehicle:wheelsSettings")
		if(data and data.chain)then
			setVehicleHandling(vehicle, "tractionLoss", hand.tractionLoss)
		else
			setVehicleHandling(vehicle, "tractionLoss", hand.tractionLoss*0.7)
		end]]
    end
end

addEventHandler("onVehicleEnter", root, function()
	setNormalHandling(source)
end)

-- useful

function table.size(t)
	local x=0
	for i,v in pairs(t) do
		x=x+1
	end
	return x
end