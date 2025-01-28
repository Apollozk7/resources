--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local weapons={}

local back={
    [349]=true,
    [355]=true,
    [356]=true,
    [357]=true,
    [358]=true,
    [359]=true,
    [360]=true,
}

function attachWeapon(player, weaponID)
    if(weapons[player])then return end 

    weapons[player]=createObject(weaponID, 0, 0, 0)

    exports["pAttach"]:attach(weapons[player], player, 3, -0.01, -0.11, 0, 180, 0, 0)

    addEventHandler("onClientRender", root, render)
end

function destroyWeapon(player)
    if(weapons[player] and isElement(weapons[player]))then
        destroyElement(weapons[player])
        weapons[player]=nil
    end
    removeEventHandler("onClientRender", root, render)
end

function render()
    local player=localPlayer
    if(weapons[player] and isElement(weapons[player]))then
        setElementDimension(weapons[player], getElementDimension(player))
        setElementInterior(weapons[player], getElementInterior(player))
    end
end

addEventHandler("onClientPlayerWeaponSwitch", localPlayer, function(last)
    if(weapons[source] and getElementModel(weapons[source]) == getID(getPedWeapon(source)))then
        setElementData(source, "custom:create_weapon", false)
        return
    end

    local weapon=getPedWeapon(source, last)
    if(weapon and not isPedInVehicle(source))then
        local id=getID(weapon)
        if(back[id])then
            setElementData(source, "custom:create_weapon", id)
        end
    end
end)

addEventHandler("onClientPlayerVehicleEnter", root, function()
    setElementData(source, "custom:create_weapon", false)
    destroyWeapon(source)
end)

addEventHandler("onClientPlayerWasted", root, function()
    setElementData(source, "custom:create_weapon", false)
    destroyWeapon(source)
end)

addEventHandler("onClientPlayerQuit", root, function()
    setElementData(source, "custom:create_weapon", false)
    destroyWeapon(source)
end)

addEventHandler("onClientElementDataChange", root, function(data, _, new)
    if(data == "custom:create_weapon" and isElementStreamedIn(source))then
        if(not new)then
            destroyWeapon(source)
        else
            attachWeapon(source, new)
        end
    elseif(data == "user:faction" and _ == 'SAPD')then
        setElementData(source, "custom:create_weapon", false)
        destroyWeapon(source)
    end
end)

addEventHandler("onClientElementStreamIn", root, function()
    local d=getElementData(source, "custom:create_weapon")
    if(d)then
        attachWeapon(source, d)
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    destroyWeapon(source)
end)

setElementData(localPlayer, "custom:create_weapon", false)

-- useful

function getID(weapon)
	local m
	if weapon > 1 and weapon < 9 then
		m = 331 + weapon
	elseif weapon == 9 then
		m = 341
	elseif weapon == 15 then
		m = 326
	elseif (weapon > 21 and weapon < 30) or (weapon > 32 and weapon < 39) or (weapon > 40 and weapon < 44) then
		m = 324 + weapon
	elseif weapon > 29 and weapon < 32 then
		m = 325 + weapon
	elseif weapon == 32 then
		m = 372
	end
	return m
end