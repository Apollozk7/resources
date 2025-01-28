--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPEEDO.render_5=function(vehicle)
    SPEEDO.getRenderLPG(vehicle, sw-42/zoom, sh-140/zoom)

    local speed=getElementSpeed(vehicle, 1)
    local distance = getElementData(vehicle, "vehicle:distance") or 0
    local fuel,bak=SPEEDO.getFuel(vehicle)
    local nitro=getElementData(vehicle, "vehicle:nitroLevel") or 0
    local rpm=exports.bengines:getVehicleRPM(vehicle)

    local speedoColor=getElementData(vehicle, "vehicle:speedoColor")
    if(speedoColor)then
        speedoColor=exports['px_workshop-illegal']:getVehicleSpeedoColorName(speedoColor) or {150,150,150}
    else
        speedoColor={150,150,150}
    end
    if(getVehicleOverrideLights(vehicle) ~= 2)then
        speedoColor={150,150,150}
    end
    
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
    local x,y=sw-342/zoom-48/zoom, sh-342/zoom-28/zoom

    dxDrawImage(x, y, 342/zoom, 342/zoom, SPEEDO.TEXTURES[5][1])
    dxDrawImage(x, y, 342/zoom, 342/zoom, SPEEDO.TEXTURES[5][12],0,0,0,tocolor(unpack(speedoColor)))
    dxDrawImage(x, y, 342/zoom, 342/zoom, SPEEDO.TEXTURES[5][2], -45+(260*(speed/251)))

    -- paliwo
    local rot=66*((bak-fuel)/bak)
    dxDrawImage(x, y, 342/zoom, 342/zoom, SPEEDO.TEXTURES[5][4])

    dxSetShaderValue(SPEEDO.speedShader, "sPicTexture", SPEEDO.TEXTURES[5][5])
    dxSetShaderValue(SPEEDO.speedShader, "sMaskTexture", SPEEDO.TEXTURES[5][4])
    dxSetShaderValue(SPEEDO.speedShader, "gUVRotAngle", math.rad(rot))

    dxDrawImage(x, y, 342/zoom, 342/zoom, SPEEDO.speedShader,0,0,0,tocolor(unpack(speedoColor)))

    local percent=math.floor((fuel/bak)*100)
    if(percent < 10 and percent > 5)then
        dxDrawImage(x+342/2/zoom-5/zoom, y+310/zoom, 10/zoom, 10/zoom, SPEEDO.TEXTURES["f_circle"], 0, 0, 0, tocolor(255, 50, 0, 200))
    elseif(percent < 5)then
        local a=interpolateBetween(0, 0, 0, 200, 0, 0, (getTickCount()-SPEEDO.tick)/1000, "SineCurve")
        dxDrawImage(x+342/2/zoom-5/zoom, y+310/zoom, 10/zoom, 10/zoom, SPEEDO.TEXTURES["f_circle"], 0, 0, 0, tocolor(255, 50, 0, a))
    end

    -- distance
    distance=string.format("%06d", distance)
    local width=(15/zoom)*6
    for i=1,6 do
        local sX=(15/zoom)*(i-1)
        dxDrawImage(x+(342)/2/zoom+sX-width/2, y+268/zoom, 14/zoom, 21/zoom, SPEEDO.TEXTURES[5][3])
        dxDrawText(string.sub(distance, i, i), x+(342)/2/zoom+sX-width/2, y+268/zoom, 14/zoom+x+(342)/2/zoom+sX-width/2, 21/zoom+y+268/zoom, tocolor(200, 200, 200), 1, SPEEDO.fonts[5][1], "center", "center")
    end

    dxDrawText("km", x, y+268/zoom, x+342/zoom, 21/zoom+y+268/zoom+40/zoom, tocolor(150, 150, 150), 1, SPEEDO.fonts[5][2], "center", "center")

    -- obroty
    local x,y=sw-220/zoom-395/zoom, sh-220/zoom-25/zoom

    rpm=rpm > 10000 and 10000 or rpm
    dxDrawImage(x, y, 220/zoom, 220/zoom, SPEEDO.TEXTURES[5][6])
    dxDrawImage(x, y, 220/zoom, 220/zoom, SPEEDO.TEXTURES[5][11],0,0,0,tocolor(unpack(speedoColor)))
    dxDrawImage(x, y, 220/zoom, 220/zoom, SPEEDO.TEXTURES[5][7], -45+(270*(rpm/10000)))

    -- biegi
    dxDrawImage(x+(220-21)/2/zoom, y+151/zoom, 21/zoom, 30/zoom, SPEEDO.TEXTURES[5][8])
    dxDrawText(gear, x+(220-21)/2/zoom, y+151/zoom, 21/zoom+x+(220-21)/2/zoom, 30/zoom+y+151/zoom, tocolor(200, 200, 200), 1, SPEEDO.fonts[5][3], "center", "center")

    local export=exports.px_custom_vehicles
    if(export)then
        local fuel_usage=export:getFuelUsage(vehicle)
        dxDrawText(fuel_usage.."l/100km", x+(220-21)/2/zoom, y+151/zoom+50/zoom, 21/zoom+x+(220-21)/2/zoom, 30/zoom+y+151/zoom, tocolor(150, 150, 150), 1, SPEEDO.fonts[5][2], "center", "center")
    end

    -- nitro
    if(SPEEDO.isVehicleHaveNitro(vehicle))then
        local nitro_max=100
        local nitro=getElementData(vehicle, "vehicle:nitroLevel") or 0
        local rot=66*((nitro_max-nitro)/nitro_max)
        dxDrawImage(x, y, 220/zoom, 220/zoom, SPEEDO.TEXTURES[5][9])

        dxSetShaderValue(SPEEDO.speedShader, "sPicTexture", SPEEDO.TEXTURES[5][10])
        dxSetShaderValue(SPEEDO.speedShader, "sMaskTexture", SPEEDO.TEXTURES[5][9])
        dxSetShaderValue(SPEEDO.speedShader, "gUVRotAngle", math.rad(rot))

        dxDrawImage(x, y, 220/zoom, 220/zoom, SPEEDO.speedShader,0,0,0,tocolor(unpack(speedoColor)))
    end
end