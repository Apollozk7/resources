--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local no_damage = {
	[23] = true,
	[27] = true,
	[41]=true,
}

local only_aim = {
	[32] = true,
	[26] = true,
	[22] = true,
	[42]=true
}

function getDM()
	if(getElementData(localPlayer, "Area.InZone"))then
		toggleControl("fire", not only_aim[getPedWeapon(localPlayer)])
		toggleControl("aim_weapon", true)
		toggleControl("action", true)
	elseif(isElementInWater(localPlayer))then
		toggleControl("fire", true)
		toggleControl("aim_weapon", true)
		toggleControl("action", true)
	elseif(getElementData(localPlayer, "user:faction") == "SAPD")then
		if(getPedWeapon(localPlayer) == 0)then
			toggleControl("fire", false)
			toggleControl("aim_weapon", true)
			toggleControl("action", false)
		elseif no_damage[getPedWeapon(localPlayer)] and not getElementData(localPlayer, "user:gui_showed") then
			toggleControl("fire", true)
			toggleControl("aim_weapon", true)
			toggleControl("action", true)
		elseif only_aim[getPedWeapon(localPlayer)] and not getElementData(localPlayer, "user:gui_showed") then
			toggleControl("fire", false)
			toggleControl("aim_weapon", true)
			toggleControl("action", false)
		else
			if(not getElementData(localPlayer, "user:gui_showed"))then
				toggleControl("fire", true)
				toggleControl("aim_weapon", true)
				toggleControl("action", true)
			else
				toggleControl("fire", false)
				toggleControl("aim_weapon", false)
				toggleControl("action", false)
			end
		end
	else
		if no_damage[getPedWeapon(localPlayer)] then
			toggleControl("fire", true)
			toggleControl("aim_weapon", true)
			toggleControl("action", true)
		elseif only_aim[getPedWeapon(localPlayer)] then
			toggleControl("fire", false)
			toggleControl("aim_weapon", true)
			toggleControl("action", false)
		else
			toggleControl("fire", false)
			toggleControl("aim_weapon", false)
			toggleControl("action", false)
		end
	end
end

addEventHandler("onClientPlayerSpawn", root, function()
	setPlayerNametagShowing(root, false)
	toggleControl("fire", false)
	toggleControl("aim_weapon", false)
	toggleControl("action", false)
end)

addEventHandler("onClientPedDamage", root, function()
	cancelEvent()
end)

addEventHandler('onClientPlayerStealthKill', root, function(target)
    if(getElementType(target) == 'ped')then
        cancelEvent()
    end
end)