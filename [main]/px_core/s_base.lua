--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local ranks=exports.px_admin:getRanks()

local cmd={}

function getSpam(source)
	if cmd[source] then
		if((getTickCount()-cmd[source].tick) > 350)then
			cmd[source].value=cmd[source].value-1
			if(cmd[source].value < 1)then
				cmd[source]=nil
			else
				cmd[source].tick=getTickCount()
			end
		else
			cmd[source].value=cmd[source].value+1
			cmd[source].tick=getTickCount()

			if(cmd[source].value >= 10)then
				cancelEvent()
				kickPlayer(source, "ANTY-SPAM")
				return true
			end
		end
	else
		cmd[source]={value=1,tick=getTickCount()}
	end

	return false
end

-- functions

function getHex(admin, el)
	ranks=exports.px_admin:getRanks()
	
	if(ranks and ranks[admin])then
		return ranks[admin].hex
	elseif(getElementData(el, "user:gold"))then
		return "#d5ad4a"
	elseif(getElementData(el, "user:premium"))then
		return "#f1ee92"
	end
	return "#939393"
end

function isPlayerHaveMute(player)
	return getElementData(player, "user:mute")
end

function outputChatWithDistance(player, text, distance)
	local x,y,z = getElementPosition(player)
	local inShape = getElementsWithinRange(x, y, z, distance, "player")
	for i,v in pairs(inShape) do
		if(getElementDimension(player) == getElementDimension(v) and getElementInterior(player) == getElementInterior(v))then
			outputChatBox("#dca2f4* "..getPlayerMaskName(player).." "..text, v, 255, 255, 255, true)
		end
	end
end

-- events

function sendPM(player, toPlayer, text)
	if(exports.px_dashboard:getSettingState(toPlayer, "private_messages"))then
		exports.px_noti:noti("Ten gracz wyłączył prywatne wiadomości.", player)
		return
	end

	text=stripColors(text)
	text=stripSpaces(text)

	outputChatBox("#ffb600[PM] >> "..getPlayerMaskName(toPlayer).." ["..getElementData(toPlayer, "user:id").."]: "..text, player, _, _, _, true)
	outputChatBox("#ffb600[PM] << "..getPlayerMaskName(player).." ["..getElementData(player, "user:id").."]: "..text, toPlayer, _, _, _, true)
	
	local text_log = "PM > ["..getElementData(player, "user:id").."] "..getPlayerMaskName(player).." > ["..getElementData(toPlayer, "user:id").."] "..getPlayerMaskName(toPlayer)..": "..text
	exports.px_admin:addLogsDuty(text_log)

	local _text_log = "> "..getPlayerMaskName(toPlayer)..": "..text
	exports.px_admin:addLogs("czat", _text_log, player, "PM")

	playSoundFrontEnd(toPlayer, 43)
	setElementData(toPlayer, "user:re_message", player)

	if(isPlayerHaveMute(toPlayer))then
		exports.px_noti:noti("Ten gracz jest wyciszony i nie uzyskasz odpowiedzi.", player)
		return
	end
end

function privateMessage(player, _, toPlayer, ...)	
	if(not getElementData(player, "user:uid") or getElementData(player, "user:bw"))then return end

	if(isPlayerHaveMute(player))then
		exports.px_noti:noti("Jesteś wyciszony i nie możesz korzystać z czatu.", player)
		return
	end

	if(toPlayer and ...)then
		local text = table.concat({...}, " ")
		if getIpInText(text) then return end

		toPlayer = findPlayer(toPlayer)
		if(toPlayer and isElement(toPlayer) and not isPlayerHaveMute(player))then
			if(toPlayer == player)then
				exports.px_noti:noti("Nie możesz pisać sam ze sobą.", player)
			else
				local block=exports.px_interaction:isPlayerBlocked(player, toPlayer)
				if(block)then
					exports.px_noti:noti("Ten gracz został przez Ciebie zablokowany.", player)
				else
					local block=exports.px_interaction:isPlayerBlocked(toPlayer, player)
					if(block)then
						exports.px_noti:noti("Ten gracz Ciebie zablokował.", player)
					else
						sendPM(player, toPlayer, text)
					end
				end
			end
		else
			exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
		end
	else
		exports.px_noti:noti("Użyj: /pm <id/nick> <treść>", player)
	end
