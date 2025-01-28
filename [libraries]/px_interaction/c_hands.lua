--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local blur=exports.blur
local buttons=exports.px_buttons
local edit=exports.px_editbox
local noti=exports.px_noti

local assets={}
assets.list={
    texs={
        "textures/hands/header_icon.png",
        "textures/hands/bg_name.png",
        "textures/hands/hands.png",
        "textures/hands/effect.png",
        "textures/hands/spacebar.png",
        "textures/hands/bg.png",
    },

    fonts={
        {"Medium", 22},
        {"Medium", 20},
        {"Regular", 13},
        {"Medium", 25},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
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

    for i,v in pairs(assets.fonts) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.fonts={}
end

-- variables

h={}

h.edits={}
h.buttons={}

h.dataName="interaction:hands"

h.window=1

-- functions

h.onRender=function()
    --h.info.myHand=h.info.myHand+0.01

    blur:dxDrawBlur(0, 0, sw, sh, tocolor(100, 100, 100, 255), true)
    dxDrawRectangle(0, 0, sw, sh, tocolor(30, 30, 30, 200), true)

    -- center top
    dxDrawText("SIŁOWANIE", 0, 85/zoom, sw, 0, tocolor(200, 200, 200, 255), 1, assets.fonts[4], "center", "top", false, false, true)
    dxDrawImage(sw/2-dxGetTextWidth("SIŁOWANIE", 1, assets.fonts[4])/2-24/zoom-10/zoom, 95/zoom, 24/zoom, 24/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, 255), true)
    dxDrawRectangle(sw/2-409/2/zoom, 129/zoom, 409/zoom, 1, tocolor(85, 85, 85, 255), true)
    dxDrawText("#c2c2c2W #2193b0siłowaniu #c2c2c2możesz konkurować z innymi graczami o to, kto\njest silniejszy. Aby popchnąć rękę przeciwnika, naciskaj\ngwałtownie spację. Kto pierwszy dotknie podłoża, przegrywa.", 0, 139/zoom, sw, 0, tocolor(200, 200, 200, 255), 1, assets.fonts[3], "center", "top", false, false, true, true)

    if(h.window == 1)then
        local data=getElementData(localPlayer, h.dataName)
        if(not data)then
            return h.destroy()
        end

        if(not data.target or (data.target and not isElement(data.target)))then
            return h.destroy()
        end

        local targetData=getElementData(data.target, h.dataName)
        if(not targetData)then
            return
        end

        -- center
        dxDrawImage(sw/2-326/2/zoom, sh/2-719/2/zoom, 326/zoom, 1080/zoom, assets.textures[3], data.myHand, 0, 0, tocolor(255, 255, 255, 255), true)

        -- left
        dxDrawImage(sw/2-850/zoom, sh/2-88/zoom, 371/zoom, 88/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, 255), true)
        dxDrawText(getPlayerName(localPlayer), sw/2-850/zoom+26/zoom, sh/2-88/zoom-33/zoom, 371/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "left", "center", false, false, true)
        dxDrawText("#42e06b$ #dedede"..data.money, sw/2-850/zoom+26/zoom, sh/2-88/zoom+33/zoom, 371/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[2], "left", "center", false, false, true, true)
        dxDrawText(data.accept and "#42e06bZaakceptowano" or "#e04242Niezaakceptowano", sw/2-850/zoom, sh/2-88/zoom+92/zoom, 371/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[3], "left", "top", false, false, true, true)

        -- right
        dxDrawImage(sw/2+850/zoom-371/zoom, sh/2-88/zoom, 371/zoom, 88/zoom, assets.textures[2], 180, 0, 0, tocolor(255, 255, 255, 255), true)
        dxDrawText(getPlayerName(data.target), sw/2+850/zoom-371/zoom, sh/2-88/zoom-33/zoom, sw/2+850/zoom-371/zoom+371/zoom-26/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "right", "center", false, false, true)
        dxDrawText("#42e06b$ #dedede"..targetData.money, sw/2+850/zoom-371/zoom, sh/2-88/zoom+33/zoom, sw/2+850/zoom-371/zoom+371/zoom-26/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[2], "right", "center", false, false, true, true)
        dxDrawText(targetData.accept and "#42e06bZaakceptowano" or "#e04242Niezaakceptowano", sw/2-850/zoom, sh/2-88/zoom+92/zoom, sw/2+850/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[3], "right", "top", false, false, true, true)

        -- center bottom
        dxDrawImage(sw/2-2007/2/zoom, sh-398/zoom, 2007/zoom, 398/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, 255), true)

        if(not h.edits[1])then
            h.edits[1]=edit:dxCreateEdit("Twój zakład", sw/2-308/2/zoom, sh-31/zoom-134/zoom, 308/zoom, 31/zoom, false, 13/zoom, 255, true, false, ":px_interaction/textures/hands/edit_icon.png", false, true)
        else
            local editText=edit:dxGetEditText(h.edits[1])
            editText=#editText < 1 and 0 or editText
            editText=tonumber(editText)
            editText=editText < 0 and 0 or editText

            if(editText ~= data.money)then
                data.money=editText
                data.accept=false
                setElementData(localPlayer, h.dataName, data)
            end
        end

        if(not h.buttons[1])then
            h.buttons[1]=buttons:createButton(sw/2-148/zoom-10/zoom, sh-38/zoom-68/zoom, 148/zoom, 40/zoom, "ANULUJ", 255, 10/zoom, false, true, ":px_interaction/textures/hands/cancel_button.png", {132,39,39})
        end

        if(not h.buttons[2])then
            h.buttons[2]=buttons:createButton(sw/2+10/zoom, sh-38/zoom-68/zoom, 148/zoom, 40/zoom, "AKCEPTUJ", 255, 10/zoom, false, true, ":px_interaction/textures/hands/accept_button.png")
        end
        
        onClick(sw/2-148/zoom-10/zoom, sh-38/zoom-68/zoom, 148/zoom, 40/zoom, function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("hands.cancelOffer", resourceRoot, data.target)
            h.destroy()
        end)

        onClick(sw/2+10/zoom, sh-38/zoom-68/zoom, 148/zoom, 40/zoom, function()
            if(SPAM.getSpam())then return end

            if(data.accept)then
                data.accept=false
                setElementData(localPlayer, h.dataName, data)
            else
                if(getPlayerMoney(localPlayer) >= tonumber(data.money))then
                    if(data.money <= 100)then
                        data.accept=true
                        setElementData(localPlayer, h.dataName, data)

                        if(data.accept and targetData.accept)then
                            h.window=2
            
                            for i,v in pairs(h.edits) do
                                edit:dxDestroyEdit(v)
                            end
                            h.edits={}
                        
                            for i,v in pairs(h.buttons) do
                                buttons:destroyButton(v)
                            end
                            h.buttons={}
            
                            triggerServerEvent("hands.acceptOffer", resourceRoot, data.target)
            
                            addEventHandler("onClientKey", root, h.key)
                        end
                    else
                        noti:noti("Kwota nie może być większa niż 100$!", client, "error")
                    end
                else
                    noti:noti("Nie posiadasz takich funduszy.", "error")
                end
            end
        end)
    elseif(h.window == 2)then
        local data=getElementData(localPlayer, h.dataName)
        if(not data)then
            return h.destroy()
        end

        if(not data.target or (data.target and not isElement(data.target)))then
            return h.destroy()
        end

        local targetData=getElementData(data.target, h.dataName)
        if(not targetData)then
            return
        end

        local one=data.started == localPlayer and data or targetData
        local two=data.started ~= localPlayer and data or targetData

        -- left
        dxDrawImage(sw/2-1160/zoom, sh/2-88/zoom, 371/zoom, 88/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, 255), true)
        dxDrawText(getPlayerName(two.target), sw/2-1160/zoom+26/zoom, sh/2-88/zoom-33/zoom, 371/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "left", "center", false, false, true)
        dxDrawText("#42e06b$ #dedede"..one.money, sw/2-1160/zoom+26/zoom, sh/2-88/zoom+33/zoom, 371/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[2], "left", "center", false, false, true, true)

        -- right
        dxDrawImage(sw/2+1160/zoom-371/zoom, sh/2-88/zoom, 371/zoom, 88/zoom, assets.textures[2], 180, 0, 0, tocolor(255, 255, 255, 255), true)
        dxDrawText(getPlayerName(one.target), sw/2+1160/zoom-371/zoom, sh/2-88/zoom-33/zoom, sw/2+1160/zoom-371/zoom+371/zoom-26/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "right", "center", false, false, true)
        dxDrawText("#42e06b$ #dedede"..two.money, sw/2+1160/zoom-371/zoom, sh/2-88/zoom+33/zoom, sw/2+1160/zoom-371/zoom+371/zoom-26/zoom, 88/zoom+sh/2-88/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[2], "right", "center", false, false, true, true)
    
        -- center bottom
        dxDrawImage(sw/2-140/2/zoom, sh-56/zoom-50/zoom, 140/zoom, 56/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, 255), true)

        -- left effect
        dxDrawImage(sw/2-545/zoom-150/zoom, sh-500/zoom, 545/zoom, 347/zoom, assets.textures[4], 0, 0, 0, tocolor(231, 44, 44, 255), true)
        dxDrawImage(sw/2+150/zoom, sh-500/zoom, 545/zoom, 347/zoom, assets.textures[4], 0, 0, 0, tocolor(86, 195, 101, 255), true)

        -- center
        local rot=180*((one.hand-two.hand)/100)
        dxDrawImage(sw/2-326/2/zoom, sh/2-719/2/zoom, 326/zoom, 1080/zoom, assets.textures[3], -90+rot, 0, 0, tocolor(255, 255, 255, 255), true)
        
        if(data.started == localPlayer and rot > 180)then
            if(SPAM.getSpam())then return end

            -- wygral
            local tbl={lose={player=one.target}, win={money=two.money,player=localPlayer}}
            triggerServerEvent("hands.win", resourceRoot, tbl)

            h.destroy()

            setElementData(localPlayer, h.dataName, false)
        elseif(data.started == localPlayer and rot < 0)then
            if(SPAM.getSpam())then return end

            -- przegral
            local tbl={lose={player=localPlayer}, win={money=one.money,player=one.target}}
            triggerServerEvent("hands.win", resourceRoot, tbl)

            h.destroy()

            setElementData(localPlayer, h.dataName, false)
        end
    end
