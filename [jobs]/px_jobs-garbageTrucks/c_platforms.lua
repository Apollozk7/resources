--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

p={}

p.trucks={
    ["Dune"]={{1.5,-2.6,0.2},{-1.5,-2.6,0.2}},
    ["Trashmaster"]={{1.2,-3.5,-0.1},{-1.2,-3.5,-0.1}},
    ["Cement Truck"]={{1.2,-3.5,-0.1},{-1.2,-3.5,-0.1}}
}

p.render=function()
    if(p.truck and isElement(p.truck))then
        local voffxc,voffyc,voffzc=getPositionFromElementOffset(p.truck,0,-10.5,3)
        local vehx,vehy,vehz=getElementPosition(p.truck)
        local _,_,rz=getElementRotation(p.truck)
        local rot=90
        if(id == 2)then
            rot=270
        end

        setCameraMatrix(voffxc,voffyc,voffzc, vehx,vehy,vehz)
        setPedRotation(localPlayer,rz+rot)
        setElementPosition(localPlayer,vehx,vehy,vehz)
    end
end

p.findNearestTruck=function()
    if(ui.vehicle and isElement(ui.vehicle))then
        local x,y,z=getElementPosition(localPlayer)
        local pos={getElementPosition(ui.vehicle)}
        local dist=getDistanceBetweenPoints3D(x,y,z,pos[1],pos[2],pos[3])
        if(dist < 5)then
            return ui.vehicle
        end
        return false
    end
    return false
end

bindKey("x", "down", function()
    if(SPAM.getSpam())then return end

    local data=getElementData(localPlayer, "user:onGarbagePlatform")
    if(data and p.truck)then
        triggerServerEvent("platform.leave", resourceRoot)

        setElementData(localPlayer, "ghost", false)

        removeEventHandler("onClientRender", root, p.render)
        setElementFrozen(localPlayer, false)
        setCameraTarget(localPlayer)

        p.truck=false
    else
        local truck=p.findNearestTruck()
        if(truck and isElement(truck) and not ui.haveTrash and ui.lider ~= localPlayer and not p.truck)then
            local speed=getElementSpeed(truck, "km/h")
            if(speed > 10)then return end

            p.truck=truck

            triggerServerEvent("platform.jump", resourceRoot, truck)

            setElementData(localPlayer, "ghost", "all")

            addEventHandler("onClientRender", root, p.render)
            setElementFrozen(localPlayer, true)
        end
    end
end)

addEvent("platform.leave", true)
addEventHandler("platform.leave", resourceRoot, function()
    triggerServerEvent("platform.leave", resourceRoot)

    setElementData(localPlayer, "ghost", false)

    removeEventHandler("onClientRender", root, p.render)
    setElementFrozen(localPlayer, false)
    setCameraTarget(localPlayer)

    p.truck=false
end)

-- events

addEventHandler("onClientPlayerQuit", localPlayer, function()
    if(p.truck and isElement(p.truck))then
        triggerServerEvent("platform.leave", resourceRoot)

        setElementData(localPlayer, "ghost", false)

        removeEventHandler("onClientRender", root, p.render)
        setElementFrozen(localPlayer, false)
        setCameraTarget(localPlayer)

        p.truck=false
    end
end)

addEventHandler("onClientPlayerWasted", localPlayer, function()
    if(p.truck and isElement(p.truck))then
        triggerServerEvent("platform.leave", resourceRoot)

        setElementData(localPlayer, "ghost", false)

        removeEventHandler("onClientRender", root, p.render)
        setElementFrozen(localPlayer, false)
        setCameraTarget(localPlayer)

        p.truck=false
    end
end)

addEventHandler("onClientElementDestroy", root, function()
    if(p.truck == source)then
        triggerServerEvent("platform.leave", resourceRoot)
    
        setElementData(localPlayer, "ghost", false)

        removeEventHandler("onClientRender", root, p.render)
        setElementFrozen(localPlayer, false)
        setCameraTarget(localPlayer)

        p.truck=false
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if(p.truck)then
        setPedAnimation(localPlayer, false)
        setElementFrozen(localPlayer, false)
        setCameraTarget(localPlayer)

        setElementData(localPlayer, "ghost", false)
    end
end)

-- useful

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function getElementSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    assert(getElementType(theElement) == "player" or getElementType(theElement) == "ped" or getElementType(theElement) == "object" or getElementType(theElement) == "vehicle", "Invalid element type @ getElementSpeed (player/ped/object/vehicle expected, got " .. getElementType(theElement) .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end