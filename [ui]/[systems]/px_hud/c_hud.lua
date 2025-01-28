--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

local avatars=exports.px_avatars
local achievements=exports.px_achievements

local fps = {
	tick=getTickCount(),
	ms=60,
}

local ui={}

local floor=math.floor

function getCirclePosition(x,y,w)
    return x+w/2,y+w/2,w/2
end

function _dxDrawCircle(x,y,w,r1,r2,color)
    r1=r1+90
    r2=r2+90
    if(r2 > 270)then
        dxDrawCircle(x,y,w,r1,r2,color)
        dxDrawCircle(x,y,w,r2,(r2-(270-90)),color)
    else
        dxDrawCircle(x,y,w,r1,r2,color)
    end
end

ui.fonts = {
	dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 13/zoom),
	dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 17/zoom),
	dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 16/zoom),
	dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 10/zoom),
	dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 14/zoom),
	dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 11/zoom),
	dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 12/zoom),
}

ui.textures = {
	'textures/avatar.png',
	'textures/circle_outline.png',

	'textures/star.png',
    'textures/star_blank.png',
    'textures/reputacja.png',

    'textures/big_outline.png',
	'textures/big_mask.png',

	'textures/hp.png',

    'textures/mini_outline.png',
    'textures/mini_mask.png',

	'textures/armor.png',
    'textures/oxygen.png',

	'textures/weapon_bg.png',
}
for i,v in pairs(ui.textures) do
	v=dxCreateTexture(v, 'argb', false, 'clamp')
end

ui.lastMoney = 0
ui.alpha = 255
ui.blur=false

ui.lastXP=0
ui.lastHP=0
ui.lastAR=0
ui.lastOX=0

ui.firstAdd=true
ui.playerMoney=0
ui.renderMoney=0
ui.addMoney=false

ui.uid = 0

ui.variables={
	logged=false,
	afk=false,
	hud_disabled=false,
	police_stars=0,
	level=0,
	exp=0,
}

ui.miscVariables={
	fps_counter=exports.px_dashboard:getSettingState("fps_counter"),
	showed_hud=exports.px_dashboard:getSettingState("showed_hud"),
}

ui.pos={
	rightFooter={0, sh-(13/zoom), sw-72, sh},
	leftFooter={5/zoom, sh-20/zoom, 0, 0},

	avatar={sw-162/zoom, 34/zoom, 125/zoom, 125/zoom},
	weapon={sw-162/zoom+(125-100)/2/zoom, 25/zoom, 100/zoom, 100/zoom},
	w_ammo_1={sw-157/zoom, 115/zoom, sw-157/zoom+115/zoom, 115/zoom},
	w_ammo_2={sw-157/zoom, 95/zoom, sw-157/zoom+115/zoom, 115/zoom},

	star={sw-184/zoom, 56/zoom, 21/zoom, 20/zoom, 22/zoom},
	money={0, 83/zoom, sw-184/zoom, 83/zoom+30/zoom},
	rp={sw-184/zoom-68/zoom, 121/zoom, 68/zoom, 16/zoom},
	rpText={0, 121/zoom, sw-184/zoom-68/zoom-10/zoom, 137/zoom},

	bigCircle_1={sw-162/zoom+(125-37)/2/zoom, 138/zoom, 36/zoom},
	bigCircle_2={sw-162/zoom+(125-37)/2/zoom, 138/zoom, 36/zoom, 36/zoom},
	bigCircle_3={sw-162/zoom+(125-37)/2/zoom+(36-30)/2/zoom, 138/zoom+(36-30)/2/zoom, 30/zoom, 30/zoom},
	hpIcon={floor(sw-162/zoom+(125-17)/2/zoom), floor(137/zoom+(38-15)/2/zoom), floor(16/zoom), floor(15/zoom)},

	miniCircle_1={sw-162/zoom+(125-37)/2/zoom-32/zoom, 137/zoom-7/zoom, 25/zoom, 25/zoom},
	miniCircle_1_2={sw-162/zoom+(125-37)/2/zoom-32/zoom, 137/zoom-7/zoom, 25/zoom, 25/zoom},
	miniCircle_1_3={sw-162/zoom+(125-37)/2/zoom-32/zoom+(25-19)/2/zoom, 137/zoom-7/zoom+(25-19)/2/zoom, 19/zoom, 19/zoom},
	armorIcon={floor(sw-162/zoom+(125-37)/2/zoom-32/zoom+(25-9)/2/zoom), floor(137/zoom-7/zoom+(25-11)/2/zoom), floor(9/zoom), floor(11/zoom)},

	miniCircle_2={sw-162/zoom+(125-37)/2/zoom+43/zoom, 137/zoom-7/zoom, 25/zoom, 25/zoom},
	miniCircle_2_2={sw-162/zoom+(125-37)/2/zoom+43/zoom, 137/zoom-7/zoom, 25/zoom, 25/zoom},
	miniCircle_2_3={sw-162/zoom+(125-37)/2/zoom+(25-19)/2/zoom+43/zoom, 137/zoom-7/zoom+(25-19)/2/zoom, 19/zoom, 19/zoom},
	oxygenIcon={floor(sw-162/zoom+(125-37)/2/zoom+(25-9)/2/zoom+43/zoom), floor(137/zoom-7/zoom+(25-9)/2/zoom), floor(9/zoom), floor(9/zoom)},
}

