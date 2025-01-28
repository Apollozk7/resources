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

-- variables

local exists={}

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local buttons = exports.px_buttons
local noti = exports.px_noti
local blur=exports.blur

PJ = {}

-- main

PJ.places = {
    ["A"] = {
        pos={
            {1163.1110839844,1348.4621582031,10.897977828979},
        },

        desc=[[Prawo jazdy kategorii A uprawnia Cię do poruszania się motocyklami po całym San Andreas.]],
        cost=100,
        rp=0,
    },

    ["B"] = {
        pos={
            {1163.3923339844,1340.6962890625,10.890625},
        },

        desc=[[Prawo jazdy kategorii B uprawnia Cię do prowadzenia samochodami osobowymi, oraz lekkimi dostawczymi po całym San Andreas.]],
        cost=0,
        rp=0,
    },

    ["C"] = {
        pos={
            {1163.3306884766,1332.3588867188,10.890625},
        },

        desc=[[Prawo Jazdy kategorii C uprawnia Cię do prowadzenia pojazdami ciężarowymi oraz specjalistycznymi o dużej masie całkowitej.]],
        cost=200,
        rp=50,
    },


    ["C+E"] = {
        pos={
            {1163.3053,1324.7032,10.8980},
        },

        desc=[[Prawo Jazdy kategorii C+E uprawnia Cię do prowadzenia pojazdami ciężarowymi oraz specjalistycznymi o dużej masie całkowitej.]],
        cost=1000,
        rp=350,
    },

    ["L"]={
        pos={
            {930.4380,1752.8650,8.8516}
        },

        desc=[[Licencja lotnicza kategorii L uprawnia Cię do zdobycia licencji lotniczej L1 i L2.]],
        cost=500,
        rp=80,
    },
}

PJ.textures = {
    "assets/images/window_start.png",
    "assets/images/icon_start.png",
    "assets/images/button_start.png",
    "assets/images/button_close.png",

    "assets/images/window_quests.png",
    "assets/images/checkbox.png",
    "assets/images/checkbox_selected.png",
    "assets/images/git.png",
    "assets/images/zle.png",

    "assets/images/window_end.png",
}

PJ.fonts = {
    {":px_assets/fonts/Font-SemiBold.ttf", 15/zoom},
    {":px_assets/fonts/Font-Medium.ttf", 13/zoom},
    {":px_assets/fonts/Font-Medium.ttf", 15/zoom},
    {":px_assets/fonts/Font-Regular.ttf", 11/zoom},
    {":px_assets/fonts/Font-Medium.ttf", 11/zoom},
}

PJ.gui = {
    alpha = 0,
}

PJ.quest = 1
PJ.points = 0
PJ.tick=0

-- collateral

PJ.markers = {}
PJ.imgs = {}
PJ.fnts = {}
PJ.buttons = {}
PJ.selected = 0

-- utlits

