--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

ui.map=false

local mapTexture=false
local hover=false
local floor=math.floor
local catchPos=false
local pos={0, 0, 3072, 3072}
local mapZoom=3
local hovers={}

local mapTexture=false

ui.getBlipPosition=function(v)
    local x,y,w,h=floor(pos[1]+(689/zoom-(pos[3]/mapZoom))/2), floor(pos[2]+(540/zoom-(pos[4]/mapZoom))/2), floor(pos[3]/mapZoom), floor(pos[4]/mapZoom)
    local pos={getElementPosition(v)}
    local p1,p2=pos[1]+3000,pos[2]-3000
    local p1,p2=x+(w*(p1/6000)),y+(h*(p2/-6000))

    return p1,p2
end

ui.updateMapRenderTarget=function(texs, apos)
    local org=ui.sql.org.org
    if(not org)then return end

    hovers={}

    mapTexture=exports.px_map:getMapTexture()
    
    ui.updateRenderTarget(
        function()
            local x,y,w,h=floor(pos[1]+(689/zoom-(pos[3]/mapZoom))/2), floor(pos[2]+(540/zoom-(pos[4]/mapZoom))/2), floor(pos[3]/mapZoom), floor(pos[4]/mapZoom)
            dxDrawImage(x,y,w,h, mapTexture)
        
            for i,v in pairs(getElementsByType("vehicle")) do
                local data=getElementData(v, "vehicle:group_owner")
                local data2=getElementData(v, "vehicle:organization")
                if(data == org or data2 == org)then
                    local p1,p2=ui.getBlipPosition(v)
                    local ww,hh=37/zoom,27/zoom
                    dxDrawImage(p1-ww/2,p2-hh/2,ww,hh,texs[1],0,0,0,tocolor(255,255,255,255))

                    hovers[v]={apos[1]+p1-ww/2, apos[2]+p2-hh/2, ww, hh, function()
                        if(hover ~= v)then
                            buttons.export:destroyButton(buttons.objects[1])
                            buttons.export:destroyButton(buttons.objects[2])

                            buttons.objects[1]=nil
                            buttons.objects[2]=nil
                        end

                        hover=v
                    end}
                end
            end

            for i,v in pairs(getElementsByType("player")) do
                local data=getElementData(v, "user:organization")
                if(data and data == org)then
                    local p1,p2=ui.getBlipPosition(v)
                    local ww,hh=34/zoom,37/zoom
                    dxDrawImage(p1-ww/2,p2-hh/2,ww,hh,texs[3],0,0,0,tocolor(255,255,255,255))
                end
            end

            for i,v in pairs(getElementsByType("house")) do
                local data=getElementData(v, "info")
                if(data and data.organization == org)then
                    local p1,p2=ui.getBlipPosition(v)
                    local ww,hh=34/zoom,31/zoom
                    dxDrawImage(p1-ww/2,p2-hh/2,ww,hh,texs[2],0,0,0,tocolor(255,255,255,255))
                end
            end
        end
    )
end

