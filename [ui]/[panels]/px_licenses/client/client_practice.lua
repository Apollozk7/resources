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
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

-- variables

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local buttons = exports.px_buttons
local noti = exports.px_noti
local blur=exports.blur

local PJ = {}

-- main

PJ.places = {
    ["A"] = {
        pos={
            {1159.7569580078,1348.2685546875,10.897977828979},
        },

        desc=[[Egzamin praktyczny składa się z jazdy miejskiej.
        Pamiętaj o uważniej jeździe przy zdawaniu.]],
        cost=500,
        points={
            -- start
            {pos={1144.0696,1308.0090,10.3398}, text="Podjedź do przodu i przygotuj się do cofania.", plac=true},
            {pos={1146.9940,1311.0482,10.3405}, text="Wycofaj motocykl do wyznaczonego miejsca.", plac=true},

            -- nr 2
            {vehPos={1149.1168,1296.1821,10.3406,0,0,131.6279}},
            {pos={1143.2358,1293.2925,10.3404}, text="Rozpoczynamy ósemkę.", plac=true},
            {pos={1145.1200,1287.8114,10.3409}, text="Robimy ósemkę.", plac=true},
            {pos={1147.4647,1280.5325,10.3404}, text="Robimy ósemkę.", plac=true},
            {pos={1142.5602,1283.1799,10.3401}, text="Robimy ósemkę.", plac=true},
            {pos={1145.7072,1287.0752,10.3409}, text="Robimy ósemkę.", plac=true},
            {pos={1147.9987,1292.3567,10.3405}, text="Robimy ósemkę.", plac=true},
            {pos={1145.1200,1287.8114,10.3409}, text="Robimy ósemkę.", plac=true},
            {pos={1147.4647,1280.5325,10.3404}, text="Robimy ósemkę.", plac=true},
            {pos={1142.5602,1283.1799,10.3401}, text="Robimy ósemkę.", plac=true},
            {pos={1145.7072,1287.0752,10.3409}, text="Robimy ósemkę.", plac=true},
            {pos={1147.9987,1292.3567,10.3405}, text="Robimy ósemkę.", plac=true},
            {pos={1145.1200,1287.8114,10.3409}, text="Robimy ósemkę.", plac=true},
            {pos={1147.4647,1280.5325,10.3404}, text="Robimy ósemkę.", plac=true},
            {pos={1142.5602,1283.1799,10.3401}, text="Robimy ósemkę.", plac=true},
            {pos={1145.7072,1287.0752,10.3409}, text="Robimy ósemkę.", plac=true},
            {pos={1147.9987,1292.3567,10.3405}, text="Robimy ósemkę.", plac=true},
            {pos={1145.1200,1287.8114,10.3409}, text="Robimy ósemkę.", plac=true},
            {pos={1147.4647,1280.5325,10.3404}, text="Robimy ósemkę.", plac=true},
            {pos={1142.5602,1283.1799,10.3401}, text="Robimy ósemkę.", plac=true},
            {pos={1145.7072,1287.0752,10.3409}, text="Robimy ósemkę.", plac=true},
            {pos={1147.9987,1292.3567,10.3405}, text="Robimy ósemkę.", plac=true},

            -- nr 3
            {vehPos={1166.3821,1305.2034,10.4784,0,0,180.3146}},
            {pos={1166.3760,1279.3434,12.0826}, text="Wjedź na wzniesienie.", plac=true},
            {pos={1166.3762,1256.9828,10.4784}, text="Zjedź ze wzniesienia.", plac=true},

            -- trasa
            {vehPos={1165.0020,1388.8732,9.6826,0,0,175.6674},text="Zaraz przekonamy się czy delikatnie wciśniesz sprzęgło, wyjeżdżamy."},
            {pos={1161.7823,1377.3163,10.3298},text="Zaraz przekonamy się czy delikatnie wciśniesz sprzęgło, wyjeżdżamy."},
            {pos={1141.2892,1374.9277,10.1919},text="Cały czas prosto."},
            {pos={1033.9392,1375.0138,10.2692},text="Tutaj w lewo."},
            {pos={1004.6380,1370.1364,10.2865},text="Świetnie jedziemy cały czas prosto."},
            {pos={1005.0905,1319.7742,10.1900},text="Trzymamy kurs na wprost."},
            {pos={1005.4070,1203.5608,10.1910},text=""},
            {pos={1014.9268,1191.1884,10.1967},text=""},
            {pos={1079.4037,1191.1709,10.1900},text=""},
            {pos={1201.5508,1191.3368,13.0921},text=""},
            {pos={1360.3763,1191.5074,10.1905},text=""},
            {pos={1442.9120,1188.6354,10.1920},text=""},
            {pos={1445.1475,1165.8721,10.1942},text=""},
            {pos={1448.9390,1134.9434,10.1920},text=""},
            {pos={1465.0363,1130.8168,10.1938},text=""},
            {pos={1587.8226,1131.3966,10.1904},text=""},
            {pos={1707.1783,1131.3243,10.1905},text=""},
            {pos={1863.9834,1127.6589,10.1921},text=""},
            {pos={1864.9327,1118.1967,10.1942},text=""},
            {pos={1865.5292,1101.6812,10.2205},text=""},
            {pos={1865.2014,975.1558,10.1942},text=""},
            {pos={1868.8679,934.8277,10.1921},text=""},
            {pos={1892.5063,930.8421,10.1942},text=""},
            {pos={2005.8610,934.7134,10.1942},text=""},
            {pos={2009.5896,957.4961,10.1863},text=""},
            {pos={2013.1053,969.2073,10.1926},text=""},
            {pos={2028.9740,970.9576,9.9742},text="Proszę ostrożnie ten motocykl jest sporo wart."},
            {pos={2056.8455,971.4713,10.0098},text=""},
            {pos={2087.5559,971.9830,10.1945},text=""},
            {pos={2196.7683,971.6985,10.1900},text=""},
            {pos={2337.7205,971.4777,10.1942},text=""},
            {pos={2349.2700,986.8342,10.2703},text=""},
            {pos={2349.3906,1070.8522,10.3477},text=""},
            {pos={2349.5344,1172.7369,10.1918},text="Proszę zmienić kierunek jazdy w lewo."},
            {pos={2346.8445,1195.2926,10.3125},text=""},
            {pos={2229.8418,1195.3146,10.3613},text=""},
            {pos={2189.3911,1326.5428,10.1940},text="Skręcamy w prawo."},
            {pos={2186.8518,1375.1410,10.3312},text="Tutaj kupiłem swoją brykę, mniejsza skręcamy w lewo."},
            {pos={2121.9004,1374.9846,10.1990},text=""},
            {pos={2070.3020,1384.3726,10.1999},text="Tutaj w prawo."},
            {pos={2069.6514,1509.2671,10.1900},text=""},
            {pos={2068.9170,1644.3160,10.1953},text=""},
            {pos={2064.2346,1716.3496,10.1927},text="Skręcamy w lewo na zjeździe."},
            {pos={1864.8820,1715.1962,10.1492},text="Upewnij się czy możesz."},
            {pos={1706.1641,1715.2737,10.1696},text="Ostrożnie tutaj."},
            {pos={1582.6453,1715.5289,10.1942},text=""},
            {pos={1569.9772,1723.0581,10.1942},text=""},
            {pos={1569.7534,1807.0067,10.1899},text=""},
            {pos={1569.6724,1867.4977,10.3154},text="Będziemy skręcać w lewo."},
            {pos={1562.2472,1875.4708,10.2962},text=""},
            {pos={1479.8934,1875.3726,10.2383},text=""},
            {pos={1364.3392,1875.3644,10.1955},text=""},
            {pos={1328.6323,1871.1920,10.1923},text="Na tym zakręcie wolniej, często dochodzi tu do wypadków."},
            {pos={1325.5398,1854.3394,10.1942},text=""},
            {pos={1322.2954,1817.5083,10.1942},text=""},
            {pos={1312.3394,1816.4054,10.1865},text=""},
            {pos={1246.3593,1815.2350,12.3530},text=""},
            {pos={1132.2859,1815.1122,10.4945},text=""},
            {pos={1055.6910,1815.2781,10.1940},text=""},
            {pos={1011.7108,1815.3989,10.3543},text="W lewo."},
            {pos={1005.0214,1805.6090,10.2395},text="Koontynujemy prosto i zjeżdżamy w stronę ośrodka."},
            {pos={1005.7631,1695.1750,10.2915},text=""},
            {pos={1005.7651,1574.2777,10.1905},text=""},
            {pos={1005.3442,1425.5718,10.2020},text="Skręcamy i powoli kończymy."},
            {pos={1014.3387,1370.8375,10.3094},text=""},
            {pos={1118.1965,1371.2777,10.1942},text="Świetnie nam poszło, mam nadzieję, że nie będziesz kolejnym dawcą."},
        },
    },

    ["B"] = {
        pos={
            {1159.7785644531,1340.2994384766,10.890625},
        },

        desc=[[Egzamin praktyczny składa się z jazdy miejskiej.
        Pamiętaj o uważniej jeździe przy zdawaniu.]],
        cost=0,
        points={
            -- start
            {pos={1128.3134,1264.5056,10.4784}, text="Jedź prosto i pokonaj łuk.", plac=true},
            {pos={1125.9697,1285.7888,10.4783}, text="Udaj się do wskazanego miejsca.", plac=true},
            {pos={1126.9899,1264.9728,10.4783}, text="Pokonaj łuk na wstecznym.", plac=true},
            {pos={1144.3955,1263.2344,10.4784}, text="Cofnij się do miejsca startu.", plac=true},

            -- nr 2
            {vehPos={1125.5839,1355.3657,10.4748,0,0,180}},
            {pos={1124.6216,1333.9761,10.4783}, text="Jedź prosto do wskazanego miejsca.", plac=true},
            {pos={1121.4163,1340.3201,10.4784}, text="Zaparkuj na wstecznym.", plac=true, result=function(veh) local _,_,rz=getElementRotation(veh); return rz > 150 and rz < 230 end},
            {pos={1125.1526,1321.5975,10.4784}, text="Wyjedź i jedź prosto.", plac=true},
            {pos={1119.5665,1327.3099,10.4784}, text="Zaparkuj na wstecznym.", plac=true, result=function(veh) local _,_,rz=getElementRotation(veh); return rz > 250 and rz < 300 end},
            {pos={1119.7773,1312.5464,10.4784}, text="Wyjedź i udaj się do nastepnęgo miejsca.", plac=true},
            {pos={1125.3295,1296.5947,10.4784}, text="Udaj się do wskazanego miejsca.", plac=true},

            -- nr 3
            {vehPos={1166.3821,1305.2034,10.4784,0,0,180.3146}},
            {pos={1166.3760,1279.3434,12.0826}, text="Wjedź na wzniesienie.", plac=true},
            {pos={1166.3762,1256.9828,10.4784}, text="Zjedź ze wzniesienia.", plac=true},

            -- trasa
            {vehPos={1165.0020,1388.8732,9.6826,0,0,175.6674},text="Proszę się skupić rozpoczynamy jazdę po mieście, proszę skręcić w prawo."},
            {pos={1161.7823,1377.3163,10.3298},text="Proszę się skupić rozpoczynamy jazdę po mieście, proszę skręcić w prawo."},
            {pos={1134.7072,1375.5521,10.3922},text="Koontynujemy prosto aż do skrzyżowania."},
            {pos={1045.4093,1375.4841,10.3918},text="Proszę skręcić w prawo i trzymać kurs na wprost."},
            {pos={1009.8344,1398.0552,10.3914},text="Jedziemy prosto, pokręcimy się przy ważniejszych obiektach."},
            {pos={1009.4702,1571.6676,10.3943},text="Za chwilę na lewo miniemy urząd miasta."},
            {pos={1009.4894,1772.9647,10.4958},text="Skręcamy w prawo i jedziemy prosto."},
            {pos={1072.7261,1810.9679,10.3900},text="Kto by pomyślał, że tyle się tu dzieje..."},
            {pos={1242.6841,1810.8820,12.8025},text="Cały czas prosto."},
            {pos={1329.7048,1835.4594,10.3909},text="Tutaj warto zachować ostrożność, dużo ludzi skraca pasy."},
            {pos={1361.7635,1870.7974,10.3944},text="Jedziemy prosto, za chwilę wyłoni się stara giełda pojazdów."},
            {pos={1558.9116,1871.0555,10.4370},text="Już ją widać, bardzo dużo ludzi się tu kręciło, można było wyrwać fajne samochody."},
            {pos={1631.8641,1871.2188,10.3983},text="Nawet sam kiedyś tu sprzedawałem, prosto."},
            {pos={1709.6986,1911.4080,10.3914},text="Jedziemy prosto."},
            {pos={1709.5894,2010.9110,10.5145},text="Jesteśmy w centrum LV, proszę skręcić w prawo."},
            {pos={1765.7817,2051.0952,10.5503},text="Bardzo dużo się tu dzieje, pod nami autostrada."},
            {pos={1885.9181,2042.9370,10.3942},text="Przed nami salon pojazdów, skręcamy w prawo i cały czas prosto."},
            {pos={1950.3268,2019.8226,10.3919},text="Bravado ostatnio wypuściło na rynek Buffalo Supercharged, wspaniałe auto."},
            {pos={2070.8774,2019.9728,10.3942},text="Skręcamy w prawo i trzymamy się prawego pasa."},
            {pos={2125.6824,1972.6171,10.4102},text="The Strip, główna ulica w Las Venturas."},
            {pos={2045.6575,1664.0088,10.3942},text="Sami bogacze tu mieszkają!"},
            {pos={2046.1499,1400.8651,10.3914},text="Po drugiej stronie, kolejny salon - wspaniałe jest to miasto."},
            {pos={2046.1440,1306.5585,10.3942},text="Proszę skręcić w prawo."},
            {pos={1947.1569,1275.4906,10.5671},text="Jedziemy prosto aż do końca."},
            {pos={1790.0472,1275.7789,13.4919},text="Cały czas prosto."},
            {pos={1645.1008,1211.8804,10.3916},text="Na najbliższym skrzyżowaniu w prawo."},
            {pos={1542.3699,1135.5205,10.3935},text="Po naszej prawej lotnisko, warto się czasem wybrać w lot i zobaczyć z góry co nas otacza."},
            {pos={1450.1108,1166.9559,10.3936},text="Jedziemy prosto."},
            {pos={1304.2942,1195.2191,10.3942},text="Zbliżamy się do wiaduktu, pod nami znowu zobaczymy autostradę."},
            {pos={1083.7175,1195.2087,10.3943},text="Nie zmieniamy kierunku jazdy."},
            {pos={1009.6548,1295.6910,10.3943},text="Już prawie na miejscu, skręcamy w stronę ośrodka."},
            {pos={1040.3434,1371.0804,10.3914},text="Jedziemy do miejsca z którego wyjechaliśmy."},
            {pos={1123.4862,1371.2028,10.3943},text="Kończymy egzamin."},
        },
    },

    ["C"] = {
        pos={
            {1160.0050048828,1332.3852539063,10.890625},
        },

        desc=[[Egzamin praktyczny składa się z jazdy miejskiej.
        Pamiętaj o uważniej jeździe przy zdawaniu.]],
        cost=1500,
        points={
            -- start
            {pos={1113.3159,1252.9905,10.8089}, text="Jedź prosto i pokonaj łuk.", plac=true},
            {pos={1110.9586,1279.2697,10.8045}, text="Udaj się do wskazanego miejsca.", plac=true},
            {pos={1112.5314,1254.2069,10.8132}, text="Pokonaj łuk na wstecznym.", plac=true},
            {pos={1132.2312,1252.1359,10.8121}, text="Cofnij się do miejsca startu.", plac=true},

            -- nr 2
            {vehPos={1110.9397,1354.7343,10.8121,0,0,180}},
            {pos={1109.6925,1336.3781,10.8093}, text="Jedź prosto do wskazanego miejsca.", plac=true},
            {pos={1106.1172,1344.7163,10.8103}, text="Zaparkuj na wstecznym.", plac=true, result=function(veh) local _,_,rz=getElementRotation(veh); return rz > 150 and rz < 230 end},
            {pos={1111.1943,1320.7407,10.8094}, text="Wyjedź i jedź prosto.", plac=true},
            {pos={1104.9105,1328.9408,10.8115}, text="Zaparkuj na wstecznym.", plac=true, result=function(veh) local _,_,rz=getElementRotation(veh); return rz > 250 and rz < 300 end},
            {pos={1104.0708,1310.5604,10.8107}, text="Wyjedź i udaj się do nastepnęgo miejsca.", plac=true},
            {pos={1110.9760,1289.1852,10.8092}, text="Udaj się do wskazanego miejsca.", plac=true},

            -- nr 3
            {vehPos={1165.9060,1304.5879,10.8124,0,0,180}},
            {pos={1166.3760,1279.3434,12.0826}, text="Wjedź na wzniesienie.", plac=true},
            {pos={1166.3762,1256.9828,10.4784}, text="Zjedź ze wzniesienia.", plac=true},

            -- trasa
            {vehPos={1165.0020,1388.8732,9.6826,0,0,175.6674},text="Egzamin teoretyczny na kategorię C, zaczynamy."},
            {pos={1161.7823,1377.3163,10.3298}, text="Egzamin teoretyczny na kategorię C, zaczynamy."},
            {pos={1134.9104,1375.7893,10.6632}, text="Prosto."},
            {pos={1029.9938,1375.6157,10.8190}, text="Skręcamy w prawo."},
            {pos={1009.7009,1382.3237,10.6902}, text="Prosto."},
            {pos={1009.7184,1489.6219,10.6639}, text=""},
            {pos={1009.5331,1647.8771,10.7654}, text=""},
            {pos={1009.6244,1813.1426,10.8581}, text="Jedziemy prosto."},
            {pos={1009.3069,2021.0391,10.6634}, text=""},
            {pos={1009.4410,2195.9575,10.7748}, text="Zaraz zjeżdżamy na ten plac po prawej."},
            {pos={1021.4393,2258.4517,10.8092}, text="Cofnij do boxu."},
            {pos={1019.8077,2251.2061,10.8133}, text=""},
            {pos={1019.4129,2241.6294,10.8132}, text=""},
            {pos={1023.9524,2238.1279,10.8101}, text=""},
            {pos={1006.9206,2234.8906,10.6607}, text="Świetnie poszło, wyjeżdżamy w lewo i jedziemy dalej."},
            {pos={1005.3057,2155.2942,10.6609}, text=""},
            {pos={1005.5367,2090.3806,10.6608}, text="Skręcamy w lewo."},
            {pos={1005.6362,2058.8691,10.7505}, text=""},
            {pos={1017.8657,2050.7935,10.6919}, text=""},
            {pos={1085.1688,2051.1118,10.6608}, text="Jedziemy cały czas prosto."},
            {pos={1183.9136,2051.3599,12.5197}, text=""},
            {pos={1389.0736,2051.4619,10.8558}, text=""},
            {pos={1500.6624,2051.1736,10.6609}, text="Odbijamy w lewo."},
            {pos={1529.3927,2060.3369,10.7606}, text=""},
            {pos={1529.5679,2131.1177,10.6609}, text=""},
            {pos={1550.3889,2170.9954,10.6609}, text="Ponownie w lewo."},
            {pos={1569.7179,2179.5173,10.7735}, text=""},
            {pos={1569.5322,2276.5203,10.8321}, text=""},
            {pos={1569.6199,2342.7104,10.6898}, text="Skręć w lewo i zawróć."},
            {pos={1564.9053,2356.5730,10.6610}, text=""},
            {pos={1536.2711,2347.5901,10.8092}, text=""},
            {pos={1536.5658,2359.8091,10.8148}, text=""},
            {pos={1556.4734,2356.3110,10.8082}, text="W prawo."},
            {pos={1565.1791,2334.0500,10.7873}, text="Prosto i najabliższym w prawo."},
            {pos={1564.3744,2194.6377,10.6609}, text="W prawo."},
            {pos={1561.3384,2176.6311,10.7472}, text=""},
            {pos={1531.0177,2173.7231,10.6607}, text=""},
            {pos={1525.2534,2134.0344,10.6647}, text=""},
            {pos={1525.4082,2073.2693,10.6613}, text="W prawo."},
            {pos={1519.3481,2056.5344,10.7064}, text=""},
            {pos={1455.7739,2055.5928,10.6640}, text=""},
            {pos={1413.8856,2055.7566,10.6608}, text="Skręcamy w lewo."},
            {pos={1386.1349,2049.9573,10.8384}, text=""},
            {pos={1385.1097,1979.3822,10.7330}, text=""},
            {pos={1385.2543,1894.7933,10.6608}, text="Prawo."},
            {pos={1378.7196,1875.9856,10.6984}, text=""},
            {pos={1331.6007,1873.8829,10.6610}, text=""},
            {pos={1325.0402,1842.9615,10.6608}, text=""},
            {pos={1320.4479,1816.5002,10.6607}, text="Ostrożnie."},
            {pos={1255.6733,1815.3481,12.2044}, text=""},
            {pos={1132.0300,1815.4137,10.9419}, text=""},
            {pos={1039.7457,1815.6069,10.6611}, text="W lewo."},
            {pos={1006.6161,1811.9374,10.8221}, text=""},
            {pos={1005.2274,1753.0450,10.7656}, text="Jedziemy prosto."},
            {pos={1005.3781,1599.3599,10.7021}, text=""},
            {pos={1005.4008,1478.7172,10.6636}, text=""},
            {pos={1005.4070,1380.9010,10.7106}, text="Lewo."},
            {pos={1027.9991,1370.5886,10.7697}, text="Kierunek ośrodek."},
            {pos={1094.1639,1370.9043,10.6608}, text=""},
        },
    },

    ["C+E"] = {
        pos={
            {1159.1476,1324.8699,10.8980},
        },

        desc=[[Egzamin praktyczny składa się z jazdy miejskiej.
        Pamiętaj o uważniej jeździe przy zdawaniu.]],
        cost=8000,
        points={
            -- start
            {pos={1127.2909,1209.5996,11.4055}, text="Jedź prosto i pokonaj łuk.", plac=true},
            {pos={1145.7427,1252.9224,11.4073}, text="Udaj się do wskazanego miejsca.", plac=true},
            {pos={1142.5842,1219.6213,11.4168}, text="Pokonaj łuk na wstecznym.", plac=true},
            {pos={1114.5985,1210.9401,11.4138}, text="Cofnij się do miejsca startu.", plac=true},

            -- trasa
            {vehPos={1169.9972,1435.4675,6.3713,0,0,178.7666},trailerPos={1170.1506,1444.1388,6.9174,0,0,179.8104},text="Rozpoczynamy egzamin praktyczny na kategorię C+E, skręcamy w prawo."},
            {pos={1161.7823,1377.3163,10.3298}, text="Proszę się skupić rozpoczynamy egzamin praktyczny na kategorię C+E, skręcamy w lewo."},
            {pos={1130.5353,1375.5562,11.6729}, text="Jedziemy prosto i na skrzyżowaniu w prawo."},
            {pos={1025.6594,1375.6479,11.8049}, text="Skręcamy w prawo, proszę wziąć spory łuk."},
            {pos={1009.7283,1414.4244,11.6771}, text="Prosto."},
            {pos={1009.7288,1562.1448,11.6760}, text="Kontynujemy."},
            {pos={1009.9232,1778.3243,11.7773}, text="Skręcamy w prawo."},
            {pos={1046.1599,1811.0068,11.6824}, text="Świetnie, wyjeżdżamy na autostradę."},
            {pos={1117.6199,1810.9673,11.6756}, text="Tutaj."},
            {pos={1137.6149,1795.6685,11.6754}, text="Na najbliższym skrzyżowaniu skręć w prawo."},
            {pos={1190.8690,1703.8337,7.7033}, text="Proszę się skupić i trzymać prawej strony."},
            {pos={1205.3943,1579.6808,7.7454}, text=""},
            {pos={1205.3099,1362.2405,7.7386}, text=""},
            {pos={1205.1921,1093.9727,7.8178}, text="Zjeżdżamy w stronę San Fierro."},
            {pos={1194.8994,973.9807,8.7067}, text=""},
            {pos={1124.3931,860.7412,11.7141}, text=""},
            {pos={1031.4844,788.4365,11.7164}, text=""},
            {pos={851.3189,714.2984,12.7118}, text=""},
            {pos={643.5057,680.0974,7.5925}, text=""},
            {pos={494.4200,729.9755,5.1268}, text="Zjeżdżamy w stronę Fort Carson."},
            {pos={345.9696,793.1106,9.0824}, text="Na najbliższym skrzyżowaniu skręć w prawo."},
            {pos={252.3044,918.6084,25.8964}, text="Skręcamy."},
            {pos={198.6793,958.5281,28.8687}, text="Na najbliższym skrzyżowaniu skręć w lewo."},
            {pos={141.0935,894.6901,21.7192}, text=""},
            {pos={9.9103,887.8904,24.5222}, text=""},
            {pos={-93.9916,840.1323,19.92}, text="Tutaj w lewo."},
            {pos={-114.2909,796.8224,21.8497}, text="Slalomem w dół, tylko proszę uważać."},
            {pos={-177.9406,741.5443,26.1666}, text=""},
            {pos={-296.8429,679.4033,19.1637}, text=""},
            {pos={-231.3661,621.0245,11.1586}, text=""},
            {pos={-141.9615,618.5782,3.0832}, text=""},
            {pos={-130.2805,569.7444,4.6963}, text="Za znakiem w lewo."},
            {pos={-84.1921,544.4442,8.0165}, text="Dobrze, że ciężarówki jeżdżą głównie po autostradzie..."},
            {pos={-7.5017,594.8809,11.3273}, text=""},
            {pos={61.8437,644.6797,7.4052}, text=""},
            {pos={174.1085,707.3369,7.1302}, text=""},
            {pos={370.0800,753.8224,7.1327}, text=""},
            {pos={535.0395,680.1591,4.3501}, text=""},
            {pos={660.0452,654.0522,8.6128}, text=""},
            {pos={851.5359,687.7885,12.7437}, text=""},
            {pos={1117.8518,816.9401,11.6782}, text=""},
            {pos={1255.7010,876.8590,15.8252}, text=""},
            {pos={1281.4644,1071.3201,10.5915}, text="W prawo, zmierzamy ku końcowi."},
            {pos={1229.3492,1277.0573,7.7393}, text=""},
            {pos={1228.7112,1520.5309,7.7390}, text=""},
            {pos={1228.7422,1607.5487,7.7377}, text="W prawo na zjazd i potem w lewo w stronę urzędu."},
            {pos={1244.5909,1704.5626,7.7044}, text=""},
            {pos={1297.0255,1797.1699,11.6661}, text="Skręcamy w lewo."},
            {pos={1263.9755,1815.7948,12.6340}, text="Na najbliższym skrzyżowaniu skręć w lewo."},
            {pos={1141.8763,1815.8510,11.8837}, text=""},
            {pos={1035.0189,1815.5719,11.6738}, text="W lewo i zaraz jesteśmy na miejscu."},
            {pos={1004.4544,1792.1425,11.6782}, text=""},
            {pos={1005.0344,1561.1844,11.6763}, text=""},
            {pos={1005.0302,1439.7942,11.6839}, text="Zjeżdżamy w stronę ośrodka."},
            {pos={1126.5898,1370.9564,11.6734}, text=""},
        },
    },

    ["L1"] = {
        pos={
            {414.8043,2535.0378,19.1484},
        },

        have="L",
        desc=[[Egzamin praktyczny składa się z lataniu po punktach.
        Pamiętaj o uważnym lataniu przy zdawaniu.]],
        cost=1000,
        points={
            {pos={370.2059,2505.1479,17.0264}, text=""},
            {pos={161.5007,2507.8782,26.0530}, text=""},
            {pos={-237.8344,2512.0981,87.8381}, text=""},
            {pos={-758.2167,2652.5229,161.4593}, text=""},
            {pos={-1303.7703,2581.4656,129.3309}, text=""},
            {pos={-1383.4059,1602.9725,92.3309}, text=""},
            {pos={-1052.7622,1032.3461,183.3309}, text=""},
            {pos={-710.1396,1776.8031,169.3309}, text=""},
            {pos={-206.3001,1557.8270,167.3309}, text=""},
            {pos={610.7830,1278.5172,286.3309}, text=""},
            {pos={712.4199,882.4545,139.3309}, text=""},
            {pos={1283.7566,392.8845,337.3309}, text=""},
            {pos={1210.1268,-125.8853,207.3309}, text=""},
            {pos={1384.4050,-604.0664,207.3309}, text=""},
            {pos={2160.3857,-896.1744,207.3309}, text=""},
            {pos={2683.6018,-608.3657,303.3309}, text=""},
            {pos={2806.9241,376.5972,303.3309}, text=""},
            {pos={2736.2080,875.0129,84.3309}, text=""},
            {pos={2326.2375,1213.3098,112.3309}, text=""},
            {pos={2102.2876,1745.1487,154.3309}, text=""},
            {pos={1636.7332,2505.2129,154.3309}, text=""},
            {pos={1049.0034,2696.7344,154.3309}, text=""},
            {pos={99.5357,2753.4788,186.3309}, text=""},
            {pos={-634.3766,2599.7168,186.3309}, text=""},
            {pos={-291.5413,2229.3123,86.3309}, text=""},
            {pos={-32.7992,2214.1416,102.3309}, text=""},
            {pos={-160.8682,2465.8076,62.3309}, text=""},
            {pos={101.0589,2505.0310,17.3309}, text=""},
            {pos={297.0481,2503.7581,17.3309}, text=""},
        },
    },

    ["L2"] = {
        pos={
            {414.6277,2537.4766,19.1484},
        },

        have="L",
        desc=[[Egzamin praktyczny składa się z lataniu po punktach.
        Pamiętaj o uważnym lataniu przy zdawaniu.]],
        cost=5000,
        points={
            {pos={352.3009,2503.2688,17.9942},text=""},
            {pos={126.0409,2510.0625,25.5547},text=""},
            {pos={-86.3445,2592.8203,48.0637},text=""},
            {pos={-102.7313,2719.0698,74.4529},text=""},
            {pos={-18.5801,2882.4702,79.7434},text=""},
            {pos={132.8421,2994.6064,33.7434},text=""},
            {pos={254.4393,2946.2002,23.7434},text=""},
            {pos={261.6374,2797.0928,40.3614},text=""},
            {pos={422.8580,2592.7505,68.0852},text=""},
            {pos={974.7070,2837.3894,90.0852},text=""},
            {pos={1397.3691,2774.5530,115.0852},text=""},
            {pos={1846.7523,2673.8181,115.0852},text=""},
            {pos={2561.4700,2699.3169,192.0852},text=""},
            {pos={2714.0872,2417.5654,92.0852},text=""},
            {pos={2469.1094,2160.2219,132.0852},text=""},
            {pos={2136.0764,1879.5083,132.0852},text=""},
            {pos={1951.5789,1483.3989,132.0852},text=""},
            {pos={2100.1440,1209.4224,88.0852},text=""},
            {pos={2288.2981,1064.6696,95.0852},text=""},
            {pos={2462.3765,830.7708,156.0852},text=""},
            {pos={2492.1357,434.2527,156.0852},text=""},
            {pos={2664.6021,-240.4615,104.0852},text=""},
            {pos={2496.8013,-520.2328,185.0852},text=""},
            {pos={2100.4143,-626.3457,177.0852},text=""},
            {pos={1760.5956,-543.1041,123.0852},text=""},
            {pos={1292.9711,-431.1318,123.0852},text=""},
            {pos={1203.9863,-628.7081,89.0852},text=""},
            {pos={1158.7609,-766.3865,89.0852},text=""},
            {pos={1035.2350,-985.3997,110.0852},text=""},
            {pos={744.0891,-865.9573,76.0852},text=""},
            {pos={707.7465,-820.1715,51.0852},text=""},
            {pos={668.9191,-593.5409,93.0852},text=""},
            {pos={787.2915,-359.7040,93.0852},text=""},
            {pos={600.4257,-250.2865,24.0852},text=""},
            {pos={330.4921,-308.5382,19.0852},text=""},
            {pos={-562.2269,-975.1024,90.0852},text=""},
            {pos={-558.4904,-1658.8356,70.0852},text=""},
            {pos={-370.6333,-1898.8582,76.6752},text=""},
            {pos={-333.4985,-2079.2136,78.0448},text=""},
            {pos={-183.9582,-2229.8694,89.0699},text=""},
            {pos={29.9894,-2450.6169,89.0699},text=""},
            {pos={-30.2838,-2578.4075,89.0699},text=""},
            {pos={-76.8606,-2802.3442,126.0699},text=""},
            {pos={-189.8485,-2780.9351,76.0699},text=""},
            {pos={-207.3675,-2511.8293,83.0699},text=""},
            {pos={-413.0090,-2357.7649,121.0699},text=""},
            {pos={-678.0027,-2365.9854,121.0699},text=""},
            {pos={-851.8262,-2570.4287,160.0699},text=""},
            {pos={-1037.3024,-2761.9490,136.0699},text=""},
            {pos={-1056.9039,-3000.3545,136.0699},text=""},
            {pos={-1158.5176,-3188.5137,136.0699},text=""},
            {pos={-1270.2179,-3100.7449,64.0699},text=""},
            {pos={-1145.1008,-2954.9351,49.0699},text=""},
            {pos={-1184.8114,-2634.0708,32.0699},text=""},
            {pos={-1240.3138,-2418.0920,32.0699},text=""},
            {pos={-1186.2537,-2074.3682,57.0699},text=""},
            {pos={-1370.5635,-1747.2417,105.0699},text=""},
            {pos={-1426.5621,-1548.7556,141.0699},text=""},
            {pos={-1509.0745,-1479.8535,141.0699},text=""},
            {pos={-1698.8667,-1554.1377,109.0699},text=""},
            {pos={-1923.7555,-1647.5594,191.0699},text=""},
            {pos={-2071.0813,-1862.7557,260.0699},text=""},
            {pos={-2408.0818,-2048.7573,303.0699},text=""},
            {pos={-2650.5166,-1835.2561,395.0699},text=""},
            {pos={-2611.2566,-1485.3680,452.0699},text=""},
            {pos={-2251.6226,-1553.6719,561.0699},text=""},
            {pos={-2242.8862,-1729.0671,512.0699},text=""},
            {pos={-2152.2224,-1859.3038,406.0699},text=""},
            {pos={-2076.9836,-2124.0532,155.0699},text=""},
            {pos={-2162.1489,-2284.5303,80.0699},text=""},
            {pos={-2026.2697,-2619.0674,94.0699},text=""},
            {pos={-1565.1920,-2420.9678,198.0699},text=""},
            {pos={-1194.4955,-2415.7461,139.0699},text=""},
            {pos={-846.0582,-2531.3113,139.0699},text=""},
            {pos={-585.4462,-2584.3982,204.0699},text=""},
            {pos={-381.1810,-2553.6277,180.0699},text=""},
            {pos={-44.3159,-2308.8171,108.0699},text=""},
            {pos={160.9491,-2004.7528,62.0699},text=""},
            {pos={514.8275,-1991.2073,62.0699},text=""},
            {pos={836.9286,-2044.9550,62.0699},text=""},
            {pos={994.4423,-2071.2617,88.0699},text=""},
            {pos={1150.2721,-2065.1133,102.0699},text=""},
            {pos={1429.1653,-2238.5244,54.0699},text=""},
            {pos={1620.0649,-2330.1321,54.0699},text=""},
            {pos={1924.1403,-2187.9434,54.0699},text=""},
            {pos={2326.6675,-2340.9590,54.0699},text=""},
            {pos={2614.6985,-2485.7334,88.0699},text=""},
            {pos={2846.3311,-2448.2307,88.0699},text=""},
            {pos={2908.9321,-1991.7035,88.0699},text=""},
            {pos={2812.6052,-1689.6656,69.0699},text=""},
            {pos={2745.8923,-1386.1501,117.0699},text=""},
            {pos={2689.9622,-1083.3049,117.0699},text=""},
            {pos={2413.4436,-723.3396,239.0699},text=""},
            {pos={2217.7683,-366.9576,172.0699},text=""},
            {pos={1879.0894,100.9647,97.0699},text=""},
            {pos={1494.4226,376.1625,156.0699},text=""},
            {pos={576.2373,388.9047,110.0699},text=""},
            {pos={-337.6317,330.7268,110.0699},text=""},
            {pos={-1615.9026,-226.7281,229.0699},text=""},
            {pos={-1958.5773,-195.8811,103.0699},text=""},
            {pos={-2283.4229,-244.2067,95.0699},text=""},
            {pos={-2404.3005,-521.0901,148.0699},text=""},
            {pos={-2459.1284,-709.1122,188.0699},text=""},
            {pos={-2692.1135,-682.9074,104.0699},text=""},
            {pos={-2833.5012,-380.7315,60.0699},text=""},
            {pos={-2724.6960,-28.2244,101.0699},text=""},
            {pos={-2588.6208,319.9468,101.0699},text=""},
            {pos={-2774.6680,687.1907,110.0699},text=""},
            {pos={-2880.1741,911.1896,73.0699},text=""},
            {pos={-2830.3140,1088.4615,100.0699},text=""},
            {pos={-2657.3689,1205.2822,100.0699},text=""},
            {pos={-2541.0852,1385.6902,46.0699},text=""},
            {pos={-2643.4226,1509.7659,27.0699},text=""},
            {pos={-2789.5176,1681.5839,106.0699},text=""},
            {pos={-2750.8950,1948.6273,119.0699},text=""},
            {pos={-2760.5046,2307.6731,190.0699},text=""},
            {pos={-2713.2451,2573.9888,176.0699},text=""},
            {pos={-2562.3796,2641.4131,167.0699},text=""},
            {pos={-2404.5508,2571.7224,118.0699},text=""},
            {pos={-2267.8752,2442.7629,47.0699},text=""},
            {pos={-2167.1570,2424.7397,60.0699},text=""},
            {pos={-1965.3710,2534.7236,110.0699},text=""},
            {pos={-1800.6801,2674.2478,110.0699},text=""},
            {pos={-1610.4302,2565.1184,121.0699},text=""},
            {pos={-1429.8251,2240.3821,104.0699},text=""},
            {pos={-1195.7914,2140.2769,111.0699},text=""},
            {pos={-896.3398,2171.2063,134.0699},text=""},
            {pos={-701.7076,2257.3850,152.0699},text=""},
            {pos={-753.1896,2403.6045,178.0699},text=""},
            {pos={-668.8662,2532.5889,163.0699},text=""},
            {pos={-479.3855,2336.4209,163.0699},text=""},
            {pos={-410.4908,2208.9661,99.0699},text=""},
            {pos={-18.4776,1890.5232,99.0699},text=""},
            {pos={218.4996,2107.3625,99.0699},text=""},
            {pos={144.3703,2294.4246,73.0699},text=""},
            {pos={-254.5630,2526.0110,77.0699},text=""},
            {pos={-449.2220,2615.1089,101.0699},text=""},
            {pos={-742.7629,2722.9609,119.0699},text=""},
            {pos={-928.8480,2623.0688,142.0699},text=""},
            {pos={-840.6469,2492.6465,176.0699},text=""},
            {pos={-668.3939,2518.8667,136.0699},text=""},
            {pos={-426.3958,2552.0149,90.0699},text=""},
            {pos={-115.1001,2512.5632,48.0699},text=""},
            {pos={233.2539,2501.3430,17.9022},text=""},
            {pos={326.7385,2502.2866,17.9190},text=""},
        },
    },
}

