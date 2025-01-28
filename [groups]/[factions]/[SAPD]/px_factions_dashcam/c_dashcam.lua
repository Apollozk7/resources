--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- exports

local blur=exports.blur

-- assets

local assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/right.png",
        "textures/circle.png",
        "textures/icon_1.png",
        "textures/icon_2.png",
        "textures/icon_3.png",
        "textures/icon_4.png",
    },

    fonts={
        {"Medium", 11},
        {"SemiBold", 11},
        {"fonts/digital-7.ttf", 25},
        {"fonts/digital-7.ttf", 10},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts={}
    for i,v in pairs(assets.list.fonts) do
        if(utf8.find(v[1], "fonts/"))then
            assets.fonts[i]=dxCreateFont(v[1], v[2]/zoom)
        else
            assets.fonts[i]=dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom)
        end
    end
end

assets.destroy=function()
    for i,v in pairs(assets.textures) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.textures={}

    for i,v in pairs(assets.fonts) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.fonts={}
end

-- variables

local ui={}

-- draw

ui.getDash=150

ui.onRender=function()
    local v=getPedOccupiedVehicle(localPlayer)
    if(not v)then 
        ui.destroy()
        return 
    end

    local pos={getElementPosition(v)}
    local rot={getElementRotation(v)}
    local x,y = (pos[1] - math.sin(math.rad(rot[3])) * ui.getDash), (pos[2] + math.cos(math.rad(rot[3])) * ui.getDash)

    local _,_,_,_,element = processLineOfSight(pos[1], pos[2], pos[3], x, y, pos[3], true, true, true, true, true, _, _, _, v)
    if(element and getElementType(element) == "vehicle")then
        blur:dxDrawBlur(sw/2-398/2/zoom, sh-123/zoom-30/zoom, 398/zoom, 123/zoom)
        dxDrawImage(sw/2-398/2/zoom, sh-123/zoom-30/zoom, 398/zoom, 123/zoom, assets.textures[1])
        dxDrawImage(sw/2-398/2/zoom+398/zoom-123/zoom, sh-123/zoom-30/zoom+1, 121/zoom, 121/zoom, assets.textures[2])
        dxDrawImage(sw/2-398/2/zoom+398/zoom-123/zoom+(121-87)/2/zoom, sh-123/zoom-30/zoom+1+(121-87)/2/zoom, 87/zoom, 87/zoom, assets.textures[3])

        dxDrawText(string.format("%01d", getElementSpeed(element, "km/h")), sw/2-398/2/zoom+398/zoom-123/zoom+(121-87)/2/zoom, sh-123/zoom-30/zoom+1+(121-87)/2/zoom-10/zoom, 87/zoom+sw/2-398/2/zoom+398/zoom-123/zoom+(121-87)/2/zoom, 87/zoom+sh-123/zoom-30/zoom+1+(121-87)/2/zoom, tocolor(150, 150, 150), 1, assets.fonts[3], "center", "center")
        dxDrawText("KM/H", sw/2-398/2/zoom+398/zoom-123/zoom+(121-87)/2/zoom, sh-123/zoom-30/zoom+1+(121-87)/2/zoom+40/zoom, 87/zoom+sw/2-398/2/zoom+398/zoom-123/zoom+(121-87)/2/zoom, 87/zoom+sh-123/zoom-30/zoom+1+(121-87)/2/zoom, tocolor(124, 216, 253), 1, assets.fonts[4], "center", "center")

        local infos={
            {"ID", (getElementData(element, "vehicle:id") or 0)},
            {"Model", getVehicleName(element)},
            {"Kierujący", getVehicleController(element) and getPlayerName(getVehicleController(element)) or "brak"},
            {"Rejestracja", getVehiclePlateText(element)}
        }
        local last_h=0
        for i,v in pairs(infos) do
            local w,h=dxGetMaterialSize(assets.textures[3+i])

            dxDrawImage(sw/2-398/2/zoom+44/zoom-w, sh-123/zoom-30/zoom+16/zoom+last_h, w/zoom, h/zoom, assets.textures[3+i])
            dxDrawText(v[1]..":", sw/2-398/2/zoom+44/zoom+11/zoom, sh-123/zoom-30/zoom+16/zoom+last_h, w/zoom, h/zoom+sh-123/zoom-30/zoom+16/zoom+last_h, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
            dxDrawText(v[2], sw/2-398/2/zoom+44/zoom+11/zoom, sh-123/zoom-30/zoom+16/zoom+last_h, sw/2-398/2/zoom+398/zoom-123/zoom-14/zoom, h/zoom+sh-123/zoom-30/zoom+16/zoom+last_h, tocolor(124, 216, 253), 1, assets.fonts[2], "right", "center")

            last_h=last_h+h+12/zoom
        end
    end
end

-- functions

ui.create=function()
    assets.create()

    blur=exports.blur
    addEventHandler("onClientRender", root, ui.onRender)
end

ui.destroy=function()
    assets.destroy()

    removeEventHandler("onClientRender", root, ui.onRender)
end

-- setup

addEventHandler("onClientVehicleEnter", root, function(player, seat)
    if(player == localPlayer and (seat == 0 or seat == 1))then
        local owner=getElementData(source, "vehicle:group_owner")
        if(owner and owner == "SAPD")then
            ui.create()
        end
    end
end)

-- useful

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and "ignore" argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end