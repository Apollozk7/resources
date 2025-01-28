--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent("hands.send.offer", true)
addEventHandler("hands.send.offer", resourceRoot, function(target)
    if(target and isElement(target))then
        exports.px_noti:noti("Pomyślnie wysłano propozycję siłowania się do gracza "..getPlayerName(target), client, "success")
        exports.px_noti:noti("Otrzymałeś ofertę siłowania się od "..getPlayerName(client)..", kliknij 'K' aby zaakceptować, lub 'X' aby odrzucić. Oferta wygaśnie za 30s.", target, "info")

        triggerClientEvent(target, "hands.offer", resourceRoot, client)
    end
end)

addEvent("start.hands", true)
addEventHandler("start.hands", resourceRoot, function(target, cancel)
    if(target and isElement(target))then
        if(not cancel)then
            triggerClientEvent(target, "hands.send.offer", resourceRoot, client, true)
            triggerClientEvent(client, "hands.send.offer", resourceRoot, target)
        else
            exports.px_noti:noti(getPlayerName(client).." odrzucił ofertę siłowania się.", target, "info")
        end
    end
end)

addEvent("hands.cancelOffer", true)
addEventHandler("hands.cancelOffer", resourceRoot, function(target)
    if(target and isElement(target))then
        triggerClientEvent(target, "hands.cancelOffer", resourceRoot, client)
    end
end)

addEvent("hands.acceptOffer", true)
addEventHandler("hands.acceptOffer", resourceRoot, function(target)
    if(target and isElement(target))then
        triggerClientEvent(target, "hands.acceptOffer", resourceRoot, client)
    end
end)

addEvent("hands.win", true)
addEventHandler("hands.win", resourceRoot, function(tbl)
    if(tbl)then
        if(isElement(tbl.lose.player) and isElement(tbl.win.player))then
            exports.px_quests:updateQuest(tbl.lose.player, "Zagraj ze znajomym na rękę", 1)
            exports.px_quests:updateQuest(tbl.win.player, "Zagraj ze znajomym na rękę", 1)

            if(tbl.win.money > 0)then
                if(getPlayerMoney(tbl.lose.player) >= tbl.win.money)then
                    takePlayerMoney(tbl.lose.player, tbl.win.money)
                    givePlayerMoney(tbl.win.player, tbl.win.money)

                    exports.px_discord:sendDiscordLogs("[SILOWANIE] Wygrana z "..getPlayerName(tbl.lose.player).." dostal: $"..tbl.win.money, "hajs", tbl.win.player)
                    exports.px_discord:sendDiscordLogs("[SILOWANIE] Przegrana z "..getPlayerName(tbl.win.player).." zabrano: $"..tbl.win.money, "hajs", tbl.lose.player)

                    exports.px_noti:noti("Wygrałeś pojedynek z graczem "..getPlayerName(tbl.lose.player).." na rękę.", tbl.win.player, "success")
                    exports.px_noti:noti("Przegrałeś pojedynek z graczem "..getPlayerName(tbl.win.player).." na rękę.", tbl.lose.player, "success")

                    if(not exports.px_achievements:isPlayerHaveAchievement(tbl.win.player, "Siłacz"))then
                        exports.px_achievements:getAchievement(tbl.win.player, "Siłacz")
                    end
                else
                    exports.px_noti:noti("Wystąpił błąd.", tbl.win.player, "error")
                    exports.px_noti:noti("Wystąpił błąd.", tbl.lose.player, "error")
                end
            end
            triggerClientEvent(tbl.lose.player == client and tbl.win.player or tbl.lose.player, "hands.win", resourceRoot)
        end
    end
end)