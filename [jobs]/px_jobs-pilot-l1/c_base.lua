--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer)then
        killTimer(SPAM.blockSpamTimer)
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 100, 1)

    return block
end

local noti=exports.px_noti
local blur=exports.blur

ui={}

ui.markers={}
ui.blips={}

ui.pos={
    {-210.1965,2674.1340,143.3642},
    {-60.7555,1176.1475,150.3642},
    {-255.2405,1087.6051,150.3642},
    {-2041.2787,932.3998,202.3642},
    {-2448.3928,665.6531,139.3642},
    {-2709.7319,31.5279,128.3642},
    {-2155.7314,-254.8676,144.3642},
    {-2056.1917,177.6887,144.3642},
    {-2663.4255,1313.6251,165.3642},
    {-2488.7498,2325.9253,130.3642},
    {-1983.2690,-877.7503,130.3642},
    {120.0745,-244.6192,133.3642},
    {189.0428,-110.4674,133.3642},
    {663.4149,-487.6520,151.3642},
    {1113.2667,-922.2642,151.3642},
    {1143.6012,-1470.8947,123.3642},
    {1582.3489,-1860.9106,123.3642},
    {2124.7524,-1868.8599,123.3642},
    {2583.8699,-1386.3666,123.3642},
    {2167.3108,-1215.4395,135.3642},
    {2564.0601,-2100.6470,135.3642},
    {2508.4229,-2.3115,102.3642},
    {2264.7483,99.4893,102.3642},
    {1287.9843,227.9343,117.3642},
    {1459.2090,-62.3950,94.3642},
    {237.0976,1403.8315,94.3642},
    {-726.9653,2048.9468,158.3642},
    {-800.4963,1573.0121,132.3642},
    {-1765.2921,686.7697,224.3642},
    {-2331.6404,170.8610,113.3642},
    {-2751.6982,-260.5777,98.3642},
    {-2166.2861,-2366.2539,133.3642},
    {-2139.7183,-2537.2058,133.3642},
    {-2064.1782,-2501.1904,133.3642},
    {337.6941,-2050.4351,76.3642},
    {1156.3256,-2038.5756,139.3642},
    {1729.3300,2191.4778,123.3642},
    {2152.8347,2287.5098,123.3642},
    {2825.8315,2480.3215,123.3642},
    {2826.7222,1345.2064,101.3642},
    {2808.3799,940.7799,101.3839},
    {2224.2256,712.5977,101.3642},
    {2056.9651,1440.2698,113.4205},
    {2118.4773,1925.5492,149.3642},
    {2231.4426,2511.4695,149.3642},
    {2039.3171,2704.9434,149.3642},
    {1542.5217,2719.9231,149.3642},
    {1007.0507,2024.0652,117.3642},
    {1081.1964,1572.2450,117.3642},
    {1054.3571,1050.7478,117.3642},
    {1509.5850,680.2148,117.4118},
    {1796.6112,1585.5521,136.3642},
    {1938.6909,1916.2496,184.3642},
    {2442.7744,1904.0750,124.3642},
}

ui.lastPos=0
ui.info=false
ui.vehicle=false
ui.banner=false

ui.timerTime=false
ui.timerFnc=function()
    if(not getElementData(localPlayer, "user:afk") and ui.vehicle and getPedOccupiedVehicle(localPlayer) == ui.vehicle and isElementInAir(ui.vehicle))then
        local data=getElementData(localPlayer, "user:pilotWeekTime") or 0
        data=tonumber(data) or 0
        data=data+1
        setElementData(localPlayer, "user:pilotWeekTime", data)
    end
end

ui.createRandomPoint=function()
    checkAndDestroy(ui.markers["point"])
    checkAndDestroy(ui.blips["point"])

    local point=false
    while(not point)do
        local rnd=math.random(1,#ui.pos)
        if(rnd ~= ui.lastPos)then
            point=rnd
        end
    end

    local v=ui.pos[point]
    if(v)then
        ui.markers["point"]=createMarker(v[1],v[2],v[3], "ring", 4, 255, 0, 0, 100)
        ui.blips["point"]=createBlipAttachedTo(ui.markers["point"], 22)
        ui.lastPos=point
    else
        ui.createRandomPoint()
    end
end

ui.timerElement=false
ui.onTimer=function()
    local data=getElementData(localPlayer, "user:jobBackTime") or 60
    if(data <= 0)then
        triggerServerEvent("stop.job", resourceRoot, localPlayer)
        return
    else
        setElementData(localPlayer, "user:jobBackTime", data-1, false)
    end
end

ui.onRender=function()
    if(ui.vehicle and isElement(ui.vehicle))then
        if(getPedOccupiedVehicle(localPlayer) ~= ui.vehicle)then
            local myPos={getElementPosition(localPlayer)}
            local vPos={getElementPosition(ui.vehicle)}
            local dist=getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], vPos[1], vPos[2], vPos[3])
            local data=getElementData(localPlayer, "user:jobBackTime")
            if(dist > 50)then
                if(not ui.timerElement)then
                    ui.timerElement=setTimer(ui.onTimer,1000,0)
                end
            else
                if(getElementData(localPlayer, "user:jobBackTime"))then
                    setElementData(localPlayer, "user:jobBackTime", false, false)

                    if(ui.timerElement and isTimer(ui.timerElement))then
                        killTimer(ui.timerElement)
                    end
                    ui.timerElement=false
                end
            end
        else
            if(getElementData(localPlayer, "user:jobBackTime"))then
                setElementData(localPlayer, "user:jobBackTime", false, false)

                if(ui.timerElement and isTimer(ui.timerElement))then
                    killTimer(ui.timerElement)
                end
                ui.timerElement=false
            end
        end
    else
        triggerLatentServerEvent("stop.job", resourceRoot, localPlayer)
    end

    if(ui.banner and not isPlayerHaveAccess())then
        triggerServerEvent("get.banner", resourceRoot)
        ui.banner=false
    end
