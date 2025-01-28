--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer)then
        killTimer(SPAM.blockSpamTimer)
        block=true

        if(not SPAM.blockNoti)then
            exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
            SPAM.blockNoti=setTimer(function() SPAM.blockNoti=nil end, 300, 1)
        end
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 300, 1)

    return block
end

ui.timerElement=false
ui.onTimer=function()
    local data=getElementData(localPlayer, "user:jobBackTime") or 60
    if(data <= 0)then
        triggerLatentServerEvent("stop.job", resourceRoot, localPlayer)
        return
    else
        setElementData(localPlayer, "user:jobBackTime", data-1, false)
    end
end

ui.onRender=function()
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
end

ui.getDXInfo=function(box)
    dxDrawImage(ui.pos[3][1], ui.pos[3][2], ui.pos[3][3], ui.pos[3][4], assets.textures[3])

    dxDrawImage(ui.pos[3][1], ui.pos[3][2], ui.pos[3][3], ui.pos[3][4], assets.textures[3])

    dxDrawText("Informacje o przesyłce", ui.pos[4][1], ui.pos[4][2], ui.pos[4][3], ui.pos[4][4], tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
    dxDrawImage(ui.pos[5][1], ui.pos[5][2], ui.pos[5][3], ui.pos[5][4], assets.textures[4])
    for i=1,5 do
        local index=i == 1 and "Nr przesyłki" or i == 2 and "Waga" or i == 3 and "Kategoria" or i == 4 and "Cena" or i == 5 and "Delikatny"
        local value=i == 1 and box.nr or i == 2 and box.sales or i == 3 and box.type or i == 4 and box.cost.."$" or i == 5 and box.delicate

        local sY=(ui.pos[8][2])*(i-1)
        dxDrawText(index..":", ui.pos[5][1]+ui.pos[8][1], ui.pos[5][2]+ui.pos[8][1]+sY, ui.pos[5][3], ui.pos[5][4], tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
        dxDrawText(value, ui.pos[5][1]+ui.pos[8][1], ui.pos[5][2]+ui.pos[8][1]+sY, ui.pos[5][1]+ui.pos[5][3]-ui.pos[8][1], ui.pos[5][4], tocolor(200, 200, 200), 1, assets.fonts[2], "right", "top")
    end

    dxDrawText("Dane adresata", ui.pos[6][1], ui.pos[6][2], ui.pos[6][3], ui.pos[6][4], tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
    dxDrawImage(ui.pos[7][1], ui.pos[7][2], ui.pos[7][3], ui.pos[7][4], assets.textures[4])
    for i=1,5 do
        local index=i == 1 and "Imię" or i == 2 and "Nazwisko" or i == 3 and "Miejscowość" or i == 4 and "Ulica" or i == 5 and "Nr budynku"
        local value=i == 1 and box.name or i == 2 and box.lastName or i == 3 and box.city or i == 4 and box.street or i == 5 and box.houseID

        local sY=(ui.pos[8][2])*(i-1)
        dxDrawText(index..":", ui.pos[7][1]+ui.pos[8][1], ui.pos[7][2]+ui.pos[8][1]+sY, ui.pos[7][3], ui.pos[7][4], tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
        dxDrawText(value, ui.pos[7][1]+ui.pos[8][1], ui.pos[7][2]+ui.pos[8][1]+sY, ui.pos[7][3]+ui.pos[7][1]-ui.pos[8][1], ui.pos[7][4], tocolor(200, 200, 200), 1, assets.fonts[2], "right", "top")
    end

    -- qr
    dxDrawImage(ui.pos[9][1], ui.pos[9][2], ui.pos[9][3], ui.pos[9][4], assets.textures[5])
    dxDrawText("Aby zeskanować przesyłkę, wciśnij przycisk [SPACJA]", ui.pos[10][1], ui.pos[10][2], ui.pos[10][3], ui.pos[10][4], tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")

    dxDrawImage(ui.pos[3][1], ui.pos[3][2], ui.pos[3][3], ui.pos[3][4], assets.textures[6])
end

ui.clientScan=function()
    local box=ui.boxesInfos[ui.clientScanID]
    if(not box or not ui.clientScanID or ui.blockGetBox)then return end

    ui.getDXInfo(box)

    if(getKeyState("space"))then
        if(SPAM.getSpam())then return end

        removeEventHandler("onClientRender", root, ui.clientScan)

        assets.destroy()

        ui.haveClientBox=false

        triggerLatentServerEvent("destroy.box", resourceRoot, nil, ui.clientScanID)

        setTimer(function()
            checkAndDestroy(ui.markers["client_"..ui.clientScanID])
            ui.markers["client_"..ui.clientScanID]=nil
            
            checkAndDestroy(ui.blips["client_"..ui.clientScanID])
            ui.blips["client_"..ui.clientScanID]=nil
    
            checkAndDestroy(ui.peds["client_"..ui.clientScanID])
            ui.peds["client_"..ui.clientScanID]=nil
    
            ui.points[ui.clientScanID]=nil
            
            if(table.size(ui.points) < 1)then
                noti:noti("Wróć na bazę, aby załadować paczki.", "info")

                ui.zones["baza"]=createColSphere(2814.6326,978.2375,10.9141, 50)
                ui.blips["baza"]=createBlipAttachedTo(ui.zones["baza"], 22)
            else
                noti:noti("Udaj się do kolejnego klienta.", "info")
            end
    
            triggerLatentServerEvent("get.payment", resourceRoot)

            setElementFrozen(localPlayer, false)
        end, 1000, 1)
    end
end

ui.onDative=function()
    local box=ui.boxesInfos[ui.box]
    if(not box)then return end

    local object=ui.boxes[ui.box]
    if(not object)then return end

    if(getKeyState("X"))then
        dxDrawImage(ui.pos[1][1], ui.pos[1][2], ui.pos[1][3], ui.pos[1][4], assets.textures[1])

        local target=getTarget()
        if(target and isElement(target) and target == object)then
            local pos={getElementPosition(target)}
            local myPos={getElementPosition(localPlayer)}
            local dist=getDistanceBetweenPoints3D(pos[1],pos[2],pos[3],myPos[1],myPos[2],myPos[3])
            if(dist < 1)then
                dxDrawImage(ui.pos[2][1], ui.pos[2][2], ui.pos[2][3], ui.pos[2][4], assets.textures[2])

                ui.getDXInfo(box)

                if(getKeyState("space"))then
                    if(SPAM.getSpam())then return end

                    checkAndDestroy(ui.blips["box"])
                    ui.blips["box"]=nil

                    removeEventHandler("onClientRender", root, ui.onDative)

                    assets.destroy()

                    ui.markers["vehicle"]=createMarker(0,0,0,"cylinder",1.2,255,0,0)
                    setElementData(ui.markers["vehicle"], "icon", ":px_jobs-courier/textures/marker_parcel.png")

                    attachElements(ui.markers["vehicle"], ui.vehicle, 0, -4, 1)
                    ui.blips["vehicle"]=createBlipAttachedTo(ui.markers["vehicle"], 22)

                    triggerLatentServerEvent("get.box", resourceRoot, ui.boxID, ui.box, nil, getElementData(ui.boxes[ui.box], "box_shader"))

                    setTimer(function()
                        checkAndDestroy(ui.boxes[ui.box])
                        ui.boxes[ui.box]=nil
                    end, 1000, 1)
                end
            end
        end
    end
end

ui.createBox=function()
    local info=ui.boxesInfos[ui.box]
    if(not info)then return end

    local tape=math.random(1,#ui.tapes)
    local pos=ui.tapes[tape] or ui.tapes[1]

    ui.boxes[ui.box]=createObject(ui.boxID, pos[1], pos[2], pos[3]-0.77)
    moveObject(ui.boxes[ui.box], 5000, pos[1], ui.tapeMaxY, pos[3]-0.77)
    setElementData(ui.boxes[ui.box], "box_shader", info.boxShader)

    ui.blips["box"]=createBlipAttachedTo(ui.boxes[ui.box], 22)

    setTimer(function()
        noti:noti("Aby zeskanować paczkę, przytrzymaj 'X', następnie na nią najedź i kliknij spację.")

        assets.create()
        addEventHandler("onClientRender", root, ui.onDative)
    end, 5000, 1)
end

ui.onMarkerHit=function(hit, dim)
    if(hit ~= localPlayer or not dim)then return end

    if(source == ui.markers["vehicle"])then
        if(ui.action == "getBoxes")then
            if(SPAM.getSpam())then return end

            triggerLatentServerEvent("destroy.box", resourceRoot, "attach", ui.box, #ui.points)

            checkAndDestroy(ui.markers["vehicle"])
            ui.markers["vehicle"]=nil
            checkAndDestroy(ui.blips["vehicle"])
            ui.blips["vehicle"]=nil

            ui.box=ui.box-1
            if(ui.box == 0)then
                noti:noti("Wszystkie paczki zostały załadowane, następnie rozwieź je po klientach.", "success")

                for i,v in pairs(ui.points) do
                    ui.createPeds(i)
                end

                ui.action="getClients"

                triggerLatentServerEvent("warp.vehicle", resourceRoot)
            else
                noti:noti("Udaj się po następną paczkę.", "info")

                ui.createBox()
            end
        elseif(ui.action == "getClients" and not ui.haveClientBox)then
            local client=ui.getNearestClient()
            if(client)then
                ui.clientScanID=tonumber(client.id)
    
                local info=ui.boxesInfos[ui.clientScanID]
                if(not info)then return end
    
                local myPos={getElementPosition(localPlayer)}
                local hisPos={getElementPosition(client.element)}
                local dist=getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], hisPos[1], hisPos[2], hisPos[3])
                if(dist < 50 and dist > 5)then
                    if(SPAM.getSpam() or ui.blockGetBox)then return end

                    checkAndDestroy(ui.markers["vehicle"])
                    ui.markers["vehicle"]=nil
                    checkAndDestroy(ui.blips["vehicle"])
                    ui.blips["vehicle"]=nil

                    triggerLatentServerEvent("get.box", resourceRoot, ui.boxID, ui.clientScanID, true, info.boxShader)
    
                    ui.haveClientBox=true
                    ui.blockGetBox=true
                else
                    noti:noti("Aby wyciągnąć paczkę musisz znajdować się maksmimum 50 metrów lub minimum 3 metry od klienta.", "error")
                end
            end
        end
    elseif(ui.haveClientBox and ui.clientScanID)then
        local pos={getElementPosition(localPlayer)}
        pos[3]=pos[3]+1

        for i,v in pairs(ui.markers) do
            local mPos={getElementPosition(v)}
            if(pos[3] >= mPos[3])then
                if(string.find(i, "client") and source == v)then
                    local id=string.gsub(i,"client_","")
                    if(tonumber(id) == ui.clientScanID)then
                        assets.create()
                        addEventHandler("onClientRender", root, ui.clientScan)
                        setElementFrozen(localPlayer, true)

                        break
                    end
                end
            end
        end
    end
end

ui.onColShapeHit=function(hit, dim)
    if(hit ~= localPlayer or not dim)then return end

    if(source == ui.zones["baza"])then
        ui.box=ui.getStartBoxes()
        ui.points=ui.getRandomPoints(ui.box)
        ui.action="getBoxes"

        ui.boxesInfos={}
        for i=1,ui.box do
            ui.boxesInfos[i]=ui.generateRandomBoxInfo(i)
        end

        checkAndDestroy(ui.zones["baza"])
        ui.zones["baza"]=nil

        checkAndDestroy(ui.blips["baza"])
        ui.blips["baza"]=nil

        ui.createBox()
    end
end

addEvent("start.job", true)
addEventHandler("start.job", resourceRoot, function(vehicle, info, reverse)
    setElementData(localPlayer, "user:jobBackTime", false, false)

    if(vehicle)then
        ui.vehicle=vehicle
    end

    if(info)then
        ui.info=info

        if(info.upgrades["Siłacz"])then
            ui.boxID=3005
        else
            ui.boxID=3006
        end

        if(not info.upgrades["Szybcior"])then
            toggleControl("sprint", false)
        end
    end

    ui.box=ui.getStartBoxes()
    ui.points=ui.getRandomPoints(ui.box)
    ui.action="getBoxes"

    ui.boxesInfos={}
    for i=1,ui.box do
        ui.boxesInfos[i]=ui.generateRandomBoxInfo(i)
    end

    if(not reverse)then
        ui.createBox()
    end

    ui.haveClientBox=false

    addEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    addEventHandler("onClientVehicleStartEnter", resourceRoot, ui.onClientVehicleStartEnter)
    addEventHandler("onClientRender", root, ui.onRender)
    addEventHandler("onClientColShapeHit", root, ui.onColShapeHit)
    addEventHandler("onClientPlayerWasted", localPlayer, wasted)

    toggleControl("crouch", false)
    toggleControl("jump", false)
end)

addEvent('back.get.box', true)
addEventHandler('back.get.box', resourceRoot, function()
    ui.blockGetBox=nil
end)

function wasted()
    triggerLatentServerEvent("stop.job", resourceRoot)
    stopJob()
end

function stopJob()  
    if(ui.timerElement and isTimer(ui.timerElement))then
        killTimer(ui.timerElement)
    end
    ui.timerElement=false
    setElementData(localPlayer, "user:jobBackTime", false, false)

    for i,v in pairs(ui.markers) do
        checkAndDestroy(v)
    end
    ui.markers={}

    for i,v in pairs(ui.blips) do
        checkAndDestroy(v)
    end
    ui.blips={}

    for i,v in pairs(ui.boxes) do
        checkAndDestroy(v)
    end
    ui.boxes={}

    for i,v in pairs(ui.zones) do
        checkAndDestroy(v)
    end
    ui.zones={}

    removeEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    removeEventHandler("onClientVehicleStartEnter", resourceRoot, ui.onClientVehicleStartEnter)
    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientColShapeHit", root, ui.onColShapeHit)
    removeEventHandler("onClientPlayerWasted", localPlayer, wasted)

    if(not ui.upgradeVeh)then
        toggleControl("crouch", true)
        toggleControl("jump", true)
        toggleControl("sprint", true)
        toggleControl("walk", true)
    end
end
addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, stopJob)

addEvent("door.state", true)
addEventHandler("door.state", resourceRoot, function(state,vehicle)
    ui.vehicle=vehicle

    if(ui.action == "getClients")then
        if(state == "open")then
            ui.markers["vehicle"]=createMarker(0,0,0,"cylinder",1.2,255,0,0)
            attachElements(ui.markers["vehicle"], ui.vehicle, 0, -4, 1)
            setElementData(ui.markers["vehicle"], "icon", ":px_jobs-courier/textures/marker_parcel.png")

            ui.blips["vehicle"]=createBlipAttachedTo(ui.markers["vehicle"], 22)
        elseif(state == "close")then
            checkAndDestroy(ui.markers["vehicle"])
            ui.markers["vehicle"]=nil

            checkAndDestroy(ui.blips["vehicle"])
            ui.blips["vehicle"]=nil
        end
    end
end)

--

ui.onClientVehicleStartEnter=function(player, seat)
    if(player == localPlayer and table.size(ui.boxes) > 0)then
        cancelEvent()
    end
end

-- useful

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end