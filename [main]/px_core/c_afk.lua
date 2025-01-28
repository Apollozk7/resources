--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local saveDataTimer=false
local function setElementCustomData(element,name,value)
    if(saveDataTimer)then
        killTimer(saveDataTimer)
        saveDataTimer=false
    end

    setElementData(element,name,value,false)
    setTimer(function()
        if(element and isElement(element))then
            setElementData(element,name,value)
        end
    end, (1000*30), 1)
end

afk={}

-- variables

afk.settings = {
    tick=getTickCount(),
    anim=getTickCount(),
    alpha=0,
    active=false,
    timeToAFK=60*10, -- w sekundach
    keys=false,
    timeTick=0,
    time=0,

    tex="textures/afk_header.png",
    fnts={
        {":px_assets/fonts/Font-Bold.ttf", 17/zoom},
        {":px_assets/fonts/Font-Regular.ttf", 15/zoom},
        {":px_assets/fonts/Font-Bold.ttf", 25/zoom},
    },

    icon=false,
    fonts={},
}

-- functions

afk.getRows=function(tbl) 
    local k=0 
    for _,_ in pairs(tbl) do 
        k=k+1 
    end 
    return k 
end

afk.getTime=function(time) 
    local hours = math.floor(time/60)
    local minutes = math.floor(time-(hours*60))
    return hours,minutes
end

afk.start=function()
    if(not getElementData(localPlayer, "user:logged") or afk.settings.active)then return end

    afk.settings.active=true
    afk.settings.time=0
    afk.settings.tick=getTickCount()

    afk.settings.icon=dxCreateTexture(afk.settings.tex, "argb", false, "clamp")
    for i,v in pairs(afk.settings.fnts) do
        afk.settings.fonts[i]=dxCreateFont(v[1],v[2])
    end

    blur=exports.blur
    addEventHandler("onClientRender", root, afk.render)

    setElementCustomData(localPlayer, "user:afk", true, false)

    if(not afk.settings.animate)then
        afk.settings.animate=true

        animate(0, 255, "Linear", 500, function(a)
            afk.settings.alpha=a
        end, function()
            afk.settings.animate=false
        end)
    end
end

afk.stop=function()
    if(not afk.settings.active or afk.settings.animate)then return end

    setElementCustomData(localPlayer, "user:afk", false, false)

    if(not afk.settings.animate)then
        afk.settings.animate=true
        animate(255, 0, "Linear", 500, function(a)
            afk.settings.alpha=a
        end, function()
            afk.settings.animate=false
            afk.settings.active=false

            checkAndDestroy(afk.settings.icon)
            afk.settings.icon=false

            for i,v in pairs(afk.settings.fonts) do
                checkAndDestroy(v)
            end
            afk.settings.fonts={}

            removeEventHandler("onClientRender", root, afk.render)
        end)
    end
end

afk.render=function()
    if((getTickCount()-afk.settings.tick) > 1000)then
        afk.settings.time=afk.settings.time+1
        afk.settings.tick=getTickCount()
    end

    local a=afk.settings.alpha

    blur:dxDrawBlur(0, 0, sw, sh, tocolor(100, 100, 100, a), true)
    dxDrawRectangle(0, 0, sw, sh, tocolor(30, 30, 30, a > 200 and 200 or a), true)

    local rot=interpolateBetween(-5, 0, 0, 5, 0, 0, (getTickCount()-afk.settings.anim)/5000, "SineCurve")
    dxDrawImage(sw/2-80/2/zoom, sh/2-80/2/zoom-50/zoom, 80/zoom, 80/zoom, afk.settings.icon, rot, 0, 0, tocolor(255, 255, 255, a), true)

    dxDrawText("Jesteś nieaktywny", 0, sh/2, sw, sh, tocolor(255, 255, 255, a), 1, afk.settings.fonts[1], "center", "top", false, false, true)

    dxDrawRectangle(sw/2-477/2/zoom, sh/2+40/zoom, 477/zoom, 1, tocolor(85,85,85, a), true)

    local afkTime={afk.getTime(afk.settings.timeToAFK)}
    afkTime=afkTime[1] > 0 and afkTime[1].." minut "..afkTime[2].." sekund" or afkTime[2].." sekund"
    dxDrawText("Przez jakiś czas nie wykonywałeś żadnej interakcji z grą.\nTwój czas online nie jest naliczany.", 0, sh/2+50/zoom, sw, sh, tocolor(200, 200, 200, a), 1, afk.settings.fonts[2], "center", "top", false, false, true)

    local sec=afk.settings.time
    local time={afk.getTime(sec)}
    time=string.format("%02d", time[1])..":"..string.format("%02d", time[2])
    dxDrawText("Czas na AFK", 0, sh-105/zoom, sw, sh, tocolor(200, 200, 200, a), 1, afk.settings.fonts[2], "center", "top", false, false, true)
    dxDrawText(time, 0, sh-85/zoom, sw, sh, tocolor(255, 255, 255, a), 1, afk.settings.fonts[3], "center", "top", false, false, true)
end

afk.getKeyStates=function()
    if(not afk.settings.active)then
        local time=getTickCount()-afk.settings.tick
        local seconds=time/1000
		if(seconds >= afk.settings.timeToAFK and not afk.settings.active)then
            afk.start()
		end
    end
end

-- events

addEventHandler("onClientKey", root, function(key, press)
    afk.settings.tick=getTickCount()

    if(afk.settings.active)then
        afk.stop()
    end
end)

addEventHandler("onClientMinimize", root, function()
    if(not afk.settings.active)then
		afk.start()

        outputConsole("[AFK] Start, user minimize the game.")
	end
end)

-- useful

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
        return true
    end
    return false
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

-- on start 

addEventHandler("onClientResourceStop", resourceRoot, function()
    setElementData(localPlayer, "user:afk", false)
end)