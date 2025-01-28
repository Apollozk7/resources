--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local blips = {}

local blipTexture = dxCreateTexture("assets/images/arrow.png", "argb", false, "clamp")

local font1 = dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", 16/zoom)
local font2 = dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 12/zoom)

local id={
	[19]=true,
	[22]=true,
	[36]=true,
	[37]=true
}

function getBlip(veh)
	local uid=getElementData(localPlayer, "user:uid")
	if(not uid)then return end	

	local faction=getElementData(localPlayer, "user:faction")
	local org=getElementData(localPlayer, "user:organization")
	local nick=getPlayerName(localPlayer)

	local owner=getElementData(veh, "vehicle:owner")
	local owner_group=getElementData(veh, "vehicle:group_ownerName")
	local veh_org=getElementData(veh, "vehicle:organization")

	local keys=getElementData(veh, 'vehicle:keys') or {}

	if(owner and owner == uid)then
		return {24}
	elseif(owner_group and owner_group == org)then
		return {45}
	elseif(veh_org and org and veh_org == org)then
		return {45}
	elseif(keys[getPlayerName(localPlayer)])then
		return {24}
	elseif(owner_group and owner_group == faction)then
		if(faction == "SACC")then
			return {0, 2, 255, 255, 0}
		elseif(faction == "SAPD")then
			return {0, 2, 0, 0, 255}
		elseif(faction == "SARA")then
			return {0, 2, 232, 153, 7}
		elseif(faction == "PSP")then
			return {0, 2, 255,0,0}
		else
			return {0, 2, 0, 255, 0}
		end
	elseif(owner_group and owner_group == nick)then
		return {24}
	end

	return false
end

function load_blips(type, destroy)
	for i,v in pairs(getElementsByType("vehicle")) do
		if(destroy)then
			if(blips[v] and isElement(blips[v]) and owner and owner == uid)then
				destroyElement(blips[v])
				blips[v]=nil
			end
		else
			local blip=getBlip(v)
			if(blip and not blips[v])then
				blips[v]=createBlipAttachedTo(v, unpack(blip))
			end
		end
	end
end

local blips_data = {}
local blips_last_update = getTickCount()

function getBlips()
	if(getTickCount() - blips_last_update > 1000)then
		local temp_table = {}

		for i,v in pairs(getElementsByType("blip")) do
			if(id[getBlipIcon(v)])then
				local x,y,z = getElementPosition(v)
				local rx,ry,rz = getElementPosition(localPlayer)
				local distance = getDistanceBetweenPoints3D(rx, ry, rz, x, y, z)
				if(distance > 10)then
					table.insert(temp_table, {v, distance})
				end
			end
		end

		table.sort(temp_table, function (a, b) return a[2] < b[2] end)

		local currentIterator = 0;
		local maxIterator = 10;

		local temp_table2 = {}

		for i,v in ipairs(temp_table) do
			currentIterator = currentIterator+1;
			if(currentIterator < maxIterator)then
				table.insert(temp_table2, v)
			end
		end

		blips_data = temp_table2;
		blips_last_update = getTickCount()
		return temp_table2
	else
		return blips_data
	end
end

addEventHandler("onClientRender", root, function()
	for i,v_tbl in pairs(getBlips()) do
		local v = v_tbl[1]
		if(isElement(v))then
			local x,y,z = getElementPosition(v)
			local rx,ry,rz = getElementPosition(localPlayer)
			local distance = getDistanceBetweenPoints3D(rx, ry, rz, x, y, z)
			if(distance > 10)then
				local size=(distance)/4
				local pZ=(distance)/10

				local sx,sy = getScreenFromWorldPosition(x, y, z)
				local zz=getGroundPosition(x,y,z)
				if((z-zz) < 10)then
					z=z+20
					z=z+pZ*2
					sx,sy = getScreenFromWorldPosition(x, y, z)
				end

				if(sx and sy)then
					distance=math.floor(distance)

					local distX=math.floor(distance*10)
					local text=distX.." M"
					if(distX > 1000)then
						distX=string.format("%.1f", distX/1000)
						text=distX.." KM"
					end

					local w=dxGetTextWidth(text, 1, font1)
					dxDrawText(text, sx+1, sy+1, sx+1, sy+1, tocolor(0, 0, 0, 255), 1, font1, "center", "top", false, false, false, true)
					dxDrawText(text, sx, sy, sx, sy, tocolor(200, 200, 200, 255), 1, font1, "center", "top", false, false, false, true)
					dxDrawRectangle(sx-w/2, sy+30/zoom, w, 2, tocolor(200, 50, 50))
					dxDrawText("CEL", sx+1, sy+30/zoom+1, sx+1, sy+1, tocolor(0, 0, 0), 1, font2, "center", "top")
					dxDrawText("CEL", sx, sy+30/zoom, sx, sy, tocolor(200, 200, 200), 1, font2, "center", "top")
					dxDrawImage(sx-7/zoom,sy+55/zoom,16/zoom,16/zoom,blipTexture,0,0,0,tocolor(150,150,150))

					if((z-zz) > 10)then
						dxDrawLine3D(x,y,z-(0.3*size),x,y,zz,tocolor(100,100,100),0.5*(size))
					end
				end
			end
		end
	end
end)

