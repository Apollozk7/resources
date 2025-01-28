--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local noti=exports.px_noti
local blur=exports.blur

ui={}

ui.markers={}
ui.blips={}

ui.pos={
    {points={
        {2670.8970,-868.1492,148.8203},
        {2614.9070,-869.2083,148.8203},
        {2552.9141,-870.1379,148.8203},
        {2481.9333,-871.7430,148.8203},
        {2416.9568,-873.4887,148.8203},
    }},

    {points={
        {2625.2214,-198.5988,112.8203},
        {2551.2346,-199.9996,112.8203},
        {2480.2473,-201.3435,112.8203},
        {2417.2585,-202.5360,112.8203},
    }},

    {points={
        {2573.0376,-242.5329,74.8203},
        {2517.2444,-230.8652,74.8203},
        {2465.3667,-220.0163,74.8203},
        {2410.5525,-208.5533,74.8203},
        {2354.7595,-196.8857,74.8203},
    }},

    {points={
        {2013.4487,194.1871,61.8203},
        {1976.2070,201.7372,61.8203},
        {1928.0919,211.0074,61.8203},
    }},

    {points={
        {1707.3102,159.1738,59.8203},
        {1746.7015,144.6025,59.8203},
        {1802.9749,123.7863,59.8203},
        {1852.6829,105.3986,59.8203},
        {1905.2047,85.9702,59.8203},
        {1955.8506,67.2356,59.8203},
        {1983.9873,56.8274,59.8203},
    }},

    {points={
        {1858.2908,308.8642,56.8203},
        {1820.9727,323.2641,56.8203},
        {1792.9840,334.0640,56.8203},
        {1755.6659,348.4639,56.8203},
        {1733.2750,357.1039,56.8203},
    }},

    {points={
        {1228.6161,396.0930,68.8203},
        {1237.1859,438.2304,68.8203},
        {1246.2972,476.1511,68.8203},
    }},

    {points={
        {1303.6732,-55.7466,69.8203},
        {1310.1591,-20.3356,69.8203},
        {1316.8251,16.0589,69.8203},
        {1324.0516,56.4170,69.8203},
        {1330.7495,93.8221,69.8203},
    }},

    {points={
        {813.0162,294.3257,69.8203},
        {856.9740,310.9603,69.8203},
        {930.8605,338.9207,69.8203},
        {988.8474,360.8642,69.8203},
        {1050.5752,384.2240,69.8203},
    }},

    {points={
        {-202.0334,182.9230,23.8203},
        {-187.9503,167.3452,23.8203},
        {-173.8673,151.7675,23.8203},
        {-153.7486,129.5135,23.8203},
        {-136.9831,110.9685,23.8203},
        {-120.8882,93.1653,23.8203},
    }},

    {points={
        {-242.0692,-1478.9313,42.4603},
        {-271.5046,-1506.0156,42.4603},
        {-300.2039,-1532.4230,42.4603},
        {-328.1674,-1558.1532,42.4603},
    }},

    {points={
        {-141.1863,59.4647,36.8203},
        {-155.2837,24.1765,36.8203},
        {-167.8973,-7.3972,36.8203},
        {-179.3979,-36.1850,36.8203},
        {-189.4145,-61.2583,36.8203},
        {-203.5123,-96.5464,36.8203},
    }},

    {points={
        {-254.0434,-89.5302,36.8203},
        {-244.6362,-61.0433,36.8203},
        {-235.2289,-32.5564,36.8203},
        {-225.1945,-2.1704,36.8203},
        {-214.5330,30.1148,36.8203},
        {-203.8714,62.3999,36.8203},
        {-195.7185,87.0886,36.8203},
    }},

    {points={
        {-556.9385,-1658.8374,65.4603},
        {-592.9055,-1657.2970,65.4603},
    }},

    {points={
        {83.7319,-64.3825,22.8203},
        {69.4519,-35.7455,22.8203},
        {56.9289,-10.7021,22.8203},
        {43.9162,15.2144,22.8203},
        {29.8325,42.8306,22.8203},
        {15.9117,70.5278,22.8203},
    }},

    {points={
        {-520.8207,-1396.6550,41.4603},
        {-464.3553,-1388.8665,41.4603},
        {-393.0306,-1379.0282,41.4603},
    }},

    {points={
        {1176.6791,291.9892,73.8203},
        {1176.0968,224.9917,73.8203},
        {1175.7404,172.9930,73.8203},
        {1175.6997,117.9930,73.8203},
    }},

    {points={
        {-321.8447,-1297.8896,64.4603},
        {-374.4161,-1304.6158,64.4603},
        {-425.9957,-1311.2152,64.4603},
        {-480.5510,-1318.1952,64.4603},
        {-528.1629,-1324.2867,64.4603},
    }},

    {points={
        {-304.1541,-1368.2247,45.4603},
        {-261.2055,-1370.3247,45.4603},
        {-215.2603,-1372.5712,45.4603},
    }},

    {points={
        {-512.4958,-1496.2131,40.4603},
        {-517.4934,-1544.9277,40.4603},
        {-523.8112,-1585.4381,40.4603},
        {-529.9748,-1624.9603,40.4603},
    }},
}

