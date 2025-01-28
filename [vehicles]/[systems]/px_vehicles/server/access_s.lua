--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEventHandler("onVehicleStartEnter", root, function(player, seat)
    if(seat ~= 0)then return end

	if(getVehicleController(source) ~= player)then
		cancelEvent()
	end
end)

addEventHandler("onVehicleEnter", root, function(player, seat)
    if(seat ~= 0)then return end

	local name=getPlayerName(player)
	local lastDrivers=getElementData(source, "vehicle:lastDrivers") or {}
	if(lastDrivers[4] and lastDrivers[4] == name)then return end

	table.insert(lastDrivers, name)

	if(#lastDrivers >= 5)then
		table.remove(lastDrivers, 1)
	end

	setElementData(source, "vehicle:lastDrivers", lastDrivers)
end)

-- auto-zapis pozycji
local lastSave={}
addEventHandler("onVehicleExit", resourceRoot, function()
	if((lastSave[source] and (getTickCount()-lastSave[source]) > 300000))then
		VEH.saveVehicle(source)
		lastSave[source]=nil
	else
		VEH.saveVehicle(source)
		lastSave[source]=getTickCount()
	end
end)

local prawko = {
    ["A"] = {
        [462] = true,
        [448] = true,
        [581] = true,
        [522] = true,
        [461] = true,
        [521] = true,
        [523] = true,
        [463] = true,
        [586] = true,
        [463] = true,
        [471] = true,
        [468] = true,
    },

    ["C"] = {
        [408] = true,
        [416] = true,
        [433] = true,
        [427] = true,
        [528] = true,
        [407] = true,
        [544] = true,
        [601] = true,
        [428] = true,
        [499] = true,
        [609] = true,
        [498] = true,
        [524] = true,
        [578] = true,
        [573] = true,
        [455] = true,
        [588] = true,
        [423] = true,
        [414] = true,
        [456] = true,
		[431]=true,
		[437]=true,
		[573]=true,
		[443] = true,
    },

    ["C+E"] = {
        [403] = true,
        [515] = true,
        [514] = true,
    },

    ["L"] = {
        [548] = true,
        [425] = true,
        [417] = true,
        [487] = true,
        [497] = true,
        [563] = true,
        [447] = true,
        [469] = true,
        [592] = true,
        [577] = true,
        [511] = true,
        [512] = true,
        [583] = true,
        [520] = true,
        [553] = true,
        [476] = true,
        [519] = true,
        [460] = true,
        [513] = true,
		[593]=true,
	},

    ["OFF"] = {
        [509] = true,
        [481] = true,
        [510] = true,
    },

    --reszta to kategoria B :)
}

