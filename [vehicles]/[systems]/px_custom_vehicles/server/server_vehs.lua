--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local vehicles={
    [438]={
        start=1.8,
        engines={
            2.0,
            2.5,
            3.0
        }
    }, -- Cabbie
    
    [400]={
        start=1.8,
        engines={
            2.0,
            2.2,
            3.0
        }
    }, -- Landstalker

    [401]={
        start=1.0,
        engines={
            1.2,
            1.4,
            1.6
        }
    }, -- Bravura

    [402]={
        start=2.0,
        engines={
            2.2,
            2.8,
            3.5
        }
    }, -- Buffalo

    [403]={
        start=10.0,
        engines={
            12.0,
            13.0,
            15.0
        }
    }, -- Linerunner

    [404]={
        start=1.2,
        engines={
            1.4,
            1.6,
            1.8
        }
    }, -- Perennial

    [405]={
        start=1.6,
        engines={
            1.8,
            2.2,
            2.5
        }
    }, -- Sentinel

    [409]={
        start=2.5,
        engines={
            3.0,
            3.5,
            4.0
        }
    }, -- Stretch

    [410]={
        start=1.1,
        engines={
            1.2,
            1.6,
            1.8
        }
    }, -- Manana

    [411]={
        start=3.0,
        engines={
            3.8,
            4.2,
            5.2
        }
    }, -- Infernus

    [412]={
        start=2.5,
        engines={
            3.0,
            3.2,
            3.8
        }
    }, -- Voodoo

    [413]={
        start=1.8,
        engines={
            2.2,
            2.4,
            2.8
        }
    }, -- Pony

    [415]={
        start=2.8,
        engines={
            3.0,
            3.2,
            4.2
        }
    }, -- Cheetah

    [418]={
        start=1.4,
        engines={
            1.6,
            1.8,
            2.2
        }
    }, -- Moonbeam

    [419]={
        start=2.4,
        engines={
            2.8,
            3.2,
            3.8
        }
    }, -- Esperanto

    [421]={
        start=1.6,
        engines={
            1.8,
            2.2,
            2.5
        }
    }, -- Washington

    [422]={
        start=1.2,
        engines={
            1.6,
            2.0,
            2.5
        }
    }, -- Bobcat

    [424]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.5
        }
    }, -- BF Injection

    [426]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.8
        }
    }, -- Premier

    [429]={
        start=2.5,
        engines={
            3.0,
            3.2,
            4.0
        }
    }, -- Banshee

    [434]={
        start=1.8,
        engines={
            2.2,
            2.5,
            2.8
        }
    }, -- Hotknife

    [436]={
        start=1.2,
        engines={
            1.4,
            1.8,
            2.0
        }
    }, -- Previon

    [439]={
        start=2.0,
        engines={
            2.4,
            2.8,
            3.5
        }
    }, -- Stallion

    [440]={
        start=1.6,
        engines={
            1.8,
            2.5,
            3.0
        }
    }, -- Rumpo

    [442]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Romero

    [443]={
        start=4.2,
        engines={
            4.4,
            5.6,
            5.9
        }
    }, -- Packer

    [444]={
        start=3.0,
        engines={
            3.5,
            4.8,
            6.0
        }
    }, -- Monster

    [445]={
        start=1.6,
        engines={
            1.8,
            2.2,
            2.5
        }
    }, -- Admiral

    [451]={
        start=3.2,
        engines={
            3.8,
            4.0,
            5.2
        }
    }, -- Turismo

    [456]={
        start=2.5,
        engines={
            2.8,
            3.0,
            3.2
        }
    }, -- Yankee

    [457]={
        start=0.6,
        engines={
            0.8,
            1.0,
            1.2
        }
    }, -- Caddy

    [458]={
        start=1.4,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Solair

    [461]={
        start=0.6,
        engines={
            0.8,
            1.0,
            1.2
        }
    }, -- PCJ-600

    [462]={
        start=0.2,
        engines={
            0.3,
            0.4,
            0.5
        }
    }, -- Faggio

    [463]={
        start=1.0,
        engines={
            1.2,
            1.4,
            2.0
        }
    }, -- Freeway

    [466]={
        start=1.4,
        engines={
            1.6,
            2.0,
            2.2
        }
    }, -- Glendale

    [467]={
        start=1.4,
        engines={
            1.6,
            2.0,
            2.2
        }
    }, -- Oceanic

    [468]={
        start=0.4,
        engines={
            0.5,
            0.6,
            0.8
        }
    }, -- Sanchez

    [470]={
        start=2.2,
        engines={
            2.5,
            3.0,
            3.5
        }
    }, -- Patriot

    [471]={
        start=0.4,
        engines={
            0.6,
            0.8,
            1.0
        }
    }, -- Quadbike

    [474]={
        start=2.2,
        engines={
            2.5,
            3.0,
            3.8
        }
    }, -- Hermes

    [475]={
        start=2.0,
        engines={
            2.8,
            3.2,
            4.0
        }
    }, -- Sabre

    [477]={
        start=1.8,
        engines={
            2.2,
            2.8,
            3.5
        }
    }, -- ZR-350

    [478]={
        start=1.0,
        engines={
            1.1,
            1.2,
            1.6
        }
    }, -- Walton

    [479]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Regina

    [480]={
        start=1.6,
        engines={
            2.2,
            3.0,
            4.2
        }
    }, -- Comet

    [482]={
        start=1.8,
        engines={
            2.0,
            2.2,
            3.0
        }
    }, -- Burrito

    [483]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.5
        }
    }, -- Camper

    [489]={
        start=1.8,
        engines={
            2.2,
            2.8,
            3.5
        }
    }, -- Rancher

    [491]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Virgo

    [492]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Greenwood

    [495]={
        start=2.5,
        engines={
            2.8,
            3.2,
            4.0
        }
    }, -- Sandking

    [496]={
        start=1.4,
        engines={
            1.6,
            2.0,
            2.5
        }
    }, -- Blista Compact

    [498]={
        start=2.0,
        engines={
            2.2,
            2.5,
            3.0
        }
    }, -- Boxville

    [499]={
        start=2.2,
        engines={
            2.4,
            2.6,
            2.8
        }
    }, -- Benson

    [500]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.5
        }
    }, -- Mesa

    [504]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.5
        }
    }, -- Bloodring Banger

    [505]={
        start=1.8,
        engines={
            2.2,
            2.8,
            3.5
        }
    }, -- Rancher Lure

    [506]={
        start=2.5,
        engines={
            3.0,
            3.2,
            3.8
        }
    }, -- Super GT

    [507]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.5
        }
    }, -- Elegant

    [508]={
        start=3.0,
        engines={
            3.6,
            4.0,
            4.5
        }
    }, -- Journey

    [516]={
        start=1.0,
        engines={
            1.2,
            1.4,
            1.6
        }
    }, -- Nebula

    [517]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Majestic

    [518]={
        start=2.0,
        engines={
            2.2,
            2.5,
            3.0
        }
    }, -- Buccaneer

    [521]={
        start=0.9,
        engines={
            1.0,
            1.1,
            1.2
        }
    }, -- FCR-900

    [522]={
        start=0.5,
        engines={
            0.9,
            1.2,
            1.6
        }
    }, -- NRG-500

    [523]={
        start=1.0,
        engines={
            1.1,
            1.2,
            1.3
        }
    }, -- HPV1000

    [526]={
        start=1.4,
        engines={
            1.8,
            2.0,
            2.5
        }
    }, -- Fortune

    [527]={
        start=1.0,
        engines={
            1.1,
            1.2,
            1.4
        }
    }, -- Cadrona

    [529]={
        start=1.4,
        engines={
            1.6,
            1.8,
            2.2
        }
    }, -- Willard

    [533]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.5
        }
    }, -- Feltzer

    [534]={
        start=2.5,
        engines={
            2.8,
            3.4,
            4.0
        }
    }, -- Remington

    [535]={
        start=2.2,
        engines={
            2.5,
            3.2,
            3.8
        }
    }, -- Slamvan

    [536]={
        start=2.0,
        engines={
            2.2,
            2.5,
            3.2
        }
    }, -- Blade

    [540]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.5
        }
    }, -- Vincent

    [541]={
        start=3.2,
        engines={
            3.8,
            4.4,
            5.2
        }
    }, -- Bullet

    [542]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.5
        }
    }, -- Clover

    [543]={
        start=1.4,
        engines={
            1.6,
            1.8,
            2.2
        }
    }, -- Sadler

    [545]={
        start=2.0,
        engines={
            2.2,
            2.4,
            3.0
        }
    }, -- Hustler

    [546]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Intruder

    [547]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Primo

    [549]={
        start=1.6,
        engines={
            1.8,
            1.9,
            2.0
        }
    }, -- Tampa

    [550]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.5
        }
    }, -- Sunrise

    [551]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Merit

    [554]={
        start=1.8,
        engines={
            2.2,
            2.5,
            3.0
        }
    }, -- Yosemite

    [555]={
        start=2.5,
        engines={
            3.0,
            3.5,
            3.8
        }
    }, -- Windsor

    [556]={
        start=3.0,
        engines={
            3.5,
            4.8,
            6.0
        }
    }, -- Monster 2

    [557]={
        start=3.0,
        engines={
            3.5,
            4.8,
            6.0
        }
    }, -- Monster 3

    [558]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.4
        }
    }, -- Uranus

    [559]={
        start=1.8,
        engines={
            2.2,
            2.5,
            2.8
        }
    }, -- Jester

    [560]={
        start=1.8,
        engines={
            2.2,
            2.5,
            2.8
        }
    }, -- Sultan

    [561]={
        start=1.8,
        engines={
            2.2,
            2.5,
            2.8
        }
    }, -- Stratum

    [562]={
        start=1.8,
        engines={
            2.2,
            2.5,
            2.8
        }
    }, -- Elegy

    [565]={
        start=1.6,
        engines={
            1.8,
            2.2,
            2.5
        }
    }, -- Flash

    [566]={
        start=2.0,
        engines={
            2.2,
            2.6,
            2.8
        }
    }, -- Tahoma

    [567]={
        start=2.0,
        engines={
            2.4,
            2.6,
            3.0
        }
    }, -- Savanna

    [568]={
        start=1.2,
        engines={
            1.4,
            1.6,
            1.8
        }
    }, -- Bandito

    [575]={
        start=2.2,
        engines={
            2.4,
            2.8,
            3.2
        }
    }, -- Broadway

    [576]={
        start=2.0,
        engines={
            2.1,
            2.2,
            2.5
        }
    }, -- Tornado

    [579]={
        start=2.5,
        engines={
            2.8,
            3.4,
            4.5
        }
    }, -- Huntley

    [580]={
        start=2.0,
        engines={
            2.2,
            2.4,
            2.6
        }
    }, -- Stafford

    [581]={
        start=0.4,
        engines={
            0.6,
            0.8,
            1.0
        }
    }, -- BF-400

    [582]={
        start=1.8,
        engines={
            2.0,
            2.2,
            2.8
        }
    }, -- Newsvan

    [585]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Emperor

    [586]={
        start=0.8,
        engines={
            1.0,
            1.2,
            1.4
        }
    }, -- Wayfarer

    [587]={
        start=2.0,
        engines={
            2.2,
            2.4,
            2.8
        }
    }, -- Euros

    [589]={
        start=1.2,
        engines={
            1.6,
            2.0,
            2.4
        }
    }, -- Club

    [600]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Picador

    [602]={
        start=1.6,
        engines={
            1.8,
            2.0,
            2.2
        }
    }, -- Alpha

    [603]={
        start=3.0,
        engines={
            3.2,
            3.8,
            4.2
        }
    }, -- Phoenix

    [604]={
        start=1.4,
        engines={
            1.6,
            2.0,
            2.2
        }
    }, -- Glendale Damaged

    [543]={
        start=1.4,
        engines={
            1.6,
            1.8,
            2.2
        }
    }, -- Sadler

    [605]={
        start=1.4,
        engines={
            1.6,
            1.8,
            2.2
        }
    }, -- Sadler Damaged

    [609]={
        start=2.0,
        engines={
            2.2,
            2.5,
            3.0
        }
    }, -- Boxville Mission
}

