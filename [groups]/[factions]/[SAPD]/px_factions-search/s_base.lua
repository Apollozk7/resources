--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local bus={}

bus.places={
    {2382.8201,-1638.0649,13.5223,315.9233},
    {2197.6553,-1504.6001,24.0092,137.3175},
    {2453.9319,-1461.1143,24.0523,270.3777},
    {2333.7195,-1340.8528,24.1268,342.5004},
    {2410.8625,-1419.2053,24.0827,319.0160},
    {2656.2522,-1329.8002,39.2491,271.0648},
    {2681.1907,-1397.7463,30.6423,311.1969},
    {2529.0591,-2010.4202,13.5959,267.8785},
    {2334.4592,-1998.6028,13.6001,219.9103},
    {2249.4629,-1917.9010,13.5802,0.6865},
    {2170.3396,-1923.8074,13.5802,88.1317},
    {1989.3564,-1899.7578,13.6051,46.2627},
    {1871.2906,-1861.5806,13.6373,30.0199},
    {1911.0455,-1775.8448,13.6991,359.1028},
    {2012.5543,-1785.2695,13.5950,269.9882},
    {2060.7598,-1780.1908,13.5998,268.8085},
    {2161.9541,-1793.8383,13.4388,92.3463},
    {2025.7024,-1589.0658,13.6699,9.8762},
    {2112.7766,-1370.5087,24.0195,358.7393},
    {2622.2761,-1484.8894,16.6017,346.2278},
}

bus.names={
    "Pony",
    "Rumpo",
    "Newsvan",
    "Boxville"
}

bus.max=2
bus.resp=0
bus.time=60

-- functions

bus.createBus=function()
    if(bus.resp < bus.max)then
        bus.resp=bus.resp+1

        local rnd=math.random(1,#bus.places)
        local inf=bus.places[rnd]
        local rnd=math.random(1,#bus.names)
        local name=bus.names[rnd]

        local veh=createVehicle(getVehicleModelFromName(name), inf[1], inf[2], inf[3], 0, 0, inf[4])
        setVehicleColor(veh, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        setElementFrozen(veh, true)
        setElementData(veh, "interaction", {options={
            {name="Przeszukaj busa", alpha=0, animate=false, tex=":px_dm-drops/textures/bus.png"},
        }, scriptName="px_dm-drops", dist=3})
    end
end

-- triggers

addEvent("destroy.bus", true)
addEventHandler("destroy.bus", resourceRoot, function(veh)
    destroyElement(veh)
    bus.resp=bus.resp-1
end)

-- timers

setTimer(function()
    bus.createBus()
end, (bus.time*60000), 0)

-- quit

addEventHandler("onPlayerQuit", root, function()
    local block=getElementData(source, "block")
    if(block and isElement(block))then
        setElementData(block, "block", false)
    end
end)