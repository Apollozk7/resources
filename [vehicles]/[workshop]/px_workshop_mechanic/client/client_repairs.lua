--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function _getVehicleComponentPosition(veh,name,type)
    local pos={getVehicleComponentPosition(veh, name, type)}
    if(not pos or not pos[1] or not pos[2] or not pos[3])then
        pos={getVehicleComponentPosition(veh, "windscreen_dummy", type)}
    end

    if(not pos or not pos[1] or not pos[2] or not pos[3])then
        pos={getElementPosition(veh)}
    end
    
    return unpack(pos)
end

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer)then
        killTimer(SPAM.blockSpamTimer)
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

local progressbar=exports.px_progressbar

local FIX={}

FIX.markers={}

FIX.target=false
FIX.cost=0
FIX.discount=0
FIX.parts={}
FIX.lastParts=0

FIX.isNotRepair=function(list, panels)
    local exist={}

    local id={}
    for i,v in pairs(panels) do
        id[v.id]=true
    end

    for i,v in pairs(list) do
        if(id[v])then
            exist[#exist+1]=v
        end
    end

    return exist
end

FIX.isMarkerExists=function(list, panels)
    list=FIX.isNotRepair(list, panels)

    local exist=0
    for i,v in pairs(list) do
        if(FIX.markers[v])then
            exist=exist+1

            setElementData(FIX.markers[v], "fix", list, false)
        end
    end
    return exist
end

FIX.updateBackCost=function(plr)
    local cost=0
    for i,v in pairs(FIX.markers) do
        local id=getElementData(v, "fix")
        for i,v in pairs(id) do
            for _,k in pairs(FIX.parts) do
                if(v == k.id)then
                    cost=cost+k.cost
                end
            end
        end
    end

    if(cost > 0)then
        setElementData(plr, "workshop:back_cost", cost)
    end
end

FIX.createRepairMarker=function(parts, veh)
    for i,v in pairs(parts) do
        if(not FIX.markers[v.id])then
            if(v.id == -1 or v.id == 4 or v.id == 5 or v.id == 2 or v.id == 10 or v.id == 20 or v.id == 21 or v.id == 22 or v.id == 23 or v.id == 30)then -- przod
                local x,y,z=_getVehicleComponentPosition(veh, "windscreen_dummy", "world")
                x,y,z=getStraightPosition(x,y,z,veh,2)
                z=getGroundPosition(x,y,z)

                local exist=FIX.isMarkerExists({-1,4,5,2,10,20,21,22,23},parts)
                if(exist < 1)then
                    FIX.markers[v.id]=createMarker(x, y, z, "cylinder", 1, 160, 176, 110)
                    setElementData(FIX.markers[v.id], "fix", {v.id}, false)
                    setElementData(FIX.markers[v.id], "icon", ":px_workshop_mechanic/assets/images/czesc_marker.png")

                    FIX.lastParts=FIX.lastParts+1
                end
            elseif(v.id == 6 or v.id == 11 or v.id == 3)then -- tyl
                local x,y,z=_getVehicleComponentPosition(veh, "wheel_rb_dummy", "world")
                x,y,z=getStraightPosition(x,y,z,veh,-1)
                x,y,z=getRightPosition(x,y,z,veh,-0.9)
                z=getGroundPosition(x,y,z)

                local exist=FIX.isMarkerExists({6,11,3},parts)
                if(exist < 1)then
                    FIX.markers[v.id]=createMarker(x, y, z, "cylinder", 1, 160, 176, 110)
                    setElementData(FIX.markers[v.id], "fix", {v.id}, false)
                    setElementData(FIX.markers[v.id], "icon", ":px_workshop_mechanic/assets/images/czesc_marker.png")

                    FIX.lastParts=FIX.lastParts+1
                end
            elseif(v.id == 12 or v.id == 0)then -- lewy przod
                local x,y,z=_getVehicleComponentPosition(veh, "door_lf_dummy", "world")
                x,y,z=getStraightPosition(x,y,z,veh,-0.7)
                z=getGroundPosition(x,y,z)

                local exist=FIX.isMarkerExists({12,0},parts)
                if(exist < 1)then
                    FIX.markers[v.id]=createMarker(x, y, z, "cylinder", 1, 160, 176, 110)
                    setElementData(FIX.markers[v.id], "fix", {v.id}, false)
                    setElementData(FIX.markers[v.id], "icon", ":px_workshop_mechanic/assets/images/czesc_marker.png")

                    FIX.lastParts=FIX.lastParts+1
                end
            elseif(v.id == 13 or v.id == 1)then -- prawy przod
                local x,y,z=_getVehicleComponentPosition(veh, "door_rf_dummy", "world")
                x,y,z=getStraightPosition(x,y,z,veh,-0.7)
                z=getGroundPosition(x,y,z)

                local exist=FIX.isMarkerExists({13,1},parts)
                if(exist < 1)then
                    FIX.markers[v.id]=createMarker(x, y, z, "cylinder", 1, 160, 176, 110)
                    setElementData(FIX.markers[v.id], "fix", {v.id}, false)
                    setElementData(FIX.markers[v.id], "icon", ":px_workshop_mechanic/assets/images/czesc_marker.png")

                    FIX.lastParts=FIX.lastParts+1
                end
            elseif(v.id == 14)then -- lewy tyl
                local x,y,z=_getVehicleComponentPosition(veh, "door_lr_dummy", "world")
                x,y,z=getStraightPosition(x,y,z,veh,-0.4)
                z=getGroundPosition(x,y,z)

                FIX.markers[v.id]=createMarker(x, y, z, "cylinder", 1, 160, 176, 110)
                setElementData(FIX.markers[v.id], "fix", {v.id}, false)
                setElementData(FIX.markers[v.id], "icon", ":px_workshop_mechanic/assets/images/czesc_marker.png")

                FIX.lastParts=FIX.lastParts+1
            elseif(v.id == 15)then -- prawy tyl
                local x,y,z=_getVehicleComponentPosition(veh, "door_rr_dummy", "world")
                x,y,z=getStraightPosition(x,y,z,veh,-0.4)
                z=getGroundPosition(x,y,z)

                FIX.markers[v.id]=createMarker(x, y, z, "cylinder", 1, 160, 176, 110)
                setElementData(FIX.markers[v.id], "fix", {v.id}, false)
                setElementData(FIX.markers[v.id], "icon", ":px_workshop_mechanic/assets/images/czesc_marker.png")

                FIX.lastParts=FIX.lastParts+1
            end
        end
    end
end

FIX.cancel=function(type)
    if(target and isElement(target))then
        removeEventHandler("onClientMarkerHit", resourceRoot, FIX.onHit)

        progressbar:destroyProgressbar()

        toggleControl(target, 'accelerate', true)
        toggleControl(target, 'enter_exit', true)
        toggleControl(target, 'brake_reverse', true)
        toggleControl(target, 'forwards', true)
        toggleControl(target, 'backwards', true)
        toggleControl(target, 'left', true)
        toggleControl(target, 'right', true)

        if(type)then
            for i,v in pairs(FIX.markers) do
                if(v and isElement(v))then
                    destroyElement(v)
                end
            end

            if(FIX.target and isElement(FIX.target))then
                setElementData(FIX.target, "workshop:back_cost", false)
            end

            FIX.target=false
            FIX.repairParts=0
            FIX.cost=0

            FIX.markers={}
            FIX.parts={}
        end
    end
end

FIX.onHit=function(hit, dim)
    if(SPAM.getSpam())then return end

    if(hit == localPlayer and dim and not isPedInVehicle(hit))then
        local fix=getElementData(source, "fix")
        if(not fix)then return end

        if(FIX.target and isElement(FIX.target))then
            local veh=getPedOccupiedVehicle(FIX.target)
            if(not veh)then 
                FIX.cancel(true)
                return 
            end

            progressbar:createProgressbar(sw/2-671/2/zoom, sh-50/zoom, 671/zoom, 4/zoom, "Trwa naprawa części...", 15/zoom, 5890, false, 0)
    
            toggleControl('accelerate', false)
            toggleControl('enter_exit', false)
            toggleControl('brake_reverse', false)
            toggleControl('forwards', false)
            toggleControl('backwards', false)
            toggleControl('left', false)
            toggleControl('right', false)
            
            triggerServerEvent("animation", resourceRoot, true)

            FIX.lastParts=FIX.lastParts-1
    
            setTimer(function(marker)
                for i,v in pairs(fix) do
                    if(FIX.markers[v] and isElement(FIX.markers[v]))then
                        destroyElement(FIX.markers[v])
                    end

                    FIX.markers[v]=nil
                    triggerServerEvent("fix.vehicle", resourceRoot, veh, v)
                end

                if(FIX.lastParts == 0)then
                    triggerServerEvent("fix.vehicle", resourceRoot, veh, false, FIX.target, FIX.cost, FIX.discount)
                    setElementData(FIX.target, "workshop:back_cost", false)
                end

                progressbar:destroyProgressbar()

                toggleControl('accelerate', true)
                toggleControl('enter_exit', true)
                toggleControl('brake_reverse', true)
                toggleControl('forwards', true)
                toggleControl('backwards', true)
                toggleControl('left', true)
                toggleControl('right', true)
    
                triggerServerEvent("playSound", resourceRoot, {getElementPosition(hit)})
                triggerServerEvent("animation", resourceRoot)
            end, 5890, 1, source)
        else
            FIX.cancel(true)
        end
    end
end

-- triggers

addEvent("fix.vehicle", true)
addEventHandler("fix.vehicle", resourceRoot, function(player, parts)
    if(not player or not parts)then return end

    local veh=getPedOccupiedVehicle(player)
    if(not veh)then return end

    FIX.cancel(true)

    FIX.target=player
    FIX.lastParts=0
    FIX.markers={}
    FIX.parts=parts
    
    local cost=0
    local discount=0
    for i,v in pairs(parts) do
        cost=cost+v.cost
        discount=discount+v.discount
    end
    FIX.cost=cost
    FIX.discount=discount

    FIX.createRepairMarker(parts, veh)
    setTimer(function()
        FIX.updateBackCost(player)
    end, 500, 1)

    addEventHandler("onClientMarkerHit", resourceRoot, FIX.onHit)
end)

addEvent("workshop->leaveZone", true)
addEventHandler("workshop->leaveZone", root, function(player)
    local back=getElementData(localPlayer, "workshop:back_cost")
    if(back)then
        triggerServerEvent("back.money", resourceRoot, localPlayer, back)
        setElementData(localPlayer, "workshop:back_cost", false)
    end

    if(player == localPlayer)then
        FIX.cancel(true)
    end
end)

addEvent("cancel.offer", true)
addEventHandler("cancel.offer", resourceRoot, function()
    toggleControl(target, 'accelerate', true)
    toggleControl(target, 'enter_exit', true)
    toggleControl(target, 'brake_reverse', true)
    toggleControl(target, 'forwards', true)
    toggleControl(target, 'backwards', true)
    toggleControl(target, 'left', true)
    toggleControl(target, 'right', true)

    FIX.offer=false
    FIX.target=false
end)

-- useful

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end

function getStraightPosition(x,y,z,element,p)
    x=x or 0
    y=y or 0
    z=z or 0
    p=p or 0

    local _,_,rot = getElementRotation(element)
    local cx, cy = getPointFromDistanceRotation(x, y, p, (-rot))
    return cx,cy,z
end

function getRightPosition(x,y,z,element,p)
    x=x or 0
    y=y or 0
    z=z or 0
    p=p or 0
    
    local _,_,rot = getElementRotation(element)
    rot=rot-90
    local cx, cy = getPointFromDistanceRotation(x, y, p, (-rot))
    return cx,cy,z
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end