function getVehicleEngines(model)
    return vehicles[model].engines or {}
end

function getVehicleEngineFromModel(model)
    return (vehicles[model] and vehicles[model].start) and string.format("%.1f", vehicles[model].start) or 1.0
end

function getVehicleEngineFromName(name)
    local model=getVehicleModelFromName(name)
    return (vehicles[model] and vehicles[model].start) and string.format("%.1f", vehicles[model].start) or 1.0
end

local default_usage=5 -- x L paliwa na 100km przy pojemności 1.0
local turbo_usage={
    ["Turbo"]=10,
    ["TwinTurbo"]=15,
    ["BiTurbo"]=20,
}

function getFuelUsage(vehicle)
    if(vehicle and isElement(vehicle) and getElementType(vehicle) == "vehicle")then
        local engine=getElementData(vehicle, "vehicle:engine")
        local def_engine=getVehicleEngineFromModel(getElementModel(vehicle))
        engine=engine or def_engine
        engine=tonumber(engine)

        local usage=default_usage*engine

        local mk1=getElementData(vehicle, "vehicle:mk1")
        local mk2=getElementData(vehicle, "vehicle:mk2")
        local turbo=getElementData(vehicle, "vehicle:turbo")

        if(mk1)then
            usage=usage+math.percent(10,usage)
        end
        if(mk2)then
            usage=usage+math.percent(10,usage)
        end
        if(turbo)then
            usage=usage+math.percent(turbo_usage[turbo] or 10,usage)
        end

        return math.floor(usage)
    elseif(tonumber(vehicle))then
        return math.floor(default_usage*tonumber(vehicle))
    end
