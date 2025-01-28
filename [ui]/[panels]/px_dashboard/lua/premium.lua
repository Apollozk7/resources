--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local points={
    {nr="71480", cost=1.25, points=10},
    {nr="72480", cost=2.46, points=20},
    {nr="73480", cost=3.69, points=30},
    {nr="74480", cost=4.92, points=50},
    {nr="75480", cost=6.15, points=60},
    {nr="76480", cost=7.38, points=70},
    {nr="79480", cost=11.07, points=110},
    {nr="91400", cost=17.22, points=170},
    {nr="91900", cost=23.37, points=230},
    {nr="92022", cost=24.60, points=250},
    {nr="92521", cost=30.75, points=300},
}

local items={
    {name="Konto premium", days=7, points=50, vehsSlots=1},
    {name="Konto premium", days=14, points=80, vehsSlots=3},
    {name="Konto premium", days=30, points=170, vehsSlots=6},

    {name="Konto gold", days=14, points=250, vehsSlots=6},
    {name="Konto gold", days=30, points=410, vehsSlots=12},
    {name="Konto gold", days=60, points=720, vehsSlots=18},
}

local items_2={
    {name="Sloty na pojazdy", points=25, vehsSlots=1},
    {name="Sloty na pojazdy", points=50, vehsSlots=3},
    {name="Sloty na pojazdy", points=80, vehsSlots=6},
}

local selected=1
local checkbox=false
local sell=false

local premium_benefit=[[- Dodatkowe sloty na pojazdy
- Dostęp do czatu premium
- Wyróżniający się kolor nicku
- Skiny premium
- Animacje premium
- Bonus $ oraz XP co godzine
- Dodatkowe 5% zarobków w postaci $ i XP
- Zmiana rejestracji w ratuszu
- Dostęp do warsztatu felg
]]

local gold_benefit=[[- Dodatkowe sloty na pojazdy
- Dostęp do czatu gold
- Dostęp do regulacji systemów MK
- Automatyczne naprawy pojazdów
- Bonus $ oraz XP co pół godziny
- Dodatkowe 10% zarobków w postaci $ i XP
- Ostatnia pozycja przy logowaniu
- Zmiana rejestracji w ratuszu
- Dostęp do warsztatu felg
]]

