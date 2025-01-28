--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

animations.selector = {}
animations.anims = {}
animations.objectPreview = exports["object_preview"]
animations.buttons = exports["px_buttons"]

animations.render = function()
    blur:dxDrawBlur(sx/2-453/zoom, sy/2-301/zoom, 907/zoom, 602/zoom, tocolor(255, 255, 255, animations.alpha))
    dxDrawImage(sx/2-453/zoom, sy/2-301/zoom, 907/zoom, 602/zoom, assets.textures[14], 0, 0, 0, tocolor(255, 255, 255, animations.alpha))

    for i, v in pairs({{"Wszystkie", assets.textures[8]}, {"Ulubione", assets.textures[9]}}) do
        local header = v[1]
        local texture = v[2]
        local w, h = dxGetMaterialSize(texture)
        local color = ((animations.actualTab or "Wszystkie") == header and tocolor(230, 230, 230, animations.alpha) or tocolor(150, 150, 150, animations.alpha))
        dxDrawImage(sx/2-(431-(i-1)*115)/zoom, sy/2-282/zoom, w/zoom, h/zoom, texture, 0, 0, 0, tocolor(255, 255, 255, animations.alpha))
        dxDrawText(header, sx/2-(431-(w+6)-(i-1)*115)/zoom, sy/2-282/zoom, sx/2-(431-(w+6)-(i-1)*115)/zoom, sy/2-(282-h)/zoom, color, 1, assets.fonts[3], "left", "center")

        if not animations.selectorMoving then
            if (animations.actualTab or "Wszystkie") ~= header and not animations.anims["przejscie"] then
                if click(sx/2-(431-(i-1)*115)/zoom, sy/2-282/zoom, w+dxGetTextWidth(header, 1, assets.fonts[3], false)+6/zoom, 18/zoom) then
                    local selectorX = (animations.selector.x or sx/2-405/zoom)
                    local targetX = (header == "Wszystkie" and sx/2-405/zoom or sx/2-289/zoom)
                    animations.anims[#animations.anims+1] = animate(animations.selector.w, dxGetTextWidth(header, 1, assets.fonts[3], false), "InOutQuad", 300, function(x) animations.selector.w = x end)
                    animations.anims[#animations.anims+1] = animate(selectorX, targetX, "InOutQuad", 300, function(x) 
                        animations.selector.x = x 
                    end, function() 
                        scroll:dxDestroyScroll(animations.scroll)
                        animations.scroll=scroll:dxCreateScroll(sx/2-452/zoom+395/zoom, sy/2-245/zoom, 4, 499/zoom, 0, 1, false, 499/zoom, 255, 0, false, true, 0, 499/zoom, 150)      

                        animations.selectorMoving = false; 
                        animations.actualTab = header; 
                        animations.scrollPosition = 0; 

                        animations.refreshRT();      
                        
                        animations.anims={}
                    end)
                    animations.selectorMoving = true
                    if isElement(animations.preview_ped) then setPedAnimation(animations.preview_ped) end
                    animations.selected = nil

                    animations.anims["przejscie"] = animate(255, 0, "InOutQuad", 300, function(x) 
                        animations.rtAlpha=x
                    end, function()
                        animations.anims["przejscie"] = animate(0, 255, "InOutQuad", 300, function(x) 
                            animations.rtAlpha=x
                        end, function()
                            animations.anims["przejscie"]=nil

                            animations.anims={}
                        end)
                    end)
                end
            end
        end
    end

    local selectorX = (animations.selector.x or sx/2-405/zoom)
    local selectorW = (animations.selector.w or 0)
    dxDrawRectangle(selectorX, sy/2-259/zoom, selectorW, 1, tocolor(42, 169, 201, animations.alpha))

    dxDrawText("Panel animacji", sx/2+48/zoom, sy/2-273/zoom, sx/2+48/zoom, sy/2-273/zoom, tocolor(200, 200, 200, animations.alpha), 1, assets.fonts[1], "right", "center")
    dxDrawImage(sx/2-452/zoom, sy/2-246/zoom, 905/zoom, 1, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, animations.alpha))

    dxDrawImage(sx/2+58/zoom, sy/2-289/zoom, 48/zoom, 30/zoom, assets.textures[15], 0, 0, 0, tocolor(255, 255, 255, animations.alpha))

    dxDrawImage(sx/2-452/zoom, sy/2+254/zoom, 905/zoom, 1, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, animations.alpha))
    dxDrawText("Kliknij "..'"F6"'.." aby zamknąć panel", sx/2, sy/2+278/zoom, sx/2, sy/2+278/zoom, tocolor(130, 130, 130, animations.alpha), 1, assets.fonts[2], "center", "center")

    local actualTab = (animations.actualTab or "Wszystkie")
    if actualTab and animations.tabs[actualTab] then animations.tabs[actualTab]() end

    if getKeyState("mouse1") and not animations.clickblock then
        animations.clickblock = true
    elseif not getKeyState("mouse1") and animations.clickblock then
        animations.clickblock = false
    end

    local scrollPos=scroll:dxScrollGetRTPosition(animations.scroll) or 0
    if(animations.scrollPosition ~= scrollPos)then
        animations.scrollPosition=scrollPos
        animations.refreshRT()
    end