ui.lastPos=0
ui.info=false
ui.vehicle=false
ui.point=0
ui.points=0

ui.destroyPoints=function()
    for i,v in pairs(ui.markers) do
        checkAndDestroy(v)
    end
    ui.markers={}

    for i,v in pairs(ui.blips) do
        checkAndDestroy(v)
    end
    ui.blips={}
end

ui.createRandomPoints=function()
    ui.point=0

    ui.destroyPoints()

    local point=false
    while(not point)do
        local rnd=math.random(1,#ui.pos)
        if(rnd ~= ui.lastPos)then
            point=rnd
        end
    end

    if(point)then
        local tbl=ui.pos[point].points
        if(tbl)then
            for i,v in pairs(tbl) do
                local x,y,z=0,0,0
                if(i < #tbl)then
                    x,y,z=tbl[i+1][1], tbl[i+1][2], tbl[i+1][3]
                else
                    x,y,z=tbl[i-1][1], tbl[i-1][2], tbl[i-1][3]
                end

                local p=(i/#tbl)
                local r,g,b=interpolateBetween(0, 255, 0, 255, 0, 0, p, "Linear")
                ui.markers["point_"..i]=createMarker(v[1],v[2],v[3], "ring", 4, r, g, b, 100)
                ui.blips["point_"..i]=createBlipAttachedTo(ui.markers["point_"..i], 22)
                setMarkerTarget(ui.markers["point_"..i], x, y, z)
            end

            ui.lastPos=point
            ui.points=#tbl
        end
    else
         ui.createRandomPoints()
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
end

ui.onMarkerHit=function(hit, dim)
    if(hit ~= localPlayer or not dim or not isPedInVehicle(hit))then return end

    for i,v in pairs(ui.markers) do
        local id=tonumber(string.sub(i, 7, #i))
        if(v == source and (ui.point+1) == id)then
            ui.point=ui.point+1

            checkAndDestroy(ui.markers[i])
            checkAndDestroy(ui.blips[i])
            ui.markers[i]=nil
            ui.blips[i]=nil

            if(ui.point == 1)then
                setPedControlState(localPlayer, "sub_mission", true)
            elseif(ui.point == ui.points)then
                ui.createRandomPoints()

                triggerLatentServerEvent("get.payment", resourceRoot)

                setTimer(function()
                    noti:noti("Udaj się do następnego punktu na mapie.", "info")     
                end, 500, 1)

                setPedControlState(localPlayer, "sub_mission", false)
            end
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

    ui.blips[1]=createBlipAttachedTo(ui.vehicle, 22)

    noti:noti("Udaj się do samolotu, który został oznaczony na mapie.", "info")

    toggleControl("sub_mission", false)
end)

addEvent("destroy.veh.blip", true)
addEventHandler("destroy.veh.blip", resourceRoot, function()
    checkAndDestroy(ui.blips[1])
    ui.blips[1]=nil

    ui.createRandomPoints()

    noti:noti("Rozpocznij lot i wlatuj w punkty oznaczone na mapie.", "info")
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
    
    removeEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientPlayerWasted", localPlayer, wasted)

    ui.destroyPoints()

    toggleControl("sub_mission", true)
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