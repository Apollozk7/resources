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
        exports.px_exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

-- variables

local sw, sh = guiGetScreenSize()
local baseX = 1920
local zoom = 1
local minZoom = 2

if sw < baseX then
    zoom = math.min(minZoom, baseX/sw)
end

local blur=exports.blur

ATM = {}

ATM.fnts = {
	{":px_assets/fonts/Font-Bold.ttf", 12/zoom},
	{":px_assets/fonts/Font-Medium.ttf", 11/zoom},
	{":px_assets/fonts/Font-Bold.ttf", 14/zoom},
}

ATM.FONTS = {}

ATM.textures = {
	"assets/images/window.png",
	"assets/images/close.png",
}

ATM.img = {}

ATM.ATM_MONEY = 0
ATM.alpha = 0

ATM.animate = false
ATM.shape = false

ATM.edit=false
ATM.btns={}

-- creating, update ATM money

ATM.UPDATE_ATM_MONEY = function(ATM_money)
	if tonumber(ATM_money) then
		ATM.ATM_MONEY = ATM_money
	end
end
addEvent("ATM.UPDATE_ATM_MONEY", true)
addEventHandler("ATM.UPDATE_ATM_MONEY", resourceRoot, ATM.UPDATE_ATM_MONEY)

ATM.CREATE_GUI = function(type, shape, transactions, pin)
	if(type == "HIT" and not getElementData(localPlayer, "user:gui_showed") and not ATM.animate)then
		if(getElementData(localPlayer, "user:gui_showed"))then return end

		blur=exports.blur

		ATM.shape = shape

		setElementData(localPlayer, "user:gui_showed", 'bankomat', false)

		for i,v	in pairs(ATM.fnts) do
			ATM.FONTS[i] = dxCreateFont(v[1], v[2])
		end

		for i,v in pairs(ATM.textures) do
			ATM.img[i] = dxCreateTexture(v, "argb", false, "clamp")
		end

		addEventHandler("onClientRender", root, ATM.DRAW_UI)

		ATM.edit=exports.px_editbox:dxCreateEdit("Kwota", sw/2-315/2/zoom, sh-120/zoom, 315/zoom, 28/zoom, false, 11/zoom, 0, true, false, ":px_atm/assets/images/edit.png")
		ATM.btns={
			exports.px_buttons:createButton(sw/2-150/2/zoom-150/2/zoom-7/zoom, sh-78/zoom, 150/zoom, 28/zoom, "WPŁATA", 0, 10, false, false, false),
			exports.px_buttons:createButton(sw/2-150/2/zoom+150/2/zoom+7/zoom, sh-78/zoom, 150/zoom, 28/zoom, "WYPŁATA", 0, 10, false, false, false, {33,124,147})
		}

		showCursor(true)

		ATM.animate = true
		animate(ATM.alpha, 255, "Linear", 500, function(a)
			ATM.alpha = a

			exports.px_editbox:dxSetEditAlpha(ATM.edit,a)
			
			for i,v in pairs(ATM.btns) do
				exports.px_buttons:buttonSetAlpha(v, a)
			end
		end, function()
			ATM.animate = false
		end)
	elseif(type == "LEAVE" and not ATM.animate)then
		showCursor(false)

		ATM.animate = true
		animate(ATM.alpha, 0, "Linear", 500, function(a)
			ATM.alpha = a

			exports.px_editbox:dxSetEditAlpha(ATM.edit,a)

			for i,v in pairs(ATM.btns) do
				exports.px_buttons:buttonSetAlpha(v, a)
			end
		end, function()
			ATM.animate = false

			setElementData(localPlayer, "user:gui_showed", false, false)

			removeEventHandler("onClientRender", root, ATM.DRAW_UI)

			for i,v in pairs(ATM.img) do
				checkAndDestroy(v)
			end

			for i,v in pairs(ATM.FONTS) do
				checkAndDestroy(v)
			end

			exports.px_editbox:dxDestroyEdit(ATM.edit)
			ATM.edit=false

			for i,v in pairs(ATM.btns) do
				exports.px_buttons:destroyButton(v)
			end
			ATM.btns=false
		end)
	end
end
addEvent("ATM.CREATE_GUI", true)
addEventHandler("ATM.CREATE_GUI", resourceRoot, ATM.CREATE_GUI)

-- drawing

