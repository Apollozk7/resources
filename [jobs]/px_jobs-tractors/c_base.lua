--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

local ui={}

-- assets

assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 15},
    },

    textures={},
    textures_paths={
        "textures/bg.png",

        "textures/plus.png",
        "textures/minus.png",

        "textures/button_D.png",
        "textures/button_S.png",
        "textures/button_A.png",
        "textures/button_W.png",
        "textures/button_D.png",
    },
}

assets.create = function()
    for k,t in pairs(assets) do
        if(k=="fonts_paths")then
            for i,v in pairs(t) do
                assets.fonts[i] = dxCreateFont(v[1], v[2]/zoom)
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

ui.zones={}
ui.markers={}
ui.objects={}
ui.blips={}

ui.effect=false

ui.action=false
ui.onVehicle=false
ui.lastPoints=false
ui.invObject=false
ui.lastPark=false

ui.parks={
    {zone={-641.96289, -1563.99866, -1.86753, 125.41583251953, 123.23425292969, 29.899999046326},points={
        {-612.0724,-1513.1506,15.0248},
        {-572.4993,-1532.7648,9.8088},
        {-532.6967,-1543.2826,8.1706},
        {-544.8018,-1499.0552,9.6623},
        {-584.8328,-1452.1499,11.1629},
        {-623.4871,-1472.5433,16.2239},
        {-618.0927,-1539.1727,16.0072},
    }},

    {zone={-1472.32544, -1606.04199, 87.00723, 244.296875, 229.81079101562, 49.899992370605},points={
        {-1250.3741,-1442.9598,107.2056},
        {-1292.5396,-1451.9177,103.6641},
        {-1338.1577,-1448.9689,103.6641},
        {-1375.5857,-1514.1145,102.2260},
        {-1375.7338,-1579.5679,102.3604},
        {-1408.9203,-1478.0197,101.7691},
        {-1458.0892,-1437.2803,101.3255},
        {-1445.8151,-1408.2810,102.2182},
        {-1387.5386,-1461.3291,101.6343},
    }},

    {zone={-1639.18481, -1487.11023, 28.32137, 136.2490234375, 224.69921875, 116.8999961853},points={
        {-1526.7018,-1459.5348,40.2822},
        {-1574.4656,-1459.9313,40.5699},
        {-1575.0602,-1405.7183,46.8936},
        {-1583.4673,-1343.2235,50.1225},
        {-1625.8885,-1306.5596,54.2098},
        {-1625.9071,-1272.7686,58.2044},
        {-1573.7335,-1311.8773,55.5665},
        {-1629.5269,-1309.4486,53.6711},
    }},

    {zone={-2425.88770, 196.61571, 24.08107, 168.98291015625, 227.96397399902, 32.9},points={
        {-2387.5400,302.9801,35.1719},
        {-2341.5881,333.3162,35.1719},
        {-2328.3716,361.0617,35.1719},
        {-2290.7100,358.4738,35.1650},
        {-2274.8987,335.2073,35.7656},
        {-2268.0242,303.9029,35.5791},
        {-2294.9314,289.0957,38.8550},
        {-2387.8315,221.8935,35.1880},
        {-2348.8816,325.3806,35.1719},
    }},
    
    {zone={-200.97089, -1708.70593, -2.18145, 133.52075195312, 145.03918457031, 25.9},points={
        {-108.8015,-1609.7749,2.6172},
        {-115.5344,-1592.0837,2.6172},
        {-151.7940,-1613.7218,4.3660},
        {-187.3990,-1601.4600,6.0105},
        {-171.4974,-1582.2432,6.9574},
        {-142.1929,-1589.3706,7.0756},
        {-176.0353,-1588.9341,6.9047},
    }},

    {zone={-1029.74634, -1771.86963, 60, 153.36614990234, 177.90368652344, 49.9},points={
        {-935.5491,-1685.7557,76.8748},
        {-914.2440,-1710.4805,78.0495},
        {-909.1715,-1751.9885,76.7395},
        {-936.8392,-1750.2625,76.1334},
        {-971.9961,-1733.9485,77.8916},
        {-1009.7383,-1725.3851,77.8773},
        {-992.2198,-1685.7922,76.3456},
        {-1007.1193,-1659.2029,76.3672},
        {-970.4756,-1635.1588,76.3739},
    }},

    {zone={-2854.48950, -2103.75708, 21.25756, 177.63500976562, 135.26477050781, 34.9},points={
        {-2840.4553,-1989.0780,38.2693},
        {-2816.0879,-2001.5052,38.3800},
        {-2772.4602,-1997.4418,38.9863},
        {-2745.9375,-2016.7048,38.5186},
        {-2712.7446,-2036.4763,36.8088},
        {-2689.7249,-2085.4592,37.1657},
        {-2724.6484,-2072.5964,33.4363},
    }},

    {zone={-2921.56836, -1282.57202, -2.00169, 146.43041992188, 163.81188964844, 41.9},points={
        {-2890.6794,-1184.2799,8.4816},
        {-2855.2332,-1164.5343,12.2966},
        {-2807.3198,-1131.3929,15.6659},
        {-2822.8755,-1151.1659,15.6719},
    }},

    {zone={-2383.17871, -2383.41846, -0.47352, 126.93041992188, 145.9228515625, 49.900001907349},points={
        {-2270.4006,-2281.2246,26.5593},
        {-2271.6689,-2330.2964,27.6156},
        {-2309.8159,-2308.3835,23.0437},
        {-2325.6475,-2304.4478,22.4964},
        {-2357.6694,-2292.3804,19.2316},
        {-2310.7678,-2364.2786,34.2127},
        {-2288.0085,-2360.1848,33.6675},
        {-2320.7703,-2255.6069,20.4942},
    }},

    {zone={-2023.80554, -2056.77271, 21.49421, 218.98596191406, 289.60302734375, 108.89999237061}, points={
        {-2009.7155,-2016.3942,81.2341},
        {-2005.0117,-1976.5544,81.6085},
        {-1990.8250,-1952.9504,81.8903},
        {-1979.4266,-1927.9756,79.3123},
        {-1936.6166,-1901.8138,84.7993},
        {-1904.3922,-1892.5859,86.7196},
        {-1867.0649,-1900.6632,89.1286},
        {-1855.1760,-1875.4623,88.4791},
        {-1908.1406,-1967.5542,86.5503},
        {-1864.7969,-1966.2986,87.8727},
    }},

    {zone={-440.46936, -1193.14453, 12.99445, 125.07528686523, 163.42199707031, 83.9},points={
        {-376.1792,-1147.7510,69.6581},
        {-366.7599,-1120.2178,70.5377},
        {-396.9100,-1112.0209,67.6514},
        {-427.7559,-1176.8555,62.1108},
        {-423.0802,-1076.5081,56.8376},
        {-365.0739,-1089.2657,60.0495},
        {-347.6531,-1097.7397,62.2705},
    }},

    {zone={-118.16674, -862.25592, -9.28299, 148.90554046631, 259.83013916016, 38.9},points={
        {-48.1262,-755.8689,11.9528},
        {-52.2274,-729.0790,10.5846},
        {-23.9570,-699.9769,12.0960},
        {-14.3256,-671.4844,11.6467},
        {5.0657,-628.0145,9.9839},
        {-76.7717,-692.6829,1.0026},
        {-72.9886,-772.9207,8.1148},
        {-70.1485,-808.5099,8.6780},
    }},

    {zone={207.17105, -559.56958, -6.28886, 115.60668945312, 116.455078125, 42.9},points={
        {291.3195,-536.9492,18.8935},
        {282.4876,-513.5448,20.4945},
        {259.4330,-511.9305,20.0871},
        {242.2263,-496.4832,19.9808},
        {229.3520,-479.1223,18.7262},
        {244.8439,-461.9873,13.1191},
        {274.0199,-467.0006,12.6317},
        {299.5277,-500.9437,11.2782},
        {289.4459,-518.1441,20.4977},
        {267.6061,-494.1850,20.4248},
        {246.1474,-487.2669,20.1276},
    }},

    {zone={-654.15979, -148.65773, 25.76669, 153.93411254883, 194.26132583618, 67.900003814697},points={
        {-590.8969,-92.8088,64.7979},
        {-617.8505,-107.4475,65.6656},
        {-637.4498,-74.2819,64.7564},
        {-634.8625,-14.0807,63.0180},
        {-593.3310,-16.5073,63.2018},
        {-553.0423,18.4798,61.7224},
        {-554.9764,-19.3467,63.2952},
        {-556.7653,-41.2026,64.1093},
        {-522.1063,-50.1745,61.9778},
        {-503.5642,-106.9106,63.7138},   
    }},

    {zone={-914.78271, -225.57626, 32.82031, 144.88494873047, 91.043228149414, 50.9},points={
        {-894.3780,-205.2718,64.9990},
        {-866.8774,-202.7868,66.1238},
        {-871.4800,-177.8753,66.1103},
        {-848.3267,-148.9556,63.3057},
        {-807.6182,-146.7444,63.8500},
        {-785.5626,-147.5801,64.6458},
        {-776.9165,-176.3229,67.6655},
        {-818.2920,-158.3609,63.6305},
    }},

    {zone={-615.49670, 151.54781, -8.51884, 173.09274291992, 89.377075195312, 43.9},points={
        {-593.2138,178.7139,22.9773},
        {-567.8304,185.0734,12.4131},
        {-539.9481,234.4296,13.2766},
        {-517.2399,205.6959,11.0420},
        {-495.8395,185.4099,7.4212},
        {-455.0127,165.4671,6.9539},
        {-451.5308,205.5077,7.4473},
        {-495.9759,229.3603,10.1078}, 
    }},

    {zone={-2886.59961, -372.85233, -10.86315, 68.63671875, 150.71870422363, 33.9},points={
        {-2852.1213,-319.4695,12.4233},
        {-2838.4319,-298.8672,9.6316},
        {-2824.3110,-280.0688,7.6086},
        {-2839.4753,-260.1814,11.2752},
        {-2850.3110,-234.7034,10.5748},
        {-2828.4187,-233.2906,8.1472},
    }},

    {zone={-1998.31201, -60.86300, 25, 37.510864257812, 134.1011390686, 35},points={
        {-1971.0205,63.2976,28.3216},
        {-1984.7168,58.4892,28.5238},
        {-1990.7958,36.7942,32.0018},
        {-1978.9432,17.9535,33.2159},
        {-1972.1444,15.6652,33.4628},
        {-1972.7429,-8.0496,35.3134},
        {-1985.5640,-20.2790,35.2513},
        {-1978.0852,-39.7169,35.3203},
        {-1971.9725,-43.0693,35.3203},
        {-1974.8950,-51.4121,35.3203},
        {-1993.5596,-22.2524,35.2021},
    }},

    {zone={-1812.54077, -564.83032, 10.77707, 42.821899414062, 195.81558227539, 31.9},points={
        {-1806.8646,-511.0853,15.1172},
        {-1803.4974,-483.4407,15.1172},
        {-1786.3282,-513.0337,15.1129},
        {-1786.2762,-506.9481,15.1129},
        {-1786.4622,-500.7250,15.1172},
        {-1798.0731,-457.1111,15.1172},
        {-1797.8042,-448.0570,15.1172},
        {-1785.4149,-417.5379,15.1172},
        {-1795.6813,-399.9246,15.9348},
    }},

    {zone={-902.60449, -2757.99902, 60, 193.40808105469, 174.10522460938, 70},points={
        {-885.9156,-2631.2993,97.3517},
        {-854.4751,-2612.5415,94.6315},
        {-829.4679,-2591.9055,89.5651},
        {-799.7462,-2609.9392,86.4271},
        {-724.2556,-2611.0232,74.6806},
        {-749.8666,-2653.1084,83.3678},
        {-771.6597,-2707.6816,83.7923},
        {-752.6808,-2714.5386,86.1140},
        {-728.0610,-2699.2664,89.2170},
        {-713.7834,-2744.0359,97.2006},
        {-810.0305,-2714.8606,88.7355},
    }},
}

