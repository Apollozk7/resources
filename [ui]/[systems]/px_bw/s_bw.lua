--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function healPlayer(player, friend)
    triggerClientEvent(player, 'stopBW', resourceRoot)

    local hand_data=getElementData(player, "user:handcuffs")
    local x,y,z = getElementPosition(player)

    if(isElementInWater(player) and not hand_data)then
        x,y,z=1641.5842,2055.1458,10.6250
    end

    if(not friend and getElementData(player, 'Area.InZone') and not hand_data)then
        x,y,z=1479.9954,-1655.0470,14.0469 -- spawn LS
    end

    spawnPlayer(player, x, y, z, 0, getElementModel(player), getElementInterior(player), getElementDimension(player))
    setElementHealth(player, math.random(5,8))
    setCameraTarget(player, player)

    setElementData(player, "user:bw", false)

    if(not exports.px_achievements:isPlayerHaveAchievement(player, "To bolało"))then
        exports.px_achievements:getAchievement(player, "To bolało")
    end

    -- dm
    if(getElementData(player, "Area.InZone"))then
        exports.px_noti:noti("Będziesz posiadał ochronę przed zabiciem przez następną minute.", player, "info")
        setElementData(player, "DM_Guard", getElementHealth(player))
        setElementHealth(player,100)
        setElementData(player, "user:inv", true)
        setElementAlpha(player, 100)
        setTimer(function()
            if(player and isElement(player))then
                setElementHealth(player,(getElementData(player,"DM_Guard") or 100))
                setElementData(player, "DM_Guard", false)
                setElementData(player, "user:inv", false)
                setElementAlpha(player, 255)
            end
        end, (1000*60), 1)
    end
    setElementData(player, "user:robbered", false)

    -- handcuffs
    if(hand_data)then
        attachElements(player,hand_data,0,0.5,0)
    end

    -- stats
    for _, stat in ipairs({71,72,76,77,78}) do
        setPedStat(player, stat, 1000)
    end
end

addEvent("bw.spawn", true)
addEventHandler("bw.spawn", resourceRoot, function(player)
    if(getElementType(client) ~= 'player')then return end

    if(player)then
        if(getElementType(player) ~= "player")then return end

        exports.px_noti:noti("Po udanej próbie reanimacji przez "..getPlayerName(client)..", udało Ci się przeżyć.", player, "success")
        exports.px_quests:updateQuest(client, "Pomóż wstać osobie, która ma BW", 1)

        healPlayer(player, true)
        return
    end

    healPlayer(client)
end)

addEventHandler('onPlayerWasted', root, function()
    if(getElementData(source, "DM_Guard"))then
        healPlayer(source, true)
    end
end)

addEventHandler("onPlayerWeaponFire", root, function(weapon, endX, endY, endZ, hitElement, startX, startY, startZ)
    local player=source
    if(hitElement and getElementType(hitElement) == "player" and getElementData(player, "DM_Guard"))then
        setElementHealth(player,getElementData(player,"DM_Guard") or 100)
        setElementData(player, "DM_Guard", false)
        setElementData(player, "user:inv", false)
        setElementAlpha(player, 255)
    end
end)

for i,v in pairs(getElementsByType('player')) do
    if(getElementData(v, 'user:bw'))then
        healPlayer(v, true)
    end
end