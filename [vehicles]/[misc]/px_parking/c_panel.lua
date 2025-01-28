--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

parking.panelAnims = {}

-- markers

parking.onParkingEnterHit = function(hit, md)
    if not hit or not md or hit ~= localPlayer or getPedOccupiedVehicle(hit) or not isEnterMarker(source) then return false end

    if parking.last.parkingPanel and getTickCount()-parking.last.parkingPanel < 5000 then
        local time = string.format("%.1f", ((parking.last.parkingPanel+5000)-getTickCount())/1000)
        sendNotification("Poczekaj "..time.." s, aby ponownie skorzystać z panelu parkingu.")
        return false
    end

    parking.last.parkingPanel = getTickCount()
    parking.parkingID = isEnterMarker(source)
    parking.toggle(true)

    triggerServerEvent("px_parking:getPlayerGarages", resourceRoot, parking.parkingID)
end
addEventHandler("onClientMarkerHit", getResourceRootElement(), parking.onParkingEnterHit)

parking.onParkingEnterLeave = function(hit, md)
    if not hit or not md or hit ~= localPlayer or not isEnterMarker(source) then return false end

    parking.parkingID = nil
    parking.toggle(false)
end
addEventHandler("onClientMarkerLeave", getResourceRootElement(), parking.onParkingEnterLeave)

-- rendering

