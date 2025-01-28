--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local object=createObject(3077,6.1,1879.7549,16,0,0,359.9710)
setObjectScale(object,1.8)
setElementCollisionsEnabled(object,false)

local zone=createColCuboid(2.85001, 1864.85413, 17.45245, 6.8995013237, 14.901733398438, 1.9)
setElementData(zone, 'object', object, false)

local dxDiag=createElement("dxDiag")

addEventHandler("onColShapeHit", zone, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player")then
        local veh=getPedOccupiedVehicle(hit)
        if(veh and getVehicleController(veh) == hit)then
            setElementData(dxDiag, "vehicle", {veh,getElementData(source,'object')})
        end
    end
end)

addEventHandler("onColShapeLeave", zone, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player")then
        local veh=getPedOccupiedVehicle(hit)
        if(veh and getVehicleController(veh) == hit and getElementData(dxDiag, "vehicle") == veh)then
            removeElementData(dxDiag, "vehicle")
        end
    end
end)