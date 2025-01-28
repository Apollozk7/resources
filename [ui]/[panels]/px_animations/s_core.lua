--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

animations = {}
    
animations.useAnimation = function(player, animationTable)
    setPedAnimation(player, unpack(animationTable))
    triggerClientEvent(player, "px_animations:onClientAnimationUse", getResourceRootElement())
end

addEvent("px_animations:useAnimation", true)
addEventHandler("px_animations:useAnimation", getResourceRootElement(), function(...)
    if not client or not ... then return false end
    animations.useAnimation(client, ...)
end)

animations.stopAnimation = function(player, forced)
    setPedAnimation(player)
    triggerClientEvent(player, "px_animations:onClientAnimationStop", getResourceRootElement(), forced)
end

addEvent("px_animations:stopAnimation", true)
addEventHandler("px_animations:stopAnimation", getResourceRootElement(), function(forced)
    if not client then return false end
    animations.stopAnimation(client, forced)
end)