--[[
    @author: Toffy., psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- assets

local assets={}
assets.list={
    texs={
        "textures/off.png",

        "textures/pixel_off.png",
        "textures/eska_off.png",
        "textures/zet_off.png",
        "textures/rmf_off.png",
        "textures/party_off.png",

        "textures/pixel_on.png",
        "textures/eska_on.png",
        "textures/zet_on.png",
        "textures/rmf_on.png",
        "textures/party_on.png",

        "textures/choose.png",
        "textures/radio_name.png",
        "textures/bg_arrow.png",
        "textures/arrow.png",

        "textures/volume.png", -- 12
        "textures/volume_1.png", -- 13
        "textures/volume_2.png", -- 14
        "textures/volume_3.png", -- 15
        "textures/volume_4.png", -- 16
    },

    fonts={
        {"Medium", 13},
        {"Medium", 11},
        {"SemiBold", 13},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts={}
    for i,v in pairs(assets.list.fonts) do
        assets.fonts[i]=dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom) or "default-bold"
    end
end

assets.destroy=function()
    for i,v in pairs(assets.textures) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.textures={}

    for i,v in pairs(assets.fonts) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.fonts={}
end

-- variables

local ui={}

-- functions

ui.radio=1
ui.volume=4
ui.anim=0
ui.currentAlpha=0

ui.radios={
    {colorAlpha = 0, name = "OFF", url = "off"},
    {colorAlpha = 0, name = "X69", url = "https://s3.slotex.pl/shoutcast/7580/listen.pls?sid=1"},
    {colorAlpha = 0, name = "Eska", url = "http://ext03.ic.smcdn.pl/2380-1.mp3"},
    {colorAlpha = 0, name = "Zet", url = "http://www.emsoft.ct8.pl/inne/zet.m3u"},
    {colorAlpha = 0, name = "RMF", url = "http://www.rmfon.pl/n/rmfmaxxx.pls"},
    {colorAlpha = 0, name = "Party", url = "http://www.radioparty.pl/play/glowny_64.m3u"},
}

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

ui.radiosLength = tablelength(ui.radios)

ui.onRender=function()
    if(not getPedOccupiedVehicle(localPlayer))then
        hideRadio()
        
        ui.destroy()

        if(ui.eventDefined) then
            ui.eventDefined = false;

            if(veh and isElement(veh))then
                removeEventHandler("onClientElementDataChange", veh, elementData_onChange)
            end
        end

        return
    end

    for k,v in ipairs(ui.radios) do
        local sX=(72/zoom)*(k-(ui.radiosLength-1))+40/zoom

        if(ui.radio == k)then
            if(v.colorAlpha < 230) then
                ui.radios[k].colorAlpha = ui.radios[k].colorAlpha+8.5;
            end

            local alpha_ = ui.currentAlpha < v.colorAlpha and ui.currentAlpha or v.colorAlpha;

            dxDrawImage(sw/2+sX+5/zoom, (sh-147/zoom)+ui.anim, 60/zoom, 60/zoom, assets.textures[k], 0,0,0, tocolor(255,255,255, ui.currentAlpha))
            dxDrawImage(sw/2+sX+5/zoom, (sh-147/zoom)+ui.anim, 60/zoom, 60/zoom, assets.textures[k == 1 and 1 or (ui.radiosLength-1)+k], 0,0,0, tocolor(255,255,255, alpha_))
            dxDrawImage(sw/2+sX+5/zoom+(60-68)/2/zoom, (sh-147/zoom+(60-68)/2/zoom)+ui.anim, 68/zoom, 68/zoom, assets.textures[12], 0,0,0, tocolor(255,255,255, alpha_))
        else
            dxDrawImage(sw/2+sX+5/zoom, (sh-147/zoom)+ui.anim, 60/zoom, 60/zoom, assets.textures[k], 0,0,0, tocolor(255,255,255, ui.currentAlpha))
            if(v.colorAlpha > 0) then
                ui.radios[k].colorAlpha = ui.radios[k].colorAlpha-8.5;

                local alpha_ = ui.currentAlpha < v.colorAlpha and ui.currentAlpha or v.colorAlpha;

                dxDrawImage(sw/2+sX+5/zoom, (sh-147/zoom)+ui.anim, 60/zoom, 60/zoom, assets.textures[k == 1 and 1 or (ui.radiosLength-1)+k], 0,0,0, tocolor(255,255,255, alpha_))
                dxDrawImage(sw/2+sX+5/zoom+(60-68)/2/zoom, (sh-147/zoom+(60-68)/2/zoom)+ui.anim, 68/zoom, 68/zoom, assets.textures[12], 0,0,0, tocolor(255,255,255, alpha_))
            end
        end
    end

    local start_x, start_y = sw/2-81/2/zoom-81/2/zoom-81/2/zoom, (sh-73/zoom-1)+ui.anim

    dxDrawImage(start_x, (sh-73/zoom)+ui.anim, 81/zoom, 21/zoom, assets.textures[13], 0,0,0, tocolor(255,255,255, ui.currentAlpha))
    dxDrawText(ui.radios[ui.radio].name, start_x, (sh-73/zoom)+ui.anim, 81/zoom+sw/2-81/2/zoom-81/2/zoom-81/2/zoom, (21/zoom+sh-73/zoom)+ui.anim, tocolor(200, 200, 200, ui.currentAlpha), 1, assets.fonts[1], "center", "center")

    dxDrawImage(start_x+81/zoom+8/zoom, start_y, 23/zoom, 23/zoom, assets.textures[14], 0,0,0, tocolor(255,255,255, ui.currentAlpha))
    dxDrawImage(start_x+81/zoom+8/zoom+23/zoom+8/zoom, start_y, 23/zoom, 23/zoom, assets.textures[14], 0,0,0, tocolor(255,255,255, ui.currentAlpha))
    
    dxDrawImage(start_x+81/zoom+8/zoom+(23-7)/2/zoom, (start_y+(23-10)/2/zoom)+ui.anim, 7/zoom, 10/zoom, assets.textures[15], 0,0,0, getKeyState('arrow_l') and tocolor(104,205,111, ui.currentAlpha) or tocolor(255,255,255, ui.currentAlpha))
    dxDrawImage(start_x+81/zoom+8/zoom+23/zoom+8/zoom+(23-7)/2/zoom, (start_y+(23-10)/2/zoom)+ui.anim, 7/zoom, 10/zoom, assets.textures[15], 180,0,0, getKeyState('arrow_r') and tocolor(104,205,111, ui.currentAlpha) or tocolor(255,255,255, ui.currentAlpha))

    -- volume
    dxDrawImage(start_x+81/zoom+8/zoom+23/zoom+8/zoom+23/zoom+17/zoom, start_y, 16/zoom, 21/zoom, assets.textures[16], 0,0,0, tocolor(255,255,255, ui.currentAlpha)) --lewy głośnik
    dxDrawImage(start_x+81/zoom+8/zoom+23/zoom+8/zoom+23/zoom+17/zoom+4/zoom+16/zoom, start_y+1, 16/zoom, 21/zoom, assets.textures[20], 0,0,0, tocolor(255,255,255, ui.currentAlpha)) -- bg

    if(ui.volume > 0) then
        dxDrawImage(start_x+81/zoom+8/zoom+23/zoom+8/zoom+23/zoom+17/zoom+4/zoom+16/zoom, start_y+1, 16/zoom, 21/zoom, assets.textures[16+ui.volume], 0,0,0, tocolor(0,255,0, ui.currentAlpha))
    end
end

ui.create=function(alphaAnim)
    if(ui.state == 1) then return end

    assets.create()
    ui.state = 1;

    if(isTimer(ui.alphaTimer)) then killTimer(ui.alphaTimer); ui.alphaTimer = nil end
    if(ui.alphaAnim) then destroyAnimation(ui.alphaAnim); ui.alphaAnim = nil; end

    animate(200, 0, "InBounce", 800, function(height)
        ui.anim = height;
    end)

    ui.alphaTimer = setTimer(function()
        hideRadio()
    end, 2500, 1)

    addEventHandler("onClientRender", root, ui.onRender)
end

ui.destroy=function()
    if(ui.state == 0) then return end

    animate(ui.anim, 200, "OutBounce", 800, function(height)
        ui.anim = height;
        if(height == 200) then
            removeEventHandler("onClientRender", root, ui.onRender)
            assets.destroy()
            ui.state = 0;
        end
    end)
end

function showRadio()
    if(isTimer(ui.alphaTimer)) then killTimer(ui.alphaTimer); ui.alphaTimer = nil end
    if(ui.alphaAnim) then destroyAnimation(ui.alphaAnim); ui.alphaAnim = nil; end

    ui.alphaTimer = setTimer(function()
        hideRadio()
    end, 2500, 1)

    ui.create(true);

    if(ui.currentAlpha == 0)then
        ui.alphaAnim = animate(0,255, "Linear", 800, function(height)
            ui.currentAlpha = height;
        end)
    else
        ui.currentAlpha = 255;
    end
end

function hideRadio()
    ui.alphaAnim = animate(255, 0, "Linear", 800, function(height)
        ui.currentAlpha = height;
        if(height == 0) then
            removeEventHandler("onClientRender", root, ui.onRender)
            assets.destroy()
            ui.state = 0;
        end
    end)
end

function playRadio(index)
    local radioData = ui.radios[index];

    if(getPedOccupiedVehicleSeat(localPlayer) == 0) then
        setElementData(getPedOccupiedVehicle(localPlayer), "radio->index", index)
    end

    if(ui.sound) then
        destroyElement(ui.sound)
        ui.sound = nil;
    end

    if(radioData.url ~= "off") then
        ui.sound = playSound(radioData.url)
        setSoundVolume(ui.sound, 1 * (ui.volume/4))
    end

    if(isTimer(ui.alphaTimer)) then killTimer(ui.alphaTimer); ui.alphaTimer = nil end
    if(ui.alphaAnim) then destroyAnimation(ui.alphaAnim); ui.alphaAnim = nil; end

    ui.alphaTimer = setTimer(function()
        hideRadio()
    end, 2500, 1)

    showRadio()
end

bindKey("arrow_r", "up", function()
    if(getPedOccupiedVehicle(localPlayer) and not isCursorShowing() and not getElementData(localPlayer, "user:gui_showed") and not getElementData(localPlayer, "user:tank_showed") and not getElementData(localPlayer, "user:interaction_showed"))then
        local type=getVehicleType(getPedOccupiedVehicle(localPlayer))
        if(type == "Plane" or type == "Helicopter")then return end

        if(ui.volume+1 > 4) then return end
        ui.volume = ui.volume+1; 
        if(ui.sound) then
            setSoundVolume(ui.sound, 1 * (ui.volume/4))
        end
        showRadio()
    end
end)

bindKey("arrow_l", "up", function()
    if(getPedOccupiedVehicle(localPlayer) and not isCursorShowing() and not getElementData(localPlayer, "user:gui_showed") and not getElementData(localPlayer, "user:tank_showed") and not getElementData(localPlayer, "user:interaction_showed"))then
        local type=getVehicleType(getPedOccupiedVehicle(localPlayer))
        if(type == "Plane" or type == "Helicopter")then return end
        
        if(ui.volume-1 < 0) then return end
        ui.volume = ui.volume-1;
        if(ui.sound) then
            setSoundVolume(ui.sound, 1 * (ui.volume/4))
        end
        showRadio()
    end
end)

bindKey("mouse_wheel_down", "down", function()
    if(getPedOccupiedVehicle(localPlayer) and not isCursorShowing() and not getElementData(localPlayer, "user:gui_showed") and not getElementData(localPlayer, "user:interaction_showed"))then
        if(getPedOccupiedVehicleSeat(localPlayer) == 0) then
            if(ui.radio+1 > ui.radiosLength) then
                ui.radio = 1;
            else
                ui.radio = ui.radio+1;
            end
            playRadio(ui.radio);
        else
            showRadio()
        end
    end
end)

bindKey("mouse_wheel_up", "down", function()
    if(getPedOccupiedVehicle(localPlayer) and not isCursorShowing() and not getElementData(localPlayer, "user:gui_showed") and not getElementData(localPlayer, "user:interaction_showed"))then
        if(getPedOccupiedVehicleSeat(localPlayer) == 0) then
            if(ui.radio-1 < 1) then
                ui.radio = ui.radiosLength;
            else
                ui.radio = ui.radio-1;
            end
            playRadio(ui.radio);
        else
            showRadio()
        end
    end
end)

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

--ui.eventDefined;

function elementData_onChange(key, _, newIndex)
    if(key == "radio->index")then
        local veh=getPedOccupiedVehicle(localPlayer)
        if(veh and veh == source)then
            ui.radio = newIndex
            playRadio(newIndex)
        end
    end
end

addEventHandler("onClientPlayerVehicleEnter", localPlayer, function(veh)
    if(getPedOccupiedVehicleSeat(localPlayer) == 0) then
        ui.create()
        playRadio(ui.radio)
    else
        local radioIndex = getElementData(veh, "radio->index");
        if(radioIndex) then
            ui.radio = radioIndex
            playRadio(radioIndex)
        end

        if(not ui.eventDefined)then
            ui.eventDefined = true;
            addEventHandler("onClientElementDataChange", veh, elementData_onChange)
        end
    end
end)

addEventHandler("onClientPlayerVehicleExit", localPlayer, function(veh)
    ui.destroy()

    if(ui.eventDefined) then
        ui.eventDefined = false;
        removeEventHandler("onClientElementDataChange", veh, elementData_onChange)
    end

    if(ui.sound) then
        destroyElement(ui.sound)
        ui.sound = nil;
    end
end)

if(getPedOccupiedVehicleSeat(localPlayer) == 0) then
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if(vehicle)then
        local radioIndex = getElementData(vehicle, "radio->index");
        if(radioIndex) then
            ui.radio = radioIndex
            playRadio(radioIndex)
        else
            ui.create()
        end
    end
else
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if(vehicle)then
        local radioIndex = getElementData(vehicle, "radio->index");
        if(radioIndex) then
            ui.radio = radioIndex
            playRadio(radioIndex)
        end 
        ui.eventDefined = true;
        addEventHandler("onClientElementDataChange", vehicle, elementData_onChange)
    end
end

addEventHandler("onClientElementDestroy", root, function()
    if(getPedOccupiedVehicle(localPlayer) == source)then
        ui.destroy()

        if(ui.eventDefined) then
            ui.eventDefined = false;
            removeEventHandler("onClientElementDataChange", source, elementData_onChange)
        end
    
        if(ui.sound) then
            destroyElement(ui.sound)
            ui.sound = nil;
        end
    end
end)

addEventHandler("onClientPlayerRadioSwitch", localPlayer, cancelEvent)
