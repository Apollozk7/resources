--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local LINE = {}

LINE.fuels = {}

LINE.color=tocolor(0,0,0)

LINE.onRender = function()
    if(table.size(LINE.fuels) < 1)then
        return removeEventHandler("onClientRender", root, LINE.onRender)
    end

    if(LINE.fuels[localPlayer])then
        local last = #LINE.fuels[localPlayer]

        if(getPedOccupiedVehicle(localPlayer))then
            triggerServerEvent("3dline.destroy", resourceRoot, localPlayer)
            return
        end

        local bonePos = {getPedBonePosition(localPlayer, 35)}
        local myPos = {getElementPosition(localPlayer)}
        local quit2 = LINE.fuels[localPlayer][last][6]
        local v = LINE.fuels[localPlayer][last]
        local dist = getDistanceBetweenPoints2D(v[1], v[2], bonePos[1], bonePos[2])

        if(((dist > 2 and quit2) or (dist > 2.5 and not quit2)) and not LINE.fuels[localPlayer].block)then
            local ground = getGroundPosition(myPos[1], myPos[2], myPos[3])
            local cs1 = createColTube(myPos[1], myPos[2], ground, 0.5, 5)
            table.insert(LINE.fuels[localPlayer], {myPos[1], myPos[2], ground+0.1, cs1, false, true})
        end
    end

    for k,_ in pairs(LINE.fuels) do
        if(k and isElement(k))then
            local tbl=smooth3D(LINE.fuels[k], 8)

            if(_.start)then
                local x,y,z=_.start[1],_.start[2],_.start[3]
                dxDrawLine3D(x, y, z, LINE.fuels[k][1][1], LINE.fuels[k][1][2], LINE.fuels[k][1][3], LINE.color, 3.5)
            end

            local lx, ly, lz=0,0,0
            local xx=0
            if(#tbl > 2)then
                for i,v in pairs(tbl) do
                    xx=xx+1
    
                    if(tbl[xx+1])then
                        local endPos = tbl[xx+1]
                        dxDrawLine3D(v.x, v.y, v.z, endPos.x, endPos.y, endPos.z, LINE.color, 3.5)
                    else
                        lx, ly, lz = v.x, v.y, v.z, x,y,z
                    end
                end
            elseif(#tbl == 2)then
                local endPos = LINE.fuels[k][2]
                dxDrawLine3D(LINE.fuels[k][1][1], LINE.fuels[k][1][2], LINE.fuels[k][1][3], endPos[1], endPos[2], endPos[3], LINE.color, 3.5)

                lx, ly, lz = endPos[1], endPos[2], endPos[3]
            elseif(#tbl == 1)then
                lx, ly, lz = LINE.fuels[k][1][1], LINE.fuels[k][1][2], LINE.fuels[k][1][3]
            end

            local x,y,z = getPedBonePosition(k, 35)
            if(_.block)then
                x,y,z=unpack(_.block)
            end

            local lastX, lastY, lastZ = x, y, z
            for i = 1, 20 do
                local x, y = interpolateBetween(x, y, 0, lx, ly, 0, i/20, "Linear")
                local z = z + interpolateBetween(0, 0, 0, lz-z, 0, 0, i/20, "InOutQuad")
                dxDrawLine3D(lastX, lastY, lastZ, x, y, z, LINE.color, 3.5)
                lastX, lastY, lastZ = x, y, z
            end
        end
    end
end
addEventHandler("onClientRender", root, LINE.onRender)

LINE.onHit = function(hit)
    if(hit ~= localPlayer)then return end

    local quit1 = LINE.fuels[localPlayer][#LINE.fuels[localPlayer]][5]
    for i,v in pairs(LINE.fuels[localPlayer]) do
        if(source == v[4] and quit1)then
            for i = i,#LINE.fuels[localPlayer] do
                if(LINE.fuels[localPlayer][i][4] and isElement(LINE.fuels[localPlayer][i][4]))then
                    destroyElement(LINE.fuels[localPlayer][i][4])
                end
        
                LINE.fuels[localPlayer][i] = nil
                LINE.fuels[localPlayer][#LINE.fuels[localPlayer]][6] = false
            end
            break
        end
    end
end

LINE.onLeave = function(hit)
    if(hit ~= localPlayer)then return end
    
    for i,v in pairs(LINE.fuels[localPlayer])do
        if(v[4] and source == v[4])then
            v[5] = true
            break
        end
    end
end

function create3dLine(player, pos, nextPos)
    LINE.fuels[player] = {}
    if(nextPos)then
        LINE.fuels[player]["start"]={pos[1], pos[2], pos[3], false, false, true}
        LINE.fuels[player][1] = {nextPos[1], nextPos[2], nextPos[3], false, false, true}
    else
        LINE.fuels[player][1]={pos[1], pos[2], pos[3], false, false, true}
    end

    if(player == localPlayer)then
        addEventHandler("onClientColShapeHit", resourceRoot, LINE.onHit)
        addEventHandler("onClientColShapeLeave", resourceRoot, LINE.onLeave)
    end

    removeEventHandler("onClientRender", root, LINE.onRender)
    addEventHandler("onClientRender", root, LINE.onRender)
end

function destroy3dLine(player)
    if(LINE.fuels[player])then
        for i,v in pairs(LINE.fuels[player]) do
            if(v[4] and isElement(v[4]))then
                destroyElement(v[4])
            end
        end

        LINE.fuels[player] = nil

        if(player == localPlayer)then
            removeEventHandler("onClientColShapeHit", resourceRoot, LINE.onHit)
            removeEventHandler("onClientColShapeLeave", resourceRoot, LINE.onLeave)
        end
    end
end

function isPlayerHaveLine(player)
    if(LINE.fuels[player])then
        return true
    end
    return false
end

function addLinePosition(player, myPos)
    if(LINE.fuels[player])then
        local z=getGroundPosition(myPos[1], myPos[2], myPos[3])
        LINE.fuels[player][#LINE.fuels[player]+1]={myPos[1], myPos[2], z+0.1, false, false, true}
    end
    return false
end

function setLineLastPosition(player, myPos)
    if(LINE.fuels[player])then
        LINE.fuels[player]["block"]={myPos[1], myPos[2], myPos[3]+0.1, false, false, true}
    end
    return false
end

addEvent("3dline.create", true)
addEventHandler("3dline.create", resourceRoot, create3dLine)

addEvent("3dline.destroy", true)
addEventHandler("3dline.destroy", resourceRoot, destroy3dLine)

addEvent("3dline.expand", true)
addEventHandler("3dline.expand", resourceRoot, function(player, pos, block)
    if(player ~= localPlayer and LINE.fuels[player])then
        if(block)then
            LINE.fuels[player]["block"]={pos[1], pos[2], pos[3]+0.1, false, false, true}
        else
            table.insert(LINE.fuels[player], {pos[1], pos[2], pos[3]})
        end
    end
end)

addEvent("3dline.fold", true)
addEventHandler("3dline.fold", resourceRoot, function(player, id)
    if(player ~= localPlayer and LINE.fuels[player])then
        for i = id,#LINE.fuels[player] do
            LINE.fuels[player][i] = nil
        end
    end
end)

-- useful

function table.size(tbl)
    local x=0; for i,v in pairs(tbl) do x=x+1; end; return x;
end

function smooth3D( points, steps, count )
    if #points < 3 then
        return points
    end
    local steps = steps or 5
    local spline = {}
    local count = (#points - 1) - (count or 0)
    local p0, p1, p2, p3, x, y, z
    for i = 1, count do
        if i == 1 then
            p0, p1, p2, p3 = points[i], points[i], points[i + 1], points[i + 2]
        elseif i == count then
            p0, p1, p2, p3 = points[#points - 2], points[#points - 1], points[#points], points[#points]
        else
            p0, p1, p2, p3 = points[i - 1], points[i], points[i + 1], points[i + 2]
        end
        for t = 0, 1, 1 / steps do
            x = 0.5 * ( ( 2 * p1[1] ) + ( p2[1] - p0[1] ) * t + ( 2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1] ) * t * t + ( 3 * p1[1] - p0[1] - 3 * p2[1] + p3[1] ) * t * t * t )
            y = 0.5 * ( ( 2 * p1[2] ) + ( p2[2] - p0[2] ) * t + ( 2 * p0[2] - 5 * p1[2] + 4 * p2[2] - p3[2] ) * t * t + ( 3 * p1[2] - p0[2] - 3 * p2[2] + p3[2] ) * t * t * t )
            z = 0.5 * ( ( 2 * p1[3] ) + ( p2[3] - p0[3] ) * t + ( 2 * p0[3] - 5 * p1[3] + 4 * p2[3] - p3[3] ) * t * t + ( 3 * p1[3] - p0[3] - 3 * p2[3] + p3[3] ) * t * t * t )
            if not(#spline > 0 and spline[#spline][1] == x and spline[#spline][2] == y ) then
                table.insert( spline , { x = x , y = y, z = z } )
            end
        end
    end
    return spline
end