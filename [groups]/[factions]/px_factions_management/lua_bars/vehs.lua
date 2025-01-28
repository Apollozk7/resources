--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

ui.rendering["vehs"]=function(execute, a)
    local texs=ui.getTextures(execute)
    if(not texs)then return false end

    local x,y,w,h=sw/2-689/2/zoom+42/2/zoom+(689-516)/2/zoom, sh/2-581/2/zoom+42/2/zoom+(581-508)/2/zoom, 516/zoom, 508/zoom
    dxDrawImage(x,y,w,h,texs[1],0,0,0,tocolor(255,255,255,a))

    local hover={}
    for i,v in pairs(getElementsByType("vehicle")) do
        if(getElementData(v, "vehicle:group_owner") == getElementData(localPlayer, "user:faction"))then
            local pos={getElementPosition(v)}
            local p1,p2=pos[1]+3000,pos[2]-3000
            local p1,p2=x+(w*(p1/6000)),y+(h*(p2/-6000))
            dxDrawImage(p1-17/2/zoom,p2-17/2/zoom,17/zoom,17/zoom,texs[3],0,0,0,tocolor(255,255,255,a))

            if(isMouseInPosition(p1-17/2/zoom,p2-17/2/zoom,17/zoom,17/zoom))then
                hover={p1-17/2/zoom,p2-17/2/zoom,17/zoom,17/zoom,v}
            end
        end
    end

    if(#hover > 0 and hover[5] and isElement(hover[5]))then
        local id=getElementData(hover[5], "vehicle:group_id") or 0
        local name=getVehicleName(hover[5])
        local controller=getVehicleController(hover[5])
        controller=controller and getPlayerName(controller) or "brak"
        local lastDriver=getElementData(hover[5], "vehicle:lastDrivers")[1] or "brak"
        local pos={getElementPosition(hover[5])}
        local zone=getZoneName(pos[1],pos[2],pos[3],false)

        dxDrawImage(math.floor(hover[1]+17/2/zoom),math.floor(hover[2]-128/zoom+17/2/zoom),185/zoom,128/zoom,texs[2],0,0,0,tocolor(255,255,255,a))
        dxDrawText(name.." ("..id..")", math.floor(hover[1]+17/2/zoom)+13/zoom,math.floor(hover[2]-128/zoom+17/2/zoom),185/zoom,math.floor(hover[2]-128/zoom+17/2/zoom)+33/zoom, tocolor(200, 200, 200,a), 1, assets.fonts[1], "left", "center")
        dxDrawRectangle(math.floor(hover[1]+17/2/zoom),math.floor(hover[2]-128/zoom+17/2/zoom)+33/zoom,185/zoom,1,tocolor(75,75,75,a))
    
        dxDrawText("Kierowca: "..controller.."\nOstatni: "..lastDriver.."\n#7c7c7c"..zone, math.floor(hover[1]+17/2/zoom)+13/zoom,math.floor(hover[2]-128/zoom+17/2/zoom)+33/zoom,185/zoom,math.floor(hover[2]-128/zoom+17/2/zoom)+33/zoom+(128-33)/zoom-26/zoom, tocolor(200, 200, 200,a), 1, assets.fonts[5], "left", "center", false, false, false, true)
    end
end