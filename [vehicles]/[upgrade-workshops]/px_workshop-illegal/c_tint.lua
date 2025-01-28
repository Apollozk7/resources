--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local shader=[[
    float4 color = float4(0, 0, 0, 1);
    
    technique tec0
    {
        pass P0
        {
            MaterialAmbient = color;
            MaterialDiffuse = color;
            MaterialEmissive = color;
            MaterialSpecular = color;
    
            AmbientMaterialSource = Material;
            DiffuseMaterialSource = Material;
            EmissiveMaterialSource = Material;
            SpecularMaterialSource = Material;
    
            ColorOp[0] = SELECTARG1;
            ColorArg1[0] = Diffuse;
    
            AlphaOp[0] = SELECTARG1;
            AlphaArg1[0] = Diffuse;
    
            Lighting = true;
            DepthBias = -0.0000;
            AlphaBlendEnable = TRUE;
            SrcBlend = SRCALPHA;
            DestBlend = INVSRCALPHA;
        }
    }
]]

local vehs={}

function setVehicleTintLevel(vehicle, level)
    if(not level or (level and not tonumber(level)))then
        removeVehicleTint(vehicle)
        return
    end

	level = tonumber(level)
    if(level > 100)then
        level=100
    end
    if(level < 0)then
        level=false
        removeVehicleTint(vehicle)
        return
    end
		
    if(vehs[vehicle] and vehs[vehicle].shader)then
    else
        vehs[vehicle]={}
        vehs[vehicle].shader = dxCreateShader(shader, 1, 200, true)
    end

    local r,g,b,a=0,0,0,255*(level/100)
    dxSetShaderValue(vehs[vehicle].shader, "color", r/255,g/255,b/255,a/255)

    engineApplyShaderToWorldTexture(vehs[vehicle].shader, "vehiclegeneric256", vehicle)
end

function removeVehicleTint(vehicle)
    if(vehs[vehicle] and vehs[vehicle].shader)then
        destroyElement(vehs[vehicle].shader)
        vehs[vehicle]={}
    end
end

addEventHandler("onClientElementDataChange", root, function(data, old, new)
    if(source and isElement(source) and getElementType(source) == "vehicle" and isElementStreamedIn(source) and data == "vehicle:tint")then
        if(new)then
            setVehicleTintLevel(source, new)
        else
            if(old)then
                removeVehicleTint(source)
            end
        end
    end
end)

addEventHandler("onClientElementStreamIn", root, function()
    if(getElementType(source) ~= "vehicle")then return end

    local data=getElementData(source, "vehicle:tint")
    if(data)then
        setVehicleTintLevel(source, data)
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    local data=getElementData(source, "vehicle:tint")
    if(data)then
        removeVehicleTint(source)
    end
end)

for i,v in pairs(getElementsByType("vehicle", root, true)) do
    local data=getElementData(v, "vehicle:tint")
    if(data)then
        setVehicleTintLevel(v, data)
    end
end