ui.onVehicleEnter=function(plr,seat)
    if(plr ~= localPlayer)then return end

    if(ui.onVehicle and source == ui.tractor)then cancelEvent() return end
    if((ui.action == "zaladuj traktor" or ui.action == "rozladuj traktor") and source == ui.vehicle)then cancelEvent() return end
    if(ui.action == "rozladuj traktor" and source == ui.tractor)then cancelEvent() return end

    ui.vehIn=false
end

ui.timerElement=false
ui.onTimer=function()
    local data=getElementData(localPlayer, "user:jobBackTime") or 60
    if(data <= 0)then
        triggerLatentServerEvent("stop.job", resourceRoot, localPlayer)
        return
    else
        setElementData(localPlayer, "user:jobBackTime", data-1, false)
    end
end

ui.minigame={}
ui.minigameAlpha={}
ui.minigamePos={}
ui.minigameKeys={
    [0]="d",
    [90]="s",
    [180]="a",
    [270]="w",
    [360]="d",
}
ui.minigamePoints=0

ui.minigameInfo={}
ui.addMinigameInfo=function(type)
    ui.minigameInfo[#ui.minigameInfo+1]={
        type=type,
        tick=getTickCount(),
        posY=0,
        posX=type == "remove" and sw/2+240/zoom+110/zoom+math.random(100,400) or sw/2-240/zoom-math.random(100,400)
    }
