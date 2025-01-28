--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPEEDO.render_1=function(vehicle)
    SPEEDO.getRenderLPG(vehicle, sw-410/zoom, sh-40/zoom, true)

    local speed=getElementSpeed(vehicle, 1)
    local distance = getElementData(vehicle, "vehicle:distance") or 0
    local fuel,bak=SPEEDO.getFuel(vehicle)
    
    local speedoColor=getElementData(vehicle, "vehicle:speedoColor")
    if(speedoColor)then
        speedoColor=exports['px_workshop-illegal']:getVehicleSpeedoColorName(speedoColor) or {150,150,150}
    else
        speedoColor={150,150,150}
    end
    if(getVehicleOverrideLights(vehicle) ~= 2)then
        speedoColor={150,150,150}
    end
    --

    dxDrawImage(sw-304/zoom-20/zoom, sh-246/zoom-20/zoom, 304/zoom, 246/zoom, SPEEDO.TEXTURES[1][1])
    dxDrawImage(sw-304/zoom, sh-246/zoom-12/zoom, 262/zoom, 262/zoom, SPEEDO.TEXTURES[1][2])

    -- predkosc
    dxDrawText(math.floor(speed), sw-304/zoom-20/zoom, sh-246/zoom+50/zoom, 304/zoom+sw-304/zoom-20/zoom, 246/zoom+sh-246/zoom-20/zoom, tocolor(200, 200, 200), 1, SPEEDO.fonts[1][1], "center", "top")
    dxDrawText("KM/H", sw-304/zoom-20/zoom, sh-246/zoom+85/zoom, 304/zoom+sw-304/zoom-20/zoom, 246/zoom+sh-246/zoom-20/zoom, tocolor(200, 200, 200), 1, SPEEDO.fonts[1][2], "center", "top")

    -- biegi
    dxDrawText(SPEEDO.gear, sw-304/zoom-20/zoom, sh-246/zoom+103/zoom, 304/zoom+sw-304/zoom-20/zoom, 246/zoom+sh-246/zoom-20/zoom, tocolor(200, 200, 200), 1, SPEEDO.fonts[1][3], "center", "top")

    -- przebieg
    distance=string.format("%.1f", distance)
    
    local hex=RGBToHex(unpack(speedoColor))
    dxDrawText("PRZEBIEG", sw-304/zoom-20/zoom, sh-246/zoom+170/zoom, 304/zoom+sw-304/zoom-20/zoom, 246/zoom+sh-246/zoom-20/zoom, tocolor(222, 222, 222), 1, SPEEDO.fonts[1][4], "center", "top")
    dxDrawText("#f3f3f3"..string.sub(distance, 1, string.len(distance)-1)..hex..string.sub(distance, string.len(distance), string.len(distance)), sw-304/zoom-20/zoom, sh-246/zoom+190/zoom, 304/zoom+sw-304/zoom-20/zoom, 246/zoom+sh-246/zoom-20/zoom, tocolor(222, 222, 222), 1, SPEEDO.fonts[1][4], "center", "top", false, false, false, true)
    local export=exports.px_custom_vehicles
    if(export)then
        local fuel_usage=export:getFuelUsage(vehicle)
        dxDrawText(fuel_usage.."l / 100km", sw-304/zoom-20/zoom, sh-246/zoom+190/zoom+18/zoom, 304/zoom+sw-304/zoom-20/zoom, 246/zoom+sh-246/zoom-20/zoom, tocolor(150, 150, 150), 1, SPEEDO.fonts[1][4], "center", "top", false, false, false, true)
    end
    -- speed
    speed=speed > 265 and 265 or speed
    local img=SPEEDO.TEXTURES[1][3]
    local rot=speed-92
    if(speed > 89 and speed < 180)then
        img=SPEEDO.TEXTURES[1][4]
        rot=rot-89
    elseif(speed > 175)then
        img=SPEEDO.TEXTURES[1][5]
        rot=rot-175
    end
    dxSetShaderValue(SPEEDO.speedShader, "sPicTexture", img)
    dxSetShaderValue(SPEEDO.speedShader, "sMaskTexture", SPEEDO.TEXTURES[1][6])
    dxSetShaderValue(SPEEDO.speedShader, "gUVRotAngle", math.rad(-rot))

    dxDrawImage(sw-304/zoom, sh-246/zoom-12/zoom, 262/zoom, 262/zoom, SPEEDO.speedShader, 0, 0, 0, tocolor(unpack(speedoColor)))

    -- fuel
    local rot=59*((bak-fuel)/bak)
    dxSetShaderValue(SPEEDO.speedShader, "sPicTexture", SPEEDO.TEXTURES[1][8])
    dxSetShaderValue(SPEEDO.speedShader, "sMaskTexture", SPEEDO.TEXTURES[1][7])
    dxSetShaderValue(SPEEDO.speedShader, "gUVRotAngle", math.rad(-rot))

    dxDrawImage(sw-304/zoom-8/zoom, sh-246/zoom-20/zoom, 278/zoom, 278/zoom, SPEEDO.TEXTURES[1][7], 0, 0, 0, tocolor(255,255,255,255))
    dxDrawImage(sw-304/zoom-8/zoom, sh-246/zoom-20/zoom, 278/zoom, 278/zoom, SPEEDO.speedShader, 0, 0, 0, tocolor(unpack(speedoColor)))

    local percent=math.floor((fuel/bak)*100)
    if(percent < 10 and percent > 5)then
        dxDrawImage(sw-25/zoom, sh-120/zoom, 15/zoom, 15/zoom, SPEEDO.TEXTURES["f_circle"], 0, 0, 0, tocolor(255, 150, 0, 200))
    elseif(percent < 5)then
        local a=interpolateBetween(0, 0, 0, 200, 0, 0, (getTickCount()-SPEEDO.tick)/1000, "SineCurve")
        dxDrawImage(sw-25/zoom, sh-120/zoom, 15/zoom, 15/zoom, SPEEDO.TEXTURES["f_circle"], 0, 0, 0, tocolor(255, 150, 0, a))
    end

    -- nitro
    if(SPEEDO.isVehicleHaveNitro(vehicle))then
        local nitro=getElementData(vehicle, "vehicle:nitroLevel") or 0

        local rot=59*((100-nitro)/100)
        dxSetShaderValue(SPEEDO.speedShader, "sPicTexture", SPEEDO.TEXTURES[1][10])
        dxSetShaderValue(SPEEDO.speedShader, "sMaskTexture", SPEEDO.TEXTURES[1][9])
        dxSetShaderValue(SPEEDO.speedShader, "gUVRotAngle", math.rad(rot))

        dxDrawImage(sw-304/zoom-9/zoom, sh-246/zoom-20/zoom, 278/zoom, 278/zoom, SPEEDO.TEXTURES[1][9], 0, 0, 0, tocolor(255,255,255,255))
        dxDrawImage(sw-304/zoom-9/zoom, sh-246/zoom-20/zoom, 278/zoom, 278/zoom, SPEEDO.speedShader, 0, 0, 0, tocolor(unpack(speedoColor)))
    end

    dxDrawImage(sw-304/zoom-20/zoom, sh-246/zoom-20/zoom, 304/zoom, 246/zoom, SPEEDO.TEXTURES[1][11], 0, 0, 0, tocolor(unpack(speedoColor)))
end