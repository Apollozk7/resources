--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local info={}

local texs={
    ["SAPD"]={
        ["Chief of Police"]=1,
        ["Assistant Chief of Police"]=2,
        ["Deputy Chief"]=3,
        ["Commander"]=4,
        ["Captain"]=5,
        ["Lieutenant II"]=6,
        ["Lieutenant I"]=6,
        ["Sergeant II"]=7,
        ["Sergeant I"]=8,
        ["Senior Lead Officer"]=9,
        ["Police Officer III"]=10,
        ["Police Officer II"]=0,
        ["Police Officer I"]=0,
        ["Cadet"]=0,
    },

    ["PSP"]={
        ["generał brygadier"]="generalbrygadier",
        ["nadbrygadier"]="nadbrygadier",
        ["starszy brygadier"]="starszybrygadier",
        ["brygadier"]="brygadier",
        ["młodszy brygadier"]="mlodszybrygadier",
        ["starszy kapitan"]="starszykapitan",
        ["kapitan"]="kapitan",
        ["młodszy kapitan"]="mlodszykapitan",
        ["aspirant sztabowy"]="aspirantsztabowy",
        ["starszy aspirant"]="starszyaspirant",
        ["aspirant"]="aspirant",
        ["młodszy aspirant"]="mlodszyaspirant",
        ["starszy ogniomistrz"]="starszyogniomistrz",
        ["ogniomistrz"]="ogniomistrz",
        ["młodszy ogniomistrz"]="mlodszyogniomistrz",
        ["starszy sekcyjny"]="starszysekcyjny",
        ["sekcyjny"]="sekcyjny",
        ["starszy strażak"]="starszystrazak",
        ["strażak"]="strazak",
    }
}

function setPlayerRank(id, player)
    local f=getElementData(player,"user:faction")
    if(not f)then return end

    local t=texs[f]
    if(not t)then return end

    t=t[id]
    if(not t or t == 0)then return end

    info[player]={
        id=id,
        shader=dxCreateShader("shader.fx", {}, 0, 0, false, "ped"),
        rt=dxCreateTexture("textures/"..t..".png"),
    }

    dxSetShaderValue(info[player].shader, "shader", info[player].rt)
    engineApplyShaderToWorldTexture(info[player].shader, f == "SAPD" and "b" or f == "PSP" and "stopien", player)
end

function destroyPlayerRank(player)
    local v=info[player]
    if(v)then
        checkAndDestroy(v.shader)
        checkAndDestroy(v.rt)
    end
end

addEventHandler("onClientElementStreamIn", root, function()
    if(getElementType(source) == "player")then
        local id=getElementData(source, "user:job_settings")
        if(id and id.police)then
            setPlayerRank(id.job_name, source)
        end
    end
end)

addEventHandler("onClientElementDataChange", root, function(data, old, new)
    if(getElementType(source) == "player" and data == "user:job_settings")then
        if(not new and old)then
            destroyPlayerRank(source)
        elseif(new and new.police)then
            destroyPlayerRank(source)
            setPlayerRank(new.job_name, source)
        end
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    if(getElementType(source) == "player")then
        destroyPlayerRank(source)
    end
end)

addEventHandler("onClientElementDestroy", root, function()
    if(getElementType(source) == "player")then
        destroyPlayerRank(source)
    end
end)

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end

for i,v in pairs(getElementsByType("player", root, true)) do
    local id=getElementData(v, "user:job_settings")
    if(id and id.police)then
        setPlayerRank(id.job_name, v)
    end
end