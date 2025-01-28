--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

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

--

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local blur=exports.blur
local dashboard=exports.px_dashboard

local UI={}

UI.font_1 = dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 10/zoom)
UI.font_2 = dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", 15/zoom)

UI.text="?"
UI.type="?"
UI.tick=getTickCount()
UI.czas=0
UI.animate=false
UI.alpha=0
UI.x=0
UI.tickX=getTickCount()
UI.showed=false

UI.render=function()
	if(dashboard:getSettingState("premium_notis"))then return end

	local radar_type=getElementData(localPlayer, "radar")
	if(UI.type == "premium")then
		UI.czas=(1000*15)

		local width=dxGetTextWidth(UI.text, 1, UI.font_1)
		local info_width=dxGetTextWidth("Las Venturas", 1, UI.font_2)
		width=width+(info_width*2)

		local align="center"
		if(width > sw/2)then
			width=sw/2
			align="left"
		end

		blur:dxDrawBlur(sw-width, 0, width, 35/zoom, tocolor(255, 255, 255, UI.alpha))
		dxDrawRectangle(sw-width, 0, width, 35/zoom, tocolor(30, 30, 30, UI.alpha > 200 and 200 or UI.alpha), true)
		dxDrawText(UI.text, sw-width+10/zoom+info_width, 0, sw, 35/zoom, tocolor(200, 200, 200, UI.alpha), 1, UI.font_1, align, "center", true, false, true)
		dxDrawText("Las Venturas", sw-width+10/zoom, 0, width, 35/zoom, tocolor(100, 100, 100, UI.alpha > 50 and 50 or UI.alpha), 1, UI.font_2, "left", "center", false, false, true)
	else
		UI.czas=(1000*10)

		local x=290/zoom
		local y=sh-45/zoom
		if(radar_type == "rectangle")then
			x=430/zoom
			y=sh-35/zoom-36/zoom
		end

		local width=dxGetTextWidth(UI.text, 1, UI.font_1)+20/zoom
		blur:dxDrawBlur(x, y, width, 35/zoom, tocolor(255, 255, 255, UI.alpha > 100 and 100 or UI.alpha))
		dxDrawRectangle(x, y, width, 35/zoom, tocolor(30, 30, 30, UI.alpha > 100 and 100 or UI.alpha), true)
		dxDrawText(UI.text, x+1, y+1, width+x+1, 35/zoom+y+1, tocolor(0, 0, 0, UI.alpha), 1, UI.font_1, "center", "center", false, false, true)
		dxDrawText(UI.text, x, y, width+x, 35/zoom+y, tocolor(200, 0, 0, UI.alpha), 1, UI.font_1, "center", "center", false, false, true)
	end

	if((getTickCount()-UI.tick) > UI.czas and not UI.animate)then
		UI.animate = true

		animate(UI.alpha, 0, "Linear", 500, function(a)
			UI.alpha = a
		end, function()
			removeEventHandler("onClientRender", root, UI.render)

			UI.animate=false
			UI.showed=false
		end)
	end
end

function noti(text, type)
	blur=exports.blur
	dashboard=exports.px_dashboard
	
	UI.text=text
	UI.type=type
	UI.tick=getTickCount()
	UI.alpha=0
	UI.tickX=getTickCount()

	if(not UI.showed)then
		addEventHandler("onClientRender", root, UI.render)
	end

	UI.showed=true

	UI.animate=true
	animate(UI.alpha, 255, "Linear", 500, function(a)
		UI.alpha=a
	end, function()
		UI.animate=false
	end)
end
addEvent("info", true)
addEventHandler("info", resourceRoot, noti)
