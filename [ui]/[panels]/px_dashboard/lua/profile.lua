--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local dxDrawRow=function(text, x,y,w,h, img, rx,ry,rz, color,a)
    dxDrawImage(x,y,w,h,img,rx,ry,rz,color)
    dxDrawText(text,x,y,w+x,y+65/zoom,tocolor(200,200,200,a),1,assets.fonts[5],"center","center")
    dxDrawRectangle(x+34/zoom,y+65/zoom,w-34/zoom-34/zoom,1,tocolor(80,80,80,a))
end

ui.rendering["Twój profil"]=function(a, mainA)
    a=a > mainA and mainA or a

    local texs=assets.textures["Twój profil"]
    if(not texs or (texs and #texs < 1))then return false end

    local white=tocolor(255,255,255,a)
    local center=(381/zoom)
    center=center+(sw-center)/2

    -- discord code
    if(ui.info.discord and #ui.info.discord > 0)then
        dxDrawText("Kod do połączenia konta (Discord): #939393"..ui.info.discord[1].code, sw-430/zoom, 15/zoom, 400/zoom+sw-430/zoom, 25/zoom+15/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[6], "right", "center", false, false, false, true)
    
        if(isMouseInPosition(sw-430/zoom, 15/zoom, 400/zoom, 25/zoom))then
            local cx,cy=getCursorPosition()
            cx,cy=cx*sw,cy*sh

            dxDrawText("Kliknij aby skopiować", cx+10/zoom, cy, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[2], "left", "top", false, false, true)

            onClick(0,0,sw,sh,function()
                setClipboard(ui.info.discord[1].code)
                noti:noti("Pomyślnie skopiowano kod do schowka.", "success")
            end)
        end
    elseif(ui.info.user.discord_id and ui.info.user.discord_award == 0)then
        dxDrawText("Odbierz nagrodę na połączenie", sw-430/zoom, 15/zoom, 400/zoom+sw-430/zoom, 25/zoom+15/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[6], "right", "center", false, false, false, true)

        if(isMouseInPosition(sw-430/zoom, 15/zoom, 400/zoom, 25/zoom))then
            local cx,cy=getCursorPosition()
            cx,cy=cx*sw,cy*sh

            dxDrawText("Kliknij aby odebrać", cx+10/zoom, cy, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[2], "left", "top", false, false, true)

            onClick(0,0,sw,sh,function()
                triggerServerEvent("get.discord.award", resourceRoot)
            end)
        end
    elseif(not ui.info.user.discord_id)then
        dxDrawText("Twoje konto nie jest połączone z kontem Discord! Aby je połączyć należy wpisać na PW do bota Pixel BOT#1099 komende /polacz i podążać wedle instrukcji.", sw-430/zoom, 15/zoom, 400/zoom+sw-430/zoom, 25/zoom+15/zoom, tocolor(255, 0, 0, a), 1, assets.fonts[6], "right", "center", false, false, false, true)
    end

    -- banner
    dxDrawImage(382/zoom, 46/zoom, 1504/zoom, 274/zoom, texs[1], 0, 0, 0, white)
    dxDrawImage(382/zoom, 46/zoom+274/zoom-1, 1504/zoom, 1, texs[2], 0, 0, 0, white)

    -- avatar and info
    local av=avatars:getPlayerAvatar(localPlayer)
    if(av)then
        dxDrawImage(506/zoom+5/zoom, 255/zoom+5/zoom, 108/zoom, 108/zoom, av, 0, 0, 0, white)
        dxDrawImage(506/zoom, 255/zoom, 118/zoom, 118/zoom, texs[3], 0, 0, 0, white)
    end
    dxDrawText(ui.info.user.login, 506/zoom+140/zoom, 290/zoom, 0, 0, tocolor(222, 222, 222, a), 1, assets.fonts[5], "left", "top")
    dxDrawText(ui.info.rank or "?", 506/zoom+140/zoom, 294/zoom+24/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[6], "left", "top")

    -- rows
    
    -- days
    dxDrawRow("Zadanie dnia", center-475/2/zoom-495/zoom, sh-674/zoom, 475/zoom, 292/zoom, texs[4], 0, 0, 0, white, a) -- left 1
    
    -- desc
    local day_quest=getElementData(localPlayer, "user:dayQuest") or {progress=0,value=1}
    if(day_quest)then
        dxDrawText(#day_quest.name > 0 and day_quest.name or "?", center-475/2/zoom-495/zoom+50/zoom, sh-674/zoom+84/zoom, center-475/2/zoom-495/zoom+475/zoom-50/zoom, 0, tocolor(180, 180, 180, a), 1, assets.fonts[6], "center", "top", false, true)
        
        -- circle progress
        day_quest.progress=day_quest.progress or 0
        day_quest.value=day_quest.value or 1
        day_quest.progress=day_quest.progress < 0 and 0 or day_quest.progress
        day_quest.value=day_quest.value < 1 and 1 or day_quest.value

        local progress=(day_quest.progress/day_quest.value)*100
        progress=progress > 100 and 100 or progress
        progress=progress < 0 and 0 or progress

        local x,y,w=getCirclePosition(center-475/2/zoom-495/zoom+(475-118)/2/zoom, sh-674/zoom+150/zoom, 118/zoom, 118/zoom)
        dxDrawImage(center-475/2/zoom-495/zoom+(475-118)/2/zoom, sh-674/zoom+150/zoom, 118/zoom, 118/zoom, texs[6], 0, 0, 0, white)
        dxDrawRing(x, y, w-3, 3, 90, (progress)/100, tocolor(0,100,255,a))
        dxDrawImage(center-475/2/zoom-495/zoom+(475-118)/2/zoom, sh-674/zoom+150/zoom, 118/zoom, 118/zoom, texs[7], 0, 0, 0, tocolor(86,86,92,a))
        dxDrawText(math.floor(progress).."%", center-475/2/zoom-495/zoom+(475-118)/2/zoom, sh-674/zoom+150/zoom, 118/zoom+center-475/2/zoom-495/zoom+(475-118)/2/zoom, 118/zoom+sh-674/zoom+150/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[6], "center", "center")
        --
    end

    -- licenses
    dxDrawRow("Posiadane kategorie", center-475/2/zoom-495/zoom, sh-674/zoom+311/zoom, 475/zoom, 330/zoom, texs[4], 0, 0, 0, white, a) -- left bottom

    local licenses=fromJSON(ui.info.user.licenses) or {}
    local lic={
        {name="A",have=licenses["a"] == 2},
        {name="B",have=licenses["b"] == 2},
        {name="C",have=licenses["c"] == 2},
        {name="C+E",have=licenses["c+e"] == 2},
        {name="L1",have=licenses["l1"] == 2},
        {name="L2",have=licenses["l2"] == 2},
        {name="na broń",have=licenses["broń palna"] == 1,tex=17},
    }

    for i,v in pairs(lic) do
        local sY=(35/zoom)*(i-1)

        i=i > 5 and 5 or i

        local tex=texs[v.tex or 7+i]
        local w,h=dxGetMaterialSize(tex)

        local have_a=v.have and 255 or 150
        have_a=have_a > a and a or have_a

        dxDrawImage(center-475/2/zoom-495/zoom+34/zoom, sh-674/zoom+311/zoom+80/zoom+sY, w/zoom, h/zoom, tex, 0, 0, 0, tocolor(255,255,255,have_a))
        dxDrawText(((v.name == "L1" or v.name == "L2") and "Licencja lotnicza" or v.name == "na broń" and "Licencja" or "Kategoria").." "..v.name, center-475/2/zoom-495/zoom+34/zoom+55/zoom, sh-674/zoom+311/zoom+80/zoom+sY, 0, sh-674/zoom+311/zoom+80/zoom+sY+h/zoom, tocolor(200, 200, 200, have_a), 1, assets.fonts[2], "left", "center")
        dxDrawText(v.have and "Posiadana" or "Brak", center-475/2/zoom-495/zoom+34/zoom+55/zoom, sh-674/zoom+311/zoom+80/zoom+sY, center-475/2/zoom-495/zoom+475/zoom-34/zoom, sh-674/zoom+311/zoom+80/zoom+sY+h/zoom, v.have and tocolor(59, 197, 81, have_a) or tocolor(200, 200, 200, have_a), 1, assets.fonts[2], "right", "center")
    end
    --


    -- infos
    dxDrawRow("Informacje o koncie", center-475/2/zoom, sh-674/zoom, 475/zoom, 640/zoom, texs[5], 0, 0, 0, white, a) -- center
    dxDrawImage(center-475/2/zoom+(475-150)/2/zoom, sh-674/zoom+83/zoom, 150/zoom, 150/zoom, "textures/skins/"..getElementModel(localPlayer)..".png", 0, 0, 0, white)
    dxDrawRectangle(center-475/2/zoom, sh-674/zoom+232/zoom, 475/zoom, 1, tocolor(80,80,80,a))

    -- list
    local online = getElementData(localPlayer, "user:online_time") or 0
    local hours = math.floor(online/60)
    local minutes = math.floor(online-(hours*60))
    local time=(hours > 0 and hours.."h " or "")..(minutes > 0 and minutes.."m" or "0m")

    local online = getElementData(localPlayer, "user:sesion_time") or 0
    local hours = math.floor(online/60)
    local minutes = math.floor(online-(hours*60))
    local time_s=(hours > 0 and hours.."h " or "")..(minutes > 0 and minutes.."m" or "0m")

    local level=getElementData(localPlayer, "user:level") or 1
    local needXP=100

    local list={
        {"Login", ui.info.user.login},
        {"Czas gry", time.." ("..time_s..")"},
        {"Data rejestracji", ui.info.user.register_date},
        {"Frakcja", ui.info.faction or "Brak"},
        {"Organizacja", ui.info.org or "Brak"},
        {"Sloty na pojazdy", ui.info.user.vehiclesSlots},
        {"PREMIUM", ui.info.user.premium and "Do "..ui.info.user.premium or "Brak"},
        {"GOLD", ui.info.user.gold and "Do "..ui.info.user.gold or "Brak"},
    }

    for i,v in pairs(list) do
        local sY=(42/zoom)*(i-1)
        dxDrawRectangle(center-475/2/zoom+34/zoom, sh-674/zoom+245/zoom+sY, 408/zoom, 41/zoom, tocolor(15, 15, 15, 40 > a and a or 40))
        dxDrawText(v[1]..":", center-475/2/zoom+34/zoom+18/zoom, sh-674/zoom+245/zoom+sY, 408/zoom, sh-674/zoom+245/zoom+sY+41/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[2], "left", "center")
        dxDrawText(v[2], center-475/2/zoom+34/zoom+18/zoom, sh-674/zoom+245/zoom+sY, center-475/2/zoom+34/zoom+408/zoom-18/zoom, sh-674/zoom+245/zoom+sY+41/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[7], "right", "center")
    end
    --

    dxDrawRow("Majątek", center-475/2/zoom+495/zoom, sh-674/zoom, 475/zoom, 292/zoom, texs[4], 0, 0, 0, white, a) -- right
    for i=1,4 do
        local w,h=dxGetMaterialSize(texs[12+i])
        local sX=(110/zoom)*(i-1)
        dxDrawImage(center-475/2/zoom+495/zoom+34/zoom+sX, sh-674/zoom+(292-h)/2/zoom, w/zoom, h/zoom, texs[12+i], 0, 0, 0, white)
        dxDrawText(i == 1 and "Przy sobie" or i == 2 and "W banku" or i == 3 and "Ilość pojazdów" or i == 4 and "Nieruchomości", center-475/2/zoom+495/zoom+34/zoom+sX, sh-674/zoom+182/zoom, w/zoom+center-475/2/zoom+495/zoom+34/zoom+sX, h/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[3], "center", "top")
        dxDrawText(i == 1 and "#45b932$ #ffffff"..convertNumber(getPlayerMoney(localPlayer)) or i == 2 and "#45b932$ #ffffff"..convertNumber(0) or i == 3 and #ui.info.vehs or i == 4 and #ui.info.houses, center-475/2/zoom+495/zoom+34/zoom+sX, sh-674/zoom+205/zoom, w/zoom+center-475/2/zoom+495/zoom+34/zoom+sX, h/zoom, white, 1, assets.fonts[3], "center", "top", false, false, false, true)
    end

    local punish=""
    for i,v in pairs(ui.info.punish) do
        local type=v.type == "pj" and "Zawieszenie prawa jazdy od:" or v.type == "mute" and "Wyciszenie od:" or v.type == "l" and "Zawieszenie licencji lotniczych od:" or v.type
        punish=#punish > 0 and punish..", "..type.." "..v.admin..", za: "..v.reason.." ("..v.date..")" or type.." "..v.admin..", za: "..v.reason.." ("..v.date..")"
    end

    dxDrawRow("Aktywne kary", center-475/2/zoom+495/zoom, sh-674/zoom+311/zoom, 475/zoom, 330/zoom, texs[4], 0, 0, 0, white, a) -- right bottom
    dxDrawText(#punish > 0 and punish or "brak", center-475/2/zoom+495/zoom+30/zoom, sh-674/zoom+311/zoom+65/zoom+30/zoom, center-475/2/zoom+495/zoom+30/zoom+475/zoom-60/zoom, sh-674/zoom+311/zoom+65/zoom+30/zoom+180/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "top", true, true)
end

-- useful

function getCirclePosition(x,y,w)
    return x+w/2,y+w/2,w/2
end

function dxDrawRing (posX, posY, radius, width, startAngle, amount, color, postGUI, absoluteAmount, anglesPerLine)
	if (type (posX) ~= "number") or (type (posY) ~= "number") or (type (startAngle) ~= "number") or (type (amount) ~= "number") then
		return false
	end
	
	if absoluteAmount then
		stopAngle = amount + startAngle
	else
		stopAngle = (amount * 360) + startAngle
	end
	
	anglesPerLine = type (anglesPerLine) == "number" and anglesPerLine or 1
	radius = type (radius) == "number" and radius or 50
	width = type (width) == "number" and width or 5
	color = color or tocolor (255, 255, 255, 255)
	postGUI = type (postGUI) == "boolean" and postGUI or false
	absoluteAmount = type (absoluteAmount) == "boolean" and absoluteAmount or false
	
	for i = startAngle, stopAngle, anglesPerLine do
		local startX = math.cos (math.rad (i)) * (radius - width)
		local startY = math.sin (math.rad (i)) * (radius - width)
		local endX = math.cos (math.rad (i)) * (radius + width)
		local endY = math.sin (math.rad (i)) * (radius + width)
		dxDrawLine (startX + posX, startY + posY, endX + posX, endY + posY, color, width, postGUI)
	end
	return math.floor ((stopAngle - startAngle)/anglesPerLine)
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