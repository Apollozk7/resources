--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- events

ui.lastCreate=false
ui.createPoints=function(isLider, points)
    if(ui.lastCreate)then return end

    ui.lastCreate=true
    setTimer(function() ui.lastCreate=false end, 1000, 1)

    for i,v in pairs(points) do
        local id=v[4] == 1 and 1339 or 1265

        local z=ui.ids[id] == "Kosz" and v[3]-0.35 or v[3]-0.52

        if(not isLider and not ui.markers[i])then
            ui.markers[i]=createColSphere(v[1], v[2], v[3], 1.5)
        end
        
        if(not ui.objects[i])then
            ui.objects[i]=createObject(id, v[1], v[2], z)

            if(ui.ids[id] == "Worek")then
                setObjectScale(ui.objects[i], 0.7)
            end

            setElementCollisionsEnabled(ui.objects[i], false)
        end

        if(not ui.blips[i])then
            ui.blips[i]=createBlip(v[1], v[2], v[3], 22)
        end
    end
end

ui.timerElement=false
ui.onTimer=function()
    local data=getElementData(localPlayer, "user:jobBackTime") or 60
    if(data <= 0)then
        triggerServerEvent("stop.job", resourceRoot, localPlayer)
        return
    else
        setElementData(localPlayer, "user:jobBackTime", data-1, false)
    end
end

ui.onRender=function()
    local offline=0
    for i,v in pairs(ui.players) do
        if(not v or (v and not isElement(v)))then
            offline=offline+1
        end
    end

    if(offline == #ui.players)then
        ui.stopJob()
        return
    end

    -- 3d arrows
    local myPos={getElementPosition(localPlayer)}
    local size=0.5
    for i,v in pairs(ui.markers) do
        if(getElementType(v) == "colshape" and not p.truck)then
            local x,y,z=getElementPosition(v)
            local dist=getDistanceBetweenPoints3D(x,y,z,myPos[1],myPos[2],myPos[3])
            if(dist <= 50)then
                z=interpolateBetween(z+0.3, 0, 0, z+0.5, 0, 0, (getTickCount()-ui.tick)/1500, "SineCurve")
                dxDrawMaterialLine3D(x,y,z+size,x,y,z,assets.textures[4],size,tocolor(255,255,255))
            end
        end
    end
    --

    --
    if(ui.vehicle and isElement(ui.vehicle))then
        -- x buttons
        if(not p.truck and ui.lider ~= localPlayer and not ui.haveTrash)then
            local vehName=getVehicleName(ui.vehicle)
            local platforms=p.trucks[vehName]
            if(platforms)then
                local size=0.3
                for i,v in pairs(platforms) do
                    local x,y,z=getPositionFromElementOffset(ui.vehicle, v[1], v[2], v[3])
                    z=interpolateBetween(z-0.1, 0, 0, z+0.1, 0, 0, (getTickCount()-ui.tick)/1500, "SineCurve")
                    dxDrawMaterialLine3D(x,y,z+size,x,y,z,assets.textures[3],size,tocolor(255,255,255))
                end
            end
        end
        --

        -- zapelnienie
        local job=getElementData(ui.vehicle, "vehicle:job_value") or 0
        local x60=math.percent(95, job.maxValue)

        blur:dxDrawBlur(ui.pos[3][1], ui.pos[3][2], ui.pos[3][3], ui.pos[3][4])
        dxDrawImage(ui.pos[3][1], ui.pos[3][2], ui.pos[3][3], ui.pos[3][4], assets.textures[1])
        
        dxDrawText("Zapełnienie:", ui.pos[4][1], ui.pos[4][2], ui.pos[4][3], ui.pos[4][4], tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
        dxDrawText("min. 95%", ui.pos[4][1], ui.pos[4][2], ui.pos[4][3], ui.pos[4][4], job.value >= x60 and tocolor(52,129,68) or tocolor(100, 100, 100), 1, assets.fonts[1], "center", "top")
        dxDrawText(job.value.."/"..job.maxValue.."KG", ui.pos[4][1], ui.pos[4][2], ui.pos[4][3], ui.pos[4][4], tocolor(150, 150, 150), 1, assets.fonts[1], "right", "top")
        
        dxDrawImage(ui.pos[5][1], ui.pos[5][2], ui.pos[5][3], ui.pos[5][4], assets.textures[2])
        dxDrawRectangle(ui.pos[5][1]+2, ui.pos[5][2]+2, (ui.pos[5][3]-4)*(job.value/job.maxValue), ui.pos[5][4]-4, tocolor(52,129,68))

        if(job.value >= x60 and not ui.markers["landing"] and ui.lider == localPlayer)then
            ui.markers["landing"]=createMarker(641.8910,1222.1268,11.7113, "cylinder", 4, 200, 100, 0)
            ui.blips["landing"]=createBlipAttachedTo(ui.markers["landing"], 22)
            setElementData(ui.markers["landing"], "icon", ":px_jobs-garbageTrucks/textures/marker_trash.png")
        end

        -- distance lider
        if(ui.vehicle and isElement(ui.vehicle))then
            if(getPedOccupiedVehicle(localPlayer) ~= ui.vehicle)then
                local myPos={getElementPosition(localPlayer)}
                local vPos={getElementPosition(ui.vehicle)}
                local dist=getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], vPos[1], vPos[2], vPos[3])
                local data=getElementData(localPlayer, "user:jobBackTime")
                if(dist > 50)then
                    if(not ui.timerElement)then
                        ui.timerElement=setTimer(ui.onTimer,1000,0)
                    end
                else
                    if(getElementData(localPlayer, "user:jobBackTime"))then
                        setElementData(localPlayer, "user:jobBackTime", false, false)
    
                        if(ui.timerElement and isTimer(ui.timerElement))then
                            killTimer(ui.timerElement)
                        end
                        ui.timerElement=false
                    end
                end
            else
                if(getElementData(localPlayer, "user:jobBackTime"))then
                    setElementData(localPlayer, "user:jobBackTime", false, false)
    
                    if(ui.timerElement and isTimer(ui.timerElement))then
                        killTimer(ui.timerElement)
                    end
                    ui.timerElement=false
                end
            end
        else
            triggerLatentServerEvent("stop.job", resourceRoot, localPlayer)
        end
    else
        ui.stopJob()
    end
