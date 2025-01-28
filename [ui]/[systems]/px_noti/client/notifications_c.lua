--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw, sh = guiGetScreenSize()
local baseX = 1920
local zoom = 1
local minZoom = 2
local floor=math.floor

if sw < baseX then
    zoom = math.min(minZoom, baseX/sw)
end

local font_1 = dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 10/zoom)
local tabela = {}
local notis={
    info={tex=dxCreateTexture("assets/images/info.png", "argb", false, "clamp"), name="Informacja", color={52,142,159}},
    error={tex=dxCreateTexture("assets/images/error.png", "argb", false, "clamp"), name="Uwaga", color={225, 76, 75}},
    success={tex=dxCreateTexture("assets/images/success.png", "argb", false, "clamp"), name="Gratulacje", color={12,162,113}},
}

function dxDrawOutline(x,y,w,h,size,color)
    exports.blur:dxDrawBlur(x,y,w,h,color, true)
    dxDrawRectangle(x-size, y-size, w+size*2, size, color, true)
    dxDrawRectangle(x-size, y, size, h, color, true)
    dxDrawRectangle(x-size, y+h, w+size*2, size, color, true)
    dxDrawRectangle(x+w, y, size, h, color, true)
end

function gui()
    local defaultPosY=sh-115/zoom
    if(getElementData(localPlayer,'user:gui_showed') == 'bankomat' or getElementData(localPlayer, 'user:tank_showed'))then
        defaultPosY=sh-280/zoom
    end
    
    for i,v in pairs(tabela) do
        local ww,hh=dxGetMaterialSize(notis[v.type].tex)
        ww,hh=ww/zoom,hh/zoom

        local sY=(41/zoom)*(i-1)
        local width=dxGetTextWidth(v.text, 1, font_1)+24/zoom+ww
        if(v.start)then
            local x,y,w,h=sw/2-(ww+16/zoom)/2, v.posY, ww+16/zoom, 31/zoom
            dxDrawRectangle(x,y,w,h, tocolor(14,14,14,v.alpha > 190 and 190 or v.alpha),true)
            dxDrawOutline(x,y,w,h,1,tocolor(81,81,81,v.alpha > 50 and 50 or v.alpha))
            dxDrawImage(x+(w-ww)/2, y+(h-hh)/2, ww, hh, notis[v.type].tex, 0, 0, 0, tocolor(255, 255, 255, v.alpha), true)
        elseif(v.rozsun)then
            local x,y,w,h=sw/2-(ww+16/zoom)/2, v.posY, ww+16/zoom, 31/zoom
            local s_x,s_width,t_width=interpolateBetween(x, w, 0, sw/2-width/2, width, v.rt.width, (getTickCount()-v.tick)/500, 'Linear')
            dxDrawRectangle(s_x,y,s_width,h, tocolor(14,14,14,v.alpha > 190 and 190 or v.alpha),true)
            dxDrawOutline(s_x,y,s_width,h,1,tocolor(81,81,81,v.alpha > 50 and 50 or v.alpha))
            dxDrawImage(s_x+(w-ww)/2, y+(h-hh)/2, ww, hh, notis[v.type].tex, 0, 0, 0, tocolor(255, 255, 255, v.alpha), true)

            dxSetRenderTarget(v.rt.element,true)
                dxSetBlendMode('add')
                    dxDrawText(v.text, -v.rt.width+t_width, 0, v.rt.width, v.rt.height, tocolor(255,255,255), 1, font_1, 'left', 'center')
                dxSetBlendMode('blend')
            dxSetRenderTarget()
            dxDrawImage(floor(s_x+16/zoom+ww),floor(y+(h-v.rt.height)/2),floor(v.rt.width),floor(v.rt.height), v.rt.element, 0, 0, 0, tocolor(255,255,255,v.alpha), true)
        else
            local x,y,w,h=sw/2-width/2, v.posY, width, 31/zoom
            dxDrawRectangle(x,y,w,h, tocolor(14,14,14,v.alpha > 190 and 190 or v.alpha), true)
            dxDrawOutline(x,y,w,h,1,tocolor(81,81,81,v.alpha > 50 and 50 or v.alpha))
    
            dxDrawImage(x+8/zoom, y+(h-hh)/2, ww, hh, notis[v.type].tex, 0, 0, 0, tocolor(255, 255, 255, v.alpha), true)
            dxDrawText(v.text, x+16/zoom+ww, y, x+w-8/zoom, y+h, tocolor(255, 255, 255, v.alpha), 1, font_1, 'center', 'center', false, false, true)
        end

        if(tonumber(v.czas) and not v.animate)then
            if((getTickCount()-v.tick) > 500 and v.start)then
                v.start=false
                v.rozsun=true
                v.tick=getTickCount()
            elseif((getTickCount()-v.tick) > 500 and v.rozsun)then
                v.start=false
                v.rozsun=false
            end

            local originalY=defaultPosY-sY
            if(((getTickCount()-v.tick) > v.czas or v.ending) and not v.stable)then
                v.animate=true

                animate(v.posY, sh, "InOutQuad", 500, function(a)
                    v.posY = a
                end)

                animate(v.alpha, 0, "InOutQuad", 500, function(a)
                    v.alpha = a
                end, function()
                    v.animate=false
                    table.remove(tabela, i)
                end)
            elseif(v.posY ~= originalY)then
                v.animate=true
            
                if(v.alpha == 0)then
                    animate(0, 255, "InOutQuad", 1000, function(a)
                        v.alpha = a
                    end)
                end
    
                animate(v.posY, defaultPosY-sY, "InOutQuad", 500, function(a)
                    v.posY = a
                end, function()
                    v.animate=false
                end)
            end
        end
    end
