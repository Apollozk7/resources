--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- functions

local adminResource = getResourceFromName("px_admin")
if adminResource then
    local ranks = call(adminResource, "getRanks")
    if not ranks then
        outputDebugString("[ERRO] px_admin:getRanks retornou nil ou false!")
    end
else
    outputDebugString("[ERRO] Recurso px_admin não encontrado!")
end

function loadClubAvatarFromIPS(player, avatar)
    triggerClientEvent(player, "load.organization.avatar", resourceRoot, avatar)
end

function updatePanel(client)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query("select * from accounts where id=? limit 1", uid)
    if(r and #r == 1)then
        local friends=exports.px_connect:query('select accounts.id,accounts.login,accounts_friends.* from accounts_friends left join accounts on (accounts_friends.uid=accounts.id or accounts_friends.uid_target=accounts.id) where (accounts_friends.uid=? or accounts_friends.uid_target=?)', uid, uid)

        local ranks=exports.px_admin:getRanks()
        local rank=false

        local faction=exports.px_factions:isPlayerInFaction(getPlayerName(client))
        local organization=exports.px_organizations:isPlayerInOrganization(getPlayerName(client))

        local vehs=exports.px_connect:query('select * from vehicles where owner=? or `keys` LIKE ?', uid, "%"..getPlayerName(client).."%")
        local groups_vehs = exports.px_connect:query("select * from groups_vehicles where owner=?", uid)

        if(groups_vehs and #groups_vehs > 0)then
            for i,v in pairs(groups_vehs) do
                v.group=true
                v.id="G_"..v.id
                table.insert(vehs, v)
            end
        end

        local houses=exports.px_connect:query("select * from houses where owner=?", uid)
        local punish=exports.px_connect:query("select * from misc_punish where active=1 and serial=?", getPlayerSerial(client))
        local admins=exports.px_connect:query("select * from admins where serial=? and nick=? and uid=? limit 1", getPlayerSerial(client), getPlayerName(client), uid)

        if(admins and #admins == 1)then
            rank=ranks[admins[1].rank].name or ranks[1].name
        end

        rank=(not rank and getElementData(client, "user:premium") and "PREMIUM") or (not rank and getElementData(client, "user:gold") and "GOLD") or rank or "GRACZ"

        local premium=exports.px_connect:query("select *,(cost/points) as ranking from misc_premiumShop order by ranking")
        local discord=exports.px_connect:query("select * from discord_codes where login=? limit 1", getPlayerName(client))

        local _,_,slots=exports.px_vehicles:getPlayerFreeVehicleSlot(client)
        if(slots)then
            r[1].vehiclesSlots=slots
        end

        local achievements = exports.px_achievements:getAchievements()
        triggerClientEvent(client, "update.info", resourceRoot, r[1], faction, organization, vehs, houses, punish, rank, premium, discord, friends, achievements)
    end
end

-- triggers

addEvent("get.discord.award", true)
addEventHandler("get.discord.award", resourceRoot, function()
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query("select discord_award from accounts where id=? and discord_award=0 limit 1", uid)
    if(r and #r == 1)then
        exports.px_connect:query("update accounts set discord_award=1 where id=? limit 1", uid)
        exports.px_noti:noti("Za połączenie konta w grze, z kontem Discord otrzymujesz $4.500 oraz 10RP.", client, "success")
        
        givePlayerMoney(client,4500)
        setElementData(client,"user:reputation",getElementData(client,"user:reputation")+10)

        updatePanel(client)
    end
end)

addEvent("get.bonus.award", true)
addEventHandler("get.bonus.award", resourceRoot, function(type, value)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    if(type == "money")then
        givePlayerMoney(client, value)
        exports.px_noti:noti("Pomyślnie odebrano nagrodę w postaci: $"..value, client, "success")
    elseif(type == "pp")then
        exports.px_connect:query("update accounts set premiumPoints=premiumPoints+? where id=? limit 1", value, uid)
        exports.px_noti:noti("Pomyślnie odebrano nagrodę w postaci: "..value.."PP.", client, "success")
    elseif(type == "exp")then
        local xp=getElementData(client, "user:reputation") or 0
        setElementData(client, "user:reputation", xp+value)
        exports.px_noti:noti("Pomyślnie odebrano nagrodę w postaci: "..value.."RP.", client, "success")
    end

    exports.px_connect:query("update accounts set getBonusDay=1,bonus_date=curdate() where id=? limit 1", uid)

    updatePanel(client)

    triggerClientEvent(client, "bonusTrigger", resourceRoot)
end)

addEvent("update.info", true)
addEventHandler("update.info", resourceRoot, function(avatar)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query("select *,DATEDIFF(`bonus_date`, NOW()) AS elapsedDays from accounts where id=? limit 1", uid)
    if(r and #r == 1)then
        local friends=exports.px_connect:query('select accounts.id,accounts.login,accounts_friends.* from accounts_friends left join accounts on (accounts_friends.uid=accounts.id or accounts_friends.uid_target=accounts.id) where (accounts_friends.uid=? or accounts_friends.uid_target=?)', uid, uid)

        local elapsedDays=r[1].elapsedDays and math.abs(r[1].elapsedDays) or 99
        if(elapsedDays == 1 and r[1].getBonusDay == 1)then
            exports.px_connect:query("update accounts set bonus_day=bonus_day+1,bonus_date=curdate(),getBonusDay=0 where id=? limit 1", uid)
        elseif(elapsedDays >= 1)then
            exports.px_connect:query("update accounts set bonus_day=1,bonus_date=curdate(),getBonusDay=0 where id=? limit 1", uid)
        end

        if(r[1].bonus_day < 1)then
            r[1].bonus_day=1
        end

        r=exports.px_connect:query("select * from accounts where id=? limit 1", uid)

        local ranks=exports.px_admin:getRanks()
        local rank=false

        local faction=exports.px_factions:isPlayerInFaction(getPlayerName(client))
        local organization=exports.px_organizations:isPlayerInOrganization(getPlayerName(client))

        local vehs=exports.px_connect:query('select * from vehicles where owner=? or `keys` LIKE ?', uid, "%"..getPlayerName(client).."%")
        local groups_vehs=exports.px_connect:query("select * from groups_vehicles where owner=?", uid)
        if(groups_vehs and #groups_vehs > 0)then
            for i,v in pairs(groups_vehs) do
                v.group=true
                v.id="G_"..v.id
                table.insert(vehs, v)
            end
        end
        
        local houses=exports.px_connect:query("select * from houses where owner=?", uid)
        local punish=exports.px_connect:query("select * from misc_punish where active=1 and serial=?", getPlayerSerial(client))
        local admins=exports.px_connect:query("select * from admins where serial=? and nick=? and uid=? limit 1", getPlayerSerial(client), getPlayerName(client), uid)

        if(admins and #admins == 1)then
            rank=ranks[admins[1].rank].name or ranks[1].name
        end

        rank=(not rank and getElementData(client, "user:premium") and "PREMIUM") or (not rank and getElementData(client, "user:gold") and "GOLD") or rank or "GRACZ"

        local premium=exports.px_connect:query("select *,(cost/points) as ranking from misc_premiumShop order by ranking")
        local discord=exports.px_connect:query("select * from discord_codes where login=? limit 1", getPlayerName(client))

        local _,_,slots=exports.px_vehicles:getPlayerFreeVehicleSlot(client)
        if(slots)then
            r[1].vehiclesSlots=slots
        end

        local achievements = exports.px_achievements:getAchievements()
        triggerClientEvent(client, "update.info", resourceRoot, r[1], faction, organization, vehs, houses, punish, rank, premium, discord, friends, achievements)
        
        local invite=fromJSON(r[1].orgInvite) or {}
        if(invite.name and not avatar)then
            exports.px_organizations:ipsGetClubLogo(client, invite.name, "px_dashboard")
        end
    end
end)

-- organizations invites

addEvent("dashboard.requestGroupInvite", true)
addEventHandler("dashboard.requestGroupInvite", resourceRoot, function(action, name, target)
    local org=getElementData(client, "user:organization")
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query("select orgInvite from accounts where id=? limit 1", uid)
    if(r and #r == 1)then
        if(action == "accept")then
            if(org)then
                exports.px_noti:noti("Posiadasz już organizacje.", client, "error")
                return
            end

            local r=exports.px_connect:query("select tag,ranks from groups_organizations where org=? limit 1", name)
            if(r and #r == 1)then
                local max=exports.px_organizations:isOrganizationHaveUpgrade(name, "Bez limitowe sloty na graczy") and 0 or exports.px_organizations:isOrganizationHaveUpgrade(name, "50 slotów na graczy") and 50 or exports.px_organizations:isOrganizationHaveUpgrade(name, "20 slotów na graczy") and 20 or 10
                local players=exports.px_connect:query("select * from groups_organizations_players where org=?", name)
                if(max == 0 or (#players+1 <= max))then
                    local ranks=fromJSON(r[1].ranks) or {{name="Początkujący"}}
                    local rank=ranks[#ranks].name
                    local q=exports.px_connect:query("insert into groups_organizations_players (uid,login,org,`rank`,added) values(?,?,?,?,now())", uid, getPlayerName(client), name, rank)
                    if(q)then
                        exports.px_noti:noti("Przyjęto zaproszenie do organizacji "..name..".", client, "success")

                        setElementData(client, "user:organization", name)
                        setElementData(client, "user:organization_tag", r[1].tag)
                        setElementData(client, "user:organization_rank", rank)

                        exports.px_organizations:ipsAddPlayer(client, name, target)
                    else
                        exports.px_noti:noti("Wystąpił błąd.", client, "error")
                    end
                else
                    exports.px_noti:noti("W organizacji może być maksymalnie "..max.." graczy.", client, "error")
                end
            end
        else
            exports.px_noti:noti("Odrzucono zaproszenie do organizacji "..name..".", client, "success")
        end

        exports.px_connect:query("update accounts set orgInvite=? where id=? limit 1", "", uid)

        updatePanel(client)
    end
end)

-- friends

function setPlayerFriendsData(player)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query('select accounts.id,accounts.login,accounts_friends.* from accounts_friends left join accounts on (accounts_friends.uid=accounts.id or accounts_friends.uid_target=accounts.id) where (accounts_friends.uid=? or accounts_friends.uid_target=?) and accept is not null', uid, uid)
    if(r and #r > 0)then
        setElementData(player, 'friends:data', r)
        return r
    end
end

addEvent("dashboard.requestFriendInvite", true)
addEventHandler("dashboard.requestFriendInvite", resourceRoot, function(type, t_uid, t_login)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local login=getPlayerName(client)

    local r=exports.px_connect:query('select * from accounts_friends where uid=? and uid_target=? and accept is null', t_uid, uid)
    if(r and #r == 1)then
        if(type == "accept")then
            exports.px_connect:query('update accounts_friends set accept=1 where uid=? and uid_target=?', t_uid, uid)
            exports.px_noti:noti("Pomyślnie przyjęto gracza "..t_login.." do znajomych.", client, "success")
        else
            exports.px_connect:query('delete from accounts_friends where uid=? and uid_target=?', t_uid, uid)
            exports.px_noti:noti("Pomyślnie odrzucono zaproszenie gracza "..t_login.." do znajomych.", client, "info")
        end

        setPlayerFriendsData(client)

        updatePanel(client)

        local player=getPlayerFromName(t_login)
        if(player and getElementData(player, "user:uid"))then
            if(type == "accept")then
                exports.px_noti:noti(getPlayerName(client).." zaakceptował twoje zaproszenie do znajomych.", player, "success")
                setPlayerFriendsData(player)

                if(not exports.px_achievements:isPlayerHaveAchievement(client, "Ziomeczek"))then
                    exports.px_achievements:getAchievement(client, "Ziomeczek")
                elseif(not exports.px_achievements:isPlayerHaveAchievement(client, "Dusza towarzystwa") and #r >= 9)then
                    exports.px_achievements:getAchievement(client, "Dusza towarzystwa")
                end
            else
                exports.px_noti:noti(getPlayerName(client).." odrzucił twoje zaproszenie do znajomych.", player, "error")
            end
        end
    end
end)

-- invites

addEvent("dashboard.getInvitesWithdraw", true)
addEventHandler("dashboard.getInvitesWithdraw", resourceRoot, function(links, money)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query("select invites from accounts where id=? limit 1", uid)
    if(r and #r == 1)then
        local invites=fromJSON(r[1].invites) or {}
        if(#invites >= links)then
            for i=1,links do
                table.remove(invites,links)
            end

            exports.px_connect:query("update accounts set invites=? where id=? limit 1", toJSON(invites), uid)

            givePlayerMoney(client, tonumber(money))

            exports.px_noti:noti("Pomyślnie wypłacono $"..money.." z "..links.." zaproszonych graczy.", client, "success")

            updatePanel(client)
        end
    end
end)

addEvent("dashboard.setInviteLink", true)
addEventHandler("dashboard.setInviteLink", resourceRoot, function(link, pp)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    if(not link)then return end
    
    link=string.gsub(link,"pixelmta/code_","")

    local q=exports.px_connect:query("select inviteAward,online from accounts where id=? limit 1", uid)
    if(q and #q == 1 and tonumber(q[1].inviteAward) == 0 and tonumber(link) ~= tonumber(uid))then
        if(q[1].online <= 60)then
            local accounts=exports.px_connect:query("select id from accounts where serial=?", getPlayerSerial(client))
            if(accounts and #accounts == 1)then
                local r=exports.px_connect:query("select id,invites from accounts where id=? limit 1", link)
                if(r and #r == 1)then
                    local inviteAward={login=r[1].login,uid=r[1].id,pp=pp}
                    exports.px_connect:query("update accounts set inviteAward=1,getInviteAward=? where id=? limit 1", toJSON(inviteAward), uid)

                    exports.px_noti:noti("Pomyślnie użyto linku z zaproszeniem.", client, "success")
                else
                    exports.px_noti:noti("Podany link do zaproszenia jest nieprawidłowy.", client, "error")
                end
            else
                exports.px_noti:noti("Link może użyć tylko i wyłącznie osoba, która posiada tylko jedno konto zarejestrowane na swój serial.", client, "error")
            end
        else
            exports.px_noti:noti("Link może użyć tylko i wyłącznie osoba, które na koncie nie ma przegrane więcej niż 1h.", client, "error")
        end
    else
        exports.px_noti:noti("Użyłeś już linku z zaproszeniem.", client, "error")
    end
end)

addEventHandler("onElementDataChange", root, function(key, old, new)
    if(key == "user:online_time" and new)then
        local uid=getElementData(source, "user:uid")
        if(not uid)then return end

        local award=getElementData(source, "dashboard_inviteAward")
        if(new >= 600 and award)then
            local q=exports.px_connect:query("select getInviteAward from accounts where id=? limit 1", uid)
            if(q and #q == 1)then
                local inviteAward=fromJSON(q[1].getInviteAward) or {}
                inviteAward.accept=true
                exports.px_connect:query("update accounts set getInviteAward=?,premiumPoints=premiumPoints+? where id=? limit 1", toJSON(inviteAward), inviteAward.pp, uid)
                setElementData(source, "dashboard_inviteAward", false, false)

                local r=exports.px_connect:query("select id,invites,inviteAward from accounts where id=? limit 1", inviteAward.uid)
                if(r and #r == 1)then
                    local invites=fromJSON(r[1].invites) or {}
                    invites[#invites+1]={login=getPlayerName(source),uid=uid}
                    exports.px_connect:query("update accounts set invites=? where id=? limit 1", toJSON(invites), inviteAward.uid)
                end
            end
        end
    end
end)

-- random elipse

addEvent("take.randomElipse", true)
addEventHandler("take.randomElipse", resourceRoot, function()
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    exports.px_connect:query("update accounts set randomElipse=randomElipse-1 where id=? limit 1", uid)
    updatePanel(client)

    triggerClientEvent(client, "losuj", resourceRoot)
end)

addEvent("dashboard.getElipseAward", true)
addEventHandler("dashboard.getElipseAward", resourceRoot, function(type)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    if(type == "pp")then
        local value=math.random(3,4)

        exports.px_connect:query("update accounts set premiumPoints=premiumPoints+? where id=? limit 1", value, uid)
        updatePanel(client)

        exports.px_noti:noti("Wygrałeś "..value.." PP!", client, "success")
    elseif(type == "kick")then
        exports.px_noti:noti("Tym razem się nie udało!", client, "success")
    elseif(type == "exp")then
        local value=math.random(50,100)
        local xp=getElementData(client, "user:reputation") or 0
        setElementData(client, "user:reputation", xp+value)

        exports.px_noti:noti("Wygrałeś "..value.." XP!", client, "success")
    elseif(type == "money")then
        local value=math.random(600,1000)
        givePlayerMoney(client, value)
        exports.px_noti:noti("Wygrałeś $"..value.."!", client, "success")
    end
end)

addEvent("dashboard.buyRandomElipse", true)
addEventHandler("dashboard.buyRandomElipse", resourceRoot, function(value, pp)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query("select premiumPoints from accounts where id=? limit 1", uid)
    if(r and #r == 1)then
        if(tonumber(r[1].premiumPoints) >= pp)then
            exports.px_noti:noti("Pomyślnie zakupiono "..value.." losowań.", client, "success")
            exports.px_connect:query("update accounts set premiumPoints=premiumPoints-?, randomElipse=randomElipse+? where id=? limit 1", pp, value, uid)
            updatePanel(client)
        else
            exports.px_noti:noti("Nie posiadasz odpowiedniej ilości PP.", client, "error")
        end
    end
end)

-- premium

local p_table={
    [71480]={api_index=1, cost=1.25, points=10},
    [72480]={api_index=2, cost=2.46, points=20},
    [73480]={api_index=3, cost=3.69, points=30},
    [74480]={api_index=4, cost=4.92, points=50},
    [75480]={api_index=5, cost=6.15, points=60},
    [76480]={api_index=6, cost=7.38, points=70},
    [79480]={api_index=7, cost=11.07, points=110},
    [91400]={api_index=8, cost=17.22, points=170},
    [91900]={api_index=9, cost=23.37, points=230},
    [92022]={api_index=10, cost=24.60, points=250},
    [92521]={api_index=11, cost=30.75, points=300},
}

function getPremium(json, error, player)
    if(not isElement(player))then
        --unlucky tego typu bęc
        return
    end

    if(error ~= 0)then return end

    local uid=getElementData(player, "user:uid")
    if(not uid)then return end

    local parsedResponse = fromJSON(json) or {}

    if(#parsedResponse == {}) then
        exports.px_noti:noti("Wystąpił błąd - #1", player, "error")
    else 
        if(parsedResponse.error)then
            if(parsedResponse.error == "invalid_code")then
                exports.px_noti:noti("Podany kod jest nieprawidłowy!", player, "error")
            elseif(parsedResponse.error == "no_connection")then
                exports.px_noti:noti("Brak połączenia z bramką płatności! #1", player, "error")
            elseif(parsedResponse.error == "no_info")then
                exports.px_noti:noti("Brak połączenia z bramką płatności! #2", player, "error")
            else
                exports.px_noti:noti(parsedResponse.error, player, "error")
            end
        else
            if(parsedResponse.success)then
                local amount = parsedResponse.amount;
                if(amount)then
                    exports.px_connect:query("update accounts set premiumPoints=premiumPoints+? where id=? limit 1", amount, uid)
                    exports.px_noti:noti("Pomyślnie zakupiłeś "..amount.." punktów premium.", player, "success")
                    updatePanel(player)
                else
                    exports.px_noti:noti("Nieprawidłowa odpowiedź z API, spróbuj ponownie później.", player, "error")
                end
            else
                exports.px_noti:noti("Brak połączenia z API, spróbuj ponownie później.", player, "error")
            end
        end
    end
end

addEvent("dashboard.buyPointsSMS", true)
addEventHandler("dashboard.buyPointsSMS", resourceRoot, function(code,number)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end
    
    local ppInfo = p_table[tonumber(number)];
    if(ppInfo)then
        --fetchRemote("https://pixelmta.pl/premiumApi/verifySms_server.php?smsOffer="..ppInfo.api_index.."&smsCode="..code, getPremium, "", false, client)
    end
end)

addEvent("dashboard.buyPremium", true)
addEventHandler("dashboard.buyPremium", resourceRoot, function(info)
    local uid=getElementData(client, "user:uid")
    if(not uid)then
        noti:noti("Nie znaleziono twojego konta!", client, "error")
        return 
    end

    local r=exports.px_connect:query("select premiumPoints from accounts where id=? limit 1", uid)
    if(r and #r == 1)then
        if(r[1].premiumPoints >= info.points)then
            if(info.name == "Konto gold")then
                exports.px_premium:giveGold(client, info.days)
            else
                exports.px_premium:givePremium(client, info.days)
            end

            exports.px_connect:query("update accounts set premiumPoints=premiumPoints-? where id=? limit 1", info.points, uid)

            exports.px_noti:noti("Pomyślnie zakupiłeś "..info.name.." na "..info.days.." dni za "..info.points.." punktów premium.", client, "success")

            if(info.vehsSlots and info.vehsSlots > 0)then
                local data=getElementData(client, "user:vehiclesSlots") or 2
                data=data+info.vehsSlots
                setElementData(client, "user:vehiclesSlots", data)
                
                exports.px_connect:query("update accounts set vehiclesSlots=? where id=? limit 1", data, uid)
                exports.px_noti:noti("Pomyślnie otrzymałeś dodatkowe sloty i posiadasz "..data.." slotów pojazdów.", client, "success")
            end

            updatePanel(client)
        else
            noti:noti("Nie posiadasz wystarczających funduszy.", client, "error")
        end
    else
        noti:noti("Nie znaleziono twojego konta!", client, "error")
    end
end)

addEvent("dashboard.buySlots", true)
addEventHandler("dashboard.buySlots", resourceRoot, function(info)
    local uid=getElementData(client, "user:uid")
    if(not uid)then
        noti:noti("Nie znaleziono twojego konta!", client, "error")
        return 
    end

    local r=exports.px_connect:query("select premiumPoints from accounts where id=? limit 1", uid)
    if(r and #r == 1)then
        if(r[1].premiumPoints >= info.points)then
            exports.px_connect:query("update accounts set premiumPoints=premiumPoints-? where id=? limit 1", info.points, uid)

            if(info.vehsSlots and info.vehsSlots > 0)then
                local data=getElementData(client, "user:vehiclesSlots") or 2
                data=data+info.vehsSlots
                setElementData(client, "user:vehiclesSlots", data)
                
                exports.px_connect:query("update accounts set vehiclesSlots=? where id=? limit 1", data, uid)
                exports.px_noti:noti("Pomyślnie otrzymałeś dodatkowe sloty i posiadasz "..data.." slotów pojazdów.", client, "success")
            end

            updatePanel(client)
        else
            noti:noti("Nie posiadasz wystarczających funduszy.", client, "error")
        end
    else
        noti:noti("Nie znaleziono twojego konta!", client, "error")
    end
end)

addEvent("dashboard.buyPoints", true)
addEventHandler("dashboard.buyPoints", resourceRoot, function(info)
    local uid=getElementData(client, "user:uid")
    if(not uid or not tonumber(info.cost))then return end

    local r=exports.px_connect:query("select id from misc_premiumShop where id=? limit 1", info.id)
    if(r and #r == 1)then
        if(info.uid == uid)then
            exports.px_connect:query("delete from misc_premiumShop where id=? limit 1", info.id)
            exports.px_connect:query("update accounts set premiumPoints=premiumPoints+? where id=? limit 1", info.points, uid)
            exports.px_noti:noti("Pomyślnie usunięto punkty premium z sprzedaży.", client, "success")

            updatePanel(client)
            return
        end

        info.cost=tonumber(info.cost)
        info.cost=math.floor(info.cost)

        if(getPlayerMoney(client) >= info.cost)then
            takePlayerMoney(client, info.cost)
            exports.px_connect:query("insert into logs_premiumShop (seller, buyer, amount, cost) VALUES(?,?,?,?)", info.uid, uid, info.points, info.cost)
            exports.px_connect:query("update accounts set premiumPoints=premiumPoints+? where id=? limit 1", info.points, uid)

            exports.px_connect:query("delete from misc_premiumShop where id=? limit 1", info.id)

            exports.px_noti:noti("Pomyślnie zakupiono "..info.points.." punktów premium za $"..info.cost..".", client, "success")

            local target=getPlayerFromName(info.login)
            if(target and getElementData(target, "user:uid"))then
                givePlayerMoney(target,info.cost)
            else
                exports.px_connect:query("update accounts set money=money+? where id=? limit 1", info.cost, info.uid)
            end

            updatePanel(client)
        else
            exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
        end
    else
        exports.px_noti:noti("Ogłoszenie jest już nieaktualnie.", client, "error")
    end
end)

addEvent("dashboard.insertSell", true)
addEventHandler("dashboard.insertSell", resourceRoot, function(points, money)
    local uid=getElementData(client, "user:uid")
    if(not uid or not tonumber(points) or not tonumber(money))then return end

    money=tonumber(money)
    money=math.floor(money)

    if(money < 100 or points < 1)then
        exports.px_noti:noti("Wprowadziłeś błędną wartość.", client, "error")
        return
    end

    if(money >= (100*points) and money < (200*points))then
        local slots=exports.px_connect:query("select uid from misc_premiumShop where uid=? limit 6", uid)
        if(slots and #slots >= 6)then
            exports.px_noti:noti("Maksymalnie możesz mieć 3 ogłoszenia na giełdzie.", client, "error")
            return
        end

        local r=exports.px_connect:query("select premiumPoints from accounts where id=? limit 1", uid)
        if(r and #r > 0 and r[1].premiumPoints >= points)then
            exports.px_connect:query("insert into misc_premiumShop (uid,login,points,cost) values(?,?,?,?)", uid, getPlayerName(client), points, money)
            exports.px_connect:query("update accounts set premiumPoints=premiumPoints-? where id=? limit 1", points, uid)

            exports.px_noti:noti("Pomyślnie wystawiono punkty premium na giełde.", client, "success")
        
            updatePanel(client)
        else
            exports.px_noti:noti("Nie posiadasz takiej ilości punktów premium.", client, "error")
        end
    else
        exports.px_noti:noti("Minimalna cena za punkt: $100. Maksymalna cena za punkt: $200.", client, "error")
    end
end)

-- exports

local settings_lists_1={
    [1]={
        ["wood_pc"]={name="Tryb dla słabych PC",id=1},
        ["voice_chat"]={name="Czat głosowy",id=2},
        ["vehicles_sounds"]={name="Dźwięki pojazdów",id=3},
        ["fps_counter"]={name="Licznik FPS",id=4},
        ["showed_hud"]={name="Ukryj HUD",id=5},
        ["premium_notis"]={name="Ukryj ogłoszenia",id=6},
        ["private_messages"]={name="Blokada prywatnych wiadomości",id=7},
        ["friends_invites"]={name="Blokada zaproszeń do znajomych",id=8},
        ["3dmusic"]={name="Wyłącz muzyke 3D",id=9},
    },

    [2]={
        ["PREMIUM_chat_off"]={name="Wyłącz czat PREMIUM",id=10},
        ["GOLD_chat_off"]={name="Wyłącz czat GOLD",id=11},

        ["nametag_distance"]={name="Większa widzialność nicków (-FPS)",id=12},
        ["street_map"]={name="Mapa z dzielnicami",id=13},
    },
}

local settings_lists_2={
    ["bloom"]={name="Bloom",id=14},
    ["detals_contrast"]={name="Ostrość detali",id=15},
    ["detals"]={name="Szczególność detali",id=16},
    ["blur"]={name="Rozmycie radialne",id=17},
    ["sky"]={name="Realistyczne niebo",id=18},
    ["distance"]={name="Wysoki dystans rysowania",id=19},
}

function getSettingState(player, name)
    local settingData=getElementData(player, "user:dash_settings")
    local settingBase=settings_lists_1[1][name] or settings_lists_1[2][name] or settings_lists_2[name]
    if(settingBase and settingData)then
        local settingID=settingBase.id
        local settingState=settingData[settingID]
        return tonumber(settingState) == 1
    end
    return false
end