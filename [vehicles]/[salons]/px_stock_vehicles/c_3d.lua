--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local VEH = {}

-- assets

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 17},
        {":px_assets/fonts/Font-Regular.ttf", 15},
        {":px_assets/fonts/Font-Regular.ttf", 13},
    },

    textures={},
    textures_paths={
        "textures/search/window.png",
    },
}

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

--

VEH.col = createColPolygon(2758.5244,1224.0465,2860.3921,1224.0924,2860.3872,1382.3395,2798.1992,1382.3472,2797.3958,1302.5215,2758.2861,1302.3951,2758.5247,1224.0465)
VEH.rt={}

floor=math.floor

VEH.renderUI=function()
    if(isPedInVehicle(localPlayer))then return end
    
    local max_dist=5
    local x,y,z=getElementPosition(localPlayer)
    local elements=getElementsWithinRange(x,y,z,max_dist,"vehicle")
    for i,v in pairs(elements) do
        local puted=getElementData(v, "vehStock:puted")
        if(puted)then
            local pos={getStraightPosition(v, 2)}

            local distance=getDistanceBetweenPoints2D(x, y, pos[1], pos[2])
            distance=distance < 1 and 1 or distance

            if(distance <= max_dist)then
                local sx,sy = getScreenFromWorldPosition(pos[1], pos[2], pos[3]+1)
                if(sx and sy)then
                    if(not VEH.rt[v])then
                        local p={0,0,500,400}

                        local info={
                            {"Cena pojazdu:", puted.drawCost.."#5fa324$"},
                            {"Przebieg:", puted.distance.."#1f5378km"},
                            {"Paliwo:", puted.fuel.."#1f5378/#c8c8c8"..puted.tank.."#1f5378L"},
                            {"Pojemność silnika:", puted.engine.."#1f5378dm³ #c9c9c9"..puted.fuelType},
                            {"Spalanie:", puted.fuel_usage.."#1f5378l#c8c8c8/100#1f5378km"},
                            {"Napęd:", puted.naped},
                            {"Właściciel:", (getPlayerFromName(puted.owner) and "#00ff00" or "#ff0000")..puted.owner},
    
                            {"Tuning mechaniczny:", puted.mech_tune, {}, add=5},
                            {"Tuning wizualny:", puted.tune, {}, add=5},
                        }

                        if(puted.offline)then
                            info[7][2]=info[7][2].." #c9c9c9 [sprzedaż offline]"
                        elseif(puted.business)then
                            info[7][2]=info[7][2].." #c9c9c9 ["..puted.business.."]"
                        end
    
                        local add=0
                        for i,v in pairs(info) do
                            if(v[3] and v.add)then
                                local t=wordWrap(v[2], (p[3]-60), 1, assets.fonts[3])
                                for _,k in pairs(t) do
                                    v[3][#v[3]+1]=k
                                    p[4]=p[4]+20
                                end
                            end
                        end

                        VEH.rt[v]={
                            rt=dxCreateRenderTarget(500,p[4] or 0),
                            h=p[4] or 0
                        }

                        dxSetRenderTarget(VEH.rt[v].rt,true)
                            dxDrawImage(p[1],p[2],p[3],p[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, 255))

                            dxDrawText(getVehicleName(v).." ("..puted.id..")", p[1],p[2]+10,p[3]+p[1],p[4], tocolor(200,200,200,255), 1, assets.fonts[1], "center", "top")
                            dxDrawRectangle(p[1]+30,p[2]+50,p[3]-60,1,tocolor(85, 85, 85,255))
        
                            for i,v in pairs(info) do
                                local sY=(35)*(i-1)
                                dxDrawText(v[1], p[1]+30, p[2]+60+sY+add, 0, 0, tocolor(200, 200, 200, 255), 1, assets.fonts[2])
        
                                if(v[3])then
                                    for ii,k in pairs(v[3]) do
                                        local nY=(20)*(ii-1)
                                        dxDrawText(k, p[1]+30, p[2]+60+sY+30+add+nY, p[1]+p[3], 0, tocolor(150, 150, 150, 255), 1, assets.fonts[3], 'left', 'top', false, true)
                                        v.add=v.add+20
                                    end
                                else
                                    dxDrawText(v[2], 0, p[2]+60+sY+add, p[1]+p[3]-30, 0, tocolor(200, 200, 200, 255), 1, assets.fonts[2], "right", "top", false, false, false, true)
                                end
        
                                add=add+(v.add or 0)
                            end
                        dxSetRenderTarget()
                    else
                        local dis=getEasingValue(1-distance/max_dist, "Linear")
                        local alpha=dis*275
                        local size=dis*1.115
                        local h=VEH.rt[v].h or 400
                        alpha=alpha>255 and 255 or alpha
    
                        local p={sx-(500/2)*size, sy-(h/2)*size, 500*size, h*size}
                        for i,v in pairs(p) do
                            v=floor(v)
                        end

                        blur:dxDrawBlur(p[1],p[2],p[3],p[4],tocolor(255, 255, 255, alpha))
                        dxDrawImage(p[1],p[2],p[3],p[4], VEH.rt[v].rt, 0, 0, 0, tocolor(255, 255, 255, alpha))
                    end
                end
            end
        end
    end
end

-- shape

addEventHandler('onClientElementDataChange', root, function(data,old,new)
    if(data == 'vehStock:puted')then
        if(VEH.rt[source])then
            destroyElement(VEH.rt[source].rt)
            VEH.rt[source]=nil
        end
    end
end)

addEvent("onShapeHit", true)
addEventHandler("onShapeHit", resourceRoot, function(elements)
    blur=exports.blur
    
    assets.create()
    addEventHandler("onClientRender", root, VEH.renderUI)
end)

addEventHandler("onClientColShapeLeave", VEH.col, function(hit, dim)
    if(hit ~= localPlayer or not dim)then return end

    removeEventHandler("onClientRender", root, VEH.renderUI)
    assets.destroy()

    for i,v in pairs(VEH.rt) do
        destroyElement(v.rt)
    end
    VEH.rt={}
end)

-- useful

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function getStraightPosition(element, plus)
    local x,y,z = getElementPosition(element)
    local _,_,rot = getElementRotation(element)
    local cx, cy = getPointFromDistanceRotation(x, y, (plus or 0), (-rot))
    return cx,cy,z
end

function wordWrap(text, maxwidth, scale, font)
    local lines = {}
    local words = split(text, " ") -- this unfortunately will collapse 2+ spaces in a row into a single space
    local line = 1 -- begin with 1st line
    local word = 1 -- begin on 1st word
    local endlinecolor
    while (words[word]) do -- while there are still words to read
        repeat
            lines[line] = lines[line] or "" -- define the line if it doesnt exist
      
            lines[line] = lines[line]..words[word] -- append a new word to the this line
            lines[line] = lines[line] .. " " -- append space to the line

            word = word + 1 -- moves onto the next word (in preparation for checking whether to start a new line (that is, if next word won't fit)
        until ((not words[word]) or dxGetTextWidth(lines[line].." "..words[word], scale, font) > maxwidth) -- jumps back to 'repeat' as soon as the code is out of words, or with a new word, it would overflow the maxwidth
    
        lines[line] = string.sub(lines[line], 1, -2) -- removes the final space from this line
        line = line + 1 -- moves onto the next line
    end -- jumps back to 'while' the a next word exists
    return lines
end