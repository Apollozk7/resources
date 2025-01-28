--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local elevators={
	-- klatki rockshore
	{pos={2583.4243,821.9042}, z={
		-3.4844,
		0.71,
		4.9,
	}},
	{pos={2691.7993,878.9857}, z={
		-3.4844,
		0.71,
		4.9,
	}},
	{pos={2672.9148,817.4028}, z={
		-3.4844,
		0.71,
		4.9,
	}},
	{pos={2640.9619,728.4998}, z={
		-3.4844,
		0.71,
		4.9,
	}},
	{pos={2559.2148,729.1224}, z={
		-3.4844,
		0.71,
		4.9,
	}},
	--
}
for i,v in pairs(elevators) do
	for _,z in pairs(v.z) do
		local wejscie = createMarker(v.pos[1], v.pos[2], z-0.97, "cylinder", 1.2, 0, 255, 175)
		setElementData(wejscie, "data:z", v.z, false)
	
		setElementData(wejscie, "icon", ":px_interiors/assets/images/marker.png")
		setElementData(wejscie, "text", {text="Winda",desc=""})
	end
end

addEventHandler("onResourceStart", resourceRoot, function()
	local query = exports.px_connect:query("select * from misc_interiors")
	for i,v in pairs(query) do
		local wejscie_pos = split(v.enterPos, ",")
		local wejscie = createMarker(wejscie_pos[1], wejscie_pos[2], wejscie_pos[3]-0.97, "cylinder", 1.2, 0, 255, 175)
		setElementData(wejscie, "marker:data", {query=v,type="wejscie"}, false)

		setElementData(wejscie, "icon", ":px_interiors/assets/images/marker.png")
		setElementData(wejscie, "text", {text="Wejście",desc=v.name})

		setElementInterior(wejscie, v.int2)
		setElementDimension(wejscie, v.dim2)

		local wyjscie_pos = split(v.exitPos, ",")
		local wyjscie = createMarker(wyjscie_pos[1], wyjscie_pos[2], wyjscie_pos[3]-0.97, "cylinder", 1.2, 0, 175, 255)
		setElementData(wyjscie, "marker:data", {query=v,type="wyjscie"}, false)

		setElementInterior(wyjscie, v.int)
		setElementDimension(wyjscie, v.dim)

		setElementData(wyjscie, "icon", ":px_interiors/assets/images/marker.png")
		setElementData(wyjscie, "text", {text="Wyjście",desc=v.name})
	end
end)

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
	if not hit or hit and not isElement(hit) or hit and isElement(hit) and getElementType(hit) ~= "player" or hit and isElement(hit) and getElementType(hit) == "player" and isPedInVehicle(hit) or not dim then return end

	local z=getElementData(source, "data:z")
	if(z)then
		triggerClientEvent(hit, "open.elevator", resourceRoot, source, z)
		return
	end

	local data = getElementData(source, "marker:data")
	if not data then return end

	if(data["type"] == "wejscie")then
		triggerClientEvent(hit, "open.ui", resourceRoot, data, "wejscie", getElementData(source, "icon"), source, data.dim)
	elseif data["type"] == "wyjscie" then
		triggerClientEvent(hit, "open.ui", resourceRoot, data, "wyjscie", getElementData(source, "icon"), source, data.dim)
	end
end)

addEvent("load.interior", true)
addEventHandler("load.interior", resourceRoot, function(data, type, dim)
	if(type == "wejscie")then
		local pos = split(data.query.enterTeleport, ",")
		setElementPosition(client, pos[1], pos[2], pos[3])
		setElementInterior(client, data.query.int)
		setElementDimension(client, data.query.dim)
	elseif(type == "wyjscie")then
		local pos = split(data.query.exitTeleport, ",")
		setElementPosition(client, pos[1], pos[2], pos[3])
		setElementInterior(client, data.query.int2)
		setElementDimension(client, data.query.dim2)
	end
end)

addEvent("teleport.player", true)
addEventHandler("teleport.player", resourceRoot, function(z)
	local p={getElementPosition(client)}
	setElementPosition(client, p[1], p[2], z)
end)
