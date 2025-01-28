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
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

ui.updateRT=function(updateButtons)
    local db=ui.info
    if(not db.vehs)then return end
    
    ui.clicks={}

    local y=(-ui.scrollPosition or 0)
    local db=ui.info
    local pY=y
    local p={ui.pos[#ui.pos][2][1], ui.pos[#ui.pos][2][2]}

    dxSetRenderTarget(ui.rt, true)
    dxSetBlendMode("modulate_add")
        for i,v in pairs(db.vehs) do
            dxDrawImage(0, pY, 684/zoom, 48/zoom, assets.textures[4])
            dxDrawRectangle(0, pY+48/zoom, 684/zoom, 1, tocolor(80,80,80))

            dxDrawImage(18/zoom, pY+(48-11)/2/zoom, 24/zoom, 11/zoom, assets.textures[5])
            dxDrawText(getVehicleNameFromModel(v.model), 63/zoom, pY, 684/zoom, pY+48/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "center")
            dxDrawText(v.id, 250/zoom, pY, 684/zoom, pY+48/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "center")
            dxDrawText(v.distance.."km", 443/zoom, pY, 684/zoom, pY+48/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "center")
            dxDrawImage(689/zoom-36/zoom, pY+(48-17)/2/zoom, 17/zoom, 17/zoom, ui.selected ~= i and assets.textures[6] or assets.textures[7])
            ui.clicks[#ui.clicks+1]={689/zoom-36/zoom, pY+(48-17)/2/zoom, 17/zoom, 17/zoom, function()
                if(ui.selected == i)then
                    ui.selected=false
                else
                    ui.selected=i
                end

                for i,v in pairs(ui.btns) do
                    btns:destroyButton(v)
                end
                ui.btns={}

                ui.updateRT()
            end}

            pY=pY+49/zoom+1

            if(ui.selected == i)then
                if(db.org)then
                    dxDrawImage(0, pY, 684/zoom, 27/zoom, assets.textures[8])
                    dxDrawText("Udostępnij organizacji", 19/zoom, pY, 0, 27/zoom+pY, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "center")

                    pY=pY+28/zoom

                    dxDrawImage(0, pY, 684/zoom, 49/zoom, assets.textures[9])
                    dxDrawRectangle(0, pY+49/zoom, 684/zoom, 1, tocolor(80,80,80))
                    dxDrawText(db.org, 19/zoom, pY, 684/zoom, 49/zoom+pY, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "center")
                    if(not ui.btns[i])then
                        ui.btns[i]=createButton(p[1]+559/zoom, p[2]+pY+(49-27)/2/zoom, 106/zoom, 27/zoom, v.organization == db.org and "USUŃ" or "UDOSTĘPNIJ", a, 10, false, false, false, v.organization == db.org and {164,51,51} or false)
                        ui.clicks[#ui.clicks+1]={559/zoom, pY+(49-27)/2/zoom, 106/zoom, 27/zoom, function()
                            if(SPAM.getSpam())then return end

                            triggerServerEvent("set.organization", resourceRoot, v.id, v.organization ~= db.org and db.org)
                        end}
                    else
                        buttonSetPosition(i, {p[1]+559/zoom, p[2]+pY+(49-27)/2/zoom, 106/zoom, 27/zoom})
                    end

                    pY=pY+49/zoom
                end
                if(db.friends)then
                    dxDrawImage(0, pY, 684/zoom, 27/zoom, assets.textures[8])
                    dxDrawText("Udostępnij znajomym", 19/zoom, pY, 0, 27/zoom+pY, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "center")

                    pY=pY+28/zoom

                    local k=0
                    for _,vv in pairs(db.friends) do
                        k=k+1
                        
                        local is=false
                        for i,v in pairs(v.keys) do
                            if(tonumber(v.uid) == tonumber(vv.id))then
                                is=true
                                break
                            end
                        end

                        dxDrawImage(0, pY, 684/zoom, 49/zoom, assets.textures[9])
                        dxDrawRectangle(0, pY+49/zoom, 684/zoom, 1, tocolor(80,80,80))

                        local av=avatars:getPlayerAvatar(vv.login)
                        if(av)then
                            dxDrawImage(23/zoom, pY+(49-21)/2/zoom, 21/zoom, 21/zoom, av)
                        end

                        dxDrawText(vv.login, 63/zoom, pY, 684/zoom, 49/zoom+pY, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "center")
                        if(not ui.btns[i+k])then
                            ui.btns[i+k]=createButton(p[1]+559/zoom, p[2]+pY+(49-27)/2/zoom, 106/zoom, 27/zoom, is and "USUŃ" or "UDOSTĘPNIJ", a, 10, false, false, false, is and {164,51,51} or false)
                        else
                            buttonSetPosition(i+k, {p[1]+559/zoom, p[2]+pY+(49-27)/2/zoom, 106/zoom, 27/zoom})
                        end

                        ui.clicks[#ui.clicks+1]={559/zoom, pY+(49-27)/2/zoom, 106/zoom, 27/zoom, function()
                            if(SPAM.getSpam())then return end

                            triggerServerEvent("set.keys", resourceRoot, v.id, is and "remove" or "add",  vv.id, vv.login)
                        end}
    
                        pY=pY+49/zoom
                    end
                end
            end
        end
    dxSetBlendMode("blend")
    dxSetRenderTarget()

    scroll:dxScrollUpdateRTSize(ui.scroll, (pY-y))
end

ui.onRender=function()
    for i,v in pairs(ui.pos) do
        if(v[1] == "image")then
            dxDrawImage(v[2][1], v[2][2], v[2][3], v[2][4], assets.textures[v[3]], 0, 0, 0, tocolor(255, 255, 255, 255), false)

            if(v[4])then
                onClick(v[2][1], v[2][2], v[2][3], v[2][4], v[4])
            end
        elseif(v[1] == "blur")then
            blur:dxDrawBlur(v[2][1], v[2][2], v[2][3], v[2][4], tocolor(255, 255, 255, 255))
        elseif(v[1] == "text")then
            dxDrawText(v[2], v[3][1], v[3][2], v[3][3], v[3][4], tocolor(200, 200, 200, 255), 1, assets.fonts[v[4]], v[5], v[6])
        elseif(v[1] == "rec")then
            dxDrawRectangle(v[2][1], v[2][2], v[2][3], v[2][4], tocolor(v[3][1], v[3][2], v[3][3], 255))
        elseif(v[1] == "rt")then
            dxDrawImage(v[2][1], v[2][2], v[2][3], v[2][4], ui.rt, 0, 0, 0, tocolor(255, 255, 255, 255))
        end
    end

    local scrollPos=scroll:dxScrollGetRTPosition(ui.scroll) or 0
    if(ui.scrollPosition ~= scrollPos)then
        ui.scrollPosition=scrollPos
        ui.updateRT(true)
    end

    for i,v in pairs(ui.clicks) do
        local p={ui.pos[#ui.pos][2][1], ui.pos[#ui.pos][2][2]}
        onClick(p[1]+v[1], p[2]+v[2], v[3], v[4], v[5])
    end
end

addEvent("open.interface", true)
addEventHandler("open.interface", resourceRoot, function(org, friends, vehs)
    noti=exports.px_noti
    blur=exports.blur
    btns=exports.px_buttons
    scroll=exports.px_scroll
    avatars=exports.px_avatars

    ui.info={org=org,friends=friends,vehs=vehs}
    ui.rt=dxCreateRenderTarget(ui.pos[#ui.pos][2][3], ui.pos[#ui.pos][2][4], true)

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)

    showCursor(true)

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    ui.scroll=scroll:dxCreateScroll(ui.pos[#ui.pos][2][1]+ui.pos[#ui.pos][2][3], ui.pos[#ui.pos][2][2], 4, 499/zoom, 0, 1, false, 499/zoom, 255, 0, false, true, 0, 499/zoom, 150)

    ui.updateRT()
end)

addEvent("update.interface", true)
addEventHandler("update.interface", resourceRoot, function(org,friends,vehs)
    ui.info={org=org,friends=friends,vehs=vehs}

    for i,v in pairs(ui.btns) do
        btns:destroyButton(v)
    end
    ui.btns={}

    ui.updateRT()
end)