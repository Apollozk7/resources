--[[
    @author: psychol, Xyrusek
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local alogo=exports.px_alogos

function toggleFunctions(state)
    if(state)then
        local v=getPedOccupiedVehicle(localPlayer)
        if(v)then
            setElementFrozen(v,false)
            toggleControl('enter_exit',true)
        else
            setElementFrozen(localPlayer,false)
        end
    else
        local v=getPedOccupiedVehicle(localPlayer)
        if(v)then
            setElementFrozen(v,true)
            toggleControl('enter_exit',false)
        else
            setElementFrozen(localPlayer,true)
        end
    end
end

local ui={}

ui.circle=2
ui.circles={}
ui.alpha=255

ui.descs={
    "Żebraki lubią mieć lepkie rączki.",
    "Aby zostać mechanikiem lub tunerem, wystarczy zatrudnić się w Urzędzie Las Venturas.",
    "Początkowo Pixel MTA nazywał się Project X.",
    "Podczas szybkiej jazdy twoja minimapa oddala się.",
    "Możesz siłować się na rękę ze znajomymi.",
}

ui.desc=1
ui.descAlpha=255
ui.descTick=getTickCount()
ui.postGUI=false
ui.sound=false
ui.tick = getTickCount()
ui.alpha_img = 255
ui.alpha_img2 = 0
ui.bg=1
ui.bg_new=5

ui.startCircles=function()
    local c=ui.circles[ui.circle-1]
    if(c)then
        c.animate=animate(c.alpha, 0, "Linear", 500, function(a)
            c.alpha=a
        end)
    else
        local c=ui.circles[#ui.circles]
        c.animate=animate(c.alpha, 0, "Linear", 500, function(a)
            c.alpha=a
        end)
    end

    local c=ui.circles[ui.circle]
    c.animate=animate(c.alpha, 255, "Linear", 500, function(a)
        c.alpha=a
    end, function()
        ui.circle=ui.circle+1 == 6 and 1 or ui.circle+1
        ui.startCircles()
    end)
end

ui.startDescs=function()
    animate(ui.descAlpha, 0, "Linear", 500, function(a)
        ui.descAlpha=a
    end, function()
        local next=ui.descs[ui.desc+1] and ui.desc+1 or 1
        ui.desc=next
        animate(ui.descAlpha, 255, "Linear", 500, function(a)
            ui.descAlpha=a
        end)
    end)
end

ui.onRender=function()
    if(ui.downloading and not isTransferBoxActive())then
        removeEventHandler('onClientRender', root, ui.onRender)
        destroyLoadingScreen(255, true)
        triggerEvent('px_loading:onDestroy', root)
        return
    end

    dxDrawImage(0, 0, sx, sy, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.alpha), ui.postGUI)

    dxDrawImage(sx/2-593/zoom, sy/2-289/zoom, 1187/zoom, 702/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.alpha), ui.postGUI)

    dxDrawImage(sx/2-593/zoom, sy/2-289/zoom, 1187/zoom, 702/zoom, "textures/screens/ss"..ui.bg..".png", 0, 0, 0, tocolor(255, 255, 255, ui.alpha < ui.alpha_img and ui.alpha or ui.alpha_img), ui.postGUI)
    if(ui.bg_new > 0)then
        dxDrawImage(sx/2-593/zoom, sy/2-289/zoom, 1187/zoom, 702/zoom, "textures/screens/ss"..ui.bg_new..".png", 0, 0, 0, tocolor(255, 255, 255, ui.alpha < ui.alpha_img2 and ui.alpha or ui.alpha_img2), ui.postGUI)
    end

    alogo:dxDrawLogo(sw/2-267/2/zoom,sh/2-480/zoom,267/zoom,128/zoom, ui.alpha, ui.postGUI)

    local max=(4*45/zoom)+11/zoom
    for i=1,5 do
        local sX=(45/zoom)*(i-1)
        local color=x == i and tocolor(190, 190, 190, ui.alpha) or tocolor(200, 200, 200, ui.alpha > 100 and 100 or ui.alpha)
        dxDrawImage(sw/2+sX-max/2, sh-55/zoom, 11/zoom, 11/zoom, assets.textures[2], 0, 0, 0, tocolor(200, 200, 200, ui.alpha > 50 and 50 or ui.alpha), ui.postGUI)
        dxDrawImage(sw/2+sX-max/2, sh-55/zoom, 11/zoom, 11/zoom, assets.textures[2], 0, 0, 0, tocolor(190, 190, 190, ui.alpha < ui.circles[i].alpha and ui.alpha or ui.circles[i].alpha), ui.postGUI)
    end

    dxDrawText("Czy wiesz, że?", sx/2-552/zoom, sy/2+333/zoom, sx/2-552/zoom, sy/2+333/zoom, tocolor(220, 220, 220, ui.alpha), 1, assets.fonts[1], "left", "bottom", false, false, ui.postGUI)
    dxDrawRectangle(sx/2-552/zoom, sy/2+342/zoom, 517/zoom, 1, tocolor(84, 84, 84, ui.alpha), ui.postGUI)
    dxDrawText(ui.descs[ui.desc], sx/2-552/zoom, sy/2+350/zoom, sx/2+535/zoom, sy/2+350/zoom, tocolor(100, 100, 100, ui.descAlpha), 1, assets.fonts[2], "left", "top", false, true, ui.postGUI)

    if((getTickCount()-ui.descTick) > 5000)then
        ui.descTick=getTickCount()
        ui.startDescs()
    end
    
    if((getTickCount()-ui.tick) > 5000)then
        if(ui.alpha_img2 > 0)then
            ui.bg = 1
            ui.tick = getTickCount()

            animate(ui.alpha_img2, 0, "Linear", 500, function(a)
                ui.alpha_img2 = a
                ui.alpha_img=255-a
            end, function()
                ui.bg_new = ui.bg+1
            end)
        else
            ui.tick = getTickCount()

            animate(ui.alpha_img2, 255, "Linear", 500, function(a)
                ui.alpha_img2 = a
                ui.alpha_img=255-a
            end, function()
                ui.bg = ui.bg_new
            end)
        end
    end
end

function createLoadingScreen(postGUI, alpha, tick, download)
    showChat(false)
    alogo=exports.px_alogos
    
    ui.postGUI=postGUI

    for i,v in pairs(ui.circles) do
        destroyAnimation(v.animate)
    end

    ui.circle=1
    ui.circles={}
    for i=1,5 do
        if(i == 1)then
            table.insert(ui.circles, {id=i, alpha=255})
        else
            table.insert(ui.circles, {id=i, alpha=0})
        end
    end
    ui.startCircles()

    assets.create()
    addEventHandler("onClientRender", root, ui.onRender)

    toggleFunctions()

    if(download)then
        setTransferBoxVisible(false)
        exports.px_progressbar:createProgressbar(sx/2-593/zoom, sy/2-289/zoom, 1187/zoom, 4/zoom, "Przygotowujemy potrzebne składniki... 0%", 13/zoom, 0, true, 0)
        ui.downloading=true
    else
        ui.downloading=false
    end

    if(not ui.sound or (ui.sound and not isElement(ui.sound)))then
        ui.sound = playSound("sounds/sound.mp3", true)
    end

    ui.descAlpha=0
    ui.descTick=getTickCount()

    ui.tick=getTickCount()
    ui.bg=math.random(1,5)
    ui.bg_new=ui.bg == 5 and 1 or ui.bg+1

    if(not alpha)then
        animate(0, 255, "Linear", 250, function(a)
            ui.descAlpha=a
            ui.alpha=a
        end)
    else
        ui.alpha=alpha
        ui.descAlpha=alpha
    end

    if(tick)then
        setTimer(function()
            if(not alpha)then
                animate(ui.alpha, 0, "InQuad", 500, function(a)
                    ui.alpha = a
                end, function()
                    removeEventHandler("onClientRender", root, ui.onRender)

                    exports.px_progressbar:destroyProgressbar()

                    assets.destroy()

                    if(ui.sound and isElement(ui.sound))then
                        destroyElement(ui.sound)
                        ui.sound = false
                    end

                    showChat(true)

                    toggleFunctions(true)
                end)
            else
                showChat(true)
                removeEventHandler("onClientRender", root, ui.onRender)

                exports.px_progressbar:destroyProgressbar()

                assets.destroy()

                if(ui.sound and isElement(ui.sound))then
                    destroyElement(ui.sound)
                    ui.sound = false
                end

                toggleFunctions(true)
            end
        end, tick, 1)
    end
end
addEvent("createLoadingScreen", true)
addEventHandler("createLoadingScreen", resourceRoot, createLoadingScreen)

function destroyLoadingScreen(alpha,download)
    if(ui.downloading and not download)then return end

    if(alpha)then
        assets.destroy()

        exports.px_progressbar:destroyProgressbar()

        removeEventHandler("onClientRender", root, ui.onRender)
    
        if(ui.sound and isElement(ui.sound))then
            destroyElement(ui.sound)
            ui.sound = false
        end
    
        for i,v in pairs(ui.circles) do
            destroyAnimation(v.animate)
        end

        showChat(true)

        toggleFunctions(true)
    else
        animate(ui.alpha, 0, "InQuad", 500, function(a)
            ui.alpha = a
        end, function()
            showChat(true)

            assets.destroy()

            exports.px_progressbar:destroyProgressbar()
    
            for i,v in pairs(ui.circles) do
                destroyAnimation(v.animate)
            end
    
            removeEventHandler("onClientRender", root, ui.onRender)
    
            if(ui.sound and isElement(ui.sound))then
                destroyElement(ui.sound)
                ui.sound = false
            end

            toggleFunctions(true)
        end)
    end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
    exports.px_progressbar:destroyProgressbar()
end)

-- downloading

local lastUpdate=getTickCount()
addEventHandler("onClientTransferBoxProgressChange", root, function(downloadedSize, totalSize)
    if(ui.downloading)then
        if(not lastMB)then
            lastMB=downloadedSize
            speedMB=0
        end

        local percentage = math.min((downloadedSize / totalSize) * 100, 100)

        local dS=string.format("%.2f", downloadedSize/1048576)
        local tS=string.format("%.2f", totalSize/1048576)
        exports.px_progressbar:updateProgressbar("Przygotowujemy potrzebne składniki... "..math.floor(percentage).."% - "..dS.."/"..tS.." MB ( "..string.format("%.2f", speedMB/1048576).." MB/s )", percentage)

        if(getTickCount()-lastUpdate > 1000)then
            speedMB=downloadedSize-lastMB
            lastMB=downloadedSize
            lastUpdate=getTickCount()
        end
    end
end)

-- start 

createLoadingScreen(false, 255, false, true)
ui.downloading=true

-- loading

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

function isLoadingVisible()
    return isEventHandlerAdded("onClientRender", root, ui.onRender)
end