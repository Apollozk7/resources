--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

setWeaponProperty(32, "poor", "weapon_range", 90)
setWeaponProperty(32, "std", "weapon_range", 90)
setWeaponProperty(32, "pro", "weapon_range", 90)

addEvent("interaction.admin", true)
addEventHandler("interaction.admin", resourceRoot, function(veh, id, pd)
	if(veh and isElement(veh))then
		local db = exports.px_connect
		local noti = exports.px_noti

		if(pd)then
			if(id == 1)then
				if(getElementData(veh, "vehicle:handbrake"))then
					setElementData(veh, "vehicle:handbrake", false)
					if(not getVehicleController(veh))then
						setElementFrozen(veh, false)
					end
					noti:noti("Pomyślnie ściągnięto ręczny.", client, "success")
				else
					setElementData(veh, "vehicle:handbrake", true)
					if(not getVehicleController(veh))then
						setElementFrozen(veh, true)
					end
					noti:noti("Pomyślnie zaciągnięto ręczny.", client, "success")
				end
			elseif(id > 1)then
				local ped=getVehicleController(veh)
				if(ped)then
					triggerClientEvent(ped, "get.screenshot", resourceRoot, pd)
					exports["px_factions-tablet"]:giveMandate(ped, "Przekroczenie prędkości", 100)
				end
			end
		elseif(id == 1)then
			fixVehicle(veh)
			noti:noti("Pojazd został naprawiony.", client)
		elseif(id == 2)then
			local _,ry,rz = getElementRotation(veh)
			setElementRotation(veh, 0, 0, rz)
			noti:noti("Pojazd został obrócony.", client)
		elseif(id == 3)then
			local group=getElementData(veh, "vehicle:group_id")
			if(group)then
				exports.px_groups_vehicles:saveVehicle(veh,'destroy')
				db:query("update groups_vehicles set parking=1 where id=?", group)
				noti:noti("Pojazd został odesłany na bazę.", client)
			else
				local i=getElementData(veh, "vehicle:id")
				local owner=getElementData(veh, "vehicle:owner")
				if(owner and i)then
					local parking_id=db:query("select id from vehicles_garages where playerID=? limit 1", owner)
					if(parking_id and #parking_id == 1)then
						noti:noti("Pojazd został oddany na parking.", client)
						exports.px_vehicles:saveVehicle(veh,'destroy')

						db:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, i)
					else
						exports.px_connect:query("INSERT INTO vehicles_garages SET playerID=?", owner)

						local parking_id=db:query("select id from vehicles_garages where playerID=? limit 1", owner)
						if(parking_id and #parking_id == 1)then
							noti:noti("Pojazd został oddany na parking.", client)
							exports.px_vehicles:saveVehicle(veh,'destroy')
		
							db:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, i)
						end
					end
				else
					if getElementData(veh, "un:destroyed") then
						noti:noti("Nie możesz usunąć tego pojazdu.", client)
					else
						destroyElement(veh)
						noti:noti("Pomyślnie usunięto pojazd", client)
					end
				end
			end
		elseif(id == 4)then
			local x,y,z = getElementPosition(client)
			if getElementData(veh, "un:destroyed") then
				noti:noti("Nie możesz przenieść tego pojazdu.", client)
			else
				setElementPosition(veh, x, y-3, z)
			end
		elseif(id == 5)then
			local x,y,z = getElementPosition(veh)
			setElementPosition(client, x, y-3, z)
		elseif(id == 6)then
			local i = getElementData(veh, "vehicle:id")
			if not i then return end
			warpPedIntoVehicle(client,veh)
		elseif(id == 7)then
			local fuel = getElementData(veh, "vehicle:fuel") or 0
			if(fuel < 5)then
				setElementData(veh, "vehicle:fuel", 5)
				noti:noti("Pojazd został zatankowany.", client)
			end
		elseif(id == 8)then
			if(getElementData(veh, "vehicle:handbrake"))then
				setElementData(veh, "vehicle:handbrake", false)
				if(not getVehicleController(veh))then
					setElementFrozen(veh, false)
				end
				noti:noti("Pomyślnie ściągnięto ręczny.", client, "success")
			else
				setElementData(veh, "vehicle:handbrake", true)
				if(not getVehicleController(veh))then
					setElementFrozen(veh, true)
				end
				noti:noti("Pomyślnie zaciągnięto ręczny.", client, "success")
			end
		end
	end
end)

addEventHandler('onVehicleEnter', root, function(plr,seat)
	if(seat == 0 and source and isElement(source))then
		setElementData(source, 'vehicle:lastUse', getTimestamp())
	end
end)

addEventHandler('onVehicleExit', root, function(plr,seat)
	if(seat == 0 and source and isElement(source))then
		setElementData(source, 'vehicle:lastUse', getTimestamp())
	end
end)

-- useful

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end