end

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end

-- vmaxy

local vmaxs={
    ["Boxville"]=130,
    ["Club"]=156,
    ["Admiral"]=164,
    ["Alpha"]=170,
    ["BF Injection"]=131,
    ["BF-400"]=168,
    ["Bandito"]=131,
    ["Banshee"]=196,
    ["Blade"]=152,
    ["Blista Compact"]=160,
    ["Bobcat"]=142,
    ["Bravura"]=142,
    ["Broadway"]=136,
    ["Buccaneer"]=150,
    ["Buffalo"]=174,
    ["Bullet"]=206,
    ["Burrito"]=140,
    ["Cadrona"]=145,
    ["Camper"]=109,
    ["Cheetah"]=208,
    ["Clover"]=140,
    ["Comet"]=182,
    ["Elegant"]=162,
    ["Elegy"]=188,
    ["Emperor"]=136,
    ["Esperanto"]=138,
    ["Euros"]=162,
    ["FCR-900"]=180,
    ["Faggio"]=50,
    ["Feltzer"]=158,
    ["Flash"]=172,
    ["Fortune"]=162,
    ["Freeway"]=130,
    ["Glendale"]=140,
    ["Greenwood"]=162,
    ["HPV1000"]=171,
    ["Hermes"]=134,
    ["Hotknife"]=150,
    ["Huntley"]=170,
    ["Hustler"]=131,
    ["Infernus"]=226,
    ["Intruder"]=136,
    ["Jester"]=174,
    ["Journey"]=115,
    ["Kart"]=83,
    ["Landstalker"]=160,
    ["Majestic"]=154,
    ["Manana"]=124,
    ["Mesa"]=146,
    ["Moonbeam"]=115,
    ["Mower"]=54,
    ["NRG-500"]=220,
    ["Nebula"]=132,
    ["Newsvan"]=145,
    ["Oceanic"]=125,
    ["PCJ-600"]=181,
    ["Patriot"]=184,
    ["Perennial"]=120,
    ["Phoenix"]=166,
    ["Picador"]=130,
    ["Pony"]=100,
    ["Premier"]=168,
    ["Previon"]=128,
    ["Primo"]=134,
    ["Quadbike"]=99,
    ["Rancher"]=154,
    ["Regina"]=125,
    ["Remington"]=164,
    ["Romero"]=124,
    ["Roadtrain"]=135,
    ["Rumpo"]=120,
    ["Sabre"]=162,
    ["Sadler"]=130,
    ["Sanchez"]=140,
    ["Sandking"]=158,
    ["Savanna"]=166,
    ["Sentinel"]=168,
    ["Slamvan"]=160,
    ["Solair"]=166,
    ["Stafford"]=132,
    ["Stallion"]=160,
    ["Stratum"]=164,
    ["Stretch"]=141,
    ["Sultan"]=176,
    ["Sunrise"]=145,
    ["Super GT"]=192,
    ["Tahoma"]=162,
    ["Tampa"]=152,
    ["Tornado"]=152,
    ["Turismo"]=220,   
    ["Uranus"]=170,
    ["Vincent"]=150,
    ["Virgo"]=138,
    ["Voodoo"]=164,
    ["Walton"]=105,
    ["Washington"]=162,
    ["Wayfarer"]=150,
    ["Willard"]=136,
    ["Windsor"]=180,
    ["Yosemite"]=152,
    ["ZR-350"]=184,
    ["Cabbie"]=145,
}

