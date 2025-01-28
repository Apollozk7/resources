--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui={}

ui.shader=[[
texture gTexture;

technique TexReplace
{
    pass P0
    {
        Texture[0] = gTexture;
    }
}
]]

ui.vehicle=false

ui.markers={}
ui.blips={}
ui.peds={}
ui.boxes={}
ui.zones={}

ui.info=false

ui.clientScanID=false

ui.action=""
ui.boxID=3006
ui.haveClientBox=false
ui.box=0
ui.boxesInfos={}

ui.pos={}

ui.tapes={
    {2804.7649,998.5565,12.0938},
    {2809.8098,998.5051,12.0938},
    {2814.7673,998.5167,12.0938},
    {2819.7764,998.3973,12.0938},
    {2824.7549,998.3812,12.0938},
}

ui.tapeMaxY=991.7 -- end of the tape of 'y' position

ui.points={}

ui.boxTypes={
    "Elektronika",
    "Szkło",
    "Ciecz",
    "Jedzenie",
    "Ubrania",
    "Gry",
    "Przemysłowe"
}

ui.ownersNames={
    -- Dafik --

    {"Andrzej", "Wróbel", 37},
    {"Janina", "Zając", 53},
    {"Fryderyk", "Dudek", 58},
    {"Kazimierz", "Szafrański", 59},
    {"Tadeusz", "Zięba", 170},
    {"Zbyszek", "Czajka", 206},
    {"Sebastian", "Pieczarka", 299},
    {"Tomasz", "Praniewicz", 302},
    {"Mateusz", "Podstawka", 72},
    {"Alan", "Podgórski", 20},
    {"Filip", "Litwin", 7},
    {"Kuba", "Zuchowski", 46},
    {"Tomasz", "Kita", 33},
    {"Bartosz", "Florczak", 15},
    {"Adam", "Woźniak", 48},
    {"Michał", "Szkudlarek", 29},
    {"Dominik", "Szuszkowski", 101},
    {"Grażynka", "Korczyńska", 263},
    {"Agnieszka", "Zaworska", 12},
    {"Jakub", "Mycka", 126},
    {"Adrian", "Janiak", 23},
    {"Alicja", "Kusiak", 233},
    {"Marlena", "Puk", 215},
    {"Weronika", "Gajewska", 191},
    {"Martyna", "Wilk", 201},
    {"Amelia", "Grodzka", 193},
    {"Mela", "Jankowska", 216},
    {"Beata", "Gorzelak", 13},
    {"Piotr", "Ustrzycki", 17},
    {"Dawid", "Bułkowski", 188},
    {"Kacper", "Klarecki", 210},
    {"Dominik", "Góra", 180},
    {"Dominika", "Rychlik", 169},
    {"Szymon", "Mucha", 127},
    {"Wiktor", "Waga", 240},
    {"Joanna", "Wysocka", 207},
    {"Jagoda", "Kasprzycka", 197},

    --easteregg'i 

    {"Karol", "Wojtyła", 68},
    {"Karyna", "Paździoch", 129},
    {"Mietek", "Puszkowski", 137},
    {"Władek", "Odlotowiec", 136},

    -- Dla Skipcia 

    {"Cris", "Kononovic", 220},
}

ui.pos={
    [1]={sw/2-199/2/zoom, sh/2-77/2/zoom, 199/zoom, 77/zoom},
    [2]={sw/2-43/2/zoom, sh/2-43/2/zoom, 43/zoom, 43/zoom},

    -- bg
    [3]={sw-750/zoom, sh/2-458/2/zoom, 695/zoom, 458/zoom},

    -- left
    [4]={sw-750/zoom+24/zoom+57/zoom, sh/2-458/2/zoom+24/zoom+106/zoom, 695/zoom, 458/zoom},
    [5]={sw-750/zoom+24/zoom+57/zoom, sh/2-458/2/zoom+24/zoom+137/zoom, 257/zoom, 151/zoom},

    -- right
    [6]={sw-750/zoom+24/zoom+57/zoom+276/zoom, sh/2-458/2/zoom+24/zoom+106/zoom, 695/zoom, 458/zoom},
    [7]={sw-750/zoom+24/zoom+57/zoom+276/zoom, sh/2-458/2/zoom+24/zoom+137/zoom, 257/zoom, 151/zoom},

    -- spaces
    [8]={18/zoom, 25/zoom},

    -- qr
    [9]={sw-750/zoom+24/zoom+57/zoom, sh/2-458/2/zoom+24/zoom+311/zoom, 84/zoom, 64/zoom},
    [10]={sw-750/zoom+24/zoom+175/zoom, sh/2-458/2/zoom+24/zoom+311/zoom, 84/zoom, sh/2-458/2/zoom+24/zoom+311/zoom+64/zoom}
}

