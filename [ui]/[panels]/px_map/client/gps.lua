-- #######################################
-- ## Name: 	Navi				    ##
-- ## Author:	Vandam					##
-- #######################################

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer)then
        killTimer(SPAM.blockSpamTimer)
        block=true

        if(not SPAM.blockNoti)then
            SPAM.blockNoti=setTimer(function() SPAM.blockNoti=nil end, 1000, 1)
        end
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

local noti=exports.px_noti

local wegTable={}
local timer=false

blip=false

local isWegRender=false
local gefundenerWeg=nil

local floor = math.floor
local function getAreaID(x, y)
	return floor((y + 3000)/750)*8 + floor((x + 3000)/750)
end

local function getNodeByID(db, nodeID)
	local areaID = floor(nodeID / 65536)
	if areaID<=63 and areaID>=0 then
		return db[areaID][nodeID]
	end
end

function findNodePosition(x,y)
	local startNode=-1
	local entfernung=10000
	local areaID = getAreaID(x, y)
	for j,row in pairs(vehicleNodes[areaID]) do
		local entfernungNodes=getDistanceBetweenPoints2D(x,y,row.x,row.y)
		if entfernung>entfernungNodes then
			entfernung=entfernungNodes
			startNode=row
		end
	end
	return startNode
end

function getPath(startNode, zielNode)
	local genutzteNodes = {}
	genutzteNodes[startNode.id] = true
	local aktuelleNodes = {}
	local wege = {}
	
	for id,distance in pairs(startNode.neighbours) do
		genutzteNodes[id] = true
		aktuelleNodes[id] = distance
		wege[id] = {startNode.id}
	end
	
	while true do
		local besterNode = -1
		local entfernung = 10000
		
		for aktId,aktDist in pairs(aktuelleNodes) do
			if aktDist<entfernung then
				besterNode = aktId
				entfernung = aktDist
			end
		end

		if besterNode==-1 then
			return {}
		end

		if zielNode.id == besterNode then
			local zuMalen = besterNode
			local wegPunkte={}
			local wegPunktID=1
			while (tonumber(zuMalen) ~= nil) do
				local wegNode = getNodeByID(vehicleNodes, zuMalen)
				wegPunkte[wegPunktID]=wegNode
				wegPunktID=wegPunktID+1		
				zuMalen = wege[zuMalen]
			end
			return wegPunkte
		end
		
		
		for nachbarID,nachbarDist in pairs(getNodeByID(vehicleNodes, besterNode).neighbours) do
			if not genutzteNodes[nachbarID] then
				wege[nachbarID] = besterNode
				aktuelleNodes[nachbarID] = entfernung+nachbarDist
				genutzteNodes[nachbarID] = true
			end
		end
		aktuelleNodes[besterNode] = nil
		
	end
end

function setGPSPosition(x,y,z,trigger)
	if(x and y and z)then
		setGPSClear()
		setGPSPositions(x,y,z)

		blip=createBlip(x,y,z,22)

		if(isPedInVehicle(localPlayer) and not trigger)then
			if(SPAM.getSpam())then return end

			triggerServerEvent('setGPSPosition', resourceRoot, getPedOccupiedVehicle(localPlayer), x, y, z)
		end
	end
end
addEvent('setGPSPosition', true)
addEventHandler('setGPSPosition', resourceRoot, setGPSPosition)

function setGPSPositions(zielx,ziely,z)
	lastx,lasty,lastz=zielx,ziely,z

	timer=setTimer(function()
		setGPSPosition(lastx,lasty)
	end, 5000, 1)

	wegSavex,wegSavey=zielx,ziely
	lastMarkerPositionX,lastMarkerPositionY,lastMarkerPositionZ=getElementPosition(getLocalPlayer())
	lastMarkerPositionZ=lastMarkerPositionZ-1
	local startNode = findNodePosition(lastMarkerPositionX,lastMarkerPositionY)
	local zielNode = findNodePosition(zielx,ziely)
	gefundenerWeg=getPath(startNode, zielNode)

	wegTable={}
	for i, wegNode in ipairs(gefundenerWeg) do
		if i==1 then
			wegTable[i]={}

			wegTable[i].lastmarker=createColSphere(wegNode.x, wegNode.y, wegNode.z,20)
			setElementData(wegTable[i].lastmarker, "last", true, false)

			wegTable[i].posX=wegNode.x
			wegTable[i].posY=wegNode.y
			wegTable[i].posZ=wegNode.z
			wegTable[i].ID=i
		else
			wegTable[i]={}

			wegTable[i].marker=createColSphere(wegNode.x, wegNode.y, wegNode.z,8)

			wegTable[i].posX=wegNode.x
			wegTable[i].posY=wegNode.y
			wegTable[i].posZ=wegNode.z
			wegTable[i].ID=i

			setElementData(wegTable[i].marker, "index", i, false)
		end
	end
end

addEventHandler("onClientColShapeHit", resourceRoot, function(hit, dim)
	if(localPlayer ~= hit or not dim)then return end

	local data=getElementData(source, "index")
	local last=getElementData(source, "last")
	if(data)then
		local wegTableNumber=data
		for i,row in ipairs(wegTable) do
			if row.ID>=wegTableNumber then 
				checkAndDestroy(wegTable[i].marker)
				
				lastMarkerPositionX,lastMarkerPositionY,lastMarkerPositionZ=wegTable[i].posX,wegTable[i].posY,wegTable[i].posZ

				wegTable[i]=nil

				if(timer)then
					killTimer(timer)
					timer=false
				end
				
				timer=setTimer(function()
					setGPSPosition(lastx,lasty,lastz)
				end, 5000, 1)
			end
		end
	elseif(last)then
		noti:noti("Dotarłeś do wyznaczonego celu.", "success")

		checkAndDestroy(source)
		setGPSClear()
	end
end)

function getGPSPositions()
	local tbl={}
	for i=#wegTable-40,#wegTable do
		if(wegTable[i])then
			tbl[#tbl+1]=wegTable[i]
		end
	end
	return tbl
end

function getGPSPositionsMax()
	return wegTable
end

function setGPSClear()
	if(timer)then
		killTimer(timer)
		timer=false
	end

	for i, row in ipairs(wegTable) do
		checkAndDestroy(row.marker)
		checkAndDestroy(row.lastmarker)
	end
	wegTable={}

	for i,v in ipairs(getElementsByType("colshape", resourceRoot)) do
		if(getElementData(v, "last") or getElementData(v, "index"))then
			checkAndDestroy(v)
		end
	end

	if(blip)then
		checkAndDestroy(blip)
		blip=false
	end
end

function checkAndDestroy(element)
	return isElement(element) and destroyElement(element)
end