local menu={
    --[[{name="Kupno", draw=function(texs,a)
        -- right
        dxDrawText("#dededeKorzyści z konta #b3bf4dPremium:#999a95\n- Dodatkowe sloty na pojazdy\n- Dostęp do czatu premium\n- Wyróżniający się kolor nicku\n- Skiny premium\n- Animacje premium\n- Bonus $ oraz XP co godzine\n- Dodatkowe 5% zarobków w postaci $ i X\n- Dostęp do warsztatu felg\n\n\n#dededeKorzyści z konta #bfa64dGold:#999a95\n- Dodatkowe sloty na pojazdy\n- Dostęp do czatu gold\n- Dostęp do warsztatu (BM)\n- Bonus $ oraz XP co pół godziny\n- Dodatkowe 10% zarobków w postaci $ i XP\n- Ostatnia pozycja przy logowaniu\n- Warsztat felg (BB)", sw-400/zoom, 249/zoom, 0, 0, tocolor(255, 255, 255, a), 1, assets.fonts[1], "left", "top", false, false, false, true)
    
        if(not ui.scrolls["premium_1"])then
            ui.scrolls["premium_1"]=scroll:dxCreateScroll(426/zoom+1041/zoom+10/zoom, 251/zoom, 4, 200/zoom, 0, 5, points, 300/zoom, a, false, {381/zoom, 0, sw, sh})
        end

        -- left
        local k=0
        local row=math.floor(scroll:dxScrollGetPosition(ui.scrolls["premium_1"])+1)
        for i=row,row+4 do
            local v=points[i]
            if(v)then
                k=k+1

                local aa=selected == i and (a > 100 and 100 or a) or a
                local sY=(60/zoom)*(k-1)

                dxDrawImage(426/zoom, 251/zoom+sY, 1041/zoom, 54/zoom, texs[3], 0, 0, 0, tocolor(255,255,255,aa))

                dxDrawImage(426/zoom+21/zoom, 251/zoom+sY+(54-16)/2/zoom, 11/zoom, 16/zoom, texs[1], 0, 0, 0, tocolor(255,255,255,a))

                dxDrawText("#d3df50"..v.points.." #dededePunktów Premium", 426/zoom+55/zoom, 251/zoom+sY, 1041/zoom, 54/zoom+251/zoom+sY, tocolor(200, 200, 200,a), 1, assets.fonts[1], "left", "center", false, false, false, true)
                dxDrawText("Wyślij SMS o treści MSMS.PX na numer "..v.nr, 426/zoom+351/zoom, 251/zoom+sY, 1041/zoom, 54/zoom+251/zoom+sY, tocolor(150,150,150,a), 1, assets.fonts[1], "left", "center", false, false, false, true)
                dxDrawText(v.cost.." zł #8a8e8ebrutto", 0, 251/zoom+sY, 426/zoom+1041/zoom-35/zoom, 54/zoom+251/zoom+sY, tocolor(200,200,200,a), 1, assets.fonts[1], "right", "center", false, false, false, true)
            
                onClick(426/zoom, 251/zoom+sY, 1041/zoom, 54/zoom, function()
                    selected=i
                end)
            end
        end

        local v=points[selected]
        if(v)then
            dxDrawImage(426/zoom, 576/zoom, 521/zoom, 166/zoom, texs[4], 0, 0, 0, tocolor(255,255,255,a))

            dxDrawText("Otrzymany w SMS pięcio znakowy kod wprowadź poniżej.", 426/zoom+20/zoom, 576/zoom+22/zoom, 521/zoom, 166/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[2], "left", "top")
        
            if(not ui.edits["premium_1"])then
                ui.edits["premium_1"]=editbox:dxCreateEdit("Wprowadź kod", 426/zoom+20/zoom, 576/zoom+65/zoom, 200/zoom, 30/zoom, false, 11/zoom, a, false, false, ":px_dashboard/textures/8/edit.png")
            end

            dxDrawImage(426/zoom+20/zoom, 576/zoom+110/zoom, 19/zoom, 19/zoom, texs[5], 0, 0, 0, tocolor(255,255,255,a))
            if(checkbox)then
                dxDrawImage(426/zoom+20/zoom+(19-11)/2/zoom, 576/zoom+110/zoom+(19-9)/2/zoom, 11/zoom, 9/zoom, texs[6], 0, 0, 0, tocolor(255,255,255,a))
            end

            onClick(426/zoom+20/zoom, 576/zoom+110/zoom, 19/zoom, 19/zoom, function()
                checkbox=not checkbox
            end)

            dxDrawText("Akceptuje regulamin", 426/zoom+53/zoom, 576/zoom+110/zoom, 19/zoom, 576/zoom+110/zoom+19/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[2], "left", "center")
            dxDrawText("https://pixelmta.pl/reg_premium.pdf", 426/zoom+53/zoom, 576/zoom+160/zoom, 19/zoom, 576/zoom+110/zoom+19/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[2], "left", "center")

            if(not ui.buttons["premium_1"])then
                ui.buttons["premium_1"]=buttons:createButton(426/zoom+521/zoom-170/zoom, 576/zoom+166/zoom-60/zoom, 147/zoom, 38/zoom, "WYKORZYSTAJ", a, 9, false, false, ":px_dashboard/textures/7/button.png")
            else
                onClick(426/zoom+521/zoom-170/zoom, 576/zoom+166/zoom-60/zoom, 147/zoom, 38/zoom, function()
                    if((getTickCount()-ui.lastTrigger) > 5000)then
                        local code=editbox:dxGetEditText(ui.edits["premium_1"]) or ""
                        if(#code > 0)then
                            if(checkbox)then
                                triggerServerEvent("dashboard.buyPointsSMS", resourceRoot, code)
                                ui.lastTrigger=getTickCount()
                            else
                                noti:noti("Najpierw zaakceptuj regulamin!", "error")
                            end
                        else
                            noti:noti("Najpierw wprowadź kod SMS.", "error")
                        end
                    else
                        noti:noti("Akcje możesz wykonywać co 5 sekund.", "error")
                    end
                end)
            end
        end

        dxDrawText("#c7c7c7Inne formy płatności możesz znaleźć na:\n#5c9ed6https://pixelmta.pl/reg_premium.pdf\n\n#c7c7c7Kod powinien przyjść maksymalnie do 5 minut,\njeżeli nie - skontaktuj się z administratorem.", sw-939/zoom, 576/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top", false, false, false, true)

        for i,v in pairs(items) do
            local sX=(225/zoom)*(i-1)
            dxDrawImage(426/zoom+sX, sh-297/zoom, 207/zoom, 241/zoom, v.name == "Konto premium" and texs[7] or texs[8], 0, 0, 0, tocolor(255,255,255,a))
            dxDrawText(v.name, 426/zoom+sX, sh-297/zoom+22/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
            dxDrawText("( "..v.days.." dni )", 426/zoom+sX, sh-297/zoom+46/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[1], "center", "top")
            dxDrawImage(426/zoom+sX+(207-79)/2/zoom, sh-297/zoom+(241-61)/2/zoom-10/zoom, 79/zoom, 61/zoom, texs[9], 0, 0, 0, tocolor(255,255,255,a))
            dxDrawText(v.points, 426/zoom+sX, sh-297/zoom+162/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
            dxDrawImage(426/zoom+sX+207/2/zoom+dxGetTextWidth("250",1, assets.fonts[5])/2, sh-297/zoom+162/zoom+5/zoom, 12/zoom, 15/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))

            if(not ui.buttons["premium_"..(i+1)])then
                ui.buttons["premium_"..(i+1)]=buttons:createButton(426/zoom+sX+(207-147)/2/zoom, sh-297/zoom+241/zoom-45/zoom, 147/zoom, 38/zoom, "ZAKUP", a, 9, false, false, ":px_dashboard/textures/7/button.png", {169,147,74})
            else
                onClick(426/zoom+sX+(207-147)/2/zoom, sh-297/zoom+241/zoom-45/zoom, 147/zoom, 38/zoom, function()
                    if((getTickCount()-ui.lastTrigger) > 5000)then
                        if(ui.info.user.premiumPoints >= v.points)then
                            ui.lastTrigger=getTickCount()
                            triggerServerEvent("dashboard.buyPremium", resourceRoot, v)
                        else
                            noti:noti("Nie posiadasz wystarczająco punktów premium.", "error")
                        end
                    else
                        noti:noti("Akcje możesz wykonywać co 5 sekund.", "error")
                    end
                end)
            end
        end
    end},]]
    
    {name="Wymiana", draw=function(texs,a)
        -- right
        dxDrawText("#dededeKorzyści z konta #b3bf4dPremium:#999a95\n"..premium_benefit, 423/zoom, 249/zoom, 0, 0, tocolor(255, 255, 255, a), 1, assets.fonts[1], "left", "top", false, false, false, true)
        dxDrawText("#dededeKorzyści z konta #bfa64dGold:#999a95\n"..gold_benefit, 930/zoom, 249/zoom, 0, 0, tocolor(255, 255, 255, a), 1, assets.fonts[1], "left", "top", false, false, false, true)

        for i,v in pairs(items) do
            local sX=(225/zoom)*(i-1)
            dxDrawImage(426/zoom+sX, sh-600/zoom, 207/zoom, 241/zoom, v.name == "Konto premium" and texs[7] or texs[8], 0, 0, 0, tocolor(255,255,255,a))
            dxDrawText(v.name, 426/zoom+sX, sh-600/zoom+10/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
            dxDrawText("( "..v.days.." dni )", 426/zoom+sX, sh-600/zoom+35/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[3], "center", "top")
            dxDrawText("[ + "..v.vehsSlots.." slotów ]", 426/zoom+sX, sh-600/zoom+55/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[3], "center", "top")
            dxDrawImage(426/zoom+sX+(207-79)/2/zoom, sh-600/zoom+(241-61)/2/zoom-10/zoom, 79/zoom, 61/zoom, texs[9], 0, 0, 0, tocolor(255,255,255,a))
            dxDrawText(v.points, 426/zoom+sX, sh-600/zoom+162/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
            dxDrawImage(426/zoom+sX+207/2/zoom+dxGetTextWidth("250",1, assets.fonts[5])/2, sh-600/zoom+162/zoom+5/zoom, 12/zoom, 15/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))

            if(not ui.buttons["premium_"..(i+1)])then
                ui.buttons["premium_"..(i+1)]=buttons:createButton(426/zoom+sX+(207-147)/2/zoom, sh-600/zoom+241/zoom-45/zoom, 147/zoom, 38/zoom, "ZAKUP", a, 9, false, false, ":px_dashboard/textures/7/button.png", {169,147,74})
            else
                onClick(426/zoom+sX+(207-147)/2/zoom, sh-600/zoom+241/zoom-45/zoom, 147/zoom, 38/zoom, function()
                    if(SPAM.getSpam())then return end
                    
                    if(ui.info.user.premiumPoints >= v.points)then
                        triggerServerEvent("dashboard.buyPremium", resourceRoot, v)
                    else
                        noti:noti("Nie posiadasz wystarczająco punktów premium.", "error")
                    end
                end)
            end
        end

        for i,v in pairs(items_2) do
            local sX=(225/zoom)*(i-1)
            dxDrawImage(426/zoom+sX, sh-297/zoom, 207/zoom, 241/zoom, texs[7], 0, 0, 0, tocolor(175,255,175,a))
            dxDrawText(v.name, 426/zoom+sX, sh-297/zoom+10/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
            dxDrawText("( + "..v.vehsSlots.." slotów )", 426/zoom+sX, sh-297/zoom+35/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[3], "center", "top")
            dxDrawImage(426/zoom+sX+(207-79)/2/zoom, sh-297/zoom+(241-61)/2/zoom-10/zoom, 79/zoom, 61/zoom, texs[9], 0, 0, 0, tocolor(255,255,255,a))
            dxDrawText(v.points, 426/zoom+sX, sh-297/zoom+162/zoom, 426/zoom+sX+207/zoom, 241/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "top")
            dxDrawImage(426/zoom+sX+207/2/zoom+dxGetTextWidth("250",1, assets.fonts[5])/2, sh-297/zoom+162/zoom+5/zoom, 12/zoom, 15/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))

            if(not ui.buttons["premium_2_"..(i+1)])then
                ui.buttons["premium_2_"..(i+1)]=buttons:createButton(426/zoom+sX+(207-147)/2/zoom, sh-297/zoom+241/zoom-45/zoom, 147/zoom, 38/zoom, "ZAKUP", a, 9, false, false, ":px_dashboard/textures/7/button.png", {169,147,74})
            else
                onClick(426/zoom+sX+(207-147)/2/zoom, sh-297/zoom+241/zoom-45/zoom, 147/zoom, 38/zoom, function()
                    if(SPAM.getSpam())then return end
                    
                    if(ui.info.user.premiumPoints >= v.points)then
                        triggerServerEvent("dashboard.buySlots", resourceRoot, v)
                    else
                        noti:noti("Nie posiadasz wystarczająco punktów premium.", "error")
                    end
                end)
            end
        end
    end},

    {name="Giełda", draw=function(texs,a)
        -- header
        dxDrawText("Giełda", 426/zoom, 248/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
        dxDrawText("Kupuj i sprzedawaj punkty premium za pieniądze wirtualne.", 426/zoom, 280/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")

        dxDrawRectangle(426/zoom, 311/zoom, 1028/zoom, 1, tocolor(80,80,80,a))

        dxDrawText("Znaleziono "..#ui.info.premium.." ogłoszeń", 426/zoom, 340/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[6], "left", "top")

        if(not ui.buttons["premium_1"])then
            ui.buttons["premium_1"]=buttons:createButton(sw-595/zoom, 337/zoom, 130/zoom, 27/zoom, "SPRZEDAJ PUNKTY", a, 9, false, false, false, {58,104,127})
        else
            onClick(sw-595/zoom, 337/zoom, 130/zoom, 27/zoom, function()
                sell=not sell
                if(not sell)then
                    buttons:destroyButton(ui.buttons["premium_sell"])
                    ui.buttons["premium_sell"]=nil

                    editbox:dxDestroyEdit(ui.edits["premium_1"])
                    ui.edits["premium_1"]=nil

                    editbox:dxDestroyEdit(ui.edits["premium_2"])
                    ui.edits["premium_2"]=nil
                end
            end)
        end

        if(not ui.scrolls["premium_1"])then
            ui.scrolls["premium_1"]=scroll:dxCreateScroll(sw-459/zoom, 388/zoom, 4, 200/zoom, 0, 6, ui.info.premium, 680/zoom, a, false, {381/zoom, 0, sw, sh})
        end

        local k=0
        local row=math.floor(scroll:dxScrollGetPosition(ui.scrolls["premium_1"])+1)
        for i=row,row+6 do
            local v=ui.info.premium[i]
            if(v)then
                k=k+1

                local sY=(116/zoom)*(k-1)
                dxDrawImage(426/zoom, 388/zoom+sY, 1028/zoom, 100/zoom, texs[10], 0, 0, 0, tocolor(255, 255, 255, a))
                dxDrawRectangle(426/zoom, 388/zoom+sY+100/zoom, 1028/zoom, 1, tocolor(80,80,80,a))

                dxDrawImage(426/zoom, 388/zoom+sY, 1028/zoom, 32/zoom, texs[10], 0, 0, 0, tocolor(255, 255, 255, a))

                local av=avatars:getPlayerAvatar(v.login)
                if(av)then
                    dxDrawImage(426/zoom+14/zoom, 388/zoom+sY+(32-22)/2/zoom, 22/zoom, 22/zoom, av, 0, 0, 0, tocolor(255, 255, 255, a))
                end

                dxDrawText(v.login, 426/zoom+45/zoom, 388/zoom+sY, 1028/zoom, 388/zoom+sY+32/zoom, tocolor(175, 175, 175, a), 1, assets.fonts[7], "left", "center")

                dxDrawRectangle(426/zoom, 388/zoom+sY+32/zoom, 1028/zoom, 1, tocolor(80,80,80,a))

                dxDrawText(v.points, 426/zoom+14/zoom, 388/zoom+sY+45/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
                dxDrawText("Punktów premium", 426/zoom+14/zoom, 388/zoom+sY+65/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[6], "left", "top")

                dxDrawText("$ "..convertNumber(math.floor(v.cost/v.points)), 426/zoom+321/zoom, 388/zoom+sY+45/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
                dxDrawText("Cena za PP", 426/zoom+321/zoom, 388/zoom+sY+65/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[6], "left", "top")

                dxDrawText("$ "..convertNumber(v.cost), 426/zoom+619/zoom, 388/zoom+sY+45/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
                dxDrawText("Cena całkowita", 426/zoom+619/zoom, 388/zoom+sY+65/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[6], "left", "top")

                if(not ui.buttons["premium_"..(k+1)])then
                    ui.buttons["premium_"..(k+1)]=buttons:createButton(426/zoom+1028/zoom-166/zoom, 388/zoom+sY+48/zoom, 147/zoom, 38/zoom, v.login == getPlayerName(localPlayer) and "USUŃ" or "ZAKUP", a, 9, false, false, ":px_dashboard/textures/7/button.png", v.login == getPlayerName(localPlayer) and {132,39,39} or false)
                else
                    buttons:buttonSetText(ui.buttons["premium_"..(k+1)],v.login == getPlayerName(localPlayer) and "USUŃ" or "ZAKUP")
                    buttons:buttonSetColor(ui.buttons["premium_"..(k+1)],v.login == getPlayerName(localPlayer) and {132,39,39} or false)

                    onClick(426/zoom+1028/zoom-166/zoom, 388/zoom+sY+48/zoom, 147/zoom, 38/zoom, function()
                        if(SPAM.getSpam())then return end

                        v.cost=tonumber(v.cost)
                        v.points=tonumber(v.points)
                            
                        triggerServerEvent("dashboard.buyPoints", resourceRoot, v)
                    end)
                end
            end
        end

        if(sell)then
            dxDrawImage(sw-414/zoom, 388/zoom, 369/zoom, 300/zoom, texs[10], 0, 0, 0, tocolor(255, 255, 255, a))

            dxDrawText("Wystaw na giełdę", sw-414/zoom+29/zoom, 388/zoom+27/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
            dxDrawText("Sprzedaj swoje Punkty Premium", sw-414/zoom+29/zoom, 388/zoom+58/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[2], "left", "top")

            if(not ui.edits["premium_1"] or not ui.edits["premium_2"])then
                ui.edits["premium_1"]=editbox:dxCreateEdit("Wprowadź ilość punktów", sw-414/zoom+29/zoom, 388/zoom+150/zoom, 304/zoom, 30/zoom, false, 11/zoom, a, false, false)
                ui.edits["premium_2"]=editbox:dxCreateEdit("Wprowadź cene za punkty (wszystkie)", sw-414/zoom+29/zoom, 388/zoom+100/zoom, 304/zoom, 30/zoom, false, 11/zoom, a, false, false)
            end

            dxDrawText("Minimalnie: $ 100\nMaksymalnie: $ 200", sw-414/zoom+29/zoom, 388/zoom+230/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "top")

            if(not ui.buttons["premium_sell"])then
                ui.buttons["premium_sell"]=buttons:createButton(sw-414/zoom+200/zoom, 388/zoom+230/zoom, 140/zoom, 38/zoom, "WYSTAW", a, 9, false, false, ":px_dashboard/textures/7/button.png")
            else
                onClick(sw-414/zoom+200/zoom, 388/zoom+230/zoom, 140/zoom, 38/zoom, function()
                    local points=editbox:dxGetEditText(ui.edits["premium_1"]) or 0
                    local money=editbox:dxGetEditText(ui.edits["premium_2"]) or 0
                    if(#money >= 1 and tonumber(money) and #points >= 1 and tonumber(points))then
                        money=tonumber(money)
                        money=math.floor(money)
                        points=tonumber(points)
                        points=math.floor(points)

                        if(money < 100 or points < 1)then
                            noti:noti("Wprowadziłeś błędną wartość.", "error")
                            return
                        end

                        if(money >= (100*points) and money < (200*points))then
                            if(ui.info.user.premiumPoints >= points)then
                                if(SPAM.getSpam())then return end

                                triggerServerEvent("dashboard.insertSell", resourceRoot, points, money)
                            else
                                noti:noti("Nie posiadasz takiej ilości punktów premium.", "error")
                            end      
                        else    
                            exports.px_noti:noti("Minimalna cena za punkt: $100. Maksymalna cena za punkt: $200.", client, "error")
                        end
                    end
                end)
            end
        end
    end},
}

local selected=1

ui.rendering["Sklep premium"]=function(a, mainA)
    a=a > mainA and mainA or a

    local texs=assets.textures["Sklep premium"]
    if(not texs or (texs and #texs < 1))then return false end

    -- header
    dxDrawText("Sklep premium", 426/zoom, 63/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText("Spraw, aby rozgrywka była jeszcze przyjemniejsza ulepszając swoje konto na status premium lub gold.", 426/zoom, 93/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")

    -- right info
    dxDrawText("Stan konta:", sw-274/zoom, 63/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText(ui.info.user.premiumPoints, sw-160/zoom, 60/zoom, 0, 0, tocolor(193,205,78, a), 1, assets.fonts[9], "left", "top")
    dxDrawImage(sw-160/zoom+dxGetTextWidth(ui.info.user.premiumPoints,1, assets.fonts[9])+10/zoom,65/zoom,18/zoom,23/zoom,texs[1],0, 0, 0, tocolor(255, 255, 255, a))

    dxDrawRectangle(381/zoom+1, 140/zoom, 1494/zoom, 1, tocolor(80,80,80,a > 50 and 50 or a))
    dxDrawImage(381/zoom+1, 140/zoom+1, 1279/zoom, 70/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, a))

    local sX=0
    for i,v in pairs(menu) do
        local w=dxGetTextWidth(v.name, 1, assets.fonts[2])

        dxDrawText(v.name, 380/zoom+45/zoom+sX, 140/zoom+1+22/zoom, 380/zoom+45/zoom+sX+w, 20/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[2], "center", "top")

        if(selected == i)then
            dxDrawRectangle(380/zoom+45/zoom+sX, 140/zoom+1+22/zoom+25/zoom, w, 1, tocolor(40,102,119,a))
        end

        onClick(380/zoom+45/zoom+sX, 140/zoom+1+22/zoom, w, 20/zoom, function()
            selected=i

            for i,v in pairs(ui.scrolls) do
                scroll:dxDestroyScroll(v)
            end
            ui.scrolls={}

            for i,v in pairs(ui.buttons) do
                buttons:destroyButton(v)
            end
            ui.buttons={}

            for i,v in pairs(ui.edits) do
                editbox:dxDestroyEdit(v)
            end
            ui.edits={}

            sell=false
        end)

        sX=sX+w+57/zoom
    end

    menu[selected].draw(texs,a)
end