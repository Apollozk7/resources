--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

parking.pcAnims = {}
parking.pcButtons = {}

parking.renderParkingChoose = function()
    parking.blur:dxDrawBlur(sx/2-344/zoom-1, sy/2-308/zoom, 689/zoom+2, 616/zoom, tocolor(255, 255, 255, parking.pcalpha))
    dxDrawImage(sx/2-344/zoom-1, sy/2-308/zoom, 689/zoom+2, 616/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, parking.pcalpha))

    local w,h=42/1.5,32/1.5
    dxDrawText("PRZECHOWALNIA", sx/2-344/zoom+w/2, sy/2-308/zoom, sx/2-344/zoom+689/zoom+w/2, sy/2-308/zoom+60/zoom, tocolor(200, 200, 200, parking.pcalpha), 1, assets.fonts[4], "center", "center")
    dxDrawImage(sx/2-120/zoom+w/2, sy/2-308/zoom+(60-h)/2/zoom, floor(w/zoom), floor(h/zoom), assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, parking.pcalpha))

    dxDrawImage(sx/2+316/zoom, sy/2-308/zoom+(60-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, parking.pcalpha))

    dxDrawRectangle(sx/2-344/zoom, sy/2-253/zoom, 689/zoom, 1, tocolor(100, 100, 100, parking.pcalpha))

    dxDrawRectangle(sx/2-344/zoom, sy/2+270/zoom, 689/zoom, 1, tocolor(100, 100, 100, parking.pcalpha))

    dxDrawImage(sx/2-154/zoom, sy/2+282/zoom, 20/zoom, 14/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, parking.pcalpha))
    dxDrawText("Właściciel", sx/2-130/zoom, sy/2+282/zoom, sx/2-130/zoom, sy/2+296/zoom, tocolor(130, 130, 130, parking.pcalpha), 1, assets.fonts[2], "left", "center")

    dxDrawImage(sx/2-14/zoom, sy/2+282/zoom, 12/zoom, 14/zoom, assets.textures[10], 0, 0, 0, tocolor(255, 255, 255, parking.pcalpha))
    dxDrawText("Udostępniony dla ciebie", sx/2+3/zoom, sy/2+282/zoom, sx/2+3/zoom, sy/2+296/zoom, tocolor(130, 130, 130, parking.pcalpha), 1, assets.fonts[2], "left", "center")

    if parking.allGarages then
        for i = 1, 9 do
            local scroll = math.floor(parking.scroll:dxScrollGetPosition(parking.pcScroll) or 0)
            local d = parking.allGarages[i+scroll]
            if d then
                local headerText = (d.isOwner and "Prywatna przechowalnia" or "Przechowalnia")
                local y = sy/2-(252-(i-1)*57)/zoom
                dxDrawImage(sx/2-344/zoom, y, 689/zoom, 56/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, parking.pcalpha))

                local w,h=42/1.7,32/1.7
                dxDrawImage(sx/2-328/zoom, y+(56-h)/2/zoom, w/zoom, h/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, parking.pcalpha))

                dxDrawText(headerText, sx/2-288/zoom, y+28/zoom, sx/2-288/zoom, y+28/zoom, tocolor(220, 220, 220, parking.pcalpha), 1, assets.fonts[1], "left", "bottom")
                dxDrawText(d.ownerName, sx/2-288/zoom, y+28/zoom, sx/2-288/zoom, y+28/zoom, tocolor(150, 150, 150, parking.pcalpha), 1, assets.fonts[1], "left", "top")

                local texture = (d.isOwner and assets.textures[6] or assets.textures[10])
                local w, h = (d.isOwner and 20/zoom or 12/zoom), (d.isOwner and 14/zoom or 14/zoom)
                dxDrawImage(sx/2+108/zoom, y+(28-h/2)/zoom, w, h, texture, 0, 0, 0, tocolor(255, 255, 255, parking.pcalpha))

                if not parking.pcButtons[i] then parking.pcButtons[i] = parking.buttons:createButton(sx/2+168/zoom, y+15/zoom, 105/zoom, 27/zoom, "SCHOWAJ", parking.pcalpha, 10/zoom, false, false, false, {73, 124, 149}) end
                if click(sx/2+168/zoom, y+15/zoom, 105/zoom, 27/zoom) then
                    parking.toggleParkingChoose(false)
                    parking.ownerID = d.playerID
                end
            else
                if parking.pcButtons[i] then
                    parking.buttons:destroyButton(parking.pcButtons[i])
                    parking.pcButtons[i] = nil
                end
            end
        end
    else
        dxDrawText("Trwa ładowanie...", sx/2, sy/2, sx/2, sy/2, tocolor(220, 220, 220, parking.pcalpha), 1, assets.fonts[1], "center", "center")
    end

    if click(sx/2+290/zoom, sy/2-307/zoom, 54/zoom, 54/zoom) then parking.toggleParkingChoose(false) end

    if getKeyState("mouse1") and not parking.clickblock then
        parking.clickblock = true
    elseif not getKeyState("mouse1") and parking.clickblock then
        parking.clickblock = false
    end