ATM.DRAW_UI = function()
	if(ATM.shape)then
		if(getElementType(ATM.shape) == "colshape" and not isElementWithinColShape(localPlayer, ATM.shape))then
			ATM.CREATE_GUI("LEAVE")
		elseif(getElementType(ATM.shape) == "marker" and not isElementWithinMarker(localPlayer, ATM.shape))then
			ATM.CREATE_GUI("LEAVE")
		end
	end

	blur:dxDrawBlur(sw/2-346/2/zoom, sh-240/zoom, 346/zoom, 205/zoom, tocolor(255,255,255,ATM.alpha))
	dxDrawImage(sw/2-346/2/zoom, sh-240/zoom, 346/zoom, 205/zoom, ATM.img[1], 0, 0, 0, tocolor(255,255,255,ATM.alpha))
	dxDrawText('Bankomat', sw/2-346/2/zoom+15/zoom, sh-240/zoom, 0, sh-240/zoom+42/zoom, tocolor(222, 222, 222, ATM.alpha), 1, ATM.FONTS[1], 'left', 'center')
	dxDrawRectangle(sw/2-346/2/zoom, sh-240/zoom+41/zoom, 346/zoom, 1, tocolor(80,80,80,ATM.alpha))
	dxDrawImage(sw/2-346/2/zoom+346/zoom-15/zoom-10/zoom, sh-240/zoom+(42-10)/2/zoom, 10/zoom, 10/zoom, ATM.img[2], 0, 0, 0, tocolor(255,255,255,ATM.alpha))

	dxDrawText('Stan twojego konta wynosi:', sw/2-346/2/zoom+15/zoom, sh-240/zoom+56/zoom, 0, 0, tocolor(175, 175, 175, ATM.alpha), 1, ATM.FONTS[2], 'left', 'top')
	dxDrawText(convertNumber(ATM.ATM_MONEY)..' $', sw/2-346/2/zoom+15/zoom, sh-240/zoom+77/zoom, 0, 0, tocolor(75, 187, 75, ATM.alpha), 1, ATM.FONTS[3], 'left', 'top')

	onClick(sw/2-150/2/zoom-150/2/zoom-7/zoom, sh-78/zoom, 150/zoom, 28/zoom, function()
		-- wplata
		local kwota=exports.px_editbox:dxGetEditText(ATM.edit)
		if(#kwota > 0 and #kwota < 10 and tonumber(kwota))then
			kwota=tonumber(kwota)
			kwota=math.floor(kwota)

			if((kwota < 1 or kwota > 1000000000) and getPlayerMoney(localPlayer) < kwota)then
				exports.px_noti:noti("Wprowadziłeś błędną wartość.", "error")
			else
				triggerServerEvent("ATM.ACTIONS", resourceRoot, "deposit", kwota)
			end
		else
			exports.px_noti:noti("Wprowadziłeś błędną wartość.", "error")
		end
	end)

	onClick(sw/2-150/2/zoom+150/2/zoom+7/zoom, sh-78/zoom, 150/zoom, 28/zoom, function()
		-- wyplata
		local kwota=exports.px_editbox:dxGetEditText(ATM.edit)
		if(#kwota > 0 and #kwota < 10 and tonumber(kwota))then
			kwota=tonumber(kwota)
			kwota=math.floor(kwota)

			if((kwota < 1 or kwota > 1000000000) and kwota > tonumber(ATM.ATM_MONEY))then
				exports.px_noti:noti("Wprowadziłeś błędną wartość.", "error")
			else
				triggerServerEvent("ATM.ACTIONS", resourceRoot, "withdraw", kwota)
			end
		else
			exports.px_noti:noti("Wprowadziłeś błędną wartość.", "error")
		end
	end)

	onClick(sw/2-346/2/zoom+346/zoom-15/zoom-10/zoom, sh-240/zoom+(42-10)/2/zoom, 10/zoom, 10/zoom, function()
		ATM.CREATE_GUI('LEAVE')
	end)
end

-- anty breakable

setObjectBreakable(resourceRoot, false)

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

			playSound("assets/sounds/click.mp3")

			mouseClicks=mouseClicks+1
            mouseTick=getTickCount()
            mouseClick=true
        end
	end
end

-- useful

function checkAndDestroy(element)
	if(element and isElement(element))then
		destroyElement(element)
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

-- on stop

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == 'bankomat')then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)

local gui = getElementData(localPlayer, "user:gui_showed")
if(gui and gui == 'bankomat')then
	setElementData(localPlayer, "user:gui_showed", false, false)
end

-- trigger

addEvent("playSound3D", true)
addEventHandler("playSound3D", resourceRoot, function(x, y, z)
	local sound=playSound3D("assets/sounds/ATM_3D.mp3", x, y, z)
	setSoundMaxDistance(sound, 5)
end)