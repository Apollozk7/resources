--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local factions=exports.px_factions
local noti=exports.px_noti

local Item={}

Item.Elements={}

local markers={
    {2278.7483,2443.6521,22.6508,name="SAPD",type="vehicle",dim=997},
    {2284.7412,2455.7612,22.6562,name="SAPD",type="skins",dim=997},
    {2509.1089,924.9531,14.3750,name="SACC",type="skins",dim=0},
    {55.2508,-332.4896,1.7656,name="SARA",type="skins",dim=0},
    {-2050.1279,-175.7759,35.5000,name="PSP",type="skins",dim=0},
}

for i,v in pairs(markers) do
    if(v.type == "skins")then
        marker=createMarker(v[1], v[2], v[3]-0.8, "cylinder", 1, 0, 200, 100)
        setElementData(marker, "icon", ":px_clothes/assets/textures/skinchangerMarker.png")
    else
        marker=createMarker(v[1], v[2], v[3]-0.8, "cylinder", 1, 255, 0, 0)
        setElementData(marker, "icon", ":px_factions_items/textures/markerStart.png")
    end

    setElementData(marker, "i", {v.name,v.type}, false)
    setElementDimension(marker, v.dim)
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local data=getElementData(source, "i")
        if(not data)then return end

        if(getElementData(hit, "user:faction") == data[1])then
            triggerClientEvent(hit, "open.ui", resourceRoot, getElementData(source, "i"))
        end
    end
end)

-- items

Item.UsePlayerItem=function(player)
    if(Item.Elements[player] and not Item.Elements[player].World)then
        Item.Elements[player].Using=true
    end
end
function usePlayerItem(...) return Item.UsePlayerItem(...) end

Item.DestroyPlayerItem=function(player)
    if(Item.Elements[player])then
        checkAndDestroy(Item.Elements[player].Object)
        Item.Elements[player]=nil
    end
    setPedWalkingStyle(player,0)

    unbindKey(player, "Q", "down", Item.getItem)

    setElementData(player, "factionItems:have", false)
    setElementData(player, "factionItem", false)
end
function destroyPlayerItem(...) return Item.DestroyPlayerItem(...) end

Item.IsPlayerHaveItem=function(player,name)
    if(Item.Elements[player] and not Item.Elements[player].Using and Item.Elements[player].ID == name and not Item.Elements[player].World)then
        return true
    end
    return false
end
function isPlayerHaveItem(...) return Item.IsPlayerHaveItem(...) end

Item.getItem=function(player)
    if(Item.Elements[player] and not Item.Elements[player].Using)then
        if(not Item.Elements[player].World)then
            Item.Elements[player].World=true

            exports.pAttach:detachElementFromBone(Item.Elements[player].Object)

            local x,y,z=getElementPosition(player)
            setElementPosition(Item.Elements[player].Object,x,y,z-0.8)
            setElementRotation(Item.Elements[player].Object,0,0,0)

            setPedWalkingStyle(player,0)
        else
            Item.Elements[player].World=false

            if(Item.Elements[player].pAttach)then
                exports.pAttach:attachElementToBone(Item.Elements[player].Object, player, 25, unpack(Item.Elements[player].pAttach))           
            end

            if(not Item.Elements[player].stopAnim)then
                setPedWalkingStyle(player,66)
            end
        end
    end
end

addEvent("use.item", true)
addEventHandler("use.item", resourceRoot, function(item)
    noti=exports.px_noti
    
    if(haveAccess(client,item.access) and haveRole(client,item.role))then
        if(item.armor)then
            setPedArmor(client, 100)
        elseif(item.gun)then
            local have=getPedWeapons(client)
            if(have and not have[item.gun])then
                giveWeapon(client, item.gun, item.ammo, true)
            else
                takeWeapon(client, item.gun)
            end
        elseif(item.skin)then
            if(not tonumber(item.id))then
                setElementData(client, "custom_name", item.id) -- nadajemy custom skina
            else
                setElementModel(client, item.id)
                if(item.sound)then
                    triggerClientEvent(client, "start.sound", resourceRoot, "aodo")
                end
            end
        elseif(item.type and item.name)then
            if(not Item.Elements[client])then
                if(not item.pAttach)then
                    exports.px_workshops:getTire(client)
                    return
                end

                local model=tonumber(item.id) and tonumber(item.id) or 1337

                Item.Elements[client]={
                    Object=createObject(model,0,0,0),
                    ID=item.name,
                    pAttach=item.pAttach,
                    stopAnim=item.stopAnim
                }

                if(item.scale)then
                    setObjectScale(Item.Elements[client].Object, item.scale)
                end
                
                if(not tonumber(item.id))then
                    setElementData(Item.Elements[client].Object, "custom_name", item.id)
                end

                if(item.pAttach)then
                    exports.pAttach:attachElementToBone(Item.Elements[client].Object, client, 25, unpack(item.pAttach))           
                end

                if(not item.stopAnim)then
                    setPedWalkingStyle(client,66)
                end

                bindKey(client, "Q", "down", Item.getItem)

                setElementData(client, "factionItem", Item.Elements[client].Object)
                setElementData(client, "factionItems:have", item.name)
            else
                if(not Item.Elements[client].Using)then
                    checkAndDestroy(Item.Elements[client].Object)
                    Item.Elements[client]=nil

                    setPedWalkingStyle(client,0)

                    unbindKey(client, "Q", "down", Item.getItem)

                    setElementData(client, "factionItems:have", false)
                    setElementData(client, "factionItem", false)
                end
            end
        end
    else
        noti:noti("Nie posiadasz uprawnień.", client, "error")
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if(Item.Elements[source])then
        checkAndDestroy(Item.Elements[source].Object)
        Item.Elements[source]=nil
    end
end)

-- useful

function checkAndDestroy(el)
    return isElement(el) and destroyElement(el) or nil
end

function getPedWeapons(ped)
	local playerWeapons = {}
	if ped and isElement(ped) and getElementType(ped) == "ped" or getElementType(ped) == "player" then
		for i=1,12 do
			local wep = getPedWeapon(ped,i)
			if wep and wep ~= 0 then
                playerWeapons[wep]=true
			end
		end
	else
		return false
	end
	return playerWeapons
end

function haveAccess(player,access)
    if(access)then
        factions=exports.px_factions
        local have=factions:isPlayerHaveAccess(getPlayerName(player),access)
        return have
    end
    return true
end

function haveRole(player,role)
    if(role)then
        factions=exports.px_factions
        local have=factions:isPlayerHaveRole(getPlayerName(player),role)
        return have
    end
    return true
end