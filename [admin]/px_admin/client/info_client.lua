--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local UI={}

local blur=exports.blur

UI.infos={}

UI.pos={
	sw/2-500/2/zoom,sh/2-20/2/zoom
}

UI.fonts = {
	dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", 10/zoom),
	dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 10/zoom),
}

UI.buttons={}

UI.button_click=false

-- renders

function dxDrawRectangle_(x,y,w,h,color)
	blur:dxDrawBlur(x,y,w,h,tocolor(255,255,255))
	dxDrawRectangle(x,y,w,h,color)
end

UI.onRender=function()
	dxDrawText("Klucz", UI.pos[1]+5/zoom+1, UI.pos[2]+1, 0+1, UI.pos[2]+20/zoom+1, tocolor(0, 0, 0, 255), 1, UI.fonts[2], "left", "center")
	dxDrawText("Klucz", UI.pos[1]+5/zoom, UI.pos[2], 0, UI.pos[2]+20/zoom, tocolor(222, 222, 222, 255), 1, UI.fonts[2], "left", "center")
	dxDrawText("Wartość", UI.pos[1]+5/zoom+1, UI.pos[2]+1, UI.pos[1]-5/zoom+500/zoom+1, UI.pos[2]+20/zoom+1, tocolor(0, 0, 0, 255), 1, UI.fonts[2], "right", "center")
	dxDrawText("Wartość", UI.pos[1]+5/zoom, UI.pos[2], UI.pos[1]-5/zoom+500/zoom, UI.pos[2]+20/zoom, tocolor(222, 222, 222, 255), 1, UI.fonts[2], "right", "center")

	local txt=""
	for i,v in pairs(UI.infos) do
		local sY=(20/zoom)*i
		if(i%2 == 1)then
			dxDrawRectangle_(UI.pos[1], UI.pos[2]+sY, 500/zoom, 20/zoom, tocolor(10, 10, 10, 200))
		else
			dxDrawRectangle_(UI.pos[1], UI.pos[2]+sY, 500/zoom, 20/zoom, tocolor(15, 15, 15, 200))
		end

		dxDrawText(v[1]..":", UI.pos[1]+5/zoom, UI.pos[2]+sY, 0, UI.pos[2]+sY+20/zoom, tocolor(200, 200, 200, 255), 1, UI.fonts[2], "left", "center")
		dxDrawText(v[2], UI.pos[1]+5/zoom, UI.pos[2]+sY, UI.pos[1]-5/zoom+500/zoom, UI.pos[2]+sY+20/zoom, tocolor(200, 200, 200, 255), 1, UI.fonts[1], "right", "center")

		if(v[2] == "aby wyświetlić skopiuj do konsoli")then
			if(#txt > 0)then
				txt=txt..", "..v[1]..": "..v[3]
			else
				txt=v[1]..": "..v[3]
			end
		else
			if(#txt > 0)then
				txt=txt..", "..v[1]..": "..v[2]
			else
				txt=v[1]..": "..v[2]
			end
		end
	end

	for i,v in pairs(UI.buttons) do
		local sY=(22/zoom)*(i-1)
		dxDrawRectangle_(UI.pos[1]+505/zoom, UI.pos[2]+20/zoom+sY, 20/zoom, 20/zoom, tocolor(15,15,15,200))
		dxDrawText(v[1], UI.pos[1]+505/zoom, UI.pos[2]+20/zoom+sY, 20/zoom+UI.pos[1]+505/zoom, 20/zoom+UI.pos[2]+20/zoom+sY, tocolor(200, 200, 200, 255), 1, UI.fonts[1], "center", "center")

		if(getKeyState("mouse1") and isMouseInPosition(UI.pos[1]+505/zoom, UI.pos[2]+20/zoom+sY, 20/zoom, 20/zoom) and not UI.button_click)then
			if(v[2] == "close")then
				removeEventHandler("onClientRender", root, UI.onRender)
				showCursor(false)
				return
			elseif(v[2] == "copy")then
				outputConsole(txt)
			elseif(v[2] == "tp" and v[3] and isElement(v[3]))then
				local x,y,z=getElementPosition(v[3])
				setElementPosition(localPlayer, x,y,z)
			end
			UI.button_click=v[2]
		elseif(not getKeyState("mouse1"))then
			UI.button_click=false
		end
	end

	if(UI.button_click == "change")then
		local cx,cy=getCursorPosition()
		cx,cy=cx*sw,cy*sh
		UI.pos={cx-510/zoom,cy-30/zoom}
	end
end

-- triggers

addEvent("pinfo.open", true)
addEventHandler("pinfo.open", resourceRoot, function(player, v, vehicles, mute, pj, houses, serial, groups_vehicles, money)
	if(player and v and vehicles and mute and pj and houses)then
		blur=exports.blur
		addEventHandler("onClientRender", root, UI.onRender)
		showCursor(true,false)

		local licenses=""
		local lic_letter=0
		for i,v in pairs((fromJSON(v.licenses) or {})) do
			if(v == 2)then
				licenses=#licenses > 0 and licenses..", "..string.upper(i) or string.upper(i)
				lic_letter=lic_letter+1
			end
		end
		licenses=#licenses < 1 and "brak" or licenses

		local water_vehs={}
		local parking_vehs={}
		local all_vehs={}
		for i,v in pairs(vehicles) do
			if(v.parking == 1)then
				table.insert(parking_vehs,v.id)
			end

			if(v.water == 1)then
				table.insert(water_vehs,v.id)
			end

			table.insert(all_vehs,v.id)
		end

		local all_houses={}
		for i,v in pairs(houses) do
			table.insert(all_houses,v.id)
		end

		local g_vehs={}
		for i,v in pairs(groups_vehicles) do
			table.insert(g_vehs,v.id)
		end

		local status=getElementData(player, "user:faction") or getElementData(player, "user:job") or "Swobodna rozgrywka"

		UI.infos={
			{"UID", v.forum_id},
			{"Login", v.login},
			{"Gotówka", money.."$"},
			{"Bankomat", (v.bank_money or 0).."$"},

			{"Rejestracja", v.register_date},
			{"Ostatnia wizyta", v.lastlogin},

			{"Serial", serial},
			{"Życie", math.floor(getElementHealth(player)).."%"},
			{"Skin", getElementModel(player)},

			{"Czas gry (łączny)", resulted(getElementData(player, "user:online_time"))},
			{"Czas gry (sesja)", resulted(getElementData(player, "user:sesion_time"))},
			{"Reputacja", getElementData(player, "user:reputation")},

			{"Ostrzeżenia", v.warns},
			{"Licencje ("..lic_letter..")", licenses},

			{"Pojazdy ("..#all_vehs..")", #table.concat(all_vehs,", ") > 0 and table.concat(all_vehs,", ") or "brak"},
			{"Pojazdy grupowe ("..#groups_vehicles..")", #table.concat(g_vehs,", ") > 0 and table.concat(g_vehs,", ") or "brak"},
			{"Pojazdy na parkingu wirtualnym ("..#parking_vehs..")", #table.concat(parking_vehs,", ") > 0 and table.concat(parking_vehs,", ") or "brak"},
			{"Pojazdy w wyławiarce ("..#water_vehs..")", #table.concat(water_vehs,", ") > 0 and table.concat(water_vehs,", ") or "brak"},
			{"Zawieszone prawko", #pj > 0 and "("..string.sub(pj[1].first_date,1,#pj[1].first_date-3).."-"..string.sub(pj[1].date,1,#pj[1].date-3)..") - "..pj[1].admin or "nie"},
			{"Wyciszenie", #mute > 0 and "("..string.sub(mute[1].first_date,1,#mute[1].first_date-3).."-"..string.sub(mute[1].date,1,#mute[1].date-3)..") - "..mute[1].admin or "nie"},
			{"Domki ("..#all_houses..")", #table.concat(all_houses,", ") > 0 and table.concat(all_houses,", ") or "brak"},

			{"Status", status},

			{"PREMIUM", getElementData(player, "user:premium") and v.premium or "nie"},
			{"GOLD", getElementData(player, "user:gold") and v.gold or "nie"},
		}

		UI.buttons={
			{"V", "change"},
			{"X", "close"},
			{"T", "tp", player},
			{"C", "copy"}
		}

		local posY=(20/zoom)*24
		UI.pos={
			sw/2-500/2/zoom,sh/2-posY/2/zoom
		}
	end
end)

addEvent("vinfo.open", true)
addEventHandler("vinfo.open", resourceRoot, function(v)
	if(not v)then return end

	blur=exports.blur
	addEventHandler("onClientRender", root, UI.onRender)
	showCursor(true,false)

	local NAMES=exports.px_vehicles:getTuningList()

    --upgrades
    local upgrades=""
	local tune=split(v.tuning, ',') or {}
    for i,v in ipairs(tune) do
        local slot=NAMES.tuningSlots[getVehicleUpgradeSlotName(v)] or getVehicleUpgradeSlotName(v)
        local upgrade=NAMES.tuningNames[v] or v
        if(upgrade == "Lampa" or slot == "Nitro" or slot == "Hydraulika" or slot == "Stereo")then
            text=slot
        else
            text=slot.." ("..upgrade..")"
        end

        if(#upgrades > 0)then
            upgrades=upgrades..", "..text
        else
            upgrades=text
        end
    end

	local mech=split(v.mechanicTuning, ',') or {}
	for i,v in pairs(mech) do
		if(#upgrades > 0)then
            upgrades=upgrades..", "..string.upper(v)
        else
            upgrades=string.upper(v)
        end
	end

    upgrades=#upgrades > 0 and upgrades or "brak"
    --

	local zone=(v.police and #v.police > 0) and "Parking policyjny" or v.parking ~= 0 and "Parking" or v.h_garage ~= 0 and "W garażu"
	if(not zone)then
		local vehElementID=getElementByID("px_vehicles_id:"..v.id)
		if(vehElementID and isElement(vehElementID))then
			local pos={getElementPosition(vehElementID)}
			zone=getZoneName(pos[1],pos[2],pos[3],false)..", "..getZoneName(pos[1],pos[2],pos[3],true).." (DIM: "..getElementDimension(vehElementID)..", INT: "..getElementInterior(vehElementID)..")"
		else
			zone='Błąd z pojazdem'
		end
	end

	UI.infos={
		{"ID", v.id},
		{"Stworzony jako", v.po_id},
		{"Model", getVehicleNameFromModel(v.model)},
		{"Pierwszy właściciel", v.first_owner},
		{"Właściciel", v.ownerName},
		{"Ostatni kierowca", v.lastDrivers},
		{"Przebieg", v.distance},
		{"Paliwo", v.fuel.."L/"..v.fuelTank.."L"},
		{"Organizacja", #v.organization > 0 and v.organization or "brak"},
		{"Tuning", upgrades ~= "brak" and "aby wyświetlić skopiuj do konsoli" or upgrades, upgrades},
		{"Lokalizacja", zone},
	}

	UI.buttons={
		{"V", "change"},
		{"X", "close"},
		{"C", "copy"}
	}

	local posY=(20/zoom)*11
	UI.pos={
		sw/2-500/2/zoom,sh/2-posY/2/zoom
	}
end)

-- useful

function isMouseInPosition(x, y, w, h)
	if(not isCursorShowing())then return end

	local cx,cy=getCursorPosition()
	cx,cy=cx*sw,cy*sh

    if(isCursorShowing() and (cx >= x and cx <= (x + w)) and (cy >= y and cy <= (y + h)))then
        return true
    end
    return false
end

function resulted(minutes)
	local h = math.floor(minutes/60)
	local m = minutes - (h*60)
	return h.."h "..m.."m"
end