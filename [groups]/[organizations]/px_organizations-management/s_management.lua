--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function loadClubAvatarFromIPS(player, avatar)
    triggerClientEvent(player, "load.avatar", resourceRoot, avatar)
end

function openManagementPanel(player)
    player=client or player

    local uid=getElementData(player, "user:uid")
    if(not uid)then return false end

    local org=getElementData(player, "user:organization")
    if(not org)then return false end 

    local r=exports.px_connect:query("select * from groups_organizations_players where uid=? and org=? limit 1", uid, org) -- czy ja jestem
    if(r and #r > 0)then
        exports.px_organizations:setOrganizationTasks(org)

        local users=exports.px_connect:query("select *, (accounts.lastlogin<now()) as not_today from groups_organizations_players left join accounts on accounts.id=groups_organizations_players.uid where org=?", org) -- pracownicy
        local f_info=exports.px_connect:query("select * from groups_organizations where org=? limit 1", org) -- informacje o organizacji
        local vehs=exports.px_connect:query("select * from vehicles where organization=?", org) -- pojazdy org
        local task,tasks=exports.px_organizations:getOrganizationTasks(org) -- zadania dzienne
        local upgrades=exports.px_organizations:getOrganizationUpgrades(org) or {} -- ulepszenia
        local lvl_up=exports.px_organizations:getOrganizationLevelUP() or 0 -- lvl up
        task,tasks=task or {},tasks or {}

        triggerClientEvent(player, "update.management.panel", resourceRoot, r[1], users, f_info[1], online, vehs, task, tasks, upgrades, lvl_up)

        return true
    end
    return false
end
addEvent("openManagementPanel", true)
addEventHandler("openManagementPanel", resourceRoot, openManagementPanel)

function isPlayerHaveAccess(player,myRank,rank,ranks)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return end

    local r=exports.px_connect:query("select access from groups_organizations_players where uid=? limit 1", uid)
    if(not r or (r and #r < 1))then
        exports.px_noti:noti("Nie posiadasz uprawnień. #1", player, "error")
        return false
    end

    local ID={myRank=0,rank=0}
    for i,v in pairs(ranks) do
        if(v.name == myRank)then
            ID.myRank=i
        end

        if(v.name == rank)then
            ID.rank=i
        end
    end

    if(r[1].access == 1 and ID.myRank ~= 1)then
        ID.myRank=2
    end

    if(ID.myRank > 3)then
        exports.px_noti:noti("Nie posiadasz uprawnień. #2", player, "error")
        return false
    end

    if(ID.rank == 1)then
        exports.px_noti:noti("Nie posiadasz uprawnień. #3", player, "error")
        return false
    end

    if(ID.myRank ~= 1 and ID.myRank >= ID.rank)then
        exports.px_noti:noti("Nie posiadasz uprawnień. #4", player, "error")
        return false
    end
    
    return true
end

addEvent("add.user", true)
addEventHandler("add.user", resourceRoot, function(login, tag)
    local player=exports.px_core:findPlayer(login)
    if(player)then
        local uid=getElementData(player, "user:uid")
        if(not uid)then return end

        local myUID=getElementData(client, "user:uid")
        if(not myUID)then return end

        local r=exports.px_connect:query("select access from groups_organizations_players where uid=? limit 1", myUID)
        local access=false
        if(r and #r == 1)then
            access=r[1].access == 1
        end

        local f=exports.px_connect:query("select * from groups_organizations where tag=? limit 1", tag)
        if(f and #f > 0)then
            local max=exports.px_organizations:isOrganizationHaveUpgrade(f[1].org, "Bez limitowe sloty na graczy") and 0 or exports.px_organizations:isOrganizationHaveUpgrade(f[1].org, "50 slotów na graczy") and 50 or exports.px_organizations:isOrganizationHaveUpgrade(f[1].org, "20 slotów na graczy") and 20 or 10
            local players=exports.px_connect:query("select * from groups_organizations_players where org=?", f[1].org)
            if(max == 0 or (#players+1 <= max))then
                local ranks=fromJSON(f[1].ranks) or {}
                local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
                if((rank == ranks[1].name or rank == ranks[2].name or rank == ranks[3].name or access))then
                    local r=exports.px_connect:query("select orgInvite from accounts where id=? limit 1", uid)
                    if(r and #r == 1)then
                        local orgInvite=fromJSON(r[1].orgInvite) or {}
                        if(orgInvite.name)then
                            exports.px_noti:noti("Ten gracz otrzymał już zaproszenie do organizacji.", client, "error")
                        else
                            orgInvite={name=f[1].org, target=myUID}
                            exports.px_connect:query("update accounts set orgInvite=? where id=? limit 1", toJSON(orgInvite), uid)

                            exports.px_noti:noti("Pomyślnie wysłano zaproszenie do organizacji dla "..getPlayerName(player), client, "success")
                            exports.px_noti:noti("Otrzymałeś zaproszenie do organizacji, więcej informacji znajdziesz pod F1.", player, "info")
                        end
                    end
                else
                    exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
                end
            else
                exports.px_noti:noti("W organizacji może być maksymalnie "..max.." graczy, aby to zwiększyć zakup ulepszenie.", client, "error")
            end
        end
    else
        exports.px_noti:noti("Nie znaleziono podanego gracza.", client, "error")
    end
end)

addEvent("leave.org", true)
addEventHandler("leave.org", resourceRoot, function()
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local org=getElementData(client, "user:organization")
    if(not org)then return end

    local f=exports.px_connect:query("select * from groups_organizations where org=? limit 1", org)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
        if(rank ~= ranks[1].name)then
            local q=exports.px_connect:query("delete from groups_organizations_players where uid=?", uid)
            if(q)then
                exports.px_organizations:ipsRemovePlayer(client, f[1].org)

                exports.px_noti:noti("Pomyślnie odszedłeś z organizacji.", client, "success")

                exports.px_connect:query("update vehicles set organization=? where owner=?", "", uid)

                setElementData(client, "user:organization", false)
                setElementData(client, "user:organization_tag", false)
                setElementData(client, "user:organization_rank", false)
            end
        else
            local users=exports.px_connect:query("select * from groups_organizations_players where org=?", org)
            if(users and #users == 1)then
                exports.px_connect:query("delete from groups_organizations_players where uid=?", uid)
                exports.px_connect:query("delete from groups_organizations where org=?", org)
                exports.px_connect:query("update houses set organization=0 where organization=?", org)
                exports.px_connect:query("update vehicles set organization=? where organization=?", "", org)
                exports.px_connect:query("delete from groups_vehicles where owner=?", org)

                --exports.px_organizations:ipsDestroyClub(org)

                exports.px_noti:noti("Pomyślnie usunąłeś organizacje.", client, "success")

                setElementData(client, "user:organization", false)
                setElementData(client, "user:organization_tag", false)
                setElementData(client, "user:organization_rank", false)
            else
                exports.px_noti:noti("Nie możesz opuścić organizacji, będąc jej właścicielem.", client, "error")
            end
        end
    end
end)

addEvent("remove.user", true)
addEventHandler("remove.user", resourceRoot, function(info)
    if(not info)then return end

    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    local f=exports.px_connect:query("select * from groups_organizations where org=? limit 1", info.org)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
        if(isPlayerHaveAccess(client,rank,info.rank,ranks))then
            local q=exports.px_connect:query("delete from groups_organizations_players where uid=?", info.uid)
            if(q)then
                exports.px_connect:query("update vehicles set organization=? where owner=?", "", uid)

                exports.px_organizations:ipsRemovePlayer(info.login, info.org)
                exports.px_noti:noti("Pomyślnie wyrzucono gracza "..info.login.." z organizacji.", client, "success")
                openManagementPanel(client)

                local player=getPlayerFromName(info.login)
                if(player and isElement(player))then
                    setElementData(player, "user:organization", false)
                    setElementData(player, "user:organization_tag", false)
                    setElementData(player, "user:organization_rank", false)
                end
            end
        end 
    end
end)

addEvent("update.user.access", true)
addEventHandler("update.user.access", resourceRoot, function(info)
    if(not info)then return end

    local f=exports.px_connect:query("select * from groups_organizations where org=? limit 1", info.org)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
        if(isPlayerHaveAccess(client,rank,info.rank,ranks))then
            local r=exports.px_connect:query("select access from groups_organizations_players where uid=? limit 1", info.uid)
            if(r and #r == 1)then
                exports.px_connect:query("update groups_organizations_players set access=? where uid=? limit 1", r[1].access == 1 and 0 or 1, info.uid)
                    
                exports.px_noti:noti("Pomyślnie zmieniono uprawnienia gracza "..info.login..".", client, "success")

                openManagementPanel(client)
            end
        end
    end
end)

addEvent("rank.up.user", true)
addEventHandler("rank.up.user", resourceRoot, function(info)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    if(not info)then return end

    if(info.uid == uid)then
        exports.px_noti:noti("Nie możesz awansować samego siebie.", client, "error")
        return
    end

    local f=exports.px_connect:query("select * from groups_organizations where org=? limit 1", info.org)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
        if(isPlayerHaveAccess(client,rank,info.rank,ranks))then
            local index=#ranks+1

            for i,v in pairs(ranks) do
                if(v.name == info.rank)then
                    index=i
                end
            end

            index=index-1

            if(not ranks[index])then
                index=#ranks
            end

            if(isPlayerHaveAccess(client,rank,ranks[index].name,ranks))then
                exports.px_connect:query("update groups_organizations_players set `rank`=? where uid=?", ranks[index].name, info.uid)
                
                exports.px_noti:noti("Pomyślnie awansowano gracza "..info.login..", na: "..ranks[index].name..".", client, "success")

                openManagementPanel(client)

                local target=getPlayerFromName(info.login)
                if(target and isElement(target) and getElementData(target, 'user:uid'))then
                    setElementData(target, "user:organization_rank", ranks[index].name)
                end
            end
        end
    end
end)

addEvent("rank.down.user", true)
addEventHandler("rank.down.user", resourceRoot, function(info)
    if(not info)then return end

    local f=exports.px_connect:query("select * from groups_organizations where org=? limit 1", info.org)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
        if(isPlayerHaveAccess(client,rank,info.rank,ranks))then
            local index=0
            for i,v in pairs(ranks) do
                if(v.name == info.rank)then
                    index=i
                end
            end

            index=index+1

            if(not ranks[index])then
                index=#ranks
            end

            if(isPlayerHaveAccess(client,rank,ranks[index].name,ranks))then
                exports.px_connect:query("update groups_organizations_players set `rank`=? where uid=?", ranks[index].name, info.uid)
                
                exports.px_noti:noti("Pomyślnie zdegradowano gracza "..info.login..", na: "..ranks[index].name..".", client, "success")

                openManagementPanel(client)

                local target=getPlayerFromName(info.login)
                if(target and isElement(target) and getElementData(target, 'user:uid'))then
                    setElementData(target, "user:organization_rank", ranks[index].name)
                end
            end
        end
    end
end)

addEvent("remove.rank", true)
addEventHandler("remove.rank", resourceRoot, function(selected, tag)
    local q=exports.px_connect:query("select * from groups_organizations where tag=?", tag)
    if(q and #q > 0)then
        local ranks=fromJSON(q[1].ranks) or {}
        if(ranks[selected])then
            if(#ranks > 3)then
                local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
                if(rank == ranks[1].name)then
                    table.remove(ranks,selected)

                    exports.px_connect:query("update groups_organizations set ranks=? where tag=?", toJSON(ranks), tag)
        
                    openManagementPanel(client)

                    exports.px_noti:noti("Pomyślnie usunięto rangę.", client, "success")
                else
                    exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
                end
            else
                exports.px_noti:noti("W organizacji muszą być minimum 3 rangi.", client, "error")
            end
        end
    end
end)

addEvent("add.rank", true)
addEventHandler("add.rank", resourceRoot, function(tag)
    local q=exports.px_connect:query("select * from groups_organizations where tag=?", tag)
    if(q and #q > 0)then
        local ranks=fromJSON(q[1].ranks) or {}
        local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
        if(rank and ranks[1] and rank == ranks[1].name)then
            local ranks=fromJSON(q[1].ranks) or {}
            ranks[#ranks+1]={name="Nowa ranga", money=0}

            exports.px_connect:query("update groups_organizations set ranks=? where tag=?", toJSON(ranks), tag)

            openManagementPanel(client)

            exports.px_noti:noti("Pomyślnie stworzono rangę.", client, "success")
        else
            exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
        end
    end
end)

local letters={
    'q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m','1','2','3','4','5','6','7','8','9','0','-'
}

local getLetter=function(text)
    local next=0
    for i=1,#text do
        local v=utf8.sub(text,i,i)
        for _,key in pairs(letters) do
            if(utf8.lower(v) == utf8.lower(key))then
                next=next+1
                break
            end
        end
    end
    return next == #text
end

addEvent("edit.rank.name", true)
addEventHandler("edit.rank.name", resourceRoot, function(selected, name, tag)
    if(getLetter(name))then
        local q=exports.px_connect:query("select * from groups_organizations where tag=?", tag)
        if(q and #q > 0)then
            local ranks=fromJSON(q[1].ranks) or {}
            if(ranks[selected])then
                local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
                if(rank == ranks[1].name)then
                    local block=false
                    for i,v in pairs(ranks) do
                        if(v.name == name)then
                            block=true
                            break
                        end
                    end

                    if(not block)then
                        local last=ranks[selected].name

                        ranks[selected].name=name

                        exports.px_connect:query("update groups_organizations set ranks=? where tag=? limit 1", toJSON(ranks), tag)
                        exports.px_connect:query("update groups_organizations_players set `rank`=? where `rank`=? and org=?", name, last, q[1].org)

                        openManagementPanel(client)

                        exports.px_noti:noti("Pomyślnie zaaktualizowano nazwę.", client, "success")
                    else
                        exports.px_noti:noti("Taka ranga już istnieje.", client, "error")
                    end
                else
                    exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
                end
            end
        end
    else
        exports.px_noti:noti("Wprowadź prawidłową nazwe.", client, "error")
    end
end)

addEvent("rank.up.vehicle", true)
addEventHandler("rank.up.vehicle", resourceRoot, function(org, veh)
    if(not org or not veh or (veh and not isElement(veh)))then return end

    local f=exports.px_connect:query("select * from groups_organizations where org=? limit 1", org)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
        local id=getElementData(veh, "vehicle:id")
        local g_id=getElementData(veh, "vehicle:group_id")
        if(id)then
            -- prywatne
            local r=exports.px_connect:query("select * from vehicles where id=? limit 1", id)
            if(r and #r > 0)then
                if((rank == ranks[1].name or rank == ranks[2].name))then
                    local index=r[1].orgRank-1
                    if(not ranks[index])then
                        index=#ranks
                    end
                    
                    exports.px_connect:query("update vehicles set orgRank=? where id=?", index, id)
            
                    exports.px_noti:noti("Pomyślnie awansowano pojazd "..getVehicleName(veh)..", na: "..ranks[index].name..".", client, "success")
        
                    openManagementPanel(client)

                    setElementData(veh, "vehicle:orgRank", index)
                end
            end
        elseif(g_id)then
            -- organizacyjne
            local r=exports.px_connect:query("select * from groups_vehicles where id=? limit 1", g_id)
            if(r and #r > 0)then
                if((rank == ranks[1].name or rank == ranks[2].name))then
                    if(index == 1 and rank == ranks[2].name)then
                        exports.px_noti:noti("Nie możesz edytować rangi "..ranks[1].name, client, "error")
                        return
                    end

                    local index=r[1].orgRank-1
                    if(not ranks[index])then
                        index=#ranks
                    end
                    
                    exports.px_connect:query("update groups_vehicles set orgRank=? where id=?", index, g_id)
            
                    exports.px_noti:noti("Pomyślnie awansowano pojazd "..getVehicleName(veh)..", na: "..ranks[index].name..".", client, "success")
        
                    openManagementPanel(client)

                    setElementData(veh, "vehicle:orgRank", index)
                end
            end
        end
    end
end)

addEvent("rank.down.vehicle", true)
addEventHandler("rank.down.vehicle", resourceRoot, function(org, veh)
    if(not org or not veh or (veh and not isElement(veh)))then return end

    local f=exports.px_connect:query("select * from groups_organizations where org=? limit 1", org)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
        local id=getElementData(veh, "vehicle:id")
        local g_id=getElementData(veh, "vehicle:group_id")
        if(id)then
            -- prywatne
            local r=exports.px_connect:query("select * from vehicles where id=? limit 1", id)
            if(r and #r > 0)then
                if((rank == ranks[1].name or rank == ranks[2].name))then
                    local index=r[1].orgRank+1
                    if(not ranks[index])then
                        index=#ranks
                    end
                    
                    exports.px_connect:query("update vehicles set orgRank=? where id=?", index, id)
            
                    exports.px_noti:noti("Pomyślnie zdegradowałeś pojazd "..getVehicleName(veh)..", na: "..ranks[index].name..".", client, "success")
        
                    openManagementPanel(client)

                    setElementData(veh, "vehicle:orgRank", index)
                end
            end
        elseif(g_id)then
            -- organizacyjne
            local r=exports.px_connect:query("select * from groups_vehicles where id=? limit 1", g_id)
            if(r and #r > 0)then
                if((rank == ranks[1].name or rank == ranks[2].name))then
                    local index=r[1].orgRank+1
                    if(not ranks[index])then
                        index=#ranks
                    end
                    
                    exports.px_connect:query("update groups_vehicles set orgRank=? where id=?", index, g_id)
            
                    exports.px_noti:noti("Pomyślnie zdegradowałeś pojazd "..getVehicleName(veh)..", na: "..ranks[index].name..".", client, "success")
        
                    openManagementPanel(client)

                    setElementData(veh, "vehicle:orgRank", index)
                end
            end
        end
    end
end)

addEvent("buy.upgrade", true)
addEventHandler("buy.upgrade", resourceRoot, function(info, org)
    if(not info or not org)then return end

    local r=exports.px_connect:query("select * from groups_organizations where org=? limit 1", org)
    if(r and #r == 1)then
        local ranks=fromJSON(r[1].ranks) or {}
        local rank=exports.px_organizations:getPlayerRank(getPlayerName(client))
        if(rank == ranks[1].name)then
            local upgrades=fromJSON(r[1].upgrades) or {}
            if(tonumber(r[1].money) >= tonumber(info.cost))then
                if(upgrades[info.name])then return end

                upgrades[info.name]=true
                exports.px_connect:query("update groups_organizations set money=money-?, upgrades=? where org=? limit 1", info.cost, toJSON(upgrades), org)
                openManagementPanel(client)

                exports.px_noti:noti("Pomyślnie zakupiono ulepszenie "..info.name.." za kwotę $"..formatNumber(math.floor(info.cost))..".", client, "success")
            else
                exports.px_noti:noti("Organizacja nie dysponuje takimi funduszami.", client, "error")
            end
        else
            exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
        end
    end
end)

-- useful

function formatNumber(number, sep)
	assert(type(tonumber(number))=="number", "Bad argument @'formatNumber' [Expected number at argument 1 got "..type(number).."]")
	assert(not sep or type(sep)=="string", "Bad argument @'formatNumber' [Expected string at argument 2 got "..type(sep).."]")
	return tostring(number):reverse():gsub("%d%d%d","%1%"..(sep and #sep>0 and sep or ",")):reverse()
end