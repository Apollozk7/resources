--[[
    @author: CrosRoad95, psychol.
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

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 200, 1)

    return block
end

local lastTick=3000

local sx,sy=guiGetScreenSize()
local zoom=1920/sx

local bgsx,bgsy = 148/zoom,478/zoom

local texs={}
local fonts={}

local optionsList = {
    engine = {
        icon = "engine",
        text = "Silnik",
        enabled = function(vehicle)
            return getElementSpeed(vehicle) < 10
        end,
        smallText = function(vehicle)
            if(getVehicleEngineState(vehicle))then
                return "Wyłącz"
            else
                return "Włącz"
            end
        end,
        action = function(vehicle)
            triggerServerEvent("interaction.action", resourceRoot, 1)
        end
    },

    lights = {
        icon = "lights",
        text = "Światła",
        enabled = function(vehicle)
            return true
        end,
        smallText = function(vehicle)
            if(getVehicleOverrideLights(vehicle) == 2)then
                return "Wyłącz"
            else
                return "Włącz"
            end
        end,
        action = function(vehicle)
            triggerServerEvent("interaction.action", resourceRoot, 2)
        end
    },

    lock =  {
        icon = "lock",
        text = "Zamek",
        enabled = function(vehicle)
            return true
        end,
        smallText = function(vehicle)
            if(isVehicleLocked(vehicle))then
                return "Otwórz"
            else
                return "Zablokuj"
            end
        end,
        action = function(vehicle)
            triggerServerEvent("interaction.action", resourceRoot, 4)
        end
    },

    brake =  {
        icon = "brake",
        text = "Hamulec ręczny",
        enabled = function(vehicle)
            return true
        end,
        smallText = function(vehicle)
            if(getElementData(vehicle, "vehicle:handbrake"))then
                return "Spuść"
            else
                return "Zaciągnij"
            end
        end,
        action = function(vehicle)
            triggerServerEvent("interaction.action", resourceRoot, 3, nil, getElementSpeed(vehicle))
        end
    },

    suspension = {
        text = "Regulowane zawieszenie",
        smallText={1,2,3,4,5,6,7},
        selected=2,
        icon = "suspension",

        enabled = function(vehicle)
            return getElementSpeed(vehicle) < 10
        end,

        leftAction = function(vehicle)
            return "minus"
        end,

        rightAction = function(vehicle)
            return "plus"
        end,

        changeSuspension=true,
    },

    kick={
        icon="wyrzuc",
        text="Wyrzuć pasażerów",
        smallText={"Wszyscy"},
        selected=1,

        enabled = function(vehicle)
            return getElementSpeed(vehicle) < 10
        end,

        action=function(vehicle, selected, tbl)
            triggerServerEvent("interaction.action", resourceRoot, "wyrzuc", tbl[selected])
        end,

        leftAction = function(vehicle)
            return "minus"
        end,

        rightAction = function(vehicle)
            return "plus"
        end,
    },

    multiLED={
        icon="multiled",
        text="MultiLED",
        smallText={},
        selected=1,

        enabled = function(vehicle)
            return true
        end,

        action=function(vehicle, selected, tbl)
            triggerServerEvent("interaction.action", resourceRoot, "multiLED", tbl[selected])
        end,

        leftAction = function(vehicle)
            return "minus"
        end,

        rightAction = function(vehicle)
            return "plus"
        end,
    },

    fuel={
        text = "Przełącz typ paliwa",
        smallText={"Petrol", "LPG"},
        selected=1,
        icon = "pb",

        enabled = function(vehicle)
            return true
        end,

        leftAction = function(vehicle)
            return "minus"
        end,

        rightAction = function(vehicle)
            return "plus"
        end,

        changeFuel=true,
    },

    najazdy =  {
        icon = "najazdy",
        text = "Najazdy",
        enabled = function(vehicle)
            return not exports.px_factions_sirens:isSirensOn()
        end,
        smallText = function(vehicle)
            local components=getElementData(vehicle, "vehicle:components") or {}
            local have=false
            for i,v in pairs(components) do
                if(v == "Najazdy")then
                    have=true
                    break
                end
            end

            if(have)then
                return "Złóż najazdy"
            end
            return "Rozłóż najazdy"
        end,
        action = function(vehicle)
            local components=getElementData(vehicle, "vehicle:components") or {}
            local del=false
            for i,v in pairs(components) do
                if(v == "Najazdy")then
                    components[i]=nil
                    del=true
                    break
                end
            end

            if(del)then
                setElementData(vehicle, "vehicle:components", components)
                return
            end
            
            components[#components+1]="Najazdy"
            setElementData(vehicle, "vehicle:components", components)
        end
    },

    kogut =  {
        icon = "siren",
        text = "Kogut",
        enabled = function(vehicle)
            return true
        end,
        smallText = function(vehicle)
            return getElementData(vehicle, "haveSiren") and "Zdejmij kogut" or "Załóż kogut"
        end,
        action = function(vehicle)
            triggerServerEvent("interaction.action", resourceRoot, "kogut")
        end
    },

    lights_back = {
        icon = "lights",
        text = "Światła tylne",
        enabled = function(vehicle)
            return true
        end,
        smallText = function(vehicle)
            return "Przełącz światła"
        end,
        action = function(vehicle)
            triggerServerEvent("interaction.action", resourceRoot, 'lights_back')
        end
    },

    asr =  {
        icon = "asr",
        text = "Kontrola trakcji",
        enabled = function(vehicle)
            return true
        end,
        smallText = function(vehicle)
            return getElementData(vehicle, "vehicle:asrOFF") and "Włącz kontrole trakcji" or "Wyłącz kontrole trakcji"
        end,
        action = function(vehicle)
            triggerServerEvent("interaction.action", resourceRoot, "asr")
        end
    },
}

local options={}

local state = false
local deltaTime = 0
local lastFrame = getTickCount()
local useClicked = false
local selected = 0
local targetSelected = selected;
local currentOption = false

local mainAlpha=0
local animated=false
local pos={sx,sx}

function render()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if(not vehicle)then
        return close()
    end

    if(getPedOccupiedVehicleSeat(localPlayer) ~= 0)then
        return close()
    end

    deltaTime = (getTickCount() - lastFrame)/1000
    selected = selected + (targetSelected-selected-#options/2) * deltaTime * 5

    local step = 360/#options/2
    local px,py = pos[1],sy/2 - bgsy/2
    dxDrawImage(px, py, bgsx, bgsy, texs.bgTexture, 0, 0, 0, tocolor(255, 255, 255, mainAlpha))

    local offset = selected
    local iconSizeX,iconSizeY = 75/zoom,75/zoom
    local selectedOption = targetSelected%#options + 1

    for i=0,#options-1 do
        local v = options[i + 1]
        local r = ((i - selected) * step)%180 - 90

        local scale =  (255 - math.min(255,math.abs(r) * 3)) / 255

        local a=255-math.min(255, (math.abs(r) * 5))
        a=a > mainAlpha and mainAlpha or a

        local enabled = v.enabled(vehicle)
        dxDrawImage(px + bgsx/2 - (iconSizeX * scale)/2, sy/2 - (iconSizeY * scale)/2, (iconSizeX * scale), (iconSizeY * scale), v.iconTexture, r, bgsy/(3/(#options/5)), 0, tocolor(255,255,255,a))

        if(not enabled)then
            dxDrawImage(px + bgsx/2 - (iconSizeX * scale)/2, sy/2 - (iconSizeY * scale)/2, (iconSizeX * scale), (iconSizeY * scale), texs.iconDisabled, r, bgsy/(3/(#options/5)), 0, tocolor(255,255,255,a))
        end
        
        offset = offset + 1
    end
    
    currentOption = options[selectedOption]
    if(currentOption)then
        local smallText = ""
        if(type(currentOption["smallText"]) == "function")then
            smallText = currentOption["smallText"](vehicle)
        elseif(type(currentOption["smallText"]) == "table")then
            if(not currentOption["smallText"][currentOption.selected])then
                currentOption.selected=1
            end
            smallText=currentOption["smallText"][currentOption.selected]

            if(currentOption["text"] == "Wyrzuć pasażerów")then
                local players=getVehicleOccupants(vehicle)
                currentOption.smallText={}
                for i,v in pairs(players) do
                    if(v and isElement(v) and v ~= localPlayer)then
                        currentOption.smallText[#currentOption.smallText+1]=getPlayerName(v)
                    end
                end

                currentOption.smallText[#currentOption.smallText+1]="Wszyscy"
                if(not currentOption.smallText[currentOption.selected])then
                    currentOption.selected=1
                end
            end
        else
            smallText = currentOption["smallText"]
        end

        local color={200,200,200}
        local text=smallText
        if(type(text) == "table")then
            color={smallText[2] or "", smallText[3] or "", smallText[4] or ""}
            text=smallText[1] or smallText[#smallText] or "(?)"
        end

        local fw1 = dxGetTextWidth(currentOption["text"], 1, fonts.fontBold)
        local fw2 = dxGetTextWidth(text, 1, fonts.fontRegular)
        local fw = math.max(fw1, fw2)

        dxDrawText(currentOption["text"], 0+1, 0+1, pos[1]-20/zoom+1, sy-25/zoom+1, tocolor(0,0,0,mainAlpha), 1, fonts.fontBold, "right", "center")
        dxDrawText(currentOption["text"], 0, 0, pos[1]-20/zoom, sy-25/zoom, tocolor(222,222,222,mainAlpha), 1, fonts.fontBold, "right", "center")

        if(currentOption["text"] == 'Regulowane zawieszenie')then
            local max=#currentOption["smallText"]
            for i,v in pairs(currentOption["smallText"]) do
                local sX=(22/zoom)*(i-1)

                local k=max-i+1
                if(k == currentOption.selected)then
                    dxDrawImage(pos[1]-39/zoom-sX, sy/2-42/2/zoom+28/zoom, 18/zoom, 18/zoom, texs.elipse_2, 0, 0, 0, tocolor(255, 255, 255, mainAlpha))
                else
                    dxDrawImage(pos[1]-39/zoom-sX, sy/2-42/2/zoom+28/zoom, 18/zoom, 18/zoom, texs.elipse_1, 0, 0, 0, tocolor(255, 255, 255, mainAlpha))
                end
            end
        else
            dxDrawText(text, 0+1, 0+1, pos[1]-20/zoom+1, sy+25/zoom+1, tocolor(0,0,0,mainAlpha), 1, fonts.fontRegular, "right", "center")
            dxDrawText(text, 0, 0, pos[1]-20/zoom, sy+25/zoom, tocolor(color[1],color[2],color[3],mainAlpha), 1, fonts.fontRegular, "right", "center")
        end

        if(currentOption.rightAction and currentOption.leftAction)then
            local tex_1=getKeyState("arrow_l") and texs.arrowLight or texs.arrowLeft
            local tex_2=getKeyState("arrow_r") and texs.arrowLight or texs.arrowLeft
            dxDrawImage(pos[1]-20/zoom-39/zoom-45/zoom, sy/2-42/2/zoom+50/zoom, 39/zoom, 38/zoom, tex_1, 180, 0, 0, tocolor(255, 255, 255, mainAlpha))
            dxDrawImage(pos[1]-20/zoom-39/zoom, sy/2-42/2/zoom+50/zoom, 39/zoom, 38/zoom, tex_2, 0, 0, 0, tocolor(255, 255, 255, mainAlpha))

            if(currentOption["text"] == "Wyrzuć pasażerów" or currentOption["text"] == "MultiLED")then
                local tex=not (getKeyState("space") or getKeyState("mouse1")) and texs.spacebar or texs.spacebarLight
                dxDrawImage(pos[1]-20/zoom-80/zoom-(80-(39+38))/2/zoom, sy/2-52/2/zoom+97/zoom, 80/zoom, 38/zoom, tex, 0, 0, 0, tocolor(255, 255, 255, mainAlpha))
            end
        else
            local tex=not (getKeyState("space") or getKeyState("mouse1")) and texs.spacebar or texs.spacebarLight
            dxDrawImage(pos[1]-20/zoom-80/zoom, sy/2-42/2/zoom+50/zoom, 80/zoom, 38/zoom, tex, 0, 0, 0, tocolor(255, 255, 255, mainAlpha))
        end

        if(useClicked and currentOption.action and currentOption.enabled(vehicle))then
            if(not SPAM.getSpam())then
                currentOption.action(vehicle, currentOption.selected, currentOption.smallText)
            end
        end
    end

    lastFrame = getTickCount()
    useClicked = false
end

function scrollUp()
    targetSelected = targetSelected + 1
end

function scrollDown()
    targetSelected = targetSelected - 1
end

local function use()
    useClicked = true
end

local function left()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(currentOption and currentOption.leftAction and veh)then
        if(SPAM.getSpam())then return end

        local output=currentOption.leftAction(veh)
        if(output)then
            local p=currentOption.selected+1 > #currentOption.smallText and #currentOption.smallText or currentOption.selected+1
            local m=currentOption.selected-1 < 1 and 1 or currentOption.selected-1
            local x=output == "plus" and p or output == "minus" and m
            currentOption.selected=x

            if(currentOption.changeSuspension)then
                setElementData(veh, "vehicle:actualHydraulicState", x)
                triggerServerEvent("hydraulic.regulation", resourceRoot, x)
            elseif(currentOption.changeFuel)then
                setElementData(veh, "vehicle:actualType", x == 1 and "Petrol" or "LPG")
                currentOption.iconTexture=currentOption["iconTexture_"..x]
            end
        end
    end
end

local function right()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(currentOption and currentOption.rightAction and veh)then
        if(SPAM.getSpam())then return end

        local output=currentOption.rightAction(veh)
        if(output)then
            local p=currentOption.selected+1 > #currentOption.smallText and #currentOption.smallText or currentOption.selected+1
            local m=currentOption.selected-1 < 1 and 1 or currentOption.selected-1
            local x=output == "plus" and p or output == "minus" and m
            currentOption.selected=x

            if(currentOption.changeSuspension)then
                setElementData(veh, "vehicle:actualHydraulicState", x)
                triggerServerEvent("hydraulic.regulation", resourceRoot, x)
            elseif(currentOption.changeFuel)then
                setElementData(veh, "vehicle:actualType", x == 1 and "Petrol" or "LPG")
                currentOption.iconTexture=currentOption["iconTexture_"..x]
            end
        end
    end
end

local function key(button, press)
    if(not press)then return end

    if(button == "mouse_wheel_up" or button == "arrow_u")then
        scrollUp()
    elseif(button == "mouse_wheel_down" or button == "arrow_d")then
        scrollDown()
    elseif(button == "arrow_l")then
        left()
    elseif(button == "arrow_r")then
        right()
    elseif(button == "space" or button == "mouse1")then
        use()
    end
end

function open(veh)
    if(not state and not animated)then
        options = {
            optionsList.engine,
            optionsList.lights, 
            optionsList.brake, 
            optionsList.lock, 
            optionsList.kick,
        }

        if(getElementData(localPlayer,"user:faction") == "SARA" and getElementModel(veh) == 443)then
            options[#options+1]=optionsList.najazdy
        end
        if(getElementData(localPlayer,"user:faction") == "SARA" and getElementModel(veh) == 498)then
            options[#options+1]=optionsList.lights_back
        end
        if(getElementData(veh, "vehicle:ASR"))then
            options[#options+1]=optionsList.asr
        end

        if(getElementData(veh, "vehicle:multiLED"))then
            options[#options+1]=optionsList.multiLED
            optionsList.multiLED.smallText=exports.px_workshop_lights:getMultiLEDColors()
        end

        if(getElementData(veh, "vehicle:hydraulicControl"))then
            options[#options+1]=optionsList.suspension
        end

        if(getElementData(veh, "vehicle:group_owner") == "SAPD" or getElementData(veh, "vehicle:group_owner") == "SARA")then
            options[#options+1]=optionsList.kogut
        end

        if(getElementData(veh, "vehicle:fuelType") == "LPG")then
            options[#options+1]=optionsList.fuel
        end
        
        animated=true

        lastFrame = getTickCount()

        state = not state
        
        addEventHandler("onClientRender", root, render)
        addEventHandler("onClientKey", root, key)

        local px,py = pos[1], sy/2 - bgsy/2

        texs.bgTexture = dxCreateTexture("textures/bg.png", "argb", false, "clamp")
        texs.iconDisabled = dxCreateTexture("textures/icon_disabled.png", "argb", false, "clamp")

        texs.arrowLeft = dxCreateTexture("textures/button_arrow_left.png", "argb", false, "clamp")
        texs.arrowLight = dxCreateTexture("textures/button_arrow_light.png", "argb", false, "clamp")

        texs.spacebar = dxCreateTexture("textures/spacebar.png", "argb", false, "clamp")
        texs.spacebarLight = dxCreateTexture("textures/spacebar_light.png", "argb", false, "clamp")

        fonts.fontBold = dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 20/zoom)
        fonts.fontRegular = dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 14/zoom)

        texs.elipse_1=dxCreateTexture("textures/elipse_1.png", "argb", false, "clamp")
        texs.elipse_2=dxCreateTexture("textures/elipse_2.png", "argb", false, "clamp")

        for _,k in pairs(optionsList) do
            for i,v in pairs(k) do
                if(i == "icon" and _ ~= "fuel")then
                    k.iconTexture = dxCreateTexture("textures/icon_"..v..".png", "argb", false, "clamp")
                elseif(_ == "fuel")then
                    k["iconTexture_1"] = dxCreateTexture("textures/icon_pb.png", "argb", false, "clamp")
                    k["iconTexture_2"] = dxCreateTexture("textures/icon_lpg.png", "argb", false, "clamp")
                end
            end
        end
        optionsList.fuel.iconTexture=optionsList.fuel["iconTexture_"..optionsList.fuel.selected]

        animate(mainAlpha, 255, "Linear", 250, function(a)
            mainAlpha=a
        end, function()
            animated=false
        end)

        animate(pos[1], (sx - bgsx), "Linear", 250, function(v)
            pos[1]=v
        end)

        local px,py = (sx - bgsx), sy/2 - bgsy/2        
        animate(pos[2], px, "Linear", 250, function(v)
            pos[2]=v
        end)

        if(not options[targetSelected])then
            targetSelected=#options
        end
    end
end

function close()
    if(state and not animated)then
        animated=true

        removeEventHandler("onClientKey", root, key)

        animate(pos[1], sx, "Linear", 250, function(v)
            pos[1]=v
        end)

        local px,py = pos[1], sy/2 - bgsy/2
        animate(pos[2], sx, "Linear", 250, function(v)
            pos[2]=v
        end)

        animate(mainAlpha, 0, "Linear", 250, function(a)
            mainAlpha=a
        end, function()
            state = not state

            removeEventHandler("onClientRender", root, render)
    
            for i,v in pairs(texs) do
                destroyElement(v)
            end
            texs={}
    
            for i,v in pairs(fonts) do
                destroyElement(v)
            end
            fonts={}
    
            for i,k in pairs(optionsList) do
                for i,v in pairs(k) do
                    if(i == "icon")then
                        destroyElement(k.iconTexture)
                    end
                end
            end

            animated=false

            setElementData(localPlayer, "user:interaction_showed", false, false)
        end)
    end
end

-- useful

local anims = {}
local rendering = false

local function renderAnimations()
    local now = getTickCount()
    for k,v in pairs(anims) do
        v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
        if(now >= v.start+v.duration)then
            table.remove(anims, k)
			if(type(v.onEnd) == "function")then
                v.onEnd()
            end
        end
    end

    if(#anims == 0)then
        rendering = false
        removeEventHandler("onClientRender", root, renderAnimations)
    end
end

function animate(f, t, easing, duration, onChange, onEnd)
	if(#anims == 0 and not rendering)then
		addEventHandler("onClientRender", root, renderAnimations)
		rendering = true
	end

    assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
    assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
    assert(type(easing) == "string", "Bad argument @ 'animate' [Invalid easing at argument 3]")
    assert(type(duration) == "number", "Bad argument @ 'animate' [expected number at argument 4, got "..type(duration).."]")
    assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
    table.insert(anims, {from = f, to = t, easing = easing, duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})

    return #anims
end

function destroyAnimation(id)
    if(anims[id])then
        anims[id] = nil
    end
end

function table.size(t)
    local x=0
    for i,v in pairs(t) do
        x=x+1
    end
    return x
end

function table.reverse(t) 
    local reversedTable = {} 
    local itemCount = #t  
    for k, v in ipairs(t) do 
        reversedTable[itemCount + 1 - k] = v  
    end 
    return reversedTable  
end 

options=table.reverse(options)