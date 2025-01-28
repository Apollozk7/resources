--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

local factions=exports.px_factions
local moving={}

ui.gates={
    {id=10149, marker={2501.1460,915.1483,10.8281}, pos={2499.89,912.5,11,180}, moveTo={2499.89,912.5,8}, access=function(element) 
        return factions:isPlayerHaveAccess(getPlayerName(element), "Otwieranie bram", "SACC")
    end}, -- taxi

    {id=10149, marker={2521.5217,923.4465,10.8295}, pos={2518.3,924.2213,11.15,90}, moveTo={2518.3,924.2213,8}, access=function(element) 
        return factions:isPlayerHaveAccess(getPlayerName(element), "Otwieranie bram", "SACC")
    end}, -- taxi

    {id=10558, size=1.5, marker={2331.5515,2440.2146,5.5055}, marker2={2333.6992,2439.1060,6.0270}, pos={2335.0322,2443.9485,7.4,150}, moveTo={2335.0322,2443.9485,-1}, access=function(element) 
        return factions:isPlayerHaveAccess(getPlayerName(element), "Otwieranie bram", "SAPD")
    end}, -- sapd

    {id=10558, size=1.5, marker={2292.3865,2493.7683,3.5138}, marker2={2295.1541,2493.7346,3.5734}, pos={2294.0125,2497.9146,5.2870}, moveTo={2294.0125,2497.9146,-1}, access=function(element) 
        return factions:isPlayerHaveAccess(getPlayerName(element), "Otwieranie bram", "SAPD")
    end}, -- sapd

    {id=968, size=1, marker={2238.6990,2449.4270,11.0372}, pos={2238.19,2450.35,10.7,0,90,0}, rot={0,90,90}, moveTo={2238.19,2450.35,10.7,0,-90,0}, access=function(element) 
        return factions:isPlayerHaveAccess(getPlayerName(element), "Otwieranie bram", "SAPD")
    end}, -- sapd

    -- szlabany org COOL-DOWNS
    {id=968, size=1, marker={2637.1543,2305.0640,10.8203}, object={966,2635.8,2303.7,9.7}, pos={2635.8,2303.7,10.55,0,-90,0}, moveTo={2635.8,2303.7,10.55,0,90,0}, access=function(element) 
        return getElementData(element, "user:organization") == "CoolDown's"
    end},
    {id=968, size=1, marker={2619.8872,2304.9607,10.8203}, object={966,2621.2115,2303.7,9.7,0,0,180}, pos={2621.2115,2303.7,10.6,0,90,0}, moveTo={2621.2115,2303.7,10.6,0,-90,0}, access=function(element) 
        return getElementData(element, "user:organization") == "CoolDown's"
    end},
    --
}

for i,v in pairs(ui.gates) do
    if(v.pos[5] and v.pos[6])then
        v.obj=createObject(v.id, v.pos[1], v.pos[2], v.pos[3], v.rot and v.rot[1] or v.pos[4], v.rot and v.rot[2] or v.pos[5], v.rot and v.rot[3] or v.pos[6])
    else
        v.obj=createObject(v.id, v.pos[1], v.pos[2], v.pos[3], 0, 0, v.pos[4])
    end

    v.shape=createColSphere(v.pos[1], v.pos[2], v.pos[3]+1, 7)

    setObjectScale(v.obj,v.size or 1)
    setElementData(v.obj,"page","left",false)

    setElementData(v.shape, "info", i,false)
    setElementData(v.shape, "obj", v.obj,false)

    if(v.object)then
        createObject(unpack(v.object))
    end
end

function openGate(id,type)
    local v=ui.gates[id]
    if(not v)then return end

    if(moving[v.obj])then return end

    if(type == "left" and getElementData(v.obj, 'page') == type)then
        -- otworz
        if(v.moveTo[4] and v.moveTo[5] and v.moveTo[6])then
            moveObject(v.obj, 5000, v.moveTo[1], v.moveTo[2], v.moveTo[3], v.moveTo[4], v.moveTo[5], v.moveTo[6])
        else
            moveObject(v.obj, 5000, v.moveTo[1], v.moveTo[2], v.moveTo[3])
        end

        moving[v.obj]=true
        setTimer(function()
            moving[v.obj]=nil
            setElementData(v.obj,"page","right",false)
        end, 5500, 1)
    elseif(type == "right" and getElementData(v.obj, 'page') == type)then
        -- zamknij
        if(v.pos[4] and v.pos[5] and v.pos[6])then
            moveObject(v.obj, 5000, v.pos[1], v.pos[2], v.pos[3], v.pos[4], v.pos[5], v.pos[6])
        else
            moveObject(v.obj, 5000, v.pos[1], v.pos[2], v.pos[3])
        end

        moving[v.obj]=true
        setTimer(function()
            moving[v.obj]=nil
            setElementData(v.obj,"page","left",false)
        end, 5500, 1)
    end
end

addEventHandler("onColShapeHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim)then
        local player=getElementType(hit) == 'player' and hit or getElementType(hit) == 'vehicle' and getVehicleController(hit)
        if(player and isElement(player))then
            local data=getElementData(source, "info")
            if(not data)then return end

            local obj=getElementData(source, 'obj')
            if(not obj)then return end

            local page=getElementData(obj, 'page')
            if(not page)then return end

            datas=ui.gates[data]
            if(not datas)then return end

            factions=exports.px_factions

            if(datas.access(player))then
                openGate(data,'left')
            end
        end
    end
end)

addEventHandler("onColShapeLeave", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim)then
        local player=getElementType(hit) == 'player' and hit or getElementType(hit) == 'vehicle' and getVehicleController(hit)
        if(player and isElement(player))then
            local data=getElementData(source, "info")
            if(not data)then return end

            local obj=getElementData(source, 'obj')
            if(not obj)then return end

            local page=getElementData(obj, 'page')
            if(not page)then return end

            datas=ui.gates[data]
            if(not datas)then return end

            factions=exports.px_factions

            if(datas.access(player))then
                openGate(data,'right')
            end
        end
    end
end)