local police={
    [596]=true,
    [597]=true,
}

function setVehicleDefaultHandling(veh)
    local model=getVehicleName(veh)
    if(model and vmaxs[model])then
        setVehicleHandling(veh, "maxVelocity", vmaxs[model])
    end
end

function getVehicleDefaultVelocity(veh)
    local model=getVehicleName(veh)
    if(model and vmaxs[model])then
        return vmaxs[model]
    end
    return 0
end

addEventHandler("onVehicleEnter", root, function(plr,seat)
    if(seat ~= 0)then return end

    if(getVehicleName(source) == 'Blista Compact' or getVehicleName(source) == 'Huntley')then
        setVehicleModelFlags(source, 4, 2)
    end
end)

-- flags

function setVehicleModelFlags(vehicle, byte, value)
    if vehicle then
        local modelFlags = string.format("%X", getVehicleHandling(vehicle)["modelFlags"])
        local reversedFlags = string.reverse(modelFlags) .. string.rep("0", 8 - string.len(modelFlags))
        local currentByte, flags = 1, ""

        for values in string.gmatch(reversedFlags, ".") do
            if type(byte) == "table" then
                for _, v in ipairs(byte) do
                    if currentByte == v then
                        values = string.format("%X", tonumber(value))
                    end
                end
            else
                if currentByte == byte then
                    values = string.format("%X", tonumber(value))
                end
            end		
            flags = flags .. values
            currentByte = currentByte + 1
        end
        setVehicleHandling(vehicle, "modelFlags", tonumber("0x" .. string.reverse(flags)), false)
    end
end