PJ.create = function()
    for i,v in pairs(PJ.places) do
        for _,k in pairs(v.pos) do
            local marker = createMarker(k[1], k[2], k[3]-1, "cylinder", 1.2, 0, 125, 255, 0)
            setElementData(marker, "icon", ":px_licenses/assets/images/markers/"..(i == "Broń palna" and "marker-gun" or i == "A" and "marker" or "marker-"..string.lower(i))..".png")
            setElementData(marker, "text", {text="Kategoria "..i,desc="Egzamin teoretyczny"})
            
            local cs = createColSphere(k[1], k[2], k[3], 1)
            PJ.markers[#PJ.markers+1] = {marker=cs, type=i, rp=v.rp, desc=v.desc, cost=v.cost, quests=v.quests}
        end
    end
end

PJ.getMarker = function(marker)
    local type = false
    for i,v in pairs(PJ.markers) do
        if(marker == v.marker)then
            type = v
            break
        end
    end
    return type
end

PJ.nextQuestion=function()
    PJ.tick=getTickCount()

    -- points
    for i,v in pairs(PJ.gui.quests[PJ.quest].options) do
        if(i == PJ.selected and v.next == "+")then
            PJ.points = PJ.points+1
            break
        end
    end
    --

    if(not PJ.gui.quests[PJ.quest+1])then
        local percent = math.percent(80, #PJ.gui.quests)
        percent = math.floor(percent)

        if(PJ.points >= percent)then
            PJ.gui.info_last2="Gratulacje!"
            PJ.gui.info_last = "Pomyślnie zdałeś egzamin teoretyczny.\nNa zdanie egzaminu wymagane jest odpowiedzenie poprawnie na minimum "..percent.." pytań."
            triggerServerEvent("give:pj", resourceRoot, PJ.gui.type, 1)
        else
            PJ.gui.info_last2="Przykro nam!"
            PJ.gui.info_last = "Niestety nie zdałeś egzaminu.\nNa zdanie egzaminu wymagane jest odpowiedzenie poprawnie na minimum "..percent.." pytań."
        end
        --

        PJ.gui.animate = true
        animate(PJ.gui.alpha, 0, "Linear", 500, function(a)
            PJ.gui.alpha = a

            for i = 1,#PJ.buttons do
                buttons:buttonSetAlpha(i, a)
            end
        end, function()
            PJ.gui.animate = false

            removeEventHandler("onClientRender", root, PJ.renders.quests)

            for i = 1,#PJ.buttons do
                buttons:destroyButton(PJ.buttons[i])
            end

            addEventHandler("onClientRender", root, PJ.renders.success)

            PJ.buttons[1] = buttons:createButton(sw/2-140/2/zoom, sh/2-518/2/zoom+340/zoom, 140/zoom, 37/zoom, "ZAMKNIJ EGZAMIN", 255, 7/zoom, false, false, ":px_licenses/assets/images/button_close.png", {132,39,39})

            PJ.gui.animate = true
            animate(PJ.gui.alpha, 255, "Linear", 500, function(a)
                PJ.gui.alpha = a

                for i = 1,#PJ.buttons do
                    buttons:buttonSetAlpha(i, a)
                end
            end, function()
                PJ.gui.animate = false
            end)
        end)
    else
        PJ.quest = PJ.quest+1
        PJ.selected = false
    end
end

-- drawing

PJ.renders = {
    main = function()
        blur:dxDrawBlur(sw/2-600/2/zoom, sh/2-360/2/zoom, 600/zoom, 360/zoom, tocolor(255, 255, 255, PJ.gui.alpha))
        dxDrawImage(sw/2-600/2/zoom, sh/2-360/2/zoom, 600/zoom, 360/zoom, PJ.imgs[1], 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha))

        dxDrawText("Egzamin teoretyczny", sw/2-600/2/zoom, sh/2-360/2/zoom+31/zoom-10/zoom, sw/2-600/2/zoom+600/zoom, sh/2-360/2/zoom+93/zoom, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[1], "center", "top", false)
        dxDrawText("Kategoria "..PJ.gui.type, sw/2-600/2/zoom, sh/2-360/2/zoom+59/zoom-10/zoom, sw/2-600/2/zoom+600/zoom, sh/2-360/2/zoom+93/zoom, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[2], "center", "top", false)

        local w=dxGetTextWidth("Egzamin teoretyczny", 1, PJ.fnts[1])+10/zoom
        dxDrawImage(sw/2-600/2/zoom+(600/zoom)/2+w/2, sh/2-360/2/zoom+31/zoom-5/zoom, 18/zoom, 18/zoom, PJ.imgs[2], 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha))

        dxDrawRectangle(sw/2-559/2/zoom, sh/2-360/2/zoom+93/zoom, 559/zoom, 1, tocolor(85, 85, 85, PJ.gui.alpha))

        dxDrawText("Witaj!", sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+116/zoom, sw/2-600/2/zoom+600/zoom, sh/2-360/2/zoom+93/zoom, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[3], "left", "top", false)
        dxDrawText(PJ.gui.info, sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+144/zoom, sw/2-600/2/zoom+600/zoom-35/zoom, sh/2-360/2/zoom+93/zoom, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[4], "left", "top", false, true)
        
        dxDrawText("Wymagania:", sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+204/zoom, sw/2-600/2/zoom+600/zoom, sh/2-360/2/zoom+93/zoom, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[3], "left", "top", false)
        dxDrawText("Zapłata "..PJ.gui.cost.." $\nPoziom: "..PJ.gui.rp, sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+230/zoom, sw/2-600/2/zoom+600/zoom-35/zoom, sh/2-360/2/zoom+93/zoom, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[4], "left", "top", false, true)

        onClick(sw/2-140/zoom-10/zoom, sh/2-360/2/zoom+289/zoom, 140/zoom, 37/zoom, function()
            if(PJ.gui.animate)then return end

            if(PJ.gui.cost > 0)then
                if(getPlayerMoney(localPlayer) < PJ.gui.cost)then
                    noti = exports.px_noti
                    noti:noti("Nie posiadasz funduszy na podejście do tego egzaminu!")
                    return
                else
                    if(PJ.gui.rp > getElementData(localPlayer, "user:reputation"))then
                        noti:noti("Tą kategorie możesz zdać od "..PJ.gui.rp.." reputacji.", "error")
                        return
                    end

                    if(SPAM.getSpam())then return end

                    triggerServerEvent("take:money", resourceRoot, PJ.gui.cost)
                    setElementData(localPlayer, "ghost", "player")
                end
            end

            PJ.gui.animate = true
            animate(PJ.gui.alpha, 0, "Linear", 500, function(a)
                PJ.gui.alpha = a

                for i = 1,#PJ.buttons do
                    buttons:buttonSetAlpha(i, a)
                end
            end, function()
                PJ.gui.animate = false

                removeEventHandler("onClientRender", root, PJ.renders.main)

                for i = 1,#PJ.buttons do
                    buttons:destroyButton(PJ.buttons[i])
                end

                -- questions
                PJ.quest = 1
                PJ.selected = 0
                PJ.points = 0

                exists={}
                PJ.gui.quests={}
                for i = 1,10 do
                    PJ.gui.quests[i]=PJ.quests[PJ.gui.type][lastReturn(1,10)]
                end

                addEventHandler("onClientRender", root, PJ.renders.quests)

                PJ.buttons[1] = buttons:createButton(sw/2-675/2/zoom+61/zoom, sh/2-518/2/zoom+445/zoom, 140/zoom, 37/zoom, "NASTĘPNE PYTANIE", 255, 7/zoom, false, false, ":px_licenses/assets/images/button_start.png")
                PJ.buttons[2] = buttons:createButton(sw/2-675/2/zoom+61/zoom+140/zoom+29/zoom, sh/2-518/2/zoom+445/zoom, 140/zoom, 37/zoom, "ZAMKNIJ EGZAMIN", 255, 7/zoom, false, false, ":px_licenses/assets/images/button_close.png", {132,39,39})

                PJ.gui.animate = true
                animate(PJ.gui.alpha, 255, "Linear", 500, function(a)
                    PJ.gui.alpha = a

                    for i = 1,#PJ.buttons do
                        buttons:buttonSetAlpha(i, a)
                    end
                end, function()
                    PJ.gui.animate = false
                end)
            end)
        end)

        onClick(sw/2+10/zoom, sh/2-360/2/zoom+289/zoom, 140/zoom, 37/zoom, function()
            if(PJ.gui.animate)then return end

            PJ.gui.animate = true
            showCursor(false)
            animate(PJ.gui.alpha, 0, "Linear", 500, function(a)
                PJ.gui.alpha = a

                for i = 1,#PJ.buttons do
                    buttons:buttonSetAlpha(i, a)
                end
            end, function()
                PJ.gui.animate = false

                removeEventHandler("onClientRender", root, PJ.renders.main)

                for i = 1,#PJ.buttons do
                    buttons:destroyButton(PJ.buttons[i])
                end

                for i,v in pairs(PJ.textures) do
                    checkAndDestroy(v)
                end

                for i,v in pairs(PJ.fonts) do
                    checkAndDestroy(v)
                end

                setElementData(localPlayer, "user:gui_showed", false, false)
            end)
        end)
    end,

    quests = function()
        blur:dxDrawBlur(sw/2-675/2/zoom, sh/2-518/2/zoom, 675/zoom, 518/zoom, tocolor(255, 255, 255, PJ.gui.alpha))
        dxDrawImage(sw/2-675/2/zoom, sh/2-518/2/zoom, 675/zoom, 518/zoom, PJ.imgs[5], 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha))

        dxDrawText("Egzamin teoretyczny", sw/2-675/2/zoom, sh/2-518/2/zoom+31/zoom-10/zoom, sw/2-675/2/zoom+675/zoom, sh/2-518/2/zoom+93/zoom, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[1], "center", "top", false)
        dxDrawText("Kategoria "..PJ.gui.type, sw/2-675/2/zoom, sh/2-518/2/zoom+59/zoom-10/zoom, sw/2-675/2/zoom+675/zoom, sh/2-518/2/zoom+93/zoom, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[2], "center", "top", false)

        local w=dxGetTextWidth("Egzamin teoretyczny", 1, PJ.fnts[1])+10/zoom
        dxDrawImage(sw/2-675/2/zoom+(675/zoom)/2+w/2, sh/2-518/2/zoom+31/zoom-5/zoom, 18/zoom, 18/zoom, PJ.imgs[2], 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha))

        dxDrawRectangle(sw/2-559/2/zoom, sh/2-518/2/zoom+90/zoom, 559/zoom, 1, tocolor(85, 85, 85, PJ.gui.alpha))

        if(not PJ.gui.quests[PJ.quest].image)then
            dxDrawImage(sw/2-675/2/zoom+43/zoom, sh/2-518/2/zoom+110/zoom, 187/zoom, 115/zoom, "assets/images/quests/error.png", 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha), false)
        else
            dxDrawImage(sw/2-675/2/zoom+43/zoom, sh/2-518/2/zoom+110/zoom, 187/zoom, 115/zoom, "assets/images/quests/"..PJ.gui.quests[PJ.quest].image, 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha), false)
        end

        local sec=30 -- liczba sekund na zaznaczenie odpowiedzi
        local time=(sec+1)-((getTickCount()-PJ.tick)/1000) -- wyliczanie sekund do konca
        if(time < 1)then
            --if(SPAM.getSpam())then return end
            if(not PJ.checkbox)then
                PJ.nextQuestion()
            end
        end
        dxDrawText("Pytanie nr. "..PJ.quest.." ("..math.floor(time < 1 and 0 or time).."s)", sw/2-675/2/zoom+43/zoom+187/zoom+10/zoom, sh/2-518/2/zoom+115/zoom+10/zoom, 0, 0, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[1], "left", "top", false)
        dxDrawText(PJ.gui.quests[PJ.quest].desc, sw/2-675/2/zoom+43/zoom+187/zoom+10/zoom, sh/2-518/2/zoom+115/zoom+40/zoom, sw/2-675/2/zoom+675/zoom-100/zoom, 0, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[5], "left", "top", false, true)

        dxDrawRectangle(sw/2-559/2/zoom, sh/2-518/2/zoom+242/zoom, 559/zoom, 1, tocolor(85, 85, 85, PJ.gui.alpha))

        for i,v in pairs(PJ.gui.quests[PJ.quest].options) do
            local sY = (45/zoom)*(i-1)
            dxDrawImage(sw/2-559/2/zoom-15/zoom, sh/2-518/2/zoom+261/zoom+sY, 42/zoom, 42/zoom, PJ.selected == i and PJ.imgs[7] or PJ.imgs[6], 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha), false)
            dxDrawText(v.name, sw/2-559/2/zoom-15/zoom+40/zoom, sh/2-518/2/zoom+261/zoom+sY, 42/zoom, 42/zoom+sh/2-518/2/zoom+261/zoom+sY, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[4], "left", "center", false, true)
            
            onClick(sw/2-559/2/zoom-15/zoom, sh/2-518/2/zoom+261/zoom+sY, 42/zoom, 42/zoom, function()
                if(not PJ.checkbox)then
                    PJ.selected=i
                end
            end)
        end

        local click=false
        if(PJ.checkbox)then
            if((getTickCount()-PJ.checkbox_tick) > 2000)then
                if(SPAM.getSpam())then return end

                PJ.nextQuestion()
                PJ.checkbox=nil
            else
                local sY=(45/zoom)*(PJ.selected-1)
                local a=interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount()-PJ.checkbox_tick)/500, "SineCurve")
                dxDrawImage(sw/2-559/2/zoom-15/zoom, sh/2-518/2/zoom+261/zoom+sY, 42/zoom, 42/zoom, PJ.checkbox == "git" and PJ.imgs[7] or "assets/images/"..PJ.checkbox.."2.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
                dxDrawImage(sw/2-559/2/zoom-15/zoom, sh/2-518/2/zoom+261/zoom+sY, 42/zoom, 42/zoom, "assets/images/"..PJ.checkbox..".png", 0, 0, 0, tocolor(255, 255, 255, a), false)
            end
        end

        onClick(sw/2-675/2/zoom+61/zoom, sh/2-518/2/zoom+445/zoom, 140/zoom, 37/zoom, function()
            if(PJ.selected and PJ.selected > 0 and not PJ.checkbox)then
                PJ.checkbox="zle"
                PJ.checkbox_tick=getTickCount()
                for i,v in pairs(PJ.gui.quests[PJ.quest].options) do
                    if(i == PJ.selected and v.next == "+")then
                        PJ.checkbox="git"
                        PJ.checkbox_tick=getTickCount()
                        break
                    end
                end

                if(PJ.checkbox == "zle")then
                    playSoundFrontEnd(5)
                    setTimer(function()
                        playSoundFrontEnd(5)
                    end, 300, 1)
                else
                    playSoundFrontEnd(5)
                end
            end
        end)

        onClick(sw/2-675/2/zoom+61/zoom+140/zoom+29/zoom, sh/2-518/2/zoom+445/zoom, 140/zoom, 37/zoom, function()
            if(PJ.gui.animate or PJ.checkbox)then return end

            PJ.gui.animate = true
            showCursor(false)
            animate(PJ.gui.alpha, 0, "Linear", 500, function(a)
                PJ.gui.alpha = a

                for i = 1,#PJ.buttons do
                    buttons:buttonSetAlpha(i, a)
                end
            end, function()
                PJ.gui.animate = false

                removeEventHandler("onClientRender", root, PJ.renders.quests)

                for i = 1,#PJ.buttons do
                    buttons:destroyButton(PJ.buttons[i])
                end

                for i,v in pairs(PJ.textures) do
                    checkAndDestroy(v)
                end

                for i,v in pairs(PJ.fonts) do
                    checkAndDestroy(v)
                end
            end)

            setElementData(localPlayer, "user:gui_showed", false, false)
            setElementData(localPlayer, "ghost", false)
        end)
    end,

    success = function()
        blur:dxDrawBlur(sw/2-600/2/zoom, sh/2-296/2/zoom, 600/zoom, 296/zoom, tocolor(255, 255, 255, PJ.gui.alpha))
        dxDrawImage(sw/2-600/2/zoom, sh/2-296/2/zoom, 600/zoom, 296/zoom, PJ.imgs[5], 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha))

        dxDrawText("Egzamin teoretyczny", sw/2-600/2/zoom, sh/2-296/2/zoom+31/zoom-10/zoom, sw/2-600/2/zoom+600/zoom, sh/2-296/2/zoom+93/zoom, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[1], "center", "top", false)
        dxDrawText("Kategoria "..PJ.gui.type, sw/2-600/2/zoom, sh/2-296/2/zoom+59/zoom-10/zoom, sw/2-600/2/zoom+600/zoom, sh/2-296/2/zoom+93/zoom, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[2], "center", "top", false)

        local w=dxGetTextWidth("Egzamin teoretyczny", 1, PJ.fnts[1])+10/zoom
        dxDrawImage(sw/2-600/2/zoom+(600/zoom)/2+w/2, sh/2-296/2/zoom+31/zoom-5/zoom, 18/zoom, 18/zoom, PJ.imgs[2], 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha))

        dxDrawRectangle(sw/2-559/2/zoom, sh/2-296/2/zoom+90/zoom, 559/zoom, 1, tocolor(85, 85, 85, PJ.gui.alpha))

        dxDrawText(PJ.gui.info_last2, sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+116/zoom+20/zoom, sw/2-600/2/zoom+600/zoom, sh/2-360/2/zoom+93/zoom, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[3], "left", "top", false)
        dxDrawText(PJ.gui.info_last, sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+144/zoom+20/zoom, sw/2-600/2/zoom+600/zoom-35/zoom, sh/2-360/2/zoom+93/zoom, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[4], "left", "top", false, true)

        -- click
        onClick(sw/2-140/2/zoom, sh/2-518/2/zoom+340/zoom, 140/zoom, 37/zoom, function()
            if(PJ.gui.animate)then return end

            PJ.gui.animate = true
            showCursor(false)
            animate(PJ.gui.alpha, 0, "Linear", 500, function(a)
                PJ.gui.alpha = a

                for i = 1,#PJ.buttons do
                    buttons:buttonSetAlpha(i, a)
                end
            end, function()
                PJ.gui.animate = false

                removeEventHandler("onClientRender", root, PJ.renders.success)

                for i = 1,#PJ.buttons do
                    buttons:destroyButton(PJ.buttons[i])
                end

                for i,v in pairs(PJ.textures) do
                    checkAndDestroy(v)
                end

                for i,v in pairs(PJ.fonts) do
                    checkAndDestroy(v)
                end

                exists={}
                PJ.gui.quests={}

                setElementData(localPlayer, "user:gui_showed", false, false)
                setElementData(localPlayer, "ghost", false)
            end)
        end)
    end,
}

