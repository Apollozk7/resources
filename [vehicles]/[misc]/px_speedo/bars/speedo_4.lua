--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPEEDO.render_4=function(vehicle)
    SPEEDO.getRenderLPG(vehicle, sw-37/zoom, sh-220/zoom)

    local speed=getElementSpeed(vehicle, 1)*1.15
    local rpm=exports.bengines:getVehicleRPM(vehicle)
    local gears=exports.bengines:getVehicleGear(vehicle)
    local gear="D"

    if(getPedControlState("brake_reverse") and not SPEEDO.backing and speed < 1)then
        SPEEDO.backing=true
    end

    if(SPEEDO.backing and gears == 1)then
        gear="R"
        if(speed < 1 and not getPedControlState("brake_reverse"))then
            SPEEDO.backing=false
        end
    end

    if(speed < 1 and not SPEEDO.backing)then
        gear="N"
    end

    local distance = getElementData(vehicle, "vehicle:distance") or 0
    local fuel,bak=SPEEDO.getFuel(vehicle)

    --
    local zoom=(1920/sw)/0.9
    local x,y=sw-322/zoom-49/zoom, sh-322/zoom-32/zoom

    if(speed > 290)then speed=290 end

    dxDrawImage(x, y, 322/zoom, 322/zoom, SPEEDO.TEXTURES[4][1])
    dxDrawImage(x, y, 322/zoom, 322/zoom, SPEEDO.TEXTURES[4][3], speed)
    dxDrawImage(x, y, 322/zoom, 322/zoom, SPEEDO.TEXTURES[4][2])

    local export=exports.px_custom_vehicles
    if(export)then
        local fuel_usage=export:getFuelUsage(vehicle)
        dxDrawText(fuel_usage.."L/100KM", x, y, 322/zoom+x, 322/zoom+y-65/zoom, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[4][2], "center", "bottom")
    end

    distance=string.format("%05d", distance)
    for i=1,5 do
        local sX=(11.2/zoom)*(i-1)
        dxDrawText(string.sub(distance, i, i), x+137/zoom+sX, y+270/zoom, 11/zoom+x, 17/zoom+y, tocolor(200, 200, 200), 1, SPEEDO.fonts[4][1], "left", "top")
    end

    dxDrawText("MILEAGE", x, y, 322/zoom+x, 322/zoom+y-17/zoom, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[4][1], "center", "bottom")

    x=sw-170/zoom-364/zoom
    y=sh-170/zoom-32/zoom
    rpm=rpm > 10000 and 10000 or rpm
    dxDrawImage(x, y, 170/zoom, 170/zoom, SPEEDO.TEXTURES[4][4])
    dxDrawImage(x, y, 170/zoom, 170/zoom, SPEEDO.TEXTURES[4][6], 290*(rpm/10000))
    dxDrawImage(x, y, 170/zoom, 170/zoom, SPEEDO.TEXTURES[4][5])

    dxDrawText("x1000", x, y, 170/zoom+x, 170/zoom+y-25/zoom, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[4][1], "center", "bottom")

    x=sw-88/zoom-369/zoom
    y=sh-88/zoom-202/zoom
    dxDrawImage(x, y, 88/zoom, 88/zoom, SPEEDO.TEXTURES[4][7])
    dxDrawImage(x, y, 88/zoom, 88/zoom, SPEEDO.TEXTURES[4][9], 285*(fuel/bak))
    dxDrawImage(x, y, 88/zoom, 88/zoom, SPEEDO.TEXTURES[4][8])

    local percent=math.floor((fuel/bak)*100)
    if(percent < 10 and percent > 5)then
        dxDrawImage(x+88/2/zoom-5/zoom, y+88/2/zoom-5/zoom, 10/zoom, 10/zoom, SPEEDO.TEXTURES["f_circle"], 0, 0, 0, tocolor(255, 0, 0, 200))
    elseif(percent < 5)then
        local a=interpolateBetween(0, 0, 0, 200, 0, 0, (getTickCount()-SPEEDO.tick)/1000, "SineCurve")
        dxDrawImage(x+88/2/zoom-5/zoom, y+88/2/zoom-5/zoom, 10/zoom, 10/zoom, SPEEDO.TEXTURES["f_circle"], 0, 0, 0, tocolor(255, 0, 0, a))
    end

    dxDrawText("FUEL", x+2, y, 88/zoom+x, 88/zoom+y-11/zoom, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[4][1], "center", "bottom")

    if(SPEEDO.isVehicleHaveNitro(vehicle))then
        local nitro_max=100
        local nitro=getElementData(vehicle, "vehicle:nitroLevel") or 0

        x=sw-88/zoom-11/zoom
        y=sh-88/zoom-7/zoom
        dxDrawImage(x, y, 88/zoom, 88/zoom, SPEEDO.TEXTURES[4][7])
        dxDrawImage(x, y, 88/zoom, 88/zoom, SPEEDO.TEXTURES[4][9], 285*(nitro/nitro_max))
        dxDrawImage(x, y, 88/zoom, 88/zoom, SPEEDO.TEXTURES[4][8])

        dxDrawText("NOS", x+2, y, 88/zoom+x, 88/zoom+y-11/zoom, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[4][1], "center", "bottom")
    end
end