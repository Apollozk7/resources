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

-- global variables

local sw, sh = guiGetScreenSize()
local baseX = 1920
local zoom = 1
local minZoom = 2

if sw < baseX then
    zoom = math.min(minZoom, baseX/sw)
end

-- exports

local blur=exports.blur
local editbox=exports.px_editbox
local buttons=exports.px_buttons
local avatars=exports.px_avatars
local noti=exports.px_noti

-- assets

local assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/logo.png",
        "textures/close.png",

        "textures/row.png",

        "textures/podpis.png",

        "textures/info_icon.png",
        "textures/arrow.png",
        "textures/close.png",

        "textures/button.png",
        "textures/button_hover.png",
        "textures/button_hover_red.png",

        "textures/enter.png",
        "textures/key.png",
        "textures/coin.png",
        "textures/logout.png",
    },

    fonts={
        {"Regular", 13},
        {"Regular", 12},
        {"Regular", 16},
        {"Medium", 12},
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
    if(assets.textures and #assets.textures > 0)then
        for i,v in pairs(assets.textures) do
            if(v and isElement(v))then
                destroyElement(v)
            end
        end
        assets.textures={}
    end

    if(assets.fonts and #assets.fonts > 0)then
        for i,v in pairs(assets.fonts) do
            if(v and isElement(v))then
                destroyElement(v)
            end
        end
        assets.fonts={}
    end
end

--

local ui={}

ui.edits={}
ui.btns={}

ui.alpha=0
ui.podpisTarget=false
ui.podpis=false
ui.prvX,ui.prvY=0,0
ui.info=false
ui.lastTrigger=0

ui.page=1
ui.tick=getTickCount()
ui.lastPos=false

ui.centerAlpha=0

ui.menus={}

ui.buttons={
    {"Wejdź", hoverAlpha=0, alpha=255, fnc=function()
        if((getTickCount()-ui.lastTrigger) > 5000)then
            ui.lastTrigger=getTickCount()

            triggerServerEvent("house.teleport", resourceRoot, ui.info)

            ui.destroy()
        else
            noti:noti("Przed następną akcją odczekaj "..math.floor((6000-(getTickCount()-ui.lastTrigger))/1000).."s.", "error")
        end
    end},
    {"Zamknij", hoverAlpha=0, alpha=255, fnc=function() 
        if((getTickCount()-ui.lastTrigger) > 5000)then
            ui.lastTrigger=getTickCount()

            triggerServerEvent("house.castle", resourceRoot, ui.info)
        else
            noti:noti("Przed następną akcją odczekaj "..math.floor((6000-(getTickCount()-ui.lastTrigger))/1000).."s.", "error")
        end
    end},
    {"Sprzedaj", hoverAlpha=0, alpha=255, fnc=function() 
        if((getTickCount()-ui.lastTrigger) > 5000 and ui.info.type ~= "Baza organizacji")then
            ui.lastTrigger=getTickCount()

            triggerServerEvent("house.out", resourceRoot, ui.info, 2, ui.levels[ui.info.level].slots)

            ui.destroy()

            ui.reloadBlips()
        else
            noti:noti("Przed następną akcją odczekaj "..math.floor((6000-(getTickCount()-ui.lastTrigger))/1000).."s.", "error")
        end
    end},
    {"Wyprowadź", hoverAlpha=0, alpha=255, fnc=function() 
        if((getTickCount()-ui.lastTrigger) > 5000 and ui.info.type ~= "Baza organizacji")then
            ui.lastTrigger=getTickCount()

            triggerServerEvent("house.out", resourceRoot, ui.info, 1)

            ui.destroy()
        else
            noti:noti("Przed następną akcją odczekaj "..math.floor((6000-(getTickCount()-ui.lastTrigger))/1000).."s.", "error")
        end
    end},
}

ui.levels={
    [1]={
        cost=5000,
        info={
            "Maksymalnie 1 lokator",
            "Dodatkowy slot pojazdu",
        },
        locators=1,
        slots=1
    },

    [2]={
        cost=10000,
        info={
            "Maksymalnie 2 lokatorów",
            "Dodatkowe 2 sloty pojazdu",
        },
        locators=2,
        slots=2,
    },
}

ui.onRender=function()
    if(ui.info.panelID == 1)then
        local cx, cy=getCursorPosition()
        cx=(cx or 0)*sw
        cy=(cy or 0)*sh

        local v=ui.info

        -- window
        blur:dxDrawBlur(sw/2-695/2/zoom, sh/2-587/2/zoom, 695/zoom, 587/zoom, tocolor(255, 255, 255, ui.alpha))
        dxDrawImage(sw/2-695/2/zoom, sh/2-587/2/zoom, 695/zoom, 587/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

        -- header
        dxDrawImage(sw/2-654/2/zoom+5/zoom, sh/2-587/2/zoom+(82-44)/2/zoom, 209/zoom, 44/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
        dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom, 654/zoom, 1, tocolor(85, 85, 85, ui.alpha))

        -- info
        dxDrawText("Główne informacje", sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+13/zoom, 0, 0, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "left", "top")
        dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom, 311/zoom, 1, tocolor(85, 85, 85, ui.alpha))
        
        local info_1={
            {"Rodzaj", v.type},
            {"ID", v.id},
            {"Poprzedni właściciel", v.lastOwner and v.lastOwnerName or "brak"},
            {"Garaż", v.garage and "tak" or "nie"},
            {"Poziom", v.level},
        }
        for i,v in pairs(info_1) do
            local sY=(43/zoom)*(i-1)
            dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom, 42/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawText(v[1], sw/2-654/2/zoom+12/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom, 42/zoom+sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "left", "center")
            dxDrawText(v[2], sw/2-654/2/zoom+12/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom+sw/2-654/2/zoom-12/zoom, 42/zoom+sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "right", "center")
        end

        -- finanse
        dxDrawText("Informacje finansowe", sw/2-654/2/zoom+341/zoom, sh/2-587/2/zoom+82/zoom+13/zoom, 0, 0, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "left", "top")
        dxDrawRectangle(sw/2-654/2/zoom+341/zoom, sh/2-587/2/zoom+82/zoom+42/zoom, 311/zoom, 1, tocolor(85, 85, 85, ui.alpha))
        
        local info_2={
            {"Cena za dobę", "$ "..formatMoney(v.cost)},
            {"Długość wynajmu", "MAX 30 dni"}
        }
        for i,v in pairs(info_2) do
            local sY=(43/zoom)*(i-1)
            dxDrawImage(sw/2-654/2/zoom+341/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom, 42/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawText(v[1], sw/2-654/2/zoom+341/zoom+12/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom, 42/zoom+sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "left", "center")
            dxDrawText(v[2], sw/2-654/2/zoom+341/zoom+12/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom+sw/2-654/2/zoom+341/zoom-12/zoom, 42/zoom+sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "right", "center")
        end

        -- wynajem
        dxDrawText("Wynajem posiadłości", sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+287/zoom, 0, 0, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "left", "top")
        dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+316/zoom, 654/zoom, 1, tocolor(85, 85, 85, ui.alpha))
        dxDrawText("Na ile dni chcesz wynająć posiadłość?", sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+320/zoom, 0, 0, tocolor(175, 175, 175, ui.alpha), 1, assets.fonts[2], "left", "top")

        -- podpis
        dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+316/zoom+95/zoom, 312/zoom, 66/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
        if(not ui.podpis)then
            dxDrawText("Twój podpis", sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+316/zoom+95/zoom+10/zoom, 0, 0, tocolor(100,100,100,ui.alpha), 1, assets.fonts[2], "left", "top")
        end

        if(isCursorShowing() and getKeyState("mouse1") and isMouseInPosition(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+316/zoom+95/zoom, 312/zoom, 66/zoom))then
            local px,py=sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+316/zoom+95/zoom
            dxSetRenderTarget(ui.podpisTarget)
                local finalX1, finalY1 = ui.prvX - px, ui.prvY - py
                local finalX2, finalY2 = cx - px, cy - py
                dxDrawLine(finalX1, finalY1, finalX2, finalY2, black, 2)
                ui.podpis=true
            dxSetRenderTarget()
        end
        
        dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+316/zoom+95/zoom, 312/zoom, 66/zoom, ui.podpisTarget, 0, 0, 0, tocolor(255,255,255,ui.alpha))

        -- prawo
        local text=editbox:dxGetEditText(ui.edits[1])
        local cost=#text < 1 and 0 or text
        cost=tonumber(cost) > 30 and 30 or cost
        dxDrawText("Całkowity koszt", sw/2-654/2/zoom+339/zoom, sh/2-587/2/zoom+82/zoom+320/zoom, 0, 0, tocolor(175, 175, 175, ui.alpha), 1, assets.fonts[2], "left", "top")
        dxDrawText("Dzienna opłata", sw/2-654/2/zoom+339/zoom+200/zoom, sh/2-587/2/zoom+82/zoom+320/zoom, 0, 0, tocolor(175, 175, 175, ui.alpha), 1, assets.fonts[2], "left", "top")
        dxDrawText("#50cb65$ #fffcfc"..formatMoney(cost*v.cost), sw/2-654/2/zoom+339/zoom, sh/2-587/2/zoom+82/zoom+320/zoom+22/zoom, 0, 0, tocolor(175, 175, 175, ui.alpha), 1, assets.fonts[3], "left", "top", false, false, false, true)
        dxDrawText("#50cb65$ #fffcfc"..formatMoney(v.cost), sw/2-654/2/zoom+339/zoom+200/zoom, sh/2-587/2/zoom+82/zoom+320/zoom+22/zoom, 0, 0, tocolor(175, 175, 175, ui.alpha), 1, assets.fonts[3], "left", "top", false, false, false, true)

        -- click
        onClick(sw/2-695/2/zoom+361/zoom, sh/2-587/2/zoom+587/zoom-68/zoom, 147/zoom, 38/zoom, function()
            ui.destroy()
        end)

        onClick(sw/2-695/2/zoom+525/zoom, sh/2-587/2/zoom+587/zoom-68/zoom, 147/zoom, 38/zoom, function()
            if(SPAM.getSpam())then return end

            local text=editbox:dxGetEditText(ui.edits[1])
            local cost=#text < 1 and 0 or text
            local days=tonumber(cost) > 30 and 30 or tonumber(cost)
            days=math.floor(days)
            if(days > 0)then                
                triggerServerEvent("buy.house", resourceRoot, days, ui.info, ui.levels[ui.info.level].slots)
                ui.destroy()
            end
        end)

        -- update pos
        ui.prvX,ui.prvY = cx, cy
    elseif(ui.info.panelID == 2)then
        -- window
        blur:dxDrawBlur(sw/2-695/2/zoom, sh/2-587/2/zoom, 695/zoom, 587/zoom, tocolor(255, 255, 255, ui.alpha))
        dxDrawImage(sw/2-695/2/zoom, sh/2-587/2/zoom, 695/zoom, 587/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

        -- header
        dxDrawImage(sw/2-654/2/zoom+5/zoom, sh/2-587/2/zoom+(82-44)/2/zoom, 209/zoom, 44/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
        dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom, 654/zoom, 1, tocolor(85, 85, 85, ui.alpha))
        dxDrawImage(sw/2-654/2/zoom+654/zoom-10/zoom, sh/2-587/2/zoom+(82-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

        -- menus
        local lastW=0
        for i,v in pairs(ui.menus) do
            local w=dxGetTextWidth(v.name, 1, assets.fonts[1])
            local x,y,h=sw/2-695/2/zoom+215/zoom+lastW, sh/2-587/2/zoom+(82-30)/2/zoom, 30/zoom

            if(ui.page == i)then
                dxDrawText(v.name, x,y,w+x,y+h, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[4], "center", "center")
            else
                dxDrawText(v.name, x,y,w+x,y+h, tocolor(150, 150, 150, ui.alpha), 1, assets.fonts[4], "center", "center")
            end

            lastW=lastW+w+30/zoom

            if(not ui.lastPos)then
                ui.lastPos={x,w}
            end

            onClick(x,y,w,h,function()
                if(ui.animate)then return end

                ui.animate=true
                animate(ui.lastPos[1], x, "Linear", 400, function(a)
                    ui.lastPos[1]=a
                end)

                animate(ui.lastPos[2], w, "Linear", 400, function(a)
                    ui.lastPos[2]=a
                end)

                animate(ui.centerAlpha, 0, "Linear", 200, function(a)
                    ui.centerAlpha=a
                    
                    for i,v in pairs(ui.btns) do
                        buttons:buttonSetAlpha(v, a)
                    end

                    for i,v in pairs(ui.edits) do
                        editbox:dxSetEditAlpha(v, a)
                    end
                end, function()
                    for i,v in pairs(ui.btns) do
                        buttons:destroyButton(v)
                        ui.btns[i]=nil
                    end
                
                    for i,v in pairs(ui.edits) do
                        editbox:dxDestroyEdit(v)
                        ui.edits[i]=nil
                    end

                    ui.page=i

                    animate(ui.centerAlpha, 255, "Linear", 200, function(a)
                        ui.centerAlpha=a

                        for i,v in pairs(ui.btns) do
                            buttons:buttonSetAlpha(v, a)
                        end

                        for i,v in pairs(ui.edits) do
                            editbox:dxSetEditAlpha(v, a)
                        end
                    end, function()
                        ui.animate=false
                    end)
                end)
            end)
        end

        dxDrawRectangle(ui.lastPos[1]+5/zoom, sh/2-587/2/zoom+(82-30)/2/zoom+30/zoom, ui.lastPos[2]-10/zoom, 1, tocolor(53, 114, 128, ui.alpha))

        if(ui.page == 1)then
            local v=ui.info
            -- info
            dxDrawText("Główne informacje", sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+13/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
            dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom, 311/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
        
            local info_1={
                {"Rodzaj", v.type},
                {"ID", v.id},
                {"Właściciel", v.ownerName},
                {"Garaż", v.garage and "tak" or "nie"},
                {"Poziom", v.level},
            }
            for i,v in pairs(info_1) do
                local sY=(43/zoom)*(i-1)
                dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom, 42/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
                dxDrawText(v[1], sw/2-654/2/zoom+12/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom, 42/zoom+sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "center")
                dxDrawText(v[2], sw/2-654/2/zoom+12/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom+sw/2-654/2/zoom-12/zoom, 42/zoom+sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "right", "center")
            end
        
            -- finanse
            dxDrawText("Informacje finansowe", sw/2-654/2/zoom+341/zoom, sh/2-587/2/zoom+82/zoom+13/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
            dxDrawRectangle(sw/2-654/2/zoom+341/zoom, sh/2-587/2/zoom+82/zoom+42/zoom, 311/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
            
            local info_2={
                {"Cena za dobę", "$ "..formatMoney(v.cost)},
                {"Długość wynajmu", string.sub(v.rentDate, 0, #v.rentDate-9)},
                {"Czynsz", "$ "..formatMoney(v.rentCost)}
            }
            for i,v in pairs(info_2) do
                local sY=(43/zoom)*(i-1)
                dxDrawImage(sw/2-654/2/zoom+341/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom, 42/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
                dxDrawText(v[1], sw/2-654/2/zoom+341/zoom+12/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom, 42/zoom+sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "center")
                dxDrawText(v[2], sw/2-654/2/zoom+341/zoom+12/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, 312/zoom+sw/2-654/2/zoom+341/zoom-12/zoom, 42/zoom+sh/2-587/2/zoom+82/zoom+42/zoom+12/zoom+sY, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "right", "center")
            end
        
            -- podstawowe
            dxDrawText("Podstawowe informacje", sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+287/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
            dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+316/zoom, 654/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
        
            -- buttons
            for i,v in pairs(ui.buttons) do
                local sX=(146/zoom+23/zoom)*(i-1)
        
                if(isMouseInPosition(sw/2-654/2/zoom+sX, sh/2-587/2/zoom+82/zoom+337/zoom, 146/zoom, 146/zoom) and not v.animate and v.hoverAlpha < 255)then
                    v.animate=true
                    animate(0, 255, "Linear", 250, function(a)
                        v.hoverAlpha=a
                        v.alpha=255-a
                    end, function()
                        v.animate=false
                    end)
                elseif(v.hoverAlpha and not isMouseInPosition(sw/2-654/2/zoom+sX, sh/2-587/2/zoom+82/zoom+337/zoom, 146/zoom, 146/zoom) and not v.animate and v.hoverAlpha > 0)then
                    v.animate=true
                    animate(255, 0, "Linear", 250, function(a)
                        v.hoverAlpha=a
                        v.alpha=255-a
                    end, function()
                        v.animate=false
                    end)
                end
        
                dxDrawImage(sw/2-654/2/zoom+sX, sh/2-587/2/zoom+82/zoom+337/zoom, 146/zoom, 146/zoom, assets.textures[9], 0, 0, 0, tocolor(255, 255, 255, v.alpha > ui.centerAlpha and ui.centerAlpha or v.alpha))
                dxDrawImage(sw/2-654/2/zoom+sX, sh/2-587/2/zoom+82/zoom+337/zoom, 146/zoom, 146/zoom, i <= 2 and assets.textures[10] or assets.textures[11], 0, 0, 0, tocolor(255, 255, 255, v.hoverAlpha > ui.centerAlpha and ui.centerAlpha or v.hoverAlpha))
        
                local tex=assets.textures[11+i]
                local w,h=dxGetMaterialSize(tex)
                dxDrawImage(sw/2-654/2/zoom+sX+(146-w)/2/zoom, sh/2-587/2/zoom+82/zoom+337/zoom+(146-h)/2/zoom-10/zoom, w/zoom, h/zoom, tex, 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
        
                dxDrawText(v[1], sw/2-654/2/zoom+sX, sh/2-587/2/zoom+82/zoom+337/zoom, 146/zoom+sw/2-654/2/zoom+sX, 146/zoom+sh/2-587/2/zoom+82/zoom+337/zoom+80/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "center", "center")
            
                onClick(sw/2-654/2/zoom+sX, sh/2-587/2/zoom+82/zoom+337/zoom, 146/zoom, 146/zoom, function()
                    if(SPAM.getSpam())then return end

                    v.fnc()
                end)
            end
        elseif(ui.page == 2)then
            if(ui.info.type == "Baza organizacji")then return end

            --
            dxDrawText("Współlokatorzy", sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+13/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
            dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom, 654/zoom, 144/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
            dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom, 654/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
            dxDrawText("Wprowadź czynsz, jaki będzesz pobierał od swioch wspólokatorów.", sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+40/zoom, 0, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[2], "left", "top")
            if(not ui.edits[1])then
                ui.edits[1]=editbox:dxCreateEdit("Kwota", sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+40/zoom+35/zoom, 325/zoom, 30/zoom, false, 11/zoom, ui.centerAlpha, true, false, ":px_houses/textures/edit_icon.png", true)
            end
            dxDrawText("Obecnie czynsz wynosi:", sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+40/zoom+76/zoom, 0, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
            dxDrawText("#50cb65$ #fffcfc"..formatMoney(ui.info.rentCost), sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+40/zoom+100/zoom, 0, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[3], "left", "top", false, false, false, true)
            if(not ui.btns[1])then
                ui.btns[1]=buttons:createButton(sw/2-654/2/zoom+654/zoom-147/zoom-10/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+144/zoom-38/zoom-10/zoom, 147/zoom, 38/zoom, "ZAPISZ", ui.centerAlpha, 9, false, false, ":px_houses/textures/button_accept.png")
            end
            onClick(sw/2-654/2/zoom+654/zoom-147/zoom-10/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+144/zoom-38/zoom-10/zoom, 147/zoom, 38/zoom, function()
                local editText=editbox:dxGetEditText(ui.edits[1]) or ""
                if(SPAM.getSpam())then return end

                if(#editText > 0)then
                    triggerServerEvent("house.setRentCost", resourceRoot, ui.info, editText)
                 end
            end)
        
            --
            local rentDate=ui.info.rentDate
            if(ui.info.access == "rent")then
                for i,v in pairs(ui.info.rents) do
                    if(v.login == getPlayerName(localPlayer))then
                        rentDate=v.rentDate
                        break
                    end
                end
            end

            dxDrawText("Przedłużanie wynajmu", sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+186/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
            dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+186/zoom, 654/zoom, 144/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
            dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+186/zoom, 654/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
            dxDrawText("Wprowadź ilość dni, na które chcesz przedłużyc wynajem.", sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+186/zoom+40/zoom, 0, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[2], "left", "top")
            if(not ui.edits[2])then
                ui.edits[2]=editbox:dxCreateEdit("Ilość dni", sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+186/zoom+40/zoom+35/zoom, 325/zoom, 30/zoom, false, 11/zoom, ui.centerAlpha, true, false, ":px_houses/textures/edit_icon.png", true)
            end
            dxDrawText("Posiadłość jest opłacona do:", sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+186/zoom+40/zoom+76/zoom, 0, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
            dxDrawText(rentDate, sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+186/zoom+40/zoom+100/zoom, 0, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[3], "left", "top", false, false, false, true)
            
            if(not ui.btns[2])then
                ui.btns[2]=buttons:createButton(sw/2-654/2/zoom+654/zoom-147/zoom-10/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+186/zoom+144/zoom-38/zoom-10/zoom, 147/zoom, 38/zoom, "ZAPISZ", ui.centerAlpha, 9, false, false, ":px_houses/textures/button_accept.png")
            else
                onClick(sw/2-654/2/zoom+654/zoom-147/zoom-10/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+186/zoom+144/zoom-38/zoom-10/zoom, 147/zoom, 38/zoom, function()
                    local text=editbox:dxGetEditText(ui.edits[2]) or ""
                    local cost=#text < 1 and 0 or text
                    local days=tonumber(cost) > 3000 and 3000 or tonumber(cost)
                    days=math.floor(days)

                    if(days > 0)then
                        if(SPAM.getSpam())then return end

                        triggerServerEvent("house.payForHouse", resourceRoot, ui.info, days)
                    end
                end)
            end
        
            --
            dxDrawText("Przepisywanie na organizację", sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+371/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
            dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+371/zoom, 654/zoom, 73/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
            dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+371/zoom, 654/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
            dxDrawText("Udostepnij nieruchomość członkom Twojej organizacji.", sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+371/zoom+40/zoom, 0, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[2], "left", "top")
            
            local org=getElementData(localPlayer, "user:organization")
            if(not ui.btns[3])then
                if(ui.info.organization ~= "0")then
                    ui.btns[3]=buttons:createButton(sw/2-654/2/zoom+654/zoom-147/zoom-10/zoom, sh/2-587/2/zoom+42/zoom+371/zoom+144/zoom-38/zoom, 147/zoom, 38/zoom, "WYŁĄCZ", ui.centerAlpha, 9, false, false, ":px_houses/textures/button_cancel.png", {132,39,39})
                else
                    ui.btns[3]=buttons:createButton(sw/2-654/2/zoom+654/zoom-147/zoom-10/zoom, sh/2-587/2/zoom+42/zoom+371/zoom+144/zoom-38/zoom, 147/zoom, 38/zoom, "WŁĄCZ", ui.centerAlpha, 9, false, false, ":px_houses/textures/button_accept.png")
                end
            else
                onClick(sw/2-654/2/zoom+654/zoom-147/zoom-10/zoom, sh/2-587/2/zoom+42/zoom+371/zoom+144/zoom-38/zoom, 147/zoom, 38/zoom, function()
                    if(org)then
                        if(SPAM.getSpam())then return end

                        triggerServerEvent("house.setOrganization", resourceRoot, ui.info, ui.info.organization == "0" and org)
                    else
                        noti:noti("Nie posiadasz żadnej organizacji!", "error")
                    end
                end)
            end
        
            dxDrawText(org or "Nie posiadasz żadnej organizacji.", sw/2-654/2/zoom+10/zoom, sh/2-587/2/zoom+82/zoom+13/zoom+371/zoom+40/zoom+30/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "top")
        elseif(ui.page == 3)then
            if(ui.info.type == "Baza organizacji")then return end

            local rents=ui.info.rents or {}
            local max=8
            local x=0
            for i=1,(1+max) do
                x=x+1
        
                local v=rents[i]
                if(v)then
                    local sY=(49/zoom)*(x-1)
                    local av=avatars:getPlayerAvatar(v.login)
                    local status=getPlayerFromName(v.login) and "teraz" or v.lastlogin
        
                    dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+sY, 654/zoom, 49/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
                    dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+sY+49/zoom-1, 654/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
        
                    dxDrawImage(sw/2-654/2/zoom+17/zoom, sh/2-587/2/zoom+82/zoom+sY+(49-21)/2/zoom, 21/zoom, 21/zoom, av, 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
                    dxDrawText(v.login, sw/2-654/2/zoom+17/zoom+19/zoom+21/zoom, sh/2-587/2/zoom+82/zoom+sY, 21/zoom, sh/2-587/2/zoom+82/zoom+sY+49/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "center")
                
                    dxDrawText("#a7a5a5Ostatnio dostępny: #dcdcdc"..status, sw/2-654/2/zoom+17/zoom+19/zoom+21/zoom+169/zoom, sh/2-587/2/zoom+82/zoom+sY, 21/zoom, sh/2-587/2/zoom+82/zoom+sY+49/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "center", false, false, false, true)
                
                    if(not ui.btns[x])then
                        ui.btns[x]=buttons:createButton(sw/2-654/2/zoom+17/zoom+19/zoom+21/zoom+169/zoom+302/zoom, sh/2-587/2/zoom+82/zoom+sY+(49-27)/2/zoom, 105/zoom, 27/zoom, "USUŃ", ui.centerAlpha, 9, false, false, false, {132,39,39})
                    else
                        onClick(sw/2-654/2/zoom+17/zoom+19/zoom+21/zoom+169/zoom+302/zoom, sh/2-587/2/zoom+82/zoom+sY+(49-27)/2/zoom, 105/zoom, 27/zoom, function()
                            if(SPAM.getSpam())then return end

                            triggerServerEvent("house.removeRent", resourceRoot, v, ui.info.id)
                        end)
                    end
                end
            end

            -- last row

            local sY=(49/zoom)*9
            dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+sY, 654/zoom, 49/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
            dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+sY+49/zoom-1, 654/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))
            
            if(not ui.btns[10])then
                ui.btns[10]=buttons:createButton(sw/2-654/2/zoom+17/zoom+19/zoom+21/zoom+169/zoom+302/zoom, sh/2-587/2/zoom+82/zoom+sY+(49-27)/2/zoom, 105/zoom, 27/zoom, "DODAJ", ui.centerAlpha, 9, false, false, false)
            end

            if(not ui.edits[1])then
                ui.edits[1]=editbox:dxCreateEdit("Wprowadź nick / id", sw/2-654/2/zoom+20/zoom, sh/2-587/2/zoom+82/zoom+sY+(49-30)/2/zoom, 325/zoom, 30/zoom, false, 11/zoom, ui.centerAlpha, false, false, ":px_houses/textures/edit_icon_user.png", true)
            end

            onClick(sw/2-654/2/zoom+17/zoom+19/zoom+21/zoom+169/zoom+302/zoom, sh/2-587/2/zoom+82/zoom+sY+(49-27)/2/zoom, 105/zoom, 27/zoom, function()
                local editText=editbox:dxGetEditText(ui.edits[1]) or ""
                if(#editText > 0)then
                    local target=findPlayer(editText)
                    if(target and isElement(target))then
                        if(SPAM.getSpam())then return end

                        local rents=#rents or 0
                        local maxRents=ui.levels[ui.info.level].locators
                        if(rents < maxRents)then
                            triggerServerEvent("house.addRent", resourceRoot, target, ui.info.id, maxRents)
                        else
                            noti:noti("W domku może być maksymalnie "..maxRents.." lokatorów.")
                        end
                    else
                        noti:noti("Nie znaleziono podanego gracza.", "error")
                    end
                end
            end)
        elseif(ui.page == 4)then
            if(ui.info.type == "Baza organizacji")then return end

            dxDrawText("Rozwinięcie wnętrza", sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+13/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
            dxDrawRectangle(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom, 654/zoom, 1, tocolor(85, 85, 85, ui.centerAlpha))

            for i=1,2 do
                local a=255-100*(i/4)
                a=a > ui.centerAlpha and ui.centerAlpha or a

                local sY=(43/zoom)*(i-1)
                dxDrawImage(sw/2-654/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+10/zoom+sY, 654/zoom, 41/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, a))
                dxDrawText("Poziom "..i, sw/2-654/2/zoom+16/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+10/zoom+sY, 654/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+10/zoom+sY+41/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "left", "center")
                dxDrawText(ui.info.level == i and "Obecnie" or "$ "..formatMoney(ui.levels[i].cost), sw/2-654/2/zoom+16/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+10/zoom+sY, sw/2-654/2/zoom-16/zoom+654/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+10/zoom+sY+41/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "right", "center")
            end

            local max=ui.info.level+1 > 2 and 2 or ui.info.level+1
            local v=ui.levels[max]
            if(v)then
                -- left
                dxDrawText("Poziom "..ui.info.level, sw/2-654/2/zoom+24/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+215/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[3], "left", "top")
                dxDrawText("Obecny poziom", sw/2-654/2/zoom+24/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+240/zoom, 0, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[1], "left", "top")
                local k=ui.levels[ui.info.level]
                if(k)then
                    for i,v in pairs(k.info) do
                        local sY=(25/zoom)*(i-1)
                        local x,y=sw/2-654/2/zoom+24/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+215/zoom+60/zoom+sY
                        dxDrawImage(x, y, 14/zoom, 10/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
                        dxDrawText(v, x+15/zoom+14/zoom, y, x, y+10/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "center")
                    end

                    dxDrawText("#50cb65$ #fffcfc"..formatMoney(k.cost), sw/2-654/2/zoom+24/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+215/zoom+194/zoom, 0, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[3], "left", "top", false, false, false, true)
                    dxDrawText("Koszt ulepszenia", sw/2-654/2/zoom+24/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+215/zoom+175/zoom, 0, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[1], "left", "top")    
                end

                if(ui.info.level < max)then
                    -- right
                    dxDrawText("Poziom "..max, 0, sh/2-587/2/zoom+82/zoom+42/zoom+215/zoom, sw/2-654/2/zoom+654/zoom-24/zoom, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[3], "right", "top")
                    dxDrawText("Następny poziom", 0, sh/2-587/2/zoom+82/zoom+42/zoom+240/zoom, sw/2-654/2/zoom+654/zoom-24/zoom, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[1], "right", "top")
                    for i,v in pairs(v.info) do
                        local sY=(25/zoom)*(i-1)
                        local x,y=sw/2-654/2/zoom+654/zoom-24/zoom-14/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+215/zoom+60/zoom+sY
                        dxDrawImage(x, y, 14/zoom, 10/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
                        dxDrawText(v, x, y, x-14/zoom, y+10/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "right", "center")
                    end

                    dxDrawText("#50cb65$ #fffcfc"..formatMoney(v.cost), 0, sh/2-587/2/zoom+82/zoom+42/zoom+215/zoom+194/zoom, sw/2-654/2/zoom+654/zoom-24/zoom, 0, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[3], "right", "top", false, false, false, true)
                    dxDrawText("Koszt ulepszenia", 0, sh/2-587/2/zoom+82/zoom+42/zoom+215/zoom+175/zoom, sw/2-654/2/zoom+654/zoom-24/zoom, 0, tocolor(150, 150, 150, ui.centerAlpha), 1, assets.fonts[1], "right", "top")    
                
                    -- center
                    dxDrawImage(sw/2-39/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+193/zoom+(249-19)/2/zoom, 39/zoom, 19/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, ui.centerAlpha))
                    if(not ui.btns[1])then
                        ui.btns[1]=buttons:createButton(sw/2-147/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+193/zoom+(249-19)/2/zoom+93/zoom, 147/zoom, 38/zoom, "ULEPSZ", ui.centerAlpha, 9, false, false, ":px_houses/textures/button_accept.png")
                    else
                        onClick(sw/2-147/2/zoom, sh/2-587/2/zoom+82/zoom+42/zoom+193/zoom+(249-19)/2/zoom+93/zoom, 147/zoom, 38/zoom, function()
                            if(SPAM.getSpam())then return end
                            triggerServerEvent("house.setLevel", resourceRoot, ui.info, v.cost, ui.levels[ui.info.level].slots, ui.levels[ui.info.level+1] and ui.levels[ui.info.level+1].slots)
                        end)
                    end
                end
            end
        end

        -- close
        onClick(sw/2-654/2/zoom+654/zoom-10/zoom, sh/2-587/2/zoom+(82-10)/2/zoom, 10/zoom, 10/zoom, function()
            ui.destroy()
        end)
    end
end

ui.create=function(id, info, access)
    if(ui.animate)then return end

    if(id == 1)then
        ui.lastPos=false

        blur=exports.blur
        editbox=exports.px_editbox
        buttons=exports.px_buttons
        avatars=exports.px_avatars
        noti=exports.px_noti

        assets.create()

        addEventHandler("onClientRender", root, ui.onRender)

        info.panelID=id

        ui.alpha=0
        ui.podpis=false
        ui.prvX,ui.prvY=0,0
        ui.info=info

        ui.edits[1]=editbox:dxCreateEdit("Ilość dni", sw/2-654/2/zoom, sh/2+150/zoom, 310/zoom, 27/zoom, false, 11/zoom, 0, true, false, ":px_houses/textures/edit_icon.png", true)
        ui.btns[1]=buttons:createButton(sw/2-695/2/zoom+525/zoom, sh/2-587/2/zoom+587/zoom-68/zoom, 147/zoom, 38/zoom, "ZAKUP", 0, 9, false, false, ":px_houses/textures/button_accept.png")
        ui.btns[2]=buttons:createButton(sw/2-695/2/zoom+361/zoom, sh/2-587/2/zoom+587/zoom-68/zoom, 147/zoom, 38/zoom, "ANULUJ", 0, 9, false, false, ":px_houses/textures/button_cancel.png", {132,39,39})

        ui.podpisTarget=dxCreateRenderTarget(312/zoom, 66/zoom, true)

        showCursor(true)

        ui.animate=true
        animate(0, 255, "Linear", 250, function(a)
            ui.alpha=a
            ui.centerAlpha=a

            for i,v in pairs(ui.btns) do
                buttons:buttonSetAlpha(v, a)
            end

            for i,v in pairs(ui.edits) do
                editbox:dxSetEditAlpha(v, a)
            end
        end, function()
            ui.animate=false
        end)
    elseif(id == 2)then
        if(info.type == "Baza organizacji")then
            ui.menus={
                {name="Informacje", pos=0, width=0},
            }
        else
            ui.menus={
                {name="Informacje", pos=0, width=0},
                {name="Zarządzanie", pos=0, width=0},
                {name="Lokatorzy", pos=0, width=0},
                {name="Poziomy", pos=0, width=0},
            }
        end

        assets.create()

        addEventHandler("onClientRender", root, ui.onRender)

        info.panelID=id
        info.access=access

        ui.alpha=0
        ui.centerAlpha=0

        ui.podpis=false
        ui.prvX,ui.prvY=0,0
        ui.info=info
        ui.page=1
        ui.lastPos=false
        ui.tick=getTickCount()
        ui.edits={}
        ui.selected_level=ui.info.level > 4 and 4 or ui.info.level
        ui.buttons[2][1]=ui.info.castle == 1 and "Otwórz" or "Zamknij"

        showCursor(true)

        ui.animate=true
        animate(0, 255, "Linear", 250, function(a)
            ui.alpha=a
            ui.centerAlpha=a

            for i,v in pairs(ui.btns) do
                buttons:destroyButton(v)
                ui.btns[i]=nil
            end
        
            for i,v in pairs(ui.edits) do
                editbox:dxDestroyEdit(v)
                ui.edits[i]=nil
            end
        end, function()
            ui.animate=false
        end)
    end
end

ui.destroy=function(force)
    --if(ui.animate and not force)then return end
    destroyAnimations()
    showCursor(false)
    ui.animate=true
    animate(255, 0, "Linear", 250, function(a)
        ui.alpha=a
        ui.centerAlpha=a

        for i,v in pairs(ui.btns) do
            buttons:buttonSetAlpha(v, a)
        end

        for i,v in pairs(ui.edits) do
            editbox:dxSetEditAlpha(v, a)
        end
    end, function()
        assets.destroy()

        removeEventHandler("onClientRender", root, ui.onRender)
    
        if(ui.podpisTarget and isElement(ui.podpisTarget))then
            destroyElement(ui.podpisTarget)
        end
    
        for i,v in pairs(ui.btns) do
            buttons:destroyButton(v)
        end
    
        for i,v in pairs(ui.edits) do
            editbox:dxDestroyEdit(v)
        end
    
        ui.animate=false
    end)
end

-- triggers

addEvent("open.house.ui", true)
addEventHandler("open.house.ui", resourceRoot, function(id, info, access)
    if(exports.px_loading:isLoadingVisible())then return end

    ui.create(id, info, access)
end)

addEvent("close.house.ui", true)
addEventHandler("close.house.ui", resourceRoot, function()
    ui.destroy(true)
end)

addEvent("refresh.house.info", true)
addEventHandler("refresh.house.info", resourceRoot, function(info)
    local id=ui.info.panelID
    if(id)then
        ui.info=info
        ui.info.panelID=id

        ui.buttons[2][1]=ui.info.castle == 1 and "Otwórz" or "Zamknij"

        for i,v in pairs(ui.btns) do
            buttons:destroyButton(v)
            ui.btns[i]=nil
        end
    
        for i,v in pairs(ui.edits) do
            editbox:dxDestroyEdit(v)
            ui.edits[i]=nil
        end
    end
end)

-- useful function created by Asper

function isMouseInPosition(x, y, w, h)
	if(not isCursorShowing())then return end

	local cx,cy=getCursorPosition()
	cx,cy=cx*sw,cy*sh

    if(isCursorShowing() and (cx >= x and cx <= (x + w)) and (cy >= y and cy <= (y + h)))then
        return true
    end
    return false
end

function getPosition(myX, myY, x, y, w, h)
    if(isCursorShowing() and (myX >= x and myX <= (x + w)) and (myY >= y and myY <= (y + h)))then
        return true
    end
    return false
end

local mouseState=false
local mouseTick=getTickCount()
local mouseClicks=0
local mouseClick=false
function onClick(x, y, w, h, fnc)
    if(ui.animate)then return end

	if(not isCursorShowing())then return end

	if((getTickCount()-mouseTick) > 1000 and mouseClicks > 0)then
		mouseClicks=mouseClicks-1
	end

	if(not mouseState and getKeyState("mouse1"))then
		local cursor={getCursorPosition()}
        mouseState=cursor
    elseif(not getKeyState("mouse1") and (mouseClick or mouseState))then
        mouseClick=false
        mouseState=false
    end

    if(mouseState and mouseClicks < 10 and not mouseClick)then
		local cx,cy=unpack(mouseState)
        cx,cy=cx*sw,cy*sh

        if(getPosition(cx, cy, x, y, w, h))then
			fnc()

			mouseClicks=mouseClicks+1
            mouseTick=getTickCount()
            mouseClick=true
        end
	end
end

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end

-- animate

local anims = {}
local rendering = false

local function renderAnimations()
    local now = getTickCount()
    for k,v in pairs(anims) do
        v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
        if(now >= v.start+v.duration)then
            table.remove(anims, k)
			if(type(v.onEnd) == "function")then
                v.onEnd()
            end
        end
    end

    if(#anims == 0)then
        rendering = false
        removeEventHandler("onClientRender", root, renderAnimations)
    end
end

function animate(f, t, easing, duration, onChange, onEnd)
	if(#anims == 0 and not rendering)then
		addEventHandler("onClientRender", root, renderAnimations)
		rendering = true
	end

    assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
    assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
    assert(type(easing) == "string", "Bad argument @ 'animate' [Invalid easing at argument 3]")
    assert(type(duration) == "number", "Bad argument @ 'animate' [expected number at argument 4, got "..type(duration).."]")
    assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
    table.insert(anims, {from = f, to = t, easing = easing, duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})

    return #anims
end

function destroyAnimation(id)
    if(anims[id])then
        anims[id] = nil
    end
end

function destroyAnimations()
    for id, _ in ipairs(anims) do
        anims[id] = nil
    end
end

-- bind

ui.blips={}
ui.myBlips={}

bindKey(";", "both", function(key, state)
    if(state == "up")then
        for i,v in pairs(ui.blips) do
            destroyElement(v)
        end
        ui.blips={}
    elseif(state == "down")then
        for i,v in pairs(getElementsByType("marker", resourceRoot)) do
            if(getElementData(v, "info"))then
                local data=getElementData(v, "info")
                if(data.owner == getElementData(localPlayer, "user:uid"))then
                    ui.blips[data.id]=createBlipAttachedTo(v, 9)
                elseif(not data.owner)then
                    ui.blips[data.id]=createBlipAttachedTo(v, 17)
                else
                    ui.blips[data.id]=createBlipAttachedTo(v, 2)
                end
            end
        end
    end
end)

ui.reloadBlips=function()
    if(not getElementData(localPlayer, "user:uid"))then return end

    for i,v in pairs(ui.myBlips) do
        destroyElement(v)
    end

    for i,v in pairs(getElementsByType("marker", resourceRoot)) do
        local info=getElementData(v, "info")
        if(info and tonumber(info.owner) == getElementData(localPlayer, "user:uid"))then
            ui.myBlips[info.id]=createBlipAttachedTo(v, 9)
        end
    end
end
addEvent('reloadBlips', true)
addEventHandler('reloadBlips', resourceRoot, ui.reloadBlips)

addEventHandler('onClientElementDataChange', localPlayer, function(name, old, new)
    if(name == 'user:uid' and not old)then
        ui.reloadBlips()
    end
end)

ui.reloadBlip=function(id,x,y,z,owner)
    if(not getElementData(localPlayer, "user:uid"))then return end

    if(ui.myBlips[id])then
        destroyElement(ui.myBlips[id])
        ui.myBlips[id]=nil
    end

    local ownered=tonumber(owner) == getElementData(localPlayer, "user:uid")
    if(ownered)then
        ui.myBlips[id]=createBlip(x,y,z,9)
    end
end
addEvent("reload.blip", true)
addEventHandler("reload.blip", resourceRoot, ui.reloadBlip)

-- format

function formatMoney(money)
	while true do
		money, i = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1,%2")
		if i == 0 then
			break
		end
	end
	return money
end

-- useful

function findPlayer(target)
	local player = false
	for i,v in pairs(getElementsByType("player")) do
		if tonumber(target) then
			if getElementData(v, "user:id") == tonumber(target) then
				player = v
				break
			end
		else
			if string.find(string.gsub(getPlayerName(v):lower(),"#%x%x%x%x%x%x", ""), target:lower(), 1, true) then
				player = v
				break
			end
		end
	end
	return player
end

-- sound

addEvent("playSound", true)
addEventHandler("playSound", resourceRoot, function(sound)
    playSound(sound)
end)