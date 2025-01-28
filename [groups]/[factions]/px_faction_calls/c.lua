--[[
    @author: Toffy. (Przemysław Silipicki)
    @mail: przemkeksilipicki@gmail.com
    @project: Pixel (MTA)
]]

local sx, sy = GuiElement.getScreenSize()
local baseX = 1920
local zoom = 1
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer and isTimer(SPAM.blockSpamTimer))then
        exports.px_noti:noti("Zaczekaj chwilkę..", "error")
        return true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1500, 1)

    return false
end

local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in pairs(t) do
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
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
	table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
end

local ui = {
    texturesList = {
        "bg",
        "close",
        "icon_bg",
        "icon_destination",
        "icon_location",
        "icon_route",
        "button-plus",
        "button-minus"
    },
    fonts = {},
    textures = {},
    animations = {},
    alpha = {},
    exports = {},
    buttons = {},
}


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
function onClick(x, y, w, h, fnc, double)
    if(ui.blockClick)then return end
    if(#anims > 0)then return end

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
        cx,cy=cx*sx,cy*sy

        if(getPosition(cx, cy, x, y, w, h))then
            mouseClicks=mouseClicks+1
            mouseTick=getTickCount()
            mouseClick=true
                
			fnc()
        end
	end
end

function math.round(num, decimals)
    decimals = math.pow(10, decimals or 0)
    num = num * decimals
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num / decimals
end

function convertTime(ms)     
    return getRealTime(ms,true) 
end 

ui.onRender = function()
    local allReports = ui.allReports;
    local main_x, main_y, main_w, main_h = sx/2-695/2/zoom, sy/2-622/2/zoom, 695/zoom, 622/zoom;

    if(not ui.scroll and not ui.animating)then
        ui.scroll = ui.exports.scroll:dxCreateScroll(main_x+main_w - 4, main_y + 50/zoom, 4, 540/zoom, 0, 6, allReports, 540/zoom, 255, 0, false, true, 0, 540/zoom, 150)
    end

    local row = math.floor(ui.exports.scroll:dxScrollGetPosition(ui.scroll))+1

    ui.exports.blur:dxDrawBlur(main_x, main_y, main_w, main_h+20/zoom, tocolor(255, 255, 255, ui.alpha))
    dxDrawImage(main_x, main_y, main_w, main_h+20/zoom, ui.textures['bg'], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    dxDrawText("Lista zgłoszeń", main_x, main_y, main_x+main_w, main_y+40/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[1], "center", "bottom")
    dxDrawImage((sx/2+695/2/zoom)-30/zoom, (sy/2-622/2/zoom)+20/zoom, 10/zoom, 10/zoom, ui.textures['close'], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    dxDrawLine(main_x + 20/zoom, main_y + 50/zoom, main_x+main_w - 20/zoom, main_y + 50/zoom, tocolor(110, 110, 110, ui.alpha))

    local margin = -19/zoom;
    local k = 0

    for i=row,row+5 do
        local v=allReports[i]
        k=k+1
        if(v)then
            dxDrawRectangle(main_x, margin + main_y + 70/zoom, main_w, 60/zoom, tocolor(0,0,0,ui.alpha > 100 and 100 or ui.alpha))
            dxDrawText(v.faction == "PSP" and "Straż pożarna" or v.faction == "SACC" and "Transport TAXI" or "Pomoc drogowa", main_x + 30/zoom, margin + main_y + 82.5/zoom, main_x+main_w, margin + main_y + 130/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[2], "left", "top")
            dxDrawText(v.reporter, main_x + 30/zoom, margin + main_y + 102.5/zoom, main_x+main_w, margin + main_y + 130/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[3], "left", "top")
            
            local time = convertTime(v.time)
            dxDrawText(string.format("%02d", time.hour)..":"..string.format("%02d", time.minute), main_x, margin + main_y + 70/zoom, main_x+main_w, margin + main_y + 130/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[2], "center", "center")
            dxDrawImage(main_x+main_w-40/zoom, margin + main_y + (17/2/zoom) + (165/2/zoom), 17/zoom, 17/zoom, ui.expanded == i and ui.textures['button-minus'] or ui.textures['button-plus'], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            
            if(not ui.animating)then
                if(not ui.buttons[k])then
                    ui.buttons[k] = {
                        ui.exports.buttons:createButton(main_x+main_w-175/zoom, margin + main_y + 72/zoom, 105/zoom, 24/zoom, "PRZYJMIJ", a, 9, false, false, false, {101,145,167}),
                        ui.exports.buttons:createButton(main_x+main_w-175/zoom, margin + main_y + 102/zoom, 105/zoom, 24/zoom, "ODRZUĆ", a, 9, false, false, false, {132,39,39}),
                    }
                else
                    ui.exports.buttons:buttonSetPosition(ui.buttons[k][1], {main_x+main_w-175/zoom, margin + main_y + 72/zoom})
                    ui.exports.buttons:buttonSetPosition(ui.buttons[k][2], {main_x+main_w-175/zoom, margin + main_y + 102/zoom})
                end
            end

            onClick(main_x+main_w-40/zoom, margin + main_y + (17/2/zoom) + (165/2/zoom), 17/zoom, 17/zoom, function()
                if(ui.expanded == i) then
                    ui.expanded = nil
                else
                    ui.expanded = i
                end
            end)

            onClick(main_x+main_w-175/zoom, margin + main_y + 72/zoom, 105/zoom, 24/zoom, function()
                if(ui.blockClick)then return end
                triggerServerEvent("faction_calls->deleteReport", resourceRoot, i, v.faction, v.time)
                ui.blockClick = true
                ui.closePanel()
            end)

            onClick(main_x+main_w-175/zoom, margin + main_y + 102/zoom, 105/zoom, 24/zoom, function()
                if(ui.blockClick)then return end
                triggerServerEvent("faction_calls->denyReport", resourceRoot, i, v.faction, v.time)
                ui.blockClick = true
                ui.closePanel()
            end)

            if(ui.expanded == i)then
                --expanded

                local player_pos = Vector3(localPlayer.position);

                if(not v.locationName)then
                    local x,y,z = v.location[1], v.location[2], v.location[3];
                    v.locationName = getZoneName(x,y,z, true)..", \n"..getZoneName(x,y,z)
                    v.distance = math.round(getDistanceBetweenPoints3D(player_pos.x, player_pos.y, player_pos.z, x, y, z)/1000, 2)
                end

                dxDrawRectangle(main_x, margin + main_y + 130/zoom, main_w, 27/zoom, tocolor(0,0,0,ui.alpha > 170 and 170 or ui.alpha))
                dxDrawText("Szczegóły zgłoszenia", main_x + 20/zoom, margin + main_y + 130/zoom, main_x+main_w, margin + main_y + 157/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[2], "left", "center")

                dxDrawRectangle(main_x, margin + main_y + 157/zoom, main_w, 27/zoom, tocolor(0,0,0,ui.alpha > 170 and 170 or ui.alpha))
                dxDrawText("Treść: "..v.text, main_x + 20/zoom, margin + main_y + 157/zoom, main_x + main_w - 10 /zoom, margin + main_y + 177/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[2], "left", "center", true)

                margin = margin + 15/zoom

                --lokalizacja gracza przyjmującego--
                dxDrawImage(main_x + 30/zoom, margin + main_y + 150/zoom + 46/2/zoom, 46/zoom, 46/zoom, ui.textures['icon_bg'], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
                dxDrawImage(main_x + 30/zoom + 14/zoom, margin + main_y + 150/zoom + 50/2/zoom + 20/2/zoom, 18/zoom, 20/zoom, ui.textures['icon_location'], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

                dxDrawText(getZoneName(player_pos.x, player_pos.y, player_pos.z, true)..", \n"..getZoneName(player_pos.x, player_pos.y, player_pos.z), main_x + 90/zoom, margin + main_y + 170/zoom, main_x + 120/zoom, margin + main_y + 220/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[2], "left", "center")
                -----------------------------------

                --lokalizacja gracza zgłaszającego--
                dxDrawImage(main_x + 230/zoom, margin + main_y + 150/zoom + 46/2/zoom, 46/zoom, 46/zoom, ui.textures['icon_bg'], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
                dxDrawImage(main_x + 230/zoom + 14/zoom, margin + main_y + 150/zoom + 50/2/zoom + 20/2/zoom, 18/zoom, 20/zoom, ui.textures['icon_destination'], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

                dxDrawText(v.locationName, main_x + 290/zoom, margin + main_y + 170/zoom, main_x + 320/zoom, margin + main_y + 220/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[2], "left", "center")
                ------------------------------------

                --dystans do zgłaszającego--
                dxDrawImage(main_x + 460/zoom, margin + main_y + 150/zoom + 46/2/zoom, 46/zoom, 46/zoom, ui.textures['icon_bg'], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
                dxDrawImage(main_x + 460/zoom + 14/zoom, margin + main_y + 150/zoom + 50/2/zoom + 20/2/zoom, 18/zoom, 20/zoom, ui.textures['icon_route'], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

                dxDrawText(v.distance.."km", main_x + 520/zoom, margin + main_y + 170/zoom, main_x + 550/zoom, margin + main_y + 220/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[2], "left", "center")
                ------------------------------------
                margin = margin + 165/zoom
            else
                margin = margin + 62/zoom
            end
        end
    end

    dxDrawLine(main_x, main_y+main_h - 30/zoom, main_x+main_w, main_y+main_h - 30/zoom, tocolor(110, 110, 110, ui.alpha))
    dxDrawText("Wszystkich zgłoszeń: "..#allReports, main_x+20/zoom, main_y+main_h - 30/zoom, main_x+main_w, main_y+main_h+20/zoom, tocolor(150, 150, 150, ui.alpha), 1, ui.fonts[2], "left", "center")

    onClick((sx/2+695/2/zoom)-30/zoom, (sy/2-622/2/zoom)+20/zoom, 10/zoom, 10/zoom, function()
        ui.blockClick = true
        ui.closePanel()
    end)

    onClick(sx/2-695/2/zoom+695/zoom-105/zoom-30/zoom, sy/2-622/2/zoom+622/zoom-17/zoom, 120/zoom, 24/zoom, function()
        triggerServerEvent("cancel.report", resourceRoot, true)
    end)
    
	local now = getTickCount()
	for k,v in pairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd()
			end
			table.remove(anims, k)
		end
	end
end

ui.openPanel = function()
    if(ui.openBlock)then return end

    ui.syncer = Element.getByID("faction_calls_syncer")
    ui.syncData = ui.syncer:getData("callers")
    
    local faction = localPlayer:getData("user:faction");
    if(not ui.syncData[faction]) then 
        localPlayer:setData("user:gui_showed", false, false)
        return 
    end

    --[[if(#ui.syncData[faction] < 1)then
        exports.px_noti:noti("Nie znaleziono żadnych zgłoszeń!", "error")
        localPlayer:setData("user:gui_showed", false, false)
        return
    end]]

    ui.openBlock = true
    ui.exports.blur = exports.blur;
    ui.exports.scroll = exports.px_scroll;
    ui.exports.buttons = exports.px_buttons;

    ui.allReports = ui.syncData[faction];

    ui.expanded = nil
    ui.alpha = 0

    ui.fonts = {
        DxFont("fonts/Font-Regular.ttf", 16/zoom),
        DxFont("fonts/Font-Regular.ttf", 13/zoom),
        DxFont("fonts/Font-Regular.ttf", 10/zoom)
    }
    
    for i,v in ipairs(ui.texturesList) do
        ui.textures[v] = DxTexture("images/"..v..".png", "argb", true, "clamp")
    end

    addEventHandler("onClientRender", root, ui.onRender)
    showCursor(true)

    ui.cancelButton=ui.exports.buttons:createButton(sx/2-695/2/zoom+695/zoom-105/zoom-30/zoom, sy/2-622/2/zoom+622/zoom-17/zoom, 120/zoom, 24/zoom, "ANULUJ ZGŁOSZENIE", a, 9, false, false, false, {132,39,39})

    if(ui.animations['alpha'])then destroyAnimation(ui.animations['alpha']) end
    ui.animations['alpha'] = animate(0, 255, "InOutQuad", 300, function(x)
        ui.alpha = x

        if(ui.scroll)then
            ui.exports.scroll:dxScrollSetAlpha(ui.scroll,x)
        end

        for _,v_ in pairs(ui.buttons) do
            for i,v in ipairs(v_) do
                ui.exports.buttons:buttonSetAlpha(v, x)
            end
        end

        ui.exports.buttons:buttonSetAlpha(ui.cancelButton, x)
    end, function()
        ui.animations['alpha'] = nil;
    end)
end

bindKey("F3", "down", function()
    if(ui.blockClick)then return end
    if(ui.openBlock)then
        ui.blockClick = true
        ui.closePanel()
    else
        if(not localPlayer:getData("user:faction"))then return end
        if(localPlayer:getData("user:gui_showed"))then return end
        if(SPAM.getSpam())then return end
        localPlayer:setData("user:gui_showed", resourceRoot, false)
        ui.openPanel()
    end
end)

ui.closePanel = function()
    if(ui.blockClick)then
        localPlayer:setData("user:gui_showed", false, false)
        if(ui.animations['alpha'])then destroyAnimation(ui.animations['alpha']) end
        ui.animating = true
        ui.animations['alpha'] = animate(255, 0, "InOutQuad", 300, function(x)
            ui.alpha = x
            if(ui.scroll)then
                ui.exports.scroll:dxScrollSetAlpha(ui.scroll,x)
            end
            for _,v_ in pairs(ui.buttons) do
                for i,v in ipairs(v_) do
                    ui.exports.buttons:buttonSetAlpha(v, x)
                end
            end
            ui.exports.buttons:buttonSetAlpha(ui.cancelButton, x)
        end, function()
            removeEventHandler("onClientRender", root, ui.onRender)
            showCursor(false)
            ui.animations['alpha'] = nil;
            ui.openBlock = false;
            ui.blockClick = false;
            if(ui.scroll)then
                ui.exports.scroll:dxDestroyScroll(ui.scroll)
                ui.scroll = nil
            end
            for i, _v in pairs(ui.buttons) do
                for _,v in ipairs(_v) do
                    ui.exports.buttons:destroyButton(v)
                end
                ui.buttons[i] = nil
            end
            ui.exports.buttons:destroyButton(ui.cancelButton)

            for i,v in ipairs(ui.fonts) do
                v:destroy()
            end
            ui.fonts = {}
            for i,v in ipairs(ui.textures) do
                v:destroy()
            end
            ui.textures = {}
            ui.animating = false
        end)
    end
end

addEvent("faction_calls->setGPS", true)
addEventHandler("faction_calls->setGPS", resourceRoot, function(location)
    if(location)then
        exports.px_map:setGPSPos(location[1], location[2], location[3])
    else
        exports.px_map:setGPSClear()
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = localPlayer:getData("user:gui_showed")
    if(gui and gui == source)then
        localPlayer:setData("user:gui_showed", false, false)
    end
    localPlayer:setData("faction_report->active", false)
end)

-- cancel

addEventHandler ("onClientElementDimensionChange", localPlayer,
	function (oldDimension, newDimension)
        if(newDimension ~= 0)then
            triggerServerEvent("cancel.report", resourceRoot)
        end
	end
)

addEventHandler ("onClientElementInteriorChange", localPlayer,
	function (oldDimension, newDimension)
        if(newDimension ~= 0)then
            triggerServerEvent("cancel.report", resourceRoot)
        end
	end
)