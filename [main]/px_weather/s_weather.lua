--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

ui.weather=false
ui.weathers={
    {id=0, name="Mocno słonecznie", time=24}, -- godziny i nazwa
    {id=1, name="Słonecznie", time=24}, -- godziny i nazwa
    {id=2, name="Mocno słonecznie i trochę chmur", time=24}, -- godziny i nazwa
    {id=3, name="Lekkie zachmurzenie, słonecznie", time=24}, -- godziny i nazwa
    {id=5, name="Słonecznie i ponuro", time=24}, -- godziny i nazwa
    {id=6, name="Mocno słonecznie i ponuro", time=24}, -- godziny i nazwa
    {id=10, name="Słoneczenie", time=24}, -- godziny i nazwa
    {id=11, name="Mocno słonecznie", time=24}, -- godziny i nazwa
    {id=13, name="Mocno słonecznie", time=24}, -- godziny i nazwa
    {id=14, name="Słonecznie", time=24}, -- godziny i nazwa
    {id=17, name="Bardzo ciepło i słonecznie", time=24}, -- godziny i nazwa
    {id=18, name="Gorąco i słonecznie", time=24}, -- godziny i nazwa
}

ui.miscWeathers={
    {id=8, name="Burza z piorunami i deszczem", time=0.25, small=true}, -- godziny i nazwa
    {id=9, name="Zachmurzenie i mgła", time=0.25, small=true}, -- godziny i nazwa
    {id=16, name="Burza z piorunami", time=0.25, small=true}, -- godziny i nazwa
    {id=19, name="Burza piaskowa", time=0.25, small=true}, -- godziny i nazwa
}

ui.setWeather=function(tbl,rnd)
    v=tbl[rnd]
    if(v)then
        v.idS=rnd
        ui.weather=v

        setWeather(v.id)

        local duration=getMinuteDuration()
        local time=(v.time*(duration/60000))
        time=time*3600000

        setTimer(function()
            ui.getRandomWeather()
        end, time, 1)

        
        local newTime=v.time < 1 and (60*(v.time/1)).."minut" or v.time.." godziny"
        for _,player in pairs(getElementsByType("player")) do
            outputChatBox("#939393Pogoda uległa zmianie na: "..v.name.." i będzie aktywna przez "..newTime..".", player, _, _, _, true)
        end
    end
end

ui.getRandomWeather=function()
    if(ui.weather)then
        if(ui.weather.id == 8 or ui.weather.id == 16)then
            exports["px_factions-trees"]:randomTrees()
        end
    end

    local rdm=math.random(10,30)
    local tbl=ui.weathers

    if((rdm > 20 and rdm < 25) or (ui.weather and ui.weather.small))then
        -- normalna pogoda
        tbl=ui.weathers
        rnd=math.random(1,#tbl)
    else
        -- inne pogody (15 minutowe)
        tbl=ui.miscWeathers
        rnd=math.random(1,#tbl)
    end

    local exist=false
    if(not ui.weather)then
        exist=true
    elseif(ui.weather.idS ~= rnd)then
        exist=true
    end

    if(exist)then
        return ui.setWeather(tbl,rnd)
    end

    setTimer(function()
        ui.getRandomWeather()
    end, 5000, 1)
end
ui.getRandomWeather()

addCommandHandler("pogoda",function(plr)
    if(getElementData(plr,"user:admin") and getElementData(plr,"user:admin") >= 4)then
        ui.getRandomWeather()
    end
end)