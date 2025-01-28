--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local wheels={}

wheels.shaderReflectionTexture = dxCreateTexture("reflection_cubemap.dds", "dxt5")

wheels.tires_id={
    [1025]=true,[1073]=true,[1074]=true,[1075]=true,[1076]=true,[1077]=true,[1078]=true,[1079]=true,[1080]=true,[1081]=true,[1082]=true,[1083]=true,[1084]=true,[1085]=true,[1096]=true,[1097]=true,[1098]=true
}

-- varables

wheels.names={
    [1]='wheel_lf_dummy',
    [2]='wheel_rf_dummy',
    [3]='wheel_lb_dummy',
    [4]='wheel_rb_dummy',
}

wheels.options={
    minWidth=0.75,
    maxWidth=1.5,
  
    minOffset=-0.07,
    maxOffset=0.07,
  
    minRot=-7,
    maxRot=7,
  
    minTire=0,
    maxTire=0.4,
}

wheels.vehicles={}
wheels.tires={}

-- renders

wheels.onRenderShowed=false

wheels.preRender=function()
    local vehiclesOnScreen=0

    for i,v in pairs(wheels.vehicles) do
        if(i and isElement(i))then
            for i2,v2 in pairs(v.elements) do
                wheels.calculateVehicleWheelRotation(i, v2, i2)
                setVehicleComponentVisible(i, wheels.names[i2], false)
            end

            vehiclesOnScreen=vehiclesOnScreen+1
        else
            wheels.destroyVehicles(i)
        end
    end

    if(vehiclesOnScreen <= 0 and wheels.onRenderShowed)then
        removeEventHandler('onClientPreRender', root, wheels.preRender)
        wheels.onRenderShowed=false
    end
end

-- functions

wheels.calculateVehicleWheelRotation=function(vehicle, wheel, x)
    if(wheel.object and isElement(wheel.object) and wheel.wheel and isElement(wheel.wheel))then
        local rotation=Vector3(getVehicleComponentRotation(vehicle, wheel.name, 'world'))
        local tilt=(wheel.tilt*wheels.options.maxRot)
        rotation.y=rotation.y+tilt

        local position={getVehicleComponentPosition(vehicle, wheel.name, 'world')}
        if(wheel.axis)then
            local axis=(wheel.axis*wheels.options.maxOffset)
            position={getTopPosition(position, rotation, axis)}
        end

        local x,y,z=(position[1] or 0),(position[2] or 0),(position[3] or 0)
        setElementPosition(wheel.object, x, y, z)
        setElementRotation(wheel.object, rotation, 'ZYX')
        setElementPosition(wheel.wheel, x, y, z)
        setElementRotation(wheel.wheel, rotation, 'ZYX')

        local dim=getElementDimension(vehicle)
        local int=getElementInterior(vehicle)
        setElementDimension(wheel.object, dim)
        setElementInterior(wheel.object, int)
        setElementDimension(wheel.wheel, dim)
        setElementInterior(wheel.wheel, int)
    else
        if(wheel.name)then
            setVehicleComponentVisible(vehicle, wheel.name, true)
        end
    end
end

