--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

function getTable(types,pos)
    if(not types)then return end

    local tbl={}
    for _,type in pairs(types) do
        if(type and tostring(type))then
            type=tostring(type)

            local t=getElementsByType(type, root, true)
            for i,v in pairs(t) do
                if(v and isElement(v))then
                    tbl[#tbl+1]=v
                end
            end
        end
    end
    return tbl
end

function setElAlpha(el,a)
    if(getElementType(el) == "ped" or getElementType(el) == "player" or getElementType(el) == "vehicle")then
        if(not getElementData(el,"user:inv"))then
            setElementAlpha(el,a)
            return true
        end
    end
    return false
end

function render()
    local tbl=getTable({"vehicle","player","ped"})
    for i,v in pairs(tbl) do
        if(v and isElement(v))then
            local ghost=getElementData(v,"ghost") or getElementData(v,"ghost_cs")
            if(ghost)then
                local tbl_2=getTable(ghost == "all" and {"vehicle","player","ped"} or {ghost})
                for _,v2 in pairs(tbl_2) do
                    if(v2 and isElement(v2))then
                        setElementCollidableWith(v, v2, false)
                    end
                end
            end
        end
    end
end
setTimer(render, 200, 0)

-- anty bug

addEventHandler("onClientElementStreamIn", root, function()
    local element=source
    local ghost=getElementData(element,"ghost") or getElementData(element,"ghost_cs")
    if(ghost)then
        for i,v in pairs(getTable({"vehicle","player","ped"})) do
            local ghost=getElementData(v,"ghost") or getElementData(v,"ghost_cs")
            if(ghost)then
                setElementCollidableWith(element, v, true)
            else
                setElementCollidableWith(element, v, false)
            end
        end
    else
        setElementCollidableWith(localPlayer, element, true)    
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    local element=source
    for i,v in pairs(getTable({"vehicle","player","ped"})) do
        setElementCollidableWith(element, v, true)
        --setElAlpha(v,255)
    end
end)

addEventHandler("onClientElementDataChange", root, function(data,old,new)
    if((data == "ghost" or data == "ghost_cs") and not new)then
        local my=source
        local x,y,z=getElementPosition(source)
        local t=getTable({"vehicle","player","ped"},{x,y,z})
        if(t and #t > 0)then
            for i,v in pairs(t) do
                if(not getElementData(v, "ghost") and not getElementData(v, "ghost_cs") and v ~= my)then
                    setElementCollidableWith(my, v, true)
                    setElAlpha(v,255)
                end
            end
        end
    end
end)