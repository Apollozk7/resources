--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPEEDO.render_6=function(vehicle)
    SPEEDO.getRenderLPG(vehicle, sw-37/zoom, sh-250/zoom)

    local speed=getElementSpeed(vehicle, 1)
    local distance = getElementData(vehicle, "vehicle:distance") or 0
    local fuel,bak=SPEEDO.getFuel(vehicle)
    local rpm=exports.bengines:getVehicleRPM(vehicle)

    local gear=exports.bengines:getVehicleGear(vehicle)

    if(getPedControlState("brake_reverse") and not SPEEDO.backing and speed < 1)then
        SPEEDO.backing=true
    end

    if(SPEEDO.backing and gear == 1)then
        gear="R"
        if(speed < 1 and not getPedControlState("brake_reverse"))then
            SPEEDO.backing=false
        end
    end

    if(speed < 1 and not SPEEDO.backing)then
        gear="N"
    end

    --

    local zoom=(1920/sw)/0.9

    -- fuel
    local x,y=sw-241/zoom-31/zoom, sh-189/zoom-29/zoom
    dxDrawImage(x, y, 241/zoom, 189/zoom, SPEEDO.TEXTURES[6][11])
    dxDrawImage(x, y, 241/zoom, 241/zoom, SPEEDO.TEXTURES[6][12], 195-(90*(fuel/bak)))

    local export=exports.px_custom_vehicles
    if(export)then
        local fuel_usage=export:getFuelUsage(vehicle)
        dxDrawText(fuel_usage.."l/100km", x, y, 330/zoom+x, 175/zoom+y, tocolor(200, 200, 200), 1, SPEEDO.fonts[6][2], "center", "bottom")
    end
    if(1*(fuel/bak) < 0.05)then
        local a=interpolateBetween(255, 0, 0, 0, 0, 0, (getTickCount()-SPEEDO.tick)/500, "SineCurve")
        dxDrawImage(x+155/zoom, y+134/zoom, 15/zoom, 15/zoom, SPEEDO.TEXTURES[6][15], 0, 0, 0, tocolor(255, 255, 255, a))
    elseif(1*(fuel/bak) < 0.25)then
        dxDrawImage(x+155/zoom, y+134/zoom, 15/zoom, 15/zoom, SPEEDO.TEXTURES[6][15])
    end

    -- rpm
    rpm=rpm/3
    rpm=rpm > 3000 and 3000 or rpm
    local x,y=sw-241/zoom-329/zoom, sh-189/zoom-29/zoom
    dxDrawImage(x, y, 241/zoom, 189/zoom, SPEEDO.TEXTURES[6][13])

    dxDrawImage(x+50/zoom, y+120/zoom, 20/zoom, 24/zoom, SPEEDO.TEXTURES[6][14])
    dxDrawText(gear, x+52/zoom, y+120/zoom, 20/zoom+x+50/zoom, 24/zoom+y+120/zoom, tocolor(200, 200, 200), 1, SPEEDO.fonts[6][2], "center", "center")

    dxDrawImage(x, y, 241/zoom, 241/zoom, SPEEDO.TEXTURES[6][12], -15+(90*(rpm/3000)))
    dxDrawText("x1000", x, y, 135/zoom+x, 175/zoom+y, tocolor(200, 200, 200), 1, SPEEDO.fonts[6][2], "center", "bottom")

    -- speed
    speed=speed > 140 and 140 or speed
    local x,y=sw-355/zoom-125/zoom, sh-263/zoom-29/zoom
    dxDrawImage(x, y, 355/zoom, 263/zoom, SPEEDO.TEXTURES[6][1])
    dxDrawImage(x+5/zoom, y, 336/zoom, 336/zoom, SPEEDO.TEXTURES[6][2], -14+(209*(speed/140)))

    -- distance
    distance=string.format("%05d", distance)
    for i=1,5 do
        local sX=(14.7/zoom)*(i-1)
        dxDrawText(string.sub(distance, i, i), x+134/zoom+sX, y+226/zoom, 11/zoom+x, 17/zoom+y, tocolor(200, 200, 200), 1, SPEEDO.fonts[6][1], "left", "top")
    end

    local wl=0
    for i=1,2 do
        local xx=i == 1 and (getVehicleOverrideLights(vehicle) == 1 and 1 or 2) or i == 2 and (getVehicleEngineState(vehicle) and 1 or 2)

        local w,h=dxGetMaterialSize(SPEEDO.TEXTURES[6][xx+(i*2)])
        local sX=(wl+15/zoom)*(i-1)
        dxDrawImage(x+50/zoom+sX,y+227/zoom,w/zoom,h/zoom,SPEEDO.TEXTURES[6][xx+(i*2)])

        wl=w/zoom
    end

    local wl=0
    for i=1,2 do
        local xx=i == 1 and (getElementData(vehicle, "vehicle:handbrake") and 6 or 5) or i == 2 and (getVehicleTowedByVehicle(vehicle) and 6 or 5)

        local w,h=dxGetMaterialSize(SPEEDO.TEXTURES[6][xx+(i*2)])
        local sX=(wl+15/zoom)*(i-1)
        dxDrawImage(x+220/zoom+sX,y+227/zoom,w/zoom,h/zoom,SPEEDO.TEXTURES[6][xx+(i*2)])
        
        wl=w/zoom
    end
end