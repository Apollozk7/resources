--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent("get.mandate", true)
addEventHandler("get.mandate", resourceRoot, function(money)
    exports["px_factions-tablet"]:giveMandate(client, "Przekroczenie prędkości", money)
    exports.px_quests:updateQuest(client, "Dostać mandat od fotoradaru", 1)
end)