end
addEventHandler('onClientRender', root, gui)

function noti(text, type, timeoff, stable)
    local exists=false
    for i,v in pairs(tabela) do
        if(v.text == text)then
            exists=true
            break
        end

        if(v.stable)then
            table.remove(tabela,i)
        end
    end

    if(exists)then return end

    if(#tabela > 10)then
        table.remove(tabela, i)
    elseif(#tabela > 5)then
        tabela[1].ending=true
    end

    type=type or "info"
    from=from or ""

	local time=timeoff or #text*150
    local lastRow=#tabela+1
    local width=dxGetTextWidth(text, 1, font_1)
    local height=dxGetFontHeight(1, font_1)
    local rt_element=dxCreateRenderTarget(width, height, true)
    tabela[lastRow]={text=text, alpha=0, tick=getTickCount(), czas=time, type=type, posY=sh, rt={element=rt_element,width=width,height=height}, start=true, stable=stable}
	outputConsole(text)

	playSound("assets/sounds/info.mp3")

    return lastRow
end
addEvent("notka", true)
addEventHandler("notka", resourceRoot, function(data, type, timeoff)
    noti(data, type, timeoff)
end)

addCommandHandler("zgredula", function()
    noti("Testowa notyfikacja #1", "info")
    setTimer(function()
        noti("Testowa notyfikacja #2", "success")
    end, 800, 1)
    setTimer(function()
        noti("Testowa notyfikacja #3", "error")
    end, 1600, 1)
end)

-- exports

function notiSetText(id,text)
    for i,v in pairs(tabela) do
        if(v.stable==id)then
            v.text=text
            break
        end
    end
end

function notiDestroy(id)
    for i,v in pairs(tabela) do
        if(v.stable==id)then
            table.remove(tabela,i)
            break
        end
    end
end

function isNotificationExists()
	return #tabela > 0 and true or false
end

-- useful

local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function animate(f, t, easing, duration, onChange, onEnd)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected number at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
	table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in ipairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
			table.remove(anims, k)
		end
	end
end)