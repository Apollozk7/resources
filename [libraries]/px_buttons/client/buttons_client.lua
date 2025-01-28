--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local BUTTONS = {}

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

BUTTONS.table = {}
BUTTONS.img = {}
BUTTONS.resources = {}

function dxDrawButton(x,y,w,h,color,postGUI)
	local px=2
	h=h-px

	local pos={
		{x,y,w,px},
		{x,y,px,h},
		{x,y+h,w,px},
		{x+w-px,y,px,h}
	}

	for i,v in pairs(pos) do
		dxDrawImage(v[1], v[2], v[3], v[4], BUTTONS.img[4], 0, 0, 0, color, postGUI)
	end
end

BUTTONS.onRender = function()
	for i,v in pairs(BUTTONS.table) do
		local w,h=v.pos[3]*1.69,v.pos[4]*3.6
		local ww,hh=v.pos[3]*1.16,v.pos[4]*1.64

		if(not v.onlyEffect)then
			local alpha=v.mainAlpha
			dxDrawImage(v.pos[1], v.pos[2], v.pos[3], v.pos[4], BUTTONS.img[2], 0, 0, 0, tocolor(v.color[1], v.color[2], v.color[3], alpha), v.postGui)
			dxDrawButton(v.pos[1], v.pos[2], v.pos[3], v.pos[4], tocolor(v.color[1], v.color[2], v.color[3], alpha), v.postGui)
			dxDrawImage(v.pos[1]+(v.pos[3]-w)/2, v.pos[2]+(v.pos[4]-h)/2, w, h, BUTTONS.img[3], 0, 0, 0, tocolor(v.color[1], v.color[2], v.color[3], v.mainAlpha > v.progress and v.progress or v.mainAlpha), v.postGui)
		end

		if(v.clickTick)then
			if(v.back)then
				v.alpha = interpolateBetween(v.alpha, 0, 0, 0, 0, 0, (getTickCount()-v.clickTick)/300, "Linear")

				if((getTickCount()-v.clickTick) > 300)then
					v.clickTick = nil
				end
			else
				v.size = interpolateBetween(0, 0, 0, (v.pos[3]*2)+v.pos[4], 0, 0, (getTickCount()-v.clickTick)/500, "Linear")
				v.alpha = interpolateBetween(0, 0, 0, 50, 0, 0, (getTickCount()-v.clickTick)/10, "Linear")

				if((getTickCount()-v.clickTick) > 500)then
					v.back = true
					v.clickTick = getTickCount()
				end
			end

			dxSetRenderTarget(v.target, true)
				dxDrawImage(v.posX-v.size/2, v.posY-v.size/2, v.size, v.size, BUTTONS.img[1], 0, 0, 0, tocolor(255, 255, 255, 150), false)
			dxSetRenderTarget()

			local color=(v.onlyEffect and v.onlyEffect[1]) and v.onlyEffect or {29, 29, 39}
			dxDrawImage(v.pos[1], v.pos[2], v.pos[3], v.pos[4], v.target, 0, 0, 0, tocolor(color[1], color[2], color[3], v.mainAlpha > v.alpha and v.alpha or v.mainAlpha), v.postGui)
		end

		if(not v.onlyEffect)then
			if(v.icon)then
				if(#v.text < 1)then
					dxDrawImage(v.pos[1]+(v.pos[3]-17/zoom)/2, v.pos[2]+(v.pos[4]-11/zoom)/2, 17/zoom, 11/zoom, v.icon, 0, 0, 0, tocolor(255, 255, 255, v.mainAlpha), v.postGui)
				else
					local w,h=dxGetMaterialSize(v.icon)
					local distance=4/zoom
					local width=dxGetTextWidth(string.upper(v.text), 1, v.font)
					w,h=w/zoom,h/zoom

					dxDrawText(string.upper(v.text), v.pos[1]+(v.pos[3]-width)/2+w/2/zoom+distance/2+1, v.pos[2]+1, 0, v.pos[2]+v.pos[4]+1, tocolor(0, 0, 0, v.mainAlpha), 1, v.font, "left", "center", false, false, v.postGui)
					dxDrawText(string.upper(v.text), v.pos[1]+(v.pos[3]-width)/2+w/2/zoom+distance/2, v.pos[2], 0, v.pos[2]+v.pos[4], tocolor(255, 255, 255, v.mainAlpha), 1, v.font, "left", "center", false, false, v.postGui)
					dxDrawImage(v.pos[1]+(v.pos[3]-width)/2-w/2/zoom-distance/2, v.pos[2]+(v.pos[4]/2-h/2), w, h, v.icon, 0, 0, 0, tocolor(255, 255, 255, v.mainAlpha), v.postGui)
				end
			else
				dxDrawText(string.upper(v.text), v.pos[1]+(v.pos[3]-w)/2+1, v.pos[2]+(v.pos[4]-h)/2+1, v.pos[1]+(v.pos[3]-w)/2+w+1, v.pos[2]+(v.pos[4]-h)/2+h+1, tocolor(0, 0, 0, v.mainAlpha), 1, v.font, "center", "center", false, false, v.postGui)
				dxDrawText(string.upper(v.text), v.pos[1]+(v.pos[3]-w)/2, v.pos[2]+(v.pos[4]-h)/2, v.pos[1]+(v.pos[3]-w)/2+w, v.pos[2]+(v.pos[4]-h)/2+h, tocolor(255, 255, 255, v.mainAlpha), 1, v.font, "center", "center", false, false, v.postGui)
			end
		end

		if(isMouseInPosition(v.pos[1], v.pos[2], v.pos[3], v.pos[4]))then
			if(not v.onMouse)then
				playSound("assets/sounds/hover.mp3")

				v.onMouse = true

				animate(v.progress, 255, "Linear", 300, function(a)
					if(v.onMouse)then
						v.progress = a
					end
				end)
			end

			onClick(v.pos[1], v.pos[2], v.pos[3], v.pos[4], function()
				playSound("assets/sounds/click.mp3")

				v.clickTick = getTickCount()
				v.back = false

				local cX, cY = getCursorPosition()
				cX,cY = cX*sw,cY*sh
				v.posX, v.posY = cX-v.pos[1], cY-v.pos[2]
			end)
		elseif(not isMouseInPosition(v.pos[1], v.pos[2], v.pos[3], v.pos[4]))then
			if(v.onMouse)then
				v.onMouse = false

				animate(v.progress, 0, "Linear", 300, function(a)
					if(not v.onMouse)then
						v.progress = a
					end
				end)
			end
		end
	end
end

function buttonSetColor(id,color)
	if(BUTTONS.table[id])then
		BUTTONS.table[id].color=color or {62,145,88}
		return true
	end
	return false
end

BUTTONS.create = function(x, y, w, h, text, alpha, fontSize, onlyEffect, postGui, icon, color)
	if(icon and fileExists(icon))then
		icon=dxCreateTexture(icon, "argb", false, "clamp")
	else
		icon=nil
	end

	table.insert(BUTTONS.table, {
		onlyEffect=onlyEffect, 
		pos={x,y,w,h}, 
		text=text, 
		color=color or {62,145,88}, 
		icon=icon, 
		progress=0, 
		onMouse=false, 
		click=false, 
		target=dxCreateRenderTarget(w, h, true), 
		size=0, 
		posX=0, 
		posY=0, 
		alpha=255, 
		mainAlpha=alpha or 255, 
		clickTick=false, 
		back=false, 
		postGui=postGui,
		font=dxCreateFont(":px_assets/fonts/Font-Bold.ttf", (fontSize or 15)/zoom)
	})

	if(#BUTTONS.table == 1)then
		addEventHandler("onClientRender", root, BUTTONS.onRender)

		BUTTONS.img[1] = dxCreateTexture("assets/images/circle.png", "argb", false, "clamp")
		BUTTONS.img[2] = dxCreateTexture("assets/images/button_1.png", "argb", false, "clamp")
		BUTTONS.img[3] = dxCreateTexture("assets/images/button_2.png", "argb", false, "clamp")
		BUTTONS.img[4] = dxCreateTexture("assets/images/line.png", "argb", false, "clamp")
	end

	if(sourceResource)then
		-- if source resource stop then destroy buttons
		BUTTONS.resources[sourceResource] = true
		BUTTONS.table[#BUTTONS.table].resource = sourceResource
		addEventHandler("onClientResourceStop", getResourceRootElement(sourceResource), function(resource)
			for i,v in pairs(BUTTONS.table) do
				if(v.resource == resource)then
					BUTTONS.destroy(i)
				end
			end
			BUTTONS.resources[resource] = nil
		end)
	end

    return #BUTTONS.table
end

BUTTONS.destroy = function(id)
	if(BUTTONS.table[id])then
		if(BUTTONS.table[id].font and isElement(BUTTONS.table[id].font))then
			destroyElement(BUTTONS.table[id].font)
		end

		if(BUTTONS.table[id].target and isElement(BUTTONS.table[id].target))then
			destroyElement(BUTTONS.table[id].target)
		end

		BUTTONS.table[id] = nil
	end

	if(#BUTTONS.table == 0)then
		removeEventHandler("onClientRender", root, BUTTONS.onRender)

		for i,v in pairs(BUTTONS.img) do
			if(v and isElement(v))then
				destroyElement(v)
				BUTTONS.img[i] = nil
			end
		end

		BUTTONS.resources = {}
	end
end

BUTTONS.setPosition = function(id, pos)
	if(BUTTONS.table[id])then
		BUTTONS.table[id].pos[1], BUTTONS.table[id].pos[2] = pos[1], pos[2]
	end
end

BUTTONS.setAlpha = function(id, a)
	if(BUTTONS.table[id])then
		BUTTONS.table[id].mainAlpha = a
	end
end

function createButton(...)
	return BUTTONS.create(...)
end
--createButton(sw/2, sh/5, 200, 50, "Testowy przycisk :)", 255, 10, false, false, ":px_interaction/textures/hands/accept_button.png")
--showCursor(true, false)

function destroyButton(...)
	BUTTONS.destroy(...)
end

function buttonSetAlpha(...)
	BUTTONS.setAlpha(...)
end

function buttonSetPosition(...)
	BUTTONS.setPosition(...)
end

function buttonSetText(id, text)
	if(BUTTONS.table[id])then
		BUTTONS.table[id].text=text
	end
end

-- animation

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

--[[BUTTONS.create(sw/2, sh/2, 200/zoom, 40/zoom, "ZALOGUJ SIĘ", 255, 10, false, false, "button_icon.png")
BUTTONS.create(sw/2, sh/2-500/zoom, 150/zoom, 40/zoom, "ZALOGUJ SIĘ", 255, 10)
BUTTONS.create(sw/2, sh/2+500/zoom, 100/zoom, 20/zoom, "ZALOGUJ SIĘ", 255, 10)
showCursor(true,false)
]]