end

animations.tabs = {}

animations.tabs["Wszystkie"] = function()
    local y = 0

    dxDrawImage(sx/2-452/zoom, sy/2-245/zoom, 395/zoom, 499/zoom, animations.rt, 0, 0, 0, tocolor(255, 255, 255, animations.rtAlpha))

    dxDrawRectangle(sx/2-452/zoom+395/zoom, sy/2-245/zoom, 1, 499/zoom, tocolor(85, 85, 85, animations.alpha))

    dxDrawImage(sx/2-57/zoom, sy/2-245/zoom, 510/zoom, 55/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, animations.alpha))
    if animations.selected then
        local categoryName, animationIndex = unpack(animations.selected)
        local animationName = animations.animationList[categoryName].animationList[animationIndex].name
        dxDrawText("Animacja "..categoryName, sx/2-54/zoom, sy/2-217/zoom, sx/2+453/zoom, sy/2-217/zoom, tocolor(220, 220, 220, animations.alpha), 1, assets.fonts[4], "center", "bottom")
        dxDrawText('"'..animationName..'"', sx/2-54/zoom, sy/2-220/zoom, sx/2+453/zoom, sy/2-220/zoom, tocolor(200, 200, 200, animations.alpha), 1, assets.fonts[3], "center", "top")
        if click(sx/2+129/zoom, sy/2+197/zoom, 147/zoom, 38/zoom) then animations.toggle(false); animations.tryUseAnimation(categoryName, animationIndex) end
    else
        dxDrawText("Wybierz animacje", sx/2-54/zoom, sy/2-217/zoom, sx/2+453/zoom, sy/2-217/zoom, tocolor(220, 220, 220, animations.alpha), 1, assets.fonts[4], "center", "center")
    end

    for i, v in pairs(animations.relase or {}) do
        local x, y, categoryName = unpack(v)
        if click(x, y, 17/zoom, 17/zoom) then
            animations.animationList[categoryName].released = not animations.animationList[categoryName].released
            animations.refreshRT()
        end
    end

    for i, v in pairs(animations.hovers or {}) do
        local x, y, categoryName, animationIndex = unpack(v)
        if isMouseInPosition(x, y, 395/zoom, 57/zoom) then
            if not animations.animationList[categoryName].animationList[animationIndex].hovered then
                animations.refreshRT()
            end
            if click(x+364/zoom, y+18/zoom, 20/zoom, 20/zoom) then
                animations.toggleFavourite(categoryName, animationIndex)
                animations.refreshRT()
            elseif click(x, y, 395/zoom, 57/zoom) then
                animations.selected = {categoryName, animationIndex}
                animations.refreshRT()
                animations.onSelectAnimation(categoryName, animationIndex)
            end
        else
            if animations.animationList[categoryName].animationList[animationIndex].hovered then
                animations.refreshRT()
            end
        end
    end
end

