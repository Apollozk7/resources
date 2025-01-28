--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui.lastUpdateInfo=5000

ui.setPage=function(id)
    if(not ui.pages.menu[id])then return end

    local last=ui.pages.selected

    ui.animate=true
    animate(255, 0, "Linear", 200, function(a)
        ui.pages.menu[ui.pages.selected].alpha=a
        ui.pages.menu[id].alpha=a

        for i,v in pairs(ui.buttons) do
            buttons:buttonSetAlpha(v,a)
        end
        for i,v in pairs(ui.scrolls) do
            scroll:dxScrollSetAlpha(v, a)
        end
        for i,v in pairs(ui.edits) do
            editbox:dxSetEditAlpha(v, a)
        end
    end, function()
        if(ui.mapRT)then
            destroyElement(ui.mapRT)
            ui.mapRT=false
        end

        for i,v in pairs(ui.buttons) do
            buttons:destroyButton(v)
        end
        ui.buttons={}

        for i,v in pairs(ui.edits) do
            editbox:dxDestroyEdit(v)
        end
        ui.edits={}

        for i,v in pairs(ui.scrolls) do
            scroll:dxDestroyScroll(v)
        end
        ui.scrolls={}

        assets.destroy(ui.pages.menu[last].name)
        assets.create(ui.pages.menu[id].name)
        ui.pages.selected=id
        ui.render=ui.pages.menu[id].name

        if(ui.pages.menu[id].name == "Pojazdy")then
            ui.mapRT=dxCreateRenderTarget(494/zoom, 285/zoom, true)
        end

        animate(0, 255, "Linear", 200, function(a)
            ui.pages.menu[last].alpha=a
            ui.pages.menu[ui.pages.selected].alpha=a

            for i,v in pairs(ui.buttons) do
                buttons:buttonSetAlpha(v,a)
            end
            for i,v in pairs(ui.edits) do
                editbox:dxSetEditAlpha(v, a)
            end
            for i,v in pairs(ui.scrolls) do
                scroll:dxScrollSetAlpha(v, a)
            end
        end, function()
            ui.animate=false
        end)
    end)
end

