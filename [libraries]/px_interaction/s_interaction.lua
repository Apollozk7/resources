--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local tick = {}

function isDoorOpened(veh)
    for i = 2,5 do
        if(getVehicleDoorOpenRatio(veh, i) == 0)then
            return true
        end
    end
    return false
end

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end

function getTopPosition(element, plus)
    local x,y,z = getElementPosition(element)
    local _,_,rot = getElementRotation(element)

    local cx, cy = getPointFromDistanceRotation(x, y, (plus or 0), (-(rot+180)))

    return cx, cy, z
end

function setWelcomeAnimation(player, target)
    local mP={getElementPosition(player)}
    local tP={getElementPosition(target)}
    local dist=getDistanceBetweenPoints3D(mP[1], mP[2], mP[3], tP[1], tP[2], tP[3])
    if(dist <= 1)then
        local pos={getTopPosition(player, -1)}
        setElementPosition(target, unpack(pos))

        local rot={getElementRotation(player)}
        rot[3]=rot[3]+180
        setElementRotation(target, unpack(rot))

        setPedAnimation(player, "GANGS", "hndshkfa", -1, false, false, true, false)
        setPedAnimation(target, "GANGS", "hndshkfa", -1, false, false, true, false)
    end
end

local welcoms={}

addEvent("interaction.action", true)
addEventHandler("interaction.action", resourceRoot, function(veh, selected, x, eq_item)
    if(x == "Zamek")then
        setVehicleLocked(veh, not isVehicleLocked(veh))

        if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
            tick[client] = getTickCount()
        elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
            return
        end

        exports.px_core:outputChatWithDistance(client, (isVehicleLocked(veh) and "zamyka zamek w pojeździe" or "otwiera zamek w pojeździe").." "..getVehicleName(veh)..".", 5)
    elseif(selected == "Przywitaj się")then
        if(welcoms[client])then
            setWelcomeAnimation(client, veh)

            exports.px_quests:updateQuest(client, "Przywitaj się ze znajomym", 1)
            exports.px_quests:updateQuest(veh, "Przywitaj się ze znajomym", 1)

            killTimer(welcoms[client])
            welcoms[client]=nil
        else
            if(not welcoms[veh])then
                exports.px_noti:noti("Poczekaj aż druga osoba zechcę się przywitać.", client, "info")
                exports.px_noti:noti("Otrzymałeś propozycję przywitania od gracza "..getPlayerName(client)..".", veh, "info")

                welcoms[veh]=setTimer(function()
                    if(veh and isElement(veh) and welcoms[veh])then
                        welcoms[veh]=nil
                    end 
                end, (10*1000), 1)
            end
        end
    elseif(selected == "paliwo")then
        x=tonumber(x) or 1

        local fuel=getElementData(veh, "vehicle:fuel") or 0
        local bak=getElementData(veh, "vehicle:fuelTank") or 25
        if(fuel >= bak)then
            exports.px_noti:noti("Bak w pojeździe jest pełny.", client, "error")

            exports.px_eq:destroyObjectItem(client)
        else
            setElementData(veh,"vehicle:fuel",fuel+x)

            exports.px_core:outputChatWithDistance(client, "dolewa "..x.." litrów paliwa do pojazdu "..getVehicleName(veh)..".", 5)

            exports.px_eq:destroyObjectItem(client)
        end

        local data=getElementData(client, "sara:sendOffer")
        if(data and isElement(data))then
            removeElementData(data, "sara:sendOffer")
        end
        removeElementData(client, "sara:sendOffer")
    elseif(selected == "take")then
        exports.px_eq:destroyObjectItem(client)
        setElementData(client, "user:have_item", false)
    elseif(selected == "off")then
        setElementData(client, "user:have_item", false)
    elseif(selected == "napraw")then
        if(eq_item.name == "Zestaw naprawczy")then
            local hp=getElementHealth(veh)
            setElementHealth(veh, hp+250)
            exports.px_core:outputChatWithDistance(client, "naprawia silnik w pojeździe "..getVehicleName(veh)..".", 5)
            exports.px_quests:updateQuest(client, "Użyj dwa razy zestawu naprawczego", 1)
        elseif(eq_item.name == "Zestaw naprawczy +")then
            setElementHealth(veh, 1000)
            exports.px_core:outputChatWithDistance(client, "naprawia silnik w pojeździe "..getVehicleName(veh)..".", 5)
            exports.px_quests:updateQuest(client, "Użyj dwa razy zestawu naprawczego", 1)
        elseif(eq_item.name == "Zestaw naprawczy opon")then
            setVehicleWheelStates(veh, 0, 0, 0, 0)
            exports.px_core:outputChatWithDistance(client, "wymienia opony w pojeździe "..getVehicleName(veh)..".", 5)
            exports.px_quests:updateQuest(client, "Użyj dwa razy zestawu naprawczego", 1)
        end

        local data=getElementData(client, "sara:sendOffer")
        if(data and isElement(data))then
            removeElementData(data, "sara:sendOffer")
        end
        removeElementData(client, "sara:sendOffer")
    elseif(selected == 2)then
        if(isDoorOpened(veh))then
            for i = 2,5 do
                setVehicleDoorOpenRatio(veh, i, 1, 2500)
            end

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            local data=getElementData(veh, "vehicle:components") or {"Podstawowe"}
            for i,v in pairs(data) do
                if(v == "Drzwi zamknięte" or v == "Drzwi otworzone")then
                    data[i]=nil
                end
            end
            data[#data+1]="Drzwi otworzone"
            setElementData(veh, "vehicle:components", data)

            local music=getElementData(veh, "vehicle:stereo_music")
            if(music)then
                music.volume=music.lastVolume or 1
                setElementData(veh, "vehicle:stereo_music", music)
            end

            exports.px_core:outputChatWithDistance(client, "otwiera drzwi w pojeździe "..getVehicleName(veh)..".", 5)
        else
            for i = 2,5 do
                setVehicleDoorOpenRatio(veh, i, 0, 2500)
            end

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            local data=getElementData(veh, "vehicle:components") or {"Podstawowe"}
            for i,v in pairs(data) do
                if(v == "Drzwi otworzone" or v == "Drzwi zamknięte")then
                    data[i]=nil
                end
            end
            data[#data+1]="Drzwi zamknięte"
            setElementData(veh, "vehicle:components", data)

            local music=getElementData(veh, "vehicle:stereo_music")
            if(music)then
                music.volume=0.1
                music.lastVolume=1
                setElementData(veh, "vehicle:stereo_music", music)
            end

            exports.px_core:outputChatWithDistance(client, "zamyka drzwi w pojeździe "..getVehicleName(veh)..".", 5)
        end
    elseif(selected == 4)then
        if(getVehicleDoorOpenRatio(veh, 1) == 0)then
            setVehicleDoorOpenRatio(veh, 1, 1, 2500)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            exports.px_core:outputChatWithDistance(client, "otwiera bagażnik w pojeździe "..getVehicleName(veh)..".", 5)
        else
            setVehicleDoorOpenRatio(veh, 1, 0, 2500)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            exports.px_core:outputChatWithDistance(client, "zamyka bagażnik w pojeździe "..getVehicleName(veh)..".", 5)
        end
    elseif(selected == 3)then
        if(getVehicleDoorOpenRatio(veh, 0) == 0)then
            setVehicleDoorOpenRatio(veh, 0, 1, 2500)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            exports.px_core:outputChatWithDistance(client, "otwiera maske w pojeździe "..getVehicleName(veh)..".", 5)
        else
            setVehicleDoorOpenRatio(veh, 0, 0, 2500)

            if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                tick[client] = getTickCount()
            elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                return
            end

            exports.px_core:outputChatWithDistance(client, "zamyka maske w pojeździe "..getVehicleName(veh)..".", 5)
        end
    end
end)

addEvent("action", true)
addEventHandler("action", resourceRoot, function(scriptName, i, element, name, id, info)
    exports[scriptName]:action(i, element, client, name, id, info)
end)

function getSettingState(name, player)
    return exports.px_dashboard:getSettingState(name,player)
end

addEvent("addFriend", true)
addEventHandler("addFriend", resourceRoot, function(player)
    if(not isElement(player))then return end
    
    local uid=getElementData(player, "user:uid")
    if(not uid)then return end

    local myUID=getElementData(client, "user:uid")
    if(not myUID)then return end

    local login=getPlayerName(client)

    local q1=exports.px_connect:query('select * from accounts_friends where uid=? and uid_target=? limit 1', uid, myUID)
    local q2=exports.px_connect:query('select * from accounts_friends where uid=? and uid_target=? limit 1', myUID, uid)
    if((q1 and #q1 > 0) or (q2 and #q2 > 0))then
        exports.px_noti:noti("Ten gracz dostał już od Ciebie zaproszenie lub posiadasz go w znajomych.", client, "error")
    else
        if(getSettingState(player, "friends_invites"))then
            exports.px_noti:noti("Ten gracz ma zablokowane zaproszenia do znajomych.", client, "error")
            return
        end

        if(isPlayerBlocked(player, client))then
            exports.px_noti:noti("Ten gracz Cię zablokował, nie możesz mu wysłać zaproszenia.", client, "error")
            return
        end

        exports.px_connect:query('insert into accounts_friends (uid,uid_target) values(?,?)', myUID, uid)

        exports.px_noti:noti("Wysłano zaproszenie do znajomych dla gracza "..getPlayerName(player), client)
        exports.px_noti:noti("Otrzymałeś zaproszenie do znajomych od gracza "..getPlayerName(client), player)
    end
end)

addEvent("removeFriend", true)
addEventHandler("removeFriend", resourceRoot, function(player)
    local uid=false
    local login=false
    if(isElement(player))then
        uid=getElementData(player, "user:uid")
        login=getPlayerName(player)
    else
        uid=player.id
        login=player.login
        player=getPlayerFromName(player.login)
    end

    if(not uid)then return end

    local myUID=getElementData(client, "user:uid")
    if(not myUID)then return end

    local r=exports.px_connect:query('select accounts.id,accounts.login,accounts_friends.* from accounts_friends left join accounts on (accounts.id=accounts_friends.uid or accounts.id=accounts_friends.uid_target) where (accounts_friends.uid=? or accounts_friends.uid_target=?) and accounts.login=?', uid, uid, login)
    if(r and #r == 1)then
        exports.px_connect:query('delete from accounts_friends where uid=? and uid_target=?', myUID, uid)
        exports.px_connect:query('delete from accounts_friends where uid=? and uid_target=?', uid, myUID)

        exports.px_dashboard:setPlayerFriendsData(client)
        exports.px_dashboard:updatePanel(client, true)

        if(isElement(player))then
            exports.px_dashboard:setPlayerFriendsData(player)
            exports.px_dashboard:updatePanel(player, true)

            exports.px_noti:noti("Gracz "..getPlayerName(client).." usunął Cię z znajomych.", player)
        end

        exports.px_noti:noti("Usunięto gracza "..login.." z znajomych.", client)
    else
        exports.px_noti:noti("Nie posiadasz tego gracza w znajomych.", client)
    end
end)

function merge(a, b)
    if type(a) == 'table' and type(b) == 'table' then
        for k,v in pairs(b) do if type(v)=='table' and type(a[k] or false)=='table' then merge(a[k],v) else a[k]=v end end
    end
    return a
end

-- voice

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function blockPlayer(player, toPlayer)
	local uid=getElementData(toPlayer, "user:uid")
	if(not uid)then return false end

	local uid_=getElementData(player, "user:uid")
	if(not uid_)then return false end

	local blocked=getElementData(player, "blocked:users") or {}
    if(table.size(blocked) >= 20)then
        exports.px_noti:noti('Maksymalnie możesz zablokować 20 graczy.', player)
        return
    end
    
	blocked[uid]=true
	setElementData(player, "blocked:users", blocked)

	return true
end

function unblockPlayer(player, toPlayer)
	local uid=getElementData(toPlayer, "user:uid")
	if(not uid)then return false end

	local uid_=getElementData(player, "user:uid")
	if(not uid_)then return false end

	local blocked=getElementData(player, "blocked:users") or {}
	if(blocked[uid])then blocked[uid]=nil end
	setElementData(player, "blocked:users", blocked)

	return true
end

function isPlayerBlocked(player, toPlayer)
	local uid=getElementData(toPlayer, "user:uid")
	if(not uid)then return false end

	local uid_=getElementData(player, "user:uid")
	if(not uid_)then return false end

	local blocked=getElementData(player, "blocked:users") or {}
	return blocked[uid]
end

-- kosz

addEventHandler("onPlayerQuit", root, function()
    if(welcoms[source])then
        welcoms[source]=nil
    end
end)