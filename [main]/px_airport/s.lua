--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- parachute

createPickup(1663.2375,1436.1000,10.4688, 2, 46, 5000, 999)       

-- doors

local doors={
    {1569, 1635.5566,1447.02115,9.5,90,require={"l1","l1"}},
    {1569, 1598.73,1447.01,9.85,90,require={"l1","l1"}}
}

for i,v in pairs(doors) do
    v.door=createObject(v[1], v[2], v[3], v[4], 0, 0, v[5])
    v.zone=createColSphere(v[2], v[3]+0.75, v[4]+0.5, 2)
end

function isPlayerHaveAccess(plr,types)
    local lic=getElementData(plr, "user:licenses") or {}
    local access=false
    for i,v in pairs(types) do
        if(lic[v] and lic[v] == 2)then
            access=true
            break
        end
    end
    return access
end

addEventHandler("onColShapeHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and not isPedInVehicle(hit))then
        for i,v in pairs(doors) do
            if(v.zone == source)then
                if(isPlayerHaveAccess(hit,v.require))then
                    triggerLatentClientEvent(hit, "setObjectPosition", resourceRoot, v.door, {v[2],v[3],v[4]-3})
                else
                    exports.px_noti:noti("Aby przejść dalej musisz posiadać licencję lotniczą.", hit, "error")
                end

                break
            end
        end
    end
end)

addEventHandler("onColShapeLeave", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and not isPedInVehicle(hit))then
        for i,v in pairs(doors) do
            if(v.zone == source)then
                if(isPlayerHaveAccess(hit,v.require))then
                    triggerLatentClientEvent(hit, "setObjectPosition", resourceRoot, v.door, {v[2],v[3],v[4]})
                end

                break
            end
        end
    end
end)