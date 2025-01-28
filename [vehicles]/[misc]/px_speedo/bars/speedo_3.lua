--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

blur=exports.blur

SPEEDO.render_3=function(vehicle)
    local speed=getElementSpeed(vehicle, 1)
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

    blur:dxDrawBlur(sw-165/zoom-207/zoom, sh-40/zoom-54/zoom, 165/zoom, 40/zoom)
    blur:dxDrawBlur(sw-165/zoom-207/zoom+165/zoom, sh-57/zoom-54/zoom, 114/zoom, 57/zoom)

    dxDrawRectangle(sw-165/zoom-207/zoom, sh-40/zoom-54/zoom, 165/zoom, 40/zoom, tocolor(15,15,15,170))
    dxDrawRectangle(sw-165/zoom-207/zoom+165/zoom, sh-57/zoom-54/zoom, 114/zoom, 57/zoom, tocolor(15,15,15,200))

    dxDrawRectangle(sw-165/zoom-207/zoom, sh-40/zoom-54/zoom, 165/zoom, 1, tocolor(130,130,130,255))
    dxDrawRectangle(sw-165/zoom-207/zoom+165/zoom, sh-57/zoom-54/zoom, 114/zoom, 1, tocolor(130,130,130,255))
    dxDrawRectangle(sw-165/zoom-207/zoom+165/zoom, sh-57/zoom-54/zoom+1, 1, 57/zoom-40/zoom, tocolor(130,130,130,255))

    -- prawo
    dxDrawText(math.floor(speed), sw-165/zoom-207/zoom+165/zoom, sh-57/zoom-54/zoom, 114/zoom+sw-165/zoom-207/zoom+165/zoom, 57/zoom+sh-57/zoom-54/zoom, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[3][1], "center", "center")
    dxDrawText("km/h", sw-165/zoom-207/zoom+165/zoom, sh-57/zoom-54/zoom, 114/zoom+sw-165/zoom-207/zoom+165/zoom, 57/zoom+sh-57/zoom-54/zoom, tocolor(200, 200, 200, 125), 1, SPEEDO.fonts[3][2], "right", "bottom")

    -- lewo
    dxDrawText(string.format("%.1f", distance).."km", sw-165/zoom-207/zoom, sh-40/zoom-54/zoom, 99/zoom+sw-165/zoom-207/zoom, 40/zoom+sh-40/zoom-54/zoom, tocolor(200, 200, 200, 255), 1, SPEEDO.fonts[3][3], "center", "center")

    -- paliwo
    dxDrawRectangle(sw-165/zoom-207/zoom+118/zoom, sh-40/zoom-54/zoom+(40-22)/2/zoom, 1, 22/zoom, tocolor(130,130,130,200))
    dxDrawRectangle(sw-165/zoom-207/zoom+118/zoom-(12/2)/zoom, sh-40/zoom-54/zoom+(40-22)/2/zoom, 12/zoom, 1, tocolor(255,0,0,125))

    dxDrawRectangle(sw-165/zoom-207/zoom+118/zoom-(7/2)/zoom, sh-40/zoom-54/zoom+(40-22)/2/zoom+22/zoom-(22*(fuel/bak))/zoom, 7/zoom, 2, tocolor(255,255,255))

    -- biegi
    dxDrawRectangle(sw-165/zoom-207/zoom+165/zoom-22/zoom, sh-40/zoom-54/zoom+1, 22/zoom, 22/zoom, tocolor(15,15,15,200))
    dxDrawText(gears, sw-165/zoom-207/zoom+165/zoom-22/zoom, sh-40/zoom-54/zoom+1, 22/zoom+sw-165/zoom-207/zoom+165/zoom-22/zoom, 22/zoom+sh-40/zoom-54/zoom+1, tocolor(200, 200, 200), 1, SPEEDO.fonts[3][3], "center", "center")
    dxDrawRectangle(sw-165/zoom-207/zoom+165/zoom-17/zoom, sh-40/zoom-54/zoom+1+22/zoom, 17/zoom, 17/zoom, tocolor(15,15,15,200))
    dxDrawText(gear, sw-165/zoom-207/zoom+165/zoom-17/zoom, sh-40/zoom-54/zoom+1+22/zoom, 17/zoom+sw-165/zoom-207/zoom+165/zoom-17/zoom, 17/zoom+sh-40/zoom-54/zoom+1+22/zoom, tocolor(200, 200, 200), 1, SPEEDO.fonts[3][4], "center", "center")

    -- gora
    blur:dxDrawBlur(sw-165/zoom-207/zoom, sh-57/zoom-125/zoom, 282/zoom, 57/zoom)
    dxDrawRectangle(sw-165/zoom-207/zoom, sh-57/zoom-125/zoom, 282/zoom, 57/zoom, tocolor(15,15,15,170))
    dxDrawRectangle(sw-165/zoom-207/zoom, sh-14/zoom-125/zoom, 282/zoom, 14/zoom, tocolor(15,15,15,170))
    dxDrawImage(sw-165/zoom-207/zoom, sh-57/zoom-125/zoom, 282/zoom, 60/zoom, SPEEDO.TEXTURES[3][1])
    dxDrawRectangle(sw-165/zoom-207/zoom, sh-57/zoom-125/zoom, 282/zoom, 1, tocolor(130,130,130,255))

    local x=0
    for i=0,7 do
        i=i*3

        x=x+1
        local sX=(38.7/zoom)*(x-1)
        dxDrawText(i, sw-165/zoom-207/zoom+sX+2/zoom, sh-14/zoom-125/zoom+3, 282/zoom, 14/zoom+sh-14/zoom-125/zoom, tocolor(200, 200, 200), 1, SPEEDO.fonts[3][4], "left", "center")
    end

    rpm=rpm/1.2
    rpm=rpm-300
    rpm=rpm < 0 and 0 or rpm

    rpm=rpm > 7100 and 7100 or rpm
    dxDrawRectangle(sw-165/zoom-207/zoom+(282*(rpm/7100))/zoom, sh-57/zoom-125/zoom, 1, 57/zoom-14/zoom, tocolor(130,130,130,255))
end