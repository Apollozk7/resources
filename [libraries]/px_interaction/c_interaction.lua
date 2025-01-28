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
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 500, 1)

    return block
end

-- exports
local noti=exports.px_noti
local progressbar=exports.px_progressbar
local dashboard=exports.px_dashboard
local workshops=exports.px_workshops

-- variables
sw,sh=guiGetScreenSize()
zoom=1920/sw
zoom=zoom+0.3

-- misc variables
local showed=false
local blur=false
local selected=0
local tbl={}
local alpha=0
local development=false

-- elements
local back=dxCreateTexture("textures/background.png", "argb", false, "clamp")
local arrow=dxCreateTexture("textures/arrow.png", "argb", false, "clamp")
local bg=dxCreateTexture("textures/bg.png", "argb", false, "clamp")

local font = dxCreateFont(":px_assets/fonts/Font-Medium.ttf", math.floor(23/zoom))
local font2 = dxCreateFont(":px_assets/fonts/Font-Regular.ttf", math.floor(15/zoom))

local block=false

-- functions

function resultInteraction(items)
	local new_items={}

	local first_item=false
	local first_element=false

	for i,v in pairs(items) do
		first_item=getElementType(v.element)
		first_element=v.element
		break
	end

	for i,v in pairs(items) do
		if(getElementType(v.element) == first_item and v.element == first_element)then
			new_items[#new_items+1]=v
		end
	end

	return new_items
end

function getNearestPlayer(vehicle,player)
    local result = false
    local p = {getElementPosition(vehicle)}
    local x = getElementsWithinRange(p[1],p[2],p[3],8,"player")
    if #x > 0 then
		for i,v in pairs(x) do
			if(v == player)then
				table.remove(x,i)
				break
			end
		end

		if #x > 0 then
        	result = x[math.random(#x)]
		end
    end
    return result
end

function getNearestVehicle(player)
    local result = false
    local p = {getElementPosition(player)}
    local x = getElementsWithinRange(p[1],p[2],p[3],8,"vehicle")
    if #x > 0 then
        result = x[math.random(#x)]
    end
    return result
end

function loadElement(v)
	local myPos={getElementPosition(localPlayer)}

	local eq_item=getElementData(localPlayer, "user:have_item")

	local faction=getElementData(localPlayer, "user:faction")
	local cuffs=getElementData(localPlayer, "police:handcuffs")

	local warsztat={
		["Mechanik"]={text="Wyślij ofertę naprawy",tex="textures/icons/car-fix-icon.png",script="px_workshop_mechanic"},
		["Tuner"]={text="Wyślij ofertę tuningu",tex=":px_workshop_tuning/assets/images/wheel.png",script="px_workshop_tuning"},
		["Lakiernik"]={text="Wyślij ofertę lakierowania",tex=":px_workshop_sprays/assets/images/spray.png",script="px_workshop_sprays"},
	}

	local fuel=getElementData(localPlayer, "user:player_fuel_line")
	local fuels={
		["odstaw"]={
			{name="Odłóż wąż", alpha=150, tex=":px_fuel_stations/textures/odloz.png"},
			{name="Opłać zamówienie", alpha=150, tex=":px_fuel_stations/textures/zaplac.png"},
		},

		["wez"]={
			{name="Weź wąż z PB-95", alpha=150, tex=":px_fuel_stations/textures/pb95.png"},
			{name="Weź wąż z ON", alpha=150, tex=":px_fuel_stations/textures/on.png"},
		},

		["lpg"]={
			{name="Weź wąż z LPG", alpha=150, tex=":px_fuel_stations/textures/lpg.png"},
		}
	}

	if(v and isElement(v))then
		local inter=getElementData(v, "interaction")
		local max_dist=inter and inter.dist or 5
		local ePos = {getElementPosition(v)}
		local dist = getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], ePos[1], ePos[2], ePos[3])
		if(development or (tonumber(dist) <= tonumber(max_dist)))then
			if(inter)then			
				if(inter.fuel and getElementData(localPlayer, "user:job") ~= "Rafineria")then
					if(not fuel)then
						if(inter.lpg)then
							for _,k in pairs(fuels.lpg) do
								k.tex=dxCreateTexture(k.tex, "argb", false, "clamp")
								k.type=inter.type
								k.scriptName=inter.scriptName
								k.info=inter.info
								k.id=inter.id
								k.element=v

								tbl[#tbl+1]=k
							end
						else
							for _,k in pairs(fuels.wez) do
								k.tex=dxCreateTexture(k.tex, "argb", false, "clamp")
								k.type=inter.type
								k.scriptName=inter.scriptName
								k.info=inter.info
								k.id=inter.id
								k.element=v

								tbl[#tbl+1]=k
							end
						end
					else
						for _,k in pairs(fuels.odstaw) do
							k.tex=dxCreateTexture(k.tex, "argb", false, "clamp")
							k.type=inter.type
							k.scriptName=inter.scriptName
							k.info=inter.info
							k.id=inter.id
							k.element=v

							tbl[#tbl+1]=k
						end
					end
				else
					for _,k in pairs(inter.options) do
						tbl[#tbl+1]={
							tex=dxCreateTexture(k.tex or "textures/error.png", "argb", false, "clamp"),
							type=inter.type,
							scriptName=inter.scriptName,
							info=inter.info,
							id=inter.id,
							element=v,
							name=k.name,
							alpha=0,
							animate=false
						}
					end
				end
			elseif(getElementType(v) == "vehicle" and getVehicleName(v) ~= "Bike" and getVehicleName(v) ~= "BMX" and getVehicleName(v) ~= "Mountain Bike")then
				for _,k in pairs(warsztat) do
					local player=getVehicleController(v)
					if(player)then
						if(workshops:isPlayerHaveInteraction(player, _))then
							tbl[#tbl+1]={name=k.text, alpha=150, tex=dxCreateTexture(k.tex, "argb", false, "clamp"), element=player, type="client", scriptName=false, script=k.script}
						end
					end
				end
				
				-- private vehicles
				local owner=getElementData(v, "vehicle:ownerName") or getElementData(v, "vehicle:group_ownerName")

				-- kanister
				if(eq_item and eq_item.name == "Kanister 5L")then
					tbl[#tbl+1]={name="Wlej paliwo", alpha=150, tex=dxCreateTexture("textures/icons/gasoline-icon.png", "argb", false, "clamp"), element=v, type="client", dist=3, scriptName=false}
				end
				--

				-- naprawka
				if(eq_item and string.find(tostring(eq_item.name),"Zestaw naprawczy"))then
					local tex=eq_item.name == "Zestaw naprawczy opon" and dxCreateTexture("textures/icons/car-tirefix-icon.png", "argb", false, "clamp") or dxCreateTexture("textures/icons/car-fix-icon.png", "argb", false, "clamp")
					tbl[#tbl+1]={name="Użyj zestawu naprawczego", alpha=150, tex=tex, element=v, type="client", dist=3, scriptName=false}
				end
				--

				-- factions
				if(faction == "SAPD")then
					if(cuffs and isElement(cuffs))then
						if(isPedInVehicle(cuffs))then
							tbl[#tbl+1]={name="Wysadź", alpha=150, tex=dxCreateTexture(":px_factions_handcuffs/textures/wysadz.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_factions_handcuffs"}
						else
							tbl[#tbl+1]={name="Wsadź", alpha=150, tex=dxCreateTexture(":px_factions_handcuffs/textures/wsadz.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_factions_handcuffs"}
						end
					end

					tbl[#tbl+1]={name="Wysadź pasażerów", alpha=150, tex=dxCreateTexture(":px_factions_handcuffs/textures/wysadz.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_factions_handcuffs"}
				end

				local data=getElementData(v, "vehicle:group_owner")
				data=data == "SAPD" and data or data == "SARA" and data or data == "PSP" and data or false
				if(data and faction == data)then
					tbl[#tbl+1]={name="Wyposażenie", alpha=150, tex=dxCreateTexture("textures/icons/schowek-icon.png", "argb", false, "clamp"), element=v, type="client", dist=3, scriptName="px_factions_items"}
				end

				if(faction == "SARA")then
					tbl[#tbl+1]={name="Wyślij ofertę naprawy", alpha=150, tex=dxCreateTexture("textures/icons/car-fix-icon.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_factions-offers"}
					tbl[#tbl+1]={name="Wyślij ofertę tankowania", alpha=150, tex=dxCreateTexture("textures/icons/gasoline-icon.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_factions-offers"}
				end

				if(faction == "PSP" and data == "PSP")then
					tbl[#tbl+1]={name="Wąż gaśniczy", alpha=150, tex=dxCreateTexture(":px_jobs-refinery/textures/hose_icon.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_factions_line"}
				end

				if(faction == "SARA" and data == "SARA")then
					tbl[#tbl+1]={name=getElementData(v, "tow:haveVehicle") and "Rozładuj pojazd" or "Załaduj pojazd", alpha=150, tex=dxCreateTexture(":px_factions-towing/sara.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_factions-towing"}
				end
				--

				local data=getElementData(v, "vehicle:group_owner")
				if((owner and owner == getPlayerName(localPlayer)) or (data and faction and data == faction))then
					tbl[#tbl+1]={name="Schowek", alpha=150, element=v, type="client", dist=7, scriptName=false, tex=dxCreateTexture("textures/icons/schowek-icon.png", "argb", false, "clamp")}
					tbl[#tbl+1]={name="Drzwi", alpha=150, element=v, type="client", dist=7, scriptName=false, tex=dxCreateTexture("textures/icons/drzwi-icon.png", "argb", false, "clamp")}
					tbl[#tbl+1]={name="Maska", alpha=150, element=v, type="client", dist=7, scriptName=false, tex=dxCreateTexture("textures/icons/maska-icon.png", "argb", false, "clamp")}
					tbl[#tbl+1]={name="Bagażnik", alpha=150, element=v, type="client", dist=7, scriptName=false, tex=dxCreateTexture("textures/icons/bagaznik-icon.png", "argb", false, "clamp")}
					tbl[#tbl+1]={name="Zamek", alpha=150, element=v, type="client", dist=7, scriptName=false, tex=dxCreateTexture("textures/icons/otworz-zamknij-icon.png", "argb", false, "clamp")}

					if(getVehicleName(v) == "Pony")then
						tbl[#tbl+1]={name="Stereo", alpha=150, element=v, type="client", dist=7, scriptName="px_audio_vehs", tex=dxCreateTexture("textures/icons/stereo_icon.png", "argb", false, "clamp")}
					end
				end

				local player=getNearestPlayer(v,localPlayer)
				if(player)then
					local rot=getElementRotation(v)
					if rot > 160 and rot < 200 then
						tbl[#tbl+1]={name="Obróć pojazd", alpha=150, tex=dxCreateTexture("textures/icons/obracanie-icon.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_flip_vehicles", info=player}
					end
				end
			elseif(getElementType(v) == "player" and not isPedInVehicle(v) and v ~= localPlayer)then
				-- player to player
				local element=v
				inter={options={},scriptName=false,dist=3,type="server",element=v,scriptName="px_eq"}

				tbl[#tbl+1]={name="Przywitaj się", alpha=150, tex=dxCreateTexture("textures/icons/przywitanie-icon.png", "argb", false, "clamp"), element=v, type="server", dist=1, scriptName=false}
				if(not getElementData(v, "user:nameMask"))then
					tbl[#tbl+1]={name="Dodaj do znajomych", alpha=150, tex=dxCreateTexture("textures/icons/friend.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName=false}
					tbl[#tbl+1]={name="Siłowanie na rękę", alpha=150, tex=dxCreateTexture("textures/icons/silowanie-icon.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName=false}
				end

				if(getElementData(v, "user:bw"))then
					tbl[#tbl+1]={name="Reanimuj", alpha=150, tex=dxCreateTexture("textures/icons/zdejmijbw-icon.png", "argb", false, "clamp"), element=v, type="client", dist=3, scriptName="px_bw"}
				end

				if(getElementData(v, "Area.InZone") and getElementData(v, "user:bw"))then
					tbl[#tbl+1]={name="Okradnij", alpha=150, tex=dxCreateTexture("textures/icons/robbery.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_dm-main"}
				end

				if(getElementData(localPlayer, "user:faction") == "SAPD")then
					local data=getElementData(v, "user:handcuffs")
					if(data)then
						tbl[#tbl+1]={name="Rozkuj", alpha=150, tex=dxCreateTexture(":px_factions_handcuffs/textures/zakuj.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_factions_handcuffs"}
					else
						tbl[#tbl+1]={name="Zakuj", alpha=150, tex=dxCreateTexture(":px_factions_handcuffs/textures/zakuj.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_factions_handcuffs"}
					end

					tbl[#tbl+1]={name="Przeszukaj", alpha=150, tex=dxCreateTexture("textures/icons/przeszukanie.png", "argb", false, "clamp"), element=v, type="client", dist=3, scriptName="px_factions-search"}
					tbl[#tbl+1]={name="Wsadź do więzienia", alpha=150, tex=dxCreateTexture(":px_factions_handcuffs/textures/zakuj.png", "argb", false, "clamp"), element=v, type="client", dist=3, scriptName="px_factions-jail"}
				end
				
				local pojazd=getNearestVehicle(localPlayer)
				if(pojazd)then
					local rot=getElementRotation(pojazd)
					if rot > 160 and rot < 200 then
						tbl[#tbl+1]={name="Obróć pojazd", alpha=150, tex=dxCreateTexture("textures/icons/obracanie-icon.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_flip_vehicles", info=pojazd}
					end
				end

				-- biznesy (komis)
				local busi=getElementData(localPlayer, 'user:businessOwner')
				if(busi and busi.name == 'Komis samochodowy')then
					tbl[#tbl+1]={name="Sprzedaj pojazd", alpha=150, tex=dxCreateTexture(":px_business-main/textures/car-sale.png", "argb", false, "clamp"), element=v, type="server", dist=3, scriptName="px_business-main"}
				end
			end
		end
	end
end

function loadInteraction()
	local myPos={getElementPosition(localPlayer)}

	local only=false
	for i,v in pairs(getElementsWithinRange(myPos[1], myPos[2], myPos[3], 10)) do
		if(v and isElement(v))then
			local data=getElementData(v, "interaction:only")
			if(data and data == localPlayer)then
				loadElement(v)
				only=true
				break
			end
		end
	end

	if(not only)then
		for i,v in pairs(getElementsWithinRange(myPos[1], myPos[2], myPos[3], 5)) do
			loadElement(v)
		end

		tbl=resultInteraction(tbl)
	end
end

function action(id, veh, option, script)
	local eq_item=getElementData(localPlayer, "user:have_item")

	if(option == "Siłowanie na rękę")then
		h.sendOffer(veh)
	elseif(option == "Wyślij ofertę naprawy" or option == "Wyślij ofertę tuningu" or option == "Wyślij ofertę lakierowania")then
		local v=getPedOccupiedVehicle(veh)
		if(veh and v and getVehicleController(v) == veh)then
			exports.px_workshops:sendOffer(veh, v, localPlayer, script)
		end
	elseif(option == "Wlej paliwo" and eq_item and eq_item.name == "Kanister 5L")then
		progressbar:createProgressbar(sw/2-671/2/zoom, sh-50/zoom, 671/zoom, 4/zoom, "Trwa wlewanie paliwa...", 15/zoom, 5000, false, 0)

		setPedAnimation(localPlayer, "CAMERA", "camstnd_to_camcrch", -1, false, false)

		noti:noti("Rozpoczynasz wlewanie paliwa...")

		triggerServerEvent("interaction.action", resourceRoot, veh, "off")

		setElementFrozen(localPlayer, true)

		setTimer(function()
			progressbar:destroyProgressbar()
			setPedAnimation(localPlayer, false)
			setElementFrozen(localPlayer, false)
			triggerServerEvent("interaction.action", resourceRoot, veh, "paliwo", 5)
			noti:noti("Pomyślnie dolano 5 litrów paliwa do pojazdu "..getVehicleName(veh)..".", "success")
		end, 5000, 1)
	elseif(option == "Użyj zestawu naprawczego" and eq_item and string.find(tostring(eq_item.name),"Zestaw naprawczy"))then
		progressbar:createProgressbar(sw/2-671/2/zoom, sh-50/zoom, 671/zoom, 4/zoom, "Trwa naprawa...", 15/zoom, 20000, false, 0)

		setPedAnimation(localPlayer, "CAMERA", "camstnd_to_camcrch", -1, false, false)

		noti:noti("Rozpoczynasz naprawę...")

		triggerServerEvent("interaction.action", resourceRoot, veh, "take")

		setElementFrozen(localPlayer, true)

		setTimer(function()
			progressbar:destroyProgressbar()
			setPedAnimation(localPlayer, false)
			triggerServerEvent("interaction.action", resourceRoot, veh, "napraw", false, eq_item)
			noti:noti("Naprawa pojazdu "..getVehicleName(veh).." została zakończona.")
			setElementFrozen(localPlayer, false)
		end, 20000, 1)
	elseif(option == "Schowek")then
		exports.px_eq:toggleSafe(veh)
	elseif(option == "Przywitaj się")then
		triggerServerEvent("interaction.action", resourceRoot, veh, option)
	else
		local ids=option == "Zamknij" and 1 or option == "Bagażnik" and 4 or option == "Maska" and 3 or option == "Drzwi" and 2 or id
		triggerServerEvent("interaction.action", resourceRoot, veh, ids, option)
	end
end

function getImagePosition(i)
	local x,y=0,0
	if(i == 1)then
		x,y=sw/2-738/2/zoom+445/zoom, sh/2-738/2/zoom+70/zoom
	elseif(i == 2)then
		x,y=sw/2-738/2/zoom+595/zoom, sh/2-738/2/zoom+238/zoom
	elseif(i == 3)then
		x,y=sw/2-738/2/zoom+595/zoom, sh/2-738/2/zoom+423/zoom
	elseif(i == 4)then
		x,y=sw/2-738/2/zoom+445/zoom, sh/2-738/2/zoom+590/zoom
	elseif(i == 7)then
		x,y=sw/2-738/2/zoom+445/zoom-390/zoom, sh/2-738/2/zoom+238/zoom
	elseif(i == 6)then
		x,y=sw/2-738/2/zoom+445/zoom-390/zoom, sh/2-738/2/zoom+423/zoom
	elseif(i == 5)then
		x,y=sw/2-738/2/zoom+205/zoom, sh/2-738/2/zoom+590/zoom
	elseif(i == 8)then
		x,y=sw/2-738/2/zoom+205/zoom, sh/2-738/2/zoom+70/zoom
	end
	return {x,y}
end

function getImageRotation(i)
	local rot=0
	if(i == 1)then
		rot=25
	elseif(i == 2)then
		rot=70
	elseif(i == 3)then
		rot=-250
	elseif(i == 4)then
		rot=-205
	elseif(i == 7)then
		rot=-70
	elseif(i == 6)then
		rot=250
	elseif(i == 5)then
		rot=205
	elseif(i == 8)then
		rot=-25
	end
	return rot
end

function onRender()
	if(getElementData(localPlayer, "user:bw"))then return end

	if(isPedInVehicle(localPlayer))then
		close()
		return
	end

	toggleControl("fire",false)

	local cX,cY=getCursorPosition()
	cX,cY=cX*sw,cY*sh

	local rot=findRotation(cX, cY, sw/2, sh/2)
	dxDrawImage(sw/2-738/2/zoom, sh/2-738/2/zoom, 738/zoom, 738/zoom, back, 0, 0, 0, tocolor(255, 255, 255, alpha))
	for i=1,(#tbl > 8 and 8 or #tbl) do
		i=i-1
		dxDrawImage(sw/2-738/2/zoom, sh/2-738/2/zoom, 738/zoom, 738/zoom, bg, 360*(i/8), 0, 0, tocolor(255, 255, 255, alpha))
	end

	dxDrawImage(sw/2-738/2/zoom, sh/2-738/2/zoom, 738/zoom, 738/zoom, arrow, rot, 0, 0, tocolor(255, 255, 255, alpha), false)

	local text="Wybierz interakcje"

	local pos={}
	local rot={}
	local value={}
	local x,y,z=getElementPosition(localPlayer)
	for i,v in pairs(tbl) do
		local rx,ry,rz=getElementPosition(v.element)
		local dist=getDistanceBetweenPoints3D(x,y,z,rx,ry,rz)
		if(dist > 10 and not development)then
			tbl[i]=nil
		end

		if(i <= 8)then
			pos=getImagePosition(i)
			rot=getImageRotation(i)

			if(isMouseInPosition(pos[1], pos[2], 78/zoom, 78/zoom))then
				text=v.name
			end

			if(v.alpha < 150)then
				v.alpha=150
			end

			if(isMouseInPosition(pos[1], pos[2], 78/zoom, 78/zoom) and not v.animate)then
				playSound("sounds/hover.mp3")
				v.animate = true

				animate(v.alpha, 255, "InQuad", 200, function(a)
					if(v.animate)then
						v.alpha = a
				  	end
				end)
			elseif(not isMouseInPosition(pos[1], pos[2], 78/zoom, 78/zoom) and v.animate)then
				v.animate = false

				animate(v.alpha, 150, "InQuad", 200, function(a)
					if(not v.animate)then
						v.alpha = a
				  	end
				end)
			end

			dxDrawImage(pos[1], pos[2], 78/zoom, 78/zoom, (v and v.tex and isElement(v.tex)) and v.tex or "textures/icons/error.png", rot, 0, 0, tocolor(255, 255, 255, alpha > v.alpha and v.alpha or alpha), false)

			onClick(pos[1], pos[2], 78/zoom, 78/zoom, function()
				playSound("sounds/click.mp3")
			
				if(v.name == "Dodaj do znajomych")then
					if(SPAM.getSpam())then return end

					close()

					triggerServerEvent("addFriend", resourceRoot, v.element)

					return
				else
					if(v.scriptName)then
						if(v.type and v.type == "server")then
							close()

							if(SPAM.getSpam())then return end

							triggerServerEvent("action", resourceRoot, v.scriptName, i, v.element, v.name, v.id, v.info)

							return
						else
							close()
							if(SPAM.getSpam())then return end

							exports[v.scriptName]:action(i, v.element, v.name, v.info)
							return
						end
					else
						close()

						if(SPAM.getSpam())then return end

						action(i, v.element, v.name, v.script)
						return
					end
				end
			end)
		end
	end

	dxDrawText(text, sw/2-738/2/zoom, sh/2-738/2/zoom, 738/zoom+sw/2-738/2/zoom, 738/zoom+sh/2-738/2/zoom-40/zoom, tocolor(200, 200, 200, alpha), 1, font, "center", "center")
	dxDrawText("#c2c2c2Użyj #6dffbamyszki#c2c2c2 lub #6dffbascrolla#c2c2c2, aby\nwybrać akcję w interakcji.", sw/2-738/2/zoom, sh/2-738/2/zoom, 738/zoom+sw/2-738/2/zoom, 738/zoom+sh/2-738/2/zoom+50/zoom, tocolor(255, 255, 255, alpha), 1, font2, "center", "center", false, false, false, true)

	dxDrawText("(( kliknij na element aby otworzyć z nim interakcje ))", 0+1, 0+1, sw+1, sh-20/zoom+1, tocolor(0, 0, 0, alpha), 1, font2, "center", "bottom", false, false, false, true)
	dxDrawText("(( kliknij na element aby otworzyć z nim interakcje ))", 0, 0, sw, sh-20/zoom, tocolor(150, 200, 150, alpha), 1, font2, "center", "bottom", false, false, false, true)
end

function click(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if(clickedElement and isElement(clickedElement) and button == "left" and state == "down" and not isMouseInPosition(sw/2-738/2/zoom, sh/2-738/2/zoom, 738/zoom, 738/zoom))then
		local myPos = {getElementPosition(localPlayer)}
		local ePos = {getElementPosition(clickedElement)}
		local dist = getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], ePos[1], ePos[2], ePos[3])
		if(dist <= 10)then
			development=true
			tbl={}
			loadElement(clickedElement)
			tbl=resultInteraction(tbl)
		end
	end
end

function open()
	if(animated)then return end
    if(getElementData(localPlayer, "user:gui_showed"))then return end
	if(getElementData(localPlayer, "user:bw"))then return end

	noti=exports.px_noti
	progressbar=exports.px_progressbar
	dashboard=exports.px_dashboard
	workshops=exports.px_workshops

	animated=true
	showed = true
	selected=0

	addEventHandler("onClientRender", root, onRender)
	addEventHandler("onClientKey", root, key)
	addEventHandler("onClientClick", root, click)

	showCursor(true)

	loadInteraction()

	animate(0, 255, "Linear", 300, function(a)
		alpha=a
	end, function()
		animated=false
	end)

	setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

	toggleControl("next_weapon", false)
	toggleControl("previous_weapon", false)
end

function close(a)
	if(a)then
		if(animated)then return end

		animated=true
		animate(255, 0, "Linear", 300, function(a)
			alpha=a
		end, function()
			animated=false
			showed=false
			development=false

			for i,v in pairs(tbl) do
				if(v.tex and isElement(v.tex))then
					destroyElement(v.tex)
				end
			end
			tbl={}

			removeEventHandler("onClientRender", root, onRender)
			removeEventHandler("onClientKey", root, key)
			removeEventHandler("onClientClick", root, click)

			showCursor(false)

			setElementData(localPlayer, "user:gui_showed", false, false)

			toggleControl("next_weapon", true)
			toggleControl("previous_weapon", true)
		end)
	else
		alpha=0

		removeEventHandler("onClientRender", root, onRender)
		removeEventHandler("onClientKey", root, key)
		removeEventHandler("onClientClick", root, click)

		for i,v in pairs(tbl) do
			if(v.tex and isElement(v.tex))then
				destroyElement(v.tex)
			end
		end
		tbl={}

		showed = false
		animated=false
		development=false

		showCursor(false)

		setElementData(localPlayer, "user:gui_showed", false, false)

		setTimer(function()
			toggleControl("next_weapon", true)
			toggleControl("previous_weapon", true)
		end, 200, 1)
	end
end

function key(button, press)
	if(press)then
		if(button == "mouse_wheel_up")then
			selected=selected-1
			if(selected == 0)then selected=8 end
			local pos=getImagePosition(selected)
			setCursorPosition(pos[1]+78/2/zoom,pos[2]+78/2/zoom)
		elseif(button == "mouse_wheel_down")then
			selected=selected+1
			if(selected > 8)then selected=1 end
			local pos=getImagePosition(selected)
			setCursorPosition(pos[1]+78/2/zoom,pos[2]+78/2/zoom)
		end
	end
end

-- events

bindKey("E", "both", function(_, keyState)
	if(not getElementData(localPlayer, "user:uid") or isPedInVehicle(localPlayer))then return end

	if(not showed and keyState == "down")then
		open()
	elseif(showed and keyState == "up")then
		close(true)
	end
end)

-- useful

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

-- blocked

function blockPlayer(player)
	local uid=getElementData(player, "user:uid")
	if(not uid)then return false end

	local uid_=getElementData(localPlayer, "user:uid")
	if(not uid_)then return false end

	local blocked=getElementData(localPlayer, "blocked:users") or {}
	blocked[uid]=true
	setElementData(localPlayer, "blocked:users", blocked)

	return true
end

function unblockPlayer(player)
	local uid=getElementData(player, "user:uid")
	if(not uid)then return false end

	local uid_=getElementData(localPlayer, "user:uid")
	if(not uid_)then return false end

	local blocked=getElementData(localPlayer, "blocked:users") or {}
	if(blocked[uid])then blocked[uid]=nil end
	setElementData(localPlayer, "blocked:users", blocked)

	return true
end

function isPlayerBlocked(player)
	local uid=getElementData(player, "user:uid")
	if(not uid)then return false end

	local uid_=getElementData(localPlayer, "user:uid")
	if(not uid_)then return false end

	local blocked=getElementData(localPlayer, "blocked:users") or {}
	return blocked[uid]
end

-- friends

function addFriend(player)
	triggerServerEvent("addFriend", resourceRoot, player)
end

function removeFriend(...)
	triggerServerEvent("removeFriend", resourceRoot, ...)
end

function isPlayerInFriends(player)
    local friends=getElementData(localPlayer, "friends:data") or {}
    local uid=getElementData(player, "user:uid")
    local inFriends=false
    for i,v in pairs(friends) do
        if(v.uid == uid)then
            inFriends=true
            break
        end
    end
    return inFriends
end

function findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
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

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)