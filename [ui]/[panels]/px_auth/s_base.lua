--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

loadstring(exports.px_connect:dbGetClass())()
local ui = {}

-- quests

ui.getRandomQuest=function()
    local q=exports.px_connect:query("select * from accounts_day_quests where (not date=? and date<curdate()) limit 1", "0000-00-00")
    if(q and #q == 1)then
        local last_quest=q[1].id
        local quests=exports.px_connect:query("select * from accounts_day_quests")
        
        local block=5
        local random=1
        if(#quests > random)then
            local index=1

            random=math.random(1,#quests)
            while(random == last_quest)do
                index=index+1

                random=math.random(1,#quests)
                if(index >= block)then
                    break
                end
            end
        end

        local row=quests[random]
        if(row)then
            exports.px_connect:query("update accounts_day_quests set date=? where date<curdate()", "0000-00-00")
            exports.px_connect:query("update accounts_day_quests set date=curdate() where id=? limit 1", row.id)
            exports.px_connect:query("update accounts set quest_progress=0")

            return {row=row, type="new", progress=0}
        end
    end

    local r=exports.px_connect:query("select * from accounts_day_quests where date=curdate()")
    return {row=r[1], type="exists"}
end

--

ui.setForumPremium=function(forum_uid, have, type)
    type=type or "premium"

    local ranks={
        ["premium"]=11,
        ["member"]=3,
        ["gold"]=13,
    }

    local r=exports.px_connect:query("forum", "select member_group_id, mgroup_others from core_members where member_id=? limit 1", forum_uid)
    if(r and #r > 0)then
        local inne=split(r[1].mgroup_others, ",") or {}
        if(tostring(r[1].member_group_id) == ranks["member"] and have)then
            exports.px_connect:query("forum", "update core_members set member_group_id=? where member_id=? limit 1", ranks[type], forum_uid)
        elseif(tostring(r[1].member_group_id) == ranks[type] and not have)then
            exports.px_connect:query("forum", "update core_members set member_group_id=? where member_id=? limit 1", ranks["member"], forum_uid)
        else
            local znaleziono=false
            for i,v in pairs(inne) do
                if(tostring(v) == tostring(ranks[type]))then
                    if(not have)then
                        inne[i]=nil
                    end

                    znaleziono=true
                    break
                end
            end

            if(have and not znaleziono)then
                inne[#inne+1]=ranks[type]
            end

            inne=table.concat(inne, ",") or {}

            -- aktualizujemy podrzędną
            exports.px_connect:query("forum", "update core_members set mgroup_others=? where member_id=? limit 1", inne, forum_uid)
        end
    end
end

ui.factions={
    ["PSP"]={pos={-2039.5802,-163.1405,35.5000},color={255,0,0}},
    ["SAPD"]={pos={2344.5830,2455.0227,14.9742},color={0,0,255}},
    ["SARA"]={pos={67.7188,-306.9370,1.7656},color={230, 145, 56}},
    ["SACC"]={pos={2505.4622,926.6923,10.8280},color={255,255,0}},
}

ui.spawnPlayer=function(player, login, uid, pos, gold)
    local spawns={}

    for i,v in pairs(ui.factions) do
        local r=exports.px_connect:query("select fraction from groups_fractions_players where uid=? and fraction=? limit 1", uid, i)
        if(r and #r == 1)then
            local pos=v.pos
            local zone=getZoneName(pos[1],pos[2],pos[3],true)
            local zone_2=getZoneName(pos[1],pos[2],pos[3],true)

            spawns[#spawns+1]={name=utf8.upper("BAZA "..i), color=v.color, desc=zone..", "..zone_2, pos=pos}

            break
        end
    end

    local org=exports.px_connect:query("select org from groups_organizations_players where uid=? limit 1", uid)
    local q=exports.px_connect:query("select position,type,id from houses where owner=?", uid)
    if(org and #org == 1)then
        q=exports.px_connect:query("select position,type,id from houses where (owner=? or organization=? or owner=?)", uid, org[1].org, org[1].org)
    end
    if(q and #q > 0)then
        for i,v in pairs(q) do
            local pos=split(v.position, ',')
            local zone=getZoneName(pos[1],pos[2],pos[3],true)
            local zone_2=getZoneName(pos[1],pos[2],pos[3],true)

            spawns[#spawns+1]={name=utf8.upper(v.type).." ["..v.id.."]", color={255,150,0}, desc=zone..", "..zone_2, pos=pos}
        end
    end

    local vehs=exports.px_connect:query("select position,model,id from vehicles where (model=? or model=?) and owner=? and parking=0 and h_garage=0", 483, 508, uid)
    if(vehs and #vehs > 0)then
        for i,v in pairs(vehs) do
            local pos=split(v.position, ',')
            local zone=getZoneName(pos[1],pos[2],pos[3],true)
            local zone_2=getZoneName(pos[1],pos[2],pos[3],true)

            spawns[#spawns+1]={name=utf8.upper(getVehicleNameFromModel(v.model)).." ["..v.id.."]", color={0,200,100}, desc=zone..", "..zone_2, pos=pos}
        end
    end

    local q=exports.px_connect:query("select * from houses_rents left join houses on houses_rents.house_id=houses.id where houses_rents.uid=?", uid)
    if(q and #q > 0)then
        for i,v in pairs(q) do
            local pos=split(v.position, ',')
            local zone=getZoneName(pos[1],pos[2],pos[3],true)
            local zone_2=getZoneName(pos[1],pos[2],pos[3],true)

            spawns[#spawns+1]={name=utf8.upper(v.type).." ["..v.id.."]", color={255,150,0}, desc=zone..", "..zone_2, pos=pos}
        end
    end

    if(gold)then
        local pos=pos and split(pos,',') or {0,0,0}
        if(pos[1] ~= 0 and pos[2] ~= 0 and pos[3] ~= 0)then
            local zone=getZoneName(pos[1],pos[2],pos[3],true)
            local zone_2=getZoneName(pos[1],pos[2],pos[3],true)
            
            spawns[#spawns+1]={name="OSTATNIA POZYCJA", color={0,200,100}, desc=zone..", "..zone_2, pos=pos}
        end
    end

    triggerClientEvent(player, "ui.showPanel", resourceRoot, login, spawns)
end

ui.getPilotTime=function(player)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return end

    -- pilot week time
    local r=exports.px_connect:query("select pilotWeekTime, pilotWeekDate, (pilotWeekDate+interval 7 day > now()) as resetPilotTime from accounts where id=? limit 1", uid)
    if(r and #r > 0 and r[1].resetPilotTime == 0)then
        exports.px_connect:query("update accounts set pilotWeekDate=now(), pilotWeekTime=0 where id=? limit 1", uid)
        setElementData(player, "user:pilotWeekTime", 0)
    else
        setElementData(player, "user:pilotWeekTime", r[1].pilotWeekTime)
    end
end

ui.loadPlayer=function(player, result, pos)
    if(string.len(result[1].login) >= 22 or string.len(result[1].login) <= 2)then
        kickPlayer(player, "Zmień swój login na forum.")
        return
    end

    local loggedIn_plr = getPlayerFromName(result[1].login);
    if(loggedIn_plr)then
        if(getElementData(loggedIn_plr, "user:uid"))then
            exports.px_noti:noti("Konto jest aktualnie używane! (#1)", player)
            return
        else
            if(result[1].logged == "1")then
                exports.px_connect:query("update accounts set logged=0 where id=?", result[1].id)
            end
            if(loggedIn_plr ~= player)then
                setPlayerName(loggedIn_plr, math.random(10000)..getPlayerName(loggedIn_plr)..math.random(10000))
            end
        end
    end

    setPlayerName(player, result[1].login)

    setTimer(function(player, result, pos)
        if(not isElement(player)) then return end

        if(getPlayerName(player) ~= result[1].login and player and isElement(player))then
            kickPlayer(player, "Zmień swój login na forum.")
        elseif(player and isElement(player))then
            -- quests
            local quest=ui.getRandomQuest()
            if(quest.progress)then
                result[1].quest_progress=quest.progress or 0
            end
            
            if(quest.type == "new")then
                exports.px_connect:query("update accounts set quest_progress=0 where id=?", result[1].id)
                result[1].quest_progress=0

                outputChatBox("* Dzisiejsze zadanie dzienne:", player)
                outputChatBox("----------------------------------", player)
                outputChatBox("- "..quest.row.text, player)
                outputChatBox("- Ukończono: 0/"..quest.row.value, player)
                outputChatBox("----------------------------------", player)
            else
                quest=quest or {}
                quest.row=quest.row or {value=0}
                quest.row.value=quest.row.value or 0
                if(result[1].quest_progress < quest.row.value)then
                    outputChatBox("* Dzisiejsze zadanie dzienne:", player)
                    outputChatBox("----------------------------------", player)
                    outputChatBox("- "..quest.row.text, player)
                    outputChatBox("- Ukończono: "..result[1].quest_progress.."/"..quest.row.value, player)
                    outputChatBox("----------------------------------", player)
                end
            end

            setElementData(player, "user:dayQuest", {
                progress=result[1].quest_progress or 0,
                value=quest.row.value or 0,
                name=quest.row.text or "",
                id=quest.row.id or 0,
                done=(result[1].quest_progress or 0) >= quest.row.value or false
            })

            local job_bonus=exports.px_connect:query("select bonus,job from jobs_points where uid=? and bonus>0", result[1].id)
            if(job_bonus and #job_bonus > 0)then
                for i,v in pairs(job_bonus) do
                    local jobs=exports.px_connect:query("select weekDate from jobs where name=? limit 1", v.job)
                    if(jobs and #jobs == 1)then
                        outputChatBox("* Posiadasz aktywny bonus: "..v.bonus.."% na pracy: "..v.job..", do: "..jobs[1].weekDate, player, 0, 200, 0)
                    end
                end
            end
            
            -- inne
            setPlayerMoney(player, result[1].money)

            if(result[1].health <= 1)then
                result[1].health=1
            end
            setElementHealth(player, result[1].health)

            setElementData(player, "user:uid", result[1].id)
            setElementData(player, 'user:reputation', result[1].reputation)
            setElementData(player, "user:logged", true)
            setElementData(player, "user:register_date", result[1].register_date)
            setElementData(player, "user:online_time", result[1].online)
            setElementData(player, "user:sesion_time", 0)
            setElementData(player, "user:police_stars", result[1].police_stars)
            setElementData(player, "user:dash_settings", split(result[1].dash_settings, ','))
            setElementData(player, "user:vehiclesSlots", result[1].vehiclesSlots or 2)
            setElementData(player, "user:respect", result[1].respect or 0)

            if(result[1].discord_avatar and #result[1].discord_avatar > 0)then
                setElementData(player, 'user:avatarURL', result[1].discord_avatar)
                exports.px_avatars:getAvatar(result[1].login, player, result[1].discord_avatar)
            end

            -- licenses
            local licenses=split(result[1].licenses,',')
            setElementData(player, "user:licenses", {a=licenses[1],b=licenses[2],c=licenses[3],['c+e']=licenses[4],l1=licenses[5],l2=licenses[6]})
            --

            -- blocked
            local blockedData=split(result[1].blocked,',') or {}
            local blocked={}
            for i,v in pairs(blockedData) do
                blocked[v]=true
            end
            setElementData(player, "blocked:users", blocked)
            --

            -- eq
            result[1].eq=#result[1].eq < 1 and "[[]]" or result[1].eq
            result[1].eq=fromJSONED(result[1].eq)
            setElementData(player, "user:eq", result[1].eq)
            --

            -- achievements
            local achievementsData = split(result[1].achievements, ", ") or {}
            local achievementsList = exports.px_achievements:getAchievements()
            local playerAchivements = {}

            for i,v in ipairs(achievementsData) do
                local achievement = achievementsList[tonumber(v)]
                if(achievement)then
                    playerAchivements[achievement.title] = true
                else
                    iprint("[px_auth] An error occurred while loading achievement ("..v..") for player with UID: "..result[1].id)
                end
            end

            setElementData(player, "user:achievements", playerAchivements)

            local friends=exports.px_dashboard:setPlayerFriendsData(player) or {}
            if(#friends >= 1 and not exports.px_achievements:isPlayerHaveAchievement(player, "Ziomeczek"))then
                exports.px_achievements:getAchievement(player, "Ziomeczek")
            elseif(#friends >= 10 and not exports.px_achievements:isPlayerHaveAchievement(player, "Dusza towarzystwa"))then
                exports.px_achievements:getAchievement(player, "Dusza towarzystwa")
            end

            -- orgs
            local r=exports.px_connect:query("select * from groups_organizations_players where uid=? limit 1", result[1].id)
            if(r and #r == 1)then
                local q=exports.px_connect:query("select * from groups_organizations where org=? limit 1", r[1].org)
                if(q and #q == 1)then
                    setElementData(player, "user:organization", q[1].org)
                    setElementData(player, "user:organization_tag", q[1].tag)
                    setElementData(player, "user:organization_rank", r[1].rank)

                    exports.px_organizations:setOrganizationTasks(q[1].org)
                end
            end
            --

            -- mandates
            local r=exports.px_connect:query('select * from accounts_mandates where uid=?', result[1].id)
            exports['px_factions-tablet']:getPlayerMandates(player, r)
            --

            --premium
            if(result[1].premium)then
                local q = exports.px_connect:query("select * from accounts where premium>now() and id=?", result[1].id)
                if(q and #q > 0)then
                    setElementData(player, "user:premium", true)

                    outputChatBox("* Posiadasz aktywne konto PREMIUM do: "..result[1].premium, player, 241, 238, 146)

                    exports.px_premium:newPremium(player)

                    if(result[1].forum_id ~= 0)then
                        ui.setForumPremium(result[1].forum_id, true)
                    end
                else
                    outputChatBox("* Twoje konto PREMIUM wygasło.", player, 241, 238, 146)

                    exports.px_connect:query("update accounts set premium=? where id=?", nil, result[1].id)

                    if(result[1].forum_id ~= 0)then
                        ui.setForumPremium(result[1].forum_id, false)
                    end
                end
            end
            if(result[1].gold)then
                local q = exports.px_connect:query("select * from accounts where gold>now() and id=?", result[1].id)
                if(q and #q > 0)then
                    setElementData(player, "user:gold", true)

                    outputChatBox("* Posiadasz aktywne konto GOLD do: "..result[1].gold, player, 213, 173, 74)

                    exports.px_premium:newGold(player)

                    if(result[1].forum_id ~= 0)then
                        ui.setForumPremium(result[1].forum_id, true, "gold")
                    end
                else
                    outputChatBox("* Twoje konto GOLD wygasło.", player, 213, 173, 74)

                    exports.px_connect:query("update accounts set gold=? where id=?", nil, result[1].id)

                    if(result[1].forum_id ~= 0)then
                        ui.setForumPremium(result[1].forum_id, false, "gold")
                    end
                end
            end
            --

            -- in admins
            local q=exports.px_connect:query("select * from admins where serial=? and nick=? and uid=?", getPlayerSerial(player), getPlayerName(player), result[1].id)
            if(q and #q > 0)then
                exports.px_premium:newPremium(player)
                exports.px_premium:newGold(player)
            end
            --

            --mute
            local q = exports.px_connect:query("select * from misc_punish where (serial=? or nick=?) and active=1 and type=? and date>now() limit 1", getPlayerSerial(player), getPlayerName(player), "mute")
            if(q and #q > 0)then
                outputChatBox("-------------------------------------------", player, 255, 0, 0)
                outputChatBox("Jesteś wyciszony!", player, 255, 0, 0)
                outputChatBox("Osoba wyciszająca: "..q[1]["admin"], player, 255, 0, 0)
                outputChatBox("Powód wyciszenia: "..q[1]["reason"], player, 255, 0, 0)
                outputChatBox("Czas wyciszenia: "..q[1]["date"], player, 255, 0, 0)
                outputChatBox("----------------------------------------", player, 255, 0, 0)
                setElementData(player, "user:mute", true)
            else
                exports.px_connect:query("update misc_punish set active=0 where (serial=? or nick=?) and type=?", getPlayerSerial(player), getPlayerName(player), "mute")
            end

            -- voice mute
            local q = exports.px_connect:query("select * from misc_punish where (serial=? or nick=?) and active=1 and type=? and date>now() limit 1", getPlayerSerial(player), getPlayerName(player), "voice_mute")
            if(q and #q > 0)then
                outputChatBox("-------------------------------------------", player, 255, 0, 0)
                outputChatBox("Jesteś wyciszony na chacie głosowym!", player, 255, 0, 0)
                outputChatBox("Osoba wyciszająca: "..q[1]["admin"], player, 255, 0, 0)
                outputChatBox("Powód wyciszenia: "..q[1]["reason"], player, 255, 0, 0)
                outputChatBox("Czas wyciszenia: "..q[1]["date"], player, 255, 0, 0)
                outputChatBox("----------------------------------------", player, 255, 0, 0)
                setElementData(player, "user:voice_mute", true)
            else
                exports.px_connect:query("update misc_punish set active=0 where (serial=? or nick=?) and type=?", getPlayerSerial(player), getPlayerName(player), "voice_mute")
            end
            --

            --pj
            local q = exports.px_connect:query("select * from misc_punish where (serial=? or nick=?) and active=1 and type=? and date>now() limit 1", getPlayerSerial(player), getPlayerName(player), "pj")
            if(q and #q > 0)then
                outputChatBox("-------------------------------------------", player, 255, 0, 0)
                outputChatBox("Posiadasz zawieszone prawo jazdy!", player, 255, 0, 0)
                outputChatBox("Osoba zawieszająca: "..q[1]["admin"], player, 255, 0, 0)
                outputChatBox("Powód zawieszenia: "..q[1]["reason"], player, 255, 0, 0)
                outputChatBox("Czas zawieszenia: "..q[1]["date"], player, 255, 0, 0)
                outputChatBox("----------------------------------------", player, 255, 0, 0)

                setElementData(player, "user:license_take", q[1])
            else
                exports.px_connect:query("update misc_punish set active=0 where (serial=? or nick=?) and type=?", getPlayerSerial(player), getPlayerName(player), "pj")
            end
            --

            --L
            local q = exports.px_connect:query("select * from misc_punish where (serial=? or nick=?) and active=1 and type=? and date>now() limit 1", getPlayerSerial(player), getPlayerName(player), "l")
            if(q and #q > 0)then
                outputChatBox("-------------------------------------------", player, 255, 0, 0)
                outputChatBox("Posiadasz zawieszone licencje lotnicze!", player, 255, 0, 0)
                outputChatBox("Osoba zawieszająca: "..q[1]["admin"], player, 255, 0, 0)
                outputChatBox("Powód zawieszenia: "..q[1]["reason"], player, 255, 0, 0)
                outputChatBox("Czas zawieszenia: "..q[1]["date"], player, 255, 0, 0)
                outputChatBox("----------------------------------------", player, 255, 0, 0)

                setElementData(player, "user:license_l_take", q[1])
            else
                exports.px_connect:query("update misc_punish set active=0 where (serial=? or nick=?) and type=?", getPlayerSerial(player), getPlayerName(player), "l")
            end
            --

            -- pilot time
            ui.getPilotTime(player)
            --

            -- invites
            local inv=fromJSON(result[1].getInviteAward) or {}
            if(not inv.accept)then
                setElementData(player, "dashboard_inviteAward", inv, false)
            end

            --losowania
            local q=exports.px_connect:query("select * from accounts where randomElipseLast=curdate() and id=? limit 1", result[1].id)
            if(#q < 1)then
                exports.px_connect:query("update accounts set randomElipseLast=curdate(),randomElipse=randomElipse+1 where id=?", result[1].id)
            end

            -- on login
            triggerEvent("onPlayerAuthLogin", root, player)

            for _, stat in ipairs({71,72,76,77,78}) do
                setPedStat(player, stat, 1000)
            end
        end
    end, 500, 1, player, result, pos)
end

-- save player

ui.savePlayer=function(player, logout)
    local id = getElementData(player, "user:uid")
    if not id then return end

    local result = exports.px_connect:query("select * from accounts where id=?", id)
    if result and #result > 0 then
        local money = getPlayerMoney(player)
        -- admin time
        local admin=getElementData(player, 'user:admin')
        local dutyTime=getElementData(player, 'user:adminTimeTick')
        if(not logout and admin and dutyTime)then
            local realDutyTime=(getTickCount()-dutyTime)/1000
            local admin_time=math.floor(realDutyTime/60)
            if(admin_time > 0)then
                local payment=exports.px_admin:givePlayerPayment(false, admin_time, admin)
                if(payment and payment > 0)then
                    money=money+payment
                end

                local r=exports.px_connect:query('select * from admins_stats where uid=? and `date`=date', id)
				if(r and #r == 1)then
					exports.px_connect:query('update admins_stats set minutes=minutes+? where uid=? and `date`=date', admin_time, id)
				else
					exports.px_connect:query('insert into admins_stats (uid,minutes,`date`) values(?,?,date)', id, admin_time)
				end
            end
        end
        --

        local online = getElementData(player, "user:online_time") or 0
        local settings=table.concat(getElementData(player, "user:dash_settings") or {},',')
        local pilotWeekTime=getElementData(player, "user:pilotWeekTime") or 0
        local eq=getElementData(player, "user:eq") or {}
        local health = getElementHealth(player)
        local rp=getElementData(player, 'user:reputation') or 0

        local lastPos='0,0,0'
        if(getElementDimension(player) == 0 and getElementInterior(player) == 0)then
            lastPos=table.concat({getElementPosition(player)}, ',')
        end

        local mask=getElementData(player, "user:nameMask")
        if(mask)then
            for i,v in pairs(eq) do
                if(v.name == "Kominiarka")then
                    eq[i]=nil
                    break
                end
            end
        end
        eq=toJSONED(eq)

        local blockedData=getElementData(player, "blocked:users") or {}
        local blocked={}
        for i,v in pairs(blockedData) do
            blocked[#blocked+1]=i
        end
        blocked=table.concat(blocked, ',')

        local licensesData=getElementData(player, 'user:licenses') or {}
        local licenses=table.concat({licensesData.a or 0,licensesData.b or 0,licensesData.c or 0,licensesData['c+e'] or 0,licensesData.l1 or 0,licensesData.l2 or 0},',')

        if(logout)then
            exports.px_connect:query("update accounts set logged=1, health=?, money=?, online=?, eq=?, dash_settings=?, blocked=?, lastlogin=now(), licenses=?, pilotWeekTime=?, lastPos=?, reputation=? where id=?", health, money, online, eq, settings, blocked, licenses, pilotWeekTime, lastPos, rp, id)
        else
            exports.px_connect:query("update accounts set logged=0, health=?, money=?, online=?, eq=?, dash_settings=?, blocked=?, lastlogin=now(), licenses=?, pilotWeekTime=?, lastPos=?, reputation=? where id=?", health, money, online, eq, settings, blocked, licenses, pilotWeekTime, lastPos, rp, id)
        end
    end
end

-- whitelist functions

ui.whitelistFind=function(player,tbl)
    tbl=string.sub(tbl,2,#tbl-1)
    tbl=split(tbl,",")

    local t=false
    for i,v in pairs(tbl) do
        v=string.gsub(v,'"', '')
        if(v==getPlayerSerial(player))then
            t=true
            break
        end
    end
    return t
end

ui.defaultWhitelist=function(player)
    local serial=getPlayerSerial(player)
    return '["'..serial..'"]'
end

-- forum and game accounts :-)

local tasks = {}

-- triggers

ui.getRandomClothes=function(player)
    local myTable={}
    for clothesType=0, 17 do 
        local block=1
        
        local rnd=math.random(0,67)
        local clothesTexture,model=getClothesByTypeIndex(clothesType, rnd)
        while(not clothesTexture or not model) do
            rnd=math.random(0,67)
            clothesTexture,model=getClothesByTypeIndex(clothesType, rnd)

            block=block+1
            if(block >= 5)then
                break
            end
        end

        if(clothesTexture and model)then
            addPedClothes(player, clothesTexture, model, clothesType)
        end
    end
end

addEvent("ui.spawnPlayer", true)
addEventHandler("ui.spawnPlayer", resourceRoot, function(login, pos)
    if(client and isElement(client))then
        local result = exports.px_connect:query("select * from accounts where login=?", login)
        if(result and #result > 0)then
            ui.loadPlayer(client, result)

            setElementFrozen(client, true)
            spawnPlayer(client, pos[1], pos[2], pos[3]+1, 0, result[1].skin, 0, 0, false)
            if(result[1].skin == 0)then
                ui.getRandomClothes(client)
            end

            -- loading
            exports.px_loading:createLoadingScreen(client, true, 255, 1000)
            exports.px_connect:query("update accounts set logged=1 where login=?", login)

            local player=client
            setTimer(function()
                if(player and isElement(player))then
                    setElementFrozen(player, false)
                end
            end, 1000, 1)
        end
    end
end)

addEvent("ui.loginPlayer", true)
addEventHandler("ui.loginPlayer", resourceRoot, function(login, password, save)
    login = escapeString(login)
    password = escapeString(password)

    table.insert(tasks, {
        type = "login", 
        player = client,
        data = {
            login = login,
            password = password,
            save = save
        }
    })
end)

addEvent("ui.registerPlayer", true)
addEventHandler("ui.registerPlayer", resourceRoot, function(login, password, mail)
    login = escapeString(login)
    password = escapeString(password)
    mail = escapeString(mail)

    table.insert(tasks, {
        type = "register",
        player = client,
        data = {
            login = login,
            password = password,
            mail = mail
        }
    })
end)

function isElementPlayer(theElement)
    if (theElement and isElement(theElement) and getElementType(theElement) == "player") then
        return true
    end
    return false
end

function taskChecker()
    if(#tasks < 1)then
        setTimer(taskChecker, 100, 1)
        return
    end

    local taskData = tasks[1]
    table.remove(tasks, 1)

    if(not isElementPlayer(taskData.player)) then
        taskChecker()
        return
    end

    if(taskData.type == "login")then
        DBQuery:new({"SELECT * FROM accounts WHERE login=?", taskData.data.login}):execute(function(result)
            if(not isElementPlayer(taskData.player))then
                taskChecker()
                return
            end

            if(result and #result > 0)then
                passwordVerify(taskData.data.password, result[1].password, function(valid)
                    if(not isElementPlayer(taskData.player))then
                        taskChecker()
                        return
                    end
                    if(valid)then
                        if(result[1].logged == "1")then
                            exports.px_noti:noti("Ktoś jest już zalogowany na te konto!", taskData.player)
                            setTimer(taskChecker, 100, 1)
                        else
                            if(not result[1].serial)then
                                local defaultWhitelist = ui.defaultWhitelist(taskData.player)
                                exports.px_connect:query("UPDATE accounts SET serial=?, whitelist=? WHERE id=?", getPlayerSerial(taskData.player), defaultWhitelist, result[1].id)
                            else
                                if(not ui.whitelistFind(taskData.player, result[1].whitelist)) then
                                    exports.px_noti:noti("Nie posiadasz dostępu do tego konta.", taskData.player)
                                    setTimer(taskChecker, 100, 1)
                                    return
                                end
                            end

                            ui.spawnPlayer(taskData.player, taskData.data.login, result[1].id, result[1].lastPos == "" and false or result[1].lastPos, result[1].gold)
                            triggerClientEvent(taskData.player, "ui.saveDates", resourceRoot, taskData.data.login, taskData.data.password, taskData.data.save)
                            setTimer(taskChecker, 100, 1)
                        end
                    else
                        exports.px_noti:noti("Podane hasło jest nieprawidłowe.", taskData.player)
                        setTimer(taskChecker, 100, 1)
                    end
                end)
            else
                exports.px_noti:noti("Nie znaleziono konta o takiej nazwie użytkownika.", taskData.player)
                setTimer(taskChecker, 100, 1)
            end
        end)
    elseif(taskData.type == "register")then
        DBQuery:new({"SELECT * FROM accounts WHERE login=? LIMIT 1", taskData.data.login}):execute(function(result)
            if(not isElementPlayer(taskData.player))then
                taskChecker()
                return
            end

            if(result and #result > 0)then
                exports.px_noti:noti("Konto o takiej nazwie użytkownika już istnieje, jeżeli zarejestrowałeś się na forum posiadasz już konto na serwerze.", taskData.player)
                triggerClientEvent(taskData.player, "ui.checkTrigger", resourceRoot)
                setTimer(taskChecker, 100, 1)
                return
            else
                DBQuery:new({"SELECT * FROM accounts WHERE mail=? LIMIT 1", taskData.data.mail}):execute(function(result)
                    if(not isElementPlayer(taskData.player))then
                        taskChecker()
                        return
                    end
                    if(result and #result > 0)then
                        exports.px_noti:noti("Konto o takim adresie e-mail już istnieje, jeżeli zarejestrowałeś się na forum posiadasz już konto na serwerze.", taskData.player)
                        triggerClientEvent(taskData.player, "ui.checkTrigger", resourceRoot)
                        setTimer(taskChecker, 100, 1)
                        return
                    else
                        DBQuery:new({"SELECT * from accounts WHERE serial=? LIMIT 2", taskData.data.mail}):execute(function(result)
                            if(not isElementPlayer(taskData.player))then
                                taskChecker()
                                return
                            end
                            if(result and #result >= 2)then
                                exports.px_noti:noti("Możesz posiadać maksymalnie dwa konta.", taskData.player)
                                triggerClientEvent(taskData.player, "ui.checkTrigger", resourceRoot)
                                setTimer(taskChecker, 100, 1)
                                return
                            else
                                passwordHash(taskData.data.password, "bcrypt", {}, function(encodedPassword)
                                    if(not isElementPlayer(taskData.player))then
                                        taskChecker()
                                        return
                                    end
                        
                                    --[[DBQuery:new({"forum", "INSERT INTO core_members (name, member_group_id, email, joined, ip_address, members_pass_hash, members_bitoptions, pp_setting_count_comments, timezone) VALUES(?, 3, ?, UNIX_TIMESTAMP(), ?, ?, 65536, 0, ?)", taskData.data.login, taskData.data.mail, getPlayerIP(taskData.player), encodedPassword, "Europe/Warsaw"}):execute(function(forumResult, _, forumInsertedId)
                                        if(not isElementPlayer(taskData.player))then
                                            taskChecker()
                                            return
                                        end
                                        
                                        if(forumResult)then
                                            local defaultWhitelist = ui.defaultWhitelist(taskData.player)
                                            DBQuery:new({"INSERT INTO accounts (forum_id, login, password, mail, serial, whitelist, logged) VALUES (?, ?, ?, ?, ?, ?, 1)", forumInsertedId, taskData.data.login, encodedPassword, taskData.data.mail, getPlayerSerial(taskData.player), defaultWhitelist}):execute(function(serverResult, _, serverInsertedId)
                                                if(not isElementPlayer(taskData.player))then
                                                    taskChecker()
                                                    return
                                                end
                                                
                                                if(serverResult)then
                                                    exports.px_connect:query("forum", "UPDATE core_members SET game_uid=? WHERE member_id=?", serverInsertedId, forumInsertedId)
                                                    ui.spawnPlayer(taskData.player, taskData.data.login, serverInsertedId)
                                                    setTimer(taskChecker, 100, 1)
                                                else
                                                    exports.px_noti:noti("Wystąpił błąd podczas logowania! Zgłoś ten błąd administratorowi, kod błędu #1.", taskData.player)
                                                    triggerClientEvent(taskData.player, "ui.checkTrigger", resourceRoot)
                                                    setTimer(taskChecker, 100, 1)
                                                end
                                            end)
                                        else
                                            exports.px_noti:noti("Wystąpił błąd podczas logowania! Zgłoś ten błąd administratorowi, kod błędu #2.", taskData.player)
                                            triggerClientEvent(taskData.player, "ui.checkTrigger", resourceRoot)
                                            setTimer(taskChecker, 100, 1)
                                        end
                                    end)]]

                                    local defaultWhitelist = ui.defaultWhitelist(taskData.player)
                                    DBQuery:new({"INSERT INTO accounts (forum_id, login, password, mail, serial, whitelist, logged) VALUES (?, ?, ?, ?, ?, ?, 1)", forumInsertedId or 0, taskData.data.login, encodedPassword, taskData.data.mail, getPlayerSerial(taskData.player), defaultWhitelist}):execute(function(serverResult, _, serverInsertedId)
                                        if(not isElementPlayer(taskData.player))then
                                            taskChecker()
                                            return
                                        end
                                        
                                        if(serverResult)then
                                            --exports.px_connect:query("forum", "UPDATE core_members SET game_uid=? WHERE member_id=?", serverInsertedId, forumInsertedId)
                                            ui.spawnPlayer(taskData.player, taskData.data.login, serverInsertedId)
                                            setTimer(taskChecker, 100, 1)
                                        else
                                            exports.px_noti:noti("Wystąpił błąd podczas logowania! Zgłoś ten błąd administratorowi, kod błędu #1.", taskData.player)
                                            triggerClientEvent(taskData.player, "ui.checkTrigger", resourceRoot)
                                            setTimer(taskChecker, 100, 1)
                                        end
                                    end)
                                end)
                            end
                        end)
                    end
                end)
            end
        end)
    end
end
setTimer(taskChecker, 100, 1)

addEvent("ui.getSave", true)
addEventHandler("ui.getSave", resourceRoot, function()
    local r=exports.px_connect:query('select * from news order by date desc')
    triggerClientEvent(client, 'px_auth:getChangelogList', resourceRoot, r)
end)

-- players

ui.getPlayersOnline=function()
	local q = exports.px_connect:query("select login from accounts where logged=1")
	for i,v in pairs(q) do
		if(not getPlayerFromName(v.login))then
			exports.px_connect:query("update accounts set logged=0 where login=?", v.login)
		end
	end
end
ui.getPlayersOnline()
--setTimer(ui.getPlayersOnline, 300000, 0)

addEventHandler("onPlayerQuit", root, function()
    ui.savePlayer(source)
end)

ui.savePlayers=function()
    for i,v in pairs(getElementsByType('player')) do
        ui.savePlayer(v,true)
    end
end
setTimer(ui.savePlayers,(1000*60)*30,0)

addCommandHandler('save', function(plr)
    ui.savePlayer(plr)
end)

-- events

addEventHandler("onPlayerLogout", root, function()
	cancelEvent()
end)

addEventHandler("onPlayerChangeNick", root, function()
	cancelEvent()
end)

-- anty cheat
local devs = {
    ["74AD615CFE02B293D95D63C9918358B3"] = true, -- psychol.
}

addEventHandler("onPlayerCommand", root, function(command)
    if(not isElement(source))then return end

	if(not getElementData(source, "user:logged") and not devs[getPlayerSerial(source)])then
		cancelEvent()
    elseif(command == "logout" and not devs[getPlayerSerial(source)])then
		cancelEvent()
    elseif(command == "login" and not devs[getPlayerSerial(source)])then
		cancelEvent()
    elseif(command == "register" and not devs[getPlayerSerial(source)])then
		cancelEvent()
    elseif(command == 'msg')then
        cancelEvent()
	end
end)

-- assets functions

function escapeString(text)
	local str = string.gsub(tostring(text), "'", "")
	str = string.gsub(str, '"', "")
	str = string.gsub(str, ';', "")
	str = string.gsub(str, "\\", "")
	str = string.gsub(str, "/*", "")
	str = string.gsub(str, "*/", "")
	str = string.gsub(str, "'", "")
	str = string.gsub(str, "`", "")
    str = string.gsub(str, " ", "")
    str = string.gsub(str, "#%x%x%x%x%x%x", "")
	return str
end

function toJSONED(table)
	local tbl={}
	for i,v in pairs(table) do
		if(v)then
			tbl[#tbl+1]={id=i,name=v}
		end
	end
	return toJSON(tbl)
end

function fromJSONED(jsoned)
	jsoned=fromJSON(jsoned)

    local tbl={}
	for i,v in pairs(jsoned) do
		tbl[v.id]=v.name
	end

	return tbl
end

--ban system (Toffy.)
addEvent("px_auth->checkBan", true)
addEventHandler("px_auth->checkBan", resourceRoot, function()
    local q = exports.px_connect:query("select * from misc_punish where serial=? and active=1 and type=? and date>now() limit 1", getPlayerSerial(client), "ban")
    if(q and #q > 0)then
        local ban_data = {
            reason = q[1].reason,
            date = q[1].date
        }

        local admin_account = exports.px_connect:query("select login from accounts where id=?", q[1].uid_admin)
        if(#admin_account > 0)then
            ban_data.admin = admin_account[1].login
        else
            ban_data.admin = q[1].admin
        end

        triggerClientEvent(client, "px_auth->responseBan", resourceRoot, ban_data)
	else
		exports.px_connect:query("update misc_punish set active=0 where serial=? and type=? limit 1", getPlayerSerial(client), "ban")
        triggerClientEvent(client, "px_auth->responseBan", resourceRoot, false)
    end
end)

addEvent("px_auth->leaveServer", true)
addEventHandler("px_auth->leaveServer", resourceRoot, function(ban_data)
    outputConsole("-------------------------------------------", client)
    outputConsole("Zostałeś zbanowany na tym serwerze!", client)
    outputConsole("Osoba banująca: "..ban_data["admin"], client)
    outputConsole("Powód bana: "..ban_data["reason"], client)
    outputConsole("Czas bana: "..ban_data["date"], client)
    outputConsole("----------------------------------------", client)
    kickPlayer(client, ban_data["admin"], "Otwórz konsole (~)")
end)

-- avatars

addEvent("get.avatar", true)
addEventHandler("get.avatar", resourceRoot, function(login)
    local r=exports.px_connect:query('select discord_avatar from accounts where login=? limit 1', login)
    if(r and #r > 0 and r[1].discord_avatar)then
        fetchRemote(r[1].discord_avatar, load_photo, "", false, client)
    end
end)

function load_photo(new_photo, errors, player)
    if(errors == 0)then
        triggerLatentClientEvent(player, "get.avatar", resourceRoot, new_photo)
    else
        triggerLatentClientEvent(player, "get.avatar", resourceRoot)
    end
end

-- save

ui.savePlayers()