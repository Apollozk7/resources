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

local noti = exports.px_noti
local buttons = exports.px_buttons
local scroll = exports.px_scroll
local progressbar=exports.px_progressbar
local blur=exports.blur

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local UI = {}

-- assets

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Regular.ttf", 17},
        {":px_assets/fonts/Font-Medium.ttf", 13},
        {":px_assets/fonts/Font-Regular.ttf", 11},
        {":px_assets/fonts/Font-Regular.ttf", 13},
        {":px_assets/fonts/Font-Regular.ttf", 15},
        {":px_assets/fonts/Font-Medium.ttf", 13},
    },

    textures={},
    textures_paths={
        "assets/images/window.png",
        "assets/images/header_icon.png",
        "assets/images/close_icon.png",
        "assets/images/list.png",
        "assets/images/nazwa_icon.png",
        "assets/images/status_icon.png",
        "assets/images/koszt_icon.png",
        "assets/images/row.png",
        "assets/images/checkbox.png",
        "assets/images/checkbox_selected.png",
        "assets/images/footer.png",
    },
}


assets.create = function()
    for k,t in pairs(assets) do
        if(k=="fonts_paths")then
            for i,v in pairs(t) do
                assets.fonts[i] = dxCreateFont(v[1], v[2]/zoom)
            end
        elseif(k=="textures_paths")then
            for i,v in pairs(t) do
                assets.textures[i] = dxCreateTexture(v, "argb", false, "clamp")
            end
        end
    end
end

assets.destroy = function()
    for k,t in pairs(assets) do
        if(k == "textures" or k == "fonts")then
            for i,v in pairs(t) do
                if(v and isElement(v))then
                    destroyElement(v)
                end
            end
            assets.fonts={}
            assets.textures={}
        end
    end
end

--


UI.buttons = {}
UI.alpha = 0
UI.window=false

UI.list={}
UI.parts = {}
UI.part_row = 1

UI.offer = false

UI.scroll = false

UI.veh = false
UI.target = false

UI.allCost = 0
UI.giveCost=0

UI.shape=false

UI.podglad=false
UI.border=false

UI.selected_category=1
UI.row_category=1

UI.wybrana_czesc={}
UI.last_tuning={}
UI.last_wheels_data={}

UI.marker=false

UI.categories={
    {name="Silnik", names={
        "Nitro"
    }},

    {name="Koła", names={
        "Wheels", "Tires", "Chain"
    }},

    {name="Wizualne", names={
        "Spoiler", "Hydraulics", "Exhaust", "Front Bullbars", "Front Bumper", "Rear Bullbars", "Rear Bumper", "Sideskirt", "Hood", "Vent", "Roof", "Stereo", "Headlights"
    }},
}

