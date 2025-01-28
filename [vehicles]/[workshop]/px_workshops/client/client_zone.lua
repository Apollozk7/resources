--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- render zones

local zone={}
zone.render=function()
    local job=getElementData(localPlayer, "user:job_settings")
    for i,v in pairs(getElementsByType("colshape", resourceRoot, true)) do
        local data=getElementData(v, "zone:settings")
        if(data and job.job_tag == data.desc and job.job_name == data.name)then
            local x,y,z=getElementPosition(v)
            local xx,yy,zz=getColShapeSize(v)
            local pos_z=getGroundPosition(x,y,z)+0.05

            local color=tocolor(0,255,0)
            if(data.take)then
                color=tocolor(255,0,0)
            end

            local pos={
                {x,y,x+xx,y},
                {x,y,x,y+yy},
                {x+xx,y+yy,x+xx,y},
                {x+xx,y+yy,x,y+yy}
            }
            
            for i,v in pairs(pos) do
                dxDrawLine3D(v[1], v[2], pos_z, v[3], v[4], pos_z, color, 1)
            end
        end
    end
end

-- zones

function isElementWithin(player)
    local exist=false
    for i,v in pairs(getElementsByType("colshape", resourceRoot, true)) do
        if(isElementWithinColShape(player, v) and getElementData(v, "zone:settings"))then
            exist=v
            break
        end
    end
    return exist
end

function isPlayerHaveInteraction(target, name)
    local job=getElementData(localPlayer, "user:job_settings")
    if(not job)then return false end

    local datas=getElementData(localPlayer, "workshop:zone")
    if(not datas)then return end

    local zone=isElementWithin(localPlayer)
    if(not zone)then return false end

    if(not isElementWithinColShape(target, zone))then return false end

    local data=getElementData(zone, "zone:settings")
    if(job.job_tag == data.desc and job.job_name == data.name and data.name == name and datas.zone == zone)then
        return true
    end
    return false
end

-- zones notis

UI2={}
UI2.tick=getTickCount()
UI2.noti=false

UI2.renderStano=function()
    local sec=math.floor(15-((getTickCount()-UI2.tick)/1000))
    if(sec == 0)then
        removeEventHandler("onClientRender", root, UI2.renderStano)
        exports.px_noti:notiDestroy(UI2.noti)
        UI2.noti=false
    else
        local text="Opuściłeś stanowisko, masz "..sec.." sekund aby wrócić."
        if(UI2.text ~= text)then
            UI2.text=text
            exports.px_noti:notiSetText(UI2.noti, text)
        end
    end
end

addEvent("zwolnij:stanowisko", true)
addEventHandler("zwolnij:stanowisko", resourceRoot, function()
    if(UI2.noti)then return end

    UI2.tick=getTickCount()
    exports.px_noti:noti("Opuściłeś stanowisko, masz 15 sekund aby wrócić.", "info", false, 'nasza')
    UI2.noti='nasza'

    addEventHandler("onClientRender", root, UI2.renderStano)
end)

addEvent("zwolnij:stanowisko:off", true)
addEventHandler("zwolnij:stanowisko:off", resourceRoot, function()
    if(UI2.noti)then
        removeEventHandler("onClientRender", root, UI2.renderStano)
        exports.px_noti:notiDestroy(UI2.noti)
        UI2.noti=false
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    exports.px_noti:notiDestroy(UI2.noti)
end)

-- 3d targets

local UI={}

UI.obj={}

function applyShader(v, obj)
    if(UI.obj[v] and UI.obj[v].shader and isElement(UI.obj[v].shader))then
        destroyElement(UI.obj[v].shader)
        UI.obj[v].shader=nil
    end

    local data=getElementData(v, "zone:settings")

    UI.obj[v]={
        target=dxCreateRenderTarget(475/zoom,132/zoom,true),
        shader=dxCreateShader("assets/shaders/shader.fx"),
        font=dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 25/zoom)
    }
    
    dxSetRenderTarget(UI.obj[v].target, true)
        dxDrawRectangle(0, 0, 475/zoom, 132/zoom, tocolor(15,15,15))

        if(data.take and isElement(data.take))then
            dxDrawText("#ff0000Stanowisko:\n#939393"..getPlayerName(data.take), 0, 0, 475/zoom, 132/zoom, tocolor(200, 200, 200), 1, UI.obj[v].font, "center", "center", false, false, false, true)
        else
            dxDrawText("#00ff00Stanowisko:\n#939393wolne", 0, 0, 475/zoom, 132/zoom, tocolor(200, 200, 200), 1, UI.obj[v].font, "center", "center", false, false, false, true)
        end
    dxSetRenderTarget()

    dxSetShaderValue(UI.obj[v].shader, "shader", UI.obj[v].target)
    engineApplyShaderToWorldTexture(UI.obj[v].shader, "mechstan", obj)

    destroyElement(UI.obj[v].target)
    destroyElement(UI.obj[v].font)
end

addEventHandler("onClientElementStreamIn", resourceRoot, function()
    local data=getElementData(source, "zone:settings")
    if(data and data.obj)then
        applyShader(source, data.obj)
    end
end)

addEventHandler("onClientElementStreamOut", resourceRoot, function()
    local data=getElementData(source, "zone:settings")
    if(data and data.obj and UI.obj[source])then
        destroyElement(UI.obj[source].shader)
        UI.obj[source]=nil
    end
end)

addEventHandler("onClientElementDataChange", root, function(key,_,data)
    if(key == "zone:settings")then
        if(UI.obj[source])then
            destroyElement(UI.obj[source].shader)
            UI.obj[source]=nil
        end

        applyShader(source, data.obj)
    elseif(key == "user:job_settings" and source == localPlayer)then
        if(not data)then
            removeEventHandler("onClientRender", root, zone.render)
        else
            if(data.job_tag and string.find(data.job_tag,"Warsztat"))then
                removeEventHandler("onClientRender", root, zone.render)
                addEventHandler("onClientRender", root, zone.render)
            end
        end
    end
end)

addEventHandler("onClientRestore", root, function(x)
    for i,v in pairs(getElementsByType("colshape", resourceRoot, true)) do
        local data=getElementData(v, "zone:settings")
        if(data and data.obj)then
            applyShader(v, data.obj)
        end
    end
end)

for i,v in pairs(getElementsByType("colshape", resourceRoot, true)) do
    local data=getElementData(v, "zone:settings")
    if(data and data.obj)then
        applyShader(v, data.obj)
    end
end