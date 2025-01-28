--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local zarobki={
	[5]=10000,
	[4]=3000,
	[3]=2500,
	[2]=1500,
	[1]=1000
}

function givePlayerPayment(player, minutes, rank)
	local firstTime=minutes
	minutes=minutes/60

	if(minutes > 0)then
		local money=zarobki[rank] -- hajs za 1h roboty
		if(money)then
			local payment=(minutes/60)*money -- wyliczamy wypłate.
			if(player and isElement(player))then
				exports.px_noti:noti("Za przepracowane "..math.floor(firstTime).." minut na służbie administracyjnej, otrzymujesz "..math.floor(payment).."$.", player)
				givePlayerMoney(player, payment)
			else
				return payment
			end
		end
	end
end

-- variables

local logs = {}

-- set ranks
local ranks={}

local jsonAsset="assets/info.json"
local skey="dsnbb371651ebxyuHDJKEDKL337d6xbnzJDND3H"

function encode(text)
	return encodeString("tea", text, {key=skey})
end

function decode(text)
	return decodeString("tea", text, {key=skey})
end

function updateJSONAssets(tbl)
	fileDelete(jsonAsset)

	local file=fileCreate(jsonAsset)
	if(file)then
		fileWrite(file, encode(toJSON(tbl)))
		fileClose(file)
	end
end

function loadJSONData()
	local q=exports.px_connect:query("select * from admins_ranks")

	local tbl={}
	for i,v in pairs(q) do
		v.permsData={}
		for _,k in pairs(split(v.perms, ", ")) do
			v.permsData[k]=true
		end
	
		ranks[v.id]=v
		tbl[v.id]={name=v.name, id=v.id, hex=v.hex, rgb=v.rgb}
	end

	local file=fileOpen(jsonAsset)
	local text=fileRead(file, fileGetSize(file))
	if(encode(toJSON(tbl)) ~= text)then
		updateJSONAssets(tbl)
	end
	fileClose(file)
end
loadJSONData()

-- functions

function getRanks()
	return ranks
end

function isPlayerHavePerm(player, name)
	local id=getElementData(player, "user:admin")
	if(not id)then return false end

	return ranks[id].permsData["all"] and true or (ranks[id].permsData[name])
end

function isRankHavePerm(id, name)
	return ranks[id].permsData["all"] and true or (ranks[id].permsData[name])
end

addCommandHandler("sloty", function(plr,_,x)
	if(getElementData(plr, "user:admin") == 6)then
		setMaxPlayers(tonumber(x))
	end
end)

