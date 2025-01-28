--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function findFreeID(id)
	table.sort(id)

	local free = 0
	for i,v in pairs(id) do
		if(v == free)then
			free = free + 1
        end

        if(v > free)then
            free = free
            break
		end
	end

	return free
end

function findPlayer(target)
	local player = false
	local findByName = getPlayerFromName(target)

	if(findByName)then
		return findByName
	end

	for i,v in pairs(getElementsByType("player")) do
		if tonumber(target) then
			if getElementData(v, "user:id") == tonumber(target) then
				player = v
				break
			end
		else
			if string.find(string.gsub(getPlayerName(v):lower(),"#%x%x%x%x%x%x", ""), target:lower(), 1, true) then
				player = v
				break
			end
		end
	end
	return player
end

addEventHandler("onPlayerJoin", root, function()
	if(source and isElement(source))then
		local id = {}
		for i,v in pairs(getElementsByType("player")) do
			local ids = getElementData(v, "user:id")
			if(ids)then
				table.insert(id, tonumber(ids))
			end
		end

		local free = findFreeID(id)
		if(free)then
			setElementData(source, "user:id", free)
		end
	end
end)