floor=math.floor
parking.panelRender = function()
    parking.blur:dxDrawBlur(sx/2-344/zoom-1, sy/2-308/zoom, 689/zoom+2, 616/zoom, tocolor(255, 255, 255, parking.alpha))
    dxDrawImage(sx/2-344/zoom-1, sy/2-308/zoom, 689/zoom+2, 616/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, parking.alpha))

    local w,h=42/1.5,32/1.5
    dxDrawText("PRZECHOWALNIA", sx/2-344/zoom+w/2, sy/2-308/zoom, sx/2-344/zoom+689/zoom+w/2, sy/2-308/zoom+60/zoom, tocolor(200, 200, 200, parking.alpha), 1, assets.fonts[4], "center", "center")
    dxDrawImage(sx/2-120/zoom+w/2, sy/2-308/zoom+(60-h)/2/zoom, floor(w/zoom), floor(h/zoom), assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, parking.alpha))

    dxDrawImage(sx/2+316/zoom, sy/2-308/zoom+(60-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, parking.alpha))

    dxDrawRectangle(sx/2-344/zoom, sy/2-253/zoom, 689/zoom, 1, tocolor(100, 100, 100, parking.alpha))

    dxDrawRectangle(sx/2-344/zoom, sy/2+270/zoom, 689/zoom, 1, tocolor(100, 100, 100, parking.alpha))

    dxDrawImage(sx/2-154/zoom, sy/2+282/zoom, 20/zoom, 14/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, parking.alpha))
    dxDrawText("Właściciel", sx/2-130/zoom, sy/2+282/zoom, sx/2-130/zoom, sy/2+296/zoom, tocolor(130, 130, 130, parking.alpha), 1, assets.fonts[2], "left", "center")

    dxDrawImage(sx/2-14/zoom, sy/2+282/zoom, 12/zoom, 14/zoom, assets.textures[10], 0, 0, 0, tocolor(255, 255, 255, parking.alpha))
    dxDrawText("Udostępniony dla ciebie", sx/2+3/zoom, sy/2+282/zoom, sx/2+3/zoom, sy/2+296/zoom, tocolor(130, 130, 130, parking.alpha), 1, assets.fonts[2], "left", "center")

    if not parking.panelRT or (parking.panelRT and not isElement(parking.panelRT)) then
        dxDrawText("Trwa ładowanie...", sx/2, sy/2, sx/2, sy/2, tocolor(220, 220, 220, parking.alpha), 1, assets.fonts[1], "center", "center")
    else
        dxDrawImage(floor(sx/2-344/zoom), floor(sy/2-252/zoom), floor(689/zoom), floor(522/zoom), parking.panelRT, 0, 0, 0, tocolor(255, 255, 255, parking.alpha))

        for i, v in ipairs(parking.relase or {}) do
            local x, y, relaseType, index, relaseSubType, xSize, ySize = unpack(v)
            if click(x, y, (xSize or 20/zoom), (ySize or 20/zoom)) then
                for i,v in pairs({"owned", "rent"}) do
                    if relaseType == v then
                        if relaseSubType then
                            if relaseSubType == "vehicles" then
                                parking[v.."Garages"][index].isReleasedVehicles = not parking[v.."Garages"][index].isReleasedVehicles
                            else
                                parking[v.."Garages"][index].isReleasedRents = not parking[v.."Garages"][index].isReleasedRents
                            end
                        else
                            parking[v.."Garages"][index].isReleased = not parking[v.."Garages"][index].isReleased
                        end
                    end
                end

                parking.refreshRT()
            end
        end

        for i, v in ipairs(parking.rentDelete or {}) do
            local x, y, playerID, ownerID = unpack(v)
            local w, h = 105/zoom, 27/zoom

            if click(x, y, w, h) then
                parking.tryRemoveRentPlayer(ownerID, playerID)
            end
        end

        if parking.rentAdd then
            local x, y, w, h, ownerID, editboxIndex = unpack(parking.rentAdd)

            if click(x, y, w, h) then                
                local value = (editboxIndex and parking.rentAddEditbox[editboxIndex] and parking.editboxes:dxGetEditText(parking.rentAddEditbox[editboxIndex][1]) or false)
                if value then
                    parking.tryAddRentPlayer(ownerID, value)
                end
            end
        end

        for i, v in ipairs(parking.enterGarage or {}) do
            local x, y, w, h, ownerID = unpack(v)

            if click(x, y, w, h) then
                parking.tryEnterGarage(ownerID)
            end
        end

        for i, v in ipairs(parking.vehicleRemove or {}) do
            local x, y, w, h, ownerID, vehicleID = unpack(v)

            if click(x, y, w, h) then
                if(ownerID == getElementData(localPlayer, 'user:uid'))then
                    triggerServerEvent("getVehicleFromParkingButton", resourceRoot, vehicleID, ownerID)
                else
                    parking.tryRemoveVehicleFromGarage(ownerID, vehicleID)
                end
            end
        end

        local scrollPos = parking.scroll:dxScrollGetRTPosition(parking.panelScroll) or 0
        if(parking.scrollPosition ~= scrollPos) then 
            parking.refreshRT() 
        end

        if click(sx/2+290/zoom, sy/2-307/zoom, 54/zoom, 54/zoom) then parking.toggle(false) end

        if getKeyState("mouse1") and not parking.clickblock then
            parking.clickblock = true
        elseif not getKeyState("mouse1") and parking.clickblock then
            parking.clickblock = false
        end
    end
end

