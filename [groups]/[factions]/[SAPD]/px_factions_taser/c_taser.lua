--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function damage(_, wep, bodypart, ile)
	local player = source
	if wep == 23 or wep == 3 then
		if(player == localPlayer)then
			toggleControl("all",false)
			setElementFrozen(player, true)
		end

		setPedAnimation(player, "CRACK", "crckdeth2", 0.0, false, true, false)
		setTimer(function()
			if(player == localPlayer)then
				setElementFrozen(player, false)
				toggleControl("all",true)
				toggleControl("radar",false)
			end

			setPedAnimation(player, "CARRY", "liftup", 0.0, false, false, false, false)
		end, 30000, 1)
		
		setElementHealth(player, getElementHealth(player)+ile)
	end
end

addEventHandler("onClientPedDamage", getRootElement(), damage)
addEventHandler("onClientPlayerDamage", getRootElement(), damage)