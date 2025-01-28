--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local vehs={
    -- sapd
    [596]="n",
    [525]="n",
    [599]='n',
    [597]='n',
    [554]='n',

    -- psp
    [407]="nr",
    [433]="nr",
    [455]="nr",
    [544]="nr",
    [578]="nr",
    [416]="nr",
    [609]="nr",
    [598]="nr",
}

local info={}

local font=dxCreateFont("font.ttf", 35)

function createImage(text,w,h)
    local rt=dxCreateRenderTarget(w,h,true)
    dxSetRenderTarget(rt, true)
        dxDrawText(text or "1", 0, 0, w, h, tocolor(255, 255, 255), 1, font, "center", "center")
    dxSetRenderTarget()
    return rt
end

function setVehicleName(id, veh, tex)
    info[veh]={
        id=id,
        shader=dxCreateShader("shader.fx"),
        rt=createImage(id, 200, 100),
    }

    dxSetShaderValue(info[veh].shader, "shader", info[veh].rt)
    engineApplyShaderToWorldTexture(info[veh].shader, tex, veh)
end

function destroyVehicleName(veh)
    local v=info[veh]
    if(v)then
        checkAndDestroy(v.shader)
        checkAndDestroy(v.rt)
    end
end

addEventHandler("onClientElementStreamIn", root, function()
    if(getElementType(source) == "vehicle" and vehs[getElementModel(source)])then
        local name=getElementData(source, "vehicle:kryptonim")
        if(name)then
            setVehicleName(name, source, vehs[getElementModel(source)])
        end
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    if(getElementType(source) == "vehicle" and vehs[getElementModel(source)])then
        destroyVehicleName(source)
    end
end)

addEventHandler("onClientElementDestroy", root, function()
    if(getElementType(source) == "vehicle" and vehs[getElementModel(source)])then
        destroyVehicleName(source)
    end
end)

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end

for i,v in pairs(getElementsByType("vehicle", root, true)) do
    if(vehs[getElementModel(v)])then
        local id=getElementData(v, "vehicle:kryptonim")
        if(id)then
            setVehicleName(id, v, vehs[getElementModel(v)])
        end
    end
end

addEventHandler("onClientRestore", root, function()
    for i,v in pairs(getElementsByType("vehicle", root, true)) do
        if(vehs[getElementModel(v)])then
            local id=getElementData(v, "vehicle:kryptonim")
            if(id)then
                setVehicleName(id, v, vehs[getElementModel(v)])
            end
        end
    end
end)