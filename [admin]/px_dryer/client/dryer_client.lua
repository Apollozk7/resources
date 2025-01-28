--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local blur=exports.blur

local INTER = {}

INTER.options = {
	"Napraw pojazd",
	"Obróć pojazd",
	"Oddaj na parking",
	"Przenieś do siebie",
	"Przenieś do pojazdu",
	"Wejdź do pojazdu",
	"Zatankuj pojazd",
	"Zaciągnij ręczny"
}

INTER.pdOptions={
	"Zaciągnij ręczny",
	"Wystaw mandat (70)",
	"Wystaw mandat (110)",
}

INTER.saraOptions={
	"Zatankuj pojazd",
	"Zaciągnij ręczny",
}

INTER.vehicle = false
INTER.selected_option = 1
INTER.events = false

INTER.pd=false
INTER.sara=false

INTER.blockOption=0

INTER.onWeapon = function(pW, cW)
	if(getPedOccupiedVehicle(localPlayer))then return end

	if(getPedWeapon(localPlayer, cW) == 32 and not INTER.events)then
		if(getElementData(localPlayer, "user:admin") or getElementData(localPlayer, "user:faction") == "SAPD" or getElementData(localPlayer, "user:faction") == "SARA")then
			bindKey("mouse1", "down", INTER.onMouse)
			bindKey("mouse_wheel_up", "down", INTER.onKey)
			bindKey("mouse_wheel_down", "down", INTER.onKey)

			blur=exports.blur
			addEventHandler("onClientRender", root, INTER.onRender)

			INTER.events = true

			INTER.fonts = {
				dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 18/zoom),
				dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 13/zoom),
				dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 13/zoom),
				dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 12/zoom),
				dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 10/zoom),
				dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 30/zoom),
			}

			INTER.img = {
				dxCreateTexture("assets/images/window.png", "argb", false, "clamp"),
				dxCreateTexture("assets/images/arrow.png", "argb", false, "clamp"),
			}

			if(getElementData(localPlayer, "user:faction") == "SAPD")then
				INTER.pd=true
			elseif(getElementData(localPlayer, "user:faction") == "SARA")then
				INTER.sara=true
			end
		end
	elseif(getPedWeapon(localPlayer, cW) ~= 32 and INTER.events)then
		unbindKey("mouse1", "down", INTER.onMouse)
		unbindKey("mouse_wheel_up", "down", INTER.onKey)
		unbindKey("mouse_wheel_down", "down", INTER.onKey)

		removeEventHandler("onClientRender", root, INTER.onRender)

		INTER.events = false
		INTER.pd=false
		INTER.sara=false

		for i,v in pairs(INTER.fonts) do
			if(v and isElement(v))then
				destroyElement(v)
			end
		end

		for i,v in pairs(INTER.img) do
			if(v and isElement(v))then
				destroyElement(v)
			end
		end
	end
end
addEventHandler("onClientPlayerWeaponSwitch", root, INTER.onWeapon)

SPAM={}
SPAM.getSpam=function()
	local block=false

	if(SPAM.blockSpamTimer)then
		if(isTimer(SPAM.blockSpamTimer))then
			killTimer(SPAM.blockSpamTimer)
		end
		exports.px_noti:noti("Zaczekaj chwilę.", "error")
		return true
	end

	SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 100, 1)

	return false
end

INTER.onMouse = function()
	if(getPedOccupiedVehicle(localPlayer))then return end

	if(INTER.vehicle and isElement(INTER.vehicle))then
		if(INTER.pd)then
			local speed=getElementSpeed(INTER.vehicle, "km/h")
			if(INTER.selected_option == 1)then
				triggerServerEvent("interaction.admin", resourceRoot, INTER.vehicle, INTER.selected_option, true)
			elseif(INTER.selected_option > 1)then
				local max=INTER.selected_option == 2 and 70 or 110
				if(speed > max)then
					if(SPAM.getSpam())then return end

					getScreenshot(speed, true)
					triggerServerEvent("interaction.admin", resourceRoot, INTER.vehicle, INTER.selected_option, speed)
				end
			end
		elseif(INTER.sara)then
			if(INTER.selected_option == 2)then
				triggerServerEvent("interaction.admin", resourceRoot, INTER.vehicle, 1, true)
			else
				triggerServerEvent("interaction.admin", resourceRoot, INTER.vehicle, 7)
			end
		else
			triggerServerEvent("interaction.admin", resourceRoot, INTER.vehicle, INTER.selected_option)
		end
	end
