--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui.getFromList=function(veh)
	if(veh and isElement(veh))then
		local haveCombi=false
		local c=getElementData(veh, 'vehicle:components') or {}
		for i,v in pairs(c) do
			if(v == 'Combi')then
				haveCombi=true
				break
			end
		end

		if(haveCombi)then
			return ui.componentsList[getVehicleName(veh)..' Combi'] or ui.componentsList[getElementModel(veh)] or ui.componentsList[getVehicleName(veh)]
		end

		return ui.componentsList[getElementModel(veh)] or ui.componentsList[getVehicleName(veh)]
	end
	return ui.componentsList[veh]
end

ui.setVehicleComponent=function(veh)
	local data=getElementData(veh, "vehicle:components")

	local components=ui.getFromList(veh)
	if(components)then
		local c=components["Podstawowe"]["Podstawowy"]
		if(c)then
			for i,v in pairs(c.hide) do
				setVehicleComponentVisible(veh, v, false)
			end

			for i,v in pairs(c.visibled) do
				setVehicleComponentVisible(veh, v, true)
			end
		end
	end

	if(data)then
		local components=ui.getFromList(veh)
		if(components)then
			local update={}
			for i,v in pairs(data) do
				for _,t in pairs(components) do
					local c=t[v]
					if(c)then
						for i,v in pairs(c.hide) do
							setVehicleComponentVisible(veh, v, false)
						end
		
						for i,v in pairs(c.visibled) do
							setVehicleComponentVisible(veh, v, true)
						end
					end
				end
			end
		end
	end
end
for i,v in pairs(getElementsByType("vehicle", root, true)) do
	ui.setVehicleComponent(v)
end

addEventHandler("onClientElementStreamIn", root, function()
    if(getElementType(source) == "vehicle")then
        ui.setVehicleComponent(source)
    end
end)

addEventHandler("onClientElementDataChange", root, function(data, _, new)
    if(getElementType(source) == "vehicle" and data == "vehicle:components")then
        ui.setVehicleComponent(source)
    end
end)

function getVehicleComponents(name)
	return ui.getFromList(name)
end

-- export

function addVehicleComponent(veh, name)
	local data=getElementData(veh, "vehicle:components") or {}

	if(name == "Podstawowy")then
		data={}
	else
		local c_list=ui.getFromList(veh)
		for i,v in pairs(c_list) do
			if(v[name])then
				for index,value in pairs(v) do
					for i,v in pairs(data) do
						if(v == index)then
							table.remove(data,i)
						end
					end
				end
			end
		end
	end

	data[#data+1]=name

	setElementData(veh, "vehicle:components", data)

	return data
end

function addVehicleClientComponent(veh, name)
	local data=getElementData(veh, "vehicle:client_components") or {}

	if(name == "Podstawowy")then
		data={}
	else
		local c_list=ui.getFromList(veh)
		for i,v in pairs(c_list) do
			if(v[name])then
				for index,value in pairs(v) do
					for i,v in pairs(data) do
						if(v == index)then
							table.remove(data,i)
						end
					end
				end
			end
		end
	end

	data[#data+1]=name

	setElementData(veh, "vehicle:client_components", data, false)
end

function setVehicleClientComponent(veh)
	local data=getElementData(veh, "vehicle:client_components")

	local components=ui.getFromList(veh)
	if(components)then
		local c=components["Podstawowe"]["Podstawowy"]
		if(c)then
			for i,v in pairs(c.hide) do
				setVehicleComponentVisible(veh, v, false)
			end

			for i,v in pairs(c.visibled) do
				setVehicleComponentVisible(veh, v, true)
			end
		end
	end

	if(data)then
		local components=ui.getFromList(veh)
		if(components)then
			local update={}
			for i,v in pairs(data) do
				for _,t in pairs(components) do
					local c=t[v]
					if(c)then
						for i,v in pairs(c.hide) do
							setVehicleComponentVisible(veh, v, false)
						end
		
						for i,v in pairs(c.visibled) do
							setVehicleComponentVisible(veh, v, true)
						end
					end
				end
			end

			setElementData(veh, "vehicle:client_components", data)
		end
	end
end

-- useful

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end
