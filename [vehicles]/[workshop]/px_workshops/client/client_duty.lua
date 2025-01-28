--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(isTimer(SPAM.blockSpamTimer))then
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        return true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return false
end

-- variables

sw,sh=guiGetScreenSize()
zoom=1920/sw

local UI={}

UI.btns={}
UI.alpha=0
UI.tag=""
UI.text=""
UI.dbJobs={}

-- exports

local buttons=exports.px_buttons
local noti=exports.px_noti
local blur=exports.blur

-- assets

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 15},
        {":px_assets/fonts/Font-Medium.ttf", 13},
        {":px_assets/fonts/Font-Regular.ttf", 11},
        {":px_assets/fonts/Font-Regular.ttf", 13},
    },

    textures={},
    textures_paths={
        "assets/images/window.png",
        "assets/images/window_icon.png",
        "assets/images/ranga.png",
        "assets/images/wyplata.png",
        "assets/images/button_start.png",
        "assets/images/button_close.png",
        "assets/images/wrench.png",
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

-- render

UI.getBorder=function(id)
    for i=1,3 do
        local text=i == 1 and "Mechanik" or i == 2 and "Lakiernik" or i == 3 and "Tuner"
        local w=dxGetTextWidth(text, 1, assets.fonts[2])
        local sX=0
        if(i == 1)then
            sX=w*(i-2)
            sX=sX-30/zoom
        elseif(i == 2)then
            sX=w*(i-2)
            sX=sX+10/zoom
        elseif(i == 3)then
            sX=w*(i-2)+17/zoom
            sX=sX+60/zoom
        end

        if(i == id)then
            return sw/2-557/2/zoom+(557-w)/2/zoom+sX, w
        end
    end
    return sw/2-557/2/zoom,73/zoom
end

UI.pos={}
UI.animate=false
UI.mainAlpha=0
UI.border=1

UI.jobs={
    [1]={
        name="Mechanik",
        desc="#c2c2c2Twoim zadaniem jako #7cd8fdMechanik#c2c2c2 jest naprawa oraz dokonywanie\nprzeglądów pojazdów graczy.",
    },

    [2]={
        name="Lakiernik",
        desc="#c2c2c2Twoim zadaniem jako #7cd8fdLakiernik#c2c2c2 jest lakierowanie pojazdów\ninnych graczy.",
    },

    [3]={
        name="Tuner",
        desc="#c2c2c2Twoim zadaniem jako #7cd8fdTuner#c2c2c2 jest ulepszanie osiągów mechanicznych\ni wizualnych graczy.",
    },
}

UI.onRender=function()
    blur:dxDrawBlur(sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom, 294/zoom, tocolor(255, 255, 255, UI.alpha))
    dxDrawImage(sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom, 294/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))

    dxDrawText("Warsztat", sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-294/2/zoom+55/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[1], "center", "center")
    local w=dxGetTextWidth("Warsztat", 1, assets.fonts[1])
    dxDrawImage(sw/2-557/2/zoom+(557/2)/zoom+w/2+10/zoom, sh/2-294/2/zoom+19/zoom, 23/zoom, 20/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
 
    dxDrawRectangle(sw/2-518/2/zoom, sh/2-294/2/zoom+55/zoom, 518/zoom, 1, tocolor(85, 85, 85, UI.alpha))

    for i=1,3 do
        local text=i == 1 and "Mechanik" or i == 2 and "Lakiernik" or i == 3 and "Tuner"
        local w=dxGetTextWidth(text, 1, assets.fonts[2])
        local sX=0
        if(i == 1)then
            sX=w*(i-2)
            sX=sX-30/zoom
        elseif(i == 2)then
            sX=w*(i-2)
            sX=sX+10/zoom
        elseif(i == 3)then
            sX=w*(i-2)+17/zoom
            sX=sX+60/zoom
        end

        dxDrawText(text, sw/2-557/2/zoom+(557-w)/2/zoom+sX, sh/2-294/2/zoom+60/zoom, w+sw/2-557/2/zoom+(557-w)/2/zoom+sX, 30/zoom+sh/2-294/2/zoom+65/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[2], "center", "top")

        onClick(sw/2-557/2/zoom+(557-w)/2/zoom+sX, sh/2-294/2/zoom+65/zoom, w, 25/zoom, function()
            if(not UI.animate)then
                local p={UI.getBorder(i)}
                UI.animate=true
                animate(UI.pos[1], p[1], "Linear", 500, function(a)
                    UI.pos[1]=a
                end)
                animate(UI.pos[2], p[2], "Linear", 500, function(a)
                    UI.pos[2]=a
                end)

                animate(UI.mainAlpha, 0, "Linear", 250, function(a)
                    UI.mainAlpha=a
                end, function()
                    UI.border=i
                    animate(UI.mainAlpha, 255, "Linear", 250, function(a)
                        UI.mainAlpha=a
                    end, function()
                        UI.animate=false
                    end)
                end)
            end
        end)
    end

    local x,w=unpack(UI.pos)
    dxDrawRectangle(x, sh/2-294/2/zoom+65/zoom+25/zoom, w, 1, tocolor(28, 89, 104, UI.alpha))

    dxDrawText(UI.jobs[UI.border].desc, sw/2-557/2/zoom, sh/2-294/2/zoom+100/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-294/2/zoom+250/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "center", "top", false, false, false, true)

    dxDrawImage(sw/2-557/2/zoom+222/zoom, sh/2-294/2/zoom+165/zoom, 46/zoom, 46/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
    dxDrawText(UI.jobs[UI.border].name, sw/2-557/2/zoom+280/zoom, sh/2-294/2/zoom+165/zoom, 46/zoom, 46/zoom+sh/2-294/2/zoom+165/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "left", "center")

    local data=getElementData(localPlayer, "user:job_settings")
    buttons:buttonSetText(UI.btns[1], data and data.job_name == UI.jobs[UI.border].name and "ZAKOŃCZ" or "ROZPOCZNIJ")

    onClick(sw/2-148/zoom-10/zoom, sh/2+90/zoom, 148/zoom, 39/zoom, function()
        if(data and data.job_name == UI.jobs[UI.border].name)then
            if(SPAM.getSpam())then return end
            if(data.job_tag ~= UI.tag)then
                noti:noti("Nie pracujesz w tym warsztacie.", "info")
            elseif(data.job_tag == UI.tag)then
                noti:noti("Pomyślnie zakończono pracę w warsztacie.", "success")
    
                setElementData(localPlayer, "user:job_settings", false)
                setElementData(localPlayer, "user:job", false)
    
                triggerServerEvent("last.skin", resourceRoot, UI.tag, UI.jobs[UI.border].name, UI.jobs[UI.border], UI.city)
            end
        else
            if(data or getElementData(localPlayer, "user:faction"))then
                noti:noti("Jesteś już gdzieś zatrudniony.", "error")
            else
                local sprays=false
                local is=false
                for i,v in pairs(UI.dbJobs) do
                    if(string.find(v.job,UI.city))then
                        sprays=true
                    end

                    if(v.job == UI.jobs[UI.border].name.." "..UI.city)then
                        is=true
                    end
                end

                if(UI.jobs[UI.border].name == "Lakiernik" and sprays)then
                    is=true
                end

                if(is)then
                    if(SPAM.getSpam())then return end

                    triggerServerEvent("set.duty", resourceRoot, UI.jobs[UI.border], UI.tag, UI.city)
                else
                    noti:noti("Nie jesteś zatrudniony jako "..UI.jobs[UI.border].name..".", "error")
                end
            end
        end
    end)

    onClick(sw/2+10/zoom, sh/2+90/zoom, 148/zoom, 39/zoom, function()
        UI.toggleUI(false)
    end)
end

UI.toggleUI=function(state, q)
    if(state and not getElementData(localPlayer, "user:gui_showed"))then
        buttons=exports.px_buttons
        noti=exports.px_noti
        blur=exports.blur

        assets.create()

        addEventHandler("onClientRender", root, UI.onRender)

        showCursor(true)

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

        UI.pos={UI.getBorder(1)}
        UI.dbJobs=q

        UI.btns[1]=buttons:createButton(sw/2-148/zoom-10/zoom, sh/2+90/zoom, 148/zoom, 39/zoom, "ROZPOCZNIJ", 0, 10/zoom, false, false, ":px_mechanic_duty/assets/images/button_start.png")
        UI.btns[2]=buttons:createButton(sw/2+10/zoom, sh/2+90/zoom, 148/zoom, 39/zoom, "ANULUJ", 0, 10/zoom, false, false, ":px_mechanic_duty/assets/images/button_close.png", {132,39,39})

        animate(UI.alpha, 255, "Linear", 200, function(a)
            UI.alpha=a
            UI.mainAlpha=a

            buttons:buttonSetAlpha(UI.btns[1], a)
            buttons:buttonSetAlpha(UI.btns[2], a)
        end)

        UI.border=1
    else
        showCursor(false)

        animate(UI.alpha, 0, "Linear", 200, function(a)
            UI.alpha=a
            UI.mainAlpha=a

            buttons:buttonSetAlpha(UI.btns[1], a)
            buttons:buttonSetAlpha(UI.btns[2], a)
        end, function()
            removeEventHandler("onClientRender", root, UI.onRender)

            buttons:destroyButton(UI.btns[1])
            buttons:destroyButton(UI.btns[2])

            assets.destroy()
        end)

        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end
addEvent("ui.open", true)
addEventHandler("ui.open", resourceRoot, function(name,q,city) UI.tag=name; UI.city=city; UI.toggleUI(true,q) end)

-- click

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
	if(not isCursorShowing())then return end

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

-- animate

anims = {}
rendering = false

function renderAnimations()
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

-- on stop

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end

addEventHandler("onClientPlayerWasted", localPlayer, function()
    local data=getElementData(localPlayer, "user:job_settings")
    if(data)then
        if(data.job_name == "Mechanik" or data.job_name == "Tuner" or data.job_name == "Lakiernik")then
            triggerServerEvent("last.skin", resourceRoot)
        end
    end
end)