addEvent("createBlipAttachedVehicle", true)
addEventHandler("createBlipAttachedVehicle", resourceRoot, function(id)
	setTimer(function()
		for i,v in pairs(getElementsByType("vehicle")) do
			if(getElementData(v, "vehicle:id") and tonumber(getElementData(v, "vehicle:id")) == tonumber(id))then
				local owner = getElementData(v, "vehicle:ownerName")
				if(not blips[v] and owner and owner == getPlayerName(localPlayer))then
					local blip=getBlip(v)
					if(blip)then
						blips[v]=createBlipAttachedTo(v, unpack(blip))
					end
				elseif(blips[v] and isElement(blips[v]) and owner and owner ~= getPlayerName(localPlayer))then
					destroyElement(blips[v])
					blips[v] = false
				end
			end
		end
	end, 1500, 1)
end)

addEventHandler("onClientElementDestroy", root, function()
	if(source and isElement(source) and getElementType(source) == "vehicle")then
		if(blips[source])then
			destroyElement(blips[source])
			blips[source] = false
		end
	end
end)

addEventHandler("onClientElementDataChange", root, function(data, _, new)
	if((data == "user:faction" or data == "user:organization") and source == localPlayer)then
		if(not new)then
			for i,v in pairs(blips) do
				if(v and isElement(v))then
					destroyElement(v)
				end
			end
		end

		for i,v in pairs(getElementsByType("vehicle")) do
			local blip=getBlip(v)
			if(blip and not blips[v])then
				blips[v]=createBlipAttachedTo(v, unpack(blip))
			end
		end
	end
end)

addEventHandler("onClientElementStreamIn", root, function()
	if(getElementType(source) ~= "vehicle")then return end

	local owner=getElementData(source, "vehicle:group_ownerName")
	if(not owner)then return end

	local data=getElementData(localPlayer, "user:organization")
	if(not data)then return end

	if(owner == data)then
		if(blips[source])then
			destroyElement(blips[source])
			blips[source]=nil
		end

		local blip=getBlip(source)
		if(blip and not blips[source])then
			blips[source]=createBlipAttachedTo(source, unpack(blip))
		end
	end
end)

addEventHandler("onClientPlayerSpawn", localPlayer, function()
	load_blips()
	setTimer(load_blips, 600000, 0)
end)

load_blips()

--toffy BLIPY--

local color = {255, 255, 255}
local factions={
	["SACC"]={255,255,0},
	["SAPD"]={0,100,255},
	["SARA"]={232, 153, 7},
	["PSP"]={255,0,0},
}

local blips = {}

addEventHandler("onClientPlayerQuit", getRootElement(), function()
	if blips[source] then
		blips[source]:destroy()
		blips[source]=nil;
	end
end)

function update_blips()
	local myData = getElementData(localPlayer,"user:faction")
	local myOrg = getElementData(localPlayer,"user:organization")

	for i,v in ipairs(getElementsByType("player")) do
		if not blips[v] or not isElement(blips[v]) then
			blips[v] = createBlipAttachedTo(v, 0, 2, color[1], color[2], color[3], 0, 0, 250)
		end
	end
	for player,blip in pairs(blips) do
		if not isElement(player) or not blips[player] then
			if isElement(blips[player]) then
				blips[player]:destroy();
			end
			blips[player] = nil;
		else
			setDimAndInt(blip,player)
			
			local data = getElementData(player,"user:faction")
			local org = getElementData(player,"user:organization")
			local invisible = getElementAlpha(player) == 0
			if(getElementData(player, "Area.InZone"))then invisible=true end

			if(org and myOrg and org == myOrg)then
				local color={0,255,200}
				setBlipColor(blip, color[1], color[2], color[3], invisible and 0 or 255)
				setBlipVisibleDistance(blip, 250)
			elseif factions[data] then
				local color = factions[data];
				if(data == "SAPD" and (not myData or (myData and myData ~= data)))then 
					invisible=true 
				end

				setBlipColor(blip, color[1], color[2], color[3], invisible and 0 or 255)
				setBlipVisibleDistance(blip, 250)
			else
				setBlipColor(blip, color[1], color[2], color[3], invisible and 0 or 255)
				setBlipVisibleDistance(blip, 250)
			end
		end
	end
end

function setDimAndInt(blip, player)
	local dim = player.dimension;
	local int = player.interior;
	setElementDimension(blip, dim)
	setElementInterior(blip, int)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	update_blips()
	Timer(update_blips, 2000, 0)
end)