function addPlayerReport(player)
	local uid=getElementData(player, "user:uid")
	if(not uid)then return end

	local r=exports.px_connect:query('select * from admins_stats where uid=? and `date`=date', uid)
	if(r and #r == 1)then
		exports.px_connect:query('update admins_stats set reports=reports+? where uid=? and `date`=date', 1, uid)
	else
		exports.px_connect:query('insert into admins_stats (uid,reports,`date`) values(?,?,date)', uid, 1)
	end
end

--

addCommandHandler("duty", function(player)
	local uid=getElementData(player, "user:uid")
	if(not uid)then return end

	local query = exports.px_connect:query("select * from admins where serial=? and nick=? and uid=? limit 1", getPlayerSerial(player), getPlayerName(player), uid)
	if query and #query > 0 then
		local rank = ranks[query[1].rank] or ranks[1]
		if getElementData(player, "user:admin") then
			exports.px_noti:noti("Pomyślnie wylogowano z rangi: "..rank.name, player, 'success')

			triggerClientEvent(player, "dutyStatusChanged", resourceRoot, false, getElementData(player, "user:admin"))

			setElementData(player, "user:admin", false)
			setElementData(player, "user:admin_logs", false)
			setElementData(player, "user:admin_reports", false)

			takeWeapon(player, 32)

			addLogs("admins", "duty-off", player, "cmd")

			if(getElementData(player, "user:inv"))then
				setElementAlpha(player, 255)
				removeElementData(player, "user:inv")
			end

			exports.px_discord:sendDiscordLogs("Wylogowanie z duty.", "admincmd", player)

			removePedJetPack(player)

			local dutyTime=getElementData(player, 'user:adminTimeTick') or getTickCount()
			local realDutyTime=(getTickCount()-dutyTime)/1000
			local admin_time=math.floor(realDutyTime/60)
			if(admin_time > 0)then
				local r=exports.px_connect:query('select * from admins_stats where uid=? and `date`=date', uid)
				if(r and #r == 1)then
					exports.px_connect:query('update admins_stats set minutes=minutes+? where uid=? and `date`=date', admin_time, uid)
				else
					exports.px_connect:query('insert into admins_stats (uid,minutes,`date`) values(?,?,date)', uid, admin_time)
				end
				givePlayerPayment(player, admin_time, rank.id)
			end
		else
			if(not getElementData(player,"user:job") or (getElementData(player,"user:job") and query[1].rank > 3))then
				exports.px_noti:noti("Pomyślnie zalogowano na rangę: "..rank.name, player, 'success')

				setElementData(player, "user:admin", query[1].rank)
				setElementData(player, "user:admin_logs", true)
				setElementData(player, "user:admin_reports", true)

				setElementData(player, 'user:adminTimeTick', getTickCount())

				giveWeapon(player, 32)

				triggerClientEvent(player, "updateLogs", resourceRoot, logs)
				triggerClientEvent(player, "dutyStatusChanged", resourceRoot, true, query[1].rank)

				addLogs("admins", "duty-on", player, "cmd")

				exports.px_discord:sendDiscordLogs("Zalogowanie na duty.", "admincmd", player)
			end
		end
	end
end)

addCommandHandler("admins", function(player)
	local tbl={}
	for i,v in pairs(ranks) do
		tbl[#ranks-v.id+1]={text=v.hex..v.name.."#939393: ",elements={}}
	end

	for i,v in pairs(getAdmins()) do
		local a = getElementData(v, "user:admin")
		if(a)then
			a=#ranks-a+1
			tbl[a].text=#tbl[a].elements > 0 and tbl[a].text..", #939393"..getPlayerName(v) or tbl[a].text..getPlayerName(v)
			tbl[a].elements[#tbl[a].elements+1]=v
		end
	end

	outputChatBox("#939393Administracja online:", player, 255, 255, 255, true)
	for i,v in pairs(tbl) do
		if(#v.elements > 0)then
			outputChatBox(v.text, player, 255, 255, 255, true)
		end
	end
end)

-- admin chat
addEventHandler("onPlayerChat", root, function(text)
	local sub=string.sub(text, 1, 1)
	local tekst=string.sub(text, 2, #text)
	local rank=getElementData(source, "user:admin")
	if(rank)then
		if(sub == "@" and #tekst > 0)then
			tekst=exports.px_core:stripColors(tekst)
			for i,v in pairs(getAdmins()) do
				if(getElementData(v, "user:admin"))then
					outputChatBox("#ff0000[@]#ffffff #9f9f9f["..getElementData(source, "user:id").."] "..ranks[rank].hex..getPlayerName(source).."#ffffff: "..tekst, v, 255, 255, 255, true)
				end
			end
		elseif(sub == "@")then
			exports.px_noti:noti("Poprawne użycie: @<tekst>", source)
		end
	end
end)
--

function RGBToHex(red, green, blue, alpha)
	
	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end

local chats = {
	["c"] = {6, 128, 0, 0},
	["g"] = {5, 10, 61, 145},
	["a"] = {4, 255, 0, 0},
	["gm"] = {3, 0, 94, 19},
	["cm"] = {2, 0, 227, 76},
	["gl"] = {1, 0, 255, 174},
}

local lastChat=3000
for i,v in pairs(chats) do
	addCommandHandler(i, function(player, _, ...)
		if ... and getElementData(player, "user:admin") and getElementData(player, "user:admin") >= v[1] then
			if((getTickCount()-lastChat) > 3000)then
				lastChat=getTickCount()
				if(i == "gl")then
					local text = table.concat({...}, " ")
					local x,y,z = getElementPosition(player)
					local getPlayersInColShape = getElementsWithinRange(x, y, z, 100, "player")
					for _,players in pairs(getPlayersInColShape) do
						if(getElementData(players, "user:admin"))then
							outputChatBox(RGBToHex(v[2], v[3], v[4]).."> "..text.." - "..getPlayerName(player), players, 255, 255, 255, true)
						else
							outputChatBox(RGBToHex(v[2], v[3], v[4]).."> "..text, players, 255, 255, 255, true)
						end
					end
					exports.px_discord:sendDiscordLogs("/"..i.." - "..text, "admincmd", player)
				else
					local text = table.concat({...}, " ")
					for _,players in pairs(getElementsByType("player")) do
						if(getElementData(players, "user:admin"))then
							outputChatBox(RGBToHex(v[2], v[3], v[4])..">> "..text.." - "..getPlayerName(player), players, 255, 255, 255, true)
						else
							outputChatBox(RGBToHex(v[2], v[3], v[4])..">> "..text, players, 255, 255, 255, true)
						end
					end
					exports.px_discord:sendDiscordLogs("/"..i.." - "..text, "admincmd", player)
				end
			else
				exports.px_noti:noti("Poczekaj 3 sekundy.", player, "info")
			end
		end
	end)
end

addCommandHandler("paliwo", function(player)
	if isPlayerHavePerm(player, "cmd_paliwo") then
		local vehicle = getPedOccupiedVehicle(player)
		if vehicle then
			setElementData(vehicle, "vehicle:fuel", (getElementData(vehicle, "vehicle:bak") or 25))
			exports.px_discord:sendDiscordLogs("/paliwo", "admincmd", player)
		end
	end
end)

addCommandHandler("warn", function(player, _, toPlayer, ...)
	if isPlayerHavePerm(player, "cmd_warn") then
		if toPlayer and ... then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				if getElementData(toPlayer, "user:admin") and getElementData(toPlayer, "user:admin") > getElementData(player, "user:admin") then
					exports.px_noti:noti("Nie posiadasz takich uprawnień.", player)
					return
				end

				local reason = table.concat({...}, " ")
				triggerClientEvent(root, "addAdminNotification", resourceRoot, getPlayerName(toPlayer).." otrzymał ostrzeżenie od "..getPlayerName(player).." z powodu "..reason)
				triggerClientEvent(toPlayer, "addWarn", resourceRoot, reason, getPlayerName(player))

				addLogs("admins", "warn", player, "cmd", toPlayer)
				exports.px_discord:sendDiscordLogs("/warn "..getPlayerName(toPlayer)..", powód: "..reason, "admincmd", player)
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /warn <id/nick> <powód>", player)
		end
	end
end)

addCommandHandler("dim", function(player, _, dim)
	if isPlayerHavePerm(player, "cmd_dim") then
		if dim then
			if(getPedOccupiedVehicle(player) and getElementData(player, "user:admin") < 3)then
				exports.px_noti:noti("Najpierw opuść pojazd!", player)
				return
			end

			setElementDimension(player, dim)
			if(getPedOccupiedVehicle(player))then
				setElementDimension(getPedOccupiedVehicle(player), dim)
			end
			exports.px_discord:sendDiscordLogs("/dim "..dim, "admincmd", player)
		else
			exports.px_noti:noti("Poprawne użycie: /dim <id/nick> <id>", player)
		end
	end
end)

addCommandHandler("int", function(player, _, int)
	if isPlayerHavePerm(player, "cmd_int") then
		if int then
			setElementInterior(player, int)
			exports.px_discord:sendDiscordLogs("/int "..int, "admincmd", player)
		else
			exports.px_noti:noti("Poprawne użycie: /int <id/nick> <id>", player)
		end
	end
end)

addCommandHandler("k", function(player, _, toPlayer, ...)
	if isPlayerHavePerm(player, "cmd_kick") then
		if toPlayer and ... then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				if getElementData(toPlayer, "user:admin") and getElementData(toPlayer, "user:admin") > getElementData(player, "user:admin") then
					exports.px_noti:noti("Nie posiadasz takich uprawnień.", player)
					return
				end

				local reason = table.concat({...}, " ")

				triggerClientEvent(root, "addAdminNotification", resourceRoot, getPlayerName(toPlayer).." został wykopany przez "..getPlayerName(player).." z powodu "..reason)

				outputConsole("--------------", toPlayer)
				outputConsole("Zostałeś wykopany z serwera przez "..getPlayerName(player), toPlayer)
				outputConsole("Powód: "..reason, toPlayer)
				outputConsole("--------------", toPlayer)

				exports.px_discord:sendDiscordLogs("/kick "..getPlayerName(toPlayer)..", powód: "..reason, "admincmd", player)
				exports.px_discord:sendDiscordLogs("/kick "..getPlayerName(toPlayer)..", powód: "..reason, "kick", player)			
				addLogs("admins", "kick", player, "cmd", toPlayer)

				kickPlayer(toPlayer, "Zobacz konsole (~)")
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /k <id/nick> <powód>", player)
		end
	end
end)

-- bans
function addBanPlayer(player, jednostka, czas, powod, admin, admin_uid)
	local unit = jednostka == "m" and "minute" or jednostka == "h" and "hour" or jednostka == "d" and "day" or "month"
	exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? "..unit..",?,1,?,?)", "ban", getPlayerName(player), getPlayerSerial(player), getPlayerIP(player), admin, czas, powod, getElementData(player, "user:uid") or 0, admin_uid or 0)
	triggerClientEvent(root, "addAdminNotification", resourceRoot, getPlayerName(player).." został zbanowany przez "..admin.." z powodu "..powod.." ("..czas..jednostka..")")
	kickPlayer(player, "Połącz się ponownie")
end

addCommandHandler("b", function(player, _, toPlayer, jednostka, czas, ...)
	if isPlayerHavePerm(player, "cmd_ban") then
		if toPlayer and ... and jednostka and czas and tonumber(czas) then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				if getElementData(toPlayer, "user:admin") and getElementData(toPlayer, "user:admin") > getElementData(player, "user:admin") then
					exports.px_noti:noti("Nie posiadasz takich uprawnień.", player)
					return
				end

				local reason = table.concat({...}, " ")

				addLogs("admins", "ban", player, "cmd", toPlayer)

				exports.px_discord:sendDiscordLogs("/ban "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "admincmd", player)
				exports.px_discord:sendDiscordLogs("/ban "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "ban", player)
				
				addBanPlayer(toPlayer, jednostka, czas, reason, getPlayerName(player), getElementData(player,"user:uid"))
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /b <id/nick> <jednostka> <czas> <powód>", player)
		end
	end
end)

addCommandHandler("unb", function(player, _, serial)
	if isPlayerHavePerm(player, "cmd_unban") then
		if(serial)then
			local q = exports.px_connect:query("select * from misc_punish where serial=? and type=?", serial, "ban")
			if(q and #q > 0)then
				exports.px_noti:noti("Odbanowałeś gracza "..q[1].nick.." ("..serial..")", player)
				exports.px_connect:query("delete from misc_punish where serial=? and type=?", serial, "ban")

				addLogs("admins", "unban", player, "cmd", toPlayer)

				exports.px_discord:sendDiscordLogs("/unb "..serial, "admincmd", player)
				exports.px_discord:sendDiscordLogs("/unb "..serial, "ban", player)
			else
				exports.px_noti:noti("Podany gracz nie ma bana.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /unb <serial>", player)
		end
	end
end)

--

-- mute
addCommandHandler("m", function(player, _, toPlayer, jednostka, czas, ...)
	if isPlayerHavePerm(player, "cmd_mute") then
		if toPlayer and jednostka and czas and tonumber(czas) and ... then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				if getElementData(toPlayer, "user:admin") and getElementData(toPlayer, "user:admin") > getElementData(player, "user:admin") then
					exports.px_noti:noti("Nie posiadasz takich uprawnień.", player)
					return
				end

				local reason = table.concat({...}, " ")

				if jednostka == "m" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? minute,?,1,?,?)", "mute", getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				elseif jednostka == "h" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? hour,?,1,?,?)", "mute" ,getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				elseif jednostka == "d" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? day,?,1,?,?)", "mute", getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				else
					return
				end

				outputChatBox("-------------------------------------------", toPlayer, 255, 0, 0)
				outputChatBox("Zostałeś wyciszony!", toPlayer, 255, 0, 0)
				outputChatBox("Osoba wyciszająca: "..getPlayerName(player), toPlayer, 255, 0, 0)
				outputChatBox("Powód wyciszenia: "..reason, toPlayer, 255, 0, 0)
				outputChatBox("Czas wyciszenia: "..czas..jednostka, toPlayer, 255, 0, 0)
				outputChatBox("----------------------------------------", toPlayer, 255, 0, 0)

				setElementData(toPlayer, "user:mute", true)

				triggerClientEvent(root, "addAdminNotification", resourceRoot, getPlayerName(toPlayer).." został wyciszony przez "..getPlayerName(player).." z powodu "..reason.." ("..czas..jednostka..")")

				addLogs("admins", "mute", player, "cmd", toPlayer)

				exports.px_discord:sendDiscordLogs("/mute "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "admincmd", player)
				exports.px_discord:sendDiscordLogs("/mute "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "mute", player)
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /m <id/nick> <jednostka> <czas> <powód>", player)
		end
	end
end)

addCommandHandler("unm", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_unmute") then
		if(toPlayer)then
			toPlayer=exports.px_core:findPlayer(toPlayer)
			if(toPlayer)then
				local q = exports.px_connect:query("select * from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "mute")
				if(q and #q > 0)then
					exports.px_noti:noti("Odciszyłeś gracza "..getPlayerName(toPlayer)..".", player)
					exports.px_connect:query("delete from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "mute")
					setElementData(toPlayer, "user:mute", false)

					addLogs("admins", "unmute", player, "cmd", toPlayer)

					exports.px_discord:sendDiscordLogs("/unm "..getPlayerName(toPlayer), "admincmd", player)
					exports.px_discord:sendDiscordLogs("/unm "..getPlayerName(toPlayer), "mute", player)
				else
					exports.px_noti:noti("Podany gracz nie jest wyciszony.", player)
				end
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /unm <id/nick>", player)
		end
	end
end)
--


-- voice mute
addCommandHandler("vm", function(player, _, toPlayer, jednostka, czas, ...)
	if isPlayerHavePerm(player, "cmd_voicemute") then
		if toPlayer and jednostka and czas and tonumber(czas) and ... then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				if getElementData(toPlayer, "user:admin") and getElementData(toPlayer, "user:admin") > getElementData(player, "user:admin") then
					exports.px_noti:noti("Nie posiadasz takich uprawnień.", player)
					return
				end

				local reason = table.concat({...}, " ")

				if jednostka == "m" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? minute,?,1,?,?)", "voice_mute", getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				elseif jednostka == "h" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? hour,?,1,?,?)", "voice_mute" ,getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				elseif jednostka == "d" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? day,?,1,?,?)", "voice_mute", getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				else
					return
				end

				outputChatBox("-------------------------------------------", toPlayer, 255, 0, 0)
				outputChatBox("Zostałeś wyciszony na chacie głosowym!", toPlayer, 255, 0, 0)
				outputChatBox("Osoba wyciszająca: "..getPlayerName(player), toPlayer, 255, 0, 0)
				outputChatBox("Powód wyciszenia: "..reason, toPlayer, 255, 0, 0)
				outputChatBox("Czas wyciszenia: "..czas..jednostka, toPlayer, 255, 0, 0)
				outputChatBox("----------------------------------------", toPlayer, 255, 0, 0)

				setElementData(toPlayer, "user:voice_mute", true)

				triggerClientEvent(root, "addAdminNotification", resourceRoot, getPlayerName(toPlayer).." został wyciszony na chacie głosowym przez "..getPlayerName(player).." z powodu "..reason.." ("..czas..jednostka..")")

				addLogs("admins", "voice_mute", player, "cmd", toPlayer)

				exports.px_discord:sendDiscordLogs("/voicemute "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "admincmd", player)
				exports.px_discord:sendDiscordLogs("/voicemute "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "mute", player)
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /vm <id/nick> <jednostka> <czas> <powód>", player)
		end
	end
end)

addCommandHandler("unmv", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_unvoicemute") then
		if(toPlayer)then
			toPlayer=exports.px_core:findPlayer(toPlayer)
			if(toPlayer)then
				local q = exports.px_connect:query("select * from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "voice_mute")
				if(q and #q > 0)then
					exports.px_noti:noti("Odciszyłeś gracza "..getPlayerName(toPlayer).." na chacie głosowym.", player)
					exports.px_connect:query("delete from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "voice_mute")
					setElementData(toPlayer, "user:voice_mute", false)

					addLogs("admins", "voice_unmute", player, "cmd", toPlayer)

					exports.px_discord:sendDiscordLogs("/unmw "..getPlayerName(toPlayer), "admincmd", player)
					exports.px_discord:sendDiscordLogs("/unmw "..getPlayerName(toPlayer), "mute", player)
				else
					exports.px_noti:noti("Podany gracz nie jest wyciszony.", player)
				end
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /unmv <id/nick>", player)
		end
	end
end)
--

-- prawka
addCommandHandler("zpj", function(player, _, toPlayer, jednostka, czas, ...)
	if isPlayerHavePerm(player, "cmd_zpj") then
		if toPlayer and jednostka and czas and tonumber(czas) and ... then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				if getElementData(toPlayer, "user:admin") and getElementData(toPlayer, "user:admin") > getElementData(player, "user:admin") then
					exports.px_noti:noti("Nie posiadasz takich uprawnień.", player)
					return
				end

				local reason = table.concat({...}, " ")

				if jednostka == "m" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? minute,?,1,?,?)", "pj", getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				elseif jednostka == "h" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? hour,?,1,?,?)", "pj" ,getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				elseif jednostka == "d" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? day,?,1,?,?)", "pj", getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				else
					return
				end

				addLogs("admins", "zabierz-prawo-jazdy", player, "cmd", toPlayer)

				if(isPedInVehicle(toPlayer))then
					removePedFromVehicle(toPlayer)
				end

				local q = exports.px_connect:query("select * from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "pj")
				if(q and #q > 0)then
					setElementData(toPlayer, "user:license_take", q[1])
				end

				triggerClientEvent(root, "addAdminNotification", resourceRoot, getPlayerName(toPlayer).." otrzymał zakaz prowadzenia pojazdów kat. A,B,C od "..getPlayerName(player).." z powodu "..reason.." ("..czas..jednostka..")")
				
				exports.px_discord:sendDiscordLogs("/zpj "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "admincmd", player)
				exports.px_discord:sendDiscordLogs("/zpj "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "prawojazdy", player)
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /zpj <id/nick> <jednostka> <czas> <powód>", player)
		end
	end
end)

addCommandHandler("zl", function(player, _, toPlayer, jednostka, czas, ...)
	if isPlayerHavePerm(player, "cmd_zpj") then
		if toPlayer and jednostka and czas and tonumber(czas) and ... then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				if getElementData(toPlayer, "user:admin") and getElementData(toPlayer, "user:admin") > getElementData(player, "user:admin") then
					exports.px_noti:noti("Nie posiadasz takich uprawnień.", player)
					return
				end

				local reason = table.concat({...}, " ")

				if jednostka == "m" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? minute,?,1,?,?)", "l", getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				elseif jednostka == "h" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? hour,?,1,?,?)", "l" ,getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				elseif jednostka == "d" then
					exports.px_connect:query("insert into misc_punish (type,nick,serial,ip,admin,first_date,date,reason,active,uid_player,uid_admin) values(?,?,?,?,?,now(),now()+interval ? day,?,1,?,?)", "l", getPlayerName(toPlayer), getPlayerSerial(toPlayer), getPlayerIP(toPlayer), getPlayerName(player), czas, reason, getElementData(toPlayer, "user:uid") or 0, getElementData(player, "user:uid") or 0)
				else
					return
				end

				addLogs("admins", "zabierz-licencje", player, "cmd", toPlayer)

				if(isPedInVehicle(toPlayer))then
					removePedFromVehicle(toPlayer)
				end

				local q = exports.px_connect:query("select * from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "l")
				if(q and #q > 0)then
					setElementData(toPlayer, "user:license_l_take", q[1])
				end

				triggerClientEvent(root, "addAdminNotification", resourceRoot, getPlayerName(toPlayer).." otrzymał zawieszenie licencji lotniczych od "..getPlayerName(player).." z powodu "..reason.." ("..czas..jednostka..")")
				
				exports.px_discord:sendDiscordLogs("/zl "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "admincmd", player)
				exports.px_discord:sendDiscordLogs("/zl "..getPlayerName(toPlayer)..", powód: "..reason..", czas: "..czas..jednostka, "prawojazdy", player)
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /zl <id/nick> <jednostka> <czas> <powód>", player)
		end
	end
end)

addCommandHandler("opj", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_opj") then
		if(toPlayer)then
			toPlayer=exports.px_core:findPlayer(toPlayer)
			if(toPlayer)then
				local q = exports.px_connect:query("select * from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "pj")
				if(q and #q > 0)then
					exports.px_noti:noti("Oddałeś prawo jazdy graczu "..getPlayerName(toPlayer)..".", player)
					exports.px_connect:query("delete from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "pj")
					setElementData(toPlayer, "user:license_take", false)

					addLogs("admins", "oddaj-prawo-jazdy", player, "cmd", toPlayer)

					exports.px_discord:sendDiscordLogs("/opj "..getPlayerName(toPlayer), "admincmd", player)
					exports.px_discord:sendDiscordLogs("/opj "..getPlayerName(toPlayer), "prawojazdy", player)
				else
					exports.px_noti:noti("Podany gracz nie ma zabranego prawa jazdy.", player)
				end
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /opj <id/nick>", player)
		end
	end
end)

addCommandHandler("opl", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_opj") then
		if(toPlayer)then
			toPlayer=exports.px_core:findPlayer(toPlayer)
			if(toPlayer)then
				local q = exports.px_connect:query("select * from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "l")
				if(q and #q > 0)then
					exports.px_noti:noti("Oddałeś licencje lotnicze graczu "..getPlayerName(toPlayer)..".", player)
					exports.px_connect:query("delete from misc_punish where serial=? and type=?", getPlayerSerial(toPlayer), "l")
					setElementData(toPlayer, "user:license_l_take", false)

					addLogs("admins", "oddaj-licencje-lotnicze", player, "cmd", toPlayer)

					exports.px_discord:sendDiscordLogs("/opl "..getPlayerName(toPlayer), "admincmd", player)
					exports.px_discord:sendDiscordLogs("/opl "..getPlayerName(toPlayer), "prawojazdy", player)
				else
					exports.px_noti:noti("Podany gracz nie ma zabranego prawa jazdy.", player)
				end
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /opl <id/nick>", player)
		end
	end
end)

addCommandHandler("nadajprawko", function(player, _, toPlayer)
	if getElementData(player, "user:admin") == 5 then
		if(toPlayer)then
			toPlayer=exports.px_core:findPlayer(toPlayer)
			if(toPlayer)then
				local uid=getElementData(toPlayer, "user:uid")
				if(not uid)then return end

				local lic={
					a=2,
					b=2,
					c=2,
					["c+e"]=2,
					l=2,
					l1=2,
					l2=2,
					['broń palna']=1
				}

				setElementData(toPlayer, "user:licenses", lic)
				exports.px_connect:query("update accounts set licenses=? where id=?", toJSON(lic), uid)

				exports.px_noti:noti("Nadałeś wszystkie prawa jazdy dla gracza "..getPlayerName(toPlayer)..".", player)
				addLogs("admins", "nadaj-prawko", player, "cmd", toPlayer)

				exports.px_discord:sendDiscordLogs("/nadajprawko "..getPlayerName(toPlayer), "admincmd", player)
				exports.px_discord:sendDiscordLogs("/nadajprawko "..getPlayerName(toPlayer), "prawojazdy", player)
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /nadajprawko <id/nick>", player)
		end
	end
end)
--

local vehs={}
addCommandHandler("cv", function(player, _, model)
	if getElementData(player, "user:admin") then
		if(getElementDimension(player) ~= 0 or isPlayerHavePerm(player, "cmd_cv"))then
			if model then
				if not tonumber(model) then
					model = getVehicleModelFromName(model)
				end

				model = model or 0

				if model == 0 then
					exports.px_noti:noti("Nie znaleziono podanego pojazdu.", player)
					return
				end

				local x,y,z = getElementPosition(player)
				local dim, int = getElementDimension(player), getElementInterior(player)

				vehs[player] = createVehicle(model, x, y, z)
				if(vehs[player] and isElement(vehs[player]))then
					setElementData(vehs[player], "admin:vehicle", player)
					setElementInterior(vehs[player], int)
					setElementDimension(vehs[player], dim)
					warpPedIntoVehicle(player, vehs[player])

					exports.px_discord:sendDiscordLogs("/cv "..getVehicleName(vehs[player]), "admincmd", player)
				else
					exports.px_noti:noti("Nie znaleziono podanego pojazdu.", player)
				end
			else
				exports.px_noti:noti("Poprawne użycie: /cv <model/id>", player)
			end
		end
	end
end)

addEventHandler("onVehicleEnter", resourceRoot, function(player,seat)
	if not getElementData(player, "user:admin") and getElementData(source, "admin:vehicle") and seat == 0 and getElementDimension(player) == 0 and getElementInterior(source) == 0 then
		local p=getElementData(source, "admin:vehicle")
		destroyElement(source)
		vehs[p]=nil
	end
end)

addEventHandler("onPlayerQuit", root, function()
	if(vehs[source] and isElement(vehs[source]))then
		destroyElement(vehs[source])
		vehs[source]=nil
	end
end)
--

addCommandHandler("jp", function(player)
	if isPlayerHavePerm(player, "cmd_jp") then
   		if not isPedWearingJetpack(player) then
    		givePedJetPack(player)
			exports.px_discord:sendDiscordLogs("/jp", "admincmd", player)
   		else
    		removePedJetPack(player)
			exports.px_discord:sendDiscordLogs("/jp", "admincmd", player)
   		end
	end
end)

local maxSpec={}

addCommandHandler("spec", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_spec") then
		if(isPedInVehicle(player))then
			exports.px_noti:noti("Nie możesz obserwować gracza gdy znajdujesz się w pojeździe.", player, "error")
			return
		end

		local spec=getElementData(player, "admin:spec")
		if(spec)then
			removePedJetPack(player)
			
			setCameraTarget(player, player)
			setElementFrozen(player, false)
			setElementAlpha(player, 255)
			detachElements(player)
			setElementCollisionsEnabled(player, true)
			setElementPosition(player, spec[1], spec[2], spec[3])

			setElementData(player, "user:inv", false)
			setElementData(player, "admin:spec", false, false)

			exports.px_discord:sendDiscordLogs("/unspec", "admincmd", player)
			return
		end

		if toPlayer then
			toPlayer = exports.px_core:findPlayer(toPlayer)

			if toPlayer then
				if(maxSpec[player])then
					exports.px_noti:noti("Nie możesz obserwować aż tyle graczy! Zaczekaj do minuty.", player, "error")
					return
				end

				setElementFrozen(player, true)
				setCameraTarget(player, toPlayer)
				setElementAlpha(player, 0)
				setElementData(player, "user:inv", true)
				setElementData(player, "admin:spec", {getElementPosition(player)}, false)

				attachElements(player, toPlayer, 0, 0, -1)

				exports.px_discord:sendDiscordLogs("/spec "..getPlayerName(toPlayer), "admincmd", player)

				setElementCollisionsEnabled(player, false)

				maxSpec[player]=setTimer(function()
					if(maxSpec[player])then
						maxSpec[player]=nil
	
						if(player and isElement(player))then
							local spec=getElementData(player, "admin:spec")
							if(spec)then
								removePedJetPack(player)
				
								setCameraTarget(player, player)
								setElementFrozen(player, false)
								setElementAlpha(player, 255)
								detachElements(player)
								setElementCollisionsEnabled(player, true)
								setElementPosition(player, spec[1], spec[2], spec[3])
					
								setElementData(player, "user:inv", false)
								setElementData(player, "admin:spec", false, false)
					
								exports.px_discord:sendDiscordLogs("/unspec", "admincmd", player)
							end
						end
					end
				end, (1000*60)*1, 1)
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /spec <id/nick>", player)
		end
	end
end)

addEventHandler("onPlayerQuit", root, function()
	if(maxSpec[source])then
		maxSpec[source]=nil
	end
end)

addCommandHandler("heal", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_heal") then
		if toPlayer then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				setElementHealth(toPlayer, 100)
				exports.px_noti:noti("Pomyślnie uleczono gracza "..getPlayerName(toPlayer), player)
				setElementData(toPlayer, "user:bw", false)

				exports.px_discord:sendDiscordLogs("/heal "..getPlayerName(toPlayer), "admincmd", player)
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			setElementHealth(player, 100)
			setElementData(player, "user:bw", false)
			exports.px_noti:noti("Pomyślnie zostałeś uleczony.", player)
			exports.px_discord:sendDiscordLogs("/heal", "admincmd", player)
		end
	end
end)

addCommandHandler("tt", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_tt") then
		if toPlayer then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				if isPedInVehicle(toPlayer) then
					local v=getPedOccupiedVehicle(toPlayer)
					local tp=false
					for i=1,4 do
						local occupied=getVehicleOccupant(v, i)
						if(not occupied)then
							local warp=warpPedIntoVehicle(player, v, i)
							exports.px_discord:sendDiscordLogs("/tt "..getPlayerName(toPlayer), "admincmd", player)
							if(warp)then tp=true end
						end
					end

					if(not tp)then
						local x,y,z = getElementPosition(toPlayer)
						setElementPosition(player, x, y+1, z)
						setElementDimension(player, getElementDimension(toPlayer))
						setElementInterior(player, getElementInterior(toPlayer))
						exports.px_discord:sendDiscordLogs("/tt "..getPlayerName(toPlayer), "admincmd", player)
					end
				elseif isPedInVehicle(player) then
					removePedFromVehicle(player)
				else
					local x,y,z = getElementPosition(toPlayer)
					setElementPosition(player, x, y+1, z)
					setElementDimension(player, getElementDimension(toPlayer))
					setElementInterior(player, getElementInterior(toPlayer))
					exports.px_discord:sendDiscordLogs("/tt "..getPlayerName(toPlayer), "admincmd", player)
				end
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /tt <id/nick>", player)
		end
	end
end)

addCommandHandler("th", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_th") then
		if toPlayer then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				if isPedInVehicle(player) then
					warpPedIntoVehicle(toPlayer, getPedOccupiedVehicle(player), 1)
				elseif isPedInVehicle(toPlayer) then
					removePedFromVehicle(toPlayer)
					local x,y,z = getElementPosition(player)
					setElementPosition(toPlayer, x, y+1, z)
				else
					local x,y,z = getElementPosition(player)
					setElementPosition(toPlayer, x, y+1, z)
				end

				setElementDimension(toPlayer, getElementDimension(player))
				setElementInterior(toPlayer, getElementInterior(player))

				exports.px_discord:sendDiscordLogs("/th "..getPlayerName(toPlayer), "admincmd", player)
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /th <id/nick>", player)
		end
	end
end)

-- vehicles
function getVehicleFromID(id)
	local veh=getElementByID("px_vehicles_id:"..id)
	if(veh and isElement(veh) and getElementDimension(veh) == 0)then
		return veh
	end
	return false
end

addCommandHandler("vtt", function(player, _, id)
	if isPlayerHavePerm(player, "cmd_vtt") then
		if id and tonumber(id) then
			local vehicle = getVehicleFromID(tonumber(id))
			if vehicle then
				exports.px_noti:noti("Pomyślnie przeteleportowano do pojazdu o id: "..id, player)
				warpPedIntoVehicle(player, vehicle)

				exports.px_discord:sendDiscordLogs("/vtt "..id, "admincmd", player)
			else
				exports.px_noti:noti("Podany pojazd nie istnieje lub jest w przechowalni/garażu.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /vtt <id>", player)
		end
	end
end)

addCommandHandler("vth", function(player, _, id)
	if isPlayerHavePerm(player, "cmd_vth") then
		vehs=exports.px_vehicles
		db=exports.px_connect
		noti=exports.px_noti

		if id and tonumber(id) then
			local vehicle = getVehicleFromID(tonumber(id))
			if(vehicle)then
				exports.px_noti:noti("Pomyślnie przeteleportowano pojazd o id: "..id, player)

				local x,y,z = getElementPosition(player)
				setElementPosition(vehicle, x, y, z)
				setElementPosition(player, x, y, z + 1)

				exports.px_discord:sendDiscordLogs("/vth "..id, "admincmd", player)
			else
				local r=exports.px_connect:query("select * from vehicles where id=? and not parking=0", id)
				if(r and #r > 0)then
					exports.px_connect:query("update vehicles set parking=0 where id=?", id)

					local veh=exports.px_vehicles:createNewVehicle(id)

					if(veh)then
						local x,y,z = getElementPosition(player)
						setElementPosition(veh, x, y, z)
						setElementPosition(player, x, y, z + 1)

						exports.px_discord:sendDiscordLogs("/vth "..id, "admincmd", player)
					else
						exports.px_noti:noti("Wystąpił błąd.", player)
					end
				else
					exports.px_noti:noti("Nie znaleziono podanego pojazdu.", player)
				end
			end
		else
			exports.px_noti:noti("Poprawne użycie: /vth <id>", player)
		end
	end
end)
--

-- vehicles factions
function getVehicleFromID2(id)
	return getElementByID("px_groups_vehicles_id:"..id)
end

addCommandHandler("gvtt", function(player, _, id)
	if isPlayerHavePerm(player, "cmd_gvtt") then
		if id and tonumber(id) then
			local vehicle = getVehicleFromID2(tonumber(id))
			if vehicle then
				exports.px_noti:noti("Pomyślnie przeteleportowano do pojazdu o id: "..id, player)
				warpPedIntoVehicle(player, vehicle)

				exports.px_discord:sendDiscordLogs("/gvtt "..id, "admincmd", player)
			else
				exports.px_noti:noti("Podany pojazd nie istnieje.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /gvtt <id>", player)
		end
	end
end)

addCommandHandler("gvth", function(player, _, id)
	if isPlayerHavePerm(player, "cmd_gvth") then
		vehs=exports.px_vehicles
		db=exports.px_connect
		noti=exports.px_noti

		if id and tonumber(id) then
			local vehicle = getVehicleFromID2(tonumber(id))
			if(vehicle)then
				exports.px_noti:noti("Pomyślnie przeteleportowano pojazd o id: "..id, player)

				local x,y,z = getElementPosition(player)
				setElementPosition(vehicle, x, y, z)
				setElementPosition(player, x, y, z + 1)

				exports.px_discord:sendDiscordLogs("/gvth "..id, "admincmd", player)
			else
				local r=exports.px_connect:query("select * from groups_vehicles where id=? and not parking=0", id)
				if(r and #r > 0)then
					exports.px_connect:query("update groups_vehicles set parking=0 where id=?", id)

					local veh=exports.px_groups_vehicles:createNewVehicle(id)

					if(veh)then
						local x,y,z = getElementPosition(player)
						setElementPosition(veh, x, y, z)
						setElementPosition(player, x, y, z + 1)

						exports.px_discord:sendDiscordLogs("/gvth "..id, "admincmd", player)
					else
						exports.px_noti:noti("Wystąpił błąd.", player)
					end
				else
					exports.px_noti:noti("Nie znaleziono podanego pojazdu.", player)
				end
			end
		else
			exports.px_noti:noti("Poprawne użycie: /gvth <id>", player)
		end
	end
end)
--

addCommandHandler("inv", function(player)
	if isPlayerHavePerm(player, "cmd_inv") then
		if not getElementData(player, "user:inv") then
			setElementAlpha(player, 0)
			setElementData(player, "user:inv", true)
		else
			setElementAlpha(player, 255)
			removeElementData(player, "user:inv")
		end
		exports.px_discord:sendDiscordLogs("/inv", "admincmd", player)
	end
end)

addCommandHandler("fix", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_fix") then
		toPlayer = toPlayer == nil and player or exports.px_core:findPlayer(toPlayer)
		if toPlayer then
			local vehicle = getPedOccupiedVehicle(toPlayer)
			if vehicle then
				fixVehicle(vehicle)

				addLogs("admins", "fix "..getVehicleName(vehicle), player, "cmd", toPlayer)

				if toPlayer == player then
					exports.px_noti:noti("Pomyślnie naprawiono pojazd.", player)
				else
					exports.px_noti:noti("Pomyślnie naprawiono pojazd gracza "..getPlayerName(toPlayer), player)
				end

				exports.px_discord:sendDiscordLogs("/fix "..getPlayerName(toPlayer), "admincmd", player)
			else
				if toPlayer == player then
					exports.px_noti:noti("Nie znajdujesz się w pojeździe.", player)
				else
					exports.px_noti:noti("Podany gracz nie znajduje się w pojeździe.", player)
				end
			end
		end
	end
end)

addCommandHandler("flip", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_flip") then
		toPlayer = toPlayer == nil and player or exports.px_core:findPlayer(toPlayer)
		if toPlayer then
			local vehicle = getPedOccupiedVehicle(toPlayer)
			if vehicle then
				local rx,ry,rz = getElementRotation(vehicle)
				setVehicleRotation(vehicle, 0, 0, rz)

				addLogs("admins", "flip "..getVehicleName(vehicle), player, "cmd", toPlayer)

				if toPlayer == player then
					exports.px_noti:noti("Pomyślnie postawiono na koła pojazd.", player)
				else
					exports.px_noti:noti("Pomyślnie postawiono na koła pojazd gracza "..getPlayerName(toPlayer), player)
				end

				exports.px_discord:sendDiscordLogs("/flip "..getPlayerName(toPlayer), "admincmd", player)
			else
				if toPlayer == player then
					exports.px_noti:noti("Nie znajdujesz się w pojeździe.", player)
				else
					exports.px_noti:noti("Podany gracz nie znajduje się w pojeździe.", player)
				end
			end
		end
	end
end)

addCommandHandler("unfreeze", function(player, _, toPlayer)
	if getElementData(player, "user:admin") then
		toPlayer = toPlayer == nil and player or exports.px_core:findPlayer(toPlayer)
		if toPlayer then
			setElementFrozen(toPlayer, false)
			exports.px_noti:noti("Pomyślnie odmrożono gracza "..getPlayerName(toPlayer), player, "success")
		end
	end
end)

addCommandHandler("reporty", function(player)
	if isPlayerHavePerm(player, "cmd_reporty") then
		setElementData(player, "user:admin_reports", not getElementData(player, "user:admin_reports"))
	end
end)

addCommandHandler("logi", function(player)
	if isPlayerHavePerm(player, "cmd_logi") then
		setElementData(player, "user:admin_logs", not getElementData(player, "user:admin_logs"))
	end
end)

function report(player, _, toPlayer, ...)
	if toPlayer and ... then
		toPlayer = exports.px_core:findPlayer(toPlayer)
		if toPlayer then
			if(not getElementData(player, "user:haveReport"))then
				local rps = getElementData(toPlayer, "user:haveReport") or 0
				local reason = table.concat({...}, " ")
				triggerClientEvent(root, "addReport", resourceRoot, getPlayerName(player).." ["..getElementData(player, "user:id").."] > "..getPlayerName(toPlayer).." ["..getElementData(toPlayer, "user:id").."]: "..reason, toPlayer, player)
				exports.px_noti:noti("Pomyślnie wysłano zgłoszenie na gracza "..getPlayerName(toPlayer), player)
				setElementData(toPlayer, "user:haveReport", (rps + 1))
			else
				exports.px_noti:noti("Najpierw poczekaj na rozpatrzenie reporta.", player)
			end
		else
			exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
		end
	else
		exports.px_noti:noti("Poprawne użycie: /report <id/nick> <powód>", player)
	end
end
addCommandHandler("report", report)
addCommandHandler("raport", report)

addCommandHandler("cl", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_cl") then
		if toPlayer then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				local rps = getElementData(toPlayer, "user:haveReport")
				if(rps)then
					local data = rps-1
					if(data <= 0)then
						data = false
					end

					setElementData(toPlayer, "user:haveReport", data)

					triggerClientEvent(root, "removeReport", resourceRoot, toPlayer, player, "cl")
					exports.px_noti:noti("Pomyślnie wzięto report na gracza "..getPlayerName(toPlayer), player)

					if(toPlayer ~= player)then
						addPlayerReport(player)
					end

					exports.px_discord:sendDiscordLogs("/cl "..getPlayerName(toPlayer), "admincmd", player)
				end
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /cl <id/nick>", player)
		end
	end
end)

addCommandHandler("xcl", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_xcl") then
		if toPlayer then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				local rps = getElementData(toPlayer, "user:haveReport")
				if(rps)then
					local data = rps-1
					if(data <= 0)then
						data = false
					end

					setElementData(toPlayer, "user:haveReport", data)

					triggerClientEvent(root, "removeReport", resourceRoot, toPlayer, player, "xcl")
					exports.px_noti:noti("Pomyślnie usunięto report na gracza "..getPlayerName(toPlayer), player)

					exports.px_discord:sendDiscordLogs("/xcl "..getPlayerName(toPlayer), "admincmd", player)
				end
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /xcl <id/nick>", player)
		end
	end
end)

-- walizki

local case=false

addCommandHandler("walizka", function(player, _, ...)
	if(isPlayerHavePerm(player, "cmd_walizka"))then
		if(not case)then
			local text=... and table.concat({...}, " ") or "brak"

			local x,y,z=getElementPosition(player)
			setElementPosition(player, x+3, y, z)

			case=createPickup(x,y,z,3,1210)

			outputChatBox("#ff0000"..getPlayerName(player).." zgubił walizkę pełną pieniędzy. Podpowiedź: "..text, root, 255, 0, 0, true)
		else
			exports.px_noti:noti("Na mapie jest już walizka.", player, "error")
		end
	end
end)

addEventHandler("onPickupHit", resourceRoot, function(hit)
	if(hit and isElement(hit) and getElementType(hit) == "player" and not isPedInVehicle(hit) and source == case)then
		local money=math.random(200,700)
		givePlayerMoney(hit, money)

		outputChatBox("#ff0000"..getPlayerName(hit).." odnalazł walizke a w niej $"..money, root, 255, 0, 0, true)

		destroyElement(case)
		case=false
	end
end)

-- klatki

local klatka={}
addCommandHandler("klatka", function(player, _, size)
	if isPlayerHavePerm(player, "cmd_klatka") then
		if(klatka[player])then
			for i,v in pairs(klatka[player]) do
				if(isElement(v))then
					destroyElement(v)
				end
			end

			klatka[player]=nil
		else
			if(size and not tonumber(size))then return end

			local x,y,z = getElementPosition(player)

			local sx=size or 4.2
			sx=tonumber(sx) or 4.2

			if(sx > 5)then
				sx=5
			end
			if(sx < 1)then
				sx=1
			end

			klatka[player]={
				createObject(971, x, y, z-1, 90, 0, 0),
				createObject(971, x, y, z + sx, 90, 0, 0),
				createObject(971, x, y+ sx, z+sx/2, 0, 0, 180),
				createObject(971, x, y- sx, z+sx/2, 0, 0, 180),
				createObject(971, x+sx, y, z+sx/2, 0, 0, 90),
				createObject(971, x- sx, y, z+sx/2, 0, 0, 90),
			}
			for i,v in pairs(klatka[player]) do
				setElementInterior(v, getElementInterior(player))
				setElementDimension(v, getElementDimension(player))
			end
		end
	end
end)

-- wlasne teleporty

local teleports={}

addCommandHandler("tpev", function(player, _, nick)
	if(nick)then
		local p=getPlayerFromName(nick)
		if(p and isElement(p) and teleports[p] and not isPedInVehicle(player))then
			exports.px_noti:noti('Pomyślnie zostałeś teleportowany.', player, 'success')

			setElementPosition(player, unpack(teleports[p].pos))
			setElementDimension(player, teleports[p].dim)
			setElementInterior(player, teleports[p].int)
		else
			exports.px_noti:noti('Podany teleport nie istnieje.', player, 'error')
		end
	else
		if isPlayerHavePerm(player, "cmd_tpev") then
			if(teleports[player])then
				teleports[player]=nil

				exports.px_noti:noti('Pomyślnie usunięto teleport.', player, 'success')
			else
				teleports[player]={
					pos={getElementPosition(player)},
					dim=getElementDimension(player),
					int=getElementInterior(player)
				}

				exports.px_noti:noti('Pomyślnie stworzono teleport.', player, 'success')
			end
		end
	end
end)

addEventHandler('onPlayerQuit', root, function()
	if(teleports[source])then
		teleports[source]=nil
	end
end)

-- dp

addCommandHandler("dp", function(player, _, id)
	if isPlayerHavePerm(player, "cmd_dp") then
		if id then
			local veh=getElementByID("px_vehicles_id:"..tonumber(id))
			if(veh and isElement(veh))then
				local owner=getElementData(veh, 'vehicle:owner')
				if(not owner)then
					exports.px_noti:noti('Podany pojazd nie ma właściciela.', player, 'error')
					return
				end

				local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", owner)
				if(parking_id and #parking_id == 1)then
					exports.px_noti:noti('Pomyślnie wysłano pojazd '..id..' ('..getVehicleName(veh)..') na parking.', player, 'success')

					exports.px_vehicles:saveVehicle(veh,'destroy')

					exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, id)
				else
					exports.px_connect:query("INSERT INTO vehicles_garages SET playerID=?", owner)

					local parking_id=db:query("select id from vehicles_garages where playerID=? limit 1", owner)
					if(parking_id and #parking_id == 1)then
						exports.px_noti:noti('Pomyślnie wysłano pojazd '..id..' ('..getVehicleName(veh)..') na parking.', player, 'success')

						exports.px_vehicles:saveVehicle(veh,'destroy')
	
						exports.px_connect:query("update vehicles set parking=?,position=NULL,h_garage=0 where id=?", parking_id[1].id, id)
					end
				end
			else
				exports.px_noti:noti('Podany pojazd nie jest na mapie.', player, 'error')
			end
		else
			exports.px_noti:noti("Poprawne użycie: /dp <id>", player)
		end
	end
end)

-- vinfo

function getVehicleType(model,id)
    local q=exports.px_connect:query("select id,model from vehicles where model=? and id<=? order by id desc", model, id)
    return #q
end

addCommandHandler("vinfo", function(player, _, id)
	if isPlayerHavePerm(player, "cmd_vinfo") then
		if id then
			local q=exports.px_connect:query("select * from vehicles where id=?", id)
			if(q)then
				for i,v in pairs(q) do
					v.po_id=getVehicleType(v.model,v.id)
					v.police=exports.px_connect:query('select id from vehicles_policeParking where id=? limit 1', v.id)
					if(not v.police or (v.police and #v.police == 0))then v.police=nil end
				end

				triggerClientEvent(player, "vinfo.open", resourceRoot, q[1])

				exports.px_discord:sendDiscordLogs("/vinfo "..id, "admincmd", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /vinfo <id>", player)
		end
	end
end)

-- reports

addEventHandler("onPlayerQuit", root, function()
	if(getElementData(source, "user:haveReport"))then
		triggerClientEvent(root, "removeReport", resourceRoot, source, source)
	end
end)

-- whitelise

addCommandHandler("addmod", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_addmod") then
		if(toPlayer)then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if(toPlayer)then
				local uid=getElementData(toPlayer, "user:uid")
				if(not uid)then return end

				local serial=getPlayerSerial(toPlayer)
				local nick=getPlayerName(toPlayer)
				
				exports.px_connect:query("INSERT INTO admins (nick, serial, uid, `rank`) VALUES (?,?,?,?)", nick, serial, uid, 2)
				exports.px_noti:noti("Dodano gracza "..nick.." (SERIAL: "..serial..")", player)

				exports.px_discord:sendDiscordLogs("/addmod "..serial..", "..nick, "admincmd", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /addmod <nick>", player)
		end
	end
end)

addCommandHandler("addtestmod", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_addmod") then
		if(toPlayer)then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if(toPlayer)then
				local uid=getElementData(toPlayer, "user:uid")
				if(not uid)then return end

				local serial=getPlayerSerial(toPlayer)
				local nick=getPlayerName(toPlayer)
				
				exports.px_connect:query("INSERT INTO admins (nick, serial, uid, `rank`) VALUES (?,?,?,?)", nick, serial, uid, 1)
				exports.px_noti:noti("Dodano gracza "..nick.." (SERIAL: "..serial..")", player)

				exports.px_discord:sendDiscordLogs("/addtestmod "..serial..", "..nick, "admincmd", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /addtestmod <nick>", player)
		end
	end
end)


-- pinfo

addCommandHandler("pinfo", function(player, _, toPlayer)
	if isPlayerHavePerm(player, "cmd_pinfo") then
		if toPlayer then
			toPlayer = exports.px_core:findPlayer(toPlayer)
			if toPlayer then
				local uid=getElementData(toPlayer, "user:uid")
				if(not uid)then return end

				local db=exports.px_connect
				local q=db:query("select * from accounts where id=? limit 1", uid)
				if(q)then
					local houses=db:query("select * from houses where owner=?", uid)
					local vehicles=db:query("select * from vehicles where owner=?", uid)
					local mute=db:query("select * from misc_punish where type=? and active=1 and nick=? limit 1", "mute", getPlayerName(toPlayer))
					local pj=db:query("select * from misc_punish where type=? and active=1 and nick=? limit 1", "pj", getPlayerName(toPlayer))
					local groups_vehicles=db:query("select * from groups_vehicles where owner=?", uid)
					triggerClientEvent(player, "pinfo.open", resourceRoot, toPlayer, q[1], vehicles, mute, pj, houses, getPlayerSerial(toPlayer), groups_vehicles, getPlayerMoney(toPlayer))

					exports.px_discord:sendDiscordLogs("/pinfo "..getPlayerName(toPlayer), "admincmd", player)
				end
			else
				exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
			end
		else
			exports.px_noti:noti("Poprawne użycie: /pinfo <id/nick>", player)
		end
	end
end)

-- tp

local tp={
    ["przecho"]={2398.4136,1480.2294,10.8203}, 
    ["lotnisko"]={1678.1252,1448.1488,10.6328}, 
    ["mechlv"]={1057.5294,1802.3861,10.8203}, 
    ["gielda"]={2822.3787,1313.2350,10.7611}, 
    ["prawko"]={1170.4904,1369.3302,10.8125}, 
    ["przebieralnia"]={2104.7881,2254.1658,11.0300}, 
    ["spawnlv"]={1668.4784,2025.5244,10.8203}, 
    ["rafineria"]={246.1767,1398.3888,10.5859}, 
    ["tiry"]={-166.5249,-330.3372,1.4297}, 
    ["smieciarki"]={-1844.5614,145.6743,15.1172}, 
    ["magazyn"]={1606.8523,1000.5295,10.8203}, 
    ["spawnsf"]={-2333.1570,209.1245,35.0593}, 
    ["wylawiarka"]={2152.4319,-79.0329,2.9704}, 
    ["fc"]={-132.2035,1212.6622,19.7422},
    ["sara"]={62.6443,-282.9942,1.5781}, 
    ["sapd"]={2342.8132,2454.8770,14.9688}, 
    ["bank"]={2446.2510,2377.1089,12.1641}, 
    ["sacc"]={2491.9746,928.8009,10.8280}, 
    ["bm"]={-2274.2410,2361.8904,5.1203},
    ["derby"]={-3250.5330,1689.8403,6.2208, dim=657}, 
    ["pniaki"]={-1063.4058,-1179.2251,129.2188},
    ["urzadlv"]={948.2778,1722.1963,8.8516},
    ["cyganlv"]={777.6524,1925.8823,5.6831}, 
    ["cyganlb"]={-888.1763,1510.6896,25.9141}, 
    ["psp"]={-2036.3560,-155.1133,35.3203}, 
    ["lotopuszczone"]={406.9191,2535.7517,16.5465}, 
    ["kosiarki"]={1524.3601,15.3418,24.1406},
    ["spawnls"]={1483.9481,-1693.5352,14.0469}, 
    ["ammo"]={241.0132,-178.5099,1.5781},
    ["salon1"]={2806.6975,1978.6776,10.8203},
    ["salon2"]={1941.5087,2070.7244,10.8203},
    ["salon3"]={2199.6116,1387.2014,10.8203},
    ["salon4"]={2745.7544,-1350.7310,44.8298},
    ["wypo"]={2303.9282,1788.0178,10.8203},
    ["kurier"]={2813.1807,964.1826,10.7500},
    ["ap"]={-2237.3213,-2462.5669,30.6283},
    ["apartamenty"]={2608.9106,756.2648,10.8906},
    ["mc"]={-2303.4062,-1629.1381,483.7382},
}

addCommandHandler("tp", function(player, _, name)
	if(isPlayerHavePerm(player, "cmd_teleports"))then
		if(name and tp[name])then
			local pos=tp[name]
			removePedFromVehicle(player)
			setElementInterior(player,0)
			setElementDimension(player,pos.dim or 0)
			setElementPosition(player, unpack(pos))
		else
			local text=""
			for i,v in pairs(tp) do
				text=#text > 0 and text..", "..i or i
			end

			exports.px_noti:noti("Poprawne użycie: /tp <nazwa>", player, "info")
			exports.px_noti:noti(text, player, "info")
		end
	end
end)

-- useful

function getAdmins()
	local q = exports.px_connect:query("select * from admins")
	local admins = {}
	local block={}
	for i,v in pairs(q) do
		if getPlayerFromName(v["nick"]) and not block[v.nick] then
			table.insert(admins, getPlayerFromName(v["nick"]))
			block[v.nick]=true
		end
	end
	block=nil
	return admins
end

function addLogsDuty(text)
	if #logs > 9 then
		table.remove(logs, 1)
	end

	table.insert(logs, text)
	triggerClientEvent(root, "updateLogs", resourceRoot, logs)
end

local log = {
	transfer = {},
	chat = {},
	job = {},
	login = {},
	admins = {},
	vehicles = {},
	business = {},
	tuning={}
}

function addLogs(type, text, player, typ, target, name)
	local nick = false
	local serial = false
	local t_name = target or "(?)"

	if(isElement(player))then
		nick = getPlayerName(player)
		serial = getPlayerSerial(player)
	else
		nick = player[1]
		serial = player[2]
	end

	if(target and isElement(target))then
		t_name = getPlayerName(target)
	end

	typ = typ or "(?)"
	text = text or "(?)"
	type = type or "przelew"

	if(type == "przelew")then
		table.insert(log.transfer, {nick, serial, text, typ, t_name})
	elseif(type == "czat")then
		table.insert(log.chat, {nick, serial, text, typ})
	elseif(type == "job")then
		table.insert(log.job, {nick, serial, text, typ})
	elseif(type == "login")then
		table.insert(log.login, {nick, serial, text, typ})
	elseif(type == "admins")then
		table.insert(log.admins, {nick, serial, text, typ, t_name})
	elseif(type == "vehicles")then
		table.insert(log.vehicles, {nick, serial, text, typ, t_name})
	elseif(type == "business")then
		table.insert(log.business, {nick, serial, text, typ, t_name, name})
	elseif(type == "bank")then
		table.insert(log.transfer, {nick, serial, text, typ, t_name, name})
	elseif(type == "tuning")then
		table.insert(log.transfer, {nick, serial, text, typ, t_name, name})
	end
end

function addTuningLogs(player,veh,cost,text)
	if(player and veh and isElement(player) and isElement(veh))then
		local serial=getPlayerSerial(player)
		local vehID=getElementData(veh,"vehicle:id") or getElementData(veh,"vehicle:group_id") or ""
		local owner=getElementData(veh,"vehicle:ownerName") or getElementData(veh,"vehicle:group_ownerName") or ""
		local ownerID=getElementData(veh,"vehicle:owner") or getElementData(veh,"vehicle:group_owner") or 0
		local model=getVehicleName(veh)
		table.insert(log.tuning, {vehID,owner,ownerID,serial,cost,text,model})
	end
end

setTimer(function()
	for i,v in pairs(log) do
		for index,k in pairs(v) do
			if(i == "transfer")then
				exports.px_connect:query("insert into logs_transfer (nick,serial,text,date,type,target,type2) values(?,?,?,now(),?,?,?)", k[1], k[2], k[3], k[4], k[5], k[6] or "")
			elseif(i == "chat")then
				exports.px_connect:query("insert into logs_chat (nick,serial,text,date,type) values(?,?,?,now(),?)", k[1], k[2], k[3], k[4])
			elseif(i == "job")then
				exports.px_connect:query("insert into logs_jobs (nick,serial,text,date,type) values(?,?,?,now(),?)", k[1], k[2], k[3], k[4])
			elseif(i == "login")then
				exports.px_connect:query("insert into logs_login (nick,serial,text,date,type) values(?,?,?,now(),?)", k[1], k[2], k[3], k[4])
			elseif(i == "admins")then
				exports.px_connect:query("insert into logs_admins (nick,serial,text,date,type,target) values(?,?,?,now(),?,?)", k[1], k[2], k[3], k[4], k[5])
			elseif(i == "vehicles")then
				exports.px_connect:query("insert into logs_vehicles (nick,serial,text,date,type,target) values(?,?,?,now(),?,?)", k[1], k[2], k[3], k[4], k[5])
			elseif(i == "business")then
				exports.px_connect:query("insert into logs_business (nick,serial,text,date,type,target,name) values(?,?,?,now(),?,?,?)", k[1], k[2], k[3], k[4], k[5], k[6])
			elseif(i == 'tuning')then
				exports.px_connect:query("insert into logs_tuning (vehID,owner,ownerID,serial,date,cost,text,model) values(?,?,?,?,now(),?,?,?)", k[1], k[2], k[3], k[4], k[5], k[6], k[7])
			end
		end
		log[i]={}
	end
end, 1000, 0)