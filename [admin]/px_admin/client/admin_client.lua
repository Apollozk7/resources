--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

sw,sh = guiGetScreenSize()
zoom = 1920/sw
if(zoom > 1)then
	zoom=zoom/1.3
end

local blur=exports.blur

local ucho = {
	logs = {},
	reports = {},
	last_report=false
}

local warn = {
	text = "",
	admin = "",
	tick = getTickCount()
}

local fonts = {
	-- logi
	dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", 11/zoom),
	dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 11/zoom),

	--warny
	dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 20/zoom),
	dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 15/zoom),
	dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 13/zoom),
	dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", 10/zoom),
	dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 13/zoom),
}

local warn_tex=dxCreateTexture("assets/images/window.png", "argb", false, "clamp")

-- exports

local ranks = {}

local skey="dsnbb371651ebxyuHDJKEDKL337d6xbnzJDND3H"
local jsonAsset="assets/info.json"

function decode(text)
	return decodeString("tea", text, {key=skey})
end

function loadJSONData()
	local file=fileOpen(jsonAsset)
	local text=fileRead(file, fileGetSize(file))
	ranks=fromJSON(decode(text))
	fileClose(file)
end
loadJSONData()

function getRanks()
	return ranks
end

local admin_time=0

function timer_fnc()
	if(getElementData(localPlayer, "user:admin") and not getElementData(localPlayer, "user:afk") and not getElementData(localPlayer, "user:job") and not getElementData(localPlayer, "user:faction"))then
		admin_time=admin_time+1
	end
end

-- renders

