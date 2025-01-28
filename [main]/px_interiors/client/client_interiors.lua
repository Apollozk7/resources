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
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

-- variables

local load = exports.px_loading
local blur=exports.blur

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local UI={}

UI.data=false
UI.type=""
UI.icon=false
UI.marker=false
UI.alpha=0

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-SemiBold.ttf", 12},
        {":px_assets/fonts/Font-Regular.ttf", 12},
        {":px_assets/fonts/Font-Regular.ttf", 11},
        {":px_assets/fonts/Font-Regular.ttf", 13},
    },

    textures={},
    textures_paths={
        "assets/images/window.png",
    },
}

-- functions

UI.onRender=function()
    blur:dxDrawBlur(sw/2-490/2/zoom, sh-160/zoom, 490/zoom, 118/zoom, tocolor(255, 255, 255, UI.alpha))
    dxDrawImage(sw/2-490/2/zoom, sh-160/zoom, 490/zoom, 118/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))

    if(UI.icon and isElement(UI.icon))then
        local w,h=dxGetMaterialSize(UI.icon)
        w,h=w/2.2,h/2.2
        dxDrawImage(sw/2-490/2/zoom+490/zoom-130/zoom, sh-160/zoom+(118-h)/2/zoom, w/zoom, h/zoom, UI.icon, 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
    end

    dxDrawText(UI.type == "wejscie" and "Wejście" or "Wyjście", sw/2-490/2/zoom+15/zoom, sh-160/zoom, 490/zoom, sh-160/zoom+33/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[1], "left", "center")
    dxDrawRectangle(sw/2-490/2/zoom+15/zoom, sh-160/zoom+33/zoom, 280/zoom, 1, tocolor(81, 81, 81, UI.alpha))
    dxDrawText(UI.data.query.name, sw/2-490/2/zoom+15/zoom, sh-160/zoom+38/zoom, sw/2-490/2/zoom+15/zoom+280/zoom, sh-160/zoom+33/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[2], "left", "top", false, true)
    
    dxDrawText("Aby wejść do budynku wciśnij klawiasz '#00baffQ#c9c9c9'.", sw/2-490/2/zoom+15/zoom, sh-160/zoom+93/zoom, sw/2-490/2/zoom+15/zoom+280/zoom, sh-160/zoom+33/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[3], "left", "top", false, true, false, true)

    if(not isElementWithinMarker(localPlayer, UI.marker) and not UI.animate and not click)then
        animate(UI.alpha, 0, "Linear", 200, function(a)
            UI.alpha=a
            UI.animate=true
        end, function()
            removeEventHandler("onClientRender", root, UI.onRender)
            assets.destroy()

            UI.data=false
            UI.type=""
            UI.marker=false
            UI.animate=false

            if(UI.icon and isElement(UI.icon))then
                destroyElement(UI.icon)
                UI.icon=false
            end
        end)
    end

    if(getKeyState("Q") and not click)then
        click=true

        animate(UI.alpha, 0, "Linear", 2000, function(a)
            UI.alpha=a
        end, function()
            removeEventHandler("onClientRender", root, UI.onRender)
            assets.destroy()

            click=false
        end)

        setElementFrozen(localPlayer, true)

        load:createLoadingScreen(true, false, 3000)

        setTimer(function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("load.interior", resourceRoot, UI.data, UI.type, UI.start_dim)

            setTimer(function()
                setElementFrozen(localPlayer, false)

                UI.data=false
                UI.type=""
                UI.marker=false

                if(UI.icon and isElement(UI.icon))then
                    destroyElement(UI.icon)
                    UI.icon=false
                end
            end, 3000, 1)
        end, 550, 1)
    end
end

-- triggers

addEvent("open.ui", true)
addEventHandler("open.ui", resourceRoot, function(data, type, path, marker, dim)
    if(UI.icon)then return end

    load = exports.px_loading
    blur=exports.blur
    
    addEventHandler("onClientRender", root, UI.onRender)

    assets.create()

    UI.data=data
    UI.type=type
    UI.marker=marker
    UI.start_dim=dim

    if(path)then
        UI.icon=dxCreateTexture(path, "argb", false, "clamp")
    end

    animate(UI.alpha, 255, "Linear", 200, function(a)
        UI.alpha=a
    end)
end)

-- main variables

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

-- animate

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
