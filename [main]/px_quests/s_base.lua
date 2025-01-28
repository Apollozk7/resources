--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function updateQuest(player, name, value)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return end

    local data=getElementData(player, "user:dayQuest")
    if(data and data.name == name and not data.done)then
        data.progress=(data.progress or 0)+value

        if(data.progress >= data.value)then
            data.progress=data.value
            data.done=true
            
            exports.px_noti:noti("Pomyślnie ukończono zadanie dzienne: "..data.name..".", player, "success")
            
            local rnd=math.random(1,10)
            local pp=math.random(0,2)
            if(rnd == 1 or rnd == 3 or rnd == 6 or rnd == 8 or rnd == 10)then
                local xp=math.random(30,200)
                local exp=getElementData(player, "user:exp") or 0
                setElementData(player, "user:exp", exp+xp)
                exports.px_noti:noti("Otrzymujesz "..xp.." EXP!", player, "success")
            elseif((rnd == 2 or rnd == 5 or rnd == 7) and pp > 0)then
                exports.px_connect:query("update accounts set premiumPoints=premiumPoints+? where id=?", pp, uid)
                exports.px_noti:noti("Otrzymujesz "..pp.." punktów premium!", player, "success")
            else
                local money=math.random(100,600)
                givePlayerMoney(player, money)
                exports.px_noti:noti("Otrzymujesz $"..money.."!", player, "success")
            end
        end

        setElementData(player, "user:dayQuest", data)
        exports.px_connect:query("update accounts set quest_progress=? where id=?", data.progress, uid)
    end
end