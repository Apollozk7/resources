--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

-- resp

ui.places={
	{1694.0825,2025.1497,10.4203,143.5777},
	{1693.5199,2028.7393,10.4205,142.1316},
	{944.6885,1725.1036,8.4504,269.3645},
	{1173.6998,1365.4635,10.4100,54.3418},
	{1175.6370,1368.4231,10.4203,63.9882},
	{2379.4033,1495.9482,10.4207},
	{2415.4561,1495.3369,10.4270,147.6828},
	{2439.4229,2343.2505,10.4200,92.0562},
	{2248.7432,-80.3860,26.1109,213.1371},
	{2248.3140,-83.3148,26.1044,227.5089},
	{220.0450,-180.6835,1.1783,93.4493},
	{-190.4994,1212.4983,19.3417,118.8547},
	{-769.6135,1556.3494,26.7129,32.3995},
	{-773.6937,1555.3538,26.7163,37.5267},
	{-257.3365,2611.3750,62.4577,239.7233},
	{1349.9867,235.7910,18.9829,335.3007},
	{1394.1758,265.2605,18.9818,155.2764},
	{-2247.0769,2367.3315,4.5890,109.8043},
	{-1916.2672,866.0422,35.0123,358.0604},
	{-1921.2572,866.3594,35.0127,356.3698},
	{-1917.7559,901.3372,35.0131,176.7743},
	{-1922.7533,901.4960,35.0135,178.4662},
	{-2398.9683,-617.9633,132.3332,326.4935},
	{-2394.3174,-616.1265,132.3331,25.6196},
	{-2285.6565,152.1701,34.6478,146.8459},
	{-2287.8821,160.5641,34.6499,81.6967},
}

ui.createPublicVeh=function(id)
	local pos=ui.places[id]
	if(pos)then
		if(pos.veh and isElement(pos.veh))then return end
		
		local veh=createVehicle(getVehicleModelFromName("Faggio"),pos[1],pos[2],pos[3],0,0,pos[4])
		setElementFrozen(veh, true)
		setElementData(veh, "public:vehicle", true)
		setElementData(veh, "un:destroyed", true)
		setElementData(veh, "ghost", "all")
		setElementData(veh, "text", "Pojazd publiczny")
		setVehicleHandling(veh, "maxVelocity", 60)

		pos.veh=veh
	end
end

for i,v in pairs(ui.places) do
	v.cs=createColSphere(v[1], v[2], v[3], 1.25)
	setElementData(v.cs, "public_id", i, false)
	ui.createPublicVeh(i)
end

addEventHandler("onColShapeLeave", resourceRoot, function(hit, dim)
	if(not hit or hit and not isElement(hit) or hit and isElement(hit) and getElementType(hit) ~= "player" or not dim)then return end

	local veh = getPedOccupiedVehicle(hit)
	if(not veh or veh and not isElement(veh) or veh and isElement(veh) and not getElementData(veh, "public:vehicle"))then return end

	local id=getElementData(source, "public_id")
	if(not id)then return end

	local pos=ui.places[id]
	if(not pos.timer)then
		pos.timer=setTimer(function(shape)
			local v = getElementsWithinColShape(shape, "vehicle")
			if(#v < 1)then
				ui.createPublicVeh(id)
				pos.timer=nil
			end
		end, 1000, 0, source)
	end
end)

--

-- zajmowanie

ui.vehicle={}
ui.timer={}

ui.onStartEnter = function(player, seat)
	if(seat ~= 0)then return end

	if(getElementData(source, "public:owner") and getElementData(source, "public:owner") ~= player)then
		exports.px_noti:noti("Ten pojazd publiczny, jest już zajęty.", player)
		cancelEvent()
	elseif(ui.vehicle[player] and ui.vehicle[player] ~= source)then
		exports.px_noti:noti("Wziąłeś swój pojazd publiczny.", player)
		cancelEvent()
	end
end

ui.onEnter = function(player, seat)
	if(seat ~= 0)then return end

	setElementData(source, "public:owner", player)
	setElementData(source, "text", "Pojazd publiczny - #149648"..getPlayerName(player))

	if(ui.timer[player] and isTimer(ui.timer[player]))then
		killTimer(ui.timer[player])
		ui.timer[player] = nil
	end

	ui.vehicle[player] = source

	setTimer(function()
		if(ui.vehicle[player] and isElement(ui.vehicle[player]))then
			setElementFrozen(ui.vehicle[player], false)
		end
	end, 500, 1)
end

ui.onExit = function(player, seat)
	if(seat ~= 0)then return end

	exports.px_noti:noti("Jeśli nie wrócisz za 15 sekund, twój pojazd publiczny zniknie.", player)

	ui.timer[player] = setTimer(function(vehicle)
		if(vehicle and isElement(vehicle))then
			destroyElement(vehicle)
		end

		if(player and isElement(player))then
			ui.timer[player] = nil
			ui.vehicle[player] = nil
		end
	end, (1000 * 15), 1, source)
end

addEventHandler("onVehicleStartEnter", resourceRoot, ui.onStartEnter)
addEventHandler("onVehicleEnter", resourceRoot, ui.onEnter)
addEventHandler("onVehicleExit", resourceRoot, ui.onExit)
addEventHandler("onPlayerQuit", root, function()
	local player=source

	if(ui.vehicle[player] and isElement(ui.vehicle[player]))then
		destroyElement(ui.vehicle[player])
		ui.vehicle[player]=nil
	end

	if(ui.timer[player] and isTimer(ui.timer[player]))then
		killTimer(ui.timer[player])
		ui.timer[player] = nil
	end
end)