end

ui.onMarkerHit=function(hit, dim)
    if(hit ~= localPlayer or not dim or not ui.vehicle or (ui.vehicle and not isElement(ui.vehicle)))then return end
    if(getElementData(hit, "user:onGarbagePlatform"))then return end

    if(SPAM.getSpam())then return end

    if(source == ui.markers["landing"] and ui.lider == localPlayer and isPedInVehicle(hit) and getPedOccupiedVehicle(hit) == ui.vehicle)then
        local job=getElementData(ui.vehicle, "vehicle:job_value") or {value=0,maxValue=1000}
        local x60=math.percent(95, job.maxValue)
        if(job.value >= x60)then
            noti:noti("Trwa rozładunek śmieciarki...", "info")

            fadeCamera(false)

            setElementFrozen(localPlayer, true)
            setElementFrozen(ui.vehicle, true)
            
            setTimer(function()
                if(ui.vehicle and isElement(ui.vehicle))then
                    fadeCamera(true)

                    setElementFrozen(localPlayer, false)
                    setElementFrozen(ui.vehicle, false)

                    triggerServerEvent("get.payment", resourceRoot, ui.players, ui.lider, job.value)

                    job.value=0
                    setElementData(ui.vehicle, "vehicle:job_value", job)

                    checkAndDestroy(ui.markers["landing"])
                    ui.markers["landing"]=nil

                    checkAndDestroy(ui.blips["landing"])
                    ui.blips["landing"]=nil

                    noti:noti("Śmieciarka została rozładowana.", "success")
                end
            end, 5000, 1)
        end
    elseif(source == ui.markers["vehicle"] and not isPedInVehicle(hit))then
        local job=getElementData(ui.vehicle, "vehicle:job_value")
        if(not job)then return end

        if(job.value >= job.maxValue)then
            noti:noti("Śmieciarka jest pełna.", "error")

            checkAndDestroy(ui.markers["vehicle"])
            ui.markers["vehicle"]=nil
    
            checkAndDestroy(ui.blips["vehicle"])
            ui.blips["vehicle"]=nil

            ui.haveTrash=false

            triggerServerEvent("take.trash", resourceRoot, ui.vehicle)
            return
        end

        checkAndDestroy(ui.markers["vehicle"])
        ui.markers["vehicle"]=nil

        checkAndDestroy(ui.blips["vehicle"])
        ui.blips["vehicle"]=nil

        noti:noti("Trwa załadunek śmieciarki...", "success")

        local id=ui.haveTrash
        triggerServerEvent("take.trash", resourceRoot, ui.vehicle)
        setTimer(function()
            local add=ui.ids[id] == "Kosz" and 15 or 10
            
            noti:noti("Pomyślnie załadowano śmieciarkę.", "success")

            local markers=0
            for k,v in pairs(ui.markers) do
                if(v and isElement(v) and v ~= ui.markers["vehicle"] and v ~= ui.markers["landing"])then
                    markers=markers+1
                end
            end
        
            if(markers == 0)then
                local names={}
                for i,v in pairs(ui.players) do
                    if(v and isElement(v))then
                        names[#names+1]=getPlayerName(v)
                    end
                end
                triggerServerEvent("get.points", resourceRoot, names)
            end

            triggerServerEvent("add.trash", resourceRoot, ui.vehicle, add)
        end, ui.ids[id] == "Kosz" and 5000 or 1000, 1)
    end
end

ui.onColShapeHit=function(hit, dim)
    if(hit ~= localPlayer or not dim or not ui.vehicle or (ui.vehicle and not isElement(ui.vehicle)))then return end
    if(getElementData(hit, "user:onGarbagePlatform"))then return end
    
    if(SPAM.getSpam())then return end

    local job=getElementData(ui.vehicle, "vehicle:job_value")
    if(not job or isPedInVehicle(hit))then return end

    local shape=source

    local i=0
    for k,v in pairs(ui.markers) do
        if(v and isElement(v))then
            if(shape == v)then
                i=k
            end
        end
    end

    if(id ~= 0)then
        if(not ui.haveTrash and isElement(shape))then
            local obj=ui.objects[i]
            if(obj and isElement(obj))then
                local job=getElementData(ui.vehicle, "vehicle:job_value")
                if(job.value >= job.maxValue)then
                    noti:noti("Śmieciarka jest pełna.", "error")
                else
                    if(ui.ids[getElementModel(obj)] == "Kosz")then
                        ui.haveTrash=i
                        triggerServerEvent("get.trash", resourceRoot, i, ui.players, ui.lider, getElementModel(obj), ui.vehicle)
                    else
                        if(obj and isElement(obj) and isElement(shape))then
                            ui.haveTrash=i
                            triggerServerEvent("get.trash", resourceRoot, i, ui.players, ui.lider, getElementModel(obj), ui.vehicle)
                        end
                    end
                end
            else
                checkAndDestroy(ui.objects[i])
                checkAndDestroy(ui.markers[i])
                checkAndDestroy(ui.blips[i])

                triggerServerEvent("getHaveTrash", resourceRoot, localPlayer, i)
            end
        else
            triggerServerEvent("getHaveTrash", resourceRoot, localPlayer, i)
        end
    else
        triggerServerEvent("getHaveTrash", resourceRoot, localPlayer)
    end
end

-- triggers

addEvent("haveTrash", true)
addEventHandler("haveTrash", resourceRoot, function()
    ui.haveTrash=false
end)

addEvent("create.vehicle.marker", true)
addEventHandler("create.vehicle.marker", resourceRoot, function(id)
    if(not ui.vehicle or (ui.vehicle and not isElement(ui.vehicle)))then return end

    ui.haveTrash=id

    ui.markers["vehicle"]=createMarker(0, 0, 0, "cylinder", 1.2, 0, 200, 100)
    ui.blips["vehicle"]=createBlipAttachedTo(ui.vehicle, 22)
    attachElements(ui.markers["vehicle"], ui.vehicle, 0, -5, -1)
    setElementData(ui.markers["vehicle"], "block:z", true)
    setElementData(ui.markers["vehicle"], "icon", ":px_jobs-garbageTrucks/textures/marker_trash.png", false)
end)

addEvent("get.trash", true)
addEventHandler("get.trash", resourceRoot, function(id)
    if(ui.haveTrash == id)then
        ui.haveTrash=false
    end

    checkAndDestroy(ui.markers[id])
    ui.markers[id]=nil

    checkAndDestroy(ui.blips[id])
    ui.blips[id]=nil

    checkAndDestroy(ui.objects[id])
    ui.objects[id]=nil
end)

addEvent("start.job", true)
addEventHandler("start.job", resourceRoot, function(info, players, lider, vehicle,points)
    if(not players or (players and #players < 1) or not lider or (lider and not isElement(lider)) or not vehicle or (vehicle and not isElement(vehicle)))then return end

    setElementData(localPlayer, "user:jobBackTime", false, false)

    ui.lider=lider
    ui.players=players
    ui.vehicle=vehicle
    ui.haveTrash=false

    ui.createPoints(ui.lider==localPlayer,points)

    addEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    addEventHandler("onClientColShapeHit", resourceRoot, ui.onColShapeHit)
    addEventHandler("onClientRender", root, ui.onRender)
    addEventHandler("onClientVehicleStartEnter", resourceRoot, ui.onClientStartEnter)
    addEventHandler("onClientPlayerWasted", localPlayer, ui.stopJob)

    assets.create()
    
    toggleControl("crouch", false)
    toggleControl("jump", false)

    if(info.upgrades["Szybcior"] and lider == localPlayer)then
        toggleControl("sprint", true)
    else
        toggleControl("sprint", false)
    end
end)

addEvent("set.upgrade", true)
addEventHandler("set.upgrade", resourceRoot, function()
    toggleControl("sprint", true)
end)

addEvent("create.points", true)
addEventHandler("create.points", resourceRoot, function(points)
    ui.block=nil

    for i,v in pairs(ui.markers) do
        checkAndDestroy(v)
    end
    ui.markers={}

    for i,v in pairs(ui.blips) do
        checkAndDestroy(v)
    end
    ui.blips={}

    for i,v in pairs(ui.objects) do
        checkAndDestroy(v)
    end
    ui.objects={}

    ui.createPoints(ui.lider==localPlayer, points)
end)

ui.stopJob=function()
    setElementData(localPlayer, "user:jobBackTime", false, false)

    removeEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    removeEventHandler("onClientColShapeHit", resourceRoot, ui.onColShapeHit)
    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientVehicleStartEnter", resourceRoot, ui.onClientStartEnter)
    removeEventHandler("onClientPlayerWasted", localPlayer, ui.stopJob)

    assets.destroy()

    for i,v in pairs(ui.markers) do
        checkAndDestroy(v)
    end
    ui.markers={}

    for i,v in pairs(ui.blips) do
        checkAndDestroy(v)
    end
    ui.blips={}

    for i,v in pairs(ui.objects) do
        checkAndDestroy(v)
    end
    ui.objects={}

    toggleControl("crouch", true)
    toggleControl("jump", true)
    toggleControl("sprint", true)

    for i,v in pairs(ui.players) do
        if(v and isElement(v))then
            triggerServerEvent("stop.job", resourceRoot, v)
        end
    end
    ui.players={}

    triggerServerEvent("stop.job", resourceRoot, localPlayer)
end
addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, ui.stopJob)

addEvent("check.players", true)
addEventHandler("check.players", resourceRoot, function(player)
    if(ui.players and #ui.players > 0)then
        local offline=0
        for i,v in pairs(ui.players) do
            if(v == player)then
                ui.players[i]=nil
                offline=offline+1
                break
            end
        end

        if(#ui.players == 0 or offline == #ui.players)then
            ui.stopJob()
        end
    end
end)

-- enter

ui.onClientStartEnter=function(player,seat)
    if(seat == 0 and source == ui.vehicle)then else
        cancelEvent()
    end
end
