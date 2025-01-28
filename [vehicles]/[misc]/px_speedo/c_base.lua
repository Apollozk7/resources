--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local noti=exports.px_noti

-- variables

SPEEDO.tick=getTickCount()

SPEEDO.tempomat=false
SPEEDO.click=false

SPEEDO.controls={
    --["steer_forward"]={time=1000},
    --["steer_back"]={time=1000},

    ["radio_next"]=true,
    ["radio_previous"]=true,
    ["radio_user_track_skip"]=true,
}

SPEEDO.controlTick=0
SPEEDO.timer=false
SPEEDO.controlTime=100

for i,v in pairs(SPEEDO.controls) do
    if(type(v) == "table")then
        toggleControl(i, true)
    end
end

-- functions

SPEEDO.getVehicleSpeedoType=function(veh)
    local data=getElementData(veh, "vehicle:speedoType")
    if(data)then return data end

    local vehName=getVehicleName(veh)

    local id=0
    for i,v in pairs(SPEEDO.types) do
        for _,v in pairs(v) do
            if(v == vehName)then
                id=i
                break
            end
        end
    end

    if(id ~= "none")then
        return id
    end
    return false
end
function getVehicleSpeedoType(veh) return SPEEDO.getVehicleSpeedoType(veh) end

SPEEDO.createSpeedo=function(id)
    SPEEDO.type=id
    if(SPEEDO.TEXTURES[id] and SPEEDO.fonts[id])then
        SPEEDO.TEXTURES[id].create()
        SPEEDO.fonts[id].create()

        SPEEDO.tick=getTickCount()
        SPEEDO.speedShader=dxCreateShader("shaders/hud_mask.fx")
        SPEEDO.backing=false

        addEventHandler("onClientRender", root, SPEEDO.UI)

        SPEEDO.showed=true
    end
end

SPEEDO.destroySpeedo=function()
    removeEventHandler("onClientRender", root, SPEEDO.UI)
    
    SPEEDO.type=false

    for i,v in pairs(SPEEDO.TEXTURES) do
        if(type(v) == "table")then
            for i,v in pairs(v) do
                if(v and isElement(v))then
                    destroyElement(v)
                    v=nil
                end
            end
        end
    end

    for i,v in pairs(SPEEDO.fonts) do
        for i,v in pairs(v) do
            if(v and isElement(v))then
                destroyElement(v)
                v=nil
            end
        end
    end

    --[[for i,v in pairs(blurs) do
        for i2,v in pairs(v) do
            exports.circleBlur:destroyBlurCircle(v)
            blurs[i][i2]=nil
        end
    end]]

    SPEEDO.tick=false
    SPEEDO.backing=false

    if(SPEEDO.speedShader and isElement(SPEEDO.speedShader))then
        destroyElement(SPEEDO.speedShader)
    end
    
    SPEEDO.showed=false

    applyElementCustomDatas()
end