animations.tabs["Ulubione"] = function()
    local y = 0

    dxDrawImage(sx/2-452/zoom, sy/2-245/zoom, 395/zoom, 499/zoom, animations.rt, 0, 0, 0, tocolor(255, 255, 255, animations.rtAlpha))
    
    dxDrawRectangle(sx/2-452/zoom+395/zoom, sy/2-245/zoom, 1, 499/zoom, tocolor(85, 85, 85, animations.alpha))

    dxDrawImage(sx/2-57/zoom, sy/2-245/zoom, 510/zoom, 55/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, animations.alpha))
    if animations.selected then
        local categoryName, animationIndex = unpack(animations.selected)
        local animationName = animations.favouriteList[categoryName].animationList[animationIndex].name
        dxDrawText("Animacja "..categoryName, sx/2-54/zoom, sy/2-217/zoom, sx/2+453/zoom, sy/2-217/zoom, tocolor(220, 220, 220, animations.alpha), 1, assets.fonts[4], "center", "bottom")
        dxDrawText('"'..animationName..'"', sx/2-54/zoom, sy/2-220/zoom, sx/2+453/zoom, sy/2-220/zoom, tocolor(200, 200, 200, animations.alpha), 1, assets.fonts[3], "center", "top")
        if click(sx/2+129/zoom, sy/2+197/zoom, 147/zoom, 38/zoom) then animations.toggle(false); animations.tryUseAnimation(categoryName, animationIndex) end
    else
        dxDrawText("Wybierz animacje", sx/2-54/zoom, sy/2-217/zoom, sx/2+453/zoom, sy/2-217/zoom, tocolor(220, 220, 220, animations.alpha), 1, assets.fonts[4], "center", "center")
    end

    for i, v in pairs(animations.relase or {}) do
        local x, y, categoryName = unpack(v)
        if click(x, y, 17/zoom, 17/zoom) then
            animations.favouriteList[categoryName].released = not animations.favouriteList[categoryName].released
            animations.refreshRT()
        end
    end

    for i, v in pairs(animations.hovers or {}) do
        local x, y, categoryName, animationIndex = unpack(v)
        if isMouseInPosition(x, y, 395/zoom, 57/zoom) then
            if not animations.favouriteList[categoryName].animationList[animationIndex].hovered then
                animations.refreshRT()
            end
            if click(x+364/zoom, y+18/zoom, 20/zoom, 20/zoom) then
                animations.toggleFavourite(categoryName, animationIndex)
                animations.refreshRT()
            elseif click(x, y, 395/zoom, 57/zoom) then
                animations.selected = {categoryName, animationIndex}
                animations.refreshRT()
                animations.onSelectAnimation(categoryName, animationIndex)
            end
        else
            if animations.favouriteList[categoryName].animationList[animationIndex].hovered then
                animations.refreshRT()
            end
        end
    end
end

animations.onSelectAnimation = function(categoryName, animationIndex)
    local animationInfo = animations.animationList[categoryName].animationList[animationIndex]
    if not animationInfo then return false end
    if not isElement(animations.preview_ped) then return false end
    if not animations.preview then return false end
    setPedAnimation(animations.preview_ped)
    setPedAnimation(animations.preview_ped, unpack(animationInfo.animation))
    return
end

animations.refreshFavourite = function()
    if not animations.favouriteList then animations.favouriteList = {} end
    for categoryName, v in pairs(animations.animationList) do
        for i, v in pairs(v.animationList) do
            if v.isFavourite then
                if not animations.favouriteList[categoryName] then animations.favouriteList[categoryName] = {animationList = {}} end
                if not animations.favouriteList[categoryName].animationList[i] then animations.favouriteList[categoryName].animationList[i] = v end
            else
                if animations.favouriteList[categoryName] and animations.favouriteList[categoryName].animationList and animations.favouriteList[categoryName].animationList[i] then
                    animations.favouriteList[categoryName].animationList[i] = nil
                    if #animations.favouriteList[categoryName].animationList <= 0 then animations.favouriteList[categoryName] = nil end
                end
            end
        end
    end
end

animations.toggleFavourite = function(categoryName, animationIndex)
    animations.animationList[categoryName].animationList[animationIndex].isFavourite = not animations.animationList[categoryName].animationList[animationIndex].isFavourite
    animations.refreshFavourite()
end