parking.refreshRT = function()
    if not isElement(parking.panelRT) then parking.panelRT = dxCreateRenderTarget(689/zoom, 522/zoom, true) end

    parking.scrollPosition = parking.scroll:dxScrollGetRTPosition(parking.panelScroll) or 0

    local y = -parking.scrollPosition
    local max = 0
    
    parking.relase = {}
    parking.enterGarage = {}
    parking.rentDelete = {}
    parking.vehicleRemove = {}
    parking.rentAdd = nil

    if not parking.enterButtons then parking.enterButtons = {} end
    if not parking.removeVehicleButtons then parking.removeVehicleButtons = {} end
    if not parking.rentDeleteButton then parking.rentDeleteButton = {} end
    if not parking.rentAddEditbox then parking.rentAddEditbox = {} end
    if not parking.rentAddButton then parking.rentAddButton = {} end

    dxSetRenderTarget(parking.panelRT, true)
        dxSetBlendMode("modulate_add")
        for _, v in ipairs({parking.ownedGarages, parking.rentGarages}) do
            for i, v in ipairs(v) do
                local garageType = (v.isOwner and "owned" or "rent")
                local headerText = (v.isOwner and "Prywatna przechowalnia #"..v.id or "Przechowalnia #"..v.id)

                -- off
                if parking.rentAddEditbox and parking.rentAddEditbox[garageType..":"..v.playerID] then 
                    parking.editboxes:dxSetEditAlpha(parking.rentAddEditbox[garageType..":"..v.playerID][1], 0)
                    parking.rentAddEditbox[garageType..":"..v.playerID][2] = 0
                end
            
                if parking.rentAddButton and parking.rentAddButton[garageType..":"..v.playerID] then 
                    parking.buttons:buttonSetAlpha(parking.rentAddButton[garageType..":"..v.playerID][1], 0)
                    parking.rentAddButton[garageType..":"..v.playerID][2] = 0
                end
                --

                dxDrawImage(0, y, 689/zoom, 57/zoom, assets.textures[8])

                local w,h=42/1.7,32/1.7
                dxDrawImage(16/zoom, y+(57-h)/2/zoom, w/zoom, h/zoom, assets.textures[7])

                dxDrawText(headerText, 50/zoom, y+28/zoom, 50/zoom, y+28/zoom, tocolor(220, 220, 220), 1, assets.fonts[1], "left", "bottom")
                dxDrawText(v.ownerName, 50/zoom, y+28/zoom, 50/zoom, y+28/zoom, tocolor(150, 150, 150), 1, assets.fonts[1], "left", "top")

                local texture = (v.isOwner and assets.textures[6] or assets.textures[10])
                local w, h = (v.isOwner and 20/zoom or 12/zoom), (v.isOwner and 14/zoom or 14/zoom)
                dxDrawImage(455/zoom, y+(28-h/2)/zoom, w, h, texture)

                local texture = (v.isReleased and assets.textures[2] or assets.textures[3])
                dxDrawImage(654/zoom, y+19/zoom, 17/zoom, 17/zoom, texture)
                if sy/2-(252-y)/zoom < sy/2+252/zoom then parking.relase[#parking.relase+1] = {sx/2+310/zoom, sy/2-(232/zoom-y), (v.isOwner and "owned" or "rent"), i} end

                if not parking.enterButtons[garageType..":"..v.playerID] then
                    parking.enterButtons[garageType..":"..v.playerID] = {parking.buttons:createButton(sx/2+168/zoom, sy/2-(252/zoom-y-15/zoom), 105/zoom, 27/zoom, "WEJDŹ", parking.alpha, 10/zoom, false, false, false, {73, 124, 149}), parking.alpha}
                else
                    parking.buttons:buttonSetPosition(parking.enterButtons[garageType..":"..v.playerID][1], {sx/2+168/zoom, sy/2-(252/zoom-y-15/zoom)})
                    if sy/2-(252/zoom-y-15/zoom) > sy/2+239/zoom or sy/2-(252/zoom-y-15/zoom) < sy/2-252/zoom then
                        parking.buttons:buttonSetAlpha(parking.enterButtons[garageType..":"..v.playerID][1], 0)
                        parking.enterButtons[garageType..":"..v.playerID][2] = 0
                    else
                        parking.buttons:buttonSetAlpha(parking.enterButtons[garageType..":"..v.playerID][1], parking.alpha)
                        parking.enterButtons[garageType..":"..v.playerID][2] = parking.alpha
                    end
                end

                if sy/2-(252/zoom-y-15/zoom) > sy/2-252/zoom and sy/2-(252/zoom-y-15/zoom) < sy/2+243/zoom then parking.enterGarage[#parking.enterGarage+1] = {sx/2+168/zoom, sy/2-(252/zoom-y-15/zoom), 105/zoom, 27/zoom, v.playerID} end

                y = y+57/zoom
                max = max+57/zoom

                if v.isReleased then
                    local texture = (v.isReleasedVehicles and assets.textures[2] or assets.textures[3])
                    dxDrawImage(0, y, 689/zoom, 29/zoom, assets.textures[9])
                    dxDrawText("Pojazdy", 16/zoom, y, 16/zoom, y+29/zoom, tocolor(220, 220, 220), 1, assets.fonts[3], "left", "center")
                    if(v.vehiclesIn and #v.vehiclesIn > 0)then
                        dxDrawImage(654/zoom, y+5/zoom, 17/zoom, 17/zoom, texture)
                    end

                    if sy/2-(252-y+15)/zoom < sy/2+252/zoom then parking.relase[#parking.relase+1] = {sx/2-344/zoom, sy/2-(232/zoom-y+20/zoom), (v.isOwner and "owned" or "rent"), i, "vehicles", 689/zoom, 29/zoom} end

                    y = y+29/zoom
                    max = max+29/zoom

                    if v.isReleasedVehicles then
                        for i, v2 in ipairs(v.vehiclesIn or {}) do
                            dxDrawImage(0, y, 689/zoom, 49/zoom, assets.textures[8])
                            dxDrawImage(16/zoom, y+21/zoom, 24/zoom, 11/zoom, assets.textures[4])

                            dxDrawText(v2.vehicleData.model, 60/zoom, y, 60/zoom, y+50/zoom, tocolor(220, 220, 220), 1, assets.fonts[3], "left", "center")
                            dxDrawText("ID #dcdcdc"..v2.vehicleID, 225/zoom, y, 225/zoom, y+50/zoom, tocolor(160, 160, 160), 1, assets.fonts[3], "left", "center", false, false, false, true)

                            dxDrawImage(365/zoom, y+17/zoom, 20/zoom, 14/zoom, assets.textures[6])
                            dxDrawText(v2.vehicleData.ownerName, 390/zoom, y, 390/zoom, y+50/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "center")

                            if v.isOwner and not v2.vehicleData.isOwner then
                                if not parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i] then
                                    parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i] = {parking.buttons:createButton(sx/2+222/zoom, sy/2-(242/zoom-y), 105/zoom, 27/zoom, "USUŃ", parking.alpha, 10/zoom, false, false, false, {126, 44, 44}), parking.alpha}
                                end

                                parking.buttons:buttonSetPosition(parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][1], {sx/2+222/zoom, sy/2-(242/zoom-y)})
                                if sy/2-(242/zoom-y) > sy/2+239/zoom or sy/2-(242/zoom-y) < sy/2-252/zoom then
                                    parking.buttons:buttonSetAlpha(parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][1], 0)
                                    parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][2] = 0
                                else
                                    parking.buttons:buttonSetAlpha(parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][1], parking.alpha)
                                    parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][2] = parking.alpha
                                end
                                
                                if sy/2-(252-y-10)/zoom > sy/2-252/zoom and sy/2-(252-y-10)/zoom < sy/2+243/zoom then parking.vehicleRemove[#parking.vehicleRemove+1] = {sx/2+222/zoom, sy/2-(252-y-10)/zoom, 105/zoom, 27/zoom, v.playerID, v2.vehicleID} end
                            else
                                if not parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i] then
                                    parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i] = {parking.buttons:createButton(sx/2+222/zoom, sy/2-(242/zoom-y), 105/zoom, 27/zoom, "WYCIĄGNIJ", parking.alpha, 10/zoom, false, false, false, {0,200,100}), parking.alpha}
                                end

                                parking.buttons:buttonSetPosition(parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][1], {sx/2+222/zoom, sy/2-(242/zoom-y)})
                                if sy/2-(242/zoom-y) > sy/2+239/zoom or sy/2-(242/zoom-y) < sy/2-252/zoom then
                                    parking.buttons:buttonSetAlpha(parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][1], 0)
                                    parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][2] = 0
                                else
                                    parking.buttons:buttonSetAlpha(parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][1], parking.alpha)
                                    parking.removeVehicleButtons[garageType..":"..v.playerID..":"..i][2] = parking.alpha
                                end

                                if sy/2-(252-y-10)/zoom > sy/2-252/zoom and sy/2-(252-y-10)/zoom < sy/2+243/zoom then parking.vehicleRemove[#parking.vehicleRemove+1] = {sx/2+222/zoom, sy/2-(252-y-10)/zoom, 105/zoom, 27/zoom, v.playerID, v2.vehicleID} end
                            end

                            y = y+50/zoom
                            max = max+50/zoom
                        end
                    else
                        if parking.removeVehicleButtons then
                            for i3, v3 in pairs(parking.removeVehicleButtons) do
                                if string.find(i3, garageType..":"..v.playerID) then
                                    parking.buttons:buttonSetAlpha(v3[1], 0)
                                    parking.removeVehicleButtons[i3][2] = 0
                                end
                            end
                        end
                    end

                    local texture = (v.isReleasedRents and assets.textures[2] or assets.textures[3])
                    dxDrawImage(0, y, 689/zoom, 29/zoom, assets.textures[9])
                    dxDrawText("Udostępnienia", 16/zoom, y, 16/zoom, y+29/zoom, tocolor(220, 220, 220), 1, assets.fonts[3], "left", "center")
                    dxDrawImage(654/zoom, y+5/zoom, 17/zoom, 17/zoom, texture)

                    if sy/2-(252-y+15)/zoom < sy/2+252/zoom then parking.relase[#parking.relase+1] = {sx/2-344/zoom, sy/2-(232/zoom-y+20/zoom), (v.isOwner and "owned" or "rent"), i, "rents", 689/zoom, 29/zoom} end

                    y = y+29/zoom
                    max = max+29/zoom

                    if v.isReleasedRents then
                        for i, v2 in ipairs(v.rents) do
                            dxDrawImage(0, y, 689/zoom, 49/zoom, assets.textures[8])

                            dxDrawImage(16/zoom, y+15/zoom, 21/zoom, 21/zoom, exports.px_avatars:getPlayerAvatar(v2.playerName))

                            dxDrawText(v2.playerName, 60/zoom, y, 60/zoom, y+50/zoom, tocolor(220, 220, 220), 1, assets.fonts[3], "left", "center")
                            dxDrawText("Ostatnio online: #dcdcdc"..v2.playerLastOnline, 235/zoom, y, 245/zoom, y+50/zoom, tocolor(160, 160, 160), 1, assets.fonts[1], "left", "center", false, false, false, true)

                            if v.isOwner then
                                if not parking.rentDeleteButton[garageType..":"..v.playerID..":"..i] then
                                    parking.rentDeleteButton[garageType..":"..v.playerID..":"..i] = {parking.buttons:createButton(sx/2+222/zoom, sy/2-(242/zoom-y), 105/zoom, 27/zoom, "USUŃ", parking.alpha, 10/zoom, false, false, false, {126, 44, 44}), parking.alpha}
                                else
                                    parking.buttons:buttonSetPosition(parking.rentDeleteButton[garageType..":"..v.playerID..":"..i][1], {sx/2+222/zoom, sy/2-(242/zoom-y)})
                                    if sy/2-(242/zoom-y) > sy/2+239/zoom or sy/2-(242/zoom-y) < sy/2-252/zoom then
                                        parking.buttons:buttonSetAlpha(parking.rentDeleteButton[garageType..":"..v.playerID..":"..i][1], 0)
                                        parking.rentDeleteButton[garageType..":"..v.playerID..":"..i][2]=0
                                    else
                                        parking.buttons:buttonSetAlpha(parking.rentDeleteButton[garageType..":"..v.playerID..":"..i][1], parking.alpha)
                                        parking.rentDeleteButton[garageType..":"..v.playerID..":"..i][2]=parking.alpha
                                    end
                                end
                                if sy/2-(242/zoom-y) > sy/2-252/zoom and sy/2-(242/zoom-y) < sy/2+243/zoom then parking.rentDelete[#parking.rentDelete+1] = {sx/2+222/zoom, sy/2-(242/zoom-y), v2.playerID, v.playerID} end
                            end

                            y = y+50/zoom
                            max = max+50/zoom
                        end

                        if #v.rents < 3 and v.isOwner then
                            dxDrawImage(0, y, 689/zoom, 49/zoom, assets.textures[8])

                            if not parking.rentAddEditbox[garageType..":"..v.playerID] then
                                parking.rentAddEditbox[garageType..":"..v.playerID] = {parking.editboxes:dxCreateEdit("ID/Nickname", sx/2-327/zoom, sy/2-(242/zoom-y), 325/zoom, 28/zoom, false, 10/zoom, parking.alpha, false, false, ":px_parking/textures/user.png", true),  parking.alpha}
                            else
                                parking.editboxes:dxSetEditPosition(parking.rentAddEditbox[garageType..":"..v.playerID][1], {sx/2-327/zoom, sy/2-(242/zoom-y)})
                                if sy/2-(242/zoom-y) > sy/2+239/zoom or sy/2-(242/zoom-y) < sy/2-252/zoom then
                                    parking.editboxes:dxSetEditAlpha(parking.rentAddEditbox[garageType..":"..v.playerID][1], 0)
                                    parking.rentAddEditbox[garageType..":"..v.playerID][2] = 0
                                else
                                    parking.editboxes:dxSetEditAlpha(parking.rentAddEditbox[garageType..":"..v.playerID][1], parking.alpha)
                                    parking.rentAddEditbox[garageType..":"..v.playerID][2] = parking.alpha
                                end
                            end

                            if not parking.rentAddButton[garageType..":"..v.playerID] then
                                parking.rentAddButton[garageType..":"..v.playerID] = {parking.buttons:createButton(sx/2+222/zoom, sy/2-(242/zoom-y), 105/zoom, 27/zoom, "DODAJ", parking.alpha, 10/zoom, false, false, false), parking.alpha}
                            else
                                parking.buttons:buttonSetPosition(parking.rentAddButton[garageType..":"..v.playerID][1], {sx/2+222/zoom, sy/2-(242/zoom-y)})
                                if sy/2-(242/zoom-y) > sy/2+239/zoom or sy/2-(242/zoom-y) < sy/2-252/zoom then
                                    parking.buttons:buttonSetAlpha(parking.rentAddButton[garageType..":"..v.playerID][1], 0)
                                    parking.rentAddButton[garageType..":"..v.playerID][2] = 0
                                else
                                    parking.buttons:buttonSetAlpha(parking.rentAddButton[garageType..":"..v.playerID][1], parking.alpha)
                                    parking.rentAddButton[garageType..":"..v.playerID][2] = parking.alpha
                                end
                            end

                            parking.rentAdd = {sx/2+222/zoom, sy/2-(242/zoom-y), 105/zoom, 27/zoom, v.playerID, garageType..":"..v.playerID}

                            y = y+49/zoom
                            max = max+49/zoom
                        end
                    else
                        if parking.rentAddEditbox and parking.rentAddEditbox[garageType..":"..v.playerID] then parking.editboxes:dxSetEditAlpha(parking.rentAddEditbox[garageType..":"..v.playerID][1], 0); parking.rentAddEditbox[garageType..":"..v.playerID][2] = 0; end
                        if parking.rentAddButton and parking.rentAddButton[garageType..":"..v.playerID] then parking.buttons:buttonSetAlpha(parking.rentAddButton[garageType..":"..v.playerID][1], 0); parking.rentAddButton[garageType..":"..v.playerID][2] = 0; end
                        
                        for i3, v3 in pairs(parking.rentDeleteButton) do
                            if string.find(i3, garageType..":"..v.playerID) then
                                parking.buttons:buttonSetAlpha(v3[1], 0)
                                parking.rentDeleteButton[i3][2] = 0
                            end
                        end
                    end
                else
                    if v.isReleasedRents then
                        if parking.rentAddEditbox and parking.rentAddEditbox[garageType..":"..v.playerID] then parking.editboxes:dxSetEditAlpha(parking.rentAddEditbox[garageType..":"..v.playerID][1], 0); parking.rentAddEditbox[garageType..":"..v.playerID][2] = 0; end
                        if parking.rentAddButton and parking.rentAddButton[garageType..":"..v.playerID] then parking.buttons:buttonSetAlpha(parking.rentAddButton[garageType..":"..v.playerID][1], 0); parking.rentAddButton[garageType..":"..v.playerID][2] = 0; end
                        
                        for i3, v3 in pairs(parking.rentDeleteButton) do
                            if string.find(i3, garageType..":"..v.playerID) then
                                parking.buttons:buttonSetAlpha(v3[1], 0)
                                parking.rentDeleteButton[i3][2] = 0
                            end
                        end

                        v.isReleasedRents = false
                    end

                    if parking.removeVehicleButtons then
                        for i3, v3 in pairs(parking.removeVehicleButtons) do
                            if string.find(i3, garageType..":"..v.playerID) then
                                parking.buttons:buttonSetAlpha(v3[1], 0)
                                parking.removeVehicleButtons[i3][2] = 0
                            end
                        end
                    end

                    v.isReleasedVehicles = false
                end
            end
        end
        dxSetBlendMode("blend")
    dxSetRenderTarget()

    parking.scroll:dxScrollUpdateRTSize(parking.panelScroll, max)
end

addEvent("px_parking:respondGetPlayerGarages", true)
addEventHandler("px_parking:respondGetPlayerGarages", getResourceRootElement(), function(ownedGarages, rentGarages)
    parking.ownedGarages = ownedGarages
    parking.rentGarages = rentGarages
    parking.allGarages = {}

    for i, v in ipairs(ownedGarages or {}) do parking.allGarages[#parking.allGarages+1] = v end; for i, v in ipairs(rentGarages or {}) do parking.allGarages[#parking.allGarages+1] = v end

    if parking.panelState then parking.refreshRT() end

    if parking.parkingChooseState then
        parking.pcScroll = parking.scroll:dxCreateScroll(sx/2+341/zoom, sy/2-252/zoom, 4, 4, 0, 10, parking.allGarages, 522/zoom, 255)
    end

    if(parking.rentDeleteButton)then
        for i, v in pairs(parking.rentDeleteButton) do
            parking.buttons:buttonSetAlpha(v[1], 0)
            parking.rentDeleteButton[i][2] = 0
        end
    end
end)

parking.toggle = function(state)
    if parking.panelRT and isElement(parking.panelRT) then destroyElement(parking.panelRT) end

    parking.panelState = state

    for i, v in ipairs(parking.panelAnims) do destroyAnimation(v) end

    parking.panelAnims = {}
    if state then
        parking.buttons = exports["px_buttons"]
        parking.editboxes = exports["px_editbox"]
        parking.scroll = exports["px_scroll"]
        parking.blur = exports.blur
        
        for i, v in pairs(parking.enterButtons or {}) do parking.buttons:destroyButton(v) end
        for i, v in pairs(parking.removeVehicleButtons or {}) do parking.buttons:destroyButton(v) end
        for i, v in pairs(parking.rentDeleteButton or {}) do parking.buttons:destroyButton(v) end
        for i, v in pairs(parking.rentAddEditbox or {}) do parking.editboxes:dxDestroyEdit(v) end
        for i, v in pairs(parking.rentAddButton or {}) do parking.buttons:destroyButton(v) end

        parking.enterButtons = nil; parking.removeVehicleButtons = nil; parking.rentDeleteButton = nil; parking.rentAddEditbox = nil; parking.rentAddButton = nil;

        removeEventHandler("onClientRender", getRootElement(), parking.panelRender)
        addEventHandler("onClientRender", getRootElement(), parking.panelRender)
        removeEventHandler("onClientRestore", getRootElement(), parking.refreshRT)
        addEventHandler("onClientRestore", getRootElement(), parking.refreshRT)

        assets.create()

        parking.panelAnims[#parking.panelAnims+1] = animate(0, 255, "InOutQuad", 300, function(x)
            parking.alpha = x
            for i, v in pairs(parking.enterButtons or {}) do if v[2] ~= 0 then parking.buttons:buttonSetAlpha(v[1], x) end end
            for i, v in pairs(parking.removeVehicleButtons or {}) do if v[2] ~= 0 then parking.buttons:buttonSetAlpha(v[1], x) end end
            for i, v in pairs(parking.rentDeleteButton or {}) do if v[2] ~= 0 then parking.buttons:buttonSetAlpha(v[1], x) end end
            for i, v in pairs(parking.rentAddEditbox or {}) do if v[2] ~= 0 then parking.editboxes:dxSetEditAlpha(v[1], x) end end
            for i, v in pairs(parking.rentAddButton or {}) do if v[2] ~= 0 then parking.buttons:buttonSetAlpha(v[1], x) end end
        end)

        parking.panelScroll = parking.scroll:dxCreateScroll(sx/2+341/zoom, sy/2-252/zoom, 4, 522/zoom, 0, 1, false, 522/zoom, 255, 0, false, true, 0, 522/zoom, 150)
        parking.refreshRT()
    else
        parking.panelAnims[#parking.panelAnims+1] = animate(255, 0, "InOutQuad", 300, function(x)
            parking.alpha = x

            for i, v in pairs(parking.enterButtons or {}) do if v[2] ~= 0 then parking.buttons:buttonSetAlpha(v[1], x) end end
            for i, v in pairs(parking.removeVehicleButtons or {}) do if v[2] ~= 0 then parking.buttons:buttonSetAlpha(v[1], x) end end
            for i, v in pairs(parking.rentDeleteButton or {}) do if v[2] ~= 0 then parking.buttons:buttonSetAlpha(v[1], x) end end
            for i, v in pairs(parking.rentAddEditbox or {}) do if v[2] ~= 0 then parking.editboxes:dxSetEditAlpha(v[1], x) end end
            for i, v in pairs(parking.rentAddButton or {}) do if v[2] ~= 0 then parking.buttons:buttonSetAlpha(v[1], x) end end
        end, function()
            removeEventHandler("onClientRender", getRootElement(), parking.panelRender)

            assets.clear()

            for i, v in pairs(parking.enterButtons or {}) do parking.buttons:destroyButton(v[1]) end
            for i, v in pairs(parking.removeVehicleButtons or {}) do parking.buttons:destroyButton(v[1]) end
            for i, v in pairs(parking.rentDeleteButton or {}) do parking.buttons:destroyButton(v[1]) end
            for i, v in pairs(parking.rentAddEditbox or {}) do parking.editboxes:dxDestroyEdit(v[1]) end
            for i, v in pairs(parking.rentAddButton or {}) do parking.buttons:destroyButton(v[1]) end

            parking.enterButtons = nil; parking.removeVehicleButtons = nil; parking.rentDeleteButton = nil; parking.rentAddEditbox = nil; parking.rentAddButton = nil;

            parking.ownedGarages = nil
            parking.rentGarages = nil

            if(parking.panelScroll)then
                parking.scroll:dxDestroyScroll(parking.panelScroll)
                parking.panelScroll=false
            end
        end)

        removeEventHandler("onClientRestore", getRootElement(), parking.refreshRT)
    end

    showCursor(state, false)
end

function isEnterMarker(marker)
    if not marker or not isElement(marker) then return false end
    local id = getElementID(marker)
    if not id then return false end
    if string.find(id, "parking_enter:") then
        local x = string.gsub(id, "parking_enter:", "")
        return tonumber(x)
    else
        return false
    end
end