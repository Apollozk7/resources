--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

Siren={}

Siren.State=false

Siren.Block=false

Siren.Factions={
    ["SAPD"]=true,
    ["SARA"]=true,
    ["PSP"]=true,
}

function Siren.Start(vehicle)
    if(getElementData(vehicle, "vehicle:group_ownerName") and Siren.Factions[getElementData(vehicle, "vehicle:group_ownerName")])then
        local components=getElementData(vehicle, "vehicle:components") or {}
        components["siren_on"]="siren_on"
        setElementData(vehicle, "vehicle:components", components)
    end
end

function Siren.Stop(vehicle)
    local components=getElementData(vehicle, "vehicle:components") or {}
    components["siren_on"]=nil
    setElementData(vehicle, "vehicle:components", components)
end

bindKey("J", "down", function()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then return end

    if(getVehicleController(veh) ~= localPlayer)then return end

    if(Siren.Block)then return end

    if(not Siren.State)then
        Siren.Start(veh)
        Siren.State=veh
    else
        Siren.Stop(veh)
        Siren.State=false
    end

    Siren.Block=setTimer(function()
        Siren.Block=false
    end, 500, 1)
end)

function isSirensOn()
    return Siren.State == getPedOccupiedVehicle(localPlayer)
end