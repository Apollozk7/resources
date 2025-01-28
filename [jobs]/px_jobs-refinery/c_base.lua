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
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

local noti=exports.px_noti
local line3d=exports.px_3dline
local blur=exports.blur

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- assets

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 8},
    },

    textures={},
    textures_paths={
        "textures/bg.png",
        "textures/bar.png",
        "textures/progress.png",

        "textures/rura-lewo.png",
        "textures/circle.png",
        "textures/nalewak.png",
        "textures/dzwignia.png",
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

--

ui={}

ui.markers={}
ui.blips={}
ui.zones={}

ui.level=0
ui.oneLevel=0
ui.saveLevel=0

ui.tanks={}

ui.miniPos={sw-500/zoom,math.random(0,sh-99/zoom)}
ui.miniClick=false
ui.catchPos=false
ui.rots={0,0}
ui.updateRot={false,false,false,false}

ui.tankTime=0
ui.removeFuel=0
ui.vehicle=false
ui.points=0
ui.savePoints=0

ui.pos={238.5286,1407.9031,10.5859}

ui.zbiornik=1
ui.zbiorniki={
    {{265.7193,1444.1080,10.5859},{264.2,1444.205,10.71},{266.1811,1444.2729,10.5859}},
    {{145.6344,1415.2604,10.5859},{145.6344,1415.2604,10.5859},{147.4115,1415.3530,10.5859}},
    {{144.9282,1399.9342,10.5859},{144.9282,1399.9342,10.5859},{146.5775,1399.9767,10.5859}},
}

ui.miniLetters={
    [1]="¹",
    [2]="²",
    [3]="³",
    [4]="⁴",
    [5]="⁵",
    [6]="⁶",
    [7]="⁷",
    [8]="⁸",
    [9]="⁹",
    [10]="¹⁰"
}

ui.createRandomTankPoint=function(points)
    local randoms={}

    local i=0
    while(i < points)do
        local rnd=#ui.tanks > 1 and math.random(1,#ui.tanks) or 1
        if(not randoms[rnd] and ui.tanks[rnd])then
            local k=table.size(ui.markers)
            local v=ui.tanks[rnd]
            
            ui.zones["dystrybutor_"..k+1]=createColSphere(v[1],v[2],v[3],10)
            ui.markers["dystrybutor_"..k+1]=createMarker(v[1],v[2],v[3]-1, "cylinder", 1.5, 0, 255, 0)
            ui.blips["dystrybutor_"..k+1]=createBlipAttachedTo(ui.markers["dystrybutor_"..k+1], 22)
            setElementData(ui.markers["dystrybutor_"..k+1], "pos:z", v[3]-1, false)
            setElementData(ui.markers["dystrybutor_"..k+1], "icon", ":px_jobs-refinery/textures/marker-fuel.png", false)

            randoms[rnd]=true

            i=i+1
        end
    end

    randoms=nil
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

ui.onRender=function()
    if(ui.vehicle and isElement(ui.vehicle))then
        if(getPedOccupiedVehicle(localPlayer) ~= ui.vehicle)then
            local myPos={getElementPosition(localPlayer)}
            local vPos={getElementPosition(ui.vehicle)}
            local dist=getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], vPos[1], vPos[2], vPos[3])
            local data=getElementData(localPlayer, "user:jobBackTime")
            if(dist > 50)then
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
        else
            if(getElementData(localPlayer, "user:jobBackTime"))then
                setElementData(localPlayer, "user:jobBackTime", false, false)

                if(ui.timerElement and isTimer(ui.timerElement))then
                    killTimer(ui.timerElement)
                end
                ui.timerElement=false
            end
        end
    else
        triggerLatentServerEvent("stop.job", resourceRoot, localPlayer)
    end

    if(not isPedInVehicle(localPlayer))then
        dxDrawImage(380/zoom, sh-310/zoom, 329/zoom, 247/zoom, assets.textures[1])

        local info={
            {name="Ilość paliwa w cysternie", value=(ui.level/ui.saveLevel)*100},
            {name="Ilość paliwa do zatankowania", value=((ui.level > 0 and 0 or ui.saveLevel)/ui.saveLevel)*100},
            {name="Czas trwania tankowania", value=100-((getTickCount()-ui.tankTime)/10000)*100},
        }
        for i,v in pairs(info) do
            if(v.value > 100)then
                v.value=100
            end
            if(v.value < 0)then
                v.value=0
            end

            local sY=(50/zoom)*(i-1)
            dxDrawText(v.name, 380/zoom+60/zoom, sh-310/zoom+50/zoom+sY, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
            dxDrawImage(380/zoom+60/zoom, sh-310/zoom+50/zoom+sY+15/zoom, 209/zoom, 19/zoom, assets.textures[2])
            dxDrawImageSection(380/zoom+60/zoom+(209-205)/2/zoom, sh-310/zoom+50/zoom+sY+15/zoom+(19-15)/2/zoom, (205/zoom)*(v.value/100), 15/zoom, 0, 0, (205/zoom)*(v.value/100), 15/zoom, assets.textures[3])
        end
    end
end

ui.renderMinigame=function()
    if(ui.updateRot[1])then
        ui.rots[1]=ui.rots[1]+1
        if(ui.rots[1] >= 180)then
            ui.updateRot[1]=false
            ui.updateRot[3]=true 
        end
    end
    if(ui.updateRot[2])then
        ui.rots[2]=ui.rots[2]+1
        if(ui.rots[2] >= 90)then
            ui.updateRot[2]=false
            ui.updateRot[4]=true 
        end
    end

    blur:dxDrawBlur(0,0,sw,sh)

    dxDrawImage(ui.miniPos[1], ui.miniPos[2], 1304/zoom, 99/zoom, assets.textures[6])
    dxDrawImage(ui.miniPos[1]-105/zoom, ui.miniPos[2]-250/zoom, 600/zoom, 600/zoom, assets.textures[7], ui.rots[2])
    onClick(ui.miniPos[1]+170/zoom, ui.miniPos[2]+(99-50)/2/zoom, 50/zoom, 50/zoom, function()
        if(not ui.updateRot[2] and not ui.updateRot[4])then
            ui.updateRot[2]=true
        end
    end)

    dxDrawImage(0, sh/2-340/2/zoom, 875/zoom, 340/zoom, assets.textures[4])
    dxDrawImage(650/zoom, sh/2-340/2/zoom-40/zoom, 159/zoom, 159/zoom, assets.textures[5], ui.rots[1])
    if(ui.updateRot[3])then
        dxDrawRectangle(875/zoom-1, sh/2-340/2/zoom+5/zoom, 10/zoom, sh, tocolor(15, 15, 0))
        ui.removeFuel=ui.removeFuel-0.1
    end
    onClick(650/zoom, sh/2-340/2/zoom-40/zoom, 159/zoom, 159/zoom, function()
        if(not ui.updateRot[1] and not ui.updateRot[3])then
            ui.updateRot[1]=true
            setTimer(function()
                ui.updateRot[1]=false
                ui.updateRot[3]=true
            end, 2000, 1)
        end
    end)

    if(ui.miniClick)then
        if(not getKeyState("mouse1"))then
            ui.miniClick=false
        else
            local cx,cy=getCursorPosition()
            cx,cy=cx*sw,cy*sh
            
            if(not ui.catchPos)then
                local cx,cy=cx-ui.miniPos[1],cy-ui.miniPos[2]
                ui.catchPos={cx,cy}
            else
                ui.miniPos={cx-ui.catchPos[1],cy-ui.catchPos[2]}
            end
        end
    end

    if(isMouseInPosition(ui.miniPos[1], ui.miniPos[2], 1304/zoom, 99/zoom) and not ui.miniClick and getKeyState("mouse1"))then
        ui.catchPos=false
        ui.miniClick=true
    end

    if(getPosition(ui.miniPos[1], ui.miniPos[2], 800/zoom, sh/2-340/2/zoom-10/zoom, 50/zoom, 120/zoom) and not ui.gameError)then
        if(ui.updateRot[3])then
            if(ui.updateRot[4])then
                noti:noti("Teraz zaczekaj aż pojazd napełni się ropą.", "success")

                local x,y,z=getElementPosition(localPlayer)
                playSound3D("sounds/ropa.mp3", x,y,z)

                removeEventHandler("onClientRender", root, ui.renderMinigame)
                showCursor(false)

                local data=getElementData(localPlayer, "user:jobs_todo") or {}
                data[2].done=true
                setElementData(localPlayer, "user:jobs_todo", data, false)

                ui.tankTime=getTickCount()

                -- testowe napelnianie to do
                setTimer(function()
                    noti:noti("Cysterna została napełniona, udaj się rozwieść ropę po dystrybutorach.", "info")

                    triggerLatentServerEvent("get.tank", resourceRoot)

                    checkAndDestroy(ui.markers.zbiornik)
                    checkAndDestroy(ui.blips.zbiornik)
                    checkAndDestroy(ui.zones.zbiornik)
                    ui.zones={}
                    ui.blips={}
                    ui.markers={}

                    ui.createRandomTankPoint(ui.points)

                    setElementFrozen(localPlayer, false)

                    local data=getElementData(localPlayer, "user:jobs_todo") or {}
                    data[3].done=true
                    setElementData(localPlayer, "user:jobs_todo", data, false)

                    ui.level=ui.saveLevel
                    ui.level=ui.level-ui.removeFuel
                end, 10000, 1)
            else
                noti:noti("Najpierw otwórz odpływ.", "error")
                ui.gameError=true
            end
        else
            noti:noti("Najpierw odkręć rure z silosu.", "error")
            ui.gameError=true
        end
    elseif(not getPosition(ui.miniPos[1], ui.miniPos[2], 800/zoom, sh/2-340/2/zoom-10/zoom, 50/zoom, 120/zoom) and ui.gameError)then
        ui.gameError=false
    end
end

ui.onMarkerHit=function(hit, dim)
    if(hit ~= localPlayer or not dim or isPedInVehicle(hit))then return end

    if(SPAM.getSpam())then return end

    local pos={getElementPosition(source)}

    if(source == ui.markers.zbiornik)then
        if(line3d:isPlayerHaveLine(hit))then
            local v=ui.zbiorniki[ui.zbiornik]
            line3d:addLinePosition(hit, i == 1 and v[1] or v[2])
            line3d:setLineLastPosition(hit, i == 1 and v[1] or v[2])

            setElementFrozen(hit, true)

            ui.removeFuel=0
            ui.miniPos={sw-500/zoom,math.random(0,sh-99/zoom)}
            ui.miniClick=false
            ui.catchPos=false
            ui.rots={0,0}
            ui.updateRot={false,false,false,false}

            assets.create()
            addEventHandler("onClientRender", root, ui.renderMinigame)
            showCursor(true)
        else
            noti:noti("Najpierw podciągnij wąż z cysterny.", "error")
        end
    else
        for i,v in pairs(ui.markers) do
            if(source == v and string.find(i, "dystrybutor"))then
                if(line3d:isPlayerHaveLine(hit))then
                    ui.tankTime=getTickCount()

                    line3d:setLineLastPosition(hit, {getElementPosition(source)})

                    noti:noti("Trwa napełnianie dystrybutora...", "success")
        
                    setElementFrozen(hit, true)

                    local x,y,z=getElementPosition(localPlayer)
                    playSound3D("sounds/ropa.mp3", x,y,z)

                    setTimer(function(source)
                        local data=getElementData(localPlayer, "user:jobs_todo") or {}
                        if(ui.points == 1)then
                            data[5].done=true
                            data[6].done=true
                            setElementData(localPlayer, "user:jobs_todo", data, false)

                            ui.zones["baza"]=createColSphere(284.3812,1412.2537,10.4047,20)
                            ui.blips["baza"]=createBlipAttachedTo(ui.zones["baza"], 22)
                        else
                            noti:noti("Dystrybutor został napełniony, udaj się napełnić kolejny dystrybutor.", "info")

                            local text=ui.miniLetters[ui.points]
                            text=ui.points == 2 and "" or text
                            data={
                                {name="Udaj się pod zbiornik z ropą", done=true},
                                {name="Podepnij wąż do zbiornika", done=true},
                                {name="Napełnij zbiornik ropą", done=true},
                                {name="Udaj się pod wskazany dystrybutor "..text},
                                {name="Podepnij wąż do dystrybutora "..text},
                                {name="Zapełnij dystrybutor ropą "..text},
                                {name="Wróć na bazę rafinerii"},
                            }
                            setElementData(localPlayer, "user:jobs_todo", data, false)
                        end

                        local dist=getDistanceBetweenPoints3D(pos[1],pos[2],pos[3],ui.pos[1],ui.pos[2],ui.pos[3])
                        local add=math.floor(dist/1000)
                        data.giveMoney=(data.giveMoney or 0)+add
                        setElementData(localPlayer, "user:jobs_todo", data, false)
                        
                        setElementFrozen(hit, false)

                        checkAndDestroy(ui.markers[i])
                        checkAndDestroy(ui.zones[i])
                        checkAndDestroy(ui.blips[i])
                        ui.markers[i]=nil
                        ui.zones[i]=nil
                        ui.blips[i]=nil

                        triggerLatentServerEvent("get.tank", resourceRoot)

                        ui.level=ui.level-ui.oneLevel
                        ui.points=ui.points-1
                    end, 10000, 1)
                else
                    noti:noti("Najpierw podciągnij wąż z cysterny.", "error")
                end
            end
        end
    end
end

ui.onColShapeHit=function(hit, dim)
    if(hit ~= localPlayer or not dim)then return end

    if(SPAM.getSpam())then return end

    if(source == ui.zones.zbiornik)then
        local data=getElementData(localPlayer, "user:jobs_todo")
        data[1].done=true
        setElementData(localPlayer, "user:jobs_todo", data, false)
    elseif(source == ui.zones.baza)then
        triggerLatentServerEvent("reverse.job", resourceRoot, localPlayer)

        checkAndDestroy(ui.zones["baza"])
        checkAndDestroy(ui.blips["baza"])
    else
        for i,v in pairs(ui.zones) do
            if(source == v and string.find(i, "dystrybutor"))then
                local data=getElementData(localPlayer, "user:jobs_todo")
                data[4].done=true
                setElementData(localPlayer, "user:jobs_todo", data, false)
            end
        end
    end
end

addEvent("start.job", true)
addEventHandler("start.job", resourceRoot, function(info, level, stations, veh, points)
    if(veh)then
        ui.vehicle=veh
    end

    ui.tanks=stations
    ui.level=0

    if(points)then
        ui.savePoints=points
    end
    ui.points=ui.savePoints

    if(level)then
        ui.saveLevel=level
        ui.oneLevel=math.floor(level/ui.points)
    end

    ui.zbiornik=math.random(1,#ui.zbiorniki)

    local pos=ui.zbiorniki[ui.zbiornik]
    ui.zones.zbiornik=createColSphere(pos[3][1],pos[3][2],pos[3][3],10)
    ui.markers.zbiornik=createMarker(pos[3][1],pos[3][2],pos[3][3], "cylinder", 1.5, 0, 255, 0)
    ui.blips.zbiornik=createBlipAttachedTo(ui.markers.zbiornik, 22)
    setElementData(ui.markers.zbiornik, "icon", ":px_jobs-refinery/textures/marker-silos.png")

    addEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    addEventHandler("onClientColShapeHit", resourceRoot, ui.onColShapeHit)
    addEventHandler("onClientRender", root, ui.onRender)
    addEventHandler("onClientPlayerWasted", localPlayer, wasted)

    assets.create()

    local text=ui.miniLetters[ui.points]
    local data=getElementData(localPlayer, "user:jobs_todo") or {}
    data={
        {name="Udaj się pod zbiornik z ropą"},
        {name="Podepnij wąż do zbiornika"},
        {name="Napełnij zbiornik ropą"},
        {name="Udaj się pod wskazany dystrybutor "..text},
        {name="Podepnij wąż do dystrybutora "..text},
        {name="Zapełnij dystrybutor ropą "..text},
        {name="Wróć na bazę rafinerii"},
    }
    setElementData(localPlayer, "user:jobs_todo", data, false)
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
    
    removeEventHandler("onClientMarkerHit", resourceRoot, ui.onMarkerHit)
    removeEventHandler("onClientColShapeHit", resourceRoot, ui.onColShapeHit)
    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientPlayerWasted", localPlayer, wasted)

    assets.destroy()

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
end
addEvent("stop.job", true)
addEventHandler("stop.job", resourceRoot, stopJob)

-- useful

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
        element=nil
    end
end

function table.size(tbl)
    local k=0
    for i,v in pairs(tbl) do
        k=k+1
    end
    return k
end

-- mouse

function isMouseInPosition(x, y, w, h)
	if(not isCursorShowing())then return end

	local cx,cy=getCursorPosition()
	cx,cy=cx*sw,cy*sh
	
    if(isCursorShowing() and (cx >= x and cx <= (x + w)) and (cy >= y and cy <= (y + h)))then
        return true
    end
    return false
end

function getPosition(myX, myY, x, y, w, h)
    if(isCursorShowing() and (myX >= x and myX <= (x + w)) and (myY >= y and myY <= (y + h)))then
        return true
    end
    return false
end

local mouseState=false
local mouseTick=getTickCount()
local mouseClicks=0
local mouseClick=false
function onClick(x, y, w, h, fnc)
	if(not isCursorShowing() or ui.animate)then return end

	if((getTickCount()-mouseTick) > 1000 and mouseClicks > 0)then
		mouseClicks=mouseClicks-1
	end

	if(not mouseState and getKeyState("mouse1"))then
		local cursor={getCursorPosition()}
        mouseState=cursor
    elseif(not getKeyState("mouse1") and (mouseClick or mouseState))then
        mouseClick=false
        mouseState=false
    end

    if(mouseState and mouseClicks < 10 and not mouseClick)then
		local cx,cy=unpack(mouseState)
        cx,cy=cx*sw,cy*sh

        if(getPosition(cx, cy, x, y, w, h))then
			fnc()

			mouseClicks=mouseClicks+1
            mouseTick=getTickCount()
            mouseClick=true
        end
	end
end

if(getElementData(localPlayer,"user:job") == "Rafineria")then
    setElementFrozen(localPlayer,false)
end

function getElementSpeed(theElement, unit)
    local vx,vy,vz=getElementVelocity(theElement)
    local speed=math.sqrt(vx^2 + vy^2 + vz^2) * 180
    return speed
end