end

ui.onMarkerHit=function(hit, dim)
    if(hit ~= localPlayer or not dim or not isPedInVehicle(hit))then return end

    if(SPAM.getSpam())then return end

    if(source == ui.markers["point"])then
        if(ui.banner)then
            ui.createRandomPoint()

            triggerServerEvent("get.payment", resourceRoot)

            noti:noti("Udaj się do następnego punktu na mapie.", "info")

            if(ui.timer)then
                killTimer(ui.timer)
                ui.timer=nil
            end

            ui.banner=false
            ui.timer=setTimer(function()
                triggerServerEvent("get.banner", resourceRoot)
                ui.timer=nil
            end, 10000, 1)
        else
            noti:noti("Najpierw rozłóż banner!", "error")
        end
    end
end

ui.onBind=function()
    if(SPAM.getSpam())then return end

    if(not ui.banner)then
        if(isPlayerHaveAccess())then
            triggerServerEvent("get.banner", resourceRoot, true)
            ui.banner=true
        else
            noti:noti("Aby wysunąć banner podleć bliżej punktu!", "error")
        end
    end
end

addEvent("start.job", true)
addEventHandler("start.job", resourceRoot, function(info, veh)
    if(info and veh)then
        ui.info=info
        ui.vehicle=veh
    end

    addEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    addEventHandler("onClientRender", root, ui.onRender)
    addEventHandler("onClientPlayerWasted", localPlayer, wasted)

    bindKey("X", "down", ui.onBind)

    ui.blips[1]=createBlipAttachedTo(ui.vehicle, 22)

    noti:noti("Udaj się do samolotu, który został oznaczony na mapie.", "info")

    if(ui.timerTime)then return end
    ui.timerTime=setTimer(ui.timerFnc, (1000*60), 0)
end)

addEvent("destroy.veh.blip", true)
addEventHandler("destroy.veh.blip", resourceRoot, function()
    checkAndDestroy(ui.blips[1])
    ui.blips[1]=nil

    ui.createRandomPoint()

    noti:noti("Rozpocznij lot i wlatuj w punkty oznaczone na mapie. Pamiętaj aby najpierw wysunąć banner!", "info")
    noti:noti("Stan paliwa jest niski, dotankuj paliwo obok hangarów.", "info")
end)

function wasted()
    triggerServerEvent("stop.job", resourceRoot)
    stopJob()
end

function stopJob()
    if(ui.timerElement and isTimer(ui.timerElement))then
        killTimer(ui.timerElement)
    end
    ui.timerElement=false
    setElementData(localPlayer, "user:jobBackTime", false, false)

    if(ui.timer and isTimer(ui.timer))then
        killTimer(ui.timer)
    end
    ui.timer=false

    if(ui.timerTime and isTimer(ui.timerTime))then
        killTimer(ui.timerTime)
    end
    ui.timerTime=false
    
    removeEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientPlayerWasted", localPlayer, wasted)

    unbindKey("X", "down", ui.onBind)

    for i,v in pairs(ui.markers) do
        checkAndDestroy(v)
    end
    ui.markers={}

    for i,v in pairs(ui.blips) do
        checkAndDestroy(v)
    end
    ui.blips={}
end
addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, stopJob)

-- useful

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
        element=nil
    end
end

-- export

function isHaveBanner()
    return ui.banner
end

function isPlayerHaveAccess()
    local access=false
    local marker=ui.markers["point"]
    if(marker and isElement(marker))then
        local iPos={getElementPosition(marker)}
        local mPos={getElementPosition(localPlayer)}
        local dist=getDistanceBetweenPoints3D(iPos[1], iPos[2], iPos[3], mPos[1], mPos[2], mPos[3])
        if(dist <= 200)then
            access=true
        end
    end
    return access
end

function getBannerInfo()
    local info="BRAK MOŻLIWOŚCI"

    if(isPlayerHaveAccess())then
        info="MOŻLIWOŚĆ ROZŁOŻENIA"
    end

    return info
end

function isElementInAir(element)
    local x, y, z = getElementPosition(element)
    local gZ = getGroundPosition(x, y, z)
    if element then 
		gZ=gZ+10
        return (z-gZ) > 0
    end
	return false
end