SPEEDO.UI = function()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if(vehicle)then
        local vehicle = getPedOccupiedVehicle(localPlayer)
        if(vehicle)then
            local speed=getElementSpeed(vehicle, 1)
            local gear=exports.bengines:getVehicleGear(vehicle)

            if(getPedControlState("brake_reverse") and not SPEEDO.backing and speed < 1)then
                SPEEDO.backing=true
            end
    
            if(SPEEDO.backing and gear == 1)then
                gear="R"
                if(speed < 1 and not getPedControlState("brake_reverse"))then
                    SPEEDO.backing=false
                end
            end
    
            if(speed < 1 and not SPEEDO.backing)then
                gear="N"
            end
    
            SPEEDO.gear=gear
        end

        -- mandaty
        if(getVehicleController(vehicle) == localPlayer)then
            local mandates=getElementData(localPlayer, "user:maxMandates") or {stars=0,maxStars=5}
            if(mandates and mandates.stars >= mandates.maxStars)then
                if(getElementSpeed(vehicle, "km/h") > 30)then
                    setElementSpeed(vehicle, "km/h", 30)
                end
            end
        end
        --

        -- controls
        if(SPEEDO.type == 3)then
            for i,v in pairs(SPEEDO.controls) do
                if(type(v) == "table" and v.tick)then
                    if((getTickCount()-v.tick) > v.time)then
                        toggleControl(i, true)
                    else
                        toggleControl(i, false)
                    end
                end

                if(getPedControlState(localPlayer, i))then
                    if(type(v) == "table" and not v.click)then
                        v.click=true
                    end
                else
                    if(type(v) == "table" and v.click)then
                        v.click=false
                        v.tick=getTickCount()
                    end
                end
            end
        end
        --

        if(not getElementData(localPlayer, "user:hud_disabled"))then
            SPEEDO['render_'..SPEEDO.type](vehicle)

            -- anty reczny bug
            if(getElementData(vehicle, "vehicle:handbrake") and not getPedControlState("handbrake"))then
                setPedControlState("handbrake", true)
            end
            --

            -- turbo
            local data_t=getElementData(vehicle, "vehicle:turbo")
            if(getVehicleController(vehicle) == localPlayer and data_t)then
                local turbo={
                    ["Turbo"]=0.0625,
                    ["TwinTurbo"]=0.125,
                    ["BiTurbo"]=0.25,
                }

                local startPuff=3000
                local rpm=exports.bengines:getVehicleRPM(vehicle)
                local maxSpeed=(getVehicleHandling(vehicle).maxVelocity)
                local speed=getElementSpeed(vehicle)
                local gear=exports.bengines:getVehicleGear(vehicle)

                if(rpm >= startPuff and speed < maxSpeed and getPedControlState("accelerate") and gear >= 2)then
                    setElementSpeed(vehicle, "km/h", speed+turbo[data_t] or 0.01)
                end
            end
            --

            -- brakes
            local data_h=getElementData(vehicle, "vehicle:brakes")
            if(getVehicleController(vehicle) == localPlayer and data_h)then
                local brakes={
                    ["Classic"]=0.2,
                    ["QuickDrive"]=0.3,
                    ["ProSpeed"]=0.4,
                    ["MaxFlow"]=0.5,
                }

                local speed=getElementSpeed(vehicle)
                if(getPedControlState("brake_reverse") and speed > 10 and not SPEEDO.backing)then
                    setElementSpeed(vehicle, "km/h", speed-brakes[data_h] or 0.01)
                end
            end

            -- nitro
            SPEEDO.getRenderNitro(vehicle)
        else
            --SPEEDO.TEXTURES[5].showBlur(true)
        end
    else
        SPEEDO.showed=false

        SPEEDO.destroySpeedo()
    end
end

-- distance, fuel, etc.

SPEEDO.pos = {}

local saveDatas={}
function setElementCustomData(element,name,value)
    setElementData(element,name,value,false)

    if(value)then
        saveDatas[name]={element,name,value}
    else
        if(saveDatas[name])then
            saveDatas[name]=nil
        end
    end
end
function applyElementCustomDatas()
    for i,v in pairs(saveDatas) do
        if(v[1] and isElement(v[1]))then
            setElementData(v[1],v[2],false,false)
            setElementData(v[1],v[2],v[3])
        end
    end
    saveDatas={}
end

