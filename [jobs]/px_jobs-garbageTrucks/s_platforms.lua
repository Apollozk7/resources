--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

p={}

p.dist=10

p.trucksPos={
    ["Dune"]={{1.5,-2.6,0.2},{-1.5,-2.6,0.2}},
    ["Trashmaster"]={{1.2,-3.5,-0.1},{-1.2,-3.5,-0.1}},
    ["Cement Truck"]={{1.2,-3.5,-0.1},{-1.2,-3.5,-0.1}}
}

p.attach={}

p.setPlayerAnimation=function(player, id, truck, pos)
    setPedAnimation(player, "CHAINSAW" ,"csaw_part", 1, true, true, true, false)

    if(id == 1)then
        setPedAnimation(player,"PED","gang_gunstand",-1,false)
        attachElements(player,truck,pos[1][1],pos[1][2],pos[1][3])
    elseif(id == 2)then
        setPedAnimation(player,"MISC","Hiker_Pose_L",-1,false)
        attachElements(player,truck,pos[2][1],pos[2][2],pos[2][3])
    elseif(id == 3)then
        setPedAnimation(player, "CHAINSAW" ,"csaw_part", 1, true, true, true, false)
        detachElements(player,truck)
    end
end

p.jumpInPlatform=function(vehicle)
    player=client

    if(getElementData(player, "user:onGarbagePlatform"))then 
        setElementData(client, "user:onGarbagePlatform", false)
        p.setPlayerAnimation(client,3)
        triggerClientEvent(client, "platform.leave", resourceRoot)
        return 
    end

    if(vehicle and isElement(vehicle) and player and isElement(player))then
        local truck_name=getVehicleName(vehicle)

        local busySlots=getAttachedElements(vehicle)
        local freeSlots=2
        local freeSlot=1

        for i,v in pairs(busySlots) do
            if(getElementType(v) == "player")then
                freeSlots=freeSlots-1
                
                local slot=getElementData(v,"user:onGarbagePlatform")
                if(slot == freeSlot)then
                    freeSlot=slot == 1 and 2 or 1
                end
            end
        end

        if(freeSlots > 0)then
            local pos=p.trucksPos[truck_name]
            p.setPlayerAnimation(player,freeSlot,vehicle,pos)
            setElementData(player, "user:onGarbagePlatform", freeSlot)
        else
            setElementData(client, "user:onGarbagePlatform", false)
            p.setPlayerAnimation(client,3)
            triggerClientEvent(client, "platform.leave", resourceRoot)
        end
    else
        setElementData(client, "user:onGarbagePlatform", false)
        p.setPlayerAnimation(client,3)
        triggerClientEvent(client, "platform.leave", resourceRoot)
    end
end
addEvent("platform.jump", true)
addEventHandler("platform.jump", resourceRoot, p.jumpInPlatform)

p.leavePlatform=function()
    setElementData(client, "user:onGarbagePlatform", false)
    p.setPlayerAnimation(client,3)
end
addEvent("platform.leave", true)
addEventHandler("platform.leave", resourceRoot, p.leavePlatform)