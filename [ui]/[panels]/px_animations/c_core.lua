--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer)then
        killTimer(SPAM.blockSpamTimer)
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

animations = {}
animations.controlsSave = {}
animations.controlsOff = {"fire", "aim_weapon", "forwards", "backwards", "left", "right", "jump", "sprint", "crouch", "action", "walk", "enter_exit"}
animations.animsTips = {}
animations.last = {}
animations.lastMovementDetection = 0

animations.tryUseAnimation = function(categoryName, animationIndex)
    if(getElementData(localPlayer, "user:job"))then return end
    if(getElementData(localPlayer, "user:handcuffs"))then return end
    if(getElementData(localPlayer,'Area.InZone'))then return end
    if(getElementData(localPlayer, "user:gui_showed") and getElementData(localPlayer, "user:gui_showed") ~= resourceRoot)then return end

    if(isPedInVehicle(localPlayer))then return end

    if(SPAM.getSpam())then return end

    if animations.last.useAnimation and getTickCount()-animations.last.useAnimation < 3000 then
        local time = string.format("%.1f", ((animations.last.useAnimation+3000)-getTickCount())/1000)
        sendNotification("Poczekaj "..time.." s, aby ponownie skorzystać z animacji.")
        return false
    end
    local animationInfo = animations.animationList[categoryName].animationList[animationIndex].animation
    if not animationInfo then
        sendNotification("Doszło do błędu #C01, zgłoś to developerom serwera, w konsoli wyświetliły się dane debugujące.")
        outputConsole(inspect({categoryName, animationIndex}))
        outputConsole(inspect(animations.animationList[categoryName].animationList[animationIndex]))
        outputConsole(inspect(#(animations.animationList[categoryName].animationList or {})))
        return false
    end
    if animations.tipsState then
        sendNotification("Aktualnie wykonujesz już jakąś animację.")
        return false
    end
    if(categoryName == "Premium" and not getElementData(localPlayer, "user:premium"))then
        sendNotification("Nie posiadasz konta PREMIUM.")
        return
    end
    animations.last.useAnimation = getTickCount()
    triggerServerEvent("px_animations:useAnimation", resourceRoot, animationInfo)
    for i, v in pairs(animations.controlsOff) do toggleControl(v, false) end
end

animations.tryStopUseAnimation = function(forced)
    if(not forced)then
        if(getElementData(localPlayer, "user:writing"))then return end
        
        if animations.last.stopAnimation and getTickCount()-animations.last.stopAnimation < 3000 then
            local time = string.format("%.1f", ((animations.last.stopAnimation+3000)-getTickCount())/1000)
            sendNotification("Poczekaj "..time.." s, aby ponownie spróbować zatrzymać animacje.")
            return false
        end
    end

    animations.last.stopAnimation = getTickCount()
    triggerServerEvent("px_animations:stopAnimation", resourceRoot, forced)
    return true
end

addEvent("px_animations:onClientAnimationUse", true)
addEventHandler("px_animations:onClientAnimationUse", getResourceRootElement(), function()
    animations.toggleAnimationTips(true)
    animations.originalPosition = {getElementPosition(localPlayer)}
end)

addEvent("px_animations:onClientAnimationStop", true)
addEventHandler("px_animations:onClientAnimationStop", getResourceRootElement(), function(forced)
    for i, v in pairs(animations.controlsOff) do toggleControl(v, true) end
    if(not forced)then
        setElementPosition(localPlayer, unpack(animations.originalPosition))
    end
    animations.originalPosition = nil
end)

animations.toggleAnimationTips = function(state)
    animations.tipsState = state
    for i, v in pairs(animations.animsTips) do destroyAnimation(v) end
    if state then
        removeEventHandler("onClientKey", getRootElement(), animations.onKeyTips)
        removeEventHandler("onClientRender", getRootElement(), animations.renderTips)
        addEventHandler("onClientRender", getRootElement(), animations.renderTips)
        addEventHandler("onClientKey", getRootElement(), animations.onKeyTips)
        animations.animsTips[#animations.animsTips+1] = animate(0, 255, "InOutQuad", 300, function(x) animations.alpha2 = x end)

        -- off panel
        setElementData(localPlayer, "user:gui_showed", false, false)
        scroll:dxDestroyScroll(animations.scroll)

        animations.showing=false
        animations.anims={}

        if animations.preview then animations.objectPreview:destroyObjectPreview(animations.preview) end
        if isElement(animations.preview_ped) then destroyElement(animations.preview_ped) end
        removeEventHandler("onClientRender", getRootElement(), animations.render)
        if isElement(animations.rt) then destroyElement(animations.rt) end
        if animations.button then animations.buttons:destroyButton(animations.button) end

        showCursor(false)
        removeEventHandler("onClientRestore", getRootElement(), animations.refreshRT)
        animations.saveFavourites()
    else
        animations.animsTips[#animations.animsTips+1] = animate(255, 0, "InOutQuad", 300, function(x) animations.alpha2 = x end, function() removeEventHandler("onClientRender", getRootElement(), animations.renderTips) end)
        removeEventHandler("onClientKey", getRootElement(), animations.onKeyTips)
    end
end

animations.renderTips = function()
    if(not animations.originalPosition)then return end

    --Detect player movement
    if(getTickCount() - animations.lastMovementDetection > 100)then
        animations.lastMovementDetection = getTickCount()
        
        local currentPosition = {getElementPosition(localPlayer)}
        local distDifference = getDistanceBetweenPoints3D(currentPosition[1], currentPosition[2], currentPosition[3], animations.originalPosition[1], animations.originalPosition[2], animations.originalPosition[3])
        
        if(distDifference > 1) then
            animations.tryStopUseAnimation(true)
            animations.toggleAnimationTips(false)
        end
    end

    local texture = (getKeyState("w") and assets.textures[17] or assets.textures[16])
    dxDrawImage(sx/2-131/zoom, sy-118/zoom, 39/zoom, 39/zoom, texture, 0, 0, 0, tocolor(255, 255, 255, animations.alpha2))

    local texture = (getKeyState("a") and assets.textures[19] or assets.textures[18])
    dxDrawImage(sx/2-172/zoom, sy-77/zoom, 39/zoom, 39/zoom, texture, 0, 0, 0, tocolor(255, 255, 255, animations.alpha2))

    local texture = (getKeyState("s") and assets.textures[21] or assets.textures[20])
    dxDrawImage(sx/2-131/zoom, sy-77/zoom, 39/zoom, 39/zoom, texture, 0, 0, 0, tocolor(255, 255, 255, animations.alpha2))

    local texture = (getKeyState("d") and assets.textures[23] or assets.textures[22])
    dxDrawImage(sx/2-89/zoom, sy-77/zoom, 39/zoom, 39/zoom, texture, 0, 0, 0, tocolor(255, 255, 255, animations.alpha2))

    dxDrawText("Poruszanie", sx/2-172/zoom+1, sy-38/zoom+1, sx/2-51/zoom+1, sy-38/zoom+1, tocolor(0, 0, 0, animations.alpha2), 1, assets.fonts[3], "center", "top")
    dxDrawText("Poruszanie", sx/2-172/zoom, sy-38/zoom, sx/2-51/zoom, sy-38/zoom, tocolor(200, 200, 200, animations.alpha2), 1, assets.fonts[3], "center", "top")

    local texture = (getKeyState("arrow_u") and assets.textures[25] or assets.textures[24])
    dxDrawImage(sx/2+17/zoom, sy-118/zoom, 39/zoom, 39/zoom, texture, -90, 0, 0, tocolor(255, 255, 255, animations.alpha2))

    local texture = (getKeyState("arrow_l") and assets.textures[25] or assets.textures[24])
    dxDrawImage(sx/2-24/zoom, sy-77/zoom, 39/zoom, 39/zoom, texture, 180, 0, 0, tocolor(255, 255, 255, animations.alpha2))

    local texture = (getKeyState("arrow_d") and assets.textures[25] or assets.textures[24])
    dxDrawImage(sx/2+17/zoom, sy-77/zoom, 39/zoom, 39/zoom, texture, 90, 0, 0, tocolor(255, 255, 255, animations.alpha2))

    local texture = (getKeyState("arrow_r") and assets.textures[25] or assets.textures[24])
    dxDrawImage(sx/2+59/zoom, sy-77/zoom, 39/zoom, 39/zoom, texture, 0, 0, 0, tocolor(255, 255, 255, animations.alpha2))

    dxDrawText("Rotacja", sx/2-24/zoom+1, sy-38/zoom+1, sx/2+97/zoom+1, sy-38/zoom+1, tocolor(0, 0, 0, animations.alpha2), 1, assets.fonts[3], "center", "top")
    dxDrawText("Rotacja", sx/2-24/zoom, sy-38/zoom, sx/2+97/zoom, sy-38/zoom, tocolor(200, 200, 200, animations.alpha2), 1, assets.fonts[3], "center", "top")

    local texture = (getKeyState("space") and assets.textures[27] or assets.textures[26])
    dxDrawImage(sx/2+124/zoom, sy-77/zoom, 80/zoom, 38/zoom, texture, 0, 0, 0, tocolor(255, 255, 255, animations.alpha2))

    dxDrawText("Anuluj", sx/2+124/zoom+1, sy-38/zoom+1, sx/2+204/zoom+1, sy-38/zoom+1, tocolor(0, 0, 0, animations.alpha2), 1, assets.fonts[3], "center", "top")
    dxDrawText("Anuluj", sx/2+124/zoom, sy-38/zoom, sx/2+204/zoom, sy-38/zoom, tocolor(200, 200, 200, animations.alpha2), 1, assets.fonts[3], "center", "top")

    if click2() then if animations.tryStopUseAnimation() then animations.toggleAnimationTips(false) end end

    if getKeyState("space") and not animations.clickblock2 then
        animations.clickblock2 = true
    elseif not getKeyState("space") and animations.clickblock2 then
        animations.clickblock2 = false
    end
end

animations.allowedKeys = {}
    animations.allowedKeys["w"] = true
    animations.allowedKeys["a"] = true
    animations.allowedKeys["s"] = true
    animations.allowedKeys["d"] = true
    animations.allowedKeys["arrow_u"] = true
    animations.allowedKeys["arrow_l"] = true
    animations.allowedKeys["arrow_d"] = true
    animations.allowedKeys["arrow_r"] = true

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z
end

function detectCollision(newPosition)
    local currentPosition = {getElementPosition(localPlayer)}
    return (not isLineOfSightClear(currentPosition[1], currentPosition[2], currentPosition[3], newPosition[1], newPosition[2], newPosition[3]))
end

animations.onKeyTips = function(key, press)
    if not press then return false end
    if not animations.allowedKeys[key] then return false end
    if(isChatBoxInputActive()) then return false end
    if(getElementData(localPlayer, "user:writing"))then return end

    if key == "w" or key == "a" or key == "s" or key == "d" then
        local x, y, z = getElementPosition(localPlayer)
        local x2, y2, z2 = (key == "w" and x-0.1 or key == "s" and x+0.1 or x), (key == "a" and y-0.1 or key == "d" and y+0.1 or y), z
        local distance = getDistanceBetweenPoints3D(animations.originalPosition[1], animations.originalPosition[2], animations.originalPosition[3], x, y, z)
        local newDistance = getDistanceBetweenPoints3D(animations.originalPosition[1], animations.originalPosition[2], animations.originalPosition[3], x2, y2, z2)
        
        if distance > 0.7 then
            if newDistance > distance then return false end
        end
        
        if key == "w" then
            local newPosition = {getPositionFromElementOffset(localPlayer, 0, 0.1, 0)}
            if(not detectCollision(newPosition))then
                setElementPosition(localPlayer, newPosition[1], newPosition[2], newPosition[3], false)
            end
        elseif key == "s" then
            local newPosition = {getPositionFromElementOffset(localPlayer, 0, -0.1, 0)}
            if(not detectCollision(newPosition))then
                setElementPosition(localPlayer, newPosition[1], newPosition[2], newPosition[3], false)
            end
        elseif key == "a" then
            local newPosition = {getPositionFromElementOffset(localPlayer, -0.1, 0, 0)}
            if(not detectCollision(newPosition))then
                setElementPosition(localPlayer, newPosition[1], newPosition[2], newPosition[3], false)
            end
        elseif key == "d" then
            local newPosition = {getPositionFromElementOffset(localPlayer, 0.1, 0, 0)}
            if(not detectCollision(newPosition))then
                setElementPosition(localPlayer, newPosition[1], newPosition[2], newPosition[3], false)
            end
        end
    else
        local rx, ry, rz = getElementRotation(localPlayer)
        local rx2, ry2, rz2 = (key == "arrow_u" and rx+10 or rx), ry, (key == "arrow_l" and rz+5 or key == "arrow_r" and rz-5 or rz)
        setElementRotation(localPlayer, rx2, ry2, rz2, "default", true)
    end
end