ui.clients={
    {1266.2103,2606.2456,10.8203,204.1571},
    {1285.1453,2605.6406,10.8203,184.4793},
    {1278.8387,2564.4487,10.8203,269.5779},
    {1274.6854,2554.5364,10.8203,270.0914},
    {1277.5876,2522.2156,10.8203,270.5320},
    {1311.0282,2524.3569,10.8203,90.5689},
    {1313.8594,2608.9094,10.8203,181.1748},
    {1326.1562,2569.4941,10.8203,359.9630},
    {1349.5808,2572.2781,10.8203,0.0369},
    {1344.9567,2607.6375,10.8203,184.3325},
    {1359.8870,2570.9363,10.8203,0.6982},
    {1365.6742,2524.9648,10.8203,243.3658},
    {1400.8767,2524.5298,10.8203,88.6608},
    {1417.9069,2572.2568,10.8203,357.1738},
    {1442.1716,2572.8123,10.8203,0.4045},
    {1451.4091,2571.0374,10.8203,0.2577},
    {1456.9429,2525.3945,10.8203,245.1280},
    {1498.1688,2535.7893,10.8203,65.7523},
    {1503.6890,2569.7217,10.8203,0.9180},
    {1515.4769,2609.0220,10.8203,178.4585},
    {1551.8239,2570.3904,10.8203,1.0649},
    {1554.1655,2609.0513,10.8203,177.1369},
    {1564.7285,2567.3386,10.8203,1.2117},
    {1600.5897,2608.5627,10.8203,178.6054},
    {1623.1735,2571.3203,10.8203,0.4775},
    {1665.6993,2570.8999,10.8203,359.3027},
    {1666.9022,2609.2595,11.0549,183.7451},
    {1570.3418,2714.7903,10.8203,358.3486},
    {1580.2394,2712.4358,10.8203,358.2018},
    {1601.0018,2715.1799,10.8203,357.3207},
    {1608.1205,2751.3462,10.8203,178.6793},
    {1626.7795,2713.3198,10.8203,29.1869},
    {1644.3107,2749.9583,10.8203,198.9444},
    {1652.3010,2712.5256,10.8203,2.7541},
    {1662.7296,2750.7876,10.8203,178.0919},
    {1678.9711,2693.7659,10.8203,30.0680},
    {1703.7084,2691.1426,10.8203,9.9497},
    {1736.2523,2693.1260,10.8203,6.2785},
    {1550.4916,2841.6240,10.8203,190.3902},
    {1576.2322,2840.8069,10.8203,207.0211},
    {1602.1433,2843.6338,10.8203,180.5883},
    {1623.1005,2843.3210,10.8203,181.2496},
    {1637.8391,2803.0186,10.8203,1.5063},
    {1790.4963,2778.7859,14.2735,68.0290},
    {1796.8080,2803.4661,14.2735,110.9819},
    {1728.4633,2834.9546,11.3438,351.5206},
    {1890.3121,2800.4404,11.3438,82.4202},
    {1992.6714,2764.6357,10.8203,183.0118},
    {2037.5522,2722.1433,11.2989,0.3315},
    {2137.4033,2732.6006,11.1763,52.6098},
    {2193.3101,2792.2175,10.8203,181.2496},
    {2244.4087,2525.0706,10.8203,189.4731},
    {2225.3171,2522.4407,11.0222,183.4523},
    {2188.2422,2469.7756,11.2422,239.6955},
    {2098.2756,2493.8831,14.8390,183.4523},
    {2247.4458,2396.5593,10.8203,11.4191},
    {2364.2725,2378.0396,10.8203,76.4733},
    {2823.7747,2269.4207,14.6615,122.4370},
    {2788.2876,2227.1528,14.6615,267.5968},
    {2825.7283,2140.6450,14.6615,90.3715},
    {2656.3730,1980.0337,14.1161,82.3832},
    {2645.7200,2019.0081,10.8169,179.5603},
    {2408.7935,2016.0548,10.8203,275.0122},
    {2539.1572,2143.9746,10.8203,63.0058},
    {2491.4749,2163.8479,10.8203,184.5969},
    {2369.6062,2120.5845,10.8399,52.6535},
    {2326.5225,2120.4163,10.8281,0.9376},
    {2217.4338,2123.3462,10.8203,1.4770},
    {2165.3386,2165.1831,10.8203,146.0494},
    {2099.8306,2224.2976,11.0234,186.1392},
    {2127.5574,2379.2002,10.8203,178.8707},
    {2057.8003,2312.4551,10.8203,320.1394},
    {1968.4182,2295.4294,16.4559,110.0354},
    {1913.3013,2350.5713,10.9799,216.5158},
    {1742.2716,2317.4023,10.8203,142.7827},
    {1637.9185,2252.1365,11.0625,8.0122},
    {1600.3964,2218.8313,11.0625,203.4864},
    {1547.9275,2153.8232,11.4617,56.0319},
    {1548.3365,2126.5862,11.4609,65.2834},
    {1548.8031,2096.1941,11.4609,158.8262},
    {1554.6241,2074.6108,11.3594,12.2709},
    {1596.6758,2039.2894,11.4688,316.4889},
    {1596.7471,2071.7827,11.3199,326.8053},
    {1595.3385,2087.8420,11.3125,247.9474},
    {1598.2317,2118.9795,11.4617,232.3813},
    {1597.8811,2145.3132,11.4609,235.9057},
    {1813.0873,2104.5559,10.9688,122.5218},
    {1810.9994,2117.4802,10.9146,124.8139},
    {1804.5460,2127.3398,10.9354,116.4436},
    {1797.5979,2139.2402,10.8698,124.3734},
    {2018.9204,1918.6038,12.3415,281.4280},
    {2196.4600,1677.1039,12.3672,91.7000},
    {1930.6503,1345.5824,9.9688,270.8696},
    {1988.1869,1245.0291,10.8203,309.9315},
    {990.1016,2272.4226,11.4609,354.2789},
    {954.0927,2271.2539,11.4688,5.4395},
    {927.4415,2271.5249,11.4609,4.8521},
    {925.1955,2214.4575,11.4624,178.4276},
    {950.7644,2213.7085,11.4624,180.7772},
    {980.1340,2214.7009,11.4624,166.0923},
    {967.2344,2132.9387,10.8203,273.8057},
    {985.4324,2032.7490,11.4688,286.4347},
    {985.7068,1998.7170,11.4609,271.8966},
    {985.2429,1980.3774,11.4683,294.5114},
    {1028.7098,1924.4010,11.4683,120.2754},
    {1028.1893,1907.9539,11.4609,93.2552},
    {986.3099,1899.4398,11.4609,248.5476},
    {986.0908,1881.5675,11.4683,306.9935},
    {1027.7338,1874.3517,11.4688,122.1844},
    {1029.2654,1845.5206,11.4683,123.2124},
    {1021.1495,1824.6066,10.8203,185.4764},
    {931.3641,1736.6891,8.8594,266.8307},
    {1369.5508,684.0294,10.8887,14.9117},
    {1533.3304,750.1333,11.0234,291.7951},
    {1611.9341,954.9005,10.7359,243.6646},
    {2108.0769,897.0679,11.1797,355.8942},
    {2661.6946,1238.0214,10.8203,83.2694},
    {2768.2017,1447.8594,10.8502,359.9330},
    {2637.6191,751.2629,10.8906,85.1424},
    {2449.8291,742.4081,11.4609,121.3772},
    {2449.5305,712.9435,11.4683,125.4890},
    {2446.8174,690.0449,11.4609,27.9812},
    {2447.9841,661.4106,11.4609,114.6222},
    {2398.8389,655.5009,11.4609,203.4659},
    {2366.3796,654.1105,11.4609,151.0407},
    {2347.7461,655.7506,11.4605,214.7732},
    {2319.9346,655.7800,11.4531,210.9552},
    {2260.1562,655.2280,11.4531,206.2560},
    {2227.0776,653.2996,11.4609,157.5021},
    {2208.5649,655.7278,11.4683,208.3119},
    {2179.7842,655.3766,11.4609,195.9766},
    {2175.4353,690.9698,11.4609,2.1358},
    {2208.3838,691.6649,11.4609,342.3112},
    {2226.8933,689.8195,11.4605,12.1215},
    {2255.2690,690.3430,11.4531,26.8064},
    {2259.7393,735.1742,11.4609,206.4028},
    {2226.5122,734.1818,11.4609,179.2358},
    {2207.4534,736.6350,11.4683,183.4944},
    {2179.1992,735.7687,11.4609,202.2911},
    {2168.3552,774.2821,11.4609,82.7560},
    {2091.9746,774.4912,11.4531,156.3273},
    {2073.6282,776.6382,11.4605,214.0390},
    {2045.4646,774.9742,11.4531,206.5497},
    {2012.0723,774.2101,11.4609,168.5158},
    {1956.7788,690.8595,10.8203,78.8649},
    {1956.5347,665.3011,10.8203,61.5367},
    {1945.0316,664.7601,10.8203,14.3982},
    {1918.8916,663.7837,10.8203,8.8179},
    {1896.7393,677.2676,14.2744,260.7370},
    {1896.9388,736.5941,14.2766,279.6805},
    {1935.8519,742.8744,14.2734,196.7108},
    {1957.0454,731.5589,14.2811,79.0847},
    {693.7324,1965.9019,5.5391,180.4845},
    {386.9746,2553.2776,16.5727,352.9073},
    {-289.9744,1172.6345,20.9399,180.9989},
    {-327.2585,1164.3148,20.9399,225.2734},
    {-365.6302,1169.3022,19.7422,225.2734},
    {-363.7150,1135.1410,20.2820,257.2865},
    {-361.6835,1114.6415,20.1517,257.2865},
    {-332.6638,1120.1217,20.1024,137.0910},
    {-315.4450,1049.4454,20.3403,4.9269},
    {-260.4664,1047.2577,20.9399,178.7776},
    {-254.3750,1083.7954,20.9399,278.7265},
    {-205.3026,1087.1024,19.7422,301.0475},
    {-176.4175,1111.9771,19.7422,132.0982},
    {-107.1097,1124.7212,19.7422,180.9989},
    {-90.6626,1116.9869,19.7422,210.8092},
    {-42.2870,1119.4668,20.2422,151.7759},
    {-41.5945,1083.6180,20.9399,38.2311},
    {0.8504,1075.6906,20.9399,12.0486},
    {9.4449,1113.2924,20.9399,117.2655},
    {-0.8893,1171.6836,19.4990,281.5166},
    {12.2450,1182.6216,19.5748,185.7710},
    {60.8462,1226.0872,18.8643,234.5249},
    {77.5810,1162.2893,18.6641,9.1116},
    {89.6230,1181.7993,18.6641,91.6408},
    {22.7353,968.1324,19.8385,0.5944},
    {-86.6927,915.4247,21.1251,85.4731},
}

