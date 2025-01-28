--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local objs={}

local shader=[[
texture shader;
technique replace
{
    pass P0
    {
        Texture[0] = shader;
    }
}

]]

-- create

local fonts={}
local listFonts={
    {":px_assets/fonts/Font-Medium.ttf", 8},
    {":px_assets/fonts/Font-Regular.ttf", 15},
}

function shaderFontsCreate()
    for i,v in pairs(listFonts) do
        fonts[#fonts+1]=dxCreateFont(v[1], v[2])
    end
end

function shaderFontsDestroy()
    for i,v in pairs(fonts) do
        if(v and isElement(v))then
            destroyElement(v)
            fonts[i]=nil
        end
    end
    fonts={}
end

function createShader(v)
    local data=getElementData(v, "job_info")
    if(data)then
        if(#fonts < 1)then
            shaderFontsCreate()
        end

        objs[v]={element=v,shader=dxCreateShader(shader),target=dxCreateRenderTarget(129, 231, true), data=data}

        applyShader(objs[v])

        if(#fonts > 0)then
            shaderFontsDestroy()
        end
    end
end

function destroyShader(v)
    if(objs[v])then
        engineRemoveShaderFromWorldTexture(objs[v].shader, "info")
        destroyElement(objs[v].shader)
        destroyElement(objs[v].target)
        objs[v]=nil
    end
end

function applyShader(v)
    dxSetRenderTarget(v.target, true)
        dxDrawRectangle(0, 0, 129, 231, tocolor(30, 30, 30))

        dxDrawText("MOŻLIWOŚĆ PRACY\nPRYWATNYM AUTEM", 0, 5, 129, 231, tocolor(200, 200, 200, 255), 1, fonts[1], "center", "top", false)
        dxDrawRectangle(25/2, 40, 129-25, 2, tocolor(100, 100, 100))

        for i,v in pairs(v.data) do
            local sY=30*(i-1)
            dxDrawText(getVehicleNameFromModel(v), 0, 45+sY, 129, 228, tocolor(200, 200, 200, 255), 1, fonts[2], "center", "top", false)
        end
    dxSetRenderTarget()

    local data=getElementData(v.element, "object")
    dxSetShaderValue(v.shader, "shader", v.target)
    engineApplyShaderToWorldTexture(v.shader, "info", data)
end

-- tutaj stojo

addEventHandler("onClientElementStreamIn", resourceRoot, function()
    if(getElementType(source) == "object")then
        createShader(source)
    end
end)

addEventHandler("onClientElementStreamOut", resourceRoot, function()
    if(getElementType(source) == "object")then
        destroyShader(source)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    for i,v in pairs(getElementsByType("object", resourceRoot, true)) do
        createShader(v)
    end
end)

addEventHandler("onClientRestore", root, function(clear)
    if(clear)then
        for i,v in pairs(getElementsByType("object", resourceRoot, true)) do
            createShader(v)
        end
    end
end)

addEventHandler("onClientElementDestroy", resourceRoot, function()
    destroyShader(source)
end)

-- cuboids

local c={}

c.places={}

c.render=function()
    for i,v in pairs(c.places) do
        local x,y,z=v[1],v[2],v[3]
        local xx,yy,zz=v[4],v[5],v[6]

        local color=tocolor(0,100,200)

        local pos={
            {x,y,x+xx,y},
            {x,y,x,y+yy},
            {x+xx,y+yy,x+xx,y},
            {x+xx,y+yy,x,y+yy}
        }
        
        for i,v in pairs(pos) do
            dxDrawLine3D(v[1], v[2], z, v[3], v[4], z, color, 1)
        end
    end
end

addEventHandler("onClientColShapeHit", resourceRoot, function(hit, dim)
    if(hit == localPlayer and dim and isPedInVehicle(hit))then
        local data=getElementData(source, "job_info")
        if(not data)then return end

        local veh=getPedOccupiedVehicle(hit)
        local model=getElementModel(veh)

        for i,v in pairs(data.vehicles) do
            if(v == model)then
                addEventHandler("onClientRender", root, c.render)
                c.places=data.places
                break
            end
        end
    end
end)

addEventHandler("onClientColShapeLeave", resourceRoot, function(hit, dim)
    if(hit == localPlayer and dim)then
        removeEventHandler("onClientRender", root, c.render)
        c.places={}
    end
end)