ui.rendering["map"]=function(execute, a)
    local texs=ui.getTextures(execute)
    if(not texs)then return false end

    local org=ui.sql.org.org
    if(not org)then return end

    local apos={floor(sw/2-730/2/zoom+42/zoom), floor(sh/2-581/2/zoom+42/zoom), floor(689/zoom), floor(540/zoom)}
    if(not ui.renderTarget)then
        ui.renderTarget=dxCreateRenderTarget(floor(689/zoom), floor(540/zoom), true)

        ui.updateMapRenderTarget(texs, apos)
    else
        dxDrawImage(apos[1], apos[2], apos[3], apos[4], ui.renderTarget, 0, 0, 0, tocolor(255, 255, 255, a))
    end

    for i,v in pairs(hovers) do
        if(isMouseInPosition(v[1],v[2],v[3],v[4]))then
            v[5]()
        end
    end

    if(getKeyState("mouse1") and isMouseInPosition(apos[1], apos[2], apos[3], apos[4]))then
        local sx,sy=getCursorPosition()
        sx,sy=sx*sw,sy*sh
        if(not catchPos)then
            local cx,cy=sx-pos[1],sy-pos[2]
            catchPos={cx,cy}
        else
            pos[1],pos[2]=sx-catchPos[1],sy-catchPos[2]

            ui.updateMapRenderTarget(texs, apos)
        end
    else
        catchPos=false
    end

    -- info
    local element=(hover and isElement(hover)) and hover
    if(element and getElementType(element) == "vehicle")then
        dxDrawRectangle(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+581/zoom-130/zoom, 450/zoom, 130/zoom, tocolor(30,30,30,a > 200 and 200 or a))

        local id=getElementData(element, "vehicle:group_id") or getElementData(element, "vehicle:id") or 0
        local name=getVehicleName(element)

        local controller=getVehicleController(element)
        controller=controller and getPlayerName(controller) or "brak"

        local pos={getElementPosition(element)}
        local zone=getZoneName(pos[1],pos[2],pos[3],false)

        local lastDrivers=getElementData(element, "vehicle:lastDrivers") or {"?", "?", "?"}
        local lastDriver=(lastDrivers[#lastDrivers] or "?")..", "..(lastDrivers[#lastDrivers-1] or "?")..", "..(lastDrivers[#lastDrivers-2] or "?")

        local ranks=fromJSON(ui.sql.org.ranks) or {}
        local rank=getElementData(element, "vehicle:orgRank") or 1
        rank=(rank and ranks[rank] and ranks[rank].name) and ranks[rank].name or "brak"

        dxDrawText(name.." ("..id..")", sw/2-730/2/zoom+42/zoom+1, sh/2-581/2/zoom+581/zoom-130/zoom+1, 450/zoom+sw/2-730/2/zoom+42/zoom+1, sh/2-581/2/zoom+581/zoom-130/zoom+35/zoom+1, tocolor(0, 0, 0, a), 1, assets.fonts[1], "center", "center")
        dxDrawText(name.." ("..id..")", sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+581/zoom-130/zoom, 450/zoom+sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+581/zoom-130/zoom+35/zoom, tocolor(222, 222, 222, a), 1, assets.fonts[1], "center", "center")
        dxDrawRectangle(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+581/zoom-130/zoom+35/zoom, 450/zoom, 1, tocolor(80,80,80, a))

        dxDrawText("Ostatni kierowcy: "..lastDriver.."\nLokalizacja: "..zone.."\nKierowca: "..controller.."\nRanga: "..rank, sw/2-730/2/zoom+42/zoom+15/zoom+1, sh/2-581/2/zoom+581/zoom-130/zoom+45/zoom+1, 450/zoom+1, 130/zoom+1, tocolor(0, 0, 0, a), 1, assets.fonts[5], "left", "top")
        dxDrawText("Ostatni kierowcy: "..lastDriver.."\nLokalizacja: "..zone.."\nKierowca: "..controller.."\nRanga: "..rank, sw/2-730/2/zoom+42/zoom+15/zoom, sh/2-581/2/zoom+581/zoom-130/zoom+45/zoom, 450/zoom, 130/zoom, tocolor(222, 222, 222, a), 1, assets.fonts[5], "left", "top")
    
        if(not buttons.objects[1] and not buttons.objects[2])then
            buttons.objects[1]=buttons.export:createButton(sw/2-730/2/zoom+42/zoom+300/zoom, sh/2-581/2/zoom+581/zoom-130/zoom+50/zoom, 120/zoom, 30/zoom, "AWANSUJ", a, 9, false, false, ":px_factions_management/textures/bars/users/awansuj.png")
            buttons.objects[2]=buttons.export:createButton(sw/2-730/2/zoom+42/zoom+300/zoom, sh/2-581/2/zoom+581/zoom-130/zoom+90/zoom, 120/zoom, 30/zoom, "DEGRADUJ", a, 9, false, false, ":px_factions_management/textures/bars/users/degraduj.png", {164,51,51})
        else
            onClick(sw/2-730/2/zoom+42/zoom+300/zoom, sh/2-581/2/zoom+581/zoom-130/zoom+50/zoom, 120/zoom, 30/zoom, function()
                if(SPAM.getSpam())then return end

                triggerServerEvent("rank.up.vehicle", resourceRoot, ui.sql.org.org, element)
            end)

            onClick(sw/2-730/2/zoom+42/zoom+300/zoom, sh/2-581/2/zoom+581/zoom-130/zoom+90/zoom, 120/zoom, 30/zoom, function()
                if(SPAM.getSpam())then return end

                triggerServerEvent("rank.down.vehicle", resourceRoot, ui.sql.org.org, element)
            end)
        end
    end
end