ui.onRender=function()
    local texs=assets.textures.menu

    local white=tocolor(255, 255, 255, ui.mainAlpha)
    -- background
    blur:dxDrawBlur(0, 0, sw, sh, white)
    dxDrawRectangle(0, 0, sw, sh, tocolor(30, 30, 30, ui.mainAlpha > 200 and 200 or ui.mainAlpha))

    -- left menu
    
    -- logo
    local w,h=132,64
    logos:dxDrawMiniLogo((381-w)/2/zoom, 59/zoom, w, h, ui.mainAlpha)

    -- right line
    dxDrawRectangle(381/zoom, sh/2-1037/2/zoom, 1, 1037/zoom, tocolor(80,80,80,ui.mainAlpha > 50 and 50 or ui.mainAlpha))

    -- left menu
    dxDrawRectangle(25/zoom, 169/zoom, 1, 460/zoom, tocolor(80,80,80,ui.mainAlpha > 200 and 200 or ui.mainAlpha))
    for i,v in pairs(ui.pages.menu) do
        local sY=(53/zoom)*(i-1)
        local w,h=dxGetMaterialSize(texs[i])
        local a=v.alpha or ui.mainAlpha
        a=a > ui.mainAlpha and ui.mainAlpha or a

        if(ui.pages.selected == i)then
            dxDrawImage(25/zoom, 167/zoom+sY, 379/zoom, 44/zoom, texs[10], 0, 0, 0, tocolor(255, 255, 255, a))
            dxDrawImage(87/zoom, 167/zoom+sY+(44-h)/2/zoom, w/zoom, h/zoom, texs[i], 0, 0, 0, tocolor(80, 170, 190, a))
            dxDrawText(v.name, 120/zoom, 167/zoom+sY, 0, 167/zoom+sY+44/zoom, v.color and tocolor(v.color[1], v.color[2], v.color[3], a) or tocolor(200, 200, 200, a), 1, assets.fonts[1], "left", "center")
        else
            dxDrawImage(68/zoom, 167/zoom+sY+(44-h)/2/zoom, w/zoom, h/zoom, texs[i], 0, 0, 0, tocolor(180, 180, 180, a))
            dxDrawText(v.name, 100/zoom, 167/zoom+sY, 0, 167/zoom+sY+44/zoom, v.color and tocolor(v.color[1], v.color[2], v.color[3], a) or tocolor(180, 180, 180, a), 1, assets.fonts[2], "left", "center")
        end

        onClick(25/zoom, 167/zoom+sY, 379/zoom, 44/zoom, function()
            if(ui.pages.selected ~= i)then
                ui.setPage(i)
            end
        end)
    end

    if(not ui.info.user or not ui.friends)then
        return
    end

    -- left invites to org
    local orgInvite=fromJSON(ui.info.user.orgInvite) or {}
    if(orgInvite.name)then
        dxDrawRectangle(0, sh-477/zoom+40/zoom, 381/zoom, 1, tocolor(80,80,80,ui.mainAlpha > 50 and 50 or ui.mainAlpha))
        dxDrawRectangle(0, sh-477/zoom+1+40/zoom, 381/zoom, 67/zoom, tocolor(128,143,144,ui.mainAlpha > 22 and 22 or ui.mainAlpha))
        dxDrawText("Zaproszenie do organizacji", 16/zoom, sh-477/zoom+1+5/zoom+40/zoom, 0, 0, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[2], "left", "top")
            
        if(ui.orgAvatar)then
            dxDrawImage(16/zoom, sh-477/zoom+35/zoom+40/zoom, 24/zoom, 24/zoom, ui.orgAvatar, 0, 0, 0, white)
        end
        dxDrawText(orgInvite.name, 53/zoom, sh-477/zoom+35/zoom+40/zoom, 0, sh-477/zoom+35/zoom+24/zoom+40/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[2], "left", "center")

        dxDrawImage(381/zoom-76/zoom, sh-477/zoom+(67-28)/2/zoom+40/zoom, 28/zoom, 28/zoom, texs[13], 0, 0, 0, white)
        dxDrawImage(381/zoom-28/zoom, sh-477/zoom+(67-9)/2/zoom+40/zoom, 9/zoom, 9/zoom, texs[14], 0, 0, 0, white)

        onClick(381/zoom-76/zoom, sh-477/zoom+(67-28)/2/zoom+40/zoom, 28/zoom, 28/zoom, function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("dashboard.requestGroupInvite", resourceRoot, "accept", orgInvite.name, orgInvite.target)
        end)
        onClick(381/zoom-28/zoom, sh-477/zoom+(67-9)/2/zoom+40/zoom, 9/zoom, 9/zoom, function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("dashboard.requestGroupInvite", resourceRoot, false, orgInvite.name)
        end)
    end

    -- left friends
    dxDrawRectangle(0, sh-410/zoom+40/zoom, 381/zoom, 1, tocolor(80,80,80,ui.mainAlpha > 50 and 50 or ui.mainAlpha))
    dxDrawImage(0, sh-410/zoom+1+40/zoom, 375/zoom, 38/zoom, texs[11], 0, 0, 0, white)
    dxDrawText("Lista znajomych", 16/zoom, sh-410/zoom+1+40/zoom, 0, sh-410/zoom+1+38/zoom+40/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[1], "left", "center")
    dxDrawText(ui.textFriends, 0, sh-410/zoom+1+40/zoom, 362/zoom, sh-410/zoom+1+38/zoom+40/zoom, tocolor(180, 180, 180, ui.mainAlpha), 1, assets.fonts[2], "right", "center")

    -- list
    local row=math.floor(scroll:dxScrollGetPosition(ui.scroll)+1)
    local k=0
    for i=row,row+5 do
        local v=ui.friends[i]
        if(v)then
            k=k+1

            local target=getPlayerFromName(v.login)
            local sY=(50/zoom)*(k-1)

            if(v.invite)then
                dxDrawRectangle(0, sh-410/zoom+1+38/zoom+sY+40/zoom, 381/zoom, 49/zoom, tocolor(12, 146, 37, ui.mainAlpha > 10 and 10 or ui.mainAlpha))
                dxDrawText("Chce zostać Twoim znajomym", 56/zoom, sh-410/zoom+1+38/zoom+sY+25/zoom+40/zoom, 0, 0, tocolor(100, 100, 100, ui.mainAlpha), 1, assets.fonts[4], "left", "top")

                dxDrawImage(381/zoom-76/zoom, sh-410/zoom+1+38/zoom+sY+(49-28)/2/zoom+40/zoom, 28/zoom, 28/zoom, texs[13], 0, 0, 0, white)
                onClick(381/zoom-76/zoom, sh-410/zoom+1+38/zoom+sY+(49-28)/2/zoom+40/zoom, 28/zoom, 28/zoom, function()
                    if(SPAM.getSpam())then return end

                    triggerServerEvent("dashboard.requestFriendInvite", resourceRoot, "accept", v.uid, v.login)
                end)
                dxDrawImage(381/zoom-28/zoom, sh-410/zoom+1+38/zoom+sY+(49-9)/2/zoom+40/zoom, 9/zoom, 9/zoom, texs[14], 0, 0, 0, white)
                onClick(381/zoom-28/zoom, sh-410/zoom+1+38/zoom+sY+(49-9)/2/zoom+40/zoom, 9/zoom, 9/zoom, function()
                    if(SPAM.getSpam())then return end

                    triggerServerEvent("dashboard.requestFriendInvite", resourceRoot, false, v.uid, v.login)
                end)
            else
                dxDrawRectangle(0, sh-410/zoom+1+38/zoom+sY+40/zoom, 381/zoom, 49/zoom, tocolor(15, 15, 15, ui.mainAlpha > 50 and 50 or ui.mainAlpha))

                if(target)then
                    local status=getElementData(target, "user:faction") or getElementData(target, "user:job") or "Swobodna rozgrywka"
                    dxDrawText("Online", 56/zoom, sh-410/zoom+1+38/zoom+sY+25/zoom+40/zoom, 0, 0, tocolor(70, 179, 70, ui.mainAlpha), 1, assets.fonts[4], "left", "top")
                    dxDrawText(status, 56/zoom, sh-410/zoom+1+38/zoom+sY+40/zoom, 381/zoom-40/zoom, sh-410/zoom+1+38/zoom+sY+49/zoom+40/zoom, tocolor(150, 150, 150, ui.mainAlpha), 1, assets.fonts[3], "right", "center")
                else
                    dxDrawText("Offline", 56/zoom, sh-410/zoom+1+38/zoom+sY+25/zoom+40/zoom, 0, 0, tocolor(150, 150, 150, ui.mainAlpha), 1, assets.fonts[4], "left", "top")
                end

                if(isMouseInPosition(0, sh-410/zoom+1+38/zoom+sY+40/zoom, 381/zoom, 49/zoom))then
                    dxDrawImage(381/zoom-28/zoom, sh-410/zoom+1+38/zoom+sY+(49-18)/2/zoom+40/zoom, 14/zoom, 18/zoom, texs[15], 0, 0, 0, white)
                    onClick(381/zoom-28/zoom, sh-410/zoom+1+38/zoom+sY+(49-18)/2/zoom+40/zoom, 14/zoom, 18/zoom, function()
                        if(SPAM.getSpam())then return end

                        exports.px_interaction:removeFriend(v)
                    end)
                end
            end

            local av=avatars:getPlayerAvatar(v.login)
            if(av)then
                dxDrawImage(14/zoom, sh-410/zoom+1+38/zoom+sY+(49-25)/2/zoom+40/zoom, 25/zoom, 25/zoom, av, 0, 0, 0, white)
                if(target)then
                    dxDrawImage(14/zoom, sh-410/zoom+1+38/zoom+sY+(49-25)/2/zoom+40/zoom, 25/zoom, 25/zoom, texs[12], 0, 0, 0, white)
                end
            end

            local login=target and getPlayerMaskName(target) or v.login
            dxDrawText(login, 56/zoom, sh-410/zoom+1+38/zoom+sY+8/zoom+40/zoom, 0, 0, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[2], "left", "top")

            dxDrawRectangle(0, sh-410/zoom+1+38/zoom+sY+48/zoom+40/zoom, 381/zoom, 1, tocolor(80, 80, 80, ui.mainAlpha > 125 and 125 or ui.mainAlpha))
        end
    end
    --

    if(ui.render)then
        ui.rendering[ui.render](ui.pages.menu[ui.pages.selected].alpha,ui.mainAlpha)
    end
