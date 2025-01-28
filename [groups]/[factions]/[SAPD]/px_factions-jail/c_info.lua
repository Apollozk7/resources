--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local C={}

C.Trigger=false

C.Render=function()
    local data=getElementData(localPlayer, "user:jailTimestamp")
    if(not data)then 
        removeEventHandler("onClientRender", root, C.Render)
        assets.destroy()
        return 
    end

    local now=getTimestamp()
    local unix=math.floor((data-now)/60)

    dxDrawText("Do wyjścia z więzienia pozostało:\n"..unix.." minut", 0+1, 0+1, sw+1, 0, tocolor(0, 0, 0), 1, assets.fonts[1], "center", "top")
    dxDrawText("Do wyjścia z więzienia pozostało:\n"..unix.." minut", 0, 0, sw, 0, tocolor(0, 100, 100), 1, assets.fonts[1], "center", "top")

    if(unix <= 0 and not C.Trigger)then
        triggerServerEvent("get.jail", resourceRoot)
        C.Trigger=setTimer(function()
            C.Trigger=false
        end, 5000, 1)
    end
end

addEvent("refresh.info", true)
addEventHandler("refresh.info", resourceRoot, function()
    if(getElementData(localPlayer, "user:jailTimestamp"))then
        addEventHandler("onClientRender", root, C.Render)
        assets.create()
        C.Trigger=false
    end
end)

addEventHandler("onClientElementDataChange", root, function(data,old,new)
    if(data == "user:jailTimestamp" and source == localPlayer)then
        removeEventHandler("onClientRender", root, C.Render)
        assets.destroy()

        if(new)then
            addEventHandler("onClientRender", root, C.Render)
            assets.create()
            C.Trigger=false
        end
    end
end)

Timer=setTimer(function()
    if(getElementData(localPlayer, "user:uid"))then
        if(getElementData(localPlayer, "user:jailTimestamp"))then
            addEventHandler("onClientRender", root, C.Render)
            assets.create()
            C.Trigger=false
        end

        killTimer(Timer)
    end
end, 500, 0)

-- useful

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end