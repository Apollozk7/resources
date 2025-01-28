--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local edit = {}

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

function isMouseInPosition(x, y, w, h)
	if not isCursorShowing() then return end

	local pos = {getCursorPosition()}
	pos[1], pos[2] = (pos[1] * sw), (pos[2] * sh)

	if pos[1] >= x and pos[1] <= (x + w) and pos[2] >= y and pos[2] <= (y + h) then
		return true
	end
	return nil
end

function edit:load()
    self.render_fnc = function() self:render() end
    self.click_fnc = function(...) self:click(...) end
    self.character_fnc = function(...) self:character(...) end
    self.key_fnc = function(...) self:key(...) end

    self.edits = {}
    self.resources = {}

    self.showed = nil

    self.tick = getTickCount()
    self.tickBack = getTickCount()
    self.backState = 0

    self.pasted = nil

    self.backing = nil

    self.font = false

    self.arrow = 0

	self.selected=false

	self.tickArrow=getTickCount()
	self.arrowState=0
end

function edit:create(opisText, x, y, w, h, masked, fontSize, a, onlyNumbers, maxLetters, filePath, onlyText, postGUI, clicked)
    if(self.font and isElement(self.font))then
        destroyElement(self.font)
        self.font = false
    end

	if(self.font2 and isElement(self.font2))then
		destroyElement(self.font2)
		self.font2 = false
	end

    local tex=filePath and dxCreateTexture(filePath, "argb", false, "clamp")
    self.font = dxCreateFont(":px_assets/fonts/Font-Regular.ttf", (fontSize or 11))
	self.font2 = dxCreateFont(":px_assets/fonts/Font-Regular.ttf", ((fontSize-2) or 9))
    self.edits[#self.edits+1] = {"", "", opisText, x, y, w, h, masked, false, 0, color or {200,200,200}, false, fontSize, a or 255, false, onlyNumbers, maxLetters, tex, onlyText, postGUI}

    if not self.showed then
        addEventHandler("onClientRender", root, self.render_fnc)
        addEventHandler("onClientClick", root, self.click_fnc)
        addEventHandler("onClientKey", root, self.key_fnc)
		addEventHandler("onClientCharacter", root, self.character_fnc)		

        self.showed = true
    end

	if(clicked)then
		setTimer(function()
			self:clicked(#self.edits, self.edits[#self.edits])			
		end, 50, 1)
    end

    if(sourceResource)then
		-- if source resource stop then destroy buttons
		self.resources[sourceResource] = true
		self.edits[#self.edits].resource = sourceResource
        addEventHandler("onClientResourceStop", getResourceRootElement(sourceResource), function(resource)
			for i,v in pairs(self.edits) do
				if(v.resource == resource)then
					edit:destroy(i)
				end
            end
            self.resources[resource] = nil
		end)
	end

	return #self.edits
end

function edit:destroy(id)
	local v=edit.edits[id]
	if(v)then
	    if v[18] and isElement(v[18]) then
	        destroyElement(v[18])
	    end

	    self.edits[id] = nil

		if(self.selected == id)then
			self.selected=false
		end
	end

    if #self.edits < 1 then
        removeEventHandler("onClientRender", root, self.render_fnc)
        removeEventHandler("onClientClick", root, self.click_fnc)
        removeEventHandler("onClientCharacter", root, self.character_fnc)
        removeEventHandler("onClientKey", root, self.key_fnc)

        self.showed = nil

        if(self.font and isElement(self.font))then
            destroyElement(self.font)
            self.font = false
        end

		if(self.font2 and isElement(self.font2))then
			destroyElement(self.font2)
			self.font2 = false
		end

        if self.pasted and isElement(self.pasted) then
            destroyElement(self.pasted)
            self.pasted = nil
        end

        showCursor(false)

        self.resources = {}
    end
end

local a,a2=0,0

function dxDrawButton(x,y,w,h,alpha,postGUI)
	dxDrawRectangle(x,y,w,h,tocolor(31,32,31,alpha),postGUI)

	dxDrawRectangle(x,y,w,1,tocolor(54,56,53,alpha),postGUI)
	dxDrawRectangle(x,y,1,h,tocolor(54,56,53,alpha),postGUI)
	dxDrawRectangle(x,y+h,w,1,tocolor(54,56,53,alpha),postGUI)
	dxDrawRectangle(x+w-1,y,1,h,tocolor(54,56,53,alpha),postGUI)
end

function edit:render()
    for i,v in pairs(self.edits) do
		v.alpha=v.alpha or 50

        local x,w = 0,0
        local xx = v[6]
        if(self.selected == i)then
            x,w,a = interpolateBetween(v[6]/2, 0, 0, 0, xx, 255, (getTickCount()-v[10])/200, "Linear")
			a2=interpolateBetween(255, 50, 0, 0, 150, 0, (getTickCount()-v[10])/200, "Linear")
        else
            x,w,a = interpolateBetween(0, xx, 255, v[6]/2, 0, 0, (getTickCount()-v[10])/200, "Linear")
			a2=interpolateBetween(0, 150, 0, 255, 50, 0, (getTickCount()-v[10])/200, "Linear")
        end

		local alpha=v[14] > v.alpha and v.alpha or v[14]
		dxDrawButton(v[4], v[5], v[6], v[7]-1, alpha, v[20])

		if(isMouseInPosition(v[4], v[5], v[6], v[7]) and not v.hover and not v.animate and self.selected ~= i)then
			v.hover=true
			v.animate=true
			animate(50, 100, "Linear", 250, function(a)
				v.alpha=a
			end, function()
				v.animate=false
			end)
		elseif(not isMouseInPosition(v[4], v[5], v[6], v[7]) and v.hover and not v.animate and self.selected ~= i)then
			v.hover=false
			v.animate=true
			animate(100, 50, "Linear", 250, function(a)
				v.alpha=a
			end, function()
				v.animate=false
			end)
		end

        dxDrawRectangle(v[4], v[5]+v[7]-1, v[6], 1, tocolor(175, 175, 175, v[14]), v[20])
        dxDrawRectangle(v[4]+x, v[5]+v[7]-1, w, 1, tocolor(0, 100, 150, v[14]), v[20])

		local x = v[15] and v[4] + v[7] or v[4]
		local w = v[15] and v[6] - v[7] or v[6]

        if(v[18])then
            local ww,hh=dxGetMaterialSize(v[18])

            dxDrawImage(v[4]+(v[7]-(hh/zoom))/2, v[5]+(v[7]-(hh/zoom))/2, ww/zoom, hh/zoom, v[18], 0, 0, 0, tocolor(255, 255, 255, v[14]), v[20])

			x=x+(v[7]-(hh/zoom))/2+ww/zoom
			w=w-(v[7]-(hh/zoom))/2+ww/zoom
        end

        local text = v[8] and string.rep("*", #v[2]) or v[2]
        local carretText = utf8.sub(text, 1, self.arrow)
        local width = dxGetTextWidth(carretText, 1, self.font, false) or 0

        if(self.selected == i)then
            if (getKeyState("lctrl") or getKeyState("rctrl")) and getKeyState("v") then
                v[2] = guiGetText(self.pasted) or ""
                self.arrow = #v[2]
            end

            if getKeyState("backspace") then
				self.backState=math.max(self.backState-3,30)

				if((getTickCount() - self.tickBack) > self.backState and #v[2] > 0 and self.arrow > 0)then
					v[2] = utf8.sub(v[2], 1, self.arrow-1)..utf8.sub(v[2], self.arrow+1, #v[2])
					self.tickBack = getTickCount()
					if(self.arrow > 0)then
						self.arrow = self.arrow-1
					end
					if(self.pasted)then
						guiSetText(self.pasted, v[2])
					end
				end
            else
                self.backState = 200
            end

			if(getKeyState("arrow_l") or getKeyState("arrow_r"))then
				self.arrowState=self.arrowState-3

				if((getTickCount() - self.tickArrow) > self.arrowState)then
					if(getKeyState("arrow_l"))then
						if(self.arrow > 0)then
							self.arrow = self.arrow-1
							self.tickArrow = getTickCount()
						end
					elseif(getKeyState("arrow_r"))then
						if(self.arrow < #v[2])then
							self.arrow = self.arrow+1
							self.tickArrow = getTickCount()
						end
					end
				end
			else
				self.arrowState=200
			end

            local carretAlpha = v[14] > 200 and interpolateBetween(50, 0, 0, 200, 0, 0, (getTickCount() - self.tick) / 1000, "SineCurve") or v[14]
            local carretSize = dxGetFontHeight(1, self.font)
			local w=v[18] and (v[6]-40/zoom) or v[6]-10/zoom
			local ww=v[18] and (v[6]-30)/zoom or v[6]
            local carretPosX = width >= w and x + ww - 8/zoom or x + width + (10 / zoom)
            dxDrawRectangle(carretPosX, v[5]+(v[7]-carretSize)/2, 1, carretSize, tocolor(v[11][1], v[11][2], v[11][3], carretAlpha), v[20])
		end

		local w=v[18] and (v[6]-40/zoom) or v[6]-10/zoom
        if width >= w then
            dxDrawText(text, x + (10 / zoom), v[5], v[4]+v[6]-10/zoom, v[7] + v[5], tocolor(v[11][1], v[11][2], v[11][3], v[14]), 1, self.font, "right", "center", true, false, v[20])
        else
            dxDrawText(text, x + (10 / zoom), v[5], v[4]+v[6], v[7] + v[5], tocolor(v[11][1], v[11][2], v[11][3], v[14]), 1, self.font, "left", "center", true, false, v[20])
        end

		if(not v[19])then
			dxDrawText(v[3], v[4], v[5]-v[7]-5/zoom-dxGetFontHeight(self.fonts2), w, v[7] + v[5], tocolor(200, 200, 200, v[14] > a and a or v[14]), 1, self.font2, "left", "center", false, false, v[20])
		end

		if(#v[2] < 1)then
			dxDrawText(v[3], x + (10 / zoom), v[5], w, v[7] + v[5], tocolor(200, 200, 200, v[14] > a2 and a2 or v[14]), 1, self.font, "left", "center", false, false, v[20])
		end
    end
end

function edit:clicked(i, v)
	if(self.selected)then
		self.edits[self.selected][10]=getTickCount()
	end

	self.arrow = #v[2]
	self.selected=i
	v[10]=getTickCount()

	if(not self.pasted)then
		self.pasted = guiCreateEdit(3000, 3000, 200, 200, "", false, false)
		guiBringToFront(self.pasted)
		guiSetText(self.pasted, v[2])

		guiSetInputMode("no_binds_when_editing")
	else
		guiBringToFront(self.pasted)
		guiSetText(self.pasted, v[2])

		guiSetInputMode("no_binds_when_editing")
	end
end

function edit:click(button, state)
    if button ~= "left" or state ~= "down" then return end

    for i,v in pairs(self.edits) do
		if(isMouseInPosition(v[4], v[5], v[6], v[7]))then
			playSound("assets/sounds/hover.mp3")
			if(self.selected == i)then
				local x = v[15] and v[4] + v[7] or v[4]		
				if(v[18])then
					local ww,hh=dxGetMaterialSize(v[18])
					x=x+(v[7]-(hh/zoom))/2+ww/zoom+(v[7]-(hh/zoom))/2
				end

				local click=false
				local text = v[8] and string.rep("*", #v[2]) or v[2]
				local last=0
				for i=1,#text do
					if(isMouseInPosition(x+last+10/zoom, v[5], dxGetTextWidth(string.sub(text,i,i),1,self.font), v[7]))then
						self.arrow=i-1
						click=true
					end
					last=last+dxGetTextWidth(string.sub(text,i,i),1,self.font)
				end
				
				if(not click)then
					self.selected=false
					v[10]=getTickCount()

					if(self.pasted)then
						destroyElement(self.pasted)
						guiSetInputMode("allow_binds")
						self.pasted=false
					end
				end

				break
			else
				self:clicked(i,v)
				break
			end
		else
			if(self.selected and self.selected == i)then
				self.selected=false
				v[10]=getTickCount()

				if(self.pasted)then
					destroyElement(self.pasted)
					guiSetInputMode("allow_binds")
					self.pasted=false
				end
			end
		end
    end
end

local numbers = {
    ["0"] = true,
    ["1"] = true,
    ["2"] = true,
    ["3"] = true,
    ["4"] = true,
    ["5"] = true,
    ["6"] = true,
    ["7"] = true,
    ["8"] = true,
    ["9"] = true,
}

function edit:character(key)
	if(self.selected)then
		local v=self.edits[self.selected]
		if(v[17] and #v[2] < v[17] or not v[17])then
			if(v[16] and numbers[key])then
				v[2] = utf8.sub(v[2], 1, self.arrow)..key..utf8.sub(v[2], self.arrow+1, #v[2])
				self.arrow = self.arrow+1

				if(self.pasted)then
					guiSetText(self.pasted, v[2])
				end
			elseif(not v[16])then
				v[2] = utf8.sub(v[2], 1, self.arrow)..key..utf8.sub(v[2], self.arrow+1, #v[2])
				self.arrow = self.arrow+1
				
				if(self.pasted)then
					guiSetText(self.pasted, v[2])
				end
			end
		end
	end
end

function edit:key(key, press)
    if press then
		if(key == "backspace" and self.selected)then
			local v=self.edits[self.selected]
			if(v)then
				v[2] = utf8.sub(v[2], 1, self.arrow-1)..utf8.sub(v[2], self.arrow+1, #v[2])
				self.tickBack = getTickCount()
				if(self.arrow > 0)then
					self.arrow = self.arrow-1
				end
				if(self.pasted)then
					guiSetText(self.pasted, v[2])
				end
			end
        elseif key == "tab" and self.selected then
			if(self.edits[self.selected+1])then
				self.edits[self.selected][10]=getTickCount()
				self.selected=self.selected+1
				self.edits[self.selected][10]=getTickCount()
			else
				self.edits[self.selected][10]=getTickCount()
				self.selected=1
				self.edits[self.selected][10]=getTickCount()
			end
        elseif (getKeyState("lctrl") or getKeyState("rctrl")) and (getKeyState("c") or getKeyState("a")) then
            cancelEvent()
        end
    end
end

function dxCreateEdit(...)
    return edit:create(...)
end

function dxDestroyEdit(...)
    return edit:destroy(...)
end

function dxGetEditText(id)
    local text = ""
	local v=edit.edits[id]
	if(v)then
		text = v[2]
	end
    return text
end

function dxSetEditText(id, text)
	local v=edit.edits[id]
	if(v)then
    	v[2] = text
		edit.arrow=#text
	end
end

function dxSetEditAlpha(id, a)
	local v=edit.edits[id]
	if(v)then
		v[14] = tonumber(a)
	end
end

function dxSetEditPosition(id, pos)
	local v=edit.edits[id]
	if(v)then
    	v[4], v[5] = pos[1], pos[2]
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    edit:load()
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