PJ.textures = {
    "assets/images/window_start.png",
    "assets/images/icon_start.png",
    "assets/images/button_start.png",
    "assets/images/button_close.png",

    "assets/images/window_praktyka.png",
    "assets/images/circle.png",
    "assets/images/circle_b.png",
    "assets/images/instruktor.png",
}

PJ.fonts = {
    {":px_assets/fonts/Font-SemiBold.ttf", 15/zoom},
    {":px_assets/fonts/Font-Medium.ttf", 13/zoom},
    {":px_assets/fonts/Font-Medium.ttf", 15/zoom},
    {":px_assets/fonts/Font-Regular.ttf", 13/zoom},
    {":px_assets/fonts/Font-Medium.ttf", 11/zoom},
    {":px_assets/fonts/Font-Regular.ttf", 18/zoom},
    {":px_assets/fonts/Font-Medium.ttf", 18/zoom},
}

PJ.gui = {
    alpha = 0,
}

-- collateral

PJ.markers = {}
PJ.imgs = {}
PJ.fnts = {}
PJ.buttons = {}
PJ.points = {}
PJ.point = 1
PJ.yes=false
PJ.tick=getTickCount()

-- utlits

PJ.create = function()
    for i,v in pairs(PJ.places) do
        for _,k in pairs(v.pos) do
            local tex=(i == "L1" and "marker-l" or i == "A" and "marker" or "marker-"..string.lower(i))
            local marker = createMarker(k[1], k[2], k[3]-1, "cylinder", 1.1, 0, 255, 125, 0)
            local cs = createColSphere(k[1], k[2], k[3], 1)
            setElementData(marker, "icon", ":px_licenses/assets/images/markers/"..tex..".png")
            setElementData(marker, "text", {text="Kategoria "..i,desc="Egzamin praktyczny"})

            PJ.markers[#PJ.markers+1] = {marker=cs, type=i, desc=v.desc, cost=v.cost, points=v.points, have=i == "L1" and "L" or i == "L2" and "L" or i}
        end
    end
end

PJ.getMarker = function(marker)
    local type = false
    for i,v in pairs(PJ.markers) do
        if(v.marker == marker)then
            type = v
            break
        end
    end
    return type
end

-- resp

PJ.cs={
    ["A"]={
        spawn={1144.0549,1313.9062,10.3404,0,0,180.1531},
    },
    
    ["B"]={
        spawn={1144.5039,1263.3660,10.4784,0,0,89.4062},
    },

    ["C"]={
        spawn={1132.3267,1251.9021,10.8101,0,0,90.9280},
    },

    ["C+E"]={
        spawn={1114.6080,1211.2186,11.4266,0,0,268.9911},
    },

    ["L1"]={
        spawn={421.7249,2512.5894,16.9427,0,0,89.1542},
    },

    ["L2"]={
        spawn={421.5135,2512.0198,17.8841,0,0,90.6462},
    },
}

function isFreeSpawn(kat)
    if(not PJ.cs[kat])then return true end

    local free=true
    for i,v in pairs(PJ.cs[kat]) do
        local elements=getElementsWithinRange(v[1], v[2], v[3], 5, "vehicle")
        if(elements and #elements > 0)then
            free=false
            break
        end
    end

    return free
end

-- start

PJ.marker = {}

PJ.createPoint = function()
    local v = PJ.gui.points[PJ.point]
    if(not v)then return end

    local size=v.plac and 1.5 or 2.5
    local type=(PJ.gui.type == "A" or PJ.gui.type == "B" or PJ.gui.type == "C" or PJ.gui.type == "C+E") and "cylinder" or "ring"
    local color=(PJ.gui.type == "A" or PJ.gui.type == "B" or PJ.gui.type == "C" or PJ.gui.type == "C+E") and {0, 255, 255} or {255,0,0}
    size=(PJ.gui.type == "A" or PJ.gui.type == "B" or PJ.gui.type == "C" or PJ.gui.type == "C+E") and size or 4

    local next=PJ.gui.points[PJ.point+1]
    local nextPos=next and next.pos or v.pos
    PJ.marker = {}
    PJ.marker[1] = createMarker(v.pos[1], v.pos[2], v.pos[3], type, size, color[1], color[2], color[3], 100)
    PJ.marker[2] = createBlip(v.pos[1], v.pos[2], v.pos[3], 19)
    setElementData(PJ.marker[1], "icon", ":px_licenses/assets/images/markers/flag.png")
    setElementData(PJ.marker[2], "blip:data", {distance=5,color={150, 50, 50},text="Punkt"})
    setMarkerTarget(PJ.marker[1], nextPos[1], nextPos[2], nextPos[3])
end

function getCirclePosition(x,y,w)
    return x+w/2,y+w/2,w/2
end

function getCircleNormalRot(rot)
    rot=rot+45
end

function _dxDrawCircle(x,y,w,r1,r2,color)
    r1=r1+90
    r2=r2+90
    if(r2 > 270)then
        dxDrawCircle(x,y,w,r1,r2,color)
        dxDrawCircle(x,y,w,r2,(r2-(270-90)),color)
    else
        dxDrawCircle(x,y,w,r1,r2,color)
    end
end

PJ.onRenderPoints = function()
    local veh = getPedOccupiedVehicle(localPlayer)
    local v = PJ.gui.points[PJ.point]
    if(not v or not veh)then return end

    if(v.vehPos)then
        local trailer=getVehicleTowedByVehicle(veh)
        if(trailer)then
            setElementFrozen(trailer, true)
        end

        setPedCanBeKnockedOffBike(localPlayer, false)
        setElementFrozen(veh, true)
        setElementFrozen(localPlayer, true)

        fadeCamera(false, 0.1)

        setTimer(function()
            if(trailer)then
                setElementPosition(trailer, v.trailerPos[1], v.trailerPos[2], v.trailerPos[3])
                setElementRotation(trailer, v.trailerPos[4], v.trailerPos[5], v.trailerPos[6])
            end

            setElementPosition(veh, v.vehPos[1], v.vehPos[2], v.vehPos[3])
            setElementRotation(veh, v.vehPos[4], v.vehPos[5], v.vehPos[6])

            setTimer(function()
                setPedCanBeKnockedOffBike(localPlayer, true)

                setElementFrozen(veh, false)
                setElementFrozen(localPlayer, false)

                if(trailer)then
                    attachTrailerToVehicle(veh, trailer)
                    setElementFrozen(trailer, false)
                end

                fadeCamera(true, 0.5)
            end, 500, 1)
        end, 100, 1)

        PJ.point=PJ.point+1
        PJ.createPoint()
        PJ.tick=getTickCount()
    else
        if(PJ.gui.type == "A" or PJ.gui.type == "B" or PJ.gui.type == "C" or PJ.gui.type == "C+E")then
            local text = v.text
            if(getVehicleOverrideLights(veh) == 1)then
                text = "Zapal światła w pojeździe."
            elseif(not getVehicleEngineState(veh))then
                text = "Odpal silnik w pojeździe."
            elseif(getElementData(veh, "vehicle:handbrake") and PJ.gui.type ~= "A")then
                text = "Spuść hamulec ręczny."
            end

            if(PJ.gui.type == "C+E")then
                local trailer=getVehicleTowedByVehicle(veh)
                if(not trailer)then
                    text = "Podepnij naczepe do ciągnika."
                end
            end

            local time=120
            local next=PJ.gui.points[PJ.point-1]
            if(next and not v.plac and next.pos and v.pos)then
                local dist=getDistanceBetweenPoints3D(v.pos[1], v.pos[2], v.pos[3], next.pos[1], next.pos[2], next.pos[3])
                if(dist > 0)then
                    time=dist*2
                end
            end

            local times=(getTickCount()-PJ.tick)/1000

            local rot=360*((time-times)/time)
            
            blur:dxDrawBlur(sw/2-506/2/zoom, 26/zoom, 506/zoom, 125/zoom, tocolor(255, 255, 255))
            dxDrawImage(sw/2-506/2/zoom, 26/zoom, 506/zoom, 125/zoom, PJ.imgs[5])

            dxDrawText("Instruktor", sw/2-506/2/zoom+22/zoom, 26/zoom+10/zoom, 506/zoom, 125/zoom, tocolor(185, 185, 185, 255), 1, PJ.fnts[7], "left", "top", false)
            dxDrawImage(sw/2-506/2/zoom+22/zoom+dxGetTextWidth("Instruktor", 1, PJ.fnts[7])+10/zoom, 26/zoom+10/zoom+8/zoom, 19/zoom, 19/zoom, PJ.imgs[8])
            dxDrawText(text or "?", sw/2-506/2/zoom+22/zoom, 26/zoom+40/zoom, sw/2-506/2/zoom+22/zoom+350/zoom, 125/zoom, tocolor(150, 150, 150, 255), 1, PJ.fnts[2], "left", "top", false, true)
                
            dxDrawText("Egzamin praktyczny", sw/2-506/2/zoom+22/zoom, 26/zoom+90/zoom, 506/zoom, 125/zoom, tocolor(150, 150, 150, 255), 1, PJ.fnts[2], "left", "top", false)

            dxDrawImage(sw/2-506/2/zoom+506/zoom-79/zoom-30/zoom+2, 26/zoom+10/zoom+2, 79/zoom-4, 79/zoom-4, PJ.imgs[6], 0, 0, 0, tocolor(190, 190, 190))
            dxDrawImage(sw/2-506/2/zoom+506/zoom-79/zoom-30/zoom+1, 26/zoom+10/zoom+1, 79/zoom-2, 79/zoom-2, PJ.imgs[6], 0, 0, 0, tocolor(190, 190, 190))
            
            local x,y,w=getCirclePosition(sw/2-506/2/zoom+506/zoom-79/zoom-30/zoom, 26/zoom+10/zoom, 79/zoom)
            _dxDrawCircle(x,y,w,0,rot,tocolor(103,168,255))

            local time_1=math.floor(time-times)
            local hours = math.floor(time_1/60)
            local minutes = math.floor(time_1-(hours*60))
            minutes=string.format("%02d", minutes)
            time_1=hours..":"..minutes

            dxDrawImage(sw/2-506/2/zoom+506/zoom-79/zoom-30/zoom+3, 26/zoom+10/zoom+3, 79/zoom-6, 79/zoom-6, PJ.imgs[7], 0, 0, 0, tocolor(255, 255, 255))
            dxDrawImage(sw/2-506/2/zoom+506/zoom-79/zoom-30/zoom, 26/zoom+10/zoom, 79/zoom, 79/zoom, PJ.imgs[6], 0, 0, 0, tocolor(190, 190, 190))
            dxDrawText(time_1, sw/2-506/2/zoom+506/zoom-79/zoom-30/zoom, 26/zoom+10/zoom, 79/zoom+sw/2-506/2/zoom+506/zoom-79/zoom-30/zoom, 79/zoom+26/zoom+10/zoom, tocolor(185, 185, 185, 255), 1, PJ.fnts[6], "center", "center", false)
            
            dxDrawText("Pozostały czas", sw/2-506/2/zoom+506/zoom-79/zoom-30/zoom, 26/zoom+10/zoom, 79/zoom+sw/2-506/2/zoom+506/zoom-79/zoom-30/zoom, 79/zoom+26/zoom+10/zoom+25/zoom, tocolor(185, 185, 185, 255), 1, PJ.fnts[5], "center", "bottom", false)

            if(math.floor(time-times) <= 0)then
                PJ.destroyPoint()

                setElementFrozen(getPedOccupiedVehicle(localPlayer), true)
                setElementFrozen(localPlayer, true)

                fadeCamera(false, 0.01)

                setTimer(function()
                    if(SPAM.getSpam())then return end

                    triggerServerEvent("destroy:pj", resourceRoot, PJ.gui.type)

                    setTimer(function()
                        setElementFrozen(localPlayer, false)
                        fadeCamera(true, 0.5)
                    end, 500, 1)
                end, 100, 1)

                noti:noti("Czas minął, oblałeś egzamin.")

                removeEventHandler("onClientMarkerHit", resourceRoot, PJ.onMarkerHit)
                removeEventHandler("onClientRender", root, PJ.onRenderPoints)

                PJ.yes=false
            end

            if(v.result and isElementWithinMarker(localPlayer, PJ.marker[1]) and text == v.text)then
                if(v.result(veh))then
                    PJ.point = PJ.point+1
                    if(PJ.gui.points[PJ.point])then
                        PJ.destroyPoint()
                        PJ.createPoint()
                        PJ.tick=getTickCount()
                        PJ.noti=false
                    end
                else
                    if(not PJ.noti and isElementWithinMarker(localPlayer, PJ.marker[1]))then
                        noti:noti("Zaparkuj równolegle.", "error")
                        PJ.noti=true
                    end
                end
            end
        end
    end
end

PJ.destroyPoint = function()
    checkAndDestroy(PJ.marker[1])
    checkAndDestroy(PJ.marker[2])
end

PJ.onMarkerHit = function(hit, dim)
    if(not PJ.marker[1] or hit ~= localPlayer or not dim or source ~= PJ.marker[1])then return end

    local veh = getPedOccupiedVehicle(localPlayer)
    if(not veh)then return end

    buttons = exports.px_buttons
    noti = exports.px_noti
    blur=exports.blur

    if(PJ.gui.type == "A" or PJ.gui.type == "B" or PJ.gui.type == "C" or PJ.gui.type == "C+E")then
        if(getElementData(veh, "vehicle:handbrake") and PJ.gui.type ~= "A")then
            return
        elseif(not getVehicleEngineState(veh))then
            return
        elseif(getVehicleOverrideLights(veh) == 1)then
            return
        end

        if(PJ.gui.type == "C+E")then
            local trailer=getVehicleTowedByVehicle(veh)
            if(not trailer)then
                return
            end
        end

        if(PJ.gui.points[PJ.point].result)then return end
    end

    PJ.noti=false

    PJ.point = PJ.point+1
    if(PJ.gui.points[PJ.point])then
        PJ.destroyPoint()
        if(not PJ.gui.points[PJ.point].vehPos)then
            PJ.createPoint()
            PJ.tick=getTickCount()
        end
    else
        if(SPAM.getSpam())then return end

        PJ.destroyPoint()

        setElementFrozen(veh, true)
        setElementFrozen(localPlayer, true)

        fadeCamera(false, 0.1)

        setTimer(function()
            triggerServerEvent("destroy:pj", resourceRoot, PJ.gui.type)

            setTimer(function()
                setElementFrozen(localPlayer, false)
                fadeCamera(true, 0.5)
            end, 500, 1)
        end, 100, 1)

        noti:noti("Pomyślnie zdałeś egzamin praktyczny na prawo jazdy kategorii "..PJ.gui.type..". Gratulacje!")
        removeEventHandler("onClientMarkerHit", resourceRoot, PJ.onMarkerHit)

        triggerServerEvent("give:pj", resourceRoot, PJ.gui.type, 2)

        removeEventHandler("onClientRender", root, PJ.onRenderPoints)

        PJ.yes=false
    end
end

-- drawing

PJ.renders = {
    main = function()
        blur:dxDrawBlur(sw/2-600/2/zoom, sh/2-360/2/zoom, 600/zoom, 360/zoom, tocolor(255, 255, 255, PJ.gui.alpha))
        dxDrawImage(sw/2-600/2/zoom, sh/2-360/2/zoom, 600/zoom, 360/zoom, PJ.imgs[1], 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha))

        dxDrawText("Egzamin praktyczny", sw/2-600/2/zoom, sh/2-360/2/zoom+31/zoom-10/zoom, sw/2-600/2/zoom+600/zoom, sh/2-360/2/zoom+93/zoom, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[1], "center", "top", false)
        dxDrawText("Kategoria "..PJ.gui.type, sw/2-600/2/zoom, sh/2-360/2/zoom+59/zoom-10/zoom, sw/2-600/2/zoom+600/zoom, sh/2-360/2/zoom+93/zoom, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[2], "center", "top", false)

        local w=dxGetTextWidth("Egzamin praktyczny", 1, PJ.fnts[1])+10/zoom
        dxDrawImage(sw/2-600/2/zoom+(600/zoom)/2+w/2, sh/2-360/2/zoom+31/zoom-5/zoom, 18/zoom, 18/zoom, PJ.imgs[2], 0, 0, 0, tocolor(255, 255, 255, PJ.gui.alpha))

        dxDrawRectangle(sw/2-559/2/zoom, sh/2-360/2/zoom+93/zoom, 559/zoom, 1, tocolor(85, 85, 85, PJ.gui.alpha))

        dxDrawText("Witaj!", sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+116/zoom, sw/2-600/2/zoom+600/zoom, sh/2-360/2/zoom+93/zoom, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[3], "left", "top", false)
        dxDrawText(PJ.gui.info, sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+144/zoom, sw/2-600/2/zoom+600/zoom-35/zoom, sh/2-360/2/zoom+93/zoom, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[4], "left", "top", false, true)
        
        dxDrawText("Wymagania:", sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+204/zoom, sw/2-600/2/zoom+600/zoom, sh/2-360/2/zoom+93/zoom, tocolor(200, 200, 200, PJ.gui.alpha), 1, PJ.fnts[3], "left", "top", false)
        dxDrawText("Poziom postaci: 1\nZapłata "..PJ.gui.cost.." $", sw/2-600/2/zoom+35/zoom, sh/2-360/2/zoom+230/zoom, sw/2-600/2/zoom+600/zoom-35/zoom, sh/2-360/2/zoom+93/zoom, tocolor(185, 185, 185, PJ.gui.alpha), 1, PJ.fnts[4], "left", "top", false, true)

        -- click
        onClick(sw/2-140/zoom-10/zoom, sh/2-360/2/zoom+289/zoom, 140/zoom, 37/zoom, function()
            if(SPAM.getSpam())then return end

            if(PJ.gui.animate or PJ.yes)then return end

            noti = exports.px_noti

            if(not isFreeSpawn(PJ.gui.type))then noti:noti("Zaczekaj aż pojazd odjedzie z miejsca spawnu.", "error") return end

            if(PJ.gui.cost > 0)then
                if(getPlayerMoney(localPlayer) < PJ.gui.cost)then
                    noti:noti("Nie posiadasz funduszy na podejście do tego egzaminu!")
                    return
                else
                    triggerServerEvent("take:money", resourceRoot, PJ.gui.cost)
                end
            end

            -- start
            triggerServerEvent("start:pj", resourceRoot, PJ.gui.type)

            fadeCamera(false, 0.5)
            setElementFrozen(localPlayer, true)

            setTimer(function()
                setTimer(function()
                    setElementFrozen(localPlayer, false)
                    fadeCamera(true, 0.5)

                    PJ.point = 1
                    PJ.createPoint()

                    addEventHandler("onClientMarkerHit", resourceRoot, PJ.onMarkerHit)
                    triggerServerEvent("warp:pj", resourceRoot)

                    PJ.tick=getTickCount()
                end, 500, 1)
            end, 500, 1)

            PJ.yes=true
            --

            showCursor(false)
            PJ.gui.animate = true
            animate(PJ.gui.alpha, 0, "Linear", 500, function(a)
                PJ.gui.alpha = a

                for i = 1,#PJ.buttons do
                    buttons:buttonSetAlpha(i, a)
                end
            end, function()
                PJ.gui.animate = false

                removeEventHandler("onClientRender", root, PJ.renders.main)

                for i = 1,#PJ.buttons do
                    buttons:destroyButton(PJ.buttons[i])
                end

                addEventHandler("onClientRender", root, PJ.onRenderPoints)

                setElementData(localPlayer, "user:gui_showed", false, false)
            end)
        end)

        onClick(sw/2+10/zoom, sh/2-360/2/zoom+289/zoom, 140/zoom, 37/zoom, function()
            if(PJ.gui.animate or PJ.yes)then return end

            PJ.gui.animate = true
            showCursor(false)
            animate(PJ.gui.alpha, 0, "Linear", 500, function(a)
                PJ.gui.alpha = a

                for i = 1,#PJ.buttons do
                    buttons:buttonSetAlpha(i, a)
                end
            end, function()
                PJ.gui.animate = false

                removeEventHandler("onClientRender", root, PJ.renders.main)

                for i = 1,#PJ.buttons do
                    buttons:destroyButton(PJ.buttons[i])
                end

                for i,v in pairs(PJ.textures) do
                    checkAndDestroy(v)
                end

                for i,v in pairs(PJ.fonts) do
                    checkAndDestroy(v)
                end

                setElementData(localPlayer, "user:gui_showed", false, false)
            end)
        end)
    end,
}

-- showing

addEventHandler("onClientColShapeHit", resourceRoot, function(hit, dim)
    if(PJ.marker[1] and source == PJ.marker[1])then return end
    if(hit ~= localPlayer or not dim or PJ.gui.animate)then return end

    if(getElementData(localPlayer, "user:gui_showed"))then return end

    if(getElementData(localPlayer, "user:job") or getElementData(localPlayer, "user:faction"))then
        noti:noti("Najpierw zakończ pracę.")
        return
    end

    local info = PJ.getMarker(source)
    if(info)then
        noti = exports.px_noti

        local take = getElementData(localPlayer, "user:license_take")
        if(take)then
            outputChatBox("-------------------------------------------", 255, 0, 0)
            outputChatBox("Posiadasz zawieszone prawo jazdy!", 255, 0, 0)
            outputChatBox("Osoba zawieszająca: "..take["admin"], 255, 0, 0)
            outputChatBox("Powód zawieszenia: "..take["reason"], 255, 0, 0)
            outputChatBox("Czas zawieszenia: "..take["date"], 255, 0, 0)
            outputChatBox("----------------------------------------", 255, 0, 0)
            return
        end


        local licenses = getElementData(hit, "user:licenses")
        local have=info.have or info.type
        if(not licenses[string.lower(have)] or licenses[string.lower(have)] == 0)then
            noti:noti("Najpierw musisz podejść do egzaminu teoretycznego!")
            return
        elseif(licenses[string.lower(info.type)] and licenses[string.lower(info.type)] == 2)then
            noti:noti("Posiadasz już zdany egzamin praktyczny na prawo jazdy kategorii "..info.type..".")
            return
        end

        if(info.type == "L2")then
            local online=getElementData(localPlayer, "user:pilotWeekTime") or 0
            local hours = math.floor(online/60)
            local minutes = math.floor(online-(hours*60))
            if(hours < 10)then
                noti:noti("Aby rozpocząć egzamin praktyczny L2 musisz wylatać 10 godzin w ciągu tygodnia na L1. Aktualnie masz wylatane: "..hours.." godzin i "..minutes.." minut.", "error")
                return
            end
        end

        buttons = exports.px_buttons

        PJ.gui.alpha = 0
        PJ.gui.info = info.desc
        PJ.gui.cost = info.cost
        PJ.gui.type = info.type
        PJ.gui.points = info.points

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

        showCursor(true)

        for i,v in pairs(PJ.textures) do
            PJ.imgs[i] = dxCreateTexture(v, "argb", false, "clamp")
        end

        for i,v in pairs(PJ.fonts) do
            PJ.fnts[i] = dxCreateFont(v[1], v[2])
        end

        addEventHandler("onClientRender", root, PJ.renders.main)

        PJ.buttons[1] = buttons:createButton(sw/2-140/zoom-10/zoom, sh/2-360/2/zoom+289/zoom, 140/zoom, 37/zoom, "ZACZNIJ EGZAMIN", 0, 7/zoom, false, false, ":px_licenses/assets/images/button_start.png")
        PJ.buttons[2] = buttons:createButton(sw/2+10/zoom, sh/2-360/2/zoom+289/zoom, 140/zoom, 37/zoom, "ZAMKNIJ EGZAMIN", 0, 7/zoom, false, false, ":px_licenses/assets/images/button_close.png", {132,39,39})

        PJ.gui.animate = true
        animate(PJ.gui.alpha, 255, "Linear", 500, function(a)
            PJ.gui.alpha = a

            for i = 1,#PJ.buttons do
				buttons:buttonSetAlpha(i, a)
			end
        end, function()
            PJ.gui.animate = false
        end)
    end
end)

-- events

addEvent("stop:pj", true)
addEventHandler("stop:pj", resourceRoot, function()
    PJ.destroyPoint()
    setElementFrozen(getPedOccupiedVehicle(localPlayer), true)

    setElementFrozen(localPlayer, true)

    fadeCamera(false, 0.5)

    removeEventHandler("onClientRender", root, PJ.onRenderPoints)

    setTimer(function()
        if(SPAM.getSpam())then return end

        triggerServerEvent("destroy:pj", resourceRoot, PJ.gui.type)

        setTimer(function()
            setElementFrozen(localPlayer, false)
            fadeCamera(true, 0.5)
        end, 500, 1)
    end, 500, 1)

    PJ.yes=false
end)

addEventHandler("onClientPlayerWasted", localPlayer, function()
    if(PJ.yes)then
        PJ.destroyPoint()

        setElementFrozen(getPedOccupiedVehicle(localPlayer), true)
        setElementFrozen(localPlayer, true)

        fadeCamera(false, 0.01)

        setTimer(function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("destroy:pj", resourceRoot, PJ.gui.type)

            setTimer(function()
                setElementFrozen(localPlayer, false)
                fadeCamera(true, 0.5)
            end, 500, 1)
        end, 100, 1)

        noti:noti("Zginąłeś więc nie zdajesz egzaminu na prawo jazdy.")

        removeEventHandler("onClientMarkerHit", resourceRoot, PJ.onMarkerHit)
        removeEventHandler("onClientRender", root, PJ.onRenderPoints)

        PJ.yes=false
    end
end)

-- creating

PJ.create()