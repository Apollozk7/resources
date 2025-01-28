--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function follow()
	local dokogo=getElementData(localPlayer,"user:handcuffs")
    if(not dokogo or (dokogo and not isElement(dokogo)))then return end
    if(getPedOccupiedVehicle(localPlayer))then return end

    if(getElementInterior(localPlayer) ~= getElementInterior(dokogo) or getElementDimension(localPlayer) ~= getElementDimension(dokogo))then
        triggerServerEvent("set.int", resourceRoot, getElementInterior(dokogo), getElementDimension(dokogo))
        removeEventHandler("onClientRender", root, follow)
        return
    end

	local x,y,z=getElementPosition(dokogo)
	local x2,y2,z2=getElementPosition(localPlayer)
	local kat=0
	kat=math.deg(math.atan(-1*(x2-x)/(y2-y)))
	if (y2-y)<0 then
		kat=kat+180.0
	end
	kat=(kat+180)%360

	setPedRotation(localPlayer, kat+180)
end

addEvent("get.render", true)
addEventHandler("get.render", resourceRoot, function()
    if(getElementData(localPlayer, "user:handcuffs"))then
        addEventHandler("onClientRender", root, follow)
    end
end)

addEventHandler("onClientElementDataChange", root, function(data, _, new)
    if(data == "user:handcuffs")then
        if(not new)then
            removeEventHandler("onClientRender", root, follow)
        else
            addEventHandler("onClientRender", root, follow)
        end
    end
end)