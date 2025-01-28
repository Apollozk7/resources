--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent("set.int", true)
addEventHandler("set.int", resourceRoot, function(int,dim)
    setElementInterior(client,int)
    setElementDimension(client, dim)
    triggerClientEvent(client, "get.render", resourceRoot)
end)

local handcuffs={}

function putHandcuffs(player, policeman)
    local pData=getElementData(player, "user:handcuffs")
    local policeData=getElementData(policeman, "police:handcuffs")
    if(pData and policeData and pData == policeman and policeData == player)then
        setElementData(policeman, "police:handcuffs", false)
        setElementData(player, "user:handcuffs", false)
        detachElements(player)
        setElementCollisionsEnabled(player, true)
        setPedAnimation(player,false)
    else
        if(not pData and not policeData)then
            setElementData(policeman, "police:handcuffs", player)
            setElementData(player, "user:handcuffs", policeman)
            attachElements(player, policeman, 0, 0.5, 0)
            setElementCollisionsEnabled(player, false)
            setPedAnimation ( player, "FAT", "IDLE_tired", -1, true, false )
            exports.px_noti:noti("Zostałeś zakuty w kajdanki przez "..getPlayerName(policeman), player, "info")
        end
    end
end

function putInHandcuffs(policeman, vehicle)
    local player=getElementData(policeman, "police:handcuffs")
    if(player)then
        detachElements(player)
        setElementCollisionsEnabled(player, true)
        setPedAnimation(player,false)

        if(not getVehicleOccupant(vehicle, 2))then
            warpPedIntoVehicle(player, vehicle, 2)
        elseif(not getVehicleOccupant(vehicle, 3))then
            warpPedIntoVehicle(player, vehicle, 3)
        else
            warpPedIntoVehicle(player, vehicle, 1)
        end
    end
end

function takeOutHandcuffs(policeman, vehicle)
    local player=getElementData(policeman, "police:handcuffs")
    if(player)then
        removePedFromVehicle(player)
        attachElements(player, policeman, 0, 0.5, 0)
        setElementCollisionsEnabled(player, false)
        setPedAnimation ( player, "FAT", "IDLE_tired", -1, true, false )
    end
end

addCommandHandler("zakuj", function(player,_,target)
    if(getElementData(player, "user:faction") == "SAPD")then
        if(target)then
            target=exports.px_core:findPlayer(target)
            if(not target)then
                exports.px_noti:noti("Nie znaleziono podanego gracza.", player, "error")
                return
            end

            local myPos={getElementPosition(player)}
            local hisPos={getElementPosition(target)}
            local dist=getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], hisPos[1], hisPos[2], hisPos[3])
            if(dist <= 10)then
                putHandcuffs(target,player)
                exports["px_dm-robbery"]:stopRobbery(target)
            else
                exports.px_noti:noti("Ten gracz znajduje się za daleko.", player, "error")
            end
        else
            exports.px_noti:noti("Poprawne użycie: /zakuj <nick/id>", player, "error")
        end
    end
end)

function action(id,target,player,name)
    if(name == "Rozkuj" or name == "Zakuj")then
        putHandcuffs(target,player)
        if(name == "Zakuj")then
            exports["px_dm-robbery"]:stopRobbery(target)
        end
    elseif(name == "Wsadź")then
        putInHandcuffs(player,target)
    elseif(name == "Wysadź")then
        takeOutHandcuffs(player,target)
    elseif(name == "Wysadź pasażerów")then
        local x,y,z=getElementPosition(player)
        for i,v in pairs(getVehicleOccupants(target)) do
            removePedFromVehicle(v)

            setElementPosition(v, x, y+1, z)
            setElementFrozen(v, true)
            setTimer(function()
                if(v and isElement(v))then
                    setElementFrozen(v, false)
                end
            end, 10000, 1)
        end
    end
end

addEventHandler("onPlayerQuit", root, function()
    local hand=getElementData(source, "user:handcuffs")
    if(hand)then
        setElementData(hand, "police:handcuffs", false)
    end

    local hand=getElementData(source, "police:handcuffs")
    if(hand)then
        setElementData(hand, "user:handcuffs", false)
    end
end)

addEventHandler("onVehicleStartExit", root, function(player)
    if(getElementData(player, "user:handcuffs"))then
	    cancelEvent()
    end
end)