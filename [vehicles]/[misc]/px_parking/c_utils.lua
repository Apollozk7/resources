--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

local noti=exports.px_noti

function getParkingIDByInCol(col)
    for i, v in pairs(parking.list) do
        if v.inCol == col then return i end
    end
    return false
end

function getParkingIDByEnter(enter)
    for i, v in pairs(parking.list) do
        if v.enter == enter then return i end
    end
    return false
end

function sendNotification(text, type)
    exports.px_noti:noti(text, type)
end

--do napisania na podstawie systemu pojazdow
function isVehiclePrivate(vehicle)
    return getElementData(vehicle, "vehicle:id")
end

function click(x, y, w, h)
    if not parking.clickblock and getKeyState("mouse1") and isMouseInPosition(x, y, w, h) then return true end
    return false
end

function isMouseInPosition(x, y, w, h)
    if not isCursorShowing() then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = sx*cx, sy*cy
    return (( cx >= x and cx <= x + w ) and ( cy >= y and cy <= y + h ))
end

function findPlayer(target)
	local player = false
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


function getPlayerUID(player)
    return getElementData(player, "user:uid")
end

function isVehiclePrivate(vehicle)
    return getElementData(vehicle, "vehicle:id")
end