end

h.key=function(key,press)
    if(press and key == "space")then
        local data=getElementData(localPlayer, h.dataName)
        data.hand=data.hand+1
        setElementData(localPlayer, h.dataName, data)
    end
end

h.sendOffer=function(player)
    if(getElementData(player, h.dataName))then return end
    if(getElementData(localPlayer, h.dataName))then return end

    triggerServerEvent("hands.send.offer", resourceRoot, player)
end

h.create=function(player, x)
    if(getElementData(localPlayer, "user:gui_showed"))then return end
    if(getElementData(player, "user:gui_showed"))then return end

    blur=exports.blur
    buttons=exports.px_buttons
    edit=exports.px_editbox
    noti=exports.px_noti

    h.window=1

    local hand=x and 50 or 0
    local info={
        hand=hand,
        money=0,

        target=player,

        accept=false,
        started=x and localPlayer or player
    }

    setElementData(localPlayer, h.dataName, info)

    assets.create()

    addEventHandler("onClientRender", root, h.onRender)

    showCursor(true)

    setElementData(localPlayer, "user:gui_showed", "hands", false)
end

h.destroy=function()
    removeEventHandler("onClientRender", root, h.onRender)
    removeEventHandler("onClientKey", root, h.key)

    assets.destroy()

    showCursor(false)

    for i,v in pairs(h.edits) do
        edit:dxDestroyEdit(v)
    end
    h.edits={}

    for i,v in pairs(h.buttons) do
        buttons:destroyButton(v)
    end
    h.buttons={}

    setElementData(localPlayer, h.dataName, false)

    setElementData(localPlayer, "user:gui_showed", false, false)
