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

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local buttons=exports.px_buttons
local noti=exports.px_noti
local blur=exports.blur

-- main variables

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Regular.ttf", 15},
        {":px_assets/fonts/Font-Regular.ttf", 13},
        {":px_assets/fonts/Font-Regular.ttf", 11},
        {":px_assets/fonts/Font-Medium.ttf", 11},
    },

    textures={},
    textures_paths={
        "assets/images/window.png",
        "assets/images/header_icon.png",
        "assets/images/close.png",
    
        "assets/images/circle.png",

        "assets/images/icon_money.png",
        "assets/images/icon_time.png",
        "assets/images/icon_rank.png",
        "assets/images/icon_wallet.png",
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

local UI={}

UI.infos={}
UI.row=0
UI.alpha=0
UI.mainAlpha=0
UI.btns={}
UI.window=false
UI.border=1
UI.pos={0,0}

UI.payments={
    {name="Frakcja",payment=0,time=0,type="faction"},
    {name="Biznes",payment=0,time=0,type="busi"},
}

UI.getBorder=function(id)
    for i=1,2 do
        local text=i == 1 and "Służby mundurowe" or i == 2 and "Działalności gospodarcze"
        local w=dxGetTextWidth(text, 1, assets.fonts[2])
        local sX=0
        if(i == 1)then
            sX=-100/zoom
        elseif(i == 2)then
            sX=100/zoom
        end

        if(i == id)then
            return sw/2-557/2/zoom+(557-w)/2/zoom+sX, w
        end
    end
    return sw/2-557/2/zoom,73/zoom
end

UI.onRender=function()
    blur:dxDrawBlur(sw/2-564/2/zoom, sh/2-401/2/zoom, 564/zoom, 401/zoom, tocolor(255, 255, 255, UI.alpha))
    dxDrawImage(sw/2-564/2/zoom, sh/2-401/2/zoom, 564/zoom, 401/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
    dxDrawText("Twoje wypłaty", sw/2-564/2/zoom, sh/2-401/2/zoom, 564/zoom+sw/2-564/2/zoom, sh/2-401/2/zoom+55/zoom+1, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[1], "center", "center")

    dxDrawImage(sw/2-564/2/zoom+564/2/zoom+dxGetTextWidth("Twoje wypłaty", 1, assets.fonts[1])/2+10/zoom, sh/2-401/2/zoom+(55-23)/2/zoom, 23/zoom, 23/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))

    dxDrawImage(sw/2-517/2/zoom+517/zoom-10/zoom, sh/2-401/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, UI.alpha))
    onClick(sw/2-517/2/zoom+517/zoom-10/zoom, sh/2-401/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, function()
        showCursor(false)
        animate(UI.alpha, 0, "Linear", 500, function(a)
            UI.alpha=a
            UI.mainAlpha=a

            buttons:buttonSetAlpha(UI.btns[1], a)
        end, function()
            assets.destroy()
            removeEventHandler("onClientRender", root, UI.onRender)

            buttons:destroyButton(UI.btns[1])
        end)
    end)

    dxDrawRectangle(sw/2-517/2/zoom, sh/2-401/2/zoom+55/zoom, 517/zoom, 1, tocolor(85,85,85, UI.alpha))

    for i=1,2 do
        local text=i == 1 and "Służby mundurowe" or i == 2 and "Działalności gospodarcze"
        local w=dxGetTextWidth(text, 1, assets.fonts[2])
        local sX=0
        if(i == 1)then
            sX=-100/zoom
        elseif(i == 2)then
            sX=100/zoom
        end

        dxDrawText(text, sw/2-557/2/zoom+(557-w)/2/zoom+sX, sh/2-401/2/zoom+55/zoom+20/zoom, w+sw/2-557/2/zoom+(557-w)/2/zoom+sX, 30/zoom+sh/2-294/2/zoom+65/zoom, tocolor(200, 200, 200, UI.alpha), 1, assets.fonts[2], "center", "top")

        onClick(sw/2-557/2/zoom+(557-w)/2/zoom+sX, sh/2-401/2/zoom+55/zoom+20/zoom, w, 25/zoom, function()
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
                    buttons:buttonSetAlpha(UI.btns[1], a)
                end, function()
                    UI.border=i
                    animate(UI.mainAlpha, 255, "Linear", 250, function(a)
                        UI.mainAlpha=a
                        buttons:buttonSetAlpha(UI.btns[1], a)
                    end, function()
                        UI.animate=false
                    end)
                end)
            end
        end)
    end

    local x,w=unpack(UI.pos)
    dxDrawRectangle(x, sh/2-401/2/zoom+55/zoom+45/zoom, w, 1, tocolor(39, 119, 170, UI.alpha))
    
    dxDrawRectangle(sw/2-453/2/zoom, sh/2-401/2/zoom+175/zoom, 453/zoom, 1, tocolor(85,85,85, UI.mainAlpha))

    local text=UI.border == 1 and "faction" or UI.border == 2 and "busi"
    local info=UI.infos[text]
    if(info)then
        local money=info[1] or 0
        local time=info[2] or 0
        local faction=info[3] or "brak"
        local rank=info[4] or "brak"
        local payment=info[5] or 0

        local hours = math.floor(time/60)
        local minutes = math.floor(time-(hours*60))
        time=(hours > 0 and hours.."h " or "")..(minutes > 0 and minutes.."m" or "0m")

        onClick(sw/2-140/2/zoom, sh/2+140/zoom, 140/zoom, 37/zoom, function()
            if(money > 0)then
                if(SPAM.getSpam())then return end

                triggerServerEvent("get.payment", resourceRoot, money, time, UI.border, info[2])

                showCursor(false)
                animate(UI.alpha, 0, "Linear", 500, function(a)
                    UI.alpha=a
                    UI.mainAlpha=a

                    buttons:buttonSetAlpha(UI.btns[1], a)
                end, function()
                    assets.destroy()
                    removeEventHandler("onClientRender", root, UI.onRender)

                    buttons:destroyButton(UI.btns[1])
                end)
            else
                noti:noti("Miminalna stawka do odebrania wynosi 1$.", "error")
            end
        end)

        if(UI.border == 1)then
            dxDrawText("#c2c2c2Pieniądze, które zarobiłeś podczas zatrudnienia w #78d0fdfrakcji#c2c2c2.\nAby je odebrać naciśnij przycisk #4ea565odbierz#c2c2c2.", sw/2-564/2/zoom, sh/2-401/2/zoom+55/zoom+67/zoom, 564/zoom+sw/2-564/2/zoom, sh/2-401/2/zoom+55/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "center", "top", false, false, false, true)

            dxDrawImage(sw/2-453/2/zoom, sh/2-401/2/zoom+175/zoom+17/zoom, 50/zoom, 50/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawImage(sw/2-453/2/zoom+(50-21)/2/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+(50-24)/2/zoom, 21/zoom, 24/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawText("Stanowisko pracy", sw/2-453/2/zoom+62/zoom, sh/2-401/2/zoom+175/zoom+17/zoom-20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(rank, sw/2-453/2/zoom+62/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "left", "center")

            dxDrawImage(sw/2-453/2/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+17/zoom, 50/zoom, 50/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawImage(sw/2-453/2/zoom+255/zoom+(50-20)/2/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+(50-20)/2/zoom, 20/zoom, 20/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawText("Stawka na godzine", sw/2-453/2/zoom+62/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+17/zoom-20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(convertNumber(payment).."$/h", sw/2-453/2/zoom+62/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "left", "center")
        
            dxDrawImage(sw/2-453/2/zoom, sh/2-401/2/zoom+175/zoom+90/zoom, 50/zoom, 50/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawImage(sw/2-453/2/zoom+(50-24)/2/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+(50-24)/2/zoom, 24/zoom, 24/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawText("Przepracowany czas", sw/2-453/2/zoom+62/zoom, sh/2-401/2/zoom+175/zoom+90/zoom-20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(time, sw/2-453/2/zoom+62/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "left", "center")

            dxDrawImage(sw/2-453/2/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+90/zoom, 50/zoom, 50/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawImage(sw/2-453/2/zoom+255/zoom+(50-24)/2/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+(50-18)/2/zoom, 24/zoom, 18/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawText("Zarobione pieniądze", sw/2-453/2/zoom+62/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+90/zoom-20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(convertNumber(money).."$", sw/2-453/2/zoom+62/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "left", "center")
        elseif(UI.border == 2)then
            dxDrawText("#c2c2c2Pieniądze, które zarobiłeś podczas zatrudnienia w #78d0fdbiznesie#c2c2c2.\nAby je odebrać naciśnij przycisk #4ea565odbierz#c2c2c2.", sw/2-564/2/zoom, sh/2-401/2/zoom+55/zoom+67/zoom, 564/zoom+sw/2-564/2/zoom, sh/2-401/2/zoom+55/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "center", "top", false, false, false, true)

            dxDrawImage(sw/2-453/2/zoom, sh/2-401/2/zoom+175/zoom+17/zoom, 50/zoom, 50/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawImage(sw/2-453/2/zoom+(50-21)/2/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+(50-24)/2/zoom, 21/zoom, 24/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawText("Stanowisko pracy", sw/2-453/2/zoom+62/zoom, sh/2-401/2/zoom+175/zoom+17/zoom-20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(rank, sw/2-453/2/zoom+62/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "left", "center")

            dxDrawImage(sw/2-453/2/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+17/zoom, 50/zoom, 50/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawImage(sw/2-453/2/zoom+255/zoom+(50-20)/2/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+(50-20)/2/zoom, 20/zoom, 20/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawText("Stawka na godzine", sw/2-453/2/zoom+62/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+17/zoom-20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(convertNumber(payment).."$/h", sw/2-453/2/zoom+62/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+17/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "left", "center")
        
            dxDrawImage(sw/2-453/2/zoom, sh/2-401/2/zoom+175/zoom+90/zoom, 50/zoom, 50/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawImage(sw/2-453/2/zoom+(50-24)/2/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+(50-24)/2/zoom, 24/zoom, 24/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawText("Przepracowany czas", sw/2-453/2/zoom+62/zoom, sh/2-401/2/zoom+175/zoom+90/zoom-20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(time, sw/2-453/2/zoom+62/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "left", "center")

            dxDrawImage(sw/2-453/2/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+90/zoom, 50/zoom, 50/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawImage(sw/2-453/2/zoom+255/zoom+(50-24)/2/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+(50-18)/2/zoom, 24/zoom, 18/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, UI.mainAlpha))
            dxDrawText("Zarobione pieniądze", sw/2-453/2/zoom+62/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+90/zoom-20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[4], "left", "center")
            dxDrawText(convertNumber(money).."$", sw/2-453/2/zoom+62/zoom+255/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+20/zoom, 50/zoom, sh/2-401/2/zoom+175/zoom+90/zoom+50/zoom, tocolor(200, 200, 200, UI.mainAlpha), 1, assets.fonts[3], "left", "center")
        end
    end
end

-- triggers

addEvent("payments.open", true)
addEventHandler("payments.open", resourceRoot, function(info)
    buttons=exports.px_buttons
    noti=exports.px_noti
    blur=exports.blur

    UI.infos=info

    assets.create()

    showCursor(true)
    addEventHandler("onClientRender", root, UI.onRender)

    UI.pos={UI.getBorder(1)}
    UI.border=1

    UI.btns[1]=buttons:createButton(sw/2-140/2/zoom, sh/2+140/zoom, 140/zoom, 37/zoom, "ODBIERZ", 0, 10/zoom, false, false, ":px_payments/assets/images/button_icon.png")

    UI.alpha=0
    UI.mainAlpha=0
    animate(UI.alpha, 255, "Linear", 500, function(a)
        UI.alpha=a
        UI.mainAlpha=a
        buttons:buttonSetAlpha(UI.btns[1], a)
    end)

    UI.selectedOption=false
end)

-- useful function created by Asper

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
