--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local buttons=exports.px_buttons
local noti=exports.px_noti
local blur=exports.blur

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 17},
        {":px_assets/fonts/Font-Medium.ttf", 15},
        {":px_assets/fonts/Font-Regular.ttf", 13},
        {":px_assets/fonts/Font-Regular.ttf", 13},
    },

    textures={},
    textures_paths={
        "assets/images/window.png",
        "assets/images/window_icon.png",
        "assets/images/wyplata.png",
        "assets/images/ranga.png",
        "assets/images/button_close.png",
        "assets/images/button_start.png",
    },
}

DUTY={}
DUTY.info={}
DUTY.buttons={}
DUTY.alpha=0

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

DUTY.onRender=function()
    blur:dxDrawBlur(sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom, 294/zoom, tocolor(255, 255, 255, DUTY.alpha))
    dxDrawImage(sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom, 294/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, DUTY.alpha))

    dxDrawText("Służba", sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-294/2/zoom+55/zoom, tocolor(200, 200, 200, DUTY.alpha), 1, assets.fonts[1], "center", "center")
    local w=dxGetTextWidth("Służba", 1, assets.fonts[1])
    dxDrawImage(sw/2-557/2/zoom+(557/2)/zoom+w/2+10/zoom, sh/2-294/2/zoom+19/zoom, 23/zoom, 20/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, DUTY.alpha))
 
    dxDrawRectangle(sw/2-518/2/zoom, sh/2-294/2/zoom+55/zoom, 518/zoom, 1, tocolor(85, 85, 85, DUTY.alpha))

    local faction = getElementData(localPlayer, "user:faction")
    if(faction == DUTY.info[1])then
        buttons:buttonSetText(DUTY.buttons[1], "ZAKOŃCZ")
        opis = "Czy na pewno chcesz zakończyć\nsłużbę we frakcji o tagu #7cd8fd"..DUTY.info[1].."#cccccc?"
    else
        buttons:buttonSetText(DUTY.buttons[1], "ROZPOCZNIJ")
        opis = "Czy na pewno chcesz rozpocząć\nsłużbę we frakcji o tagu #7cd8fd"..DUTY.info[1].."#cccccc?"
    end
    dxDrawText(opis, sw/2-557/2/zoom, sh/2-294/2/zoom+90/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-294/2/zoom+250/zoom, tocolor(200, 200, 200, DUTY.alpha), 1, assets.fonts[3], "center", "top", false, false, false, true)

    dxDrawImage(sw/2-557/2/zoom+222/zoom+100/zoom, sh/2-294/2/zoom+165/zoom, 46/zoom, 46/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, DUTY.alpha))
    dxDrawText(DUTY.info[2].rank, sw/2-557/2/zoom+280/zoom+100/zoom, sh/2-294/2/zoom+165/zoom, 46/zoom, 46/zoom+sh/2-294/2/zoom+165/zoom, tocolor(200, 200, 200, DUTY.alpha), 1, assets.fonts[3], "left", "center")
    
    dxDrawImage(sw/2-557/2/zoom+222/zoom-100/zoom, sh/2-294/2/zoom+165/zoom, 46/zoom, 46/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, DUTY.alpha))
    dxDrawText(convertNumber(DUTY.info[2].payment).."$/h", sw/2-557/2/zoom+280/zoom-100/zoom, sh/2-294/2/zoom+165/zoom, 46/zoom, 46/zoom+sh/2-294/2/zoom+165/zoom, tocolor(200, 200, 200, DUTY.alpha), 1, assets.fonts[3], "left", "center")

    onClick(sw/2-148/zoom-10/zoom, sh/2+90/zoom, 148/zoom, 39/zoom, function()
        if(SPAM.getSpam())then return end
        
        local faction = getElementData(localPlayer, "user:faction")
        if(faction == DUTY.info[1])then
            exports.px_blips:load_blips("group", true)

            noti:noti("Zakończyłeś służbę w "..DUTY.info[1]..".")

            setElementData(localPlayer, "user:faction", false)
            setElementData(localPlayer, "user:job_settings", false)

            triggerServerEvent("stop.duty", resourceRoot, DUTY.info[1])
        elseif(faction)then
            noti:noti("Pracujesz już w innej pracy.")
        else
            noti:noti("Rozpocząłeś służbę w "..DUTY.info[1]..".")

            exports.px_blips:load_blips("group")

            setElementData(localPlayer, "user:faction", DUTY.info[1])
            setElementData(localPlayer, "user:job_settings", {
                job_name=DUTY.info[2].rank,
                job_tag=DUTY.info[1],
                job_hour_money=DUTY.info[2].payment,
                job_add_hour_money=true,
                police=true
            })

            triggerServerEvent("start.duty", resourceRoot, DUTY.info[1])
        end

        animate(DUTY.alpha, 0, "Linear", 200, function(a)
            DUTY.alpha=a
    
            buttons:buttonSetAlpha(DUTY.buttons[1], a)
            buttons:buttonSetAlpha(DUTY.buttons[2], a)
        end, function()
            removeEventHandler("onClientRender", root, DUTY.onRender)

            DUTY.info={}
    
            assets.destroy()
    
            showCursor(false)
    
            for i = 1,#DUTY.buttons do
                buttons:destroyButton(DUTY.buttons[i])
            end
    
            setElementData(localPlayer, "user:gui_showed", false, false)
        end)
    end)

    onClick(sw/2+10/zoom, sh/2+90/zoom, 148/zoom, 39/zoom, function()
        animate(DUTY.alpha, 0, "Linear", 200, function(a)
            DUTY.alpha=a
    
            buttons:buttonSetAlpha(DUTY.buttons[1], a)
            buttons:buttonSetAlpha(DUTY.buttons[2], a)
        end, function()
            removeEventHandler("onClientRender", root, DUTY.onRender)

            DUTY.info={}
    
            assets.destroy()
    
            showCursor(false)
    
            for i = 1,#DUTY.buttons do
                buttons:destroyButton(DUTY.buttons[i])
            end
    
            setElementData(localPlayer, "user:gui_showed", false, false)
        end)
    end)
end

addEvent("open:duty_gui", true)
addEventHandler("open:duty_gui", resourceRoot, function(name, data)
    if(getElementData(localPlayer, "user:gui_showed"))then return end

    if(getElementData(localPlayer, "user:job"))then
        noti = exports.px_noti
        noti:noti("Aktualnie pracujesz w innej pracy.")
        return
    end

    buttons=exports.px_buttons
    blur=exports.blur
    weapons=exports["px_back-weapons"]

    DUTY.info={name,data}

    assets.create()

    addEventHandler("onClientRender", root, DUTY.onRender)

    showCursor(true)

    local faction = getElementData(localPlayer, "user:faction")
    DUTY.buttons[1]=buttons:createButton(sw/2-148/zoom-10/zoom, sh/2+90/zoom, 148/zoom, 39/zoom, "ROZPOCZNIJ", 0, 10/zoom, false, false, ":px_factions/assets/images/button_start.png")
    DUTY.buttons[2]=buttons:createButton(sw/2+10/zoom, sh/2+90/zoom, 148/zoom, 39/zoom, "ANULUJ", 0, 10/zoom, false, false, ":px_factions/assets/images/button_close.png", {132,39,39})

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    animate(DUTY.alpha, 255, "Linear", 200, function(a)
        DUTY.alpha=a

        buttons:buttonSetAlpha(DUTY.buttons[1], a)
        buttons:buttonSetAlpha(DUTY.buttons[2], a)
    end)
end)

-- useful function created by Asper

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

-- click

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

--

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

--

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)

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