end

ui.minigameKey=function(button, press)
    if(not press)then return end

    local add=false

    local pos=ui.minigame[1]
    local yep=1
    for i,v in pairs(ui.minigamePos) do
        if(v > pos)then
            pos=v
            yep=i
        end
    end

    for i=1,4 do
        local arrow=ui.minigame[i]
        arrow=(arrow-1)*90

        local key=ui.minigameKeys[arrow]
        if(ui.minigamePos[i] > 415 and ui.minigamePos[i] < 600 and yep == i)then
            if(button == key)then
                add=true

                ui.minigamePos[i]=(-300)*i
                ui.minigamePoints=ui.minigamePoints+1
                ui.minigame[i]=math.random(1,4)

                ui.addMinigameInfo("success")

                if(ui.minigamePoints >= 10)then
                    assets.destroy()
                    removeEventHandler("onClientRender",root,ui.minigameRender)
                    removeEventHandler("onClientKey",root,ui.minigameKey)
        
                    checkAndDestroy(ui.effect)

                    local x,y,z=getElementPosition(ui.markers[ui.lastPoints])
                    ui.effect=createEffect("prt_smoke_huge",x,y,z)
                    setTimer(function()
                        checkAndDestroy(ui.effect)
                        ui.effect=false

                        checkAndDestroy(ui.sound)
                        ui.sound=false
                    end, 5000, 1)

                    ui.action="udaj sie po pien"

                    setElementFrozen(ui.tractor, false)
                    setElementFrozen(localPlayer, false)

                    toggleControl("enter_exit",true)

                    if(ui.lastPoints)then
                        local m=ui.markers[ui.lastPoints]
                        local o=ui.objects[ui.lastPoints]
                        local b=ui.blips[ui.lastPoints]
                        checkAndDestroy(m)
                        checkAndDestroy(o)
                        checkAndDestroy(b)
                        ui.markers[ui.lastPoints]=nil
                        ui.objects[ui.lastPoints]=nil
                        ui.blips[ui.lastPoints]=nil
                        ui.lastPoints=false
            
                        triggerServerEvent("get.payment", resourceRoot)
            
                        setElementData(ui.tractor, "vehicle:components", {"Job_2"})

                        local m=0
                        for i,v in pairs(ui.markers) do
                            if(string.find(i,"pien") and isElement(v))then
                                m=m+1
                                break
                            end
                        end
                        if(m == 0)then
                            setElementData(ui.vehicle, "interaction", {options={
                                {name="Załaduj traktor", alpha=150, animate=false, tex=":px_jobs-tractors/textures/interaction.png"},
                            }, scriptName="px_jobs-tractors", dist=10}, false)
                
                            ui.action="zaladuj traktor"

                            exports.px_noti:noti("Załaduj traktor na lawete.", "info")

                            setElementData(localPlayer, "user:jobs_todo",{
                                {name="Przygotuj lawetę do załadunku traktora", done=true},
                                {name="Załaduj traktor na lawete"},
                                {name="Udaj się do parku"},
                                {name="Wyładuj traktor"},
                                {name="Udaj się usuwać pnie"}
                            }, false)

                            ui.minigameInfo={}
                        end
                    end
                end
            else
                ui.minigamePos[i]=(-300)*i
                ui.minigame[i]=math.random(1,4)

                if(ui.minigamePoints > 0)then
                    ui.minigamePoints=ui.minigamePoints-1
                    ui.addMinigameInfo("remove")
                end
            end

            break
        end
    end
