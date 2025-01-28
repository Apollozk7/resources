--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function createMarkers()
    local r=exports.px_connect:query("select * from groups_fractions")
    for i,v in pairs(r) do
        local pos=split(v.panel, ",")
        local marker=createMarker(pos[1], pos[2], pos[3]-0.98, "cylinder", 1.2, 200, 50, 0)

        setElementData(marker, "text", {text=v.tag,desc="Panel zarządzania"})
        setElementData(marker, "icon", ":px_factions/assets/images/markerStart.png")
        setElementData(marker, "info", v.tag, false)

        setElementDimension(marker, v.dim)
    end
end
createMarkers()

function openManagementPanel(player, fraction)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return false end

    local r=exports.px_connect:query("select * from groups_fractions_players where uid=? and fraction=? limit 1", uid, fraction) -- czy ja jestem
    if(r and #r > 0)then
        local users=exports.px_connect:query("select * from groups_fractions_players left join accounts on accounts.id=groups_fractions_players.uid where fraction=?", fraction) -- pracownicy
        local f_info=exports.px_connect:query("select * from groups_fractions where tag=? limit 1", fraction) -- informacje o frakcji

        -- online na sluzbie
        local online=0
        for i,v in pairs(users) do
            local p=getPlayerFromName(v.login)
            if(p and isElement(p) and getElementData(p, "user:faction") == fraction)then
                online=online+1
            end
        end
        --

        -- najaktywniesi
        local active=exports.px_connect:query("select * from groups_fractions_players where fraction=? order by week_time desc limit 7", fraction)
        --

        triggerClientEvent(player, "open.management.panel", resourceRoot, r[1], users, f_info[1], online, active)

        return true
    end
    return false
end

function updateManagementPanel(player)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return false end

    local r=exports.px_connect:query("select * from groups_fractions_players where uid=? limit 1", uid)
    if(r and #r > 0)then
        local users=exports.px_connect:query("select * from groups_fractions_players left join accounts on accounts.id=groups_fractions_players.uid where fraction=?", r[1].fraction)
        local f_info=exports.px_connect:query("select * from groups_fractions where tag=? limit 1", r[1].fraction)

        -- online na sluzbie
        local online=0
        for i,v in pairs(users) do
            local p=getPlayerFromName(v.login)
            if(p and isElement(p) and getElementData(p, "user:faction") == r[1].fraction)then
                online=online+1
            end
        end
        --

        -- najaktywniesi
        local active=exports.px_connect:query("select * from groups_fractions_players where fraction=? order by week_time desc limit 7", r[1].fraction)
        --

        triggerClientEvent(player, "open.management.panel", resourceRoot, r[1], users, f_info[1], online, active)

        return true
    end
    return false
end

function isPlayerHaveAccess(player,myRank,rank,ranks)
    local ID={myRank=0,rank=0}
    for i,v in pairs(ranks) do
        if(v.name == myRank)then
            ID.myRank=i
        end

        if(v.name == rank)then
            ID.rank=i
        end
    end

    if(ID.myRank > 3)then
        exports.px_noti:noti("Nie posiadasz uprawnień. #1", player, "error")
        return false
    end

    if(ID.rank == 1)then
        exports.px_noti:noti("Nie posiadasz uprawnień. #2", player, "error")
        return false
    end

    if(ID.myRank ~= 1 and ID.myRank > ID.rank)then
        exports.px_noti:noti("Nie posiadasz uprawnień. #3", player, "error")
        return false
    end
    
    return true
end

addEvent("update.user.access", true)
addEventHandler("update.user.access", resourceRoot, function(update)
    local r=exports.px_connect:query("select * from groups_fractions_players where uid=? limit 1", update.uid)
    if(r and #r > 0)then
        local f=exports.px_connect:query("select * from groups_fractions where tag=? limit 1", r[1].fraction)
        if(f and #f > 0)then
            local ranks=fromJSON(f[1].ranks) or {}
            local rank=exports.px_factions:getPlayerRank(getPlayerName(client), r[1].fraction)
            local t_rank=exports.px_factions:getPlayerRank(update.login, r[1].fraction)
            if(isPlayerHaveAccess(client,rank,t_rank,ranks))then
                local access=fromJSON(r[1].access) or {}
                access[update.access]=update.check
                exports.px_connect:query("update groups_fractions_players set access=? where uid=?", toJSON(access), update.uid)
                updateManagementPanel(client)
            end
        end
    end
end)

addEvent("update.user.roles", true)
addEventHandler("update.user.roles", resourceRoot, function(update)
    local r=exports.px_connect:query("select * from groups_fractions_players where uid=? limit 1", update.uid)
    if(r and #r > 0)then
        local f=exports.px_connect:query("select * from groups_fractions where tag=? limit 1", r[1].fraction)
        if(f and #f > 0)then
            local ranks=fromJSON(f[1].ranks) or {}
            local rank=exports.px_factions:getPlayerRank(getPlayerName(client), r[1].fraction)
            local t_rank=exports.px_factions:getPlayerRank(update.login, r[1].fraction)
            if(isPlayerHaveAccess(client,rank,t_rank,ranks))then    
                local roles=fromJSON(r[1].roles) or {}
                roles[update.roles]=update.check
                exports.px_connect:query("update groups_fractions_players set roles=? where uid=?", toJSON(roles), update.uid)
                updateManagementPanel(client)
            end
        end
    end
end)

addEvent("add.user", true)
addEventHandler("add.user", resourceRoot, function(login, tag)
    local player=exports.px_core:findPlayer(login)
    if(player)then
        local uid=getElementData(player, "user:uid")
        if(not uid)then return end

        local f=exports.px_connect:query("select * from groups_fractions where tag=? limit 1", tag)
        if(f and #f > 0)then
            local ranks=fromJSON(f[1].ranks) or {}
            local rank=exports.px_factions:getPlayerRank(getPlayerName(client), tag)
            if((rank == ranks[1].name or rank == ranks[2].name or rank == ranks[3].name))then
                local q=exports.px_connect:query("insert into groups_fractions_players (uid,login,fraction,`rank`,added) values(?,?,?,?,now())", uid, getPlayerName(player), tag, ranks[#ranks].name)
                if(q)then
                    exports.px_noti:noti("Pomyślnie dodano gracza "..getPlayerName(player).." do frakcji.", client, "success")
                    exports.px_noti:noti("Zostałeś dodany do frakcji "..tag..".", player, "success")
                    updateManagementPanel(client)
                end
            end
        end
    else
        exports.px_noti:noti("Nie znaleziono podanego gracza.", client, "error")
    end
end)

addEvent("remove.user", true)
addEventHandler("remove.user", resourceRoot, function(info)
    if(not info)then return end

    local f=exports.px_connect:query("select * from groups_fractions where tag=? limit 1", info.fraction)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_factions:getPlayerRank(getPlayerName(client), info.fraction)
        if(isPlayerHaveAccess(client,rank,info.rank,ranks))then
            local q=exports.px_connect:query("delete from groups_fractions_players where uid=?", info.uid)
            if(q)then
                exports.px_noti:noti("Pomyślnie wyrzucono gracza "..info.login.." z frakcji.", client, "success")
                updateManagementPanel(client)
            end
        end 
    end
end)

addEvent("rank.up.user", true)
addEventHandler("rank.up.user", resourceRoot, function(info)
    if(not info)then return end

    local f=exports.px_connect:query("select * from groups_fractions where tag=? limit 1", info.fraction)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_factions:getPlayerRank(getPlayerName(client), info.fraction)
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
                exports.px_connect:query("update groups_fractions_players set `rank`=? where uid=?", ranks[index].name, info.uid)
                
                exports.px_noti:noti("Pomyślnie awansowano gracza "..info.login..", na: "..ranks[index].name..".", client, "success")

                updateManagementPanel(client)
            end
        end
    end
end)

addEvent("rank.down.user", true)
addEventHandler("rank.down.user", resourceRoot, function(info)
    if(not info)then return end

    local f=exports.px_connect:query("select * from groups_fractions where tag=? limit 1", info.fraction)
    if(f and #f > 0)then
        local ranks=fromJSON(f[1].ranks) or {}
        local rank=exports.px_factions:getPlayerRank(getPlayerName(client), info.fraction)
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
                exports.px_connect:query("update groups_fractions_players set `rank`=? where uid=?", ranks[index].name, info.uid)
                
                exports.px_noti:noti("Pomyślnie zdegradowano gracza "..info.login..", na: "..ranks[index].name..".", client, "success")

                updateManagementPanel(client)
            end
        end
    end
end)

addEvent("remove.rank", true)
addEventHandler("remove.rank", resourceRoot, function(selected, tag)
    local q=exports.px_connect:query("select * from groups_fractions where tag=?", tag)
    if(q and #q > 0)then
        local ranks=fromJSON(q[1].ranks) or {}
        if(ranks[selected])then
            if(#ranks > 3)then
                local rank=exports.px_factions:getPlayerRank(getPlayerName(client), tag)
                if(rank == ranks[1].name)then
                    table.remove(ranks,selected)

                    exports.px_connect:query("update groups_fractions set ranks=? where tag=?", toJSON(ranks), tag)
        
                    updateManagementPanel(client)

                    exports.px_noti:noti("Pomyślnie usunięto rangę.", client, "success")
                else
                    exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
                end
            else
                exports.px_noti:noti("W frakcji muszą być minimum 3 rangi.", client, "error")
            end
        end
    end
end)

addEvent("add.rank", true)
addEventHandler("add.rank", resourceRoot, function(tag)
    local q=exports.px_connect:query("select * from groups_fractions where tag=?", tag)
    if(q and #q > 0)then
        local ranks=fromJSON(q[1].ranks) or {}
        local rank=exports.px_factions:getPlayerRank(getPlayerName(client), tag)
        if(rank == ranks[1].name)then
            local ranks=fromJSON(q[1].ranks) or {}
            ranks[#ranks+1]={name="Nowa ranga", money=0}

            exports.px_connect:query("update groups_fractions set ranks=? where tag=?", toJSON(ranks), tag)

            updateManagementPanel(client)

            exports.px_noti:noti("Pomyślnie stworzono rangę.", client, "success")
        else
            exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
        end
    end
end)

addEvent("edit.rank.name", true)
addEventHandler("edit.rank.name", resourceRoot, function(selected, name, tag)
    local q=exports.px_connect:query("select * from groups_fractions where tag=?", tag)
    if(q and #q > 0)then
        local ranks=fromJSON(q[1].ranks) or {}
        if(ranks[selected])then
            local rank=exports.px_factions:getPlayerRank(getPlayerName(client), tag)
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

                    exports.px_connect:query("update groups_fractions set ranks=? where tag=?", toJSON(ranks), tag)
                    exports.px_connect:query("update groups_fractions_players set `rank`=? where `rank`=? and fraction=?", name, last, tag)

                    updateManagementPanel(client)

                    exports.px_noti:noti("Pomyślnie zaaktualizowano nazwę.", client, "success")
                else
                    exports.px_noti:noti("Taka ranga już istnieje.", client, "error")
                end
            else
                exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
            end
        end
    end
end)

addEvent("edit.rank.money", true)
addEventHandler("edit.rank.money", resourceRoot, function(selected, money, tag)
    money=tonumber(money)
    money=math.floor(money)

    local q=exports.px_connect:query("select * from groups_fractions where tag=? limit 1", tag)
    if(q and #q > 0)then
        local ranks=fromJSON(q[1].ranks) or {}
        if(ranks[selected] and tonumber(money) and money > 0 and money <= 9500)then
            local rank=exports.px_factions:getPlayerRank(getPlayerName(client), tag)
            if(rank == ranks[1].name)then
                ranks[selected].money=money

                exports.px_connect:query("update groups_fractions set ranks=? where tag=?", toJSON(ranks), tag)

                updateManagementPanel(client)

                exports.px_noti:noti("Pomyślnie zaaktualizowano wypłatę.", client, "success")
            else
                exports.px_noti:noti("Nie posiadasz uprawnień.", client, "error")
            end
        end
    end
end)

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local data=getElementData(source, "info")
        local tag=exports.px_factions:isPlayerInFaction(getPlayerName(hit), data)
        if(data and tag)then
            if(getElementData(hit, "user:faction") == data)then
                openManagementPanel(hit,tag)
            else
                exports.px_noti:noti("Najpierw wejdź na służbę!", hit, "error")
            end
        else
            exports.px_noti:noti("Nie należysz do frakcji "..data..".", hit, "error")
        end
    end
end)

-- zresetuj tygodniowki :x
function reload()
    local q=exports.px_connect:query("select week_date,id,tag from groups_fractions where week_date<now()")
    for i,v in pairs(q) do
        exports.px_connect:query("update groups_fractions_players set week_time=0 where fraction=?", v.tag)
        exports.px_connect:query("update groups_fractions set week_date=now()+interval 7 day where id=? limit 1", v.id)
    end
end
setTimer(function()
    reload()
end, 60000, 0)
reload()