end

ui.togglePanel=function(toggle)
    if(ui.animate)then return end
    if(not getElementData(localPlayer, "user:logged"))then return end

    if(toggle)then
        ui.loadingImages = false
        if((getTickCount()-ui.lastUpdateInfo) < 5000)then return exports.px_noti:noti("Zaczekaj chwilkę!") end
        if(getElementData(localPlayer, "user:hud_disabled"))then return end
        if(getElementData(localPlayer, "user:gui_showed"))then return end

        blur=exports.blur
        logos=exports.px_alogos
        avatars=exports.px_avatars
        noti=exports.px_noti
        scroll=exports.px_scroll
        interaction=exports.px_interaction
        object_preview=exports.object_preview
        buttons=exports.px_buttons
        scroll=exports.px_scroll
        editbox=exports.px_editbox

        ui.pages.selected=1

        showCursor(true)

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
        setElementData(localPlayer, "user:hud_disabled", true, false)

        assets.create()
        assets.create(ui.pages.menu[ui.pages.selected].name)
        ui.render=ui.pages.menu[ui.pages.selected].name

        addEventHandler("onClientRender", root, ui.onRender)

        if(not SPAM.getSpam())then
            triggerServerEvent("update.info", resourceRoot, ui.orgAvatar and true)
        end

        scroll:dxDestroyScroll(ui.scroll)
        if(ui.friends and #ui.friends > 0)then
            ui.scroll=scroll:dxCreateScroll(381/zoom-3, sh-410/zoom+38/zoom+40/zoom, 4, 4, 0, 6, ui.friends, 300/zoom, ui.pages.menu[ui.pages.selected].alpha, false, {0, 0, 381/zoom, sh})
        end

        ui.dashboard=true

        ui.animate=true
        animate(ui.mainAlpha, 255, "Linear", 200, function(a)
            ui.mainAlpha=a

            scroll:dxScrollSetAlpha(ui.scroll, a)
            for i,v in pairs(ui.scrolls) do
                scroll:dxScrollSetAlpha(v, a)
            end

            for i,v in pairs(ui.buttons) do
                buttons:buttonSetAlpha(v,a)
            end

            for i,v in pairs(ui.edits) do
                editbox:dxSetEditAlpha(v, a)
            end
        end, function()
            ui.animate=false
        end)

        showChat(false)
    else
        showCursor(false)

        ui.animate=true
        animate(ui.mainAlpha, 0, "Linear", 200, function(a)
            ui.mainAlpha=a

            scroll:dxScrollSetAlpha(ui.scroll, a)
            for i,v in pairs(ui.scrolls) do
                scroll:dxScrollSetAlpha(v, a)
            end

            for i,v in pairs(ui.buttons) do
                buttons:buttonSetAlpha(v,a)
            end

            for i,v in pairs(ui.edits) do
                editbox:dxSetEditAlpha(v, a)
            end
        end, function() 
            assets.destroy()

            setElementData(localPlayer, "user:gui_showed", false, false)
            setElementData(localPlayer, "user:hud_disabled", false, false)
    
            removeEventHandler("onClientRender", root, ui.onRender)

            ui.animate=false

            scroll:dxDestroyScroll(ui.scroll)
            ui.scroll=false

            for i,v in pairs(ui.scrolls) do
                scroll:dxDestroyScroll(v)
            end
            ui.scrolls={}

            if(ui.mapRT)then
                destroyElement(ui.mapRT)
                ui.mapRT=false
            end

            for i,v in pairs(ui.buttons) do
                buttons:destroyButton(v)
            end
            ui.buttons={}

            for i,v in pairs(ui.edits) do
                editbox:dxDestroyEdit(v)
            end
            ui.edits={}

            ui.dashboard=false

            showChat(true)
        end)
    end
end

bindKey("F1", "down", function()
    ui.togglePanel(not ui.dashboard)
end)

function getArraySize(array)
    local i = 0

    for _, _ in pairs(array) do
        i = i + 1
    end

    return i
end

addEvent("update.info", true)
addEventHandler("update.info", resourceRoot, function(user, faction, organization, vehs, houses, punish, rank, premium, discord, friends, achievements)
    if(not user)then return end

    if(getElementData(localPlayer, 'user:gui_showed') ~= resourceRoot)then return end

    ui.info={
        user=user,
        faction=faction,
        org=organization,
        vehs=vehs,
        houses=houses,
        punish=punish,
        rank=rank,
        premium=premium,
        discord=discord,
        achievements=achievements,
        achievementsLength = getArraySize(achievements)
    }

    local friends_rows={}
    local online=0
    local max=0

    for i,v in pairs(friends) do
        if(v.login ~= getPlayerName(localPlayer))then
            if(v.accept)then
                if(getPlayerFromName(v.login))then
                    online=online+1
                end
        
                friends_rows[#friends_rows+1]=v
                max=max+1
            else
                if(tonumber(v.uid) ~= tonumber(user.id))then
                    v.invite=true
                    friends_rows[#friends_rows+1]=v
                    max=max+1
                end
            end
        end
    end

    ui.friends=friends_rows
    ui.textFriends=online.."/"..max

    scroll:dxDestroyScroll(ui.scroll)
    if(ui.friends and #ui.friends > 0)then
        ui.scroll=scroll:dxCreateScroll(381/zoom-3, sh-410/zoom+38/zoom+40/zoom, 4, 4, 0, 6, ui.friends, 300/zoom, ui.pages.menu[ui.pages.selected].alpha, false, {0, 0, 381/zoom, sh})
    end

    for i,v in pairs(ui.buttons) do
        buttons:destroyButton(v)
    end
    ui.buttons={}

    for i,v in pairs(ui.scrolls) do
        scroll:dxDestroyScroll(v)
    end
    ui.scrolls={}

    ui.backTrigger=true
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)

addEvent("load.organization.avatar", true)
addEventHandler("load.organization.avatar", resourceRoot, function(logo)
    if(logo)then
        ui.orgAvatar=dxCreateTexture(logo, "argb", false, "clamp")
        ui.orgAvatar=exports.px_avatars:getCircleTexture(ui.orgAvatar)
    end
end)

-- mask

function getPlayerMaskName(player)
	return getElementData(player, "user:nameMask") or getPlayerName(player)
end