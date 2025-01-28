--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local timers={}

local alpha_cuboids = {
    {1972.84937, 2046.95825, 9.82031, 5.1458740234375, 9.914794921875, 1.9, "vehicle"},
    {2210.05737, 1418.64392, 9.81252, 11.517822265625, 4.23974609375, 1.9077953338623, "vehicle"},
    {2400.86938, 1480.55884, 9.82031, 9.1796875, 15.025634765625, 4, "vehicle"},
    {2541.56958, 2126.36060, 9.81299, 36.1298828125, 45.73950195312, 9.9173263549805, "all"},
    {2288.92578, 1788.50037, 10.07469, 9.99658203125, 12.641479492188, 4, "vehicle"}, -- wypo
    {2799.16016, 974.10016, 9.75000, 31.309326171875, 25.369567871094, 5.8799995422363, "all"}, -- kurier
    {110.36491, 1335.43079, 9.72834, 178.17304992676, 150.51232910156, 19.9, "all"}, -- rafineria
    {2789.12524, 2014.39795, 9.80146, 4.704833984375, 7.1572265625, 1.9069427490234, "all"}, -- salon premium
    {-153.50906, -295.04758, 2.89904, 27.658714294434, 39.102844238281, 12.997208023071, "all"}, -- tiry
    {753.72229, 1925.84631, 4.67818, 6.8547973632812, 7.81689453125, 1.7196892738342, "all"}, -- cygan pod lv
    {-889.78479, 1560.58069, 24.95153, 10.030517578125, 7.564208984375, 2.4559215545654, "all"}, -- cygan 2
    {1156.02747, 1319.80103, 9.82031, 22.221313476562, 44.52001953125, 11.212782287598, "all"}, -- prawo jazdy
    {-1865.55725, 108.77190, 14.15252, 37.152465820312, 63.955169677734, 13.009999656677,"all"}, -- smieciarki
    {1569.36560, 1419.19458, 9.84718, 21.32763671875, 57.181518554688, 10.9,"all"}, -- lotnisko
    {-1848.2811,125.4163,15.1172,20,"all","sphere"}, -- kosiarki
    {-1216.84851, -1185.43298, 120.18875, 184.18994140625, 119.15307617188, 16.230001831055,"all"}, -- usuwanie pni
    {-1931.22375, 267.61423, 40.04688, 5.895751953125, 10.134796142578, 3.0100006103516, "vehicle"}, -- salon sf
    {-1713.43005, 1201.97375, 24.12885, 11.321533203125, 11.365234375, 5.8681396484375, "vehicle"}, -- salon sf motory
}

for i,v in ipairs(alpha_cuboids) do
    if(v[6] == "sphere")then
        local cs = createColSphere(v[1],v[2],v[3],v[4])
        setElementData(cs, "ghost:type", "all", false)
    else
        local cs = createColCuboid(v[1], v[2], v[3], v[4], v[5], v[6])
        setElementData(cs, "ghost:type", v[7], false)
    end
end

local types={
    ["player"]=true,
    ["vehicle"]=true,
    ["ped"]=true
}

addEventHandler("onColShapeHit", resourceRoot, function(hit, dim)
	if(not hit or hit and not isElement(hit) or not dim)then return end

    local type = getElementData(source, "ghost:type")
    if(type == "all" and types[getElementType(hit)])then
        local ghost = getElementData(hit, "ghost")
        if(not ghost)then
            setElementData(hit, "ghost_cs", type)
        end
    elseif(type ~= "all" and getElementType(hit) == type)then
        local ghost = getElementData(hit, "ghost")
        if(not ghost)then
            setElementData(hit, "ghost_cs", type)
        end
    end
end)

addEventHandler("onColShapeLeave", resourceRoot, function(hit, dim)
	if(not hit or hit and not isElement(hit) or not dim)then return end

    if(types[getElementType(hit)])then
        setElementData(hit, "ghost_cs", false)
    end
end)