end

ui.minigameRender=function()
    exports.blur:dxDrawBlur(0,0,sw,sh)

    for i,v in pairs(ui.minigameInfo) do
        if((getTickCount()-v.tick) < 2500)then            
            local a=interpolateBetween(255,0,0,0,0,0,(getTickCount()-v.tick)/2500, "Linear")
            if(v.type == "remove")then
                v.posY=interpolateBetween(-100/zoom,0,0,sh/2,0,0,(getTickCount()-v.tick)/2500, "Linear")

                dxDrawImage(v.posX, v.posY, 100/zoom, 100/zoom, assets.textures[3], 0, 0, 0, tocolor(255,255,255,a))
            else
                v.posY=interpolateBetween(sh,0,0,sh/2,0,0,(getTickCount()-v.tick)/2500, "Linear")

                dxDrawImage(v.posX, v.posY, 100/zoom, 100/zoom, assets.textures[2], 0, 0, 0, tocolor(255,255,255,a))
            end
        else
            table.remove(ui.minigameInfo,i)
        end
    end

    local sx=sw/2-455/2/zoom
    for i=1,4 do
        local mx=(119/zoom)*(i-1)
        dxDrawRectangle(sx+mx, sh-566/zoom, 1, 566/zoom, tocolor(80,80,80))
        dxDrawRectangle(sx+mx+101/zoom, sh-566/zoom, 1, 566/zoom, tocolor(80,80,80))

        dxDrawRectangle(sx+mx, sh-566/zoom+52/zoom, 101/zoom, 103/zoom, tocolor(80,80,80,150))

        local ay=ui.minigamePos[i]
        local arrow=ui.minigame[i]
        
        local ayP=ay-500
        local a=255
        if(ay > 500)then
            a=interpolateBetween(255, 0, 0, 0, 0, 0, (ayP/100), "Linear")
        end
        dxDrawImage(sx+mx+(101-78)/2/zoom, sh-566/zoom+52/zoom+(101-78)/2/zoom+(500-ay)/zoom, 78/zoom, 78/zoom, assets.textures[3+arrow], 0, 0, 0, tocolor(255, 255, 255, a))

        ui.minigamePos[i]=ui.minigamePos[i]+6

        if(ui.minigamePos[i] > 600)then
            ui.minigamePos[i]=(-300)*i            
            ui.minigame[i]=math.random(1,4)

            if(ui.minigamePoints > 0)then
                ui.minigamePoints=ui.minigamePoints-1
                ui.addMinigameInfo("remove")
            end
        end
    end

    dxDrawImage(sw/2-454/2/zoom, sh-670/zoom, 454/zoom, 48/zoom, assets.textures[1])
    dxDrawText("Posiadane punkty "..ui.minigamePoints.."/10", 0, sh-670/zoom, sw, sh-670/zoom+48/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")
end

ui.createMinigame=function()
    assets.create()

    addEventHandler("onClientRender",root,ui.minigameRender)
    addEventHandler("onClientKey",root,ui.minigameKey)

    ui.minigame={math.random(1,4),math.random(1,4),math.random(1,4),math.random(1,4)}
    ui.minigameAlpha={255,255,255}
    ui.minigamePos={}

    for i=1,4 do
        ui.minigamePos[i]=(-300)*i
    end

    ui.minigamePoints=0

    ui.minigameInfo={}

    toggleControl("enter_exit",false)

    checkAndDestroy(ui.sound)

    local rnd=math.random(1,4)
    local x,y,z=getElementPosition(ui.tractor)
    ui.sound=playSound3D("sounds/chainsaw"..rnd..".mp3", x, y, z, true)
    setSoundVolume(ui.sound,0.1)
end

ui.onRender=function()
    if(ui.action == "minigra")then return end

    if(ui.invObject and isElement(ui.invObject) and getPedOccupiedVehicle(localPlayer) == ui.tractor and ui.action == "udaj sie po pien")then
        local speed=getElementSpeed(ui.tractor)
        local elements=getElementsWithinColShape(ui.invObject)
        if(#elements > 0)then
            if(speed <= 25)then
                for _,element in pairs(elements) do
                    if(getElementType(element) == "marker")then
                        for i,v in pairs(ui.markers) do
                            if(element == v)then
                                ui.createMinigame()

                                setElementFrozen(ui.tractor, true)
                                setElementFrozen(localPlayer, true)
                    
                                setElementData(ui.tractor, "vehicle:components", {"Job_1"})
                    
                                ui.action="minigra"

                                ui.lastPoints=i
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    local v=ui.zones["tractor"]
    if(v and isElement(v))then
        local myPos={getElementPosition(localPlayer)}
        local x,y,z=getElementPosition(v)
        local xx,yy,zz=getColShapeSize(v)

        local pos={
            {x,y,x+xx,y},
            {x,y,x,y+yy},
            {x+xx,y+yy,x+xx,y},
            {x+xx,y+yy,x,y+yy}
        }
        
        for i,v in pairs(pos) do
            dxDrawLine3D(v[1], v[2], z, v[3], v[4], z, tocolor(0,150,0), 1)
        end

        if(ui.action == "jedz po traktor")then
            local el=getElementsWithinColShape(v)
            for i,v in pairs(el) do
                local rPos={getElementPosition(ui.vehicle)}
                local rot=findRotation(rPos[1],rPos[2],myPos[1],myPos[2])
                local _,_,r_rot=getElementRotation(ui.tractor)
                if(getElementType(v) == "vehicle" and v == ui.vehicle and rot > (r_rot-20) and rot < (r_rot+20))then
                    local todo=getElementData(localPlayer, "user:jobs_todo")
                    if(todo)then
                        todo[1].done=true
                        setElementData(localPlayer, "user:jobs_todo",todo,false)
            
                        exports.px_noti:noti("Następnie wysiądź z pojazdu i użyj interakcji aby załadować pojazd.", "info")
                        
                        checkAndDestroy(ui.blips["tractor"])
                        ui.blips["tractor"]=nil
                
                        checkAndDestroy(ui.zones["tractor"])
                        ui.zones["tractor"]=nil
            
                        setPedControlState("enter_exit", true)
                        setTimer(function()
                            setPedControlState("enter_exit", false)
                        end, 50, 1)
            
                        setElementData(ui.vehicle, "interaction", {options={
                            {name="Załaduj traktor", alpha=150, animate=false, tex=":px_jobs-tractors/textures/interaction.png"},
                        }, scriptName="px_jobs-tractors", dist=10}, false)
            
                        ui.action="zaladuj traktor"
                    end
                end
            end
        end
    end

    local ped=getPedOccupiedVehicle(localPlayer)
    local vehicle=ped == ui.tractor and ui.vehicle or ped == ui.vehicle and ui.tractor or ui.vehicle
    if(vehicle and isElement(vehicle))then
        local myPos={getElementPosition(localPlayer)}
        local vPos={getElementPosition(vehicle)}
        local dist=getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], vPos[1], vPos[2], vPos[3])
        local data=getElementData(localPlayer, "user:jobBackTime")
        if(dist > 200)then
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
    end