ui.onRender = function()
	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minute
	local seconds = time.second
    local monthday = time.monthday
	local month = time.month
	local year = time.year
    local formattedTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year + 1900, month + 1, monthday, hours, minutes, seconds)
	dxDrawText(formattedTime.." | "..ui.uid.." |", ui.pos.rightFooter[1], ui.pos.rightFooter[2], ui.pos.rightFooter[3], ui.pos.rightFooter[4], tocolor(255, 255, 255, 125), 1, "default", "right", "bottom", false, false, true)

	if(ui.miscVariables.fps_counter)then
		dxDrawText(math.floor(fps.ms), 1, 1, 0, 0, tocolor(0, 0, 0), 1, ui.fonts[1])
		dxDrawText(math.floor(fps.ms), 0, 0, 0, 0, tocolor(255, 255, 255), 1, ui.fonts[1])
	end

	if(not ui.variables.logged)then return end

	if(ui.uid == 0)then
		ui.uid = math.random(0,3)..getElementData(localPlayer, "user:uid")..math.random(3,6) -- new uid (33005) = 300
	end

	getDM() -- dm
	ui.getPlayerMoney() -- money

	if(ui.variables.hud_disabled or ui.miscVariables.showed_hud)then 
		return 
	end

	-- draw
	local avatar=avatars:getPlayerAvatar(localPlayer)
	dxDrawImage(ui.pos.avatar[1], ui.pos.avatar[2], ui.pos.avatar[3], ui.pos.avatar[4], avatar or ui.textures[1])
	dxDrawImage(ui.pos.avatar[1], ui.pos.avatar[2], ui.pos.avatar[3], ui.pos.avatar[4], ui.textures[2])

	-- weapons
	if(getPedWeapon(localPlayer) ~= 0)then
		dxDrawImage(ui.pos.avatar[1], ui.pos.avatar[2], ui.pos.avatar[3], ui.pos.avatar[4], ui.textures[13])
		dxDrawImage(ui.pos.weapon[1], ui.pos.weapon[2], ui.pos.weapon[3], ui.pos.weapon[4], "textures/weapons/"..getPedWeapon(localPlayer)..".png")

		local ammo1=getPedAmmoInClip(localPlayer,getPedWeaponSlot(localPlayer))
		local ammo2=getPedTotalAmmo(localPlayer),getPedAmmoInClip(localPlayer)
		dxDrawText(ammo1, ui.pos.w_ammo_2[1]+1, ui.pos.w_ammo_2[2]+1, ui.pos.w_ammo_2[3]+1, ui.pos.w_ammo_2[4]+1, tocolor(0, 0, 0), 1, ui.fonts[1], "center", "top", false)
		dxDrawText(ammo2, ui.pos.w_ammo_1[1]+1, ui.pos.w_ammo_1[2]+1, ui.pos.w_ammo_1[3]+1, ui.pos.w_ammo_1[4]+1, tocolor(0, 0, 0), 1, ui.fonts[6], "center", "top", false)
		dxDrawText(ammo1, ui.pos.w_ammo_2[1], ui.pos.w_ammo_2[2], ui.pos.w_ammo_2[3], ui.pos.w_ammo_2[4], tocolor(200, 200, 200), 1, ui.fonts[1], "center", "top", false)
		dxDrawText(ammo2, ui.pos.w_ammo_1[1], ui.pos.w_ammo_1[2], ui.pos.w_ammo_1[3], ui.pos.w_ammo_1[4], tocolor(100, 100, 100), 1, ui.fonts[6], "center", "top", false)
	end

	if(getElementData(localPlayer, 'user:factionAFK'))then
		dxDrawText('S2', ui.pos.avatar[1]+1, 190/zoom+1, ui.pos.avatar[1]+ui.pos.avatar[3]+1, 0, tocolor(0,0,0), 1, ui.fonts[2], 'center')
		dxDrawText('S2', ui.pos.avatar[1], 190/zoom, ui.pos.avatar[1]+ui.pos.avatar[3], 0, tocolor(0, 200, 200), 1, ui.fonts[2], 'center')
	end

	-- stars
	local data=getElementData(localPlayer, "user:maxMandates")
	if(data)then
		local stars=math.floor(data.stars)
		for i=1,data.maxStars do
			local sX=(ui.pos.star[5])*i
			local reverseID=(data.maxStars-i)+1
			dxDrawImage(ui.pos.star[1]-sX, ui.pos.star[2], ui.pos.star[3], ui.pos.star[4], stars >= reverseID and ui.textures[3] or ui.textures[4])
		end
	end

	-- money
	dxDrawText('$ '..ui.renderMoney, ui.pos.money[1]+1, ui.pos.money[2]+1, ui.pos.money[3]+1, ui.pos.money[4]+1, tocolor(0, 0, 0, 255), 1, ui.fonts[2], "right", "top", false)
	dxDrawText('$ '..ui.renderMoney, ui.pos.money[1], ui.pos.money[2], ui.pos.money[3], ui.pos.money[4], tocolor(85, 152, 70, 255), 1, ui.fonts[2], "right", "top", false, false, false, true)
	if(ui.addMoney)then
		local color=ui.addMoney > 0 and tocolor(85, 152, 70, 200) or tocolor(156,40,40)
		dxDrawText((ui.addMoney > 0 and '+' or '')..''..convertNumber(ui.addMoney)..'$', ui.pos.money[1]+1, ui.pos.money[2]+1, ui.pos.money[3]-dxGetTextWidth('$ '..ui.renderMoney, 1, ui.fonts[2])-10/zoom+1, ui.pos.money[4]+1, tocolor(0,0,0), 1, ui.fonts[5], "right", "bottom", false, false, false, true)
		dxDrawText((ui.addMoney > 0 and '+' or '')..''..convertNumber(ui.addMoney)..'$', ui.pos.money[1], ui.pos.money[2], ui.pos.money[3]-dxGetTextWidth('$ '..ui.renderMoney, 1, ui.fonts[2])-10/zoom, ui.pos.money[4], color, 1, ui.fonts[5], "right", "bottom", false, false, false, true)
	end

	-- rp
	local rp=getElementData(localPlayer, 'user:reputation')
	local color=rp > 0 and tocolor(85, 152, 70) or rp < 0 and tocolor(156,40,40) or tocolor(200,200,200)
	dxDrawImage(ui.pos.rp[1], ui.pos.rp[2], ui.pos.rp[3], ui.pos.rp[4], ui.textures[5])
	dxDrawText(rp, ui.pos.rpText[1]+1, ui.pos.rpText[2]+1, ui.pos.rpText[3]+1, ui.pos.rpText[4]+1, tocolor(0, 0, 0, 255), 1, ui.fonts[7], "right", "center", false, false, false, true)
	dxDrawText(rp, ui.pos.rpText[1], ui.pos.rpText[2], ui.pos.rpText[3], ui.pos.rpText[4], color, 1, ui.fonts[7], "right", "center", false, false, false, true)

	-- big circle HP
	local x,y,w=getCirclePosition(ui.pos.bigCircle_1[1], ui.pos.bigCircle_1[2], ui.pos.bigCircle_1[3])
	dxDrawCircle(x,y,w,0,360,tocolor(33,33,33))
	_dxDrawCircle(x,y,w,0, (ui.lastHP / 100) * 360, tocolor(236,34,34))
	dxDrawImage(ui.pos.bigCircle_3[1], ui.pos.bigCircle_3[2], ui.pos.bigCircle_3[3], ui.pos.bigCircle_3[4], ui.textures[7])
	dxDrawImage(ui.pos.bigCircle_2[1], ui.pos.bigCircle_2[2], ui.pos.bigCircle_2[3], ui.pos.bigCircle_2[4], ui.textures[6], 0, 0, 0, tocolor(33,33,33))
	dxDrawImage(ui.pos.hpIcon[1], ui.pos.hpIcon[2], ui.pos.hpIcon[3], ui.pos.hpIcon[4], ui.textures[8])
	
	-- mini circle ARMOR
	local x,y,w=getCirclePosition(ui.pos.miniCircle_1[1], ui.pos.miniCircle_1[2], ui.pos.miniCircle_1[3])
	dxDrawCircle(x,y,w,0,360,tocolor(33,33,33))
	_dxDrawCircle(x,y,w,0,(ui.lastAR / 100) * 360,tocolor(139,139,139))
	dxDrawImage(ui.pos.miniCircle_1_2[1], ui.pos.miniCircle_1_2[2], ui.pos.miniCircle_1_2[3], ui.pos.miniCircle_1_2[4], ui.textures[9], 0, 0, 0, tocolor(33,33,33))
	dxDrawImage(ui.pos.miniCircle_1_3[1], ui.pos.miniCircle_1_3[2], ui.pos.miniCircle_1_3[3], ui.pos.miniCircle_1_3[4], ui.textures[10])
	dxDrawImage(ui.pos.armorIcon[1], ui.pos.armorIcon[2], ui.pos.armorIcon[3], ui.pos.armorIcon[4], ui.textures[11])

	-- mini circle OXYGEN
	local x,y,w=getCirclePosition(ui.pos.miniCircle_2[1], ui.pos.miniCircle_2[2], ui.pos.miniCircle_2[3])
	dxDrawCircle(x,y,w,0,360,tocolor(33,33,33))
	_dxDrawCircle(x,y,w,0,(ui.lastOX / 100) * 360,tocolor(53,186,198))
	dxDrawImage(ui.pos.miniCircle_2_2[1], ui.pos.miniCircle_2_2[2], ui.pos.miniCircle_2_2[3], ui.pos.miniCircle_2_2[4], ui.textures[9], 0, 0, 0, tocolor(33,33,33))
	dxDrawImage(ui.pos.miniCircle_2_3[1], ui.pos.miniCircle_2_3[2], ui.pos.miniCircle_2_3[3], ui.pos.miniCircle_2_3[4], ui.textures[10])
	dxDrawImage(ui.pos.oxygenIcon[1], ui.pos.oxygenIcon[2], ui.pos.oxygenIcon[3], ui.pos.oxygenIcon[4], ui.textures[12])

	-- footer
	if(not footer or ((getTickCount()-footer) > 50))then
		local hour,minute=getTime()
		hour=string.format("%02d", hour)
		minute=string.format("%02d", minute)

		dxDrawText("pixelREMAKE - "..hour..":"..minute, ui.pos.leftFooter[1]+1, ui.pos.leftFooter[2]+1, ui.pos.leftFooter[3]+1, ui.pos.leftFooter[4]+1, tocolor(0, 0, 0, 125), 1, ui.fonts[4], "left", "top", false, false, true)
		dxDrawText("pixelREMAKE - "..hour..":"..minute, ui.pos.leftFooter[1], ui.pos.leftFooter[2], ui.pos.leftFooter[3], ui.pos.leftFooter[4], tocolor(255, 255, 255, 125), 1, ui.fonts[4], "left", "top", false, false, true)
	end

	-- settings
	local hp=getElementHealth(localPlayer)
	local oxygen=getPedOxygenLevel(localPlayer)
	local armour=getPedArmor(localPlayer)

	if(ui.lastHP ~= hp and not ui.animate2)then
		ui.animate2 = true
        animate(ui.lastHP, hp, "Linear", 500, function(new)
            ui.lastHP = new
        end, function()
            ui.animate2 = false
        end)
	end

	if(ui.lastAR ~= armour and not ui.animate3)then
		ui.animate3 = true
		animate(ui.lastAR, armour, "Linear", 500, function(new)
			ui.lastAR = new
		end, function()
			ui.animate3 = false
		end)
	end

	if(ui.lastOX ~= oxygen and not ui.animate4)then
		ui.animate4 = true
		animate(ui.lastOX, oxygen, "Linear", 500, function(new)
			ui.lastOX = new
		end, function()
			ui.animate4 = false
		end)
	end