end

-- events

addCommandHandler("pm", privateMessage)
addCommandHandler("pw", privateMessage)
addCommandHandler("pv", privateMessage)
addCommandHandler("napisz", privateMessage)
addCommandHandler("msg", privateMessage)
addCommandHandler("priv", privateMessage)

addCommandHandler("re", function(player, _, ...)
	if(not getElementData(player, "user:uid") or getElementData(player, "user:bw"))then return end

	if(isPlayerHaveMute(player))then
		exports.px_noti:noti("Jesteś wyciszony i nie możesz korzystać z czatu.", player)
		return
	end

	if(...)then
		local text = table.concat({...}, " ")
		if getIpInText(text) then return end

		local toPlayer = getElementData(player, "user:re_message")
		if(toPlayer and isElement(toPlayer) and not isPlayerHaveMute(player))then
			if(toPlayer == player)then
				exports.px_noti:noti("Nie możesz pisać sam ze sobą.", player)
			else
				sendPM(player, toPlayer, text)
			end
		end
	end
end)

local transfer_security={}

function checkTransferSecurity(plr)
    local security_players = {};
    local security_count = 0;
    local security_iterator = 0;

    for i, details in pairs(transfer_security[getPlayerMaskName(plr)]) do
    	if details then
    		local details = transfer_security[getPlayerMaskName(plr)][details[5]]
    		if details then
    			--900000 ms = 15 minut
    			if (getTickCount() - details[4]) < 900000 then
    				security_count = security_count + details[3]
    				table.insert(security_players, details[2].." ("..details[3].."$)")
    				security_iterator = security_iterator + 1;
    			else
    				transfer_security[getPlayerMaskName(plr)][details[5]] = nil;
    			end
    		end
    	end
    end

    if security_iterator > 0 and security_count >= 50000 then
		for i,v in ipairs(getElementsByType("player")) do
			if getElementData(v, "user:admin") then
				outputChatBox(getPlayerMaskName(plr).." przelał "..security_count.."$ do graczy w przeciągu 15 minut!", v, 255, 0, 0)
				outputChatBox("(Przelewy: "..table.concat(security_players, ", ")..")", v, 255, 0, 0)
			end
		end
		local alertText = "\n||@everyone||\n"..getPlayerMaskName(plr).." przelał "..security_count.."$ do graczy w przeciągu 15 minut!\n(Przelewy: "..table.concat(security_players, ", ")..")"
		exports.px_discord:sendDiscordLogs(alertText, "hajs", plr)
    end
end