end

parking.toggleParkingChoose = function(state)
    parking.parkingChooseState = state

    for i, v in ipairs(parking.pcAnims) do destroyAnimation(v) end
    if state then
        for i, v in ipairs(parking.pcButtons) do parking.buttons:destroyButton(v) end

        parking.buttons = exports["px_buttons"]
        parking.editboxes = exports["px_editbox"]
        parking.scroll = exports["px_scroll"]
        parking.blur = exports.blur

        parking.pcButtons = {}

        parking.ownerID=false

        removeEventHandler("onClientRender", getRootElement(), parking.renderParkingChoose)
        addEventHandler("onClientRender", getRootElement(), parking.renderParkingChoose)

        assets.create()

        parking.pcAnims[#parking.pcAnims+1] = animate(0, 255, "InOutQuad", 300, function(x)
            parking.pcalpha = x
            for i, v in pairs(parking.pcButtons) do parking.buttons:buttonSetAlpha(v, x) end
        end)

        local vehicle = getPedOccupiedVehicle(localPlayer)
        if(vehicle)then
            setElementFrozen(vehicle, true)
        end
    else
        parking.pcAnims[#parking.pcAnims+1] = animate(255, 0, "InOutQuad", 300, function(x)
            parking.pcalpha = x

            for i, v in pairs(parking.pcButtons) do parking.buttons:buttonSetAlpha(v, x) end
            parking.scroll:dxScrollSetAlpha(parking.pcScroll, x)
        end, function()
            removeEventHandler("onClientRender", getRootElement(), parking.renderParkingChoose)

            assets.clear()

            for i, v in ipairs(parking.pcButtons) do parking.buttons:destroyButton(v) end
            parking.scroll:dxDestroyScroll(parking.pcScroll)

            local vehicle = getPedOccupiedVehicle(localPlayer)
            if(vehicle)then
                setElementFrozen(vehicle, false)
            end

            -- send vehicle
            if parking.vehicleToParking and parking.ownerID then 
                parking.getVehicleInParking(parking.ownerID, parking.vehicleToParking)
            end
        end)
    end
    showCursor(state)
end

parking.onParkingColHit = function(hit, md)
    if not hit or not md or hit ~= localPlayer or not getPedOccupiedVehicle(hit) or getVehicleController(getPedOccupiedVehicle(hit)) ~= hit or not isEnterCol(source) then return false end

    local vehicle = getPedOccupiedVehicle(hit)
    if not isVehiclePrivate(vehicle) then
        sendNotification("Jedynie prywatne auta są możliwe do oddania na parking.")
        return false
    end

    if parking.last.takeoutVehicle and getTickCount()-parking.last.takeoutVehicle < 5000 then
        local time = string.format("%.1f", ((parking.last.takeoutVehicle+5000)-getTickCount())/1000)
        sendNotification("Poczekaj "..time.." s, aby ponownie skorzystać z parkingu.")
        return false
    end

    parking.last.takeoutVehicle = getTickCount()
    parking.vehicleToParking = getPedOccupiedVehicle(hit)
    parking.parkingID = isEnterCol(source)
    parking.toggleParkingChoose(true)
    triggerServerEvent("px_parking:getPlayerGarages", resourceRoot, parking.parkingID)
end
addEventHandler("onClientMarkerHit", resourceRoot, parking.onParkingColHit)

parking.getVehicleInParking = function(ownerID, vehicle)
    if not ownerID or not vehicle then return false end
    
    if parking.last.sendVehicleToParking and getTickCount()-parking.last.sendVehicleToParking < 5000 then
        local time = string.format("%.1f", ((parking.last.takeoutVehicle+5000)-getTickCount())/1000)
        sendNotification("Poczekaj "..time.." s, aby ponownie wysłać pojazd do parkingu.")
        return false
    end

    parking.last.sendVehicleToParking = getTickCount()

    setElementFrozen(vehicle, true)
    setPedControlState("enter_exit", true)
    setTimer(toggleControl, 3000, 1, "enter_exit", true)
    setTimer(function()
        triggerServerEvent("px_parking:trySendVehicleToParking", resourceRoot, vehicle, ownerID)
    end, 3000, 1)
end

function isEnterCol(col)
    if not col or not isElement(col) then return false end
    local id = getElementID(col)
    if not id then return false end
    if string.find(id, "parking_colenter:") then
        local x = string.gsub(id, "parking_colenter:", "")
        return tonumber(x)
    else
        return false
    end
end