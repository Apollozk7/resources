--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function createLoadingScreen(player, postGUI, alpha, tick, downloading)
    triggerClientEvent(player, "createLoadingScreen", resourceRoot, postGUI, alpha, tick, downloading)
end