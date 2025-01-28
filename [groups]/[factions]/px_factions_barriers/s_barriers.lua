--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local CLASS={}

CLASS.objects={}

-- event

addEvent("create:object", true)
addEventHandler("create:object", resourceRoot, function(id, pos, rot)
    local have=exports.px_factions:isPlayerHaveAccess(getPlayerName(client),"Blokady")
    if(have)then
        if(id == 2892)then
            local have=exports.px_factions:isPlayerHaveAccess(getPlayerName(client),"Kolczatka")
            if(not have)then
                exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
                return
            end
        end
        
        if(not CLASS.objects[client])then
            CLASS.objects[client]={}
        else
            local last=0
            for i,v in pairs(CLASS.objects[client]) do
                last=i
            end
            
            if(last >= 100)then
                exports.px_noti:noti("Możesz postawić maksymalnie 100 zabezpieczeń.", client)
                return
            end
        end

        local index=#CLASS.objects[client]+1
        local object=createObject(tonumber(id) and id or 1337, pos[1], pos[2], pos[3], rot[1], rot[2], rot[3])
        setElementFrozen(object, true)

        if(not tonumber(id))then
            setElementData(object, "custom_name", id)
        end

        if(id == 2892)then
            local cs=createColSphere(pos[1], pos[2], pos[3], 5)
            setElementData(object, "quiver", cs, false)
        end

        setElementData(object, "interaction", {options={
            {name="Usuń obiekt", alpha=0, animate=false, tex=":px_factions_barriers/textures/destroy.png"},
        }, scriptName="px_factions_barriers", type="server", off3D=true})
        setElementData(object, "id", index, false)

        triggerClientEvent(root, "setBreakable", resourceRoot, object)

        CLASS.objects[client][index]=object
    else
        exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
    end
end)

addEvent("destroy:last:object", true)
addEventHandler("destroy:last:object", resourceRoot, function(id, pos, rot)
    if(CLASS.objects[client])then
        local last=0
        for i,v in pairs(CLASS.objects[client]) do
            last=i
        end

        if(last > 0)then
            local obj=CLASS.objects[client][last]

            local cs=getElementData(obj, "quiver")
            if(cs)then
                destroyElement(cs)
            end
    
            destroyElement(obj)
    
            CLASS.objects[client][last]=nil
        end
    end
end)

-- on hit cs

addEventHandler("onColShapeHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player" and isPedInVehicle(hit))then
        local x,y,z=getElementPosition(source)
        local veh=getPedOccupiedVehicle(hit)
		triggerClientEvent(hit, "hit:quiver", resourceRoot, x, y, z, veh)
    end
end)

addEventHandler("onColShapeLeave", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player" and isPedInVehicle(hit))then
		triggerClientEvent(hit, "hit:quiver", resourceRoot)
    end
end)

-- destroy

local ticks={}
function action(id, object, player, name)
    if(name == "Usuń obiekt")then
        if(not ticks[player] or (ticks[player] and (getTickCount()-ticks[player]) > 500))then
            ticks[player]=getTickCount()

            local index=getElementData(object, "id")
            if(not index)then return end

            if(CLASS.objects[player] and CLASS.objects[player][index])then
                local cs=getElementData(CLASS.objects[player][index], "quiver")
                if(cs)then
                    destroyElement(cs)
                end

                destroyElement(CLASS.objects[player][index])
                CLASS.objects[player][index]=nil
            end
        end
    end
end

-- on quit

addEventHandler("onPlayerQuit", root, function()
    if(CLASS.objects[source])then
        for i,v in pairs(CLASS.objects[source]) do
            local cs=getElementData(v, "quiver")
            if(cs)then
                destroyElement(cs)
            end

            destroyElement(v)
        end
        CLASS.objects[source]=nil
    end
end)

addEventHandler("onElementDataChange", root, function(data, last, new)
    if(data == "user:faction" and not new)then
        if(CLASS.objects[source])then
            for i,v in pairs(CLASS.objects[source]) do
                local cs=getElementData(v, "quiver")
                if(cs)then
                    destroyElement(cs)
                end
                
                destroyElement(v)
            end
            CLASS.objects[source]=nil
        end
    end
end)