end

ui.onColShapeHit=function(hit, dim)
    if(hit ~= localPlayer or not dim or not isPedInVehicle(hit))then return end

    local veh=getPedOccupiedVehicle(hit)
    if(veh ~= ui.vehicle)then return end

    if(source == ui.zones["park"] and ui.action == "udaj sie do parku")then
        local todo=getElementData(localPlayer, "user:jobs_todo")
        if(todo)then
            todo[3].done=true
            setElementData(localPlayer, "user:jobs_todo",todo,false)

            exports.px_noti:noti("Następnie wysiądź z pojazdu i użyj interakcji aby wyładować pojazd.", "info")

            checkAndDestroy(ui.zones["park"])
            ui.zones["park"]=nil

            checkAndDestroy(ui.blips["park"])
            ui.blips["park"]=nil

            setElementData(ui.vehicle, "interaction", {options={
                {name="Rozładuj traktor", alpha=150, animate=false, tex=":px_jobs-tractors/textures/interaction.png"},
            }, scriptName="px_jobs-tractors", dist=10}, false)

            if(ui.onVehicle)then
                ui.action="rozladuj traktor"
            else
                ui.action="udaj sie po pien"
            end
        end
    end
end

function action(id, element, name, info)
    if(element == ui.vehicle)then
        if(name == "Rozładuj traktor")then
            if(ui.action ~= "rozladuj traktor")then return end

            setElementData(ui.vehicle, "interaction", false, false)
    
            exports.px_noti:noti("Trwa wyładunek traktora z lawety...", "info")
        
            if(ui.upgrades["Załadunek"])then
                ui.action="udaj sie po pien"
                
                ui.onVehicle=false

                local pos={getStraightPosition(ui.vehicle)}
                triggerServerEvent("detach.tractor", resourceRoot, pos)
    
                local todo=getElementData(localPlayer, "user:jobs_todo")
                if(todo)then
                    todo[4].done=true
                    setElementData(localPlayer, "user:jobs_todo",todo,false)
                end
            else
                setElementFrozen(localPlayer, true)
                exports.px_progressbar:createProgressbar(sw/2-671/2/zoom, sh-50/zoom, 671/zoom, 4/zoom, "Trwa wyładunek traktora z lawety...", 15/zoom, 10000, false, 0)
                setTimer(function()
                    ui.action="udaj sie po pien"

                    ui.onVehicle=false
                    setElementFrozen(localPlayer, false)

                    exports.px_progressbar:destroyProgressbar()

                    local pos={getStraightPosition(ui.vehicle)}
                    triggerServerEvent("detach.tractor", resourceRoot, pos)
        
                    local todo=getElementData(localPlayer, "user:jobs_todo")
                    if(todo)then
                        todo[4].done=true
                        setElementData(localPlayer, "user:jobs_todo",todo,false)
                    end
                end, 10000, 1)
            end
        else
            if(ui.action == "zaladuj traktor")then
                local m=0
                for i,v in pairs(ui.markers) do
                    if(string.find(i,"pien") and isElement(v))then
                        m=m+1
                        break
                    end
                end

                if(m == 0)then
                    ui.onVehicle=true

                    setElementData(ui.vehicle, "interaction", false, false)
            
                    exports.px_noti:noti("Trwa załadunek traktora na lawete...", "info")
            
                    if(ui.upgrades["Załadunek"])then
                        triggerServerEvent("attach.tractor", resourceRoot)
                        
                        local todo=getElementData(localPlayer, "user:jobs_todo")
                        if(todo)then
                            todo[2].done=true
                            setElementData(localPlayer, "user:jobs_todo",todo,false)
                        end

                        ui.action="udaj sie do parku"
                    else
                        setElementFrozen(localPlayer, true)

                        exports.px_progressbar:createProgressbar(sw/2-671/2/zoom, sh-50/zoom, 671/zoom, 4/zoom, "Trwa załadunek traktora na lawete...", 15/zoom, 10000, false, 0)
                        setTimer(function()
                            exports.px_progressbar:destroyProgressbar()

                            setElementFrozen(localPlayer, false)
                    
                            triggerServerEvent("attach.tractor", resourceRoot)
                        
                            local todo=getElementData(localPlayer, "user:jobs_todo")
                            if(todo)then
                                todo[2].done=true
                                setElementData(localPlayer, "user:jobs_todo",todo,false)
                            end

                            ui.action="udaj sie do parku"
                        end, 10000, 1)
                    end
                else
                    exports.px_noti:noti("Najpierw usuń wszystkie pnie w parku.", "error")
                end
            end
        end
    end
