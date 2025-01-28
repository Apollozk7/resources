local playerTimers = {}
function sendStats(player)
	if isElement(player) then
		local columns, rows = getPerformanceStats("Lua timing")
		triggerClientEvent(player, "receiveServerStat", player, columns, rows)
		playerTimers[player] = setTimer(sendStats, 1000, 1, player)
	end
end

addEvent("getServerStat", true)
addEventHandler("getServerStat", root, function()
	sendStats(client)
end)

addEvent("destroyServerStat", true)
addEventHandler("destroyServerStat", root, function()
	if isTimer(playerTimers[client]) then
		killTimer(playerTimers[client])
		playerTimers[client] = nil
	end
end)

function kurwaPseudolJebany()
	local columns, rows = getPerformanceStats("Lua timing")
	for i,v in pairs(rows) do
		local percent=string.sub(v[2],1,#v[2]-1)
		if(percent and string.len(percent) > 0 and tonumber(percent))then
			if(tonumber(percent) > 30)then
				if(getPlayerFromName('psychol.'))then
					outputChatBox("WARMING! SKRYPT "..v[1].." WPIERDALA "..percent.."CPU OGARNIJ TO ZJEBIE!", getPlayerFromName('psychol.'))
				end
				if(getPlayerFromName('SavenQ'))then
					outputChatBox("WARMING! SKRYPT "..v[1].." WPIERDALA "..percent.."CPU OGARNIJ TO ZJEBIE!", getPlayerFromName('SavenQ'))
				end
				iprint("WARMING! SKRYPT "..v[1].." WPIERDALA "..percent.."CPU OGARNIJ TO ZJEBIE!")
			end
		end
	end
end
setTimer(kurwaPseudolJebany,(1000*10),0)
kurwaPseudolJebany()