animations.saveFavourites = function()
    local xml = (xmlLoadFile("favourite.xml") or xmlCreateFile("favourite.xml", "favouriteAnimations"))
    if not xml then return false end
    local favourites = xmlNodeGetChildren(xml)
    local favouritesChecked = {}
    for i, v in pairs(favourites) do
        local categoryName = xmlNodeGetAttribute(v, "categoryName")
        local animationIndex = (xmlNodeGetAttribute(v, "animationIndex") and tonumber(xmlNodeGetAttribute(v, "animationIndex")))
        if not categoryName or not animationIndex then xmlDestroyNode(v) end
        if not animations.animationList[categoryName] or not animations.animationList[categoryName].animationList[animationIndex] or not animations.animationList[categoryName].animationList[animationIndex].isFavourite then xmlDestroyNode(v) end
        favouritesChecked[categoryName..":"..animationIndex] = true
    end
    for categoryName, v in pairs(animations.animationList) do
        for i, v in pairs(v.animationList) do
            if not favouritesChecked[categoryName..":"..i] then
                if v.isFavourite then
                    local child = xmlCreateChild(xml, "favourite")
                    xmlNodeSetAttribute(child, "categoryName", categoryName)
                    xmlNodeSetAttribute(child, "animationIndex", i)
                end
            end
        end
    end
    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end

