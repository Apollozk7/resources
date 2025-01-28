--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local def_avatar=dxCreateTexture("textures/circle_avatar.png", "argb", true, "clamp")

local avatars={}
local loading={}

function getCircleTexture(tex)
    local shader=dxCreateShader("shaders/hud_mask.fx")
	dxSetShaderValue(shader, "sPicTexture", tex)
	dxSetShaderValue(shader, "sMaskTexture", def_avatar)
	return shader
end

function createPlayerAvatar(login, avatar)
    if(avatar)then
        local tex = dxCreateTexture(avatar, "argb", true, "clamp")

        if(not tex)then tex=def_avatar end
        avatars[login]=getCircleTexture(tex)

        if(loading[login])then
            loading[login]=nil
        end

        local player=getPlayerFromName(login)
        if(player)then
            setElementData(player, "user:avatar", tex)
        end
    else
        if(loading[login])then
            loading[login]=nil
        end
        
        loadPlayerAvatar(login)
    end
end

function loadPlayerAvatar(login)
    if(loading[login])then return end
    loading[login]=true

    triggerServerEvent("load.avatar", resourceRoot, login)
end

function getPlayerAvatar(login)
    if(not login)then return def_avatar end

    local player=(isElement(login)) and login or getPlayerFromName(login)
    if(player and isElement(player))then
        if(getElementData(player, "user:nameMask"))then
            return def_avatar
        else
            if(avatars[player] and isElement(avatars[player]))then
                return avatars[player]
            else
                local data=getElementData(player, "user:avatarIMG")
                if(data)then
                    local tex=dxCreateTexture(data, "argb", true, "clamp")
                    if(not tex)then tex=def_avatar end
                    avatars[player]=getCircleTexture(tex)
                    return avatars[player]
                else
                    return def_avatar
                end
            end
        end
    else
        return def_avatar
    end
    return def_avatar
end

addEvent("load.avatar", true)
addEventHandler("load.avatar", resourceRoot, createPlayerAvatar)