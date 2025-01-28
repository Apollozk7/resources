--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent("off.lights", true)
addEventHandler("off.lights", resourceRoot, function(veh)
    exports.px_noti:noti("Żarówki w twoim pojeździe się spaliły.", client, "error")
    setElementData(veh, "vehicle:multiLED", false)
    setElementData(veh, "vehicle:lights", false)
    setVehicleHeadLightColor(veh,255,255,255)
end)

addEventHandler("onVehicleEnter", root, function(plr,seat)
    if(seat ~= 0)then return end

    if(getElementData(source, "vehicle:nitro"))then
        local upgrades=getVehicleUpgrades(source)
        for i,v in pairs(upgrades) do
            if(v == 1008 or v == 1009 or v == 1010 or v == 1087)then
                removeVehicleUpgrade(source,v)
                addVehicleUpgrade(source,v)
            end
        end
    end

    local hydra=getVehicleUpgradeOnSlot(source, 9)
    if(hydra == 1087)then
        removeVehicleUpgrade(source,1087)
        addVehicleUpgrade(source,1087)
    end
end)