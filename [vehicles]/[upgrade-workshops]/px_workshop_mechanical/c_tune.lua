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

local sw,sh=guiGetScreenSize()
local zoom = 1
local fh = 1920

if sw < fh then
  zoom = math.min(2,fh/sw)
end

local blur=exports.blur
local btns=exports.px_buttons
local export=exports.px_custom_vehicles
local noti=exports.px_noti

local ui={}

-- assets

local assets={}
assets.list={
    texs={
        "textures/bg.png",
        "textures/close.png",
        "textures/row.png",
    
        "textures/bar_1.png",
        "textures/bar_2.png",
        "textures/bar_3.png",
        "textures/bar_4.png",
        "textures/bar_5.png",
        "textures/bar_6.png",
        "textures/bar_7.png",
    
        "textures/item.png",
        "textures/mk_bg.png",
        "textures/check.png",
        "textures/check_gray.png",
    },

    fonts={
        {"Regular", 15},
        {"Regular", 12},
        {"Regular", 10},
        {"Bold", 12},
        {"Bold", 10},
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

ui.selected=1
ui.selectedMenu=false
ui.panel=false

ui.alpha=0
ui.menuAlpha=0

ui.triggerBlock=false

ui.btns={}

ui.pos={
    bg={sw/2-742/2/zoom, sh/2-421/2/zoom, 742/zoom, 421/zoom},

    ht={sw/2-742/2/zoom, sh/2-421/2/zoom, sw/2-742/2/zoom+742/zoom, sh/2-421/2/zoom+56/zoom},
    hx={sw/2-742/2/zoom+742/zoom-10/zoom-(56-10)/2/zoom, sh/2-421/2/zoom+(56-10)/2/zoom, 10/zoom, 10/zoom},

    i={sw/2-742/2/zoom, sh/2-421/2/zoom+56/zoom, 371/zoom, 92/zoom, 371/zoom, 92/zoom},

    mb={sw/2-742/2/zoom, sh/2-421/2/zoom+428/zoom, 742/zoom, 202/zoom},
    
    -- 1 bar
    mbo={sw/2-742/2/zoom+100/zoom, sh/2-421/2/zoom+428/zoom+20/zoom, 77/zoom, 33/zoom, 154/zoom, 20/zoom},
    mbt1={sw/2-742/2/zoom, sh/2-421/2/zoom+428/zoom+180/zoom, sw/2-742/2/zoom+742/zoom, sh/2-421/2/zoom+428/zoom+202/zoom-70/zoom},
    mbl={sw/2-742/2/zoom, sh/2-421/2/zoom+428/zoom+202/zoom-30/zoom, 742/zoom, 1},
    mbt2={sw/2-742/2/zoom, sh/2-421/2/zoom+428/zoom+202/zoom-30/zoom, sw/2-742/2/zoom+742/zoom, sh/2-421/2/zoom+428/zoom+202/zoom},
    --

    -- 2 bar
    mbmk={sw/2, sh/2-421/2/zoom+428/zoom+10/zoom, 114/zoom, 80/zoom, 150/zoom, 15/zoom, 36/zoom, 10/zoom},
    --
}

ui.info={}

ui.lastTrigger=0
ui.vehicle=false
ui.upgrades={
    engine_cost=44500,

    turbo={
        {"Turbo", 24900},
        {"TwinTurbo", 43400},
        {"BiTurbo", 50500},
    },

    mk={
        {"MK1", 28200},
        {"MK2", 49750},
    },

    suspension={
        {"Terenowe H2", 7800, "Zawieszenie terenowe podwyższa samochód o 2 poziomy"},
        {"Drogowe H1", 5800, "Zawieszenie drogowe podwyższa samochód o 1 poziom"},
        {"Sportowe H-1", 12800, "Zawieszenie sportowe obniża samochód o 1 poziom"},
        {"Wyścigowe H-2", 15800, "Zawieszenie wyścigowe obniża samochód o 2 poziomy"},
        {"Regulowane HR", 35100, "Zawieszenie regulowane pozwala na regulację wysokości w interakcji o 11 poziomów góra-dół."},
    },

    brakes={
        {"Classic", 1800},
        {"QuickDrive", 12600},
        {"ProSpeed", 25500},
        {"MaxFlow", 44200},
    },

    tanks={
        {25, 0},
        {40, 15700},
        {60, 32000},
        {80, 69100},
    },

    nitro={
        {"Nitro x2", 175000},
        {"Nitro x5", 350000},
        {"Pulsacyjne", 550000},
    }
}

ui.panels={
    {name="Pojemność silnika", icon=4, render=function(p)
        blur:dxDrawBlur(p.mb[1], p.mb[2], p.mb[3], p.mb[4], tocolor(255, 255, 255, ui.menuAlpha))
        dxDrawImage(p.mb[1], p.mb[2], p.mb[3], p.mb[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))

        dxDrawImage(p.mb[1], p.mbo[2], p.mb[3], p.mbo[4], assets.textures[11], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha > 150 and 150 or ui.menuAlpha))

        local veh=getPedOccupiedVehicle(localPlayer)
        local cost=ui.upgrades.engine_cost
        local nextEngine=false
        for i,v in pairs(ui.info.engines) do
            local sX=(p.mbo[5])*(i-1)

            local a=tonumber(ui.info.engine) > tonumber(v) and 150 or 255
            a=ui.menuAlpha > a and a or ui.menuAlpha

            if(tonumber(ui.info.engine) == tonumber(v))then
                dxDrawImage(p.mbo[1]+sX, p.mbo[2]+(p.mbo[4]-p.mbo[6])/2, p.mbo[6], p.mbo[6], assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))
            end

            dxDrawText(string.format("%.1f", v).." L", p.mbo[1]+sX, p.mbo[2], p.mbo[3]+p.mbo[1]+sX, p.mbo[4]+p.mbo[2], tocolor(200, 200, 200, a), 1, assets.fonts[4], "center", "center")

            if(not nextEngine and tonumber(v) > tonumber(ui.info.engine))then
                nextEngine=v
            end
        end

        if(not ui.btns[1])then
            if(nextEngine)then
                ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+85/zoom, 147/zoom, 38/zoom, "ULEPSZ", ui.menuAlpha, 10, false, false)
            end
        else
            onClick(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+85/zoom, 147/zoom, 38/zoom, function()
                if(SPAM.getSpam())then return end

                triggerLatentServerEvent("buy.engine", resourceRoot, ui.vehicle, nextEngine, cost)
                ui.triggerBlock=true
            end)
        end

        local text=nextEngine and "Koszt zmiany pojemności silnika do "..string.format("%.1f", nextEngine).." wynosi #3e994d$#ffffff"..cost or "Posiadasz już maksymalny dostępny silnik do tego pojazdu."
        dxDrawText(text, p.mbt1[1], p.mbt1[2], p.mbt1[3], p.mbt1[4], tocolor(200, 200, 200, ui.menuAlpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
        dxDrawRectangle(p.mbl[1], p.mbl[2], p.mbl[3], p.mbl[4], tocolor(80, 80, 80, ui.menuAlpha))
        dxDrawText("Operacji zmiany silnika na większą pojemnść nie można cofnąć, bądź pewny swojej decyzji!", p.mbt2[1], p.mbt2[2], p.mbt2[3], p.mbt2[4], tocolor(135, 23, 23, ui.menuAlpha), 1, assets.fonts[3], "center", "center")
    end},

    {name="Układy MK", icon=5, render=function(p)
        blur:dxDrawBlur(p.mb[1], p.mb[2], p.mb[3], p.mb[4], tocolor(255, 255, 255, ui.menuAlpha))
        dxDrawImage(p.mb[1], p.mb[2], p.mb[3], p.mb[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))

        local upgrades=ui.upgrades.mk
        local width=(p.mbmk[5]*#upgrades)
        local k=0
        for i,v in pairs(upgrades) do
            k=k+1

            local have=ui.info[v[1]]

            local a=ui.selected == i and 255 or have and 200 or 100
            a=ui.menuAlpha > a and a or ui.menuAlpha

            local sX=(p.mbmk[5])*(k-1)
            local x,y,w,h=p.mb[1]+((p.mb[3])-width)/2+sX+p.mbmk[6], p.mbmk[2], p.mbmk[3], p.mbmk[4]
            dxDrawImage(x,y,w,h, assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, a))
            onClick(x,y,w,h,function()
                if(ui.selected == i)then
                    ui.selected=false
                else
                    ui.selected=i
                end
                btns:destroyButton(ui.btns[1])
                ui.btns[1]=nil
            end)

            dxDrawText(v[1], x,y,w+x,y+h-p.mbmk[8]/2, tocolor(200, 200, 200, a), 1, assets.fonts[4], "center", "bottom")

            local ww,hh=dxGetMaterialSize(assets.textures[5])
            dxDrawImage(x+(p.mbmk[3]-ww/zoom)/2,y+p.mbmk[8],ww/zoom,hh/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, a))

            dxDrawImage(x+w-p.mbo[6]/2, y+h-p.mbo[6], p.mbo[6], p.mbo[6], have and assets.textures[13] or assets.textures[14], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))
        end

        local info=upgrades[ui.selected]
        local cost=0
        if(info)then
            local veh=getPedOccupiedVehicle(localPlayer)
            cost=info[2]
        end

        if(not ui.btns[1])then
            if(ui.selected)then
                if(info and ui.info[info[1]])then
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZDEMONTUJ", ui.menuAlpha, 10, false, false, false, {135,82,37})
                else
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZAKUP", ui.menuAlpha, 10, false, false)
                end
            end
        elseif(ui.btns[1])then
            onClick(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, function()
                if(info)then
                    if(SPAM.getSpam())then return end

                    if(ui.info[info[1]])then
                        triggerLatentServerEvent("buy.mk", resourceRoot, ui.vehicle, info[1], cost/2, "sell")
                    else
                        triggerLatentServerEvent("buy.mk", resourceRoot, ui.vehicle, info[1], cost, "buy")
                    end
                    ui.triggerBlock=true
                end
            end)
        end

        local text=(info and ui.info[info[1]]) and "Za demontaż układu "..info[1].." otrzymasz #3e994d$#ffffff"..cost/2 or info and "Instalacja układu "..info[1].." wynosi #3e994d$#ffffff"..cost or "Zaznacz układ który Cię interesuje."
        dxDrawText(text, p.mbt1[1], p.mbt1[2], p.mbt1[3], p.mbt1[4], tocolor(200, 200, 200, ui.menuAlpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
        dxDrawRectangle(p.mbl[1], p.mbl[2], p.mbl[3], p.mbl[4], tocolor(80, 80, 80, ui.menuAlpha))
        dxDrawText("Układy MK pozwalają na dostosowanie pojazdu pod siebie.", p.mbt2[1], p.mbt2[2], p.mbt2[3], p.mbt2[4], tocolor(100, 100, 100, ui.menuAlpha), 1, assets.fonts[3], "center", "center")
    end},

    {name="Turbosprężarka", icon=6, render=function(p)
        blur:dxDrawBlur(p.mb[1], p.mb[2], p.mb[3], p.mb[4], tocolor(255, 255, 255, ui.menuAlpha))
        dxDrawImage(p.mb[1], p.mb[2], p.mb[3], p.mb[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))

        local upgrades=ui.upgrades.turbo
        local width=(p.mbmk[5]*#upgrades)
        for i,v in pairs(upgrades) do
            local have=ui.info["turbo"] and ui.info["turbo"] == v[1]

            local a=ui.selected == i and 255 or have and 200 or 100
            a=ui.menuAlpha > a and a or ui.menuAlpha

            local sX=(p.mbmk[5])*(i-1)
            local x,y,w,h=p.mb[1]+((p.mb[3])-width)/2+sX+p.mbmk[6], p.mbmk[2], p.mbmk[3], p.mbmk[4]
            dxDrawImage(x,y,w,h, assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, a))
            onClick(x,y,w,h,function()
                if(ui.selected == i)then
                    ui.selected=false
                else
                    ui.selected=i
                end
                btns:destroyButton(ui.btns[1])
                ui.btns[1]=nil
            end)

            dxDrawText(v[1], x,y,w+x,y+h-p.mbmk[8]/2, tocolor(200, 200, 200, a), 1, assets.fonts[4], "center", "bottom")

            local ww,hh=dxGetMaterialSize(assets.textures[6])
            dxDrawImage(x+(p.mbmk[3]-ww/zoom)/2,y+p.mbmk[8],ww/zoom,hh/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, a))

            local have_id=ui.info["turbo"] and ui.info["turbo"] == v[1] and i or 0
            if(ui.info["turbo"] and (have_id > i or have_id ~= i))then
                dxDrawImage(x+w-(p.mbo[6]/2)/2, y+h-p.mbo[6]/2, p.mbo[6]/2, p.mbo[6]/2, assets.textures[2], 0, 0, 0, tocolor(135, 23, 23, ui.menuAlpha))
            elseif(ui.info["turbo"])then
                dxDrawImage(x+w-p.mbo[6]/2, y+h-p.mbo[6], p.mbo[6], p.mbo[6], assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))
            end
        end

        local info=upgrades[ui.selected]
        local cost=0
        if(info)then
            local veh=getPedOccupiedVehicle(localPlayer)
            cost=info[2]
        end

        if(not ui.btns[1])then
            if(ui.selected)then
                if(info and ui.info["turbo"] and ui.info["turbo"] == info[1])then
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZDEMONTUJ", ui.menuAlpha, 10, false, false, false, {135,82,37})
                else
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZAKUP", ui.menuAlpha, 10, false, false)
                end
            end
        elseif(ui.btns[1])then
            onClick(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, function()
                if(info)then
                    if(ui.info["turbo"] and ui.info["turbo"] == info[1])then
                        if(SPAM.getSpam())then return end

                        triggerLatentServerEvent("buy.misc", resourceRoot, ui.vehicle, "turbo", info[1], cost/2, "sell")
                        ui.triggerBlock=true
                    elseif(not ui.info["turbo"])then
                        if(SPAM.getSpam())then return end

                        triggerLatentServerEvent("buy.misc", resourceRoot, ui.vehicle, "turbo", info[1], cost, "buy")
                        ui.triggerBlock=true
                    else
                        noti:noti("Możesz mieć zamontowany jeden układ turbo.", "error")
                    end
                end
            end)
        end

        local text=(info and ui.info["turbo"] and ui.info["turbo"] == info[1]) and "Za demontaż układu "..info[1].." otrzymasz #3e994d$#ffffff"..cost/2 or info and "Instalacja układu "..info[1].." wynosi #3e994d$#ffffff"..cost or "Zaznacz układ który Cię interesuje."
        dxDrawText(text, p.mbt1[1], p.mbt1[2], p.mbt1[3], p.mbt1[4], tocolor(200, 200, 200, ui.menuAlpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
        dxDrawRectangle(p.mbl[1], p.mbl[2], p.mbl[3], p.mbl[4], tocolor(80, 80, 80, ui.menuAlpha))
        dxDrawText("Turbosprężarka pozwala na lepsze osiągi względem przyśpieszenia.", p.mbt2[1], p.mbt2[2], p.mbt2[3], p.mbt2[4], tocolor(100, 100, 100, ui.menuAlpha), 1, assets.fonts[3], "center", "center")
    end},

    {name="Zawieszenie", icon=7, render=function(p)
        blur:dxDrawBlur(p.mb[1], p.mb[2], p.mb[3], p.mb[4], tocolor(255, 255, 255, ui.menuAlpha))
        dxDrawImage(p.mb[1], p.mb[2], p.mb[3], p.mb[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))

        local upgrades=ui.upgrades.suspension
        local width=(p.mbmk[5]*#upgrades)
        for i,v in pairs(upgrades) do
            local have=ui.info["suspension"] and ui.info["suspension"] == v[1]

            local a=ui.selected == i and 255 or have and 200 or 100
            a=ui.menuAlpha > a and a or ui.menuAlpha

            local sX=(p.mbmk[5])*(i-1)
            local x,y,w,h=p.mb[1]+((p.mb[3])-width)/2+sX+p.mbmk[6], p.mbmk[2], p.mbmk[3], p.mbmk[4]
            dxDrawImage(x,y,w,h, assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, a))
            onClick(x,y,w,h,function()
                if(ui.selected == i)then
                    ui.selected=false
                else
                    ui.selected=i
                end
                btns:destroyButton(ui.btns[1])
                ui.btns[1]=nil
            end)

            dxDrawText(v[1], x,y,w+x,y+h-p.mbmk[8]/2, tocolor(200, 200, 200, a), 1, assets.fonts[5], "center", "bottom")

            local ww,hh=dxGetMaterialSize(assets.textures[7])
            dxDrawImage(x+(p.mbmk[3]-ww/zoom)/2,y+p.mbmk[8],ww/zoom,hh/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, a))

            local have_id=ui.info["suspension"] and ui.info["suspension"] == v[1] and i or 0
            if(ui.info["suspension"] and (have_id > i or have_id ~= i))then
                dxDrawImage(x+w-(p.mbo[6]/2)/2, y+h-p.mbo[6]/2, p.mbo[6]/2, p.mbo[6]/2, assets.textures[2], 0, 0, 0, tocolor(135, 23, 23, ui.menuAlpha))
            elseif(ui.info["suspension"])then
                dxDrawImage(x+w-p.mbo[6]/2, y+h-p.mbo[6], p.mbo[6], p.mbo[6], assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))
            end        
        end

        local info=upgrades[ui.selected]
        local cost=0
        if(info)then
            local veh=getPedOccupiedVehicle(localPlayer)
            cost=info[2]
        end

        if(not ui.btns[1])then
            if(ui.selected)then
                if(info and ui.info["suspension"] and ui.info["suspension"] == info[1])then
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZDEMONTUJ", ui.menuAlpha, 10, false, false, false, {135,82,37})
                else
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZAKUP", ui.menuAlpha, 10, false, false)
                end
            end
        elseif(ui.btns[1])then
            onClick(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, function()
                if(info)then
                    if(ui.info["suspension"] and ui.info["suspension"] == info[1])then
                        if(SPAM.getSpam())then return end

                        triggerLatentServerEvent("buy.misc", resourceRoot, ui.vehicle, "suspension", info[1], cost/2, "sell")
                        ui.triggerBlock=true
                    elseif(not ui.info["suspension"])then
                        if(SPAM.getSpam())then return end

                        triggerLatentServerEvent("buy.misc", resourceRoot, ui.vehicle, "suspension", info[1], cost, "buy")
                        ui.triggerBlock=true
                    end
                else
                    noti:noti("Odczekaj sekunde przed następną akcją.", "error")
                end
            end)
        end

        local text=(info and ui.info["suspension"] and ui.info["suspension"] == info[1]) and "Za demontaż zawieszenia "..info[1].." otrzymasz #3e994d$#ffffff"..cost/2 or info and "Instalacja zawieszenia "..info[1].." wynosi #3e994d$#ffffff"..cost or "Zaznacz zawieszenie który Cię interesuje."
        dxDrawText(text, p.mbt1[1], p.mbt1[2], p.mbt1[3], p.mbt1[4], tocolor(200, 200, 200, ui.menuAlpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
        dxDrawRectangle(p.mbl[1], p.mbl[2], p.mbl[3], p.mbl[4], tocolor(80, 80, 80, ui.menuAlpha))
        dxDrawText(info and info[3] or "Zawieszenie pozwala na wybraną przez nas konfiguracje wysokości podwozia, lub regulacje zawieszenia.", p.mbt2[1], p.mbt2[2], p.mbt2[3], p.mbt2[4], tocolor(100, 100, 100, ui.menuAlpha), 1, assets.fonts[3], "center", "center")
    end},

    {name="Hamulce", icon=8, render=function(p)
        blur:dxDrawBlur(p.mb[1], p.mb[2], p.mb[3], p.mb[4], tocolor(255, 255, 255, ui.menuAlpha))
        dxDrawImage(p.mb[1], p.mb[2], p.mb[3], p.mb[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))

        local upgrades=ui.upgrades.brakes
        local width=(p.mbmk[5]*#upgrades)
        for i,v in pairs(upgrades) do
            local have=ui.info["brakes"] and ui.info["brakes"] == v[1]

            local a=ui.selected == i and 255 or have and 200 or 100
            a=ui.menuAlpha > a and a or ui.menuAlpha

            local sX=(p.mbmk[5])*(i-1)
            local x,y,w,h=p.mb[1]+((p.mb[3])-width)/2+sX+p.mbmk[6], p.mbmk[2], p.mbmk[3], p.mbmk[4]
            dxDrawImage(x,y,w,h, assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, a))
            onClick(x,y,w,h,function()
                if(ui.selected == i)then
                    ui.selected=false
                else
                    ui.selected=i
                end
                btns:destroyButton(ui.btns[1])
                ui.btns[1]=nil
            end)

            dxDrawText(v[1], x,y,w+x,y+h-p.mbmk[8]/2, tocolor(200, 200, 200, a), 1, assets.fonts[4], "center", "bottom")

            local ww,hh=dxGetMaterialSize(assets.textures[8])
            dxDrawImage(x+(p.mbmk[3]-ww/zoom)/2,y+p.mbmk[8],ww/zoom,hh/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, a))

            local have_id=ui.info["brakes"] and ui.info["brakes"] == v[1] and i or 0
            if(ui.info["brakes"] and (have_id > i or have_id ~= i))then
                dxDrawImage(x+w-(p.mbo[6]/2)/2, y+h-p.mbo[6]/2, p.mbo[6]/2, p.mbo[6]/2, assets.textures[2], 0, 0, 0, tocolor(135, 23, 23, ui.menuAlpha))
            elseif(ui.info["brakes"])then
                dxDrawImage(x+w-p.mbo[6]/2, y+h-p.mbo[6], p.mbo[6], p.mbo[6], assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))
            end        
        end

        local info=upgrades[ui.selected]
        local cost=0
        if(info)then
            local veh=getPedOccupiedVehicle(localPlayer)
            cost=info[2]
        end

        if(not ui.btns[1])then
            if(ui.selected)then
                if(info and ui.info["brakes"] and ui.info["brakes"] == info[1])then
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZDEMONTUJ", ui.menuAlpha, 10, false, false, false, {135,82,37})
                else
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZAKUP", ui.menuAlpha, 10, false, false)
                end
            end
        elseif(ui.btns[1])then
            onClick(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, function()
                if(info)then
                    if(ui.info["brakes"] and ui.info["brakes"] == info[1])then
                        if(SPAM.getSpam())then return end

                        triggerLatentServerEvent("buy.misc", resourceRoot, ui.vehicle, "brakes", info[1], cost/2, "sell")
                        ui.triggerBlock=true
                    elseif(not ui.info["brakes"])then
                        if(SPAM.getSpam())then return end

                        triggerLatentServerEvent("buy.misc", resourceRoot, ui.vehicle, "brakes", info[1], cost, "buy")
                        ui.triggerBlock=true
                    else
                        noti:noti("Możesz mieć zamontowany jeden układ hamulcowy.", "error")
                    end
                else
                    noti:noti("Odczekaj sekunde przed następną akcją.", "error")
                end
            end)
        end

        local text=(info and ui.info["brakes"] and ui.info["brakes"] == info[1]) and "Za demontaż układu hamulcowego "..info[1].." otrzymasz #3e994d$#ffffff"..cost/2 or info and "Instalacja układu hamulcowego "..info[1].." wynosi #3e994d$#ffffff"..cost or "Zaznacz zawieszenie który Cię interesuje."
        dxDrawText(text, p.mbt1[1], p.mbt1[2], p.mbt1[3], p.mbt1[4], tocolor(200, 200, 200, ui.menuAlpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
        dxDrawRectangle(p.mbl[1], p.mbl[2], p.mbl[3], p.mbl[4], tocolor(80, 80, 80, ui.menuAlpha))
        dxDrawText("Chcesz driftować? A może trzymać się drogi! Dopasuj hamulce pojazdu do swoich upodobań.", p.mbt2[1], p.mbt2[2], p.mbt2[3], p.mbt2[4], tocolor(100, 100, 100, ui.menuAlpha), 1, assets.fonts[3], "center", "center")
    end},

    {name="Pojemność baku", icon=9, render=function(p)
        blur:dxDrawBlur(p.mb[1], p.mb[2], p.mb[3], p.mb[4], tocolor(255, 255, 255, ui.menuAlpha))
        dxDrawImage(p.mb[1], p.mb[2], p.mb[3], p.mb[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))

        dxDrawImage(p.mb[1], p.mbo[2], p.mb[3], p.mbo[4], assets.textures[11], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha > 150 and 150 or ui.menuAlpha))

        local nextTank=false
        for i,v in pairs(ui.upgrades.tanks) do
            local sX=(p.mbo[5])*(i-1)

            local a=tonumber(ui.info.tank) > tonumber(v[1]) and 150 or 255
            a=ui.menuAlpha > a and a or ui.menuAlpha

            if(tonumber(ui.info.tank) == tonumber(v[1]))then
                dxDrawImage(p.mbo[1]+sX, p.mbo[2]+(p.mbo[4]-p.mbo[6])/2, p.mbo[6], p.mbo[6], assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))
            end

            dxDrawText(v[1].." L", p.mbo[1]+sX, p.mbo[2], p.mbo[3]+p.mbo[1]+sX, p.mbo[4]+p.mbo[2], tocolor(200, 200, 200, a), 1, assets.fonts[4], "center", "center")

            if(not nextTank and tonumber(v[1]) > tonumber(ui.info.tank))then
                nextTank=v
            end
        end

        local veh=getPedOccupiedVehicle(localPlayer)
        local cost=0
        if(nextTank)then
            cost=nextTank[2]
        end

        if(not ui.btns[1] and nextTank)then
            ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+85/zoom, 147/zoom, 38/zoom, "ULEPSZ", ui.menuAlpha, 10, false, false)
        elseif(ui.btns[1])then
            onClick(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+85/zoom, 147/zoom, 38/zoom, function()
                if(SPAM.getSpam())then return end

                triggerLatentServerEvent("buy.tank", resourceRoot, ui.vehicle, nextTank[1], cost)
                ui.triggerBlock=true
            end)
        end

        local text=nextTank and "Koszt zmiany pojemności baku do "..string.format("%.1f", nextTank[1]).." L wynosi #3e994d$#ffffff"..cost or "Posiadasz już maksymalny dostępny bak do tego pojazdu."
        dxDrawText(text, p.mbt1[1], p.mbt1[2], p.mbt1[3], p.mbt1[4], tocolor(200, 200, 200, ui.menuAlpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
        dxDrawRectangle(p.mbl[1], p.mbl[2], p.mbl[3], p.mbl[4], tocolor(80, 80, 80, ui.menuAlpha))
        dxDrawText("Operacji zmiany pojemności baku nie można cofnąć, bądź pewny swojej decyzji!", p.mbt2[1], p.mbt2[2], p.mbt2[3], p.mbt2[4], tocolor(135, 23, 23, ui.menuAlpha), 1, assets.fonts[3], "center", "center")
    end},

    {name="Instalacja NOS", icon=10, render=function(p)
        blur:dxDrawBlur(p.mb[1], p.mb[2], p.mb[3], p.mb[4], tocolor(255, 255, 255, ui.menuAlpha))
        dxDrawImage(p.mb[1], p.mb[2], p.mb[3], p.mb[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))

        local upgrades=ui.upgrades.nitro
        local width=(p.mbmk[5]*#upgrades)
        for i,v in pairs(upgrades) do
            local have=ui.info["nitro"] and ui.info["nitro"] == v[1]

            local a=ui.selected == i and 255 or have and 200 or 100
            a=ui.menuAlpha > a and a or ui.menuAlpha

            local sX=(p.mbmk[5])*(i-1)
            local x,y,w,h=p.mb[1]+((p.mb[3])-width)/2+sX+p.mbmk[6], p.mbmk[2], p.mbmk[3], p.mbmk[4]
            dxDrawImage(x,y,w,h, assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, a))
            onClick(x,y,w,h,function()
                if(ui.selected == i)then
                    ui.selected=false
                else
                    ui.selected=i
                end
                btns:destroyButton(ui.btns[1])
                ui.btns[1]=nil
            end)

            dxDrawText(v[1], x,y,w+x,y+h-p.mbmk[8]/2, tocolor(200, 200, 200, a), 1, assets.fonts[4], "center", "bottom")

            local ww,hh=dxGetMaterialSize(assets.textures[10])
            dxDrawImage(x+(p.mbmk[3]-ww/zoom)/2,y+p.mbmk[8],ww/zoom,hh/zoom, assets.textures[10], 0, 0, 0, tocolor(255, 255, 255, a))

            local have_id=ui.info["nitro"] and ui.info["nitro"] == v[1] and i or 0
            if(ui.info["nitro"] and (have_id > i or have_id ~= i))then
                dxDrawImage(x+w-(p.mbo[6]/2)/2, y+h-p.mbo[6]/2, p.mbo[6]/2, p.mbo[6]/2, assets.textures[2], 0, 0, 0, tocolor(135, 23, 23, ui.menuAlpha))
            elseif(ui.info["nitro"])then
                dxDrawImage(x+w-p.mbo[6]/2, y+h-p.mbo[6], p.mbo[6], p.mbo[6], assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))
            end        
        end

        local info=upgrades[ui.selected]
        local cost=0
        if(info)then
            local veh=getPedOccupiedVehicle(localPlayer)
            cost=info[2]
        end

        if(not ui.btns[1])then
            if(ui.selected)then
                if(info and ui.info["nitro"] and ui.info["nitro"] == info[1])then
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZDEMONTUJ", ui.menuAlpha, 10, false, false, false, {135,82,37})
                else
                    ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, "ZAKUP", ui.menuAlpha, 10, false, false)
                end
            end
        elseif(ui.btns[1])then
            onClick(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+100/zoom, 147/zoom, 38/zoom, function()
                if(info)then
                    if(ui.info["nitro"] and ui.info["nitro"] == info[1])then
                        if(SPAM.getSpam())then return end

                        triggerLatentServerEvent("buy.misc", resourceRoot, ui.vehicle, "nitro", info[1], cost/2, "sell")
                        ui.triggerBlock=true
                    elseif(not ui.info["nitro"])then
                        if(SPAM.getSpam())then return end

                        triggerLatentServerEvent("buy.misc", resourceRoot, ui.vehicle, "nitro", info[1], cost, "buy")
                        ui.triggerBlock=true
                    else
                        noti:noti("Możesz mieć zamontowany jeden układ NOS.", "error")
                    end
                end
            end)
        end

        local text=(info and ui.info["nitro"] and ui.info["nitro"] == info[1]) and "Za demontaż układu NOS "..info[1].." otrzymasz #3e994d$#ffffff"..cost/2 or info and "Instalacja układu NOS "..info[1].." wynosi #3e994d$#ffffff"..cost or "Zaznacz zawieszenie który Cię interesuje."
        dxDrawText(text, p.mbt1[1], p.mbt1[2], p.mbt1[3], p.mbt1[4], tocolor(200, 200, 200, ui.menuAlpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
        dxDrawRectangle(p.mbl[1], p.mbl[2], p.mbl[3], p.mbl[4], tocolor(80, 80, 80, ui.menuAlpha))
        dxDrawText("Układ NOS jest to nitro - inaczej podtlenek azotu.", p.mbt2[1], p.mbt2[2], p.mbt2[3], p.mbt2[4], tocolor(100, 100, 100, ui.menuAlpha), 1, assets.fonts[3], "center", "center")
    end},

    {name="Butla LPG", icon=9, render=function(p)
        local veh=getPedOccupiedVehicle(localPlayer)
        local cost=12800

        blur:dxDrawBlur(p.mb[1], p.mb[2], p.mb[3], p.mb[4], tocolor(255, 255, 255, ui.menuAlpha))
        dxDrawImage(p.mb[1], p.mb[2], p.mb[3], p.mb[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha))

        dxDrawImage(p.mb[1], p.mbo[2], p.mb[3], p.mbo[4], assets.textures[11], 0, 0, 0, tocolor(255, 255, 255, ui.menuAlpha > 150 and 150 or ui.menuAlpha))
        dxDrawText("Koszt zakupu butli LPG wynosi "..cost.."$.", p.mb[1], p.mbo[2], p.mb[3]+p.mb[1], p.mbo[4]+p.mbo[2], tocolor(200, 200, 200, a), 1, assets.fonts[4], "center", "center")

        if(not ui.btns[1])then
            ui.btns[1]=btns:createButton(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+90/zoom, 147/zoom, 38/zoom, "ZAKUP", ui.menuAlpha, 10, false, false)
        elseif(ui.btns[1])then
            onClick(p.mb[1]+(p.mb[3]-147/zoom)/2, p.mb[2]+85/zoom, 147/zoom, 38/zoom, function()
                if(SPAM.getSpam())then return end

                triggerLatentServerEvent("buy.lpg", resourceRoot, ui.vehicle, cost)
                ui.triggerBlock=true
            end)
        end

        dxDrawRectangle(p.mbl[1], p.mbl[2], p.mbl[3], p.mbl[4], tocolor(80, 80, 80, ui.menuAlpha))
        dxDrawText("Operacji kupna butli LPG nie można cofnąć, bądź pewny swojej decyzji!", p.mbt2[1], p.mbt2[2], p.mbt2[3], p.mbt2[4], tocolor(135, 23, 23, ui.menuAlpha), 1, assets.fonts[3], "center", "center")
    end},
}

