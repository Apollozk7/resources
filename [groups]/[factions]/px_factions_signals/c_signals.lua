--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local signals_paths={
    ["SAPD"]={
        {button="n",path="sounds/sapd/1.wav"},
        {button="1",path="sounds/sapd/2.wav"},
        {button="2",path="sounds/sapd/3.wav"},
        {button="3",path="sounds/sapd/4.wav"},
        {button="4",path="sounds/sapd/5.wav"},
        {button="5",path="sounds/sapd/6.wav"},
    },

    ["PSP"]={
        {button="n",path="sounds/psp/n.mp3"},
        {button="1",path="sounds/psp/1.mp3"},
        {button="2",path="sounds/psp/2.mp3"},
        {button="3",path="sounds/psp/3.mp3"},
        {button="4",path="sounds/psp/4.mp3"},
        {button="5",path="sounds/psp/5.mp3"},
        {button="6",path="sounds/psp/6.mp3"},
    }
}

local signals={}
local misc_signals={}

addEventHandler("onClientKey", root, function(key, press)
    if(not press or isCursorShowing() or getElementData(localPlayer, "user:writing"))then return end

    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh or (veh and getVehicleController(veh) ~= localPlayer))then return end

    local data=getElementData(veh, "vehicle:group_owner")
    if(not data)then return end

    local tbl=signals_paths[data]
    if(not tbl)then return end

    for i,v in pairs(tbl) do
        if(key == v.button)then
            if(getElementData(veh, "emergency_signals"))then
                setElementData(veh, "emergency_signals", false)
            else
                setElementData(veh, "emergency_signals", v.path)
            end

            break
        end
    end
end)

addEventHandler("onClientElementDataChange", root, function(data, _, new)
    if(data == "emergency_signals")then
        if(signals[source] and isElement(signals[source]))then
            destroyElement(signals[source])
            signals[source]=nil
        end

        if(new)then
            signals[source]=playSound3D(new, 0, 0, 0, true)
            attachElements(signals[source], source)
            setSoundMaxDistance(signals[source], 120)
        end
    end
end)

addEventHandler("onClientElementStreamIn", root, function()
    local data=getElementData(source, "emergency_signals")
    if(data)then
        if(signals[source] and isElement(signals[source]))then
            destroyElement(signals[source])
            signals[source]=nil
        end

        if(data)then
            signals[source]=playSound3D(data, 0, 0, 0, true)
            attachElements(signals[source], source)
            setSoundMaxDistance(signals[source], 120)
        end
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    if(signals[source] and isElement(signals[source]))then
        if(signals[source] and isElement(signals[source]))then
            destroyElement(signals[source])
            signals[source]=nil
        end
    end
end)

addEventHandler("onClientElementDestroy", root, function()
    if(signals[source] and isElement(signals[source]))then
        if(signals[source] and isElement(signals[source]))then
            destroyElement(signals[source])
            signals[source]=nil
        end
    end
end)