UI.updateList=function()
    local tbl={}
    for i,v in pairs(UI.parts) do
        for _,value in pairs(UI.categories[UI.selected_category].names) do
            if(v.kategoria == value)then
                tbl[#tbl+1]=v
            end
        end
    end

    scroll:dxDestroyScroll(UI.scroll)
    UI.scroll=scroll:dxCreateScroll(sw/2-695/2/zoom+695/zoom-4/zoom, sh/2-608/2/zoom+55/zoom+22/zoom, 4/zoom, 4/zoom, 0, 7, tbl, 410/zoom, 255)
    UI.list=tbl
end

UI.onRender = function()
    if(UI.offer and UI.veh and isElement(UI.veh) and UI.target and isElement(UI.target))then
        blur:dxDrawBlur(sw/2-695/2/zoom, sh/2-608/2/zoom, 695/zoom, 608/zoom, tocolor(255, 255, 255, UI.alpha))
        dxDrawImage(sw/2-695/2/zoom, sh/2-608/2/zoom, 695/zoom, 608/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
    
        -- header
        dxDrawText("Oferta tuningu", sw/2-695/2/zoom, sh/2-608/2/zoom, 695/zoom+sw/2-695/2/zoom, sh/2-608/2/zoom+55/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[1], "center", "center")
        local w=dxGetTextWidth("Oferta tuningu", 1, assets.fonts[1])
        dxDrawImage(sw/2-695/2/zoom+695/2/zoom-20/2+w/2+20/zoom, sh/2-608/2/zoom+(60-20)/2/zoom, 20/zoom, 20/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
    
        -- close
        dxDrawImage(sw/2-695/2/zoom+695/zoom-10/zoom-(55-10)/2/zoom, sh/2-608/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
        --
    
        --26px
        local last=0
        for i,v in pairs(UI.categories) do
            local x,y,w,h=sw/2-695/2/zoom+20/zoom, sh/2-608/2/zoom, 50/zoom, 26/zoom
            w=dxGetTextWidth(v.name, 1, assets.fonts[6])
            y=y+(55/zoom-h)/2

            x=x+last

            if(not UI.border)then
                UI.border={x,y+h-1,w,1}
                UI.selected_category=1
                UI.updateList()
            end

            if(UI.selected_category == i)then
                dxDrawText(v.name, x,y,w+x,y+h, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[6], "center", "center")
            else
                dxDrawText(v.name, x,y,w+x,y+h, tocolor(160, 160, 160,UI.alpha), 1, assets.fonts[6], "center", "center")
            end

            onClick(x,y,w,h,function()
                if(not UI.animate)then
                    UI.animate=true
                    UI.selected_category=i
                    UI.updateList()

                    animate(UI.border[1], x, "Linear", 250, function(a)
                        UI.border[1]=a
                    end, function()
                        UI.animate=false
                    end)

                    animate(UI.border[3], w, "Linear", 250, function(a)
                        UI.border[3]=a
                    end)
                end
            end)

            last=last+w+15/zoom
        end
        dxDrawRectangle(UI.border[1],UI.border[2],UI.border[3],UI.border[4],tocolor(42,108,126,UI.alpha))
        --
    
        dxDrawRectangle(sw/2-654/2/zoom, sh/2-608/2/zoom+55/zoom-1, 654/zoom, 1, tocolor(85,85,85,UI.alpha))
    
        -- list
        dxDrawImage(sw/2-695/2/zoom, sh/2-608/2/zoom+55/zoom, 695/zoom, 22/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
    
        dxDrawImage(sw/2-695/2/zoom+40/zoom, sh/2-608/2/zoom+55/zoom+(22-12)/2/zoom, 16/zoom, 12/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
        dxDrawText("Nazwa części", sw/2-695/2/zoom+65/zoom, sh/2-608/2/zoom+55/zoom, 695/zoom, 22/zoom+sh/2-608/2/zoom+55/zoom, tocolor(170, 170, 170,UI.alpha), 1, assets.fonts[3])
    
        dxDrawImage(sw/2-695/2/zoom+230/zoom, sh/2-608/2/zoom+55/zoom+(22-15)/2/zoom, 15/zoom, 15/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
        dxDrawText("Koszt montażu/demontażu", sw/2-695/2/zoom+283/zoom, sh/2-608/2/zoom+55/zoom, sw/2-695/2/zoom+283/zoom+115/zoom, 22/zoom+sh/2-608/2/zoom+55/zoom, tocolor(170, 170, 170,UI.alpha), 1, assets.fonts[3], "center")
    
        dxDrawImage(sw/2-695/2/zoom+530/zoom, sh/2-608/2/zoom+55/zoom+(22-12)/2/zoom, 12/zoom, 12/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
        dxDrawText("Status", sw/2-695/2/zoom+500/zoom, sh/2-608/2/zoom+55/zoom, sw/2-695/2/zoom+500/zoom+140/zoom, 22/zoom+sh/2-608/2/zoom+55/zoom, tocolor(170, 170, 170,UI.alpha), 1, assets.fonts[3], "center")
    
        UI.part_row = math.floor(scroll:dxScrollGetPosition(UI.scroll)+1)

        local selected_parts={}
        for i,v in pairs(UI.parts) do
            if(v.selected)then
                selected_parts[#selected_parts+1]=v
            end
        end
    
        local selected=false
        local k=0
        for i,v in pairs(UI.list) do
            if(i >= UI.part_row and i <= (UI.part_row+6))then
                k=k+1
    
                local cost=100
    
                local sY=(59/zoom)*(k-1)
                dxDrawImage(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, 693/zoom, 57/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
                dxDrawRectangle(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom-1, 693/zoom, 1, tocolor(85, 85, 85,UI.alpha))
    
                dxDrawText("#56b553$#dcdcdc "..convertNumber(v.cost), sw/2-695/2/zoom+283/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, sw/2-695/2/zoom+283/zoom+115/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
                dxDrawText(v.demontaz and "#56b553Zamontowany" or "Niezamontowany", sw/2-695/2/zoom+500/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, sw/2-695/2/zoom+500/zoom+140/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom, tocolor(220, 220, 220,UI.alpha), 1, assets.fonts[4], "center", "center", false, false, false, true)

                if(v.selected)then
                    onClick(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+(57-42)/2/zoom+55/zoom+20/zoom+2+sY, 42/zoom, 42/zoom, function()
                        if((v.kategoria == "Tires" or v.kategoria == "Chain"))then
                            if(not v.demontaz)then
                                if(not UI.wybrana_czesc[v.kategoria])then UI.wybrana_czesc[v.kategoria]={} end

                                UI.allCost=UI.allCost-v.cost
                                v.selected=false
                                UI.wybrana_czesc[v.kategoria][i]=nil
                            end
                        else
                            local inne_czesci=false
                            for i,v in pairs(UI.wybrana_czesc[v.kategoria]) do
                                if(v ~= "demontaz")then
                                    inne_czesci=true
                                end
                            end

                            if(v.demontaz)then
                                if(not inne_czesci)then
                                    UI.giveCost=UI.giveCost-v.cost
                                    v.selected=false
                                    UI.wybrana_czesc[v.kategoria][i]=nil
                                end
                            else
                                UI.allCost=UI.allCost-v.cost
                                v.selected=false
                                UI.wybrana_czesc[v.kategoria][i]=nil
                            end
                        end
                    end)
                else
                    onClick(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+(57-42)/2/zoom+55/zoom+20/zoom+2+sY, 42/zoom, 42/zoom, function()
                        if((v.kategoria == "Tires"))then
                            if(getVehicleUpgradeOnSlot(UI.veh,12))then
                                if(not v.demontaz)then
                                    if(not UI.wybrana_czesc[v.kategoria])then UI.wybrana_czesc[v.kategoria]={} end

                                    local size=table.size(UI.wybrana_czesc[v.kategoria])
                                    local inne_czesci=size>0
                                    if(not inne_czesci)then
                                        UI.allCost=UI.allCost+v.cost
                                        UI.wybrana_czesc[v.kategoria][i]="montaz"
                                        v.selected=true
                                    end
                                else
                                    noti:noti("Nie możesz wymontować opon lub łacuchów.", "error")
                                end
                            else
                                noti:noti("Najpierw musisz zamontować felgi!", "error")
                            end
                        else
                            if(v.kategoria == 'Hydraulics' and getElementData(UI.veh, 'vehicle:suspension'))then
                                exports.px_noti:noti('Najpierw wymontuj zawieszenie!', 'error')
                            else
                                if(not UI.wybrana_czesc[v.kategoria])then UI.wybrana_czesc[v.kategoria]={} end

                                local size=table.size(UI.wybrana_czesc[v.kategoria])
                                local wybral_demontaz=false
                                local jest_demontaz=false
                                local inne_czesci=false
                                for i,v in pairs(UI.wybrana_czesc[v.kategoria]) do
                                    if(v == "demontaz")then
                                        wybral_demontaz=true
                                    else
                                        inne_czesci=true
                                    end
                                end

                                for _,k in pairs(UI.list) do
                                    if(k.demontaz and k.kategoria == v.kategoria)then jest_demontaz=true break end
                                end

                                if((not inne_czesci and not jest_demontaz) or v.demontaz or (wybral_demontaz and not inne_czesci))then
                                    v.selected=true

                                    if(v.demontaz)then
                                        UI.giveCost=UI.giveCost+v.cost
                                        UI.wybrana_czesc[v.kategoria][i]="demontaz"
                                    else
                                        UI.allCost=UI.allCost+v.cost
                                        UI.wybrana_czesc[v.kategoria][i]="montaz"
                                    end
                                end
                            end
                        end
                    end)
                end
                
                dxDrawText(v.name, sw/2-695/2/zoom+65/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, 695/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom, tocolor(220, 220, 220,UI.alpha), 1, assets.fonts[4], "left", "center")
    
                dxDrawImage(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+(57-42)/2/zoom+55/zoom+20/zoom+2+sY, 42/zoom, 42/zoom, not v.selected and assets.textures[9] or assets.textures[10], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
            end
        end
    
        -- footer
        dxDrawImage(sw/2-694/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom, 693/zoom, 57/zoom, assets.textures[11], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
    
        dxDrawImage(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom+(57-42)/2/zoom, 42/zoom, 42/zoom, #selected_parts > 0 and assets.textures[10] or assets.textures[9], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
    
        dxDrawText("Wybrano "..#selected_parts.." części", sw/2-694/2/zoom+(57-42)/2/zoom+60/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom, 0, sh/2-608/2/zoom+608/zoom-50/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[4], "left", "center")
        
        local cost=math.floor(UI.allCost-UI.giveCost)
        cost=cost < 0 and  "+ #56b553$#dcdcdc "..convertNumber(math.abs(cost)) or cost > 0 and "- #56b553$#dcdcdc "..convertNumber(cost) or cost == 0 and "#56b553$#dcdcdc 0"
        dxDrawText("#dcdcdcŁączny koszt: "..cost, sw/2-694/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom, sw/2-694/2/zoom+693/zoom, sh/2-608/2/zoom+608/zoom-50/zoom, tocolor(200, 200, 200,UI.alpha), 1, assets.fonts[4], "center", "center", false, false, false, true)
    
        dxDrawRectangle(sw/2-694/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-1, 693/zoom, 1, tocolor(85, 85, 85,UI.alpha))
    
        -- infos
        local name=getPlayerName(UI.target) or "?"
        local id=getElementData(UI.target, "user:id") or "(?)"
        dxDrawText("#929293Tuner: [#e5e322"..id.."#929293] "..name, sw/2-695/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom, 695/zoom+sw/2-695/2/zoom, sh/2-608/2/zoom+608/zoom, tocolor(255, 255, 255,UI.alpha), 1, assets.fonts[4], "center", "center", false, false, false, true)    

        onClick(sw/2-694/2/zoom+524/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom+(57-39)/2/zoom, 148/zoom, 39/zoom, function()
            if(UI.target and isElement(UI.target))then
                if(SPAM.getSpam())then return end

                if(#selected_parts > 0)then
                    triggerServerEvent("notis", resourceRoot, "Gracz "..getPlayerName(localPlayer).." przyjął oferte.", UI.target)
                    triggerServerEvent("start.tuning", resourceRoot, UI.target, selected_parts, UI.veh, tonumber(UI.allCost), tonumber(UI.giveCost))
                else
                    noti:noti("Najpierw zaznacz części.")
                    return
                end
            end

            UI.toggleUI()

            toggleControl('accelerate', false)
            toggleControl('enter_exit', false)
            toggleControl('brake_reverse', false)
            toggleControl('forwards', false)
            toggleControl('backwards', false)
            toggleControl('left', false)
            toggleControl('right', false)
        end)

        if(UI.podglad and getKeyState("mouse1"))then
            if(UI.animation or not UI.podglad)then return end

            for i,v in pairs(getVehicleUpgrades(UI.veh)) do
                removeVehicleUpgrade(UI.veh, v)
            end
            for i,v in pairs(UI.last_tuning) do
                addVehicleUpgrade(UI.veh, v)
            end
    
            setElementData(UI.veh, "vehicle:wheelsSettings", UI.last_wheels_data or {})

            showCursor(true)

            UI.podglad=false
            UI.animation = true
            animate(UI.alpha, 255, "Linear", 200, function(a)
                UI.alpha = a

                for i = 1,#UI.buttons do
                    buttons:buttonSetAlpha(i, a)
                end

                scroll:dxScrollSetAlpha(UI.scroll, a)
            end, function()
                UI.animation=false
            end)
        end

        onClick(sw/2-694/2/zoom+524/zoom-50/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom+(57-39)/2/zoom, 39/zoom, 39/zoom, function()
            if(UI.animation or UI.podglad)then return end

            if(#selected_parts < 1)then
                noti:noti("Musisz wybrać co najmniej jedną część.")
                return
            end

            noti:noti("Kliknij LPM aby zakończyć podgląd.")

            local data=getElementData(UI.veh, "vehicle:wheelsSettings") or {}
            for i,v in pairs(selected_parts) do
                if(not v.data_name)then
                    if(v.demontaz)then
                        removeVehicleUpgrade(UI.veh, v.id_czesci)
                    else
                        if(v.id_czesci ~= 1087)then
                            addVehicleUpgrade(UI.veh, v.id_czesci)
                        end
                    end
                else
                    data[v.data_index]=v.id
                end
            end
            setElementData(UI.veh, "vehicle:wheelsSettings", data, false)

            showCursor(false)

            UI.podglad=true
            UI.animation = true
            animate(UI.alpha, 0, "Linear", 200, function(a)
                UI.alpha = a

                for i = 1,#UI.buttons do
                    buttons:buttonSetAlpha(i, a)
                end

                scroll:dxScrollSetAlpha(UI.scroll, a)
            end, function()
                UI.animation=false
            end)
        end)

        onClick(sw/2-695/2/zoom+695/zoom-10/zoom-(55-10)/2/zoom, sh/2-608/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, function()
            if(UI.target and isElement(UI.target))then
                if(SPAM.getSpam())then return end

                noti:noti("Anulowałeś oferte od gracza "..getPlayerName(UI.target))
                triggerServerEvent("notis", resourceRoot, "Gracz "..getPlayerName(localPlayer).." anulował oferte.", UI.target)
            end

            UI.toggleUI()
            UI.target=false
        end)
    else
        UI.toggleUI()
        UI.target=false
        UI.offer=false
    end
end

UI.toggleUI=function(toggle, veh, target, rabat)
    if(toggle)then
        if(UI.offer or UI.animation or UI.target)then return end

        noti = exports.px_noti
        buttons = exports.px_buttons
        scroll = exports.px_scroll
        progressbar=exports.px_progressbar
        blur=exports.blur
    
        UI.allCost = 0
        UI.giveCost=0
        UI.wybrana_czesc={}
        UI.podglad=false
        UI.veh = veh
        UI.target = target
        UI.selected_category=1
        UI.parts=fillVehicleData(veh, rabat)
        UI.row_category=1
        UI.offer = true
        UI.animation = true
        UI.border=false
    
        assets.create()
    
        addEventHandler("onClientRender", root, UI.onRender)
        showCursor(true)
        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
    
        UI.buttons[1]=buttons:createButton(sw/2-694/2/zoom+524/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom+(57-39)/2/zoom, 148/zoom, 39/zoom, "PRZYJMIJ", 255, 10/zoom, false, false, ":px_workshop_tuning/assets/images/button_icon.png")
        UI.buttons[2]=buttons:createButton(sw/2-694/2/zoom+524/zoom-50/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom+(57-39)/2/zoom, 39/zoom, 39/zoom, "", 255, 10/zoom, false, false, ":px_workshop_tuning/assets/images/button_eye.png", {46,78,160})
    
        if(#UI.parts > 7)then
            UI.scroll=scroll:dxCreateScroll(sw/2-695/2/zoom+695/zoom-4/zoom, sh/2-608/2/zoom+55/zoom+22/zoom, 4/zoom, 4/zoom, 0, 7, UI.parts, 410/zoom, 255)
        end
    
        setElementFrozen(localPlayer, true)
    
        animate(UI.alpha, 255, "Linear", 200, function(a)
            UI.alpha = a
    
            for i = 1,#UI.buttons do
                buttons:buttonSetAlpha(i, a)
            end
    
            scroll:dxScrollSetAlpha(UI.scroll, a)
        end, function()
            setElementFrozen(localPlayer, false)
            UI.animation = nil
        end)
    
        toggleControl('accelerate', false)
        toggleControl('enter_exit', false)
        toggleControl('brake_reverse', false)
        toggleControl('forwards', false)
        toggleControl('backwards', false)
        toggleControl('left', false)
        toggleControl('right', false)
    
        UI.updateList()

        UI.last_tuning=getVehicleUpgrades(UI.veh)
        UI.last_wheels_data=getElementData(UI.veh, "vehicle:wheelsSettings") or {}
    else
        if(not UI.offer or UI.animation)then return end

        for i,v in pairs(getVehicleUpgrades(UI.veh)) do
            removeVehicleUpgrade(UI.veh, v)
        end
        for i,v in pairs(UI.last_tuning) do
            addVehicleUpgrade(UI.veh, v)
        end

        setElementData(UI.veh, "vehicle:wheelsSettings", UI.last_wheels_data or {})
        
        UI.last_tuning={}
        UI.last_wheels_data={}

        toggleControl('accelerate', true)
        toggleControl('enter_exit', true)
        toggleControl('brake_reverse', true)
        toggleControl('forwards', true)
        toggleControl('backwards', true)
        toggleControl('left', true)
        toggleControl('right', true)

        showCursor(false)

        UI.animation = true
        animate(UI.alpha, 0, "Linear", 200, function(a)
            UI.alpha = a

            for i = 1,#UI.buttons do
                buttons:buttonSetAlpha(i, a)
            end

            scroll:dxScrollSetAlpha(UI.scroll, a)
        end, function()
            removeEventHandler("onClientRender", root, UI.onRender)

            for i,v in pairs(UI.buttons) do
                buttons:destroyButton(v)
            end
            UI.buttons={}

            UI.animation = nil

            if(UI.scroll)then
                scroll:dxDestroyScroll(UI.scroll)
                UI.scroll = false
            end

            setElementData(localPlayer, "user:gui_showed", false, false)

            assets.destroy()

            UI.offer=false
        end)
    end
end

function sendOffer(player, vehicle, rabat)
    if(getElementHealth(vehicle) < 1000)then
        noti:noti("Aby ulepszyć pojazd, musi on być sprawny.", "error")
    else
        local uid=getElementData(player, "user:uid")    
        local owner=getElementData(vehicle, "vehicle:owner") or getElementData(vehicle, "vehicle:liderUID")
        if(not uid or not owner or (owner and owner ~= uid))then 
            noti:noti("Pojazd nie należy do kierowcy.", "error")
            return 
        end

        triggerServerEvent("send.offer", resourceRoot, player, vehicle, rabat)
    end
end

-- triggers

addEvent("send.offer", true)
addEventHandler("send.offer", resourceRoot, function(veh, target, rabat)
    if(getVehicleType(veh) ~= "Automobile")then return end
    
    UI.toggleUI(true, veh, target, rabat)
end)

addEvent("workshop->leaveZone", true)
addEventHandler("workshop->leaveZone", root, function(player)
    if(UI.target and UI.target == player)then
        toggleControl('accelerate', true)
        toggleControl('enter_exit', true)
        toggleControl('brake_reverse', true)
        toggleControl('forwards', true)
        toggleControl('backwards', true)
        toggleControl('left', true)
        toggleControl('right', true)

        UI.offer=false
        UI.target=false
    end
end)

addEvent("cancel.offer", true)
addEventHandler("cancel.offer", resourceRoot, function()
    UI.toggleUI()

    UI.offer=false
    UI.target=false
end)

addEvent("playSound", true)
addEventHandler("playSound", resourceRoot, function(pos)
    playSound3D("assets/sounds/repair.mp3", pos[1], pos[2], pos[3])
end)

-- job

UI.thenValues={}

UI.markerHit_start=function(hit, dim)
    if(hit ~= localPlayer or not dim)then return end

    if(SPAM.getSpam())then return end

    removeEventHandler("onClientMarkerHit", UI.marker, UI.markerHit_start)
    destroyElement(UI.marker)
    UI.marker=false

    local veh=UI.thenValues[3]
    if(veh and isElement(veh))then
        triggerServerEvent("create.object", resourceRoot)

        local pos={getVehicleComponentPosition(veh, "windscreen_dummy", "world")}
        if(not pos or not pos[1] or not pos[2] or not pos[3])then
            pos={getElementPosition(veh)}
        end

        local x,y,z=getStraightPosition(pos[1],pos[2],pos[3],veh,2)
        z=getGroundPosition(x,y,z)
        UI.marker=createMarker(x, y, z, "cylinder", 1.2, 200, 200, 0)
        setElementData(UI.marker, "icon", ":px_workshop_tuning/assets/images/wrench_1.png")

        addEventHandler("onClientMarkerHit", UI.marker, UI.markerHit_end)
    else
        noti:noti("Pojazd już nie istnieje.")
    end
end

UI.markerHit_end=function(hit, dim)
    if(hit ~= localPlayer or not dim)then return end

    if(SPAM.getSpam())then return end

    if(not UI.thenValues or (UI.thenValues and #UI.thenValues < 1))then return end

    local time=#UI.thenValues[2]*5000
    progressbar:createProgressbar(sw/2-671/2/zoom, sh-50/zoom, 671/zoom, 4/zoom, "Trwa montaż części...", 15/zoom, time, false, 0)

    toggleControl('accelerate', false)
    toggleControl('enter_exit', false)
    toggleControl('brake_reverse', false)
    toggleControl('forwards', false)
    toggleControl('backwards', false)
    toggleControl('left', false)
    toggleControl('right', false)

    triggerServerEvent("animation", resourceRoot, true)

    setTimer(function()
        removeEventHandler("onClientMarkerHit", UI.marker, UI.markerHit_end)
        destroyElement(UI.marker)
        UI.marker=false

        triggerServerEvent("destroy.object", resourceRoot)

        triggerServerEvent("update.tuning", resourceRoot, UI.thenValues[1], UI.thenValues[2], UI.thenValues[3], UI.thenValues[4], UI.thenValues[5])

        UI.thenValues={}

        toggleControl('accelerate', true)
        toggleControl('enter_exit', true)
        toggleControl('brake_reverse', true)
        toggleControl('forwards', true)
        toggleControl('backwards', true)
        toggleControl('left', true)
        toggleControl('right', true)

        triggerServerEvent("animation", resourceRoot, false)

        progressbar:destroyProgressbar()
    end, time, 1)
end

addEvent("start.tuning", true)
addEventHandler("start.tuning", resourceRoot, function(target, parts, veh, cost, giveCost)
    local data=getElementData(localPlayer, "workshop:zone")
    if(not data)then return end
    
    if(not data.tune_pos)then return end

    UI.marker=createMarker(data.tune_pos[1], data.tune_pos[2], data.tune_pos[3], "cylinder", 1.2, 200, 200, 0)
    setElementData(UI.marker, "icon", ":px_workshop_tuning/assets/images/wrench_1.png")
    addEventHandler("onClientMarkerHit", UI.marker, UI.markerHit_start)

    noti:noti("Udaj się pod półkę, aby wziąć walizke z częsciami.")

    UI.thenValues={target, parts, veh, cost, giveCost}
end)

-- useful

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
	if(not isCursorShowing() or UI.animation)then return end

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

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end

function getStraightPosition(x,y,z,element,p)
    local _,_,rot = getElementRotation(element)
    local cx, cy = getPointFromDistanceRotation(x, y, p, (-rot))
    return cx,cy,z
end

-- on stop

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)