end

-- money

ui.getMoneyValue=function(last, now, money)
	return last > now and last-money or last < now and last+money
end

ui.getPlayerMoney=function()
	local money=getPlayerMoney()
	local value=math.abs(money-ui.playerMoney)
	if(ui.playerMoney ~= money)then
		ui.playerMoney=value < 100 and ui.getMoneyValue(ui.playerMoney, money, 1) or value < 1000 and ui.getMoneyValue(ui.playerMoney, money, 10) or value < 10000 and ui.getMoneyValue(ui.playerMoney, money, 100) or value < 100000 and ui.getMoneyValue(ui.playerMoney, money, 1000) or ui.getMoneyValue(ui.playerMoney, money, 10000)
		ui.renderMoney=convertNumber(math.floor(ui.playerMoney))

		if(not ui.firstAdd)then
			ui.addMoney=money-ui.playerMoney
		end
	else
		ui.firstAdd=false
		ui.addMoney=false
	end
end

-- footer

function showFooterInfo(ranga, ranga2)
	if(ui.variables.hud_disabled or ui.miscVariables.showed_hud or not ui.variables.logged)then return end

	footer=getTickCount()

	local hour,minute=getTime()
	hour=string.format("%02d", hour)
	minute=string.format("%02d", minute)

	dxDrawText("pixelREMAKE - "..ranga2.." - "..hour..":"..minute, ui.pos.leftFooter[1]+1, ui.pos.leftFooter[2]+1, ui.pos.leftFooter[3]+1, ui.pos.leftFooter[4]+1, tocolor(0, 0, 0, 125), 1, ui.fonts[4], "left", "top", false, false, true, true)
	dxDrawText("pixelREMAKE - "..ranga.."#ffffff - "..hour..":"..minute, ui.pos.leftFooter[1], ui.pos.leftFooter[2], ui.pos.leftFooter[3], ui.pos.leftFooter[4], tocolor(255, 255, 255, 125), 1, ui.fonts[4], "left", "top", false, false, true, true)
