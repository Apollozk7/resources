--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

ui.places={
    {2270.7773,2449.2556,18.7734},
    {2270.9971,2444.4041,18.7734},
    {2270.9614,2440.2041,18.7734},
    {2281.4109,2440.1282,18.7734},
    {2281.3125,2445.1272,18.7734},
    {2281.2280,2449.4163,18.7734}
}

ui.timers={}
ui.backPos={2276.2363,2448.0312,18.7671}

ui.cs=createColCuboid(2268.37207, 2438.46533, 17.76706, 15.436279296875, 13.074951171875, 3.359192276001)
setElementDimension(ui.cs, 997)

addEventHandler("onColShapeLeave", ui.cs, function(hit, dim)
    if(hit and dim and getElementData(hit,"user:jailTimestamp"))then
        local rnd=math.random(1,#ui.places)
        local pos=ui.places[rnd]
        setElementPosition(hit, unpack(pos))
    end
end)

ui.setPlayerToJail=function(client,target,reason,time)
    local q,_,id=exports.px_connect:query("insert into police_jail (nick,date,serial,reason) values(?,now()+interval ? minute,?,?)", getPlayerName(target), time, getPlayerSerial(target), reason)
    if(q and id)then
        setElementData(target, "user:handcuffs", false)
        setElementData(client, "police:handcuffs", false)
        detachElements(target,client)
        detachElements(client,target)
        setElementFrozen(target, false)
        setPedAnimation(target,false)
        setElementCollisionsEnabled(target, true)

        local rnd=math.random(1,#ui.places)
        local pos=ui.places[rnd]

        setElementPosition(target, unpack(pos))
        setElementDimension(target, 997)
    
        exports.px_noti:noti(getPlayerName(target).." trafił do więzienia na "..time.." minut z powodu "..reason, client, "success")
        exports.px_noti:noti("Trafiłeś do więzienia na "..time.." minut z powodu "..reason.." przez "..getPlayerName(client), target, "info")

        if(not exports.px_achievements:isPlayerHaveAchievement(target, "Problemy z prawem"))then
            exports.px_achievements:getAchievement(target, "Problemy z prawem")
        end

        local q=exports.px_connect:query("select *,UNIX_TIMESTAMP(date) as wyjdzie from police_jail where id=? limit 1", id)
        if(q and #q == 1)then
            setElementData(target, "user:jailTimestamp", q[1].wyjdzie)

            setTimer(function()
                triggerClientEvent(target, "refresh.info", resourceRoot)            
            end, 500, 1)
        end
    end
end

addEvent("get.jail", true)
addEventHandler("get.jail", resourceRoot, function()
    local player=client

    exports.px_noti:noti("Twój pobyt w więzieniu się zakończył.", player, "success")

    setElementPosition(player, unpack(ui.backPos))

    exports.px_connect:query("delete from police_jail where serial=?", getPlayerSerial(player))

    setElementData(player, "user:jailTimestamp", false)
end)

addEventHandler("onPlayerSpawn", root, function()
    local q=exports.px_connect:query("select *,UNIX_TIMESTAMP(date) as wyjdzie from police_jail where serial=? and date>now()", getPlayerSerial(source))
    if(q and #q > 0)then
        local rnd=math.random(1,#ui.places)
        local pos=ui.places[rnd]

        setElementPosition(source, unpack(pos))
        setElementDimension(source, 997)

        exports.px_noti:noti("Będziesz przebywał w więzieniu do: "..q[1].date..", z powodu: "..q[1].reason, source, "info")

        if(not exports.px_achievements:isPlayerHaveAchievement(source, "Problemy z prawem"))then
            exports.px_achievements:getAchievement(source, "Problemy z prawem")
        end

        setElementData(source, "user:jailTimestamp", q[1].wyjdzie)
    else
        exports.px_connect:query("delete from police_jail where serial=? and date<now()", getPlayerSerial(source))
    end
end)

addEvent("start.jail", true)
addEventHandler("start.jail", resourceRoot, function(target, reason, time)
    if(isElementWithinColShape(client, ui.cs))then
        ui.setPlayerToJail(client,target,reason,time)
    else
        exports.px_noti:noti("Musisz znajdować się w więzieniu.", client, "error")
    end
end)

addCommandHandler("jail", function(plr, _, nick, time, ...)
    if(getElementData(plr, "user:faction") == "SAPD")then
        if(nick and time and ...)then
            local target=getPlayerFromName(nick)
            if(target)then
                local r=exports.px_connect:query("select serial from accounts where login=? limit 1", nick)
                if(r and #r > 0 and getElementData(target, "user:handcuffs") == plr)then
                    local reason=table.concat({...}, "")
                    ui.setPlayerToJail(plr,target,reason,time)
                else
                    exports.px_noti:noti("Podany gracz nie istnieje, lub nie masz go zakutego w kajdanki.", plr, "error")
                end
            else
                local r=exports.px_connect:query("select serial from accounts where login=? limit 1", nick)
                if(r and #r > 0)then
                    local reason=table.concat({...}, "")
                    local q=exports.px_connect:query("insert into police_jail (nick,date,serial,reason) values(?,now()+interval ? minute,?,?)", nick, time, r[1].serial, reason)
                    if(q)then
                        exports.px_noti:noti(nick.." trafił do więzienia na "..time.." minut z powodu "..reason.." (AKCJA OFFLINE)", plr, "success")
                    end
                else
                    exports.px_noti:noti("Podany gracz nie istnieje.", plr, "error")
                end
            end
        else
            exports.px_noti:noti("Prawidłowe użycie komendy: /jail <nick> <ilość minut> <powód>", plr, "error")
        end
    end
end)

addCommandHandler("wyciagnij_jail", function(plr, _, nick)
    if(getElementData(plr, "user:faction") == "SAPD")then
        if(nick)then
            local target=getPlayerFromName(nick)
            if(target and getElementData(target, 'user:jailTimestamp'))then
                setElementPosition(target, 2275.5024,2447.6514,18.7671)
                setElementDimension(target, 997)
            
                exports.px_noti:noti('Pomyślnie wyciągnieto '..getPlayerName(target)..' z więzienia.', plr, "success")
                exports.px_noti:noti('Zostałeś wyciągnięty z więzienia przez '..getPlayerName(plr)..'.', target, "info")

                setElementData(target, "user:jailTimestamp", false)
        
                exports.px_connect:query("delete from police_jail where serial=?", getPlayerSerial(target))
            end
        end
    end
end)

addEventHandler("onPlayerQuit", root, function()
    local data=getElementData(source, "user:handcuffs")
    if(data)then
        local nick=getPlayerName(source)
        local time=60
        local serial=getPlayerSerial(source)
        local reason="Wyjście z serwera podczas zakucia"
        exports.px_connect:query("insert into police_jail (nick,date,serial,reason) values(?,now()+interval ? minute,?,?)", nick, time, serial, reason)
    end

    if(ui.timers[source] and isTimer(ui.timers[source]))then
        killTimer(ui.timers[source])
        ui.timers[source]=nil
    end
end)