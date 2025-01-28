--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- exports

blur=exports.blur
alogo=exports.px_alogos
avatars=exports.px_avatars
edits=exports.px_editbox
btns=exports.px_buttons
loading=exports.px_loading
scroll=exports.px_scroll

-- assets

assets={}
assets.list={
    texs_news={
        "textures/news_bg.png",
        "textures/header.png",
        "textures/plus.png",
        "textures/new_bg.png",
        "textures/new.png",
    },

    texs={
        "textures/bg.png",

        "textures/button.png",
        "textures/shadow_button.png",
        "textures/login_button.png",
        "textures/register_button.png",

        "textures/window.png",
        "textures/avatar.png",

        "textures/checkbox.png",
        "textures/checkbox_selected.png",

        -- zones
        "textures/zones/map_shadow.png",
        "textures/zones/placeholder.png",
        "textures/zones/card-back.png",
        "textures/zones/card.png",
        "textures/zones/button_hover.png",
        "textures/zones/lv-icon.png",
    },

    fonts={
        {"Medium", 11},
        {"Bold", 14},
        {"Regular", 10},
        {"Bold", 15},
        {"Regular", 12},
        {"Medium", 8},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.newsTxt={}
    for i,v in pairs(assets.list.texs_news) do
        assets.newsTxt[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts={}
    for i,v in pairs(assets.list.fonts) do
        assets.fonts[i]=dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom)
    end
end

assets.destroy=function()
    for i,v in pairs(assets.textures) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.textures={}

    for i,v in pairs(assets.newsTxt) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.newsTxt={}

    for i,v in pairs(assets.fonts) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.fonts={}
end

-- variables

ui={}

ui.rules=0
ui.selectedUpdate=1
ui.selectedUpdateTextAlpha=255
ui.save=0
ui.draw={}
ui.option="LOGOWANIE"
ui.border={}
ui.mainAlpha=255
ui.animate=false
ui.options={
    ["LOGOWANIE"]={x=sw/2-199/zoom-4/zoom, y=sh/2-217/zoom, a=255, a2=255},
    ["REJESTRACJA"]={x=sw/2+4/zoom, y=sh/2-217/zoom, a=150, a2=0},
    ["WYBÓR SPAWNU"]={a2=0},
}

ui.login_save=""
ui.password_save=""

ui.edits={}
ui.btns={}
ui.scroll=false

-- functions

ui.onRender=function()
    dxDrawImage(0, 0, sw, sh, assets.textures[1], 0, 0, 0, tocolor(255,255,255,255))

    if(ui.banStatus)then
        alogo:dxDrawLogo(sw/2-267/2/zoom,sh/2-300/zoom,267/zoom,128/zoom,ui.mainAlpha)
        dxDrawText("ZOSTAŁEŚ ZBANOWANY", 0, 0, sw, sh, tocolor(200,200,200,200), 1, assets.fonts[1], "center", "center")
        
        local ban_text = "-----------------\nOsoba banująca: "..ui.banStatus['admin'].."\nPowód: "..ui.banStatus['reason'].."\nCzas trwania kary: "..ui.banStatus['date'].."\n\nJeżeli uważasz, że kara została nadana niesłusznie bądź jej czas trwania\nwykracza poza normy, możesz napisać odwołanie.\n-----------------";
        dxDrawText(ban_text, 0, 200/zoom, sw, sh, tocolor(200,200,200,200), 1, assets.fonts[2], "center", "center")
    
        local exitButton = {sw/2 - 187/2/zoom, sh - 150/zoom, 187/zoom, 38/zoom}
        dxDrawText("Od kary możesz się odwołać na naszym forum:\npixelmta.pl", exitButton[1], exitButton[2] - 100/zoom, exitButton[1]+exitButton[3], exitButton[2]+exitButton[4], tocolor(200,200,200,200), 1, assets.fonts[1], "center", "top")
    
        if(not ui.btns[1])then
            ui.btns[1]=btns:createButton(exitButton[1], exitButton[2], exitButton[3], exitButton[4], "OPUŚĆ SERWER", 255, 10, false, false, false, {132,39,39})
        end
    
        onClick(exitButton[1], exitButton[2], exitButton[3], exitButton[4], function()
            if(SPAM.getSpam())then return end
            triggerServerEvent("px_auth->leaveServer", resourceRoot, ui.banStatus)
        end)
        return
    end

    local visible=loading:isLoadingVisible()
    if(visible)then 
        if(sound and isElement(sound))then
            music(false)
        end
        return 
    else
        if(not sound and not isElement(sound))then
            music(true)
        end
    end

    if(ui.option ~= "WYBÓR SPAWNU")then
        alogo:dxDrawLogo(sw/2-267/2/zoom,sh/2-460/zoom,267/zoom,128/zoom,ui.mainAlpha)
        ui.draw["Aktualizacje"](ui.mainAlpha)
    end

    if(ui.draw[ui.option])then
        local a2=ui.options[ui.option].a2 > ui.mainAlpha and ui.mainAlpha or ui.options[ui.option].a2
        local a=ui.option ~= "WYBÓR SPAWNU" and a2 or ui.options[ui.option].a2
        ui.draw[ui.option](a)
    end

    if(ui.option ~= "WYBÓR SPAWNU")then
        local k=0
        for i,v in pairs(ui.options) do
            if(i ~= "WYBÓR SPAWNU")then
                k=k+1

                local w=dxGetTextWidth(i,1,assets.fonts[1])
                if(not ui.border[1] or not ui.border[2])then
                    ui.border={
                        v.x,
                        v.y
                    }
                end

                local y=ui.border[2]
                dxDrawImage(v.x, v.y, 199/zoom, 36/zoom, assets.textures[2], 0, 0, 0, tocolor(255,255,255,ui.mainAlpha > v.a and v.a or ui.mainAlpha))
                dxDrawImage(v.x-(234-199)/2/zoom,v.y+36/2/zoom,234/zoom,35/zoom,assets.textures[3],0,0,0,tocolor(255,255,255,ui.mainAlpha > 150 and 150 or ui.mainAlpha))
                dxDrawRectangle(v.x, v.y+36/zoom-2, 199/zoom, 2, tocolor(39,40,41,ui.mainAlpha))

                local text=i == 'LOGOWANIE' and 'L O G O W A N I E' or 'R E J E S T R A C J A'
                local width=dxGetTextWidth(text, 1, assets.fonts[1])
                local w,h=dxGetMaterialSize(assets.textures[3+k])
                dxDrawText(text, v.x+((199/zoom)-width)/2+w/2/zoom+5/zoom, v.y, v.x+199/zoom, v.y+36/zoom, tocolor(200,200,200,ui.mainAlpha > v.a and v.a or ui.mainAlpha), 1, assets.fonts[1], "left", "center")
                dxDrawImage(v.x+((199/zoom)-width)/2-w/2/zoom-5/zoom, v.y+(36-h)/2/zoom, w/zoom, h/zoom, assets.textures[3+k], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha > v.a and v.a or ui.mainAlpha))            

                onClick(v.x, v.y, 199/zoom, 36/zoom, function()
                    ui.animate=true
                    animate(ui.border[1], v.x, "InOutQuad", 400, function(a)
                        ui.border[1]=a
                    end, function()
                        ui.animate=false
                    end)

                    animate(ui.options[ui.option].a, 150, "Linear", 200, function(a)
                        ui.options[ui.option].a=a
                    end, function()
                        for i,v in pairs(ui.edits) do
                            edits:dxDestroyEdit(v)
                        end
                        ui.edits={}

                        for i,v in pairs(ui.btns) do
                            btns:destroyButton(v)
                        end
                        ui.btns={}

                        ui.option=i
                        animate(ui.options[ui.option].a, 255, "Linear", 200, function(a)
                            ui.options[ui.option].a=a
                        end)
                    end)

                    animate(ui.options[ui.option].a2, 0, "Linear", 200, function(a)
                        ui.options[ui.option].a2=a
                    end, function()
                        animate(ui.options[ui.option].a2, 255, "Linear", 200, function(a)
                            ui.options[ui.option].a2=a
                        end)
                    end)
                end)
            end
        end

        dxDrawImage(ui.border[1]-(234-199)/2/zoom,ui.border[2]+36/2/zoom,234/zoom,35/zoom,assets.textures[3],0,0,0,tocolor(255,255,255,ui.mainAlpha))
        dxDrawRectangle(ui.border[1], ui.border[2]+36/zoom-2, 199/zoom, 2, tocolor(33,147,176,ui.mainAlpha))
    end
end

ui.create=function()
    if(exports.px_loading:isLoadingVisible() or getElementData(localPlayer, 'user:uid'))then return end

    ui.login_save, ui.password_save=dx.getPlayerXML()
    if(ui.login_save and #ui.login_save > 0)then
        ui.save=1
        ui.checkboxAlpha=255
  
        edits:dxSetEditText(ui.edits[1], ui.login_save)
        edits:dxSetEditText(ui.edits[2], ui.password_save)
    end
    
    showChat(false)
    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)
    setPlayerHudComponentVisible("all", false)
    showCursor(true)
    fadeCamera(true)
    music(true, ui.banStatus)
    setElementFrozen(localPlayer, true)
    setElementData(localPlayer, "user:hud_disabled", true, false)

    if(ui.banStatus)then return end

    triggerServerEvent("ui.getSave", resourceRoot)

    ui.rt=dxCreateRenderTarget(510/zoom,sh,true)
    ui.map=exports.px_map:getMapTextureWithBlips()

    addEventHandler("onClientRestore", root, restore)
end
addEvent('px_loading:onDestroy', true)
addEventHandler('px_loading:onDestroy', root, ui.create)

function restore()
    ui.rt=dxCreateRenderTarget(510/zoom,sh,true)
    ui.map=exports.px_map:getMapTextureWithBlips()
end

ui.destroy=function(login, pos)
    ui.animate=true
    animate(ui.mainAlpha, 0, "Linear", 500, function(a)
        ui.mainAlpha=a

        exports.px_scroll:dxScrollSetAlpha(ui.scroll, a)
    end, function()
        showChat(true)
        
        removeEventHandler("onClientRender", root, ui.onRender)

        showCursor(false)
    
        setElementData(localPlayer, "user:hud_disabled", false, false)
    
        setElementFrozen(localPlayer, false)
    
        music(false)
    
        setCameraTarget(localPlayer)
    
        for i,v in pairs(ui.edits) do
            edits:dxDestroyEdit(v)
        end
        ui.edits={}
    
        for i,v in pairs(ui.btns) do
            btns:destroyButton(v)
        end
        ui.btns={}
    
        destroyElement(ui.rt)
        ui.rt=nil
    
        setPlayerHudComponentVisible("all", false)
        setPlayerHudComponentVisible("crosshair", true)
    
        assets.destroy()
        
        ui.animate=false

        destroyElement(ui.map)
        ui.map=false

        exports.px_scroll:dxDestroyScroll(ui.scroll)
        ui.scroll=false

        exports.px_scroll:dxDestroyScroll(ui.spawnScroll)
        ui.spawnScroll=false
    end)

    triggerServerEvent("ui.spawnPlayer", resourceRoot, login, pos)
    removeEventHandler("onClientRestore", root, restore)
end

-- triggers

addEvent("ui.showPanel", true)
addEventHandler("ui.showPanel", resourceRoot, function(login, spawns)
    if(ui.animate)then return end

    ui.animate=true
    animate(ui.mainAlpha, 0, "Linear", 500, function(a)
        ui.mainAlpha=a

        exports.px_scroll:dxScrollSetAlpha(ui.scroll, a)
    end, function()
        scroll:dxDestroyScroll(ui.scroll)
        ui.scroll=false

        for i,v in pairs(ui.edits) do
            edits:dxDestroyEdit(v)
        end
        ui.edits={}
    
        for i,v in pairs(ui.btns) do
            btns:destroyButton(v)
        end
        ui.btns={}
    
        ui.option="WYBÓR SPAWNU"
        ui.login=login
    
        ui.spawns={}
        for i,v in pairs(spawns) do
            ui.spawns[#ui.spawns+1]=v
        end
        for i,v in pairs(ui.spawnsAll) do
            ui.spawns[#ui.spawns+1]=v
        end
        ui.pos=ui.spawns[1].pos
        ui.newPos=ui.spawns[1].pos

        ui.spawnScroll=scroll:dxCreateScroll(1900/zoom, 86/zoom, 4, 200/zoom, 0, 8, ui.spawns, 920/zoom, 0)
        animate(ui.options[ui.option].a2, 255, "Linear", 500, function(a)
            ui.options[ui.option].a2=a
            scroll:dxScrollSetAlpha(ui.spawnScroll, a)
        end, function()
            ui.animate=false
        end)
    end)
end)

-- create login

addEvent("px_auth->responseBan", true)
addEventHandler("px_auth->responseBan", resourceRoot, function(status)
    ui.banStatus = status;
    ui.create()
end)

if(not getElementData(localPlayer, "user:uid"))then
    triggerServerEvent("px_auth->checkBan", resourceRoot)
    --ui.create()
end
