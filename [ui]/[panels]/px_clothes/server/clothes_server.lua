--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent("clothes.accept", true)
addEventHandler("clothes.accept", resourceRoot, function(id, cost, rp)
    if(getElementModel(client) == id)then return end

    if(cost > 0)then
        if(getPlayerMoney(client) >= cost)then
            exports.px_noti:noti("Zakupiłeś skin (ID: "..id.."), za cene "..cost.."$", client, "success", false, "dashboard")
            setElementModel(client, id)
            exports.px_connect:query("update accounts set skin=? where id=?", id, getElementData(client, "user:uid"))

            if(not exports.px_achievements:isPlayerHaveAchievement(client, "Świetnie wyglądasz"))then
                exports.px_achievements:getAchievement(client, "Świetnie wyglądasz")
            end
        else
            exports.px_noti:noti("Brak wystarczających funduszy.", client, "errror", false, "dashboard")
        end
    else
        exports.px_noti:noti("Wziąłeś skin (ID: "..id..")", client, "success", false, "dashboard")
        setElementModel(client, id)
        exports.px_connect:query("update accounts set skin=? where id=?", id, getElementData(client, "user:uid"))

        if(not exports.px_achievements:isPlayerHaveAchievement(client, "Świetnie wyglądasz"))then
            exports.px_achievements:getAchievement(client, "Świetnie wyglądasz")
        end
    end
end)
