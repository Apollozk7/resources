--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local blur=exports.blur

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local UI = {}

-- variables main

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Regular.ttf", 10},
        {":px_assets/fonts/Font-Medium.ttf", 15},
    },

    textures={},
    textures_paths={
        "assets/images/window.png",
        "assets/images/info_icon.png",
        "assets/images/fire.png",
    },
}

function tableMerge(t1, t2)
    for _,v in pairs(t2) do
        local i=getElementData(v, "interaction") or getElementData(v, "3dui_text")
        if(i and not i['off3D'])then
            k=#t1+1
            if type(v) == "table" then
                if type(t1[k] or false) == "table" then
                    tableMerge(t1[k] or {}, t2[k] or {})
                else
                    t1[k] = v
                end
            else
                t1[k] = v
            end
        end
    end
    return t1
end

--

UI.targets={}

UI.getInteractionObjects=function(a1,a2,a3,a4)
    local objects={}

    tableMerge(objects, a1)
    tableMerge(objects, a2)
    tableMerge(objects, a3)
    tableMerge(objects, a4)

    return objects
end

UI.onRender = function()
    blur=exports.blur
    
    local elements={}

    local x,y,z=getElementPosition(localPlayer)

    local max_dist=5
    local vehicles=getElementsWithinRange(x,y,z,max_dist,"vehicle")
    local players=getElementsWithinRange(x,y,z,max_dist,"player")
    local peds=getElementsWithinRange(x,y,z,max_dist,"ped")
    local objects=getElementsWithinRange(x,y,z,max_dist,"object")
    local inter=UI.getInteractionObjects(vehicles, players, objects, peds)
    for i,v in pairs(inter) do
        local pos={getElementPosition(v)}

        local distance=getDistanceBetweenPoints2D(x, y, pos[1], pos[2])
        distance=distance < 1 and 1 or distance

        if(distance <= max_dist)then
            local dis=getEasingValue(1-distance/max_dist, "Linear")
            local alpha=dis*255
            local size=dis*1.115
            local size2=dis*1

            local sx,sy = getScreenFromWorldPosition(pos[1], pos[2], pos[3])
            if(sx and sy and not isPedInVehicle(localPlayer))then
                local data=getElementData(v, "3dui_text")
                local text=data and data.text
                local tex=(data and data.type == "fire") and 3 or 2
                local w,h=244,42
                if(text)then
                    w,h=w*1.3,h*1.3
                end

                blur:dxDrawBlur(sx-(w/2)*size, sy-(h/2)*size, w*size, h*size, tocolor(255, 255, 255, alpha))
                dxDrawImage(sx-(w/2)*size, sy-(h/2)*size, w*size, h*size, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, alpha))
                dxDrawImage(sx-w/2*size+(h-19)/2*size, sy-h/2*size+(h-19)/2*size, 19*size, 19*size, assets.textures[tex], 0, 0, 0, tocolor(255, 255, 255, alpha))
                dxDrawRectangle(sx-w/2*size+(h-19)/2*size+19*size+(h-19)/2*size, sy-h/2*size+(h-19)/2*size, 1, 22*size, tocolor(85, 85, 85, alpha))
                dxDrawText(text or "Ten obiekt ma dostępne akcje.\nKliknij 'E' aby otworzyć interakcje.", sx-w/2*size+(h-19)/2*size+19*size+(h-19)*size, sy-h/2*size, w*size, sy-h/2*size+h*size, tocolor(200, 200, 200, alpha), size2, text and assets.fonts[2] or assets.fonts[1], "left", "center")
            end
        end
    end

    for i,v in pairs(vehicles) do
        local data=getElementData(v, "vehicle:stationFuel")
        if(data)then
            local pos={getElementPosition(v)}

            local distance=getDistanceBetweenPoints2D(x, y, pos[1], pos[2])
            distance=distance < 1 and 1 or distance
    
            if(distance <= max_dist)then
                local dis=getEasingValue(1-distance/max_dist, "Linear")
                local alpha=dis*255
                local size=dis*1.115
                local size2=dis*1
    
                local sx,sy = getScreenFromWorldPosition(pos[1], pos[2], pos[3])
                if(sx and sy and not isPedInVehicle(localPlayer))then
                    local w,h=350,70

                    blur:dxDrawBlur(sx-(w/2)*size, sy-(h/2)*size, w*size, h*size, tocolor(255, 255, 255, alpha))
                    dxDrawImage(sx-(w/2)*size, sy-(h/2)*size, w*size, h*size, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, alpha))

                    dxDrawText("Poziom paliwa:", sx-(w/2)*size+10*size, sy-(h/2)*size+10*size, 0, 0, tocolor(200, 200, 200, alpha), 1, assets.fonts[1], "left", "top")
                    dxDrawText(data.cost.."$/1L", 0, sy-(h/2)*size+10*size, sx-(w/2)*size+w*size-10*size, 0, tocolor(200, 200, 200, alpha), 1, assets.fonts[1], "right", "top")

                    local bak=getElementData(v, "vehicle:fuelTank") or 25
                    dxDrawRectangle(sx-(w/2)*size+10*size, sy-(h/2)*size+45*size, 330*size, 20*size, tocolor(15, 15, 15, alpha))
                    dxDrawRectangle(sx-(w/2)*size+10*size+5*size, sy-(h/2)*size+45*size+5*size, (330*size-10*size)*(data.fuel/bak), 20*size-10*size, tocolor(0, 200, 50, alpha))
                end
            end
        end
    end
end
addEventHandler("onClientHUDRender", root, UI.onRender)

-- assets

assets.create = function()
    for k,t in pairs(assets) do
        if(k=="fonts_paths")then
            for i,v in pairs(t) do
                assets.fonts[i] = dxCreateFont(v[1], v[2])
            end
        elseif(k=="textures_paths")then
            for i,v in pairs(t) do
                assets.textures[i] = dxCreateTexture(v, "argb", false, "clamp")
            end
        end
    end
end

assets.destroy = function()
    for k,t in pairs(assets) do
        if(k == "textures" or k == "fonts")then
            for i,v in pairs(t) do
                if(v and isElement(v))then
                    destroyElement(v)
                end
            end
            assets.fonts={}
            assets.textures={}
        end
    end
end

assets.create()

-- convert

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end