wheels.setVehicleCustomWheel=function(vehicle, data, wheelID)
    wheels.destroyVehicles(vehicle)
    
    local wheel_size=getVehicleWheelScale(vehicle)
    local wheel_size_2=getVehicleWheelScale(vehicle)
    local x,y,z=getElementPosition(vehicle)

    wheelID=wheelID or 1025

    data.rot=data.rot or {0,0,0,0}
    data.size=data.size or {0,0,0,0}
    data.axis=data.axis or {0,0,0,0}
    data.color=(data.color and data.color.felga[1]) or {
        felga={255,255,255},
        hamulec={255,255,255},
        szprycha={255,255,255},
        tarcza={255,255,255}
    }
    data.tire=data.tire or 1
    data.tire=not tonumber(data.tire) and 1 or tonumber(data.tire)

    for i,v in pairs({
        [1]={wheel_size*0.73},
        [2]={wheel_size*0.86},
        [3]={wheel_size*0.93},
        [4]={wheel_size*1},
        [5]={wheel_size*0.731},
    }) do
        if(data.tire == i)then
            wheel_size=v[1]
            break
        end
    end

    wheels.vehicles[vehicle]={
        shader_1=dxCreateShader('shader.fx'),
        shader_2=dxCreateShader('shader.fx'),
        shader_3=dxCreateShader('shader.fx'),
        shader_4=dxCreateShader('shader.fx'),

        elements={
            {object=createObject(wheelID,x,y,z),tilt=tonumber(data.rot[1]),name=wheels.names[1],size=data.size[1],axis=data.axis[1],wheel=createObject(1337,x,y,z)},
            {object=createObject(wheelID,x,y,z),tilt=tonumber(data.rot[2]),name=wheels.names[2],size=data.size[2],axis=data.axis[2],wheel=createObject(1337,x,y,z)},
            {object=createObject(wheelID,x,y,z),tilt=tonumber(data.rot[3]),name=wheels.names[3],size=data.size[3],axis=data.axis[3],wheel=createObject(1337,x,y,z)},
            {object=createObject(wheelID,x,y,z),tilt=tonumber(data.rot[4]),name=wheels.names[4],size=data.size[4],axis=data.axis[4],wheel=createObject(1337,x,y,z)},
        },
    }

    for i,v in pairs(wheels.vehicles[vehicle].elements) do
        setElementData(v.wheel, 'custom_name', 'opona'..data.tire)

        setElementData(v.object, 'vehicle:wheel', true, false)
        setElementCollisionsEnabled(v.object, false)
        setElementCollisionsEnabled(v.wheel, false)

        v.size=tonumber(v.size) or 0

        local width=(v.size+1)/2
        width=v.size < 1 and ((width+1)*wheels.options.minWidth) or (v.size*wheels.options.maxWidth)
        setObjectScale(v.object, width, wheel_size, wheel_size)
        setObjectScale(v.wheel, width, wheel_size_2, wheel_size_2)
        
        dxSetShaderValue(wheels.vehicles[vehicle].shader_1, 'color', data.color.felga[1]/255, data.color.felga[2]/255, data.color.felga[3]/255)
        dxSetShaderValue(wheels.vehicles[vehicle].shader_1, 'sReflectionTexture', wheels.shaderReflectionTexture)
        engineApplyShaderToWorldTexture(wheels.vehicles[vehicle].shader_1, 'felga', v.object)

        dxSetShaderValue(wheels.vehicles[vehicle].shader_2, 'color', data.color.hamulec[1]/255, data.color.hamulec[2]/255, data.color.hamulec[3]/255)
        dxSetShaderValue(wheels.vehicles[vehicle].shader_2, 'sReflectionTexture', wheels.shaderReflectionTexture)
        engineApplyShaderToWorldTexture(wheels.vehicles[vehicle].shader_2, 'hamulec', v.object)

        dxSetShaderValue(wheels.vehicles[vehicle].shader_3, 'color', data.color.szprycha[1]/255, data.color.szprycha[2]/255, data.color.szprycha[3]/255)
        dxSetShaderValue(wheels.vehicles[vehicle].shader_3, 'sReflectionTexture', wheels.shaderReflectionTexture)
        engineApplyShaderToWorldTexture(wheels.vehicles[vehicle].shader_3, 'szprycha', v.object)

        dxSetShaderValue(wheels.vehicles[vehicle].shader_4, 'color', data.color.tarcza[1]/255, data.color.tarcza[2]/255, data.color.tarcza[3]/255)
        dxSetShaderValue(wheels.vehicles[vehicle].shader_4, 'sReflectionTexture', wheels.shaderReflectionTexture)
        engineApplyShaderToWorldTexture(wheels.vehicles[vehicle].shader_4, 'tarcza', v.object)

        setElementDoubleSided(v.wheel, true)

        setElementDimension(v.object, getElementDimension(vehicle))
        setElementInterior(v.object, getElementInterior(vehicle))
        setElementDimension(v.wheel, getElementDimension(vehicle))
        setElementInterior(v.wheel, getElementInterior(vehicle))
    end

    if(not wheels.onRenderShowed)then
        addEventHandler('onClientPreRender', root, wheels.preRender)
        wheels.onRenderShowed=true
    end
end

wheels.updateVehicleWheels=function(vehicle)
    local tune=getVehicleUpgradeOnSlot(vehicle, 12)
    if(tune > 0)then
        local wheels_data=getElementData(vehicle, 'vehicle:wheelsSettings') or {}
        wheels.setVehicleCustomWheel(vehicle, wheels_data, tune)
    end
end

wheels.destroyVehicles=function(vehicle)
    local data=wheels.vehicles[vehicle]
    if(data)then
        for i,v in pairs(data.elements) do
            checkAndDestroy(v.object)
            checkAndDestroy(v.wheel)
        end

        checkAndDestroy(data.shader_1)
        checkAndDestroy(data.shader_2)
        checkAndDestroy(data.shader_3)
        checkAndDestroy(data.shader_4)

        wheels.vehicles[vehicle]=nil

        for _,name in pairs(wheels.names) do
            setVehicleComponentVisible(vehicle, name, true)
        end
    end
end

-- streaming, etc

addEventHandler('onClientElementStreamIn', root, function()
    if(getElementType(source) == 'vehicle' and not wheels.vehicles[source])then
        wheels.updateVehicleWheels(source)
    end
end)

addEventHandler('onClientElementStreamOut', root, function()
    if(getElementType(source) == 'vehicle' and wheels.vehicles[source])then
        wheels.destroyVehicles(source)
    end
end)

addEventHandler('onClientElementDestroy', root, function()
    if(getElementType(source) == 'vehicle' and wheels.vehicles[source])then
        wheels.destroyVehicles(source)
    end
end)

addEventHandler('onClientElementDataChange', root, function(data, lastData, newData)
    if(getElementType(source) == 'vehicle' and data == 'vehicle:wheelsSettings')then
        wheels.destroyVehicles(source)
        wheels.updateVehicleWheels(source)
    end
end)

addEventHandler('onClientRestore', root, function(clear)
    if(clear)then
        for i,v in pairs(getElementsByType('vehicle', root, true)) do
            wheels.destroyVehicles(v)
            wheels.updateVehicleWheels(v)
        end
    end
end)

for i,v in pairs(getElementsByType('vehicle', root, true)) do
    if(not wheels.vehicles[v])then
        wheels.updateVehicleWheels(v)
    end
end

-- useful

function getPointFromDistanceRotation(x, y, dist, angle)

  local a = math.rad(90 - angle);

  local dx = math.cos(a) * dist;
  local dy = math.sin(a) * dist;

  return x+dx, y+dy;

end

function getTopPosition(pos, rot, plus)
    pos=pos or {0,0}
    pos[1]=pos[1] or 0
    pos[2]=pos[2] or 0
    
    local cx, cy = getPointFromDistanceRotation(pos[1], pos[2], (plus or 0), -rot.z+90)
    return cx, cy, pos[3]
end

function checkAndDestroy(element)
    return isElement(element) and destroyElement(element) or false
end