function transfer(player, _, toPlayer, dolars)
	if(not getElementData(player, "user:uid") or getElementData(player, "user:bw"))then return end

	if toPlayer and dolars then
		if not tonumber(dolars) then return end
		dolars = string.gsub(dolars, "%a", "")

		dolars = tonumber(dolars)
		dolars = math.floor(dolars)

		if dolars < 1 then return end

		if dolars > 100000 then
			exports.px_noti:noti("Maksymalna jednorazowa kwota przelewu wynosi 100,000$.", player)
			return
		end

		toPlayer = findPlayer(toPlayer)

		if(toPlayer == player)then
			exports.px_noti:noti("Nie możesz wysyłać przelewów do samego siebie!", player)
			return
		end

		if(toPlayer and isElement(toPlayer) and getElementData(toPlayer, 'user:uid'))then
			if getPlayerMoney(player) >= tonumber(dolars) then
				givePlayerMoney(toPlayer, dolars)
				takePlayerMoney(player, dolars)

				outputChatBox("#ffd400Przelewasz "..formatMoney(dolars).."$ dla gracza "..getPlayerMaskName(toPlayer).." ["..getElementData(toPlayer, "user:id").."]", player, 255, 255, 255, true)
				outputChatBox("#ffd400Gracz "..getPlayerMaskName(player).." ["..getElementData(player, "user:id").."] przelewa Ci "..formatMoney(dolars).."$", toPlayer, 255, 255, 255, true)

				local text_log = "PRZELEW > ["..getElementData(player, "user:id").."] "..getPlayerMaskName(player).." > ["..getElementData(toPlayer, "user:id").."] "..getPlayerMaskName(toPlayer)..": "..formatMoney(dolars).."$"
				exports.px_admin:addLogsDuty(text_log)

				  local text_database = {formatMoney(dolars).."$", formatMoney(dolars).."$"}
				exports.px_admin:addLogs("przelew", text_database[1], player, "PRZEKAZANE", toPlayer)
				exports.px_admin:addLogs("przelew", text_database[2], toPlayer, "OTRZYMANE", player)

				playSoundFrontEnd(toPlayer, 27)

				exports.px_discord:sendDiscordLogs("Przelew "..dolars.."$ do "..getPlayerMaskName(toPlayer).." ["..getElementData(toPlayer, "user:uid").."]", "przelewy", player)

				if(dolars > 150)then
					exports.px_quests:updateQuest(player, "Podaruj komuś więcej niż 150$", dolars)
				end

				if not transfer_security[getPlayerMaskName(player)] then
					transfer_security[getPlayerMaskName(player)] = {}
				end
				transfer_security[getPlayerMaskName(player)][#transfer_security[getPlayerMaskName(player)]+1] = {player, getPlayerMaskName(toPlayer), dolars, getTickCount(), #transfer_security[getPlayerMaskName(player)]+1}
				checkTransferSecurity(player)
			else
				exports.px_noti:noti("Nie posiadasz wystarczających funduszy.", player)
			end
		else
			exports.px_noti:noti("Nie znaleziono podanego gracza.", player)
		end
	else
		exports.px_noti:noti("Użyj: /przelej <id/nick> <ilość pieniędzy>", player)
	end
end
addCommandHandler("przelej", transfer)
addCommandHandler("dajkase", transfer)
addCommandHandler("zaplac", transfer)

addCommandHandler("do", function(player, _, ...)
	if(not getElementData(player, "user:uid") or getElementData(player, "user:bw"))then return end

	if(isPlayerHaveMute(player))then
		exports.px_noti:noti("Jesteś wyciszony i nie możesz korzystać z czatu.", player)
		return
	end

	if(...)then
		local text = table.concat({...}, " ")
		text=stripColors(text)
		text=stripSpaces(text)

		local x,y,z = getElementPosition(player)
		local getPlayersInColShape = getElementsWithinRange(x, y, z, 25, "player")
		for i,v in pairs(getPlayersInColShape) do
			if(getElementDimension(player) == getElementDimension(v) and getElementInterior(player) == getElementInterior(v))then
				outputChatBox("* "..text.." (("..getPlayerMaskName(player).."))", v,  103, 130, 155, false)
			end
		end

		local text_log = "DO > ["..getElementData(player, "user:id").."] "..getPlayerMaskName(player)..": "..text
		exports.px_admin:addLogsDuty(text_log, "DO")
		exports.px_admin:addLogs("czat", text, player, "DO")
	end
end)

function replaceStars(text)
    return pregReplace(text, "\\*{2}(.*?)\\*{2}", "#dca2f4**\\1**#e5e5e5")
end

function replaceStars2(text)
    return pregReplace(text, "\\*{2}(.*?)\\*{2}", "#dca2f4**\\1**#c8c8c8")
end

addEventHandler("onPlayerChat", root, function(text, type)
	local player = source
	cancelEvent()

	if(not getElementData(player, "user:uid") or getElementData(player, "user:bw"))then return end

	if(isPlayerHaveMute(player))then
		exports.px_noti:noti("Jesteś wyciszony i nie możesz korzystać z czatu.", player)
		return
	end

	local sub=string.sub(text, 1, 1)
	if(getIpInText(text) or sub == "@" or sub == "$" or sub == "!")then return end

	text=stripColors(text)
	text=stripSpaces(text)

	if(getSpam(player))then return end

	if type == 0 and text ~= " " then
		setElementData(player, "user:last_chat_message", text)

		local text_2=text

		local x,y,z = getElementPosition(player)
		local getPlayersInColShape = getElementsWithinRange(x, y, z, 25, "player")

		local admin=getElementData(player, "user:admin")
		local hex=getHex(admin, player)

		local rep=replaceStars(text)
		if(rep)then
			text=rep
		end

		local rep2=replaceStars2(text_2)
		if(rep2)then
			text_2=rep2
		end

		for i,v in pairs(getPlayersInColShape) do
			if(getElementDimension(player) == getElementDimension(v) and getElementInterior(player) == getElementInterior(v))then
				outputChatBox(hex..getElementData(player, "user:id")..hex.."#e5e5e5 "..stripColors(getPlayerMaskName(player))..": "..text, v, 255, 255, 255, true)
			end
		end

		local text_log = "CHAT > ["..getElementData(player, "user:id").."] "..getPlayerMaskName(player)..": "..text
		exports.px_admin:addLogsDuty(text_log)
		exports.px_admin:addLogs("czat", text, player, "CHAT")

		exports.px_discord:sendDiscordLogs("[LOCAL] ["..getElementData(player, "user:id").."] "..getPlayerMaskName(player)..": "..text, "chat", player)
	elseif type == 1 and #text > 0 and text ~= " " then
		outputChatWithDistance(player, text, 25)

		local text_log = "ME > ["..getElementData(player, "user:id").."] "..getPlayerMaskName(player)..": "..text
		exports.px_admin:addLogsDuty(text_log)
		exports.px_admin:addLogs("czat", text, player, "ME")

		exports.px_discord:sendDiscordLogs("[ME] ["..getElementData(player, "user:id").."] "..getPlayerMaskName(player)..": "..text, "chat", player)
	end
end)

addEventHandler("onPlayerCommand", root, function()
	getSpam(source)
end)

addEventHandler("onResourceStart", resourceRoot, function()
	setGameType("RPG + Prace")
	setMapName("Las Venturas")

	setMinuteDuration((60000/4))

	setFPSLimit(0)
	setOcclusionsEnabled(false)
end)

-- useful

function stripColors(text)
    local cnt=1
    while (cnt>0) do
      text,cnt=utf8.gsub(text,"#%x%x%x%x%x%x","")
    end
    return text
end

function formatMoney(money)
	while true do
		money, i = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1,%2")
		if i == 0 then
			break
		end
	end
	return money
end

function getIpInText(ip)
    if ip == nil or type(ip) ~= "string" then
        return false
	end

    local chunks = {ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")}
    if (#chunks == 4) then
        for _,v in pairs(chunks) do
            if (tonumber(v) < 0 or tonumber(v) > 255) then
                return false
			else
				return true
			end
        end
	end

    return false
end

function stripSpaces(text)
	return utf8.gsub(text, " +", " ")
end

-- chat ATC

addCommandHandler("atc", function(player,_,...)
	if(not getElementData(player, "user:uid") or getElementData(player, "user:bw"))then return end

	if(isPlayerHaveMute(player))then
		exports.px_noti:noti("Jesteś wyciszony i nie możesz korzystać z czatu.", player)
		return
	end

	if(...)then
		local text = table.concat({...}, " ")
		if getIpInText(text) then return end

		if(getSpam(player))then return end

		if(#text > 3)then
			local veh=getPedOccupiedVehicle(player)
			if(veh and (getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Helicopter"))then
				for i,v in pairs(getElementsByType("player")) do
					local t_veh=getPedOccupiedVehicle(v)
					if(t_veh and (getVehicleType(t_veh) == "Plane" or getVehicleType(t_veh) == "Helicopter"))then
						outputChatBox("#939393<"..getVehicleName(veh).."-"..getElementData(player, "user:id").."> "..getPlayerMaskName(player)..": "..text, v, 255, 255, 255, true)
					end
				end
			end
		end
	end
end)

-- names

function getPlayerMaskName(player)
	return getElementData(player, "user:nameMask") or getPlayerName(player)
end

-- binds

local chats={
    ["SAPD"]="#0000ff",
    ["SACC"]="#ffff00",
    ["SARA"]="#e89907",
    ["PSP"]="#e73232",
}

addCommandHandler("Organizacja", function(player, _, ...)
    local tag=getElementData(player, "user:organization_tag")
    local rank=getElementData(player, "user:organization_rank")
    if(tag and ... and rank)then
        local text=table.concat({...}, " ")
        for i,v in pairs(getElementsByType("player")) do
            if(getElementData(v, "user:organization_tag") == tag)then
                outputChatBox("#262626"..tag.."> #9f9f9f"..getPlayerName(player).." ["..rank.."] #ffffff: "..text, v, 255, 255, 255, true)
            end
        end
    end
end)

addCommandHandler("Frakcja", function(player, _, ...)
    local Frakcja=getElementData(player, "user:faction")
    local c=chats[Frakcja]
    if(Frakcja and c and ...)then
        local text=table.concat({...}, " ")
        for i,v in pairs(getElementsByType("player")) do
            if(getElementData(v, "user:faction") == Frakcja)then
                outputChatBox("#9f9f9f["..c..Frakcja.."#9f9f9f] ["..getElementData(player, "user:id").."] "..c..getPlayerName(player).."#ffffff: "..text, v, 255, 255, 255, true)
            end
        end
        exports.px_discord:sendDiscordLogs("[FRAKCJA] "..Frakcja.." ["..getElementData(player, "user:id").."] "..getPlayerName(player)..": "..text, "frakcje", player)
    end
end)

addCommandHandler("Służby", function(player, _, ...)
    local Frakcja=getElementData(player, "user:faction")
    local c=chats[Frakcja]
    if(Frakcja and c and ...)then
        local text=table.concat({...}, " ")
        for i,v in pairs(getElementsByType("player")) do
            if(getElementData(v, "user:faction"))then
                outputChatBox("#9f9f9f[#ff0000*#9f9f9f] #9f9f9f["..c..Frakcja.."#9f9f9f] ["..getElementData(player, "user:id").."] "..c..getPlayerName(player).."#ffffff: "..text, v, 255, 255, 255, true)
            end
        end
        exports.px_discord:sendDiscordLogs("[SŁUŻBY] "..Frakcja.." ["..getElementData(player, "user:id").."] "..getPlayerName(player)..": "..text, "frakcje", player)
    end
end)

addCommandHandler("s2", function(plr)
    local faction=getElementData(plr, "user:faction")
    if(faction and chats[faction] and not getElementData(plr, "user:factionAFK"))then
        setElementData(plr, "user:factionAFK", true)
        exports.px_noti:noti("Od teraz posiadasz status 2.", plr, "success")
    end
end)

addCommandHandler("s3", function(plr)
    local faction=getElementData(plr, "user:faction")
    if(faction and chats[faction] and getElementData(plr, "user:factionAFK"))then
        setElementData(plr, "user:factionAFK", false)
        exports.px_noti:noti("Od teraz jesteś dostępny na służbie posiadasz status 3.", plr, "success")
    end
end)

-- binds

function bindCmd(v)
    bindKey(v, "y", "down", "chatbox", "Frakcja")
	bindKey(v, "u", "down", "chatbox", "Służby")
    bindKey(v, "o", "down", "chatbox", "Organizacja")
    bindKey(v, "b", "down", "chatbox", "CB")
end
addEventHandler("onPlayerSpawn", root, function() bindCmd(source) end)
addEventHandler("onResourceStart", resourceRoot, function() for i,v in ipairs(getElementsByType("player")) do bindCmd(v) end end)