end

addEvent("start.job", true)
addEventHandler("start.job", resourceRoot, function(vehicle, tractor, upgrades, col)
    setElementData(localPlayer, "user:jobBackTime",false,false)

    addEventHandler("onClientRender", root, ui.onRender)
    addEventHandler("onClientPlayerWasted", localPlayer, wasted)
    addEventHandler("onClientColShapeHit", resourceRoot, ui.onColShapeHit)
    addEventHandler("onClientVehicleStartEnter", resourceRoot, ui.onVehicleEnter)

    ui.upgrades=upgrades
    ui.vehicle=vehicle
    ui.tractor=tractor
    ui.invObject=createColSphere(0,0,0,1)
    attachElements(ui.invObject,ui.tractor,0,-2.5,-0.5)

    ui.blips["laweta"]=createBlipAttachedTo(vehicle, 24)
    ui.zones["tractor"]=createColCuboid(unpack(col))
    ui.blips["tractor"]=createBlipAttachedTo(ui.zones["tractor"],22)

    setElementData(localPlayer, "user:jobs_todo",{
        {name="Przygotuj lawetę do załadunku traktora"},
        {name="Załaduj traktor na lawete"},
        {name="Udaj się do parku"},
        {name="Wyładuj traktor"},
        {name="Udaj się usuwać pnie"}
    }, false)

    setElementData(ui.tractor, "vehicle:components", {"Job_2"})

    ui.action="jedz po traktor"
end)

