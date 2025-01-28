--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

db=exports.px_connect

ui={}
ui.jobs={}

ui.getPlayerUpgrades=function(uid, jobName)
    local upgrades={}
    local r=exports.px_connect:query('select * from jobs_upgrades where job=? and uid=?', uid, jobName)
    if(r and #r > 0)then
        for i,v in pairs(r) do
            upgrades[v.upgrade]=v.state == 1
        end
    end
    return upgrades
end

ui.createJobs=function(jobs)
    for i,v in pairs(jobs) do
        local p=split(v.ped,",")
        local m=split(v.marker,",")
        ui.jobs[v.name]={
            ped=createPed(unpack(p)),
            marker=createMarker(m[1],m[2],m[3]-1,"cylinder",1.7,0,100,200),
            blip=createBlip(m[1],m[2],m[3],11),
            info=v
        }

        if(v.testState == 1)then
            destroyElement(ui.jobs[v.name].blip)
        end

        v.ownedVehicle=v.ownedVehicle and fromJSON(v.ownedVehicle) or false
        if(v.ownedVehicle)then
            ui.jobs[v.name].ownedVehicleShape=createColCuboid(unpack(v.ownedVehicle.colshape))
            ui.jobs[v.name].ownedVehicleObject=createObject(961, v.ownedVehicle.object[1], v.ownedVehicle.object[2], v.ownedVehicle.object[3]-0.5, 0, 0, v.ownedVehicle.object[4])
            setElementData(ui.jobs[v.name].ownedVehicleObject, "job_info", v.ownedVehicle.vehicles)
            setElementData(ui.jobs[v.name].ownedVehicleShape, "job_info", v.ownedVehicle)
        end

        local d=split(v.pedInfo,",")
        setElementData(ui.jobs[v.name].ped, "ped:desc", {name=d[1],desc=d[2]})

        setElementData(ui.jobs[v.name].marker, "icon", ":px_jobs_settings/textures/govMarker.png")
        setElementData(ui.jobs[v.name].marker, "text", {text="Praca dorywcza",desc=v.name})

        setElementData(ui.jobs[v.name].marker, "pos:z", m[3]-1)

        setElementData(ui.jobs[v.name].marker, "job_info", {
            sql=v,
            table=ui.jobs[v.name],
            name=v.name,
        })

        setBlipVisibleDistance(ui.jobs[v.name].blip, 500)

        setElementFrozen(ui.jobs[v.name].ped, true)
    end
end
ui.createJobs(exports.px_connect:query("select * from jobs"))

setTimer(function()
    for i,v in pairs(ui.jobs) do
        local r=exports.px_connect:query("select * from jobs where name=? limit 1", i)
        if(r and #r == 1)then
            ui.jobs[i].info.payment=r[1].payment
            ui.jobs[i].info.payment_xp=r[1].payment_xp
            ui.jobs[i].info.payment_points=r[1].payment_points
            ui.jobs[i].info.upgrades=r[1].upgrades
        end
    end
end, (1000*60), 0)

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and not isPedInVehicle(hit) and dim)then
        local data=getElementData(source, "job_info")
        if(not data)then return end

        local uid=getElementData(hit, "user:uid")
        if(not uid)then return end

        data.rankings=exports.px_connect:query("select * from jobs_points where job=? order by week_points desc limit 9", data.name)
        data.rankingsAll=exports.px_connect:query("select * from jobs_points where job=? order by ranking_points desc limit 9", data.name)

        local myRanking=exports.px_connect:query("select * from jobs_points where uid=? and job=? limit 1", uid, data.name)
        if(not myRanking or (myRanking and #myRanking < 1))then
            local q=exports.px_connect:query("insert into jobs_points (uid,login,job) values(?,?,?)", uid, getPlayerName(hit), data.name)
            if(q)then
                myRanking=exports.px_connect:query("select * from jobs_points where uid=? and job=? limit 1", uid, data.name)
            end
        end
        data.myRanking=myRanking[1]

        triggerLatentClientEvent(hit, "open.job", resourceRoot, data)
    end
end)

-- lobbys

addEvent("create.lobby", true)
addEventHandler("create.lobby", resourceRoot, function(name, pass, level)
    local id=#getElementsByType("lobby")
    id=tonumber(id) or 0
    id=id+1

    if(getElementData(client, "user:jobLobby"))then
        exports.px_noti:noti("Jesteś już w poczekalni.", client, "error")
        return
    end

    lobby=createElement("lobby")
    setElementID(lobby, "job_lobby_"..name.."_"..id)

    setElementData(client, "user:jobLobby", "job_lobby_"..name.."_"..id)

    setElementData(lobby, "info", {
        lider=client,
        players={},
        pass=pass,
        level=level,
        max=2,
        id="job_lobby_"..name.."_"..id
    })
end)

addEvent("join.lobby", true)
addEventHandler("join.lobby", resourceRoot, function(id)
    local myName=getPlayerName(client)

    if(getElementData(client, "user:jobLobby"))then 
        exports.px_noti:noti("Jesteś już w poczekalni.", client, "error")
        return 
    end

    local lobby=getElementByID(id)
    if(lobby and isElement(lobby))then
        local data=getElementData(lobby, "info")
        if(not data)then checkAndDestroy(lobby); setElementData(client, "user:jobLobby", false) return end

        if(table.size(data.players) < data.max and data.lider ~= client)then
            data.players[myName]=client
            setElementData(lobby, "info", data)

            setElementData(client, "user:jobLobby", id)
        else
            exports.px_noti:noti("Brak miejsc.", client, "error")
        end
    end
end)

addEvent("destroy.lobby", true)
addEventHandler("destroy.lobby", resourceRoot, function(id)
    id=id or getElementData(client, "user:jobLobby")

    if(id)then
        local lobby=getElementByID(id)
        if(lobby and isElement(lobby))then
            local data=getElementData(lobby, "info")
            if(not data)then checkAndDestroy(lobby); setElementData(client, "user:jobLobby", false) return end

            if(data.lider == client)then
                for i,v in pairs(data.players) do
                    if(v and isElement(v))then
                        setElementData(v, "user:jobLobby", false)
                    end
                end

                destroyElement(lobby)

                setElementData(client, "user:jobLobby", false)
            end
        end
    end
end)

addEvent("quit.lobby", true)
addEventHandler("quit.lobby", resourceRoot, function()
    local myName=getPlayerName(client)

    local id=getElementData(client, "user:jobLobby")
    if(id)then
        local lobby=getElementByID(id)
        if(lobby and isElement(lobby))then
            local data=getElementData(lobby, "info")
            if(not data)then checkAndDestroy(lobby); setElementData(client, "user:jobLobby", false) return end

            if(data.players[myName])then
                data.players[myName]=nil

                setElementData(client, "user:jobLobby", false)

                setElementData(lobby, "info", data)
            end
        end
    end
end)

addEvent("remove.lobby", true)
addEventHandler("remove.lobby", resourceRoot, function(player)
    local id=getElementData(client, "user:jobLobby")
    if(id)then
        local lobby=getElementByID(id)
        if(lobby and isElement(lobby))then
            local data=getElementData(lobby, "info")
            if(not data)then checkAndDestroy(lobby); setElementData(client, "user:jobLobby", false) return end

            if(data.players[player])then
                setElementData(data.players[player], "user:jobLobby", false)

                data.players[player]=nil

                setElementData(lobby, "info", data)
            end
        end
    end
end)

addEventHandler("onPlayerQuit", root, function()
    local id=getElementData(source, "user:jobLobby")
    local myName=getPlayerName(source)
    if(id)then
        local lobby=getElementByID(id)
        if(lobby and isElement(lobby))then
            local data=getElementData(source, "info")
            if(not data)then checkAndDestroy(source); setElementData(source, "user:jobLobby", false) return end

            if(data.players[myName])then
                data.players[myName]=nil

                setElementData(source, "user:jobLobby", false)

                setElementData(lobby, "info", data)
            else
                if(data.lider == client)then
                    for i,v in pairs(data.players) do
                        setElementData(v, "user:jobLobby", false)
                    end
    
                    destroyElement(lobby)

                    setElementData(source, "user:jobLobby", false)
                end
            end
        end
    end
end)

-- buy upgrade

addEvent("buy.upgrade", true)
addEventHandler("buy.upgrade", resourceRoot, function(v)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local q=exports.px_connect:query("select * from jobs_points where uid=? and job=? limit 1", uid, v.job)
    if(q and #q > 0)then
        local upgrades=fromJSON(q[1].upgrades) or {}
        if(not upgrades[v.upgrade.name] and q[1].points >= v.upgrade.points)then
            upgrades[v.upgrade.name]=true
            exports.px_connect:query("update jobs_points set upgrades=?, points=points-? where uid=? and job=? limit 1", toJSON(upgrades), v.upgrade.points, uid, v.job)

            triggerLatentClientEvent(client, "update.myRanking", resourceRoot, exports.px_connect:query("select * from jobs_points where uid=? and job=? limit 1", uid, v.job)[1], "upgrade")

            exports.px_noti:noti("Pomyślnie zakupiono ulepszenie "..v.upgrade.name..".", client, "success")
        end
    end
end)

addEvent("upgrade.set.state", true)
addEventHandler("upgrade.set.state", resourceRoot, function(v)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local q=exports.px_connect:query("select * from jobs_points where uid=? and job=? limit 1", uid, v.job)
    if(q and #q > 0)then
        local upgrades=fromJSON(q[1].upgrades) or {}
        if(upgrades[v.upgrade.name])then
            if(upgrades[v.upgrade.name] == true)then
                upgrades[v.upgrade.name]={state=true}

                exports.px_noti:noti("Pomyślnie wyłączono ulepszenie "..v.upgrade.name..".", client, "success")
            elseif(upgrades[v.upgrade.name].state)then
                upgrades[v.upgrade.name]=true

                exports.px_noti:noti("Pomyślnie włączono ulepszenie "..v.upgrade.name..".", client, "success")
            end

            exports.px_connect:query("update jobs_points set upgrades=? where uid=? and job=? limit 1", toJSON(upgrades), uid, v.job)

            triggerLatentClientEvent(client, "update.myRanking", resourceRoot, exports.px_connect:query("select * from jobs_points where uid=? and job=? limit 1", uid, v.job)[1], "upgrade")
        end
    end
end)


-- start job

ui.startJob = function(player, job, v)
    setElementData(player, "user:job", job)
    setElementData(player, "user:job_settings", {
        job_name = job,
        job_tag = job,
    })

    if v.info.skin then
        setElementData(player, "save:skin", getElementModel(player), false)
        setElementModel(player, v.info.skin)
    end
end

addEvent("start.job", true)
addEventHandler("start.job", resourceRoot, function(job, players, lobby, level)
    local uid = getElementData(client, "user:uid")
    if not uid then return end

    local info = false

    if getElementData(client, "user:job") then info = "Jesteś już zatrudniony." end
    if getElementData(client, "user:faction") then info = "Jesteś już zatrudniony." end

    if info then
        exports.px_noti:noti(info, client, "error")
        return
    end

    if players and #players > 0 and level then
        for i, v in pairs(players) do
            if v and isElement(v) and getElementData(v, "user:reputation") < level then
                info = getPlayerName(v) .. " nie posiada odpowiedniej ilości reputacji."
                break
            else
                if not v or (v and not isElement(v)) then
                    players[i] = nil
                end
            end
        end

        if #players < 1 then
            info = "Graczy nie ma na serwerze."
        end
    end

    local v = ui.jobs[job]
    if v then
        removePedFromVehicle(client)
        exports.px_noti:noti("Pomyślnie rozpocząłeś pracę w: " .. job, client, "success")

        local r = exports.px_connect:query("select * from jobs_points where uid=? and job=? limit 1", uid, job)
        if r and #r > 0 then
            r[1].upgrades = fromJSON(r[1].upgrades) or {}
            for i, v in pairs(r[1].upgrades) do
                if v ~= true and v.state then
                    r[1].upgrades[i] = nil
                end
            end
            r[1].upgrades = toJSON(r[1].upgrades)

            exports.px_quests:updateQuest(client, "Podejmij pracę dorywczą", 1)

            ui.startJob(client, job, v)
            exports[v.info.scriptName]:startJob(client, r[1], false, players, false)
            triggerLatentClientEvent(client, "destroy.window", resourceRoot)

            setElementData(client, "user:jobBackTime", false)

            if players and #players > 0 then
                for _, plr in pairs(players) do
                    local uid = getElementData(plr, "user:uid")
                    if uid then
                        local q = exports.px_connect:query("select * from jobs_points where uid=? and job=? limit 1", uid, job)
                        if q and #q == 1 then
                            local upgrades = fromJSON(q[1].upgrades) or {}
                            for i, v in pairs(upgrades) do
                                if v ~= true and v.state then
                                    upgrades[i] = nil
                                end
                            end

                            upgrades = toJSON(upgrades)
                            exports[v.info.scriptName]:sendUpgrades(plr, upgrades)
                        end

                        setElementData(plr, "user:jobBackTime", false)
                        ui.startJob(plr, job, v)
                        triggerLatentClientEvent(plr, "destroy.window", resourceRoot)
                    end
                end
            end

            if lobby then
                lobby = getElementByID(lobby)
                if lobby and isElement(lobby) then
                    local data = getElementData(lobby, "info")
                    if not data then return end

                    for i, v in pairs(data.players) do
                        if v and isElement(v) then
                            setElementData(v, "user:jobLobby", false)
                        end
                    end

                    setElementData(client, "user:jobLobby", false)

                    checkAndDestroy(lobby)
                end
            end
        end
    end
end)


ui.stopJob=function(player)
    local skin=getElementData(player, "save:skin")
    if(skin)then
        setElementModel(player, skin)
        setElementData(player, "save:skin", false)
    end

    if(getElementData(player, "user:job"))then
        setElementData(player, "user:job", false)
        setElementData(player, "user:job_settings", false)
    end
end
function stopJob(...) ui.stopJob(...) end

addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, function(job)
    local v=ui.jobs[job]
    if(v)then
        exports[v.info.scriptName]:stopJob(client)
    end

    exports.px_noti:noti("Pomyślnie zakończyłeś pracę w: "..job, client, "success")
    ui.stopJob(client)
end)

-- on stop

addEventHandler("onPlayerQuit", root, function()
    local player=source
    for i,v in pairs(ui.jobs) do
        if(getElementData(player, "user:job") == i)then
            exports[v.info.scriptName]:stopJob(player)
        end
    end
end)

addEventHandler("onPlayerWasted", root, function()
    local player=source
    for i,v in pairs(ui.jobs) do
        if(getElementData(player, "user:job") == i)then
            exports[v.info.scriptName]:stopJob(player)
        end
    end
end)

-- payments

ui.getPlayerPayment=function(payment,myUpgrades,ourUpgrades,onlyUpgrades)
    local addOff=false
    local normal_payment=payment
    for i,v in pairs(ourUpgrades) do
        local k=myUpgrades[v.name]
        if(v.money and k and (type(k) ~= "table" or not k.state))then
            if(not onlyUpgrades or (onlyUpgrades and onlyUpgrades[v.name]))then      
                if(not v.offAll or (v.offAll and not addOff))then
                    normal_payment=normal_payment+v.money

                    if(v.offAll)then
                        addOff=true
                    end
                end
            end
        end
    end
    return normal_payment
end

function getPayment(player, multiplier, cost, onlyUpgrades, target)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return end

    local job=getElementData(player, "user:job")
    if(job)then
        local v=ui.jobs[job]
        if(v)then
            local r=db:query("select upgrades,bonus from jobs_points where job=? and uid=? limit 1", job, uid)
            if(r and #r == 1)then
                local data=getElementData(player, "user:job_settings")

                local money=cost or v.info.payment
                local points=v.info.payment_points
                local xp=v.info.payment_xp

                local biggerPayments=db:query("select bonus,bonusTimeout from jobs where bonus>0 and bonusTimeout<now() and name=? limit 1", job)
                if(biggerPayments and #biggerPayments > 0)then
                    db:query("update jobs set bonus=0, bonusTimeout=? where name=? limit 1", "0000-00-00", job)
                end
                biggerPayments=db:query("select bonus from jobs where bonus>0 and name=? limit 1", job)
                if(biggerPayments and #biggerPayments > 0)then
                    biggerPayments=biggerPayments[1].bonus
                else
                    biggerPayments=nil
                end

                local bonus={}

                bonus["PREMIUM"]={}
                bonus["GOLD"]={}
                bonus["ORGANIZACJA"]={}
                bonus["WYGRANA"]={}
                bonus["WIĘKSZE ZAROBKI"]={}

                if(multiplier)then
                    multiplier=tonumber(multiplier)
                    multiplier=multiplier < 1 and 1 or multiplier

                    money=math.ceil(money*multiplier)
                    xp=math.ceil(xp*multiplier)
                end

                money=ui.getPlayerPayment(money,fromJSON(r[1].upgrades) or {},fromJSON(v.info.upgrades) or {},onlyUpgrades)

                if(data.takeMoney)then
                    money=money-math.percent(data.takeMoney,money)
                end
                if(data.giveMoney)then
                    money=money+math.percent(data.giveMoney,money)
                end

                if(biggerPayments)then
                    bonus["WIĘKSZE ZAROBKI"][#bonus["WIĘKSZE ZAROBKI"]+1]={percent=biggerPayments,typ="$"}
                end

                local org=getElementData(target or player, "user:organization")
                if(org)then                    
                    if(exports.px_organizations:isOrganizationHaveUpgrade(org, "+10% zarobków w pracach"))then
                        bonus["ORGANIZACJA"][#bonus["ORGANIZACJA"]+1]={percent=10,typ="$"}
                    end

                    if(exports.px_organizations:isOrganizationHaveUpgrade(org, "+10% punktów w pracach"))then
                        bonus["ORGANIZACJA"][#bonus["ORGANIZACJA"]+1]={percent=10,typ="punktów"}
                    end
                end
                
                if(getElementData(target or player, "user:premium"))then
                    bonus["PREMIUM"][#bonus["PREMIUM"]+1]={percent=5,typ="$"}
                    bonus["PREMIUM"][#bonus["PREMIUM"]+1]={percent=5,typ="XP"}
                end

                if(getElementData(target or player, "user:gold"))then
                    bonus["GOLD"][#bonus["GOLD"]+1]={percent=10,typ="$"}
                    bonus["GOLD"][#bonus["GOLD"]+1]={percent=10,typ="XP"}
                end

                if(target)then
                    local uid=getElementData(target, "user:uid")
                    local q=db:query("select bonus from jobs_points where job=? and uid=? limit 1", job, uid)
                    if(q and #q == 1 and q[1].bonus > 0)then
                        bonus["WYGRANA"][#bonus["WYGRANA"]+1]={percent=q[1].bonus,typ="$"}
                        bonus["WYGRANA"][#bonus["WYGRANA"]+1]={percent=q[1].bonus,typ="XP"}
                    end
                else
                    if(r[1].bonus > 0)then
                        bonus["WYGRANA"][#bonus["WYGRANA"]+1]={percent=r[1].bonus,typ="$"}
                        bonus["WYGRANA"][#bonus["WYGRANA"]+1]={percent=r[1].bonus,typ="XP"}
                    end
                end

                local info={}
                for name, t in pairs(bonus) do
                    for i,v in pairs(t) do
                        local add=0
                        if(v.typ == "$")then
                            add=math.percent(v.percent, money)
                            money=math.ceil(money+add)
                        elseif(v.typ == "XP")then
                            add=math.percent(v.percent, xp)
                            xp=math.ceil(xp+add)
                        elseif(v.typ == "punktów")then
                            add=math.percent(v.percent, points)
                            points=math.ceil(points+add)
                        end

                        if(not info[name])then
                            info[name]={}
                        end
                        info[name][#info[name]+1]={add,v.typ,v.percent}
                    end
                end

                local text_bonus=""
                for i,v in pairs(info) do
                    local text=i.." +"..v[1][1]..v[1][2].." ("..v[1][3].."%)"
                    if(v[2])then
                        text=i.." +"..v[1][1]..v[1][2].." ("..v[1][3].."%) +"..v[2][1]..v[2][2].." ("..v[2][3].."%)"
                    end
                    text_bonus=#text_bonus > 0 and text_bonus..", "..text or text
                end

                if(target)then
                    player=target
                    uid=getElementData(player, "user:uid")
                end

                if(#text_bonus > 0)then
                    exports.px_noti:noti("Otrzymujesz dodatkowe bonusy: "..text_bonus..". Razem otrzymujesz: $"..money..", "..xp.."XP oraz "..points.." punktów pracy.", player, "success")
                else
                    exports.px_noti:noti("Twoje wynagrodzenie: $"..money..", "..xp.."XP oraz "..points.." punktów pracy.", player, "success")
                end

                if(data)then
                    data.money=(data.money or 0)+tonumber(money)
                    setElementData(player, "user:job_settings", data)
                end

                local exp=getElementData(player, "user:exp") or 0
                setElementData(player, "user:exp", exp+xp)

                if(money > 0)then
                    givePlayerMoney(player,money)
                end

                local org=getElementData(target or player, "user:organization")
                if(org)then
                    exports.px_organizations:updateOrganizationTask(org, "addFromJob", tonumber(money))
                    exports.px_organizations:updateOrganizationLevel(target or player, money)
                end

                exports.px_admin:addLogs("job", "Wypłata z pracy "..job.." w kwocie: $"..money.." dla "..getPlayerName(player), player, "WYPŁATA")

                exports.px_connect:query("update jobs_points set points=points+?, ranking_points=ranking_points+?, week_points=week_points+? where uid=? and job=? limit 1", points, points, points, uid, job)
            end
        end
    end
end

-- useful

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return math.ceil((maxvalue*percent)/100)
    end
    return false
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function checkAndDestroy(element)
    if element and isElement(element) then
        destroyElement(element)
        element = nil
    end
end

-- job

addEventHandler("onResourceStart", resourceRoot, function()
    for i,v in pairs(getElementsByType("player")) do
        if(getElementData(v,"user:jobLobby"))then
            removeElementData(v,"user:jobLobby")
        end
    end
end)

-- zresetuj tygodniowki :x
local bonus={
    [1]=10,
    [2]=7,
    [3]=5,
}

function reload()
    local q=exports.px_connect:query("select weekDate,id,name from jobs where weekDate<now()")
    for i,v in pairs(q) do
        local top=exports.px_connect:query("select uid from jobs_points where job=? order by week_points desc limit 3", v.name)

        exports.px_connect:query("update jobs_points set week_points=0,bonus=0 where job=?", v.name)
        exports.px_connect:query("update jobs set weekDate=now()+interval 7 day where id=? limit 1", v.id)
        
        for key,value in pairs(top) do
            exports.px_connect:query("update jobs_points set bonus=? where uid=? and job=? limit 1", (bonus[key] or 0), value.uid, v.name)
        end
    end
end
setTimer(function()
    reload()
end, 60000, 0)
reload()