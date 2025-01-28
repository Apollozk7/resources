--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent("take.money", true)
addEventHandler("take.money", resourceRoot, function(veh, money, time, time_2, id)
    if(getPlayerMoney(client) >= money)then
        exports.px_noti:noti("Rozpoczęto mycie, koszt: "..money.."$, czas trwania: "..time..".", client, "success")
        takePlayerMoney(client, money)
        triggerClientEvent("create.water", resourceRoot, veh, client, time_2, id)

        exports.px_quests:updateQuest(client, "Umyj swój pojazd w myjni", 1)
    else
        exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
    end
end)

addEvent("destroy.water", true)
addEventHandler("destroy.water", resourceRoot, function(veh)
    triggerClientEvent("destroy.water", resourceRoot, veh)
end)