end

addEvent("hands.send.offer", true)
addEventHandler("hands.send.offer", resourceRoot, function(target, x)
    if(target and isElement(target))then
        h.create(target, x)
    end
end)

addEvent("hands.cancelOffer", true)
addEventHandler("hands.cancelOffer", resourceRoot, function()
    h.destroy()
end)

addEvent("hands.win", true)
addEventHandler("hands.win", resourceRoot, function()
    h.destroy()
    setElementData(localPlayer, h.dataName, false)
end)

addEvent("hands.acceptOffer", true)
addEventHandler("hands.acceptOffer", resourceRoot, function(target)
    if(target and isElement(target))then
        for i,v in pairs(h.edits) do
            edit:dxDestroyEdit(v)
        end
        h.edits={}
    
        for i,v in pairs(h.buttons) do
            buttons:destroyButton(v)
        end
        h.buttons={}

        h.window=2

        addEventHandler("onClientKey", root, h.key)
    end
end)

setElementData(localPlayer, h.dataName, false)

-- offers

h.offerPlayer=false
h.offerTimer=false
h.offerKey=function(button,press)
    if(getElementData(localPlayer, "user:gui_showed"))then return end

    if(press)then
        if(SPAM.getSpam())then return end

        if(button == "k")then
            exports.px_noti:noti("Pomyślnie przyjęto ofertę siłowania.", "success")
            triggerServerEvent("start.hands", resourceRoot, h.offerPlayer)

            h.offerPlayer=false
            killTimer(h.offerTimer)
            h.offerTimer=false
    
            removeEventHandler("onClientKey", root, h.offerKey)
        elseif(button == "x")then
            exports.px_noti:noti("Pomyślnie odrzucono ofertę siłowania.", "success")
            triggerServerEvent("start.hands", resourceRoot, h.offerPlayer, true)

            h.offerPlayer=false
            killTimer(h.offerTimer)
            h.offerTimer=false
    
            removeEventHandler("onClientKey", root, h.offerKey)
        end
    end
end

addEvent("hands.offer", true)
addEventHandler("hands.offer", resourceRoot, function(player)
    if(getElementData(localPlayer, "user:gui_showed"))then return end
    if(getElementData(player, "user:gui_showed"))then return end
    if(h.offerPlayer or h.offerTimer)then return end
    if(SPAM.getSpam())then return end

    addEventHandler("onClientKey", root, h.offerKey)
    h.offerPlayer=player

    h.offerTimer=setTimer(function()
        noti:noti("Oferta handlu wygasła.", "info")

        h.offerPlayer=false
        h.offerTimer=false

        removeEventHandler("onClientKey", root, h.offerKey)

        triggerServerEvent("start.hands", resourceRoot, h.offerPlayer, true)
    end, (1000*30), 1)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == "hands")then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)