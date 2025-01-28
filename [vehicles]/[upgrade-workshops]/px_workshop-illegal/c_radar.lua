--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local r={}

r['tex']=false
r['font']=false

r['cameras']=false

r['getNearestCamera']=function()
    local myPos={getElementPosition(localPlayer)}
    local distance=false
    for i,v in pairs(r['cameras']) do
        local dist=getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], v.object[1], v.object[2], v.object[3])
        if(not distance or (distance and distance > dist))then
            distance=dist
        end
    end
    return distance < 250 and distance
end

r['render']=function()
    if(not isPedInVehicle(localPlayer))then
        r['destroy']()
        return
    end

    local camera=r['getNearestCamera']()
    if(camera)then
        blur:dxDrawBlur(sw-670/zoom-5/zoom, sh-50/zoom-5/zoom, 125/zoom, 36/zoom+10/zoom)
        dxDrawRectangle(sw-670/zoom-5/zoom, sh-50/zoom-5/zoom, 125/zoom, 36/zoom+10/zoom, tocolor(30,30,30,200))
        dxDrawImage(sw-670/zoom, sh-50/zoom, 53/zoom, 36/zoom, r['tex'])
        dxDrawText(math.floor(camera).."M", sw-670/zoom+53/zoom, sh-50/zoom, sw-670/zoom+125/zoom, sh-50/zoom+36/zoom, tocolor(200, 200, 200), 1, r['font'], 'center', 'center')
    end
end

r['create']=function()
    r['tex']=dxCreateTexture('textures/radar.png', 'argb', false, 'clamp')
    r['font']=dxCreateFont(':px_assets/fonts/Font-Bold.ttf', 15/zoom)

    r['cameras']=exports['px_speed_cameras']:getCameras() or {}

    addEventHandler('onClientRender', root, r['render'])
end

r['destroy']=function()
    if(r['tex'])then
        destroyElement(r['tex'])
    end
    
    if(r['font'])then
        destroyElement(r['font'])
    end

    r['tex']=false
    r['font']=false

    r['cameras']=false

    removeEventHandler('onClientRender', root, r['render'])
end

addEventHandler('onClientVehicleEnter', root, function(plr,seat)
    if(seat ~= 0 or plr ~= localPlayer)then return end

    if(getElementData(source, 'vehicle:radarDetector'))then
        r['create']()
    end
end)

addEventHandler('onClientVehicleExit', root, function(plr,seat)
    if(seat ~= 0 or plr ~= localPlayer)then return end

    if(getElementData(source, 'vehicle:radarDetector'))then
        r['destroy']()
    end
end)

addEventHandler('onClientElementDataChange', root, function(data, old, new)
    if(data == 'vehicle:radarDetector' and getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicle(localPlayer) == source)then
        if(new)then
            r['create']()
        else
            r['destroy']()
        end
    end
end)