function wasted()
    triggerLatentServerEvent("stop.job", resourceRoot)
    stopJob()
end

function stopJob()
    if(ui.timerElement and isTimer(ui.timerElement))then
        killTimer(ui.timerElement)
    end
    ui.timerElement=false
    setElementData(localPlayer, "user:jobBackTime", false, false)
    setElementData(localPlayer, "user:jobs_todo", false, false)
    
    ui.upgrades={}

    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientPlayerWasted", localPlayer, wasted)
    removeEventHandler("onClientColShapeHit", resourceRoot, ui.onColShapeHit)
    removeEventHandler("onClientVehicleStartEnter", resourceRoot, ui.onVehicleEnter)

    for i,v in pairs(ui.markers) do
        checkAndDestroy(v)
    end
    ui.markers={}

    for i,v in pairs(ui.blips) do
        checkAndDestroy(v)
    end
    ui.blips={}

    for i,v in pairs(ui.zones) do
        checkAndDestroy(v)
    end
    ui.zones={}

    for i,v in pairs(ui.objects) do
        checkAndDestroy(v)
    end
    ui.objects={}

    checkAndDestroy(ui.invObject)
    ui.invObject=false

    ui.vehicle=false

    ui.lastPark=false

    triggerServerEvent("stop.job", resourceRoot)