function isPlayerHavePJ(player, vehicle_model)
	local uid=getElementData(player, "user:uid")
	if(not uid)then return end

	if(getElementData(player, "user:admin"))then
		return true
	end

	if(prawko["L"][vehicle_model])then
		local take = getElementData(player, "user:license_l_take")
		if(take)then
			outputChatBox("-------------------------------------------", player, 255, 0, 0)
			outputChatBox("Posiadasz zawieszone licencje lotnicze!", player, 255, 0, 0)
			outputChatBox("Osoba zawieszająca: "..take["admin"], player, 255, 0, 0)
			outputChatBox("Powód zawieszenia: "..take["reason"], player, 255, 0, 0)
			outputChatBox("Czas zawieszenia: "..take["date"], player, 255, 0, 0)
			outputChatBox("----------------------------------------", player, 255, 0, 0)

			exports.px_custom_chat:addMessage("Twoje licencje lotnicze zostały zawieszone przez "..take.admin..", z powodu "..take.reason.." do "..take.date, player, false, tocolor(255,0,0))
			
			return false
		end
	else
		local take = getElementData(player, "user:license_take")
		if(take)then
			outputChatBox("-------------------------------------------", player, 255, 0, 0)
			outputChatBox("Posiadasz zawieszone prawo jazdy!", player, 255, 0, 0)
			outputChatBox("Osoba zawieszająca: "..take["admin"], player, 255, 0, 0)
			outputChatBox("Powód zawieszenia: "..take["reason"], player, 255, 0, 0)
			outputChatBox("Czas zawieszenia: "..take["date"], player, 255, 0, 0)
			outputChatBox("----------------------------------------", player, 255, 0, 0)

			exports.px_custom_chat:addMessage("Twoje prawo jazdy zostało zawieszone przez "..take.admin..", z powodu "..take.reason.." do "..take.date, player, false, tocolor(255,0,0))
			
			return false
		end
	end

	local lic=getElementData(player, "user:licenses") or {}
	local have=false
	local p=prawko["OFF"][vehicle_model] and "OFF" or prawko["C"][vehicle_model] and "c" or prawko["C+E"][vehicle_model] and "c+e" or prawko["L"][vehicle_model] and "l1" or false
	if(p)then
		if(p == "OFF")then
			have=true
		else
			if(lic and lic[p] == 2)then
				have=true
			end
		end
	else
		if(lic and lic["b"] == 2)then
			have=true
		end
	end

	if(not have)then
		exports.px_noti:noti("Aby kierować ten pojazd musisz posiadać odpowiednie prawo jazdy.", player)
	end

	return have
end

function isPlayerHaveAccessToVehicle(player, vehicle)
	local uid=getElementData(player, "user:uid")
	if(not uid)then return end

	local friends=getElementData(player, 'friends:data') or {}
	local org=getElementData(player, "user:organization")
	if(isElement(vehicle))then
		local group_owner=getElementData(vehicle, "vehicle:group_owner")
		local owner=getElementData(vehicle, "vehicle:owner")
		local ownerName=getElementData(vehicle, "vehicle:ownerName")
		local v_org=getElementData(vehicle, "vehicle:organization")
		local orgRank=getElementData(vehicle, "vehicle:orgRank")
		local keys=getElementData(vehicle, "vehicle:keys") or {}
		local id=getElementData(vehicle, 'vehicle:id')

		local isPlayerHaveKeys=false
		for i,v in pairs(keys) do
			if(tonumber(v.uid) == tonumber(uid))then
				isPlayerHaveKeys=i
				break
			end
		end

		if(v_org and org and v_org == org)then
			local rank_id=exports.px_organizations:getPlayerRankID(getPlayerName(player)) or 1
			orgRank=orgRank or 1

			if(owner == uid)then
				return true
			elseif(rank_id <= orgRank)then
				return true
			end
		elseif(isPlayerHaveKeys)then
			return true
		else
			return (group_owner and group_owner == uid) or (owner and owner == uid)
		end
	end
	return false
end

addEventHandler("onVehicleStartEnter", root, function(player, seat)
	if(seat ~= 0 or getElementData(player, "user:admin") and getElementData(player, "user:admin") >= 3)then return end

	local uid=getElementData(player, "user:uid")
	local owner=getElementData(source, "vehicle:owner")
	if(getElementData(source, "public:vehicle"))then return end

	if(not isPlayerHavePJ(player, getElementModel(source)))then
		cancelEvent()
	end
end)

addEventHandler("onVehicleEnter", resourceRoot, function(player, seat)
	if(seat ~= 0 or getElementData(player, "user:admin") and getElementData(player, "user:admin") >= 3)then return end

	local uid=getElementData(player, "user:uid")
	local owner=getElementData(source, "vehicle:owner")

	if(not isPlayerHavePJ(player, getElementModel(source)))then
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
	if(seat ~= 0 or (getElementData(player, "user:admin") and getElementData(player, "user:admin") >= 3))then return end

	if(not isPlayerHaveAccessToVehicle(player, source))then
		exports.px_noti:noti("Nie posiadasz kluczyków do tego pojazdu.", player)
		cancelEvent()
	end
end)