local admin_info=false
local admin_timer=false
local adminRender=function()
	if(admin_info)then
		local hours = math.floor(admin_time/60)
		local minutes = math.floor(admin_time-(hours*60))
		local time=(hours > 0 and hours.."m " or "")..(minutes > 0 and minutes.."s" or "0s")
		
		if(ranks[admin_info.rank])then
			exports.px_hud:showFooterInfo(ranks[admin_info.rank].hex..ranks[admin_info.rank].name.."#ffffff - "..time, ranks[admin_info.rank].name.." - "..time)
		end
	end	

  	--ucho
	if getElementData(localPlayer, "user:admin") and getElementData(localPlayer, "user:admin_logs") then
		local logi = table.concat(ucho.logs, "\n")
		blur:dxDrawBlur(21/zoom, sh-600/zoom, 350/zoom, 25/zoom, tocolor(255, 255, 255))
		dxDrawRectangle(21/zoom, sh-600/zoom, 350/zoom, 25/zoom, tocolor(30, 30, 30, 150))
		dxDrawText("Logi serwerowe:", 21/zoom+5/zoom+1, sh-600/zoom+1, 350/zoom+21/zoom+1, 25/zoom+sh-600/zoom+1, tocolor(0, 0, 0, 255), 1, fonts[1], "left", "center", false, false, false, false, false)
		dxDrawText("Logi serwerowe:", 21/zoom+5/zoom, sh-600/zoom, 350/zoom+21/zoom, 25/zoom+sh-600/zoom, tocolor(200, 200, 200, 255), 1, fonts[1], "left", "center", false, false, false, false, false)

		dxDrawText(logi, 21/zoom + 1, sh-600/zoom + 1 +30/zoom, 400/zoom + 1, 749/zoom + 1, tocolor(0, 0, 0, 255), 1, fonts[2], "left", "top", false, true, false, false, false)
		dxDrawText(logi, 21/zoom, sh-600/zoom+30/zoom, 400/zoom, 749/zoom, tocolor(222, 222, 222, 255), 1, fonts[2], "left", "top", false, true, false, false, false)
	end

	if getElementData(localPlayer, "user:admin") and getElementData(localPlayer, "user:admin_reports") then
    	local text = ""
		local newReports = (#ucho.reports - 10)
		local n = "\n"
		local _n = ""

		blur:dxDrawBlur(sw - 21/zoom-350/zoom, 350/zoom, 350/zoom, 25/zoom, tocolor(255, 255, 255))
		dxDrawRectangle(sw - 21/zoom-350/zoom, 350/zoom, 350/zoom, 25/zoom, tocolor(30, 30, 30, 150))
    	dxDrawText("Lista reportów:", 21/zoom + 1, 350/zoom + 1, sw - 21/zoom - 5/zoom + 1, 350/zoom+25/zoom + 1, tocolor(0, 0, 0, 255), 1, fonts[1], "right", "center", false, false, false, false, false)
		dxDrawText("Lista reportów:", 21/zoom, 350/zoom, sw - 21/zoom - 5/zoom, 350/zoom+25/zoom, tocolor(200, 200, 200, 255), 1, fonts[1], "right", "center", false, false, false, false, false)

		for i = 1,10 do
			local v = ucho.reports[i]
			if(v)then
				if(v[2] and isElement(v[2]))then
					n = n.."\n"
					_n = _n.."\n"

					dxDrawText(_n..v[1], 21/zoom+1, 355/zoom+1, sw - 21/zoom+1, 749/zoom+1, tocolor(0, 0, 0, 255), 1, fonts[2], "right", "top", false, false, false, false, false)
					dxDrawText(_n..v[1], 21/zoom, 355/zoom, sw - 21/zoom, 749/zoom, tocolor(222, 222, 222, 255), 1, fonts[2], "right", "top", false, false, false, false, false)
				else
					ucho.reports[i]=nil
				end
			end
		end

		blur:dxDrawBlur(sw - 21/zoom-350/zoom, 300/zoom, 350/zoom, 25/zoom, tocolor(255, 255, 255))
		dxDrawRectangle(sw - 21/zoom-350/zoom, 300/zoom, 350/zoom, 25/zoom, tocolor(30, 30, 30, 150))
		dxDrawText("Ostatnio wzięty report:", 21/zoom + 1, 300/zoom + 1, sw - 21/zoom - 5/zoom + 1, 300/zoom+25/zoom + 1, tocolor(0, 0, 0, 255), 1, fonts[1], "right", "center", false, false, false, false, false)
		dxDrawText("Ostatnio wzięty report:", 21/zoom, 300/zoom, sw - 21/zoom - 5/zoom, 300/zoom+25/zoom, tocolor(200, 200, 200, 255), 1, fonts[1], "right", "center", false, false, false, false, false)
		if(ucho.last_report)then
			dxDrawText("\n"..ucho.last_report[1], 21/zoom + 1, 305/zoom + 1, sw - 21/zoom + 1, 749/zoom + 1, tocolor(0, 0, 0, 255), 1, fonts[2], "right", "top", false, false, false, false, false)
			dxDrawText("\n"..ucho.last_report[1], 21/zoom, 305/zoom, sw - 21/zoom, 749/zoom, tocolor(222, 222, 222, 255), 1, fonts[2], "right", "top", false, false, false, false, false)
		else
			dxDrawText("\nbrak", 21/zoom + 1, 305/zoom + 1, sw - 21/zoom + 1, 749/zoom + 1, tocolor(0, 0, 0, 255), 1, fonts[2], "right", "top", false, false, false, false, false)
			dxDrawText("\nbrak", 21/zoom, 305/zoom, sw - 21/zoom, 749/zoom, tocolor(222, 222, 222, 255), 1, fonts[2], "right", "top", false, false, false, false, false)
		end

		dxDrawText(n.."razem: "..#ucho.reports, 21/zoom + 1, 355/zoom + 1, sw - 21/zoom + 1, 749/zoom + 1, tocolor(0, 0, 0, 255), 1, fonts[1], "right", "top", false, false, false, false, false)
		dxDrawText(n.."razem: "..#ucho.reports, 21/zoom, 355/zoom, sw - 21/zoom, 749/zoom, tocolor(222, 222, 222, 255), 1, fonts[1], "right", "top", false, false, false, false, false)
		if(newReports > 0)then
			dxDrawText(n.."\ndodatkowo: "..newReports, 21/zoom + 1, 355/zoom + 1, sw - 21/zoom + 1, 749/zoom + 1, tocolor(0, 0, 0, 255), 1, fonts[1], "right", "top", false, false, false, false, false)
			dxDrawText(n.."\ndodatkowo: "..newReports, 21/zoom, 355/zoom, sw - 21/zoom, 749/zoom, tocolor(222, 222, 222, 255), 1, fonts[1], "right", "top", false, false, false, false, false)
		end
	end
end

local warnRender=function()
	if(warn.text ~= "")then
		blur:dxDrawBlur(sw/2-556/2/zoom, sh/2-195/2/zoom, 556/zoom, 195/zoom, tocolor(255, 255, 255))
		dxDrawImage(sw/2-556/2/zoom, sh/2-195/2/zoom, 556/zoom, 195/zoom, warn_tex, 0, 0, 0, tocolor(255, 255, 255), false)
		dxDrawText("Ostrzeżenie", sw/2-556/2/zoom, sh/2-195/2/zoom, 556/zoom+sw/2-556/2/zoom, sh/2-195/2/zoom+50/zoom, tocolor(200, 200, 200), 1, fonts[3], "center", "center")
		dxDrawRectangle(sw/2-518/2/zoom, sh/2-195/2/zoom+50/zoom, 518/zoom, 1, tocolor(88,88,88))
		dxDrawText("Otrzymałeś ostrzeżenie od "..warn.admin.."!", sw/2-556/2/zoom, sh/2-195/2/zoom+60/zoom, 556/zoom+sw/2-556/2/zoom, sh/2-195/2/zoom+50/zoom, tocolor(200, 200, 200), 1, fonts[4], "center", "top")
		dxDrawText("Powód ostrzeżenia:", sw/2-500/2/zoom, sh/2-195/2/zoom+100/zoom, 500/zoom+sw/2-500/2/zoom, sh/2-195/2/zoom+50/zoom, tocolor(200, 200, 200), 1, fonts[5], "center", "top",false,true)
		dxDrawText("\n"..warn.text, sw/2-500/2/zoom, sh/2-195/2/zoom+100/zoom, 500/zoom+sw/2-500/2/zoom, sh/2-195/2/zoom+50/zoom, tocolor(200, 0, 0), 1, fonts[7], "center", "top",false,true)
		dxDrawText("> NIESTOSOWANIE SIĘ DO OSTRZEŻEŃ MOŻE SKUTKOWAĆ KICKIEM LUB BANEM.", sw/2-556/2/zoom, sh/2-195/2/zoom+170/zoom, 556/zoom+sw/2-556/2/zoom, sh/2-195/2/zoom+50/zoom, tocolor(200, 200, 200), 1, fonts[6], "center", "top")
	end
end

-- triggers

addEvent("dutyStatusChanged", true)
addEventHandler("dutyStatusChanged", resourceRoot, function(status,rank)
	if(getElementData(localPlayer, "user:job"))then return end

	if(status)then
		blur=exports.blur

		addEventHandler("onClientRender", root, adminRender)

		admin_info={status=status,rank=rank}

		admin_timer=setTimer(timer_fnc, 1000, 0)
	else
		removeEventHandler("onClientRender", root, adminRender)

		admin_info=false

		if(admin_timer and isTimer(admin_timer))then
			killTimer(admin_timer)
			admin_timer=false
			admin_time=0
		end
	end
end)
if(getElementData(localPlayer, 'user:admin'))then
	triggerEvent('dutyStatusChanged', resourceRoot, true, getElementData(localPlayer, 'user:admin'))
end

addEvent("addAdminNotification", true)
addEventHandler("addAdminNotification", resourceRoot, function(text)
	exports.px_informations:noti(text, "admin")
	outputConsole(text)
end)

addEvent("updateLogs", true)
addEventHandler("updateLogs", root, function(logs)
	if getElementData(localPlayer, "user:admin_logs") and getElementData(localPlayer, "user:admin") then
    	ucho.logs = logs
  	end
end)

addEvent("addReport", true)
addEventHandler("addReport", resourceRoot, function(text, player, getPlayer)
	table.insert(ucho.reports, {text, player, getPlayer})
end)

addEvent("removeReport", true)
addEventHandler("removeReport", resourceRoot, function(player, admin, type)
	for i = 1,#ucho["reports"] do
		if(ucho["reports"][i][2] == player)then
			if(admin == localPlayer and type == "cl")then
				ucho.last_report = {ucho["reports"][i][1], ucho["reports"][i][2], ucho["reports"][i][3], i}
			end
			
			if(ucho["reports"][i] and ucho["reports"][i][3] == localPlayer)then
				if(type == "cl")then
					exports.px_noti:noti("Twój report jest w trakcie rozpatrywania.")
				elseif(type == "xcl")then
					exports.px_noti:noti("Twój report zawierał niedokładne informacje, dlatego został odrzucony przez administratora.")
				end
			end

			table.remove(ucho["reports"], i)

			break
		end
	end
end)

addEvent("addWarn", true)
addEventHandler("addWarn", resourceRoot, function(text,admin)
	local time_warn = 10*1000 -- sekund minutka

	warn.text = text
	warn.admin = admin

	playSoundFrontEnd(5)
	setTimer(function()
		playSoundFrontEnd(5)
	end, (time_warn/100), 100)

	blur=exports.blur
	addEventHandler("onClientRender", root, warnRender)

	setTimer(function()
		warn.text = ""
		warn.admin = ""
		removeEventHandler("onClientRender", root, warnRender)
	end, time_warn, 1)
end)

-- get positions

function formatPosition(x,y,z)
	return string.format("%.4f", x), string.format("%.4f", y), string.format("%.4f", z)
end

addCommandHandler("gp", function()
	if(not getElementData(localPlayer, "user:admin"))then return end

	local element = getPedOccupiedVehicle(localPlayer) or localPlayer
	local x,y,z = getElementPosition(element)
	x,y,z=formatPosition(x,y,z)
	local txt = x..","..y..","..z
	outputChatBox(txt)
	setClipboard(txt)
end)

addCommandHandler("gp2", function()
	if(not getElementData(localPlayer, "user:admin"))then return end

	local element = getPedOccupiedVehicle(localPlayer) or localPlayer
	local x,y,z = getElementPosition(element)
	local _,_,rz = getElementRotation(element)
	x,y,z=formatPosition(x,y,z)
	_,_,rz=formatPosition(0,0,rz)
	local txt = x..","..y..","..z..","..rz
	outputChatBox(txt)
	setClipboard(txt)
end)

addCommandHandler("gpx", function()
	if(not getElementData(localPlayer, "user:admin"))then return end

	local element = getPedOccupiedVehicle(localPlayer) or localPlayer
	local x,y,z = getElementPosition(element)
	x,y,z=formatPosition(x,y,z)
	local txt = "{"..x..","..y..","..z.."},"
	outputChatBox(txt)
	setClipboard(txt)
end)

addCommandHandler("gpx2", function()
	if(not getElementData(localPlayer, "user:admin"))then return end

	local element = getPedOccupiedVehicle(localPlayer) or localPlayer
	local x,y,z = getElementPosition(element)
	local _,_,rz = getElementRotation(element)
	x,y,z=formatPosition(x,y,z)
	_,_,rz=formatPosition(0,0,rz)
	local txt = "{"..x..","..y..","..z..","..rz.."},"
	outputChatBox(txt)
	setClipboard(txt)
end)

addCommandHandler("gc", function()
	if(not getElementData(localPlayer, "user:admin"))then return end

	local cx,cy,cz,cx2,cy2,cz2 = getCameraMatrix()
	cx,cy,cz=formatPosition(cx,cy,cz)
	cx2,cy2,cz2=formatPosition(cx2,cy2,cz2)
	local txt = cx..","..cy..","..cz..","..cx2..","..cy2..","..cz2
	outputChatBox(txt)
	setClipboard(txt)
end)

addCommandHandler("gp3", function()
	if(not getElementData(localPlayer, "user:admin"))then return end

	local element = getPedOccupiedVehicle(localPlayer) or localPlayer
	local x,y,z = getElementPosition(element)
	x,y,z=formatPosition(x,y,z)
	local txt = x..","..y..","
	outputChatBox(txt)
	setClipboard(txt)
end)

-- useful
function hex2rgb(hex)
  hex = hex:gsub("#","")
  return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function dxDrawShadowText(text, x, y, w, h, color, size, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
	local text_gsub=string.gsub(text, "#%x%x%x%x%x%x", "")
	dxDrawText(text_gsub, x+1, y+1, w+1, h+1, tocolor(0, 0, 0), size, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
	dxDrawText(text, x, y, w, h, color, size, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
end

setElementData(localPlayer, "user:haveReport", false)