SPEEDO.render = function()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if(vehicle)then
        if(getPedOccupiedVehicleSeat(localPlayer) == 0)then
            local distance = getElementData(vehicle, "vehicle:distance") or 0
            local fuel = getElementData(vehicle, "vehicle:fuel") or 25
            local gas = getElementData(vehicle, "vehicle:gas") or 25
            local actualType = getElementData(vehicle, "vehicle:actualType") or "Petrol"
            local lights=getElementData(vehicle, "vehicle:lights")

            if(((actualType == "Petrol" or actualType == "Diesel") and fuel <= 0) or (actualType == "LPG" and gas <= 0) and getVehicleEngineState(vehicle))then
                setVehicleEngineState(vehicle, false)
            end

            if(#SPEEDO.pos < 3)then
                SPEEDO.pos = {getElementPosition(vehicle)}
            else
                local x,y,z = getElementPosition(vehicle)
                local dist = getDistanceBetweenPoints3D(SPEEDO.pos[1], SPEEDO.pos[2], SPEEDO.pos[3], x, y, z)
                if(dist > 10)then
                    local export=exports.px_custom_vehicles
                    if(export)then
                        local fuel_usage=export:getFuelUsage(vehicle)
                        local usage_10meters=fuel_usage/3000

                        setElementCustomData(vehicle, "vehicle:distance", distance+0.1)

                        if(actualType == "LPG" and gas > 0)then
                            setElementCustomData(vehicle, "vehicle:gas", gas-usage_10meters)
                        elseif(fuel > 0)then
                            setElementCustomData(vehicle, "vehicle:fuel", fuel-usage_10meters)
                        end

                        SPEEDO.addNitro(vehicle,0.1)
                    end

                    if(lights and lights < 1)then
                        triggerServerEvent("off.lights", resourceRoot, vehicle)
                    elseif(lights)then
                        setElementCustomData(vehicle, "vehicle:lights", lights-0.001)
                    end

                    SPEEDO.pos = {getElementPosition(vehicle)}
                end
            end
        else
            SPEEDO.showed=false
            removeEventHandler("onClientRender", root, SPEEDO.render)
            applyElementCustomDatas()
        end
    else
        SPEEDO.showed=false
        removeEventHandler("onClientRender", root, SPEEDO.render)
        applyElementCustomDatas()
    end
end

-- showed

addEventHandler("onClientElementDataChange", root, function(data, last, new)
    if(data == "vehicle:speedoType")then
        for i,v in pairs(getVehicleOccupants(source))do
            if(v == localPlayer)then
                SPEEDO.destroySpeedo()

                local id=SPEEDO.getVehicleSpeedoType(source)
                if(id)then
                    SPEEDO.createSpeedo(id)
                end
            end
        end
    end
end)

addEventHandler("onClientVehicleEnter", root, function(player, seat)
    if(player ~= localPlayer)then return end

    if(SPEEDO.showed)then return end
    
    if(getVehicleName(source) == "Bike" or getVehicleName(source) == "BMX" or getVehicleName(source) == "Mountain Bike")then
        toggleControl("vehicle_secondary_fire", false)
        return
    end
    toggleControl("vehicle_secondary_fire", true)

    local id=SPEEDO.getVehicleSpeedoType(source)
    if(id)then
        addEventHandler("onClientRender", root, SPEEDO.render)

        SPEEDO.showed=true
    
        SPEEDO.createSpeedo(id)

        local mandates=getElementData(player, "user:maxMandates") or {stars=0,maxStars=5}
        if(mandates and mandates.stars >= mandates.maxStars)then
            exports.px_noti:noti("Przez ilość mandatów możesz poruszać się maksymalnie 30km/h. Mandaty opłacisz na komisariacie.", "info")
        end
    end
end)

addEventHandler("onClientVehicleExit", root, function(player, seat)
    if(player ~= localPlayer or getVehicleName(source) == "Bike" or getVehicleName(source) == "BMX" or getVehicleName(source) == "Mountain Bike")then return end

    removeEventHandler("onClientRender", root, SPEEDO.render)

    SPEEDO.showed=false

    SPEEDO.destroySpeedo()

    applyElementCustomDatas()
end)

local veh = getPedOccupiedVehicle(localPlayer)
if(veh and getVehicleName(veh) ~= "Bike" and getVehicleName(veh) ~= "BMX" and getVehicleName(veh) ~= "Mountain Bike")then
    if(SPEEDO.showed)then return end

    local id=SPEEDO.getVehicleSpeedoType(veh)
    if(id)then
        SPEEDO.createSpeedo(id)

        addEventHandler("onClientRender", root, SPEEDO.render)

        SPEEDO.showed=true
    end
end

addEventHandler("onClientResourceStop",resourceRoot,function()
    applyElementCustomDatas()
end)

addEventHandler("onClientPlayerQuit", localPlayer,function()
    applyElementCustomDatas()
end)

-- useful

function getElementSpeed(theElement, unit)
    local vx,vy,vz=getElementVelocity(theElement)
    local speed=math.sqrt(vx^2 + vy^2 + vz^2) * 180
    return speed
end

function setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = getElementSpeed(element, unit)
	if acSpeed and acSpeed~=0 then -- if true - element is valid, no need to check again
		local diff = speed/acSpeed
		if diff ~= diff then return false end -- if the number is a 'NaN' return false.
        	local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end
	return false
end

-- off 

setWorldSpecialPropertyEnabled("extraairresistance", false)