-- rendering, etc

ui.onRender=function()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(not ui.vehicle or (ui.vehicle and not isElement(ui.vehicle)) or not veh or veh ~= ui.vehicle)then ui.destroy() return end

    local p=ui.pos

    blur:dxDrawBlur(p.bg[1], p.bg[2], p.bg[3], p.bg[4], tocolor(255, 255, 255, ui.alpha))
    dxDrawImage(p.bg[1], p.bg[2], p.bg[3], p.bg[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

    dxDrawText("Tuning mechaniczny", p.ht[1], p.ht[2], p.ht[3], p.ht[4], tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "center", "center")
    dxDrawImage(p.hx[1], p.hx[2], p.hx[3], p.hx[4], assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

    local sY=0
    for i,v in pairs(ui.panels) do
        local sX=i%2 == 1 and 0 or p.i[5]

        local x=(i+1)%2
        sY=x == 0 and sY+p.i[6] or sY

        local x,y,w,h=p.i[1]+sX, p.i[2]+(sY-p.i[6]), p.i[3], p.i[4]

        dxDrawImage(x,y,w,h, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, ui.selectedMenu == i and (ui.alpha > 200 and 200 or ui.alpha) or isMouseInPosition(x,y,w,h) and (ui.alpha > 200 and 200 or ui.alpha) or ui.alpha))

        if(v.icon)then
            local ww,hh=dxGetMaterialSize(assets.textures[v.icon])
            dxDrawImage(x+(w-ww/zoom)/2-dxGetTextWidth(v.name, 1, assets.fonts[1])/2, y+(h-hh/zoom)/2, ww/zoom, hh/zoom, assets.textures[v.icon], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            dxDrawText(v.name, x+ww/zoom,y,w+x+ww/2/zoom,h+y, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[1], "center", "center")
        else
            dxDrawText(v.name, x,y,w+x,h+y, tocolor(70, 70, 70, ui.alpha), 1, assets.fonts[1], "center", "center")
        end

        onClick(x,y,w,h,function()
            ui.anim=true
            if(ui.selectedMenu)then
                animate(ui.menuAlpha, 0, "Linear", 200, function(a)
                    ui.menuAlpha=a

                    for i,v in pairs(ui.btns) do
                        btns:buttonSetAlpha(v,a)
                    end
                end, function()
                    ui.selected=false
                    
                    for i,v in pairs(ui.btns) do
                        btns:destroyButton(v)
                    end
                    ui.btns={}
                    
                    if(ui.selectedMenu == i)then
                        ui.anim=false
                        ui.selectedMenu=false
                    else
                        ui.selectedMenu=i
                        animate(ui.menuAlpha, 255, "Linear", 200, function(a)
                            ui.menuAlpha=a
        
                            for i,v in pairs(ui.btns) do
                                btns:buttonSetAlpha(v,a)
                            end
                        end, function()
                            ui.anim=false
                        end)
                    end
                end)
            else
                ui.selectedMenu=i
                animate(ui.menuAlpha, 255, "Linear", 200, function(a)
                    ui.menuAlpha=a

                    for i,v in pairs(ui.btns) do
                        btns:buttonSetAlpha(v,a)
                    end
                end, function()
                    ui.anim=false
                end)
            end
        end)
    end

    onClick(p.hx[1], p.hx[2], p.hx[3], p.hx[4], function()
        ui.destroy()
    end)

    if(ui.selectedMenu and ui.panels[ui.selectedMenu] and ui.panels[ui.selectedMenu].render)then
        ui.panels[ui.selectedMenu].render(p)
    end
end

-- create

ui.create=function()
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(not vehicle or ui.panel or ui.anim)then return end

    if(getElementHealth(vehicle) < 1000)then
        noti:noti("Aby ulepszyć pojazd, musi on być sprawny.", "error")
        return
    end
    
    blur=exports.blur
    btns=exports.px_buttons
    export=exports.px_custom_vehicles
    noti=exports.px_noti

    local uid=getElementData(localPlayer, "user:uid")
    local owner=getElementData(vehicle, "vehicle:owner")
    if(not uid or not owner or (owner and owner ~= uid))then 
        noti:noti("Pojazd nie należy do Ciebie.", "error")
        return 
    end

    ui.vehicle=vehicle

    ui.info={
        engine=getElementData(vehicle, "vehicle:engine") or export:getVehicleEngineFromModel(getElementModel(vehicle)) or 1.0,
        engines=export:getVehicleEngines(getElementModel(vehicle)) or {1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.5,2.7,3.0},

        MK1=getElementData(vehicle, "vehicle:mk1"),
        MK2=getElementData(vehicle, "vehicle:mk2"),

        turbo=getElementData(vehicle, "vehicle:turbo"),
        suspension=getElementData(vehicle, "vehicle:suspension"),
        brakes=getElementData(vehicle, "vehicle:brakes"),
        tank=getElementData(vehicle, "vehicle:fuelTank") or 20,
        nitro=getElementData(vehicle, "vehicle:nitro")
    }
    if(tonumber(ui.info.engine) < tonumber(ui.info.engines[1]))then
        ui.info.engines={
            ui.info.engine,
            ui.info.engines[1],
            ui.info.engines[2],
            ui.info.engines[3],
            ui.info.engines[4]
        }
    end

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)

    ui.selected=false
    ui.selectedMenu=false

    toggleControl("enter_exit", false)

    ui.panel=true

    showCursor(true, false)

    ui.anim=true
    animate(ui.alpha, 255, "Linear", 200, function(a)
        ui.alpha=a

        for i,v in pairs(ui.btns) do
            btns:buttonSetAlpha(v,a)
        end
    end, function()
        ui.anim=false
    end)
end

ui.destroy=function()
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(not vehicle or not ui.panel or ui.anim)then return end

    ui.anim=true
    animate(ui.alpha, 0, "Linear", 200, function(a)
        ui.alpha=a

        if(ui.menuAlpha > 0)then
            ui.menuAlpha=a
        end

        for i,v in pairs(ui.btns) do
            btns:buttonSetAlpha(v,a)
        end
    end, function()
        removeEventHandler("onClientRender", root, ui.onRender)

        assets.destroy()

        toggleControl("enter_exit", true)
    
        ui.panel=false
        ui.anim=false

        for i,v in pairs(ui.btns) do
            btns:destroyButton(v)
        end
        ui.btns={}
    end)

    showCursor(false)
end

-- triggers

addEvent("open.ui", true)
addEventHandler("open.ui", resourceRoot, function()
    ui.triggerBlock=false
    ui.create()
end)

addEvent('trigger.unblock', true)
addEventHandler('trigger.unblock', resourceRoot, function()
    ui.triggerBlock=false
end)

addEvent("destroy.ui", true)
addEventHandler("destroy.ui", resourceRoot, function(refresh)
    ui.triggerBlock=false

    if(refresh)then
        local vehicle=ui.vehicle
        if(vehicle and isElement(vehicle))then
            ui.info={
                engine=getElementData(vehicle, "vehicle:engine") or export:getVehicleEngineFromModel(getElementModel(vehicle)) or 1.0,
                engines=export:getVehicleEngines(getElementModel(vehicle)) or {1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.5,2.7,3.0},
        
                MK1=getElementData(vehicle, "vehicle:mk1"),
                MK2=getElementData(vehicle, "vehicle:mk2"),
        
                turbo=getElementData(vehicle, "vehicle:turbo"),
                suspension=getElementData(vehicle, "vehicle:suspension"),
                brakes=getElementData(vehicle, "vehicle:brakes"),
                tank=getElementData(vehicle, "vehicle:fuelTank") or 20,
                nitro=getElementData(vehicle, "vehicle:nitro")
            }

            btns:destroyButton(ui.btns[1])
            ui.btns[1]=nil
        else
            ui.destroy()
        end
    else
        ui.destroy()
    end
end)

-- useful

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function dxDrawShadowText(text,x,y,w,h,color,size,font,alignX,alignY)
    dxDrawText(text,x+1,y+1,w+1,h+1,tocolor(0,0,0),size,font,alignX,alignY)
    dxDrawText(text,x,y,w,h,color,size,font,alignX,alignY)
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
	if(not isCursorShowing() or ui.anim or ui.triggerBlock)then return end

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