--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPEEDO.render_2=function(vehicle)
    SPEEDO.getRenderLPG(vehicle, sw-548/zoom, sh-40/zoom, true)

    local speed=getElementSpeed(vehicle, 1)
    local rpm=exports.bengines:getVehicleRPM(vehicle)/1.3

    local distance = getElementData(vehicle, "vehicle:distance") or 0
    
    local speedoColor=getElementData(vehicle, "vehicle:speedoColor")
    if(speedoColor)then
        speedoColor=exports['px_workshop-illegal']:getVehicleSpeedoColorName(speedoColor) or {150,150,150}
    else
        speedoColor={150,150,150}
    end
    if(getVehicleOverrideLights(vehicle) ~= 2)then
        speedoColor={150,150,150}
    end
    
    local fuel,bak=SPEEDO.getFuel(vehicle)

    local a=interpolateBetween(100, 0, 0, 281, 0, 0, (getTickCount()-SPEEDO.tick)/500, "SineCurve")

    -- draw
    -- tarcza
    dxDrawImage(sw-500/zoom, sh-350/zoom, 487/zoom, 327/zoom, SPEEDO.TEXTURES[2][1])
    dxDrawImage(sw-500/zoom, sh-350/zoom, 487/zoom, 327/zoom, SPEEDO.TEXTURES[2][20], 0, 0, 0, tocolor(speedoColor[1],speedoColor[2],speedoColor[3],100))

    -- speed
    local speedo=speed
    speed=speed > 240 and 240 or speed

    local x,y=sw-500/zoom+182/zoom, sh-325/zoom
    local rot=275*((speed*1.04)/240)
    local img=SPEEDO.TEXTURES[2][2]
    if(rot > 90 and rot < 160)then
        img=SPEEDO.TEXTURES[2][14]
        rot=rot-65
    elseif(rot > 160 and rot < 200)then
        img=SPEEDO.TEXTURES[2][15]
        rot=rot-(65*2)+5
    elseif(rot > 200)then
        img=SPEEDO.TEXTURES[2][16]
        rot=rot-(65*2)-65
    end

    dxSetShaderValue(SPEEDO.speedShader, "sPicTexture", img)
    dxSetShaderValue(SPEEDO.speedShader, "sMaskTexture", SPEEDO.TEXTURES[2][3])
    dxSetShaderValue(SPEEDO.speedShader, "gUVRotAngle", math.rad(-rot))

    dxDrawImage(x,y, 281/zoom, 281/zoom, SPEEDO.speedShader, 0, 0, 0, tocolor(speedoColor[1],speedoColor[2],speedoColor[3],255))
    dxDrawText(math.floor(speedo), x, y-10/zoom, 281/zoom+x, 281/zoom+y, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[2][1], "center", "center", false)
    dxDrawText("km/h", x, y-80/zoom, 281/zoom+x, 281/zoom+y, tocolor(113, 113, 113, 255), 1, SPEEDO.fonts[2][3], "center", "center", false)

    dxDrawImage(x+(281-39)/2/zoom-30/zoom, y+(281-34)/2/zoom+35/zoom, 39/zoom, 34/zoom, getVehicleOverrideLights(vehicle) == 1 and SPEEDO.TEXTURES[2][6] or SPEEDO.TEXTURES[2][7], 0, 0, 0, getVehicleOverrideLights(vehicle) ~= 1 and tocolor(unpack(speedoColor)) or tocolor(255,255,255))
    dxDrawImage(x+(281-39)/2/zoom, y+(281-34)/2/zoom+35/zoom, 39/zoom, 34/zoom, getVehicleEngineState(vehicle) and SPEEDO.TEXTURES[2][9] or SPEEDO.TEXTURES[2][8], 0, 0, 0, getVehicleEngineState(vehicle) and tocolor(unpack(speedoColor)) or tocolor(255,255,255))
    dxDrawImage(x+(281-40)/2/zoom+30/zoom, y+(281-36)/2/zoom+35/zoom, 40/zoom, 36/zoom, getElementData(vehicle, "vehicle:handbrake") and SPEEDO.TEXTURES[2][11] or SPEEDO.TEXTURES[2][10], 0, 0, 0, getElementData(vehicle, "vehicle:handbrake") and tocolor(unpack(speedoColor)) or tocolor(255,255,255))

    dxDrawImage(x+(282-98)/2/zoom, y+230/zoom, 98/zoom, 29/zoom, SPEEDO.TEXTURES[2][17])
    dxDrawText(string.format("%05d", math.floor(distance)), 0, y+230/zoom, 98/zoom+x+(282-98)/2/zoom-40/zoom, 29/zoom+y+230/zoom, tocolor(170, 170, 170, 255), 1, SPEEDO.fonts[2][8], "right", "center", false)
    dxDrawText("km", 0, y+230/zoom, 98/zoom+x+(282-98)/2/zoom-40/zoom+20/zoom, 29/zoom+y+230/zoom, tocolor(170, 170, 170, 255), 1, SPEEDO.fonts[2][3], "right", "center", false)
    
    -- obroty
    local x,y=sw-483/zoom, sh-239/zoom
    rpm=rpm > 7000 and 7000 or rpm
    local rot=180*(rpm/7000)
    dxSetShaderValue(SPEEDO.speedShader, "sPicTexture", SPEEDO.TEXTURES[2][4])
    dxSetShaderValue(SPEEDO.speedShader, "sMaskTexture", SPEEDO.TEXTURES[2][5])
    dxSetShaderValue(SPEEDO.speedShader, "gUVRotAngle", math.rad(-rot))

    rpm=math.floor(rpm)
    local r1=string.sub(rpm, 0, 1)
    local r2=string.sub(rpm, 2, string.len(rpm))
    dxDrawImage(x, y, 198/zoom, 198/zoom, SPEEDO.speedShader, 0, 0, 0, tocolor(unpack(speedoColor)))
    dxDrawText(SPEEDO.gear, x, y+5/zoom-15/zoom, 198/zoom+x, 198/zoom+y-15/zoom, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[2][9], "center", "center", false)
    dxDrawText("bieg", x, y+50/zoom-15/zoom, 198/zoom+x, 198/zoom+y-15/zoom, tocolor(113, 113, 113, 255), 1, SPEEDO.fonts[2][4], "center", "center", false)

    local export=exports.px_custom_vehicles
    if(export)then
        local fuel_usage=export:getFuelUsage(vehicle)
        dxDrawText("Spalanie", x, y+165/zoom-15/zoom, 198/zoom+x, 198/zoom+y-15/zoom, tocolor(134, 134, 134, 255), 1, SPEEDO.fonts[2][4], "center", "center", false)
        dxDrawText(fuel_usage.."l", x, y+195/zoom-15/zoom, 198/zoom+x, 198/zoom+y-15/zoom, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[2][7], "center", "center", false)
    end

    -- paliwo
    local x,y=sw-500/zoom+182/zoom, sh-351/zoom
    local rot=67*((bak-fuel)/bak)
    dxDrawImage(x+(281-325)/2/zoom, y, 325/zoom, 325/zoom, SPEEDO.TEXTURES[2][12])

    dxSetShaderValue(SPEEDO.speedShader, "sPicTexture", SPEEDO.TEXTURES[2][13])
    dxSetShaderValue(SPEEDO.speedShader, "sMaskTexture", SPEEDO.TEXTURES[2][12])
    dxSetShaderValue(SPEEDO.speedShader, "gUVRotAngle", math.rad(rot))

    dxDrawImage(x+(281-325)/2/zoom, y, 325/zoom, 325/zoom, SPEEDO.speedShader, 0, 0, 0, tocolor(unpack(speedoColor)))

    local percent=math.floor((fuel/bak)*100)
    if(percent < 10 and percent > 5)then
        dxDrawImage(sw-167/zoom, sh-50/zoom, 10/zoom, 10/zoom, SPEEDO.TEXTURES["f_circle"], 0, 0, 0, tocolor(255, 150, 0, 200))
    elseif(percent < 5)then
        local a=interpolateBetween(0, 0, 0, 200, 0, 0, (getTickCount()-SPEEDO.tick)/1000, "SineCurve")
        dxDrawImage(sw-167/zoom, sh-50/zoom, 10/zoom, 10/zoom, SPEEDO.TEXTURES["f_circle"], 0, 0, 0, tocolor(255, 150, 0, a))
    end

    -- nitro
    if(SPEEDO.isVehicleHaveNitro(vehicle))then
        local x,y=sw-500/zoom+36/zoom, sh-232/zoom
        local nitro_max=100
        local nitro=getElementData(vehicle, "vehicle:nitroLevel") or 0
        local rot=67*((nitro_max-nitro)/nitro_max)
        dxDrawImage(x+(281-325)/2/zoom, y, 203/zoom, 203/zoom, SPEEDO.TEXTURES[2][18])

        dxSetShaderValue(SPEEDO.speedShader, "sPicTexture", SPEEDO.TEXTURES[2][19])
        dxSetShaderValue(SPEEDO.speedShader, "sMaskTexture", SPEEDO.TEXTURES[2][19])
        dxSetShaderValue(SPEEDO.speedShader, "gUVRotAngle", math.rad(rot))

        dxDrawImage(x+(281-325)/2/zoom, y, 203/zoom, 203/zoom, SPEEDO.speedShader, 0, 0, 0, tocolor(unpack(speedoColor)))
    end
end