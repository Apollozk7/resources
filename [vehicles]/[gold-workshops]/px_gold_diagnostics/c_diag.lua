--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

local shader=[[
    texture gTexture;
    
    technique TexReplace
    {
        pass P0
        {
            Texture[0] = gTexture;
        }
    }
]]

function el() return getElementsByType("dxDiag")[1] end

local tuning={}

function updateElTV()
    local dx=el()
    local data=getElementData(dx, "vehicle")
    if(dx and isElement(dx) and source == dx and data[1] and isElement(data[1]))then
        tuning=exports.px_vehicles:getTuningList()
        
        ui={
            w=1300,
            h=650,
            shader=dxCreateShader(shader),
            font=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 18),
            font2=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 13),
            veh=data[1]
        }

        ui.rt=dxCreateRenderTarget(ui.w, ui.h, true)

        -- tuning
        local upgrades=""
        for i,v in ipairs(getVehicleUpgrades(ui.veh)) do
            local slot=tuning.tuningSlots[getVehicleUpgradeSlotName(v)] or getVehicleUpgradeSlotName(v)
            local upgrade=tuning.tuningNames[v] or v
            if(upgrade == "Lampa" or slot == "Nitro" or slot == "Hydraulika" or slot == "Stereo")then
                text=slot
            else
                text=slot.." ("..upgrade..")"
            end

            if(#upgrades > 0)then
                upgrades=upgrades..", "..text
            else
                upgrades=text
            end
        end
        upgrades=#upgrades > 0 and upgrades or "brak"
        --

        local engine=getElementData(ui.veh, "vehicle:engine")
        engine=(engine and tonumber(engine) and tonumber(engine) > 0) and engine or exports.px_custom_vehicles:getVehicleEngineFromModel(getElementModel(ui.veh))
        engine=engine or 1

        local i={
            name=getVehicleName(ui.veh),
            id=getElementData(ui.veh, "vehicle:id") or getElementData(ui.veh, "vehicle:group_id") or 0,
            dist=string.format("%.2f", getElementData(ui.veh, "vehicle:distance") or 0),
            engine=string.format("%.1f", engine),
            engineType=getElementData(ui.veh, "vehicle:fuelType") or "Petrol",
            mk1=getElementData(ui.veh, "vehicle:mk1"),
            mk2=getElementData(ui.veh, "vehicle:mk2"),
            turbo=getElementData(ui.veh, "vehicle:turbo") or "brak",
            suspension=getElementData(ui.veh, "vehicle:suspension") or "brak",
            brakes=getElementData(ui.veh, "vehicle:brakes") or "brak",
            tank=getElementData(ui.veh, "vehicle:fuelTank") or 25,
            nitro=getElementData(ui.veh, "vehicle:nitro") or "brak",
            lights=getElementData(ui.veh, "vehicle:lights") or 0,
        }

        local x={
            ['ASR OFF']=getElementData(ui.veh, 'vehicle:ASR'),
            ['ALS']=getElementData(ui.veh, 'vehicle:ALS'),
            ['Wykrywacz radarów']=getElementData(ui.veh, 'vehicle:radarDetector'),
            ['CB-Radio']=getElementData(ui.veh, 'vehicle:cbRadio'),
            ['Kolor licznika']=getElementData(ui.veh, 'vehicle:speedoColor'),
            ['Maskowanie szyb']=getElementData(ui.veh, 'vehicle:tint') and getElementData(ui.veh, 'vehicle:tint').."%",
        }

        local addTune=''
        for v,d in pairs(x) do
            if(d)then
                addTune=#addTune > 0 and addTune..', '..v or v
            end
        end

        i.mk=""
        if(i.mk1)then
            i.mk=#i.mk > 0 and i.mk..", MK1" or "MK1"
        end
        if(i.mk2)then
            i.mk=#i.mk > 0 and i.mk..", MK2" or "MK2"
        end

        i.engineType=i.engineType == "Petrol" and "Benzyna" or i.engineType == "LPG" and "LPG" or "Diesel"

        ui.text={
            {"Model", i.name.." - ID "..i.id},
            {"Przebieg", i.dist.."km"},
            {"Silnik", i.engine.."dm³ "..i.engineType},
            {"Układy MK", (#i.mk > 0 and i.mk or "brak")},
            {"Turbosprężarka", i.turbo},
            {"Zawieszenie", i.suspension},
            {"Hamulce", i.brakes},
            {"Bak paliwa", i.tank.." L"},
            {"Nitro", i.nitro},
            {"Tuning", upgrades},
            {"Światła", math.floor(i.lights).."%"},
            {"Dodatkowy tuning", addTune}
        }

        local margin=10
        dxSetRenderTarget(ui.rt, true)
            dxDrawRectangle(0, 0, ui.w, ui.h, tocolor(15,15,15))
            for i,v in pairs(ui.text) do
                local sY=40*(i-1)
                dxDrawText(v[1], margin, margin+sY, ui.w-margin, margin+sY+40, tocolor(255,255,255), 1, ui.font, "left", "center", false, true)
                dxDrawText(v[2], margin+dxGetTextWidth(v[1], 1, ui.font)+10, margin+sY, ui.w-margin, margin+sY+40, tocolor(255,255,255), 1, (v[1] == "Tuning" or v[1] == "Dodatkowy tuning") and ui.font2 or ui.font, "right", "center", false, true)
                dxDrawRectangle(margin, margin+sY+40, ui.w-margin*2, 2, tocolor(80,80,80))
            end
        dxSetRenderTarget()

        dxSetShaderValue(ui.shader, "gTexture", ui.rt)
        engineApplyShaderToWorldTexture(ui.shader, "nf_blackbrd", data[2])
    end
end

function deleteElTV()
    if(source == el())then
        for i,v in pairs(ui) do
            if(v and isElement(v))then
                destroyElement(v)
            end
        end
        ui={}
    end
end

updateElTV()
addEventHandler("onClientElementStreamIn", root, updateElTV)
addEventHandler("onClientElementStreamOut", root, deleteElTV)
addEventHandler("onClientElementDataChange", root, function(data,last,new)
    if(data == "vehicle" and source == el())then
        deleteElTV()
        updateElTV()
    end
end)