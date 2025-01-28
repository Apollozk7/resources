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
        exports.px_noti:noti("Zaczekaj chwilkę.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 200, 1)

    return block
end

local noti=exports.px_noti

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

ui.vehicles={
    {1617.4890,1007.4409,10.9976,181.3717},
    {1596.0416,1008.0734,10.9973,179.9584},
}

ui.cases={
    [1]={
        {1593.6802,1050.6534,10.8203},
        {1600.2932,1050.8851,10.8203},
        {1599.9227,1024.6987,10.8203},
        {1593.5985,1024.6906,10.8203},
        {1612.9469,1024.6050,10.8203},
        {1619.4185,1024.8159,10.8203},
    }, -- zielone
    [2]={
        {1599.9751,1029.3495,10.8203},
        {1593.4348,1029.2145,10.8203},
        {1593.3596,1032.0553,10.8273},
        {1600.0015,1032.1729,10.8273},
        {1613.2643,1050.6025,10.8203},
        {1619.8799,1050.6595,10.8203},
    }, -- czerwone
    [3]={
        {1596.8257,1056.6780,10.8203},
        {1603.2987,1056.5923,10.8203},
        {1609.7814,1056.4614,10.8203},
        {1616.4714,1056.7235,10.8203},
        {1613.2040,1032.1357,10.8273},
        {1619.7993,1032.2880,10.8273},
        {1620.1389,1029.3046,10.8203},
        {1613.4447,1029.1012,10.8203},
    }, -- rozowe
    [4]={
        {1613.1223,1039.4243,10.8273},
        {1619.7600,1039.5082,10.8273},
        {1620.0927,1036.2126,10.8203},
        {1613.2397,1036.0154,10.8203},
    }, -- zolte
    [5]={
        {1599.9683,1036.0168,10.8203},
        {1593.7032,1036.0159,10.8203},
        {1593.4622,1039.5140,10.8203},
        {1600.0752,1039.5145,10.8203},
    }, -- niebieskie
    [6]={
        {1600.2662,1043.1234,10.8203},
        {1593.5560,1043.1191,10.8203},
        {1593.4032,1046.5986,10.8203},
        {1599.7544,1046.5989,10.8203},
        {1613.0033,1046.5979,10.8203},
        {1613.2731,1043.1212,10.8203},
        {1619.5739,1046.5972,10.8203},
        {1619.9570,1043.1234,10.8203},
    }, -- fioletowe
}

ui.pallet=false
ui.veh=false

ui.markers={}
ui.blips={}
ui.boxes={}
ui.action=""
ui.myCases=0
ui.boxID=3006
ui.upgradeVeh=false
ui.havePallet=false
ui.tickPallet=getTickCount()
ui.tick=getTickCount()
ui.markerBlock=false

ui.getPallet=function()
    if(isPedInVehicle(localPlayer))then return end

    ui.havePallet=getElementData(localPlayer, "px_warehouse:havePallet")
    if((getTickCount()-ui.tickPallet) > 500)then
        if(not ui.havePallet)then
            if(ui.action ~= "Odłóż paczke na paleciaka" and ui.action ~= "Odłóż paczke na regał")then
                if(SPAM.getSpam())then return end

                triggerLatentServerEvent("get.pallet", resourceRoot, localPlayer, true)
                ui.tickPallet=getTickCount()
                ui.markerBlock=true
            end
        else
            local hisPos={getElementPosition(ui.pallet)}
            local cancelDistance=false
            for i,v in pairs(ui.markers) do
                if(i ~= "giveBox")then
                    local myPos={getElementPosition(v)}
                    local dist=getDistanceBetweenPoints3D(myPos[1],myPos[2],myPos[3],hisPos[1],hisPos[2],hisPos[3])
                    if(dist < 2)then
                        cancelDistance=true
                        break
                    end
                end
            end

            if(not cancelDistance)then
                if(SPAM.getSpam())then return end

                triggerLatentServerEvent("get.pallet", resourceRoot, localPlayer)
                ui.tickPallet=getTickCount()
                ui.markerBlock=true
            else
                noti:noti("Wózek nie może stać tak blisko punktu!", "error")
            end
        end
    end
end

ui.createVehicle=function()
    checkAndDestroy(ui.veh)

    local rnd=math.random(1,#ui.vehicles)
    local v=ui.vehicles[rnd]

    ui.veh=createVehicle(456,v[1],v[2],v[3],0,0,v[4])
    setVehicleDoorOpenRatio(ui.veh, 1, 1)
    setVehicleColor(ui.veh,math.random(0,255),math.random(0,255),math.random(0,255))
    setElementFrozen(ui.veh,true)
    setElementCollisionsEnabled(ui.veh,false)

    ui.markers.getBox=createMarker(0,0,0,"cylinder",1.5,0,200,100)
    attachElements(ui.markers.getBox,ui.veh,0,-6,-0.6)
    setElementData(ui.markers.getBox, "out:icon", true)

    local add=(v[4] > 80 and v[4] < 100) and 6 or (-6)
    ui.blips.getBox=createBlip(v[1]+add,v[2],v[3],22)

    local sZ=ui.boxID == 3006 and 0.44 or 0.51
    ui.boxes={
        createObject(ui.boxID,0,0,0),
        createObject(ui.boxID,0,0,0),
        createObject(ui.boxID,0,0,0),
        createObject(ui.boxID,0,0,0),
    }
    attachElements(ui.boxes[1],ui.markers.getBox,0,0,-sZ+0.1)
    attachElements(ui.boxes[2],ui.markers.getBox,0,0,0+0.1)
    attachElements(ui.boxes[3],ui.markers.getBox,0,0,sZ+0.1)
    attachElements(ui.boxes[4],ui.markers.getBox,0,0,sZ*2+0.1)

    for i,v in pairs(ui.boxes) do
        setElementData(v, "box_shader", ui.myCases)
        setElementCollisionsEnabled(v,false)
    end

    if(ui.upgradeVeh)then
        ui.action="Załaduj paczkę"
    else
        ui.action="Idź po paczki"
    end
end

local park={}
ui.getRandom=function(max)
    local x=math.random(1,max)
    while(park[x])do
        x=math.random(1,max)
    end
    return x
end

ui.getRandomCase=function()
    local t=ui.cases[ui.myCases]
    
    park={}

    if(t)then
        for i=1,4 do
            local rnd=ui.getRandom(#t)
            if(rnd and t[rnd])then
                local pos=t[rnd]

                if(not ui.markers["case_"..i])then
                    ui.markers["case_"..i]=createMarker(pos[1],pos[2],pos[3],"cylinder",1,255,0,255)
                    ui.blips["case_"..i]=createBlip(pos[1],pos[2],pos[3],22)
                    setElementData(ui.markers["case_"..i], "icon", ":px_jobs-warehouse/textures/boxMarker.png")
                end

                park[rnd]=true
            end
        end
    end
end

ui.onRender=function()
    if(ui.pallet and isElement(ui.pallet) and getElementType(ui.pallet) == "object")then
        ui.havePallet=getElementData(localPlayer, "px_warehouse:havePallet")
        if(not ui.havePallet)then
            local size=0.3
            local x,y,z=getElementPosition(ui.pallet)
            z=z+1
            z=interpolateBetween(z-0.1, 0, 0, z+0.1, 0, 0, (getTickCount()-ui.tick)/1500, "SineCurve")
            dxDrawMaterialLine3D(x,y,z+size,x,y,z,ui.button,size,tocolor(255,255,255))
        end
    end
end

ui.onMarkerHit=function(hit, dim)
    if(hit ~= localPlayer or not dim)then return end

    if(SPAM.getSpam())then return end

    ui.havePallet=getElementData(hit, "px_warehouse:havePallet")
    if(ui.havePallet or ui.markerBlock)then return end

    if(ui.upgradeVeh and isPedInVehicle(hit) and getPedOccupiedVehicle(localPlayer) == ui.pallet)then
        if(source == ui.markers.getBox and ui.action == "Załaduj paczkę")then
            local data=getElementData(localPlayer, "user:jobs_todo") or {}
            data[1].done=true
            setElementData(localPlayer, "user:jobs_todo", data, false)

            triggerLatentServerEvent("get.box", resourceRoot, getElementModel(ui.boxes[1]), ui.myCases, true)
            ui.action="Odwieź paczkę na regał"

            local max=#ui.boxes
            destroyElement(ui.boxes[max])
            ui.boxes[max]=nil

            if(not ui.markers.giveBox)then
                local t=ui.cases[ui.myCases]
                if(t)then
                    local rnd=math.random(1,#t)
                    if(rnd and t[rnd])then
                        local pos=t[rnd]
                        ui.markers["case_1"]=createMarker(pos[1],pos[2],pos[3],"cylinder",1.5,255,0,255)
                        ui.blips["case_1"]=createBlip(pos[1],pos[2],pos[3],22)
                        setElementData(ui.markers["case_1"], "icon", ":px_jobs-warehouse/textures/boxMarker.png")
                    end
                end
            end

            checkAndDestroy(ui.markers.getBox)
            ui.markers.getBox=nil

            checkAndDestroy(ui.blips.getBox)
            ui.blips.getBox=nil
        elseif(ui.action == "Odwieź paczkę na regał" and source == ui.markers["case_1"])then
            local data={
                {name="Udaj się załadować paczkę"},
                {name="Zawieź paczkę na regał"},
            }
            setElementData(localPlayer, "user:jobs_todo", data, false)

            checkAndDestroy(ui.markers["case_1"])
            checkAndDestroy(ui.blips["case_1"])
            ui.markers["case_1"]=nil
            ui.blips["case_1"]=nil

            if(#ui.boxes > 0)then
                local v={getElementPosition(ui.veh)}
                ui.markers.getBox=createMarker(0,0,0,"cylinder",1.5,0,200,100)
                attachElements(ui.markers.getBox,ui.veh,0,-6,-0.5)
                ui.blips.getBox=createBlip(v[1],v[2],v[3],22)
                setElementData(ui.markers.getBox, "icon", ":px_jobs-warehouse/textures/boxMarker.png")
    
                ui.action="Załaduj paczkę"
            else
                triggerLatentServerEvent("reverse.job", resourceRoot, localPlayer)
            end

            triggerLatentServerEvent("case.box", resourceRoot, true)
        end
    else
        if(isPedInVehicle(hit))then return end

        if(source == ui.markers.getBox and ui.pallet and isElement(ui.pallet) and ui.action == "Idź po paczki")then
            local pPos={getElementPosition(ui.pallet)}
            local mPos={getElementPosition(source)}
            local dist=getDistanceBetweenPoints3D(pPos[1], pPos[2], pPos[3], mPos[1], mPos[2], mPos[3])
            if(dist > 1)then
                triggerLatentServerEvent("get.box", resourceRoot, getElementModel(ui.boxes[1]), ui.myCases)

                ui.action="Odłóż paczke na paleciaka"
        
                setTimer(function()
                    local max=#ui.boxes
                    if(max ~= 1)then
                        if(isElement(ui.boxes[max]))then
                            destroyElement(ui.boxes[max])
                        end
                        
                        ui.boxes[max]=nil
        
                        if(not ui.markers.giveBox)then
                            ui.markers.giveBox=createMarker(0,0,0,"cylinder",1,0,100,200)
                            attachElements(ui.markers.giveBox, ui.pallet, 0, -0.5, 1)
                            setElementData(ui.markers.giveBox, "icon", ":px_jobs-warehouse/textures/boxMarker.png")
                        end
                    else
                        checkAndDestroy(ui.boxes[1])
                        ui.boxes={}
        
                        checkAndDestroy(ui.markers.getBox)
                        ui.markers.getBox=nil
        
                        checkAndDestroy(ui.blips.getBox)
                        ui.blips.getBox=nil
                    end
                end, 1000, 1)
            else
                noti:noti("Paleciak stoi zbyt blisko paczek.", "error")
            end
        elseif(source == ui.markers.giveBox)then
            if(ui.action == "Weź paczke z paleciaka")then
                local br=false
                for i=1,4 do
                    local m=ui.markers["case_"..i]
                    if(m and isElement(m))then
                        local pPos={getElementPosition(ui.pallet)}
                        local mPos={getElementPosition(m)}
                        local dist=getDistanceBetweenPoints3D(pPos[1], pPos[2], pPos[3], mPos[1], mPos[2], mPos[3])
                        if(dist < 1)then
                            br=true
                            break
                        end
                    end
                end

                if(not br)then
                    triggerLatentServerEvent("set.box", resourceRoot, i)
                    ui.action="Odłóż paczke na regał"
                    ui.tickPallet=getTickCount()
                else
                    noti:noti("Paleciak stoi zbyt blisko regałów.", "error")
                end
            elseif(ui.action == "Odłóż paczke na paleciaka")then
                triggerLatentServerEvent("attach.box", resourceRoot, ui.boxID)
    
                if(not ui.boxes[1])then
                    ui.getRandomCase()
    
                    ui.action="Weź paczke z paleciaka"
    
                    checkAndDestroy(ui.veh)
                    ui.veh=false

                    local data=getElementData(localPlayer, "user:jobs_todo") or {}
                    data[2].done=true
                    setElementData(localPlayer, "user:jobs_todo", data, false)
                else
                    ui.action="Idź po paczki"
                end
            end
        elseif(ui.action == "Odłóż paczke na regał")then
            for i=1,4 do
                if(source == ui.markers["case_"..i])then
                    triggerLatentServerEvent("case.box", resourceRoot)
                    ui.action="Weź paczke z paleciaka"
    
                    checkAndDestroy(ui.markers["case_"..i])
                    checkAndDestroy(ui.blips["case_"..i])
                    ui.markers["case_"..i]=nil
                    ui.blips["case_"..i]=nil
                end
            end
        end
    end
end

addEvent("start.job", true)
addEventHandler("start.job", resourceRoot, function(pallet, info, reverse)
    local data=getElementData(localPlayer, "user:jobs_todo") or {} or {}

    info=info and info or ui.info
    if(info)then
        ui.info=info

        if(info.upgrades["Siłacz"])then
            ui.boxID=3005
        else
            ui.boxID=3006
        end

        if(not info.upgrades["Szybcior"])then
            toggleControl("sprint", false)
        end

        ui.upgradeVeh=info.upgrades["Wózek widłowy"]

        if(ui.upgradeVeh)then
            local data={
                {name="Udaj się załadować paczkę"},
                {name="Zawieź paczkę na regał"},
            }
            setElementData(localPlayer, "user:jobs_todo", data, false)
        else
            if(not reverse)then
                local data={
                    {name="Udaj się po paleciaka"},
                    {name="Załaduj paczki na paleciaka"},
                    {name="Rozwieź paczki po półkach"},
                }
                setElementData(localPlayer, "user:jobs_todo", data, false)
            else
                for i,v in pairs(data) do
                    v.done=false
                end
                setElementData(localPlayer, "user:jobs_todo", data, false)
            end
        end
    end

    local max=table.size(ui.cases)
    local rnd=math.random(1,max)
    ui.myCases=rnd

    ui.pallet=pallet
    ui.createVehicle()

    addEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    addEventHandler("onClientRender", root, ui.onRender)
    addEventHandler("onClientVehicleStartEnter", root, ui.onVehicleEnter)

    if(not ui.upgradeVeh)then
        toggleControl("crouch", false)
        toggleControl("jump", false)
    end

    if(getElementType(ui.pallet) == "object")then
        bindKey("Q", "down", ui.getPallet)
    end

    ui.button=dxCreateTexture("textures/buttonQ.png", "argb", false, "clamp")
end)

addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, function(reverse)
    if(not reverse)then
        setElementData(localPlayer, "user:jobs_todo", false, false)
    end

    checkAndDestroy(ui.veh)
    
    for i,v in pairs(ui.markers) do
        checkAndDestroy(v)
    end
    ui.markers={}

    for i,v in pairs(ui.blips) do
        checkAndDestroy(v)
    end
    ui.blips={}

    for i,v in pairs(ui.boxes) do
        checkAndDestroy(v)
    end
    ui.boxes={}

    removeEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientVehicleStartEnter", root, ui.onVehicleEnter)

    checkAndDestroy(ui.button)

    toggleControl("crouch", true)
    toggleControl("jump", true)
    toggleControl("sprint", true)
    toggleControl("walk", true)

    unbindKey("Q", "down", ui.getPallet)
end)

addEvent("triggerClient", true)
addEventHandler("triggerClient", resourceRoot, function()
    ui.markerBlock=false

    local data=getElementData(localPlayer, "user:jobs_todo") or {}
    data[1].done=true
    setElementData(localPlayer, "user:jobs_todo", data, false)
end)

table.size=function(t)
    local x=0; for i,v in pairs(t) do x=x+1; end; return x;
end

local boxes={}
local tex_name={"smallbox","bigbox"}

function createBoxes()
    for i=1,6 do
        local shader=dxCreateShader(ui.shader)
        local tex=dxCreateTexture("textures/"..i..".png")
        dxSetShaderValue(shader, "gTexture", tex)
        boxes[i]={shader,tex}
    end
end

function setBoxTexture(nr, box)
    if(not boxes[nr])then
        createBoxes()
    end

    if(boxes[nr][1])then
        for i,v in pairs(tex_name) do
            engineApplyShaderToWorldTexture(boxes[nr][1], v, box)
        end
    end
end
addEventHandler("onClientElementStreamIn", resourceRoot, function()
    if(getElementData(source,"box_shader") and source and isElement(source))then
        setBoxTexture(getElementData(source,"box_shader"),source)
    end
end)

function deleteBoxes()
    for i,v in pairs(boxes) do
        checkAndDestroy(v)
    end
    boxes={}
end

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end

addEventHandler("onClientColShapeHit", resourceRoot, function(hit, dim)
    if(hit ~= localPlayer or not dim)then return end

    createBoxes()
end)

addEventHandler("onClientColShapeLeave", resourceRoot, function(hit, dim)
    if(hit ~= localPlayer or not dim)then return end

    deleteBoxes()
end)

ui.onVehicleEnter=function()
    cancelEvent()
end