animations.refreshRT = function()    
    animations.hovers = {}
    animations.relase = {}

    local actualTab = (animations.actualTab or "Wszystkie")
    dxSetRenderTarget(animations.rt, true)
        dxSetBlendMode("modulate_add")
            local y=-(animations.scrollPosition or 0)

            local max=0
            for categoryName, v in pairs(actualTab == "Ulubione" and (animations.favouriteList or {}) or animations.animationList) do
                local isReleased = (v.released or false)
                local texture = (isReleased and assets.textures[3] or assets.textures[4])
                dxDrawImage(0, y, 395/zoom, 27/zoom, texture, 0, 0, 0, tocolor(255, 255, 255))
                dxDrawText("Animacje "..categoryName, 24/zoom, y, 24/zoom, y+27/zoom, tocolor(220, 220, 220), 1, assets.fonts[3], "left", "center")

                max=max+27/zoom

                local texture = (isReleased and assets.textures[12] or assets.textures[13])
                dxDrawImage(363/zoom, y+3/zoom, 20/zoom, 20/zoom, texture, 0, 0, 0, tocolor(255, 255, 255))

                animations.relase[#animations.relase+1] = {sx/2-89/zoom, sy/2-((240/zoom)-y), categoryName}
                y = y+27/zoom

                if isReleased then
                    for i, v in pairs(v.animationList) do
                        local isHovered = isMouseInPosition(sx/2-452/zoom, sy/2-((245/zoom)-y), 395/zoom, 57/zoom)
                        local isSelected = (animations.selected and (animations.selected[1] == categoryName and animations.selected[2] == i) and true or false)
                        local texture = ((isHovered or isSelected) and assets.textures[2] or assets.textures[1])
                        dxDrawImage(0, y, 395/zoom, 57/zoom, texture, 0, 0, 0, tocolor(255, 255, 255))

                        local texture = (v.isFavourite and assets.textures[9] or (isHovered or isSelected) and assets.textures[11] or assets.textures[10])
                        dxDrawImage(364/zoom, y+18/zoom, 20/zoom, 20/zoom, texture)

                        dxDrawText(i, 27/zoom, y, 27/zoom, y+57/zoom, tocolor(220, 220, 220), 1, assets.fonts[4], "left", "center")

                        dxDrawText(v.name.." #646464( /"..v.command.." )", 57/zoom, y, 57/zoom, y+57/zoom, tocolor(220, 220, 220), 1, assets.fonts[3], "left", "center", false, false, false, true)

                        animations.hovers[#animations.hovers+1] = {sx/2-452/zoom, sy/2-((245/zoom)-y), categoryName, i}
                        
                        if actualTab == "Wszystkie" then
                            animations.animationList[categoryName].animationList[i].hovered = isHovered
                        else
                            animations.favouriteList[categoryName].animationList[i].hovered = isHovered
                        end

                        y = y+58/zoom
                        max=max+58/zoom
                    end
                end
            end
        dxSetBlendMode("blend")
    dxSetRenderTarget()

    scroll:dxScrollUpdateRTSize(animations.scroll, max)
end

animations.toggle = function()  
    if(#animations.anims > 0)then return end
      
    animations.selectorMoving = false

    if not animations.showing then
        if(not getElementData(localPlayer, "user:logged"))then return end
        if(getElementData(localPlayer, "user:gui_showed"))then return end

        if animations.preview then animations.objectPreview:destroyObjectPreview(animations.preview) end
        if isElement(animations.preview_ped) then destroyElement(animations.preview_ped) end

        removeEventHandler("onClientRestore", getRootElement(), animations.refreshRT)
        addEventHandler("onClientRestore", getRootElement(), animations.refreshRT)
        removeEventHandler("onClientRender", getRootElement(), animations.render)
        addEventHandler("onClientRender", getRootElement(), animations.render)

        animations.scroll=scroll:dxCreateScroll(sx/2-452/zoom+395/zoom, sy/2-245/zoom, 4, 499/zoom, 0, 1, false, 499/zoom, 255, 0, false, true, 0, 499/zoom, 150)

        animations.rt = dxCreateRenderTarget(395/zoom, 499/zoom, true)
        animations.refreshRT()
        animations.preview_ped = createPed(0, 0, 0, 0)
        animations.preview = animations.objectPreview:createObjectPreview(animations.preview_ped, 0, 0, 180, sx/2+22/zoom, sy/2-165/zoom, 335/zoom, 335/zoom, false, true)
        animations.objectPreview:setAlpha(animations.preview, 0)
        animations.selector.w = dxGetTextWidth((animations.actualTab or "Wszystkie"), 1, assets.fonts[3], false)
        if animations.button then animations.buttons:destroyButton(animations.button) end
        animations.button = animations.buttons:createButton(sx/2+129/zoom, sy/2+197/zoom, 147/zoom, 38/zoom, "AKTYWUJ ANIMACJE", 0, 9)
        animations.refreshFavourite()

        animations.showing=true
        animations.anims[#animations.anims+1] = animate(0, 255, "InOutQuad", 300, function(x) 
            scroll:dxScrollSetAlpha(animations.scroll,x); 
            animations.rtAlpha=x; 
            animations.alpha = x; 
            animations.objectPreview:setAlpha(animations.preview, x); 
            if animations.button then 
                animations.buttons:buttonSetAlpha(animations.button, x) 
            end 
        end, function()
            animations.anims={}
        end)

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

        showCursor(true, false)
    else
        animations.anims[#animations.anims+1] = animate(255, 0, "InOutQuad", 300, function(x) 
            scroll:dxScrollSetAlpha(animations.scroll,x); 
            animations.rtAlpha=x; 
            animations.alpha = x; 
            animations.objectPreview:setAlpha(animations.preview, x); 
            if animations.button then animations.buttons:buttonSetAlpha(animations.button, x) end 
        end, function()
            setElementData(localPlayer, "user:gui_showed", false, false)
            scroll:dxDestroyScroll(animations.scroll)

            animations.showing=false
            animations.anims={}

            if animations.preview then animations.objectPreview:destroyObjectPreview(animations.preview) end
            if isElement(animations.preview_ped) then destroyElement(animations.preview_ped) end
            removeEventHandler("onClientRender", getRootElement(), animations.render)
            if isElement(animations.rt) then destroyElement(animations.rt) end
            if animations.button then animations.buttons:destroyButton(animations.button) end
        end)

        showCursor(false)
        removeEventHandler("onClientRestore", getRootElement(), animations.refreshRT)
        animations.saveFavourites()
    end
end

animations.getAlpha = function(value)
    return math.min((animations.alpha or 0), value)
end

animations.factions={
    ["SAPD"]=true,
    ["SARA"]=true,
    ["PSP"]=true,
    ["SACC"]=true,
}

bindKey("F6", "down", function()
    if(isPedInVehicle(localPlayer))then return end
    if(animations.tipsState)then return end
    if(getElementData(localPlayer, "user:job"))then return end
    if(getElementData(localPlayer,'Area.InZone'))then return end

    local faction=getElementData(localPlayer, "user:faction")
    if(not faction or (faction and animations.factions[faction]))then
        animations.toggle()
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)