-- showing

addEventHandler("onClientColShapeHit", resourceRoot, function(hit, dim)
    if(hit ~= localPlayer or not dim or PJ.gui.animate)then return end

    if(getElementData(localPlayer, "user:gui_showed"))then return end

    buttons = exports.px_buttons
    noti = exports.px_noti
    blur=exports.blur

    if(getElementData(localPlayer, "user:job") or getElementData(localPlayer, "user:faction"))then
        noti:noti("Najpierw zakończ pracę.")
        return
    end

    local info = PJ.getMarker(source)
    if(info)then
        local licenses = getElementData(hit, "user:licenses")
        if(licenses[string.lower(info.type)] and (licenses[string.lower(info.type)] == 1 or licenses[string.lower(info.type)] == 2))then
            noti:noti("Posiadasz już zdany egzamin teoretyczny kategorii "..info.type..".")
            return
        end

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

        PJ.gui.alpha = 0
        PJ.gui.info = info.desc
        PJ.gui.cost = info.cost
        PJ.gui.type = info.type
        PJ.gui.rp=info.rp or 1
        PJ.tick=getTickCount()

        showCursor(true)

        for i,v in pairs(PJ.textures) do
            PJ.imgs[i] = dxCreateTexture(v, "argb", false, "clamp")
        end

        for i,v in pairs(PJ.fonts) do
            PJ.fnts[i] = dxCreateFont(v[1], v[2])
        end

        addEventHandler("onClientRender", root, PJ.renders.main)

        PJ.buttons[1] = buttons:createButton(sw/2-140/zoom-10/zoom, sh/2-360/2/zoom+289/zoom, 140/zoom, 37/zoom, "ZACZNIJ EGZAMIN", 0, 7/zoom, false, false, ":px_licenses/assets/images/button_start.png")
        PJ.buttons[2] = buttons:createButton(sw/2+10/zoom, sh/2-360/2/zoom+289/zoom, 140/zoom, 37/zoom, "ZAMKNIJ EGZAMIN", 0, 7/zoom, false, false, ":px_licenses/assets/images/button_close.png", {132,39,39})

        PJ.gui.animate = true
        animate(PJ.gui.alpha, 255, "Linear", 500, function(a)
            PJ.gui.alpha = a

            for i = 1,#PJ.buttons do
				buttons:buttonSetAlpha(i, a)
			end
        end, function()
            PJ.gui.animate = false
        end)
    end
end)

-- usefull function created by Asper

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

-- useful

function checkAndDestroy(element)
	if(element and isElement(element))then
		destroyElement(element)
	end
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

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
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

-- useful by asper

function lastReturn(start,endz)
    while(true)do
        random=math.random(start,endz)
        if(not exists[random])then
            exists[random]=true
            break
        end
    end
    return random
end

-- creating

PJ.create()

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)