end

INTER.onKey = function(key, keyState)
	if(key == "mouse_wheel_up")then
		if(INTER.pd)then
			INTER.selected_option = INTER.selected_option > 1 and INTER.selected_option-1 or #INTER.pdOptions
		elseif(INTER.sara)then
			INTER.selected_option = INTER.selected_option > 1 and INTER.selected_option-1 or #INTER.saraOptions
		else
			INTER.selected_option = INTER.selected_option > 1 and INTER.selected_option-1 or #INTER.options
		end
	elseif(key == "mouse_wheel_down")then
		if(INTER.pd)then
			INTER.selected_option = INTER.selected_option < #INTER.pdOptions and INTER.selected_option+1 or 1
		elseif(INTER.sara)then
			INTER.selected_option = INTER.selected_option < #INTER.saraOptions and INTER.selected_option+1 or 1
		else
			INTER.selected_option = INTER.selected_option < #INTER.options and INTER.selected_option+1 or 1
		end
	end
end

INTER.factions={
	["SARA"]=true,
	["SAPD"]=true,
	["PSP"]=true,
	["SACC"]=true,
}

INTER.onRender = function()
	if(isPedAiming() and getPedTarget(localPlayer) and getElementType(getPedTarget(localPlayer)) == "vehicle")then
		INTER.vehicle = getPedTarget(localPlayer)
	else
		INTER.vehicle = false
	end

	if(INTER.vehicle and isElement(INTER.vehicle))then
		local id = getElementData(INTER.vehicle, "vehicle:id") or getElementData(INTER.vehicle, "vehicle:group_id") or 0
		local name = getVehicleName(INTER.vehicle)

		local fuel = getElementData(INTER.vehicle, "vehicle:fuel") or 25
		local bak = getElementData(INTER.vehicle, "vehicle:fuelTank") or 25
		fuel = math.floor(fuel)

		local distance = getElementData(INTER.vehicle, "vehicle:distance") or 0
		distance = string.format("%.1f", distance)

		local owner=getElementData(INTER.vehicle, "vehicle:ownerName") or getElementData(INTER.vehicle, "vehicle:group_ownerName") or "brak"
		local owner_group=getElementData(INTER.vehicle, "vehicle:group_owner")
		if(tonumber(owner_group))then
			owner_group="(WYPO)"
		elseif(owner_group)then
			if(INTER.factions[owner_group])then
				owner_group="(FRAKCJA)"
			else
				owner_group="(ORG)"
			end
		else
			owner_group="(PRIV)"
		end

		local last_driver = getElementData(INTER.vehicle, "vehicle:lastDrivers") or {}
		last_driver=last_driver[#last_driver] or "brak"
		last_driver=getPlayerFromName(last_driver) and "#00ff00"..last_driver or "#ff0000"..last_driver

		local hex=getPlayerFromName(owner) and "#00ff00" or "#ff0000"

		local speed=getElementSpeed(INTER.vehicle, "km/h")

		local last=getElementData(INTER.vehicle, 'vehicle:lastUse') or getTimestamp()
		local now=getTimestamp()
		local online=math.abs((last-now)/60)

		local hours = math.floor(online/60)
		local minutes = math.floor(online-(hours*60))
		local time_s=(hours > 0 and hours.."h " or "")..(minutes > 0 and minutes.."m" or "0m")
		if(hours >= 24)then
			time_s=get_date_from_unix(last)
		end

		if(INTER.sara)then
			local health=getElementHealth(INTER.vehicle)
			local hp=((health-200)/800)
			hp=math.floor(hp*100)

			INTER.saraOptions[2]=getElementData(INTER.vehicle, "vehicle:handbrake") and "Spuść ręczny" or "Zaciągnij ręczny"

			local y=50/zoom
			blur:dxDrawBlur(sw/2-556/2/zoom, y, 556/zoom, 220/zoom, tocolor(255,255,255))
			dxDrawImage(sw/2-556/2/zoom, y, 556/zoom, 220/zoom, INTER.img[1])

			dxDrawText("Pomoc drogowa", sw/2-556/2/zoom, y, 556/zoom+sw/2-556/2/zoom, y+50/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[1], "center", "center", false, false, false, false, false)
			dxDrawRectangle(sw/2-518/2/zoom, y+50/zoom, 518/zoom, 1, tocolor(88,88,88))

			dxDrawText("Model\nPaliwo\nOstatni kierowca\nWłaściciel\nStan\nOstatnio używany", sw/2-518/2/zoom, y+50/zoom, 556/zoom+sw/2-556/2/zoom, y+220/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[2], "left", "center", false, false, false, false, false)
			dxDrawText(name.." (ID: "..id..")\n"..fuel.."l/"..bak.."l\n"..last_driver.."\n"..hex..owner.."#939393 "..owner_group.."\n"..hp.."%\n"..time_s, sw/2-556/2/zoom+40/zoom, y+50/zoom, 300/zoom+sw/2-556/2/zoom, y+220/zoom, tocolor(150, 150, 150, 255), 1, INTER.fonts[3], "right", "center", false, false, false, true, false)

			dxDrawRectangle(sw/2-518/2/zoom+300/zoom, y+25/zoom-(117-220)/2/zoom, 1, 117/zoom, tocolor(88,88,88))

			local color=speed > 70 and tocolor(255, 0, 0) or tocolor(200, 200, 200)
			dxDrawText(math.floor(speed), sw/2-556/2/zoom+300/zoom, y+25/zoom-(117-220)/2/zoom-60/zoom, 556/zoom+sw/2-556/2/zoom, y+25/zoom-(117-220)/2/zoom+117/zoom, color, 1, INTER.fonts[6], "center", "center", false, false, false, false, false)
			dxDrawText("KM/H", sw/2-556/2/zoom+300/zoom, y+25/zoom-(117-220)/2/zoom, 556/zoom+sw/2-556/2/zoom, y+25/zoom-(117-220)/2/zoom+117/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[1], "center", "center", false, false, false, false, false)
		
			dxDrawRectangle(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, y+150/zoom, 189/zoom, 24/zoom, tocolor(26,26,26,100))
			dxDrawRectangle(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, y+150/zoom+24/zoom, 189/zoom, 1, tocolor(0,168,255))
			dxDrawText(INTER.saraOptions[INTER.selected_option], sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, y+150/zoom, 189/zoom+sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, 24/zoom+y+150/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[4], "center", "center", false, false, false, false, false)
		
			local color1=tocolor(200, 200, 200)
			local color2=tocolor(200, 200, 200)
			dxDrawImage(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom+(24-10)/2/zoom, y+150/zoom+(24-10)/2/zoom, 10/zoom, 10/zoom, INTER.img[2], 0, 0, 0, color1)
			dxDrawImage(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom+189/zoom-10/zoom-(24-10)/2/zoom, y+150/zoom+(24-10)/2/zoom, 10/zoom, 10/zoom, INTER.img[2], 180, 0, 0, color2)
		elseif(INTER.pd)then
			INTER.pdOptions[1]=getElementData(INTER.vehicle, "vehicle:handbrake") and "Spuść ręczny" or "Zaciągnij ręczny"

			local y=50/zoom
			blur:dxDrawBlur(sw/2-556/2/zoom, y, 556/zoom, 220/zoom, tocolor(255,255,255))
			dxDrawImage(sw/2-556/2/zoom, y, 556/zoom, 220/zoom, INTER.img[1])

			dxDrawText("Radar policyjny", sw/2-556/2/zoom, y, 556/zoom+sw/2-556/2/zoom, y+50/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[1], "center", "center", false, false, false, false, false)
			dxDrawRectangle(sw/2-518/2/zoom, y+50/zoom, 518/zoom, 1, tocolor(88,88,88))

			dxDrawText("Model\nPrzebieg\nPaliwo\nOstatni kierowca\nWłaściciel\nOstatnio używany", sw/2-518/2/zoom, y+50/zoom, 556/zoom+sw/2-556/2/zoom, y+220/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[2], "left", "center", false, false, false, false, false)
			dxDrawText(name.." (ID: "..id..")\n"..distance.."km\n"..fuel.."l/"..bak.."l\n"..last_driver.."\n"..hex..owner.."#939393 "..owner_group.."\n"..time_s, sw/2-556/2/zoom+40/zoom, y+50/zoom, 300/zoom+sw/2-556/2/zoom, y+220/zoom, tocolor(150, 150, 150, 255), 1, INTER.fonts[3], "right", "center", false, false, false, true, false)

			dxDrawRectangle(sw/2-518/2/zoom+300/zoom, y+25/zoom-(117-220)/2/zoom, 1, 117/zoom, tocolor(88,88,88))

			local color=speed > 70 and tocolor(255, 0, 0) or tocolor(200, 200, 200)
			dxDrawText(math.floor(speed), sw/2-556/2/zoom+300/zoom, y+25/zoom-(117-220)/2/zoom-60/zoom, 556/zoom+sw/2-556/2/zoom, y+25/zoom-(117-220)/2/zoom+117/zoom, color, 1, INTER.fonts[6], "center", "center", false, false, false, false, false)
			dxDrawText("KM/H", sw/2-556/2/zoom+300/zoom, y+25/zoom-(117-220)/2/zoom, 556/zoom+sw/2-556/2/zoom, y+25/zoom-(117-220)/2/zoom+117/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[1], "center", "center", false, false, false, false, false)
		
			dxDrawRectangle(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, y+150/zoom, 189/zoom, 24/zoom, tocolor(26,26,26,100))
			dxDrawRectangle(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, y+150/zoom+24/zoom, 189/zoom, 1, tocolor(0,168,255))
			dxDrawText(INTER.pdOptions[INTER.selected_option], sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, y+150/zoom, 189/zoom+sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, 24/zoom+y+150/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[4], "center", "center", false, false, false, false, false)
		
			local color1=tocolor(200, 200, 200)
			local color2=tocolor(200, 200, 200)
			dxDrawImage(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom+(24-10)/2/zoom, y+150/zoom+(24-10)/2/zoom, 10/zoom, 10/zoom, INTER.img[2], 0, 0, 0, color1)
			dxDrawImage(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom+189/zoom-10/zoom-(24-10)/2/zoom, y+150/zoom+(24-10)/2/zoom, 10/zoom, 10/zoom, INTER.img[2], 180, 0, 0, color2)
		else
			if(getElementData(INTER.vehicle, "vehicle:group_id"))then
				INTER.options[3]="Odstaw na bazę"
			elseif(id > 0)then
				INTER.options[3]="Oddaj na parking"
			else
				INTER.options[3]="Usuń pojazd"
			end

			INTER.options[8]=getElementData(INTER.vehicle, "vehicle:handbrake") and "Spuść ręczny" or "Zaciągnij ręczny"

			blur:dxDrawBlur(sw/2-556/2/zoom, sh/2-230/2/zoom, 556/zoom, 230/zoom, tocolor(255,255,255))
			dxDrawImage(sw/2-556/2/zoom, sh/2-230/2/zoom, 556/zoom, 230/zoom, INTER.img[1])
			
			dxDrawText("Opcje administracyjne", sw/2-556/2/zoom, sh/2-230/2/zoom, 556/zoom+sw/2-556/2/zoom, sh/2-230/2/zoom+50/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[1], "center", "center", false, false, false, false, false)
			dxDrawRectangle(sw/2-518/2/zoom, sh/2-230/2/zoom+50/zoom, 518/zoom, 1, tocolor(88,88,88))
			
			dxDrawText("Model\nPrzebieg\nPaliwo\nOstatni kierowca\nWłaściciel\nOstatnio używany", sw/2-518/2/zoom, sh/2-230/2/zoom+50/zoom, 556/zoom+sw/2-556/2/zoom, sh/2-230/2/zoom+230/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[2], "left", "center", false, false, false, false, false)
			dxDrawText(name.." (ID: "..id..")\n"..distance.."km\n"..fuel.."l/"..bak.."l\n"..last_driver.."\n"..hex..owner.."#939393 "..owner_group.."\n"..time_s, sw/2-556/2/zoom+40/zoom, sh/2-230/2/zoom+50/zoom, 300/zoom+sw/2-556/2/zoom, sh/2-230/2/zoom+230/zoom, tocolor(150, 150, 150, 255), 1, INTER.fonts[3], "right", "center", false, false, false, true, false)
			
			dxDrawRectangle(sw/2-518/2/zoom+300/zoom, sh/2-230/2/zoom+25/zoom-(117-230)/2/zoom, 1, 117/zoom, tocolor(88,88,88))
			
			dxDrawText("Wybrana interakcja", sw/2-556/2/zoom+300/zoom, sh/2-230/2/zoom+100/zoom, 556/zoom+sw/2-556/2/zoom, sh/2-230/2/zoom+50/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[2], "center", "center", false, false, false, false, false)
			
			dxDrawRectangle(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, sh/2-5/zoom-15/zoom, 189/zoom, 24/zoom, tocolor(26,26,26,100))
			dxDrawRectangle(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, sh/2-5/zoom+24/zoom-15/zoom, 189/zoom, 1, tocolor(0,168,255))
			dxDrawText(INTER["options"][INTER["selected_option"]], sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, sh/2-5/zoom-15/zoom, 189/zoom+sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, 24/zoom+sh/2-5/zoom-15/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[4], "center", "center", false, false, false, false, false)
			
			local color1=tocolor(200, 200, 200)
			local color2=tocolor(200, 200, 200)
			dxDrawImage(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom+(24-10)/2/zoom, sh/2-5/zoom+(24-10)/2/zoom-15/zoom, 10/zoom, 10/zoom, INTER.img[2], 0, 0, 0, color1)
			dxDrawImage(sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom+189/zoom-10/zoom-(24-10)/2/zoom, sh/2-5/zoom+(24-10)/2/zoom-15/zoom, 10/zoom, 10/zoom, INTER.img[2], 180, 0, 0, color2)
			
			dxDrawText("Klawiszologia:\nUżyj scrolla do zmiany interakcji\nUżyj LPM aby zatwierdzić", sw/2-500/2/zoom+300/zoom+(518-300-189)/2/zoom, sh/2-230/2/zoom+280/zoom, 556/zoom+sw/2-556/2/zoom, sh/2-230/2/zoom+50/zoom, tocolor(200, 200, 200, 255), 1, INTER.fonts[5], "left", "center", false, false, false, false, false)
		end
	end
end

-- useful

function isMouseIn(x, y, w, h)
	if not isCursorShowing() then return end

	local pos = {getCursorPosition()}
	pos[1],pos[2] = (pos[1]*sw),(pos[2]*sh)

	if pos[1] >= x and pos[1] <= (x+w) and pos[2] >= y and pos[2] <= (y+h) then
		return true
	end
	return false
end

function isPedAiming()
	if getPedTask(localPlayer, "secondary", 0) == "TASK_SIMPLE_USE_GUN" then
		return true
	end
	return false
end

-- useful

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and "ignore" argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

-- screens

local w,h = 650,400
local screen=dxCreateScreenSource(w/zoom, h/zoom)
local flashed=false
local rt=false

function render()
    dxDrawImage(sw-700/zoom, sh/2-h/2/zoom, w/zoom, h/zoom, rt, -10, 0, 0, tocolor(255, 255, 255, 222), false)

	if(flashed)then
		dxDrawRectangle(0, 0, sw, sh, tocolor(255, 255, 255))
	end
end

function getScreenshot(speed, flash)
	flashed=not flash
	rt=dxCreateRenderTarget(w,h,true)
	dxUpdateScreenSource(screen)

	dxSetRenderTarget(rt,true)
		dxDrawImage(0, 0, w, h, screen)
		dxDrawText(math.floor(speed).."km/h", 0, 0, w, h, tocolor(255, 0, 0), 2, "default-bold", "right", "bottom")
	dxSetRenderTarget()

	addEventHandler("onClientRender", root, render)

	setTimer(function()
		removeEventHandler("onClientRender", root, render)
		destroyElement(rt)
		rt=false
	end, 5000, 1)
	setTimer(function()
		flashed=false
	end, 500, 1)
end
addEvent("get.screenshot", true)
addEventHandler("get.screenshot", resourceRoot, getScreenshot)

-- useful

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end

function get_date_from_unix(unix_time)
    local day_count, year, days, month = function(yr) return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365 end, 1970, math.ceil(unix_time/86400)

    while days >= day_count(year) do
        days = days - day_count(year) year = year + 1
    end

    local tab_overflow = function(seed, table) for i = 1, #table do if seed - table[i] <= 0 then return i, seed end seed = seed - table[i] end end
    month, days = tab_overflow(days, {31,(day_count(year) == 366 and 29 or 28),31,30,31,30,31,31,30,31,30,31})
    return string.format("%04d-%02d-%02d", year, month, days)
end