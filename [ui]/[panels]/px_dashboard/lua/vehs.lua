--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local t={}
for i=1,2 do
    local sY=(153/zoom)*(i-1)
    for i=1,4 do
        local sX=(360/zoom)*(i-1)
        t[#t+1]={sX=sX,sY=sY}
    end
end

local selected=1
local vehicleImages={}
local loaded=0

local wheels={
	[1025]="Offroad",
	[1073]="Shadow",
	[1074]="Mega",
	[1075]="Rimshine",
	[1076]="Wires",
	[1077]="Classic",
	[1078]="Twist",
	[1079]="Cutter",
	[1080]="Switch",
	[1081]="Grove",
	[1082]="Import",
	[1083]="Dolar",
	[1084]="Trance",
	[1085]="Atomic",
	[1096]="Ahab",
	[1097]="Virtual",
	[1098]="Access",
}

local mapPos={3000, 3000}

local tickPos=0

local pos={0,0,0}
local newPos=false

local short={
    ['Las Venturas']='LV',
    ['Los Santos']='LS',
    ['San Fierro']='SF',
    ['Red County']='RC',
    ['Bone County']='BC',
}

function getVehicleLocation(v)
    local new=false
    local street=false

    if(v.police_parking and #v.police_parking > 0)then
        street="Parking policyjny"
    elseif(v.parking ~= 0 and v.parking ~= "0")then
        street="Parking #"..v.parking
    elseif(v.h_garage and v.h_garage ~= 0 and v.h_garage ~= "0")then
        street="Garaż #"..v.h_garage
    end

    if(not street)then
		local vehElementID=getElementByID("px_vehicles_id:"..v.id)
		if(vehElementID and isElement(vehElementID))then
			local pos={getElementPosition(vehElementID)}
            local z2=getZoneName(pos[1],pos[2],pos[3],true)
            z2=short[z2] or z2

			street=getZoneName(pos[1],pos[2],pos[3],false)..", "..z2

            new=pos
		else
			street='Błąd z pojazdem'
            new=v.pos and (fromJSON(v.pos) or {0,0,0}) or {0,0,0}
		end
    else
        new=v.pos and (fromJSON(v.pos) or {0,0,0}) or {0,0,0}
    end

    return (new or "(?)"),(street or "(?)")
end

ui.rendering["Pojazdy"]=function(a, mainA)
    a=a > mainA and mainA or a

    local texs=assets.textures["Pojazdy"]
    if(not texs or (texs and #texs < 1))then return false end

    dxDrawText("Pojazdy", 426/zoom, 63/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText("W tym miejscu możesz dowiedzieć się wszystkiego o Twoich pojazdach.", 426/zoom, 93/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")

    local k=0
    local row=math.floor(scroll:dxScrollGetPosition(ui.scrolls["pojazdy_1"])+1)
    for i=row,row+7 do
        local v=ui.info.vehs[i]
        if(v)then
            local lastDriver=fromJSON(v.lastDrivers) or {}
            lastDriver=lastDriver[#lastDriver] or "brak"

            local new,street=getVehicleLocation(v)

            k=k+1

            local pos=t[k]
            if(pos)then
                dxDrawImage(426/zoom+pos.sX, 151/zoom+pos.sY, 344/zoom, 138/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))

                local path='vehicles/'..v.model..'.png'
                if(fileExists(path))then
                    dxDrawImage(426/zoom+pos.sX+10/zoom, 151/zoom+pos.sY+30/zoom, 100/zoom, 100/zoom, path, 0, 0, 0, tocolor(255, 255, 255, a))
                end

                dxDrawText(getVehicleNameFromModel(v.model), 426/zoom+pos.sX+24/zoom, 151/zoom+pos.sY+16/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[1], "left", "top")
                dxDrawText("#939393ID: #dedede"..v.id.."\n#939393Ostatni kierowca: #dedede"..lastDriver.."\n#939393Lokalizacja: #dedede"..street.."\n#939393Właściciel: #dedede"..v.ownerName, 426/zoom+pos.sX+123/zoom, 151/zoom+pos.sY+50/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "top", false, false, false, true)
                dxDrawRectangle(426/zoom+pos.sX, 151/zoom+pos.sY+138/zoom-4, 344/zoom, 4, selected == i and tocolor(85,205,186,a) or tocolor(80,80,80,a))

                onClick(426/zoom+pos.sX, 151/zoom+pos.sY, 344/zoom, 138/zoom, function()
                    selected=i
                    newPos=new or {0,0,0}
                    tickPos=getTickCount()
                end)
            end
        end
    end

    if(not ui.scrolls["pojazdy_1"])then
        ui.scrolls["pojazdy_1"]=scroll:dxCreateScroll(sw-35/zoom, 151/zoom, 4, 200/zoom, 0, 8, ui.info.vehs, 300/zoom, a, false, {381/zoom, 0, sw, sh})
    end

    dxDrawRectangle(427/zoom, sh-540/zoom, 1427/zoom, 1, tocolor(80,80,80,ui.mainAlpha > 50 and 50 or ui.mainAlpha))

    local v=ui.info.vehs[selected]
    if(selected and v)then
        if(not newPos and v.position)then
            local pos=fromJSON(v.position) or {}
            if(#pos > 0 and type(pos) == "table")then
                newPos=pos
            end
        end

        dxDrawText("Informacje o pojeździe", 427/zoom, sh-508/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")

        local path='vehicles/'..v.model..'.png'
        if(fileExists(path))then
            dxDrawImage(427/zoom, sh-560/zoom, 400/zoom, 400/zoom, path, 0, 0, 0, tocolor(255, 255, 255, a))
        end

        local mechanic=fromJSON(v.mechanicTuning) or {}
        local mk=""
        if(mechanic["MK1"])then
            mk=#mk > 0 and mk..", MK1" or "MK1"
        end
        if(mechanic["MK2"])then
            mk=#mk > 0 and mk..", MK2" or "MK2"
        end

        local default_engine=exports.px_custom_vehicles:getVehicleEngineFromModel(v.model)
        local engine=(v.engine and string.len(v.engine) > 0 and tonumber(v.engine) > 0) and string.format("%.1f", v.engine) or default_engine

        local lastDriver=fromJSON(v.lastDrivers) or {}
        lastDriver=lastDriver[#lastDriver] or "Brak"

        local info={
            ["left"]={
                {"Model pojazdu", getVehicleNameFromModel(v.model)},
                {"ID pojazdu", v.id},
                {"Właściciel", v.group and "Wypożyczalnia" or v.ownerName},
                {"Ostatni kierowca", lastDriver}
            },

            ["right"]={
                {"Stopień uszkodzenia", math.floor(100-(v.health-200)/8).."%"},
                {"Stan paliwa", math.floor((v.fuel/v.fuelTank)*100).."%"},
                {"Udostępniony", (v.keys and (#(fromJSON(v.keys) or {}) > 0) and "Tak" or "Nie")},
                {"Układy MK", #mk > 0 and mk or "Brak"},
                {"Turbosprężarka", mechanic.turbo or "Brak"},
                {"Zawieszenie", mechanic.suspension or "Brak"},
                {"Hamulce", mechanic.brakes or "Brak"},
                {"Pojemność", engine.."dm³"},
                {"Pierwszy właściciel", v.first_owner or "brak informacji"},
                {"W posiadaniu od", v.buy_date or "brak informacji"},
            }
        }

        for i,v in pairs(info["left"]) do
            local sY=(42/zoom)*(i-1)
            dxDrawImage(427/zoom, sh-219/zoom+sY, 408/zoom, 41/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, a))
            dxDrawText(v[1]..":", 427/zoom+19/zoom, sh-219/zoom+sY, 408/zoom, 41/zoom+sh-219/zoom+sY, tocolor(200, 200, 200, a), 1, assets.fonts[2], "left", "center")
            dxDrawText(v[2], 427/zoom, sh-219/zoom+sY, 427/zoom+408/zoom-19/zoom, 41/zoom+sh-219/zoom+sY, tocolor(150, 150, 150, a), 1, assets.fonts[2], "right", "center")
        end

        for i,v in pairs(info["right"]) do
            local sY=(42/zoom)*(i-1)
            dxDrawImage(427/zoom+469/zoom, sh-471/zoom+sY, 408/zoom, 41/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, a))
            dxDrawText(v[1]..":", 427/zoom+19/zoom+469/zoom, sh-471/zoom+sY, 408/zoom, 41/zoom+sh-471/zoom+sY, tocolor(200, 200, 200, a), 1, assets.fonts[2], "left", "center")
            dxDrawText(v[2], 427/zoom, sh-471/zoom+sY, 427/zoom+408/zoom-19/zoom+469/zoom, 41/zoom+sh-471/zoom+sY, tocolor(150, 150, 150, a), 1, assets.fonts[2], "right", "center")
        end

        if(newPos and newPos[1] == 0 and newPos[2] == 0 and newPos[3] == 0)then
            buttons:destroyButton(ui.buttons["pojazdy_1"])
            ui.buttons["pojazdy_1"]=nil
        else
            local x,y,z=pos[1],pos[2],pos[3]
            if(newPos)then
                x,y,z=interpolateBetween(pos[1],pos[2],pos[3],newPos[1],newPos[2],newPos[3],(getTickCount()-tickPos)/250,"InOutQuad")
            end

            pos={x,y,z}

            local map=exports.px_map:getMapTexture()
            if(map)then
                local w,h=mapPos[1],mapPos[2],mapPos[3],mapPos[4]
                local x,y=pos[1],pos[2]
                dxSetRenderTarget(ui.mapRT,true)

                    x,y=x+3000,y-3000
                    x,y=mapPos[1]*(x/6000),mapPos[2]*(y/-6000)
            
                    dxDrawImage(-x+494/2/zoom,-y+285/2/zoom,w,h, map)
                dxSetRenderTarget()
                dxDrawImage(sw-560/zoom, sh-469/zoom, 494/zoom, 285/zoom, texs[1], 0, 0, 0, tocolor(255,255,255,a > 75 and 75 or a))
                dxDrawImage(sw-560/zoom, sh-469/zoom, 494/zoom, 285/zoom, ui.mapRT, 0, 0, 0, tocolor(255,255,255,a))
            end
            dxDrawImage(sw-560/zoom+(494-64)/2/zoom, sh-469/zoom+(285-72)/2/zoom, 64/zoom, 72/zoom, texs[3], 0, 0, 0, tocolor(255,255,255,a))

            local zone=getZoneName(x,y,z,true)..", "..getZoneName(x,y,z,false)
            if(zone)then
                dxDrawText("Lokalizacja:\n"..zone, sw-560/zoom, sh-130/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[1], "left", "top")
            end

            if(not ui.buttons["pojazdy_1"])then
                ui.buttons["pojazdy_1"]=buttons:createButton(sw-212/zoom, sh-91/zoom, 147/zoom, 38/zoom, "NAMIERZ", a, 9, false, false, ":px_dashboard/textures/2/button.png")
            else
                onClick(sw-212/zoom, sh-91/zoom, 147/zoom, 38/zoom, function()
                    if(v.parking == 0 and v.h_garage == 0 and v.water == 0)then
                        exports.px_map:setGPSPos(newPos[1],newPos[2],newPos[3])
                    end
                end)
            end
        end
    end
end