end
addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, stopJob)

addEvent("stop.action", true)
addEventHandler("stop.action", resourceRoot, function(action)
    if(action == "spawn.points")then
        local rnd=math.random(1,#ui.parks)
        if(ui.lastPark and ui.lastPark == rnd)then
            local block=1
            while(ui.lastPark == rnd)do
                rnd=math.random(1,#ui.parks)

                block=block+1
                if(block >= 5)then
                    break
                end
            end
        end
        ui.lastPark=rnd
        
        local p=ui.parks[rnd]
        if(p)then
            local id=ui.upgrades["Większe pnie"] and 843 or 847
            ui.zones["park"]=createColCuboid(unpack(p.zone))
            for i,v in pairs(p.points) do
                local z=ui.upgrades["Większe pnie"] and v[3]-1 or v[3]-2.5

                ui.markers["pien_"..i]=createMarker(v[1],v[2],v[3],"cylinder",1.2,255,150,0)
                ui.objects["pien_"..i]=createObject(id,v[1],v[2],z)
                ui.blips["pien_"..i]=createBlipAttachedTo(ui.markers["pien_"..i],22)
                setElementData(ui.markers["pien_"..i],"out:icon",true,false)
                setElementCollisionsEnabled(ui.objects["pien_"..i],false)
                setElementData(ui.markers["pien_"..i], 'pos:z', v[3])
            end
        end
    end
end)

function checkAndDestroy(element)
    return isElement(element) and destroyElement(element)
end

function getElementSpeed(theElement, unit)
    local vx,vy,vz=getElementVelocity(theElement)
    local speed=math.sqrt(vx^2 + vy^2 + vz^2) * 180
    return speed
end

if(getElementData(localPlayer,"user:job") == "Usuwanie pni")then
    setElementFrozen(localPlayer,false)
end

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end

function getStraightPosition(element)
    local x,y,z = getElementPosition(element)
    local _,_,rot = getElementRotation(element)
    rot=rot+90

    local cx, cy = getPointFromDistanceRotation(x, y, -3, -rot)

    return cx,cy,z
end