end

-- variables

addEventHandler("onClientPlayerSpawn", getLocalPlayer(), function()
	for i,v in pairs(ui.variables) do
		ui.variables[i]=getElementData(localPlayer, "user:"..i)
	end
end)

-- datas
addEventHandler("onClientElementDataChange", root, function(data, last, new)
	if(source == localPlayer)then
		if(data == "user:dash_settings")then
			local state=exports.px_dashboard:getSettingState("fps_counter")
			ui.miscVariables["fps_counter"]=state

			local state=exports.px_dashboard:getSettingState("showed_hud")
			ui.miscVariables["showed_hud"]=state
		end

		data=string.sub(data, 6, #data)
		for i,v in pairs(ui.variables) do
			if(i == data)then
				ui.variables[data]=getElementData(localPlayer, "user:"..data)
			end
		end
	end
end)

for i,v in pairs(ui.variables) do
	ui.variables[i]=getElementData(localPlayer, "user:"..i)
end
addEventHandler("onClientRender", root, ui.onRender)

-- showgui

addCommandHandler("showgui", function()
	setElementData(localPlayer, "user:hud_disabled", not getElementData(localPlayer, "user:hud_disabled"))
end)

-- useful

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

function getCirclePosition(x,y,w)
    return x+w/2,y+w/2,w/2
end

function _dxDrawCircle(x,y,w,r1,r2,color)
    r1=r1+90
    r2=r2+90
    if(r2 > 270)then
        dxDrawCircle(x,y,w,r1,r2,color)
        dxDrawCircle(x,y,w,r2,(r2-(270-90)),color)
    else
        dxDrawCircle(x,y,w,r1,r2,color)
    end
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

function dxDrawRing (posX, posY, radius, width, startAngle, amount, color, postGUI, absoluteAmount, anglesPerLine)
	if (type (posX) ~= "number") or (type (posY) ~= "number") or (type (startAngle) ~= "number") or (type (amount) ~= "number") then
		return false
	end
	
	if absoluteAmount then
		stopAngle = amount + startAngle
	else
		stopAngle = (amount * 360) + startAngle
	end
	
	anglesPerLine = type (anglesPerLine) == "number" and anglesPerLine or 1
	radius = type (radius) == "number" and radius or 50
	width = type (width) == "number" and width or 5
	color = color or tocolor (255, 255, 255, 255)
	postGUI = type (postGUI) == "boolean" and postGUI or false
	absoluteAmount = type (absoluteAmount) == "boolean" and absoluteAmount or false
	
	for i = startAngle, stopAngle, anglesPerLine do
		local startX = math.cos (math.rad (i)) * (radius - width)
		local startY = math.sin (math.rad (i)) * (radius - width)
		local endX = math.cos (math.rad (i)) * (radius + width)
		local endY = math.sin (math.rad (i)) * (radius + width)
		dxDrawLine (startX + posX, startY + posY, endX + posX, endY + posY, color, width, postGUI)
	end
	return math.floor ((stopAngle - startAngle)/anglesPerLine)
end

-- fps

function updateFPS(ms)
	if((getTickCount()-fps.tick) > 500)then
		fps.ms = (1/ms)*1000
		fps.tick = getTickCount()
	end
end
addEventHandler("onClientPreRender", root, updateFPS)

-- online time

local o={}

o.time=0

o.add=function()
	if(getElementData(localPlayer, "user:uid") and not getElementData(localPlayer, "user:afk"))then
		local online=getElementData(localPlayer, "user:online_time") or 0
		local ses=getElementData(localPlayer, "user:sesion_time") or 0
		setElementData(localPlayer, "user:online_time", online+1)
		setElementData(localPlayer, "user:sesion_time", ses+1)

		achievements=exports.px_achievements
		if(math.floor(online) >= 600 and math.floor(online) <= 601 and not achievements:isPlayerHaveAchievement(localPlayer, "Zdobywasz doświadczenie na serwerze"))then
			achievements:getAchievement(localPlayer, "Zdobywasz doświadczenie na serwerze")
		elseif(math.floor(online) >= 6000 and math.floor(online) <= 6001 and not achievements:isPlayerHaveAchievement(localPlayer, "Stały bywalec"))then
			achievements:getAchievement(localPlayer, "Stały bywalec")
		elseif(math.floor(online) >= 60000 and math.floor(online) <= 60001 and not achievements:isPlayerHaveAchievement(localPlayer, "Prawdziwy gracz!"))then
			achievements:getAchievement(localPlayer, "Prawdziwy gracz!")
		end
	end
end
setTimer(o.add,1000*60,0)