ui.parcelLockers={
    {1576.21423, 2239.57422, 10.82031},
    {1576.28296, 2236.36670, 10.82031},
    {2035.39185, 2434.48267, 10.82031},
    {2035.51074, 2431.20947, 10.82031},
    {2670.76270, 765.21637, 10.82031},
    {2674.02466, 765.10419, 10.82031},
    {1425.40637, 1185.75073, 10.82031},
    {1422.13867, 1185.63257, 10.82031},
    {2291.20898, 2721.26685, 10.82031},
    {2294.46973, 2721.26416, 10.82031},
    {1034.21118, 2285.26538, 10.82031},
    {1030.95300, 2285.27612, 10.82031},
    {2871.02905, 2300.79517, 10.82031},
    {2874.15918, 2300.85645, 10.82031},
    {2294.82080, 1505.41223, 10.82031},
    {2291.63403, 1505.51367, 10.82031},
    {2062.13696, 1768.49451, 10.82031},
    {2063.57593, 1771.30542, 10.82031},
    {2387.67456, 1781.28235, 10.82031},
    {2390.91113, 1781.41589, 10.82031},
    {2614.04199, 1365.23633, 10.82031},
    {2610.85742, 1365.37830, 10.82031},
    {1035.35828, 1353.88623, 10.82031},
    {1035.32898, 1350.60449, 10.82031},
    {2435.39307, 1059.67773, 10.82031},
    {2435.42505, 1056.35266, 10.82031},
    {2235.46973, 2730.24829, 10.82031},
    {2235.60815, 2727.02393, 10.82031},
    {1962.66333, 1445.11951, 10.82031},
    {1959.47485, 1445.06250, 10.82031},
    {2514.20264, 2061.40796, 10.82031},
    {2510.91748, 2061.35425, 10.82031},
    {1399.33569, 2610.66479, 10.82031},
    {1402.58044, 2610.61108, 10.82031},
    {729.69098, 1937.11487, 5.53906},
    {729.61914, 1933.95178, 5.53906},
    {1494.59119, 2061.04248, 10.82031},
    {1491.24915, 2060.99316, 10.82031},
    {1479.50928, 951.53967, 10.82031},
    {1479.60547, 954.73224, 10.82031},
    {2329.93457, 1929.26306, 10.90052},
    {2329.78223, 1932.45288, 10.82912},
    {1873.77502, 1265.25439, 10.82031},
    {1870.47009, 1265.19434, 10.82031},
    {1584.14343, 925.44885, 10.82031},
    {1580.85352, 925.31427, 10.82031},
    {949.6530,1754.4727,8.6484},
    {949.6901,1758.2837,8.6484},
}

ui.startBoxes={
    ["Speedo"]=9,
    ["Boxville"]=7,
    ["Rumpo"]=6,
    ["Pony"]=5,
}

ui.getStartBoxes=function()
    local box=ui.startBoxes["Pony"]
    for i,v in pairs(ui.startBoxes) do
        if(ui.info.upgrades[i] and v > box)then
            box=v
        end
    end
    return box
end

ui.getRandomPoints=function(clients)
    local save={}
    local points={}

    while(#points < clients)do
        local r=math.random(1,10)
        if(ui.info.upgrades["Paczkomaty"] and r < 5)then
            local rnd=math.random(1,#ui.parcelLockers)
            points[#points+1]=ui.parcelLockers[rnd]
        else
            local rnd=math.random(1,#ui.clients)
            if(not save[rnd])then
                save[rnd]=true
                points[#points+1]=ui.clients[rnd]
            end
        end
    end

    return points
end

ui.generateRandomBoxInfo=function(id)
    local point=ui.points[id]
    if(not point)then return end

    local info={}

    info.city="?"
    info.street="?"

    local names=ui.ownersNames[math.random(1,#ui.ownersNames)]
    info.name=names[1]
    info.lastName=names[2]
    info.houseID=math.random(1,100)
    info.skinID=names[3]

    local boxType=math.random(1,#ui.boxTypes)
    local type=ui.boxTypes[boxType]
    info.type=type
    info.boxShader=boxType

    info.city=getZoneName(point[1], point[2], point[3], true)
    info.street=getZoneName(point[1], point[2], point[3], false)

    info.nr="#"..math.random(1,9)..math.random(1,9)..math.random(1,9)..math.random(1,9)..math.random(1,9)..math.random(1,9)..math.random(1,9)..math.random(1,9)
    info.cost=math.random(1000,50000)
    info.sales=math.random(1,50)
    info.delicate=math.random(0,1) == 0 and "tak" or "nie"

    return info
end

ui.createPeds=function(id)
    local v=ui.points[id]
    if(not v)then return end

    local info=ui.boxesInfos[id]
    if(not info)then return end

    if(v[4])then
        ui.peds["client_"..id]=createPed(info.skinID, v[1], v[2], v[3], v[4])
        setElementData(ui.peds["client_"..id], "ped:desc", {name=info.name.." "..info.lastName, desc="Klient"}, false)
        setElementFrozen(ui.peds["client_"..id], true)
    end

    ui.markers["client_"..id]=createMarker(v[1], v[2], v[3], "cylinder", 1.5, 0, 200, 100)
    ui.blips["client_"..id]=createBlipAttachedTo(ui.markers["client_"..id], 22)

    setElementData(ui.markers["client_"..id], "client:id", id, false)
    setElementData(ui.markers["client_"..id], "settings", {offIcon=true}, false)
end

ui.getNearestClient=function()
    local nearest=false
    local myPos={getElementPosition(localPlayer)}
    for i,v in pairs(ui.markers) do
        if(string.find(i, "client"))then
            local hisPos={getElementPosition(v)}
            local dist=getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], hisPos[1], hisPos[2], hisPos[3])
            if(not nearest or (nearest and dist < nearest.dist))then
                nearest={element=v,id=string.gsub(i,"client_",""),dist=dist}
            end
        end
    end
    return nearest
end

-- useful

function getTarget()
	local camPos = {getCameraMatrix()}
	local myPos = {getElementPosition(localPlayer)}

	local rotZ = -getPedCameraRotation(localPlayer)
	local x,y = (camPos[1] - math.sin(math.rad(rotZ)) * 7.5), (camPos[2] + math.cos(math.rad(rotZ)) * 7.5)

	local _,_,_,_,element = processLineOfSight(myPos[1], myPos[2], myPos[3], x, y, myPos[3])

    return element
end

table.size=function(t)
    local x=0; for i,v in pairs(t) do x=x+1; end; return x;
end

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end

-- shading

local boxes={}
local tex_name={"smallbox","bigbox"}
local textures={}
textures.gopostalShader=dxCreateShader(ui.shader)
textures.gopostal=dxCreateTexture("textures/gopostal.png")
dxSetShaderValue(textures.gopostalShader, "gTexture", textures.gopostal)

function setBoxTexture(id, box)
    if(not boxes[id] or not textures[id])then
        boxes[id]={}
        boxes[id][box]=true

        local shader=dxCreateShader(ui.shader)
        local tex=dxCreateTexture("textures/boxes/"..id..".png")
        dxSetShaderValue(shader, "gTexture", tex)

        textures[id]={shader,tex}
    else
        boxes[id][box]=true
    end

    for i,v in pairs(tex_name) do
        engineApplyShaderToWorldTexture(textures[id][1], v, box)
    end
    engineApplyShaderToWorldTexture(textures.gopostalShader, "inoprosto", box)
end

function removeBoxTexture(id, box)
    if(boxes[id])then
        if(boxes[id][box])then
            boxes[id][box]=nil

            if(table.size(boxes[id]) < 1)then
                if(textures[id])then
                    checkAndDestroy(textures[id][1])
                    checkAndDestroy(textures[id][2])
                    textures[id]=nil
                end
            end
        end
    end
end

addEventHandler("onClientElementStreamIn", resourceRoot, function()
    if(getElementData(source,"box_shader") and source and isElement(source))then
        setBoxTexture(getElementData(source,"box_shader"),source)
    end
end)

addEventHandler("onClientElementStreamOut", resourceRoot, function()
    if(getElementData(source,"box_shader") and source and isElement(source))then
        removeBoxTexture(getElementData(source,"box_shader"), source)
    end
end)