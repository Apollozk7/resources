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

local SCOREBOARD = {}

local edit = exports.px_editbox
local scroll = exports.px_scroll
local admin = exports.px_admin
local noti=exports.px_noti
local blur=exports.blur
local alogo=exports.px_alogos
local avatars=exports.px_avatars

local ranks = admin:getRanks()

--

function getHex(admin, el)
	if(ranks and ranks[admin])then
		return ranks[admin].hex
	elseif(getElementData(el, "user:gold"))then
		return "#d5ad4a"
	elseif(getElementData(el, "user:premium"))then
		return "#f1ee92"
	end
	return "#939393"
end

local sw, sh = guiGetScreenSize()
local baseX = 1920
local zoom = 1
local minZoom = 2
local floor = math.floor

if sw < baseX then
    zoom = math.min(minZoom, baseX/sw)
end

SCOREBOARD.players = {}
SCOREBOARD.row = 1
SCOREBOARD.alpha = 0
SCOREBOARD.edit = false
SCOREBOARD.scroll = false
SCOREBOARD.visibled = 12
SCOREBOARD.showed = false
SCOREBOARD.cursor = false
SCOREBOARD.editText = ""
SCOREBOARD.imgs = {}
SCOREBOARD.settings={}
SCOREBOARD.posY=0

SCOREBOARD.duty={
	["brak"]="#939393",

	["SACC"]="#c7971a",
	["SAPD"]="#0f4aa4",
	["SARA"]="#e89907",

	["PSP"]="#e73232",

	["Mechanik"]="#a7b1ab",
	["Lakiernik"]="#b19dad",
	["Tuner"]="#9da4b1",
}

SCOREBOARD.refresh = {
	time=1000,
	tick=getTickCount()
}

SCOREBOARD.textures = {
    "assets/images/window.png",

	"assets/images/info_bar.png",

	"assets/images/nick.png",
	"assets/images/rp.png",
	"assets/images/org.png",
	"assets/images/frakcja.png",
	"assets/images/ping.png",

	"assets/images/bar.png",

	"assets/images/default.png",

	"assets/images/settings.png",
	"assets/images/settings_bg.png",
	"assets/images/add.png",
	"assets/images/block.png",

	"assets/images/id.png",
}

for i,v in pairs(SCOREBOARD.textures) do
	SCOREBOARD.imgs[i] = dxCreateTexture(v, "argb", false, "clamp")
end

SCOREBOARD.fonts = {
    dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 21/zoom),
    dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", 16/zoom),
    dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", 11/zoom),
    dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", 12/zoom),
    dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 12/zoom),
	dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 11/zoom),
}

SCOREBOARD.options={
	{name="Dodaj do znajomych", alpha=0},
	{name="Zablokuj gracza", alpha=0},
}

SCOREBOARD.table={
	{"#", 49/2/zoom-8/zoom, false, "id"},
	{"Nick", 100/zoom, SCOREBOARD.imgs[3], "name"},
	{"Reputacja", 330/zoom, SCOREBOARD.imgs[4], "reputation"},
	{"Organizacja", 500/zoom, SCOREBOARD.imgs[5], "organization"},
	{"Służba", 680/zoom, SCOREBOARD.imgs[6], "faction"},
	{"Ping", 820/zoom, SCOREBOARD.imgs[7], "ping"},
}

SCOREBOARD.sortFunction=false

SCOREBOARD.sort=function(a1,a2,sort)
	local rtrn=false
	for i,v in pairs(SCOREBOARD.table) do
		if(SCOREBOARD.sortFunction == v[1])then
			if(a1 and a1[v[4]] and a2 and a2[v[4]])then
				if(SCOREBOARD.sortDouble)then
					rtrn=a1[v[4]] < a2[v[4]] and true or false
				else
					rtrn=a1[v[4]] > a2[v[4]] and true or false
				end
			end
			break
		end
	end
	return rtrn
end

SCOREBOARD.getTable=function(element)
	local job=getElementData(element,"user:job_settings")
	local faction=getElementData(element, "user:faction")
	local name=faction
	if(job and job.job_tag and utf8.find(job.job_tag,"Warsztat"))then
		local m=#job.job_tag
		faction=job.job_name.." "..utf8.sub(job.job_tag,m-2,m)
		name=job.job_name
	end

	local table = {
		id=getElementData(element, "user:id"),
		name=getElementData(element, 'user:uid') and getPlayerMaskName(element):gsub("#%x%x%x%x%x%x", "") or 'Niezalogowany',
		hex=getHex(getElementData(element, "user:admin"), element),
		organization=getElementData(element, "user:organization_tag") or "brak",
		faction=faction or "brak",
		ping=getPlayerPing(element),
		element=element,
		reputation=getElementData(element, "user:reputation") or 0,
		color=getElementData(element, "user:uid") and {200, 200, 200} or {100,100,100},
		avatar=avatars:getPlayerAvatar(element, true),
		hoverAlpha=0,
		dutyColor=SCOREBOARD.duty[name or "brak"] or ""
	}

	return table
end

SCOREBOARD.loadPlayers = function(search)
	SCOREBOARD.players = {}

	if(not search)then
		SCOREBOARD.players[1] = {id=0}
	end

	for i,v in pairs(getElementsByType("player")) do
		if(search)then
			if((string.find(getPlayerMaskName(v):lower(), SCOREBOARD.editText:lower(), 1, true) or string.find(getElementData(v, "user:id"), SCOREBOARD.editText, 1, true)))then
				SCOREBOARD.players[#SCOREBOARD.players+1] = SCOREBOARD.getTable(v)
			end
		else
			if(v ~= localPlayer)then
				SCOREBOARD.players[#SCOREBOARD.players+1] = SCOREBOARD.getTable(v)
			end
		end
	end

	if(not search)then
		SCOREBOARD.players[1] = SCOREBOARD.getTable(localPlayer)
	end

	if(SCOREBOARD.scroll and #SCOREBOARD.players > 0)then
		scroll:dxScrollUpdateTable(SCOREBOARD.scroll, SCOREBOARD.players)
	end

	table.sort(SCOREBOARD.players,SCOREBOARD.sort)
end

SCOREBOARD.updatePlayers = function()
	for i = SCOREBOARD.row, (SCOREBOARD.row+SCOREBOARD.visibled) do
		if(SCOREBOARD.players[i] and SCOREBOARD.players[i].element and isElement(SCOREBOARD.players[i].element))then
			SCOREBOARD.players[i] = SCOREBOARD.getTable(SCOREBOARD.players[i].element)
		end
	end
end

SCOREBOARD.hovers={}

SCOREBOARD.onRender = function()
    -- main
    local w,h=890,757-16

    blur:dxDrawBlur(sw/2-w/2/zoom, SCOREBOARD.posY, w/zoom, h/zoom, tocolor(255, 255, 255, SCOREBOARD.alpha))
    dxDrawImage(sw/2-w/2/zoom, SCOREBOARD.posY, w/zoom, h/zoom, SCOREBOARD.imgs[1], 0, 0, 0, tocolor(255, 255, 255, SCOREBOARD.alpha), false)

    -- header
	local xw,xh=132,64
	xw,xh=xw/1.3,xh/1.3
	alogo:dxDrawMiniLogo(sw/2-w/2/zoom+20/zoom, SCOREBOARD.posY+(80-xh)/2/zoom, xw/zoom, xh/zoom, SCOREBOARD.alpha)

    -- players online on header
	local pp=string.format("%03d", #getElementsByType("player"))
    dxDrawTextShadow("Obecnie online", sw/2-w/2/zoom, SCOREBOARD.posY, w/zoom+sw/2-w/2/zoom-80/zoom, 80/zoom+SCOREBOARD.posY-20/zoom, tocolor(195, 195, 195, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[2], "right", "center", false)
    dxDrawTextShadow("na serwerze", sw/2-w/2/zoom, SCOREBOARD.posY, w/zoom+sw/2-w/2/zoom-80/zoom, 80/zoom+SCOREBOARD.posY+20/zoom, tocolor(150, 150, 150, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[3], "right", "center", false)
    dxDrawTextShadow(pp, sw/2-w/2/zoom+w/zoom-30/zoom-40/zoom, SCOREBOARD.posY, w/zoom+sw/2-w/2/zoom-30/zoom, 80/zoom+SCOREBOARD.posY, tocolor(102, 167, 255, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[1], "left", "center", false)

	-- update
	local editText = edit:dxGetEditText(SCOREBOARD.edit)
	if(SCOREBOARD.editText ~= editText)then
		SCOREBOARD.row = 1
		SCOREBOARD.editText = editText
		SCOREBOARD.loadPlayers(true)
	end

	if((getTickCount()-SCOREBOARD.refresh.tick) > SCOREBOARD.refresh.time)then
		SCOREBOARD.updatePlayers()
		SCOREBOARD.refresh.tick = getTickCount()
	end

	if(getKeyState("mouse2") and not SCOREBOARD.cursor and SCOREBOARD.showed)then
		SCOREBOARD.cursor = true
		showCursor(true, false)
	elseif(not getKeyState("mouse2") and not SCOREBOARD.cursor)then
		SCOREBOARD.cursor = false
		showCursor(false)
	end

	SCOREBOARD.row = math.floor(scroll:dxScrollGetPosition(SCOREBOARD.scroll)+1)

    -- info bar
	dxDrawImage(sw/2-888/2/zoom, SCOREBOARD.posY+80/zoom, 888/zoom, 24/zoom, SCOREBOARD.imgs[2], 0, 0, 0, tocolor(255, 255, 255, SCOREBOARD.alpha), false)
	for i,v in pairs(SCOREBOARD.table) do
		local ww,hh=dxGetTextWidth(v[1],1,SCOREBOARD.fonts[3]),10/zoom
		if(v[3])then
			ww,hh=dxGetMaterialSize(v[3])
			ww,hh=ww/1.3,hh/1.3
			dxDrawImage(sw/2-883/2/zoom+v[2]-ww/zoom-5/zoom, SCOREBOARD.posY+80/zoom+(24-hh)/2/zoom, ww/zoom, hh/zoom, v[3], 0, 0, 0, tocolor(200, 200, 200, SCOREBOARD.alpha), false)
		end

		local text=v[1]
		if(SCOREBOARD.sortFunction == v[1])then
			text=text.." "..(SCOREBOARD.sortDouble and "▼" or "▲")
		end

		dxDrawTextShadow(text, sw/2-883/2/zoom+v[2], SCOREBOARD.posY+80/zoom, 888/zoom, 24/zoom+SCOREBOARD.posY+80/zoom, tocolor(200, 200, 200, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[3], "left", "center")
		
		onClick(sw/2-883/2/zoom+v[2]-ww/zoom-5/2, SCOREBOARD.posY+80/zoom+(24-hh)/2/zoom, ww/zoom+dxGetTextWidth(v[1],1,SCOREBOARD.fonts[3]), hh/zoom, function()
			SCOREBOARD.sortFunction=v[1]
			SCOREBOARD.sortDouble=not SCOREBOARD.sortDouble
			SCOREBOARD.loadPlayers()
		end)
	end

	if(#SCOREBOARD.players < SCOREBOARD.visibled)then
		dxDrawRectangle(sw/2-888/2/zoom, SCOREBOARD.posY+h/zoom-37/zoom, 888/zoom, 1, tocolor(85,85,85,SCOREBOARD.alpha))
		dxDrawTextShadow("użyj scrolla aby używać / użyj PPM aby pokazać kursor", sw/2-888/2/zoom, SCOREBOARD.posY+h/zoom-37/zoom, 888/zoom+sw/2-888/2/zoom, SCOREBOARD.posY+h/zoom, tocolor(130, 130, 130, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[6], "center", "center")
	end

	-- players
	if(#SCOREBOARD.players > 0)then
		local x = 0
		for i = SCOREBOARD.row, (SCOREBOARD.row+SCOREBOARD.visibled) do
			if(SCOREBOARD.players[i] and SCOREBOARD.players[i].element and isElement(SCOREBOARD.players[i].element))then
				if(not SCOREBOARD.hovers[i])then
					SCOREBOARD.hovers[i]={hoverAlpha=0}
				end

				x = x+1

				local sY=(49/zoom)*(x-1)

				if(SCOREBOARD.players[i].element == localPlayer)then
					dxDrawImage(sw/2-w/2/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, w/zoom-1, 49/zoom, SCOREBOARD.imgs[8], 0, 0, 0, tocolor(255, 255, 255, SCOREBOARD.alpha), false)
					dxDrawImage(sw/2-w/2/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, w/zoom-1, 49/zoom, SCOREBOARD.imgs[8], 0, 0, 0, tocolor(255, 255, 255, SCOREBOARD.alpha), false)
				else
					dxDrawImage(sw/2-w/2/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, w/zoom-1, 49/zoom, SCOREBOARD.imgs[8], 0, 0, 0, tocolor(255, 255, 255, SCOREBOARD.alpha), false)
				end

				if(SCOREBOARD.hovers[i] and SCOREBOARD.hovers[i].hoverAlpha and isMouseInPosition(sw/2-w/2/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, w/zoom-1, 49/zoom) and not SCOREBOARD.hovers[i].animate and SCOREBOARD.hovers[i].hoverAlpha < 255)then
					SCOREBOARD.hovers[i].animate=true
					animate(0, 255, "Linear", 250, function(a)
						if(SCOREBOARD.hovers[i])then
							SCOREBOARD.hovers[i].hoverAlpha=a
						end
					end, function()
						if(SCOREBOARD.hovers[i])then
							SCOREBOARD.hovers[i].animate=false
						end
					end)
				elseif(SCOREBOARD.hovers[i] and SCOREBOARD.hovers[i].hoverAlpha and not isMouseInPosition(sw/2-w/2/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, w/zoom-1, 49/zoom) and not SCOREBOARD.hovers[i].animate and SCOREBOARD.hovers[i].hoverAlpha > 0)then
					SCOREBOARD.hovers[i].animate=true
					animate(255, 0, "Linear", 250, function(a)
						if(SCOREBOARD.hovers[i])then
							SCOREBOARD.hovers[i].hoverAlpha=a
						end
					end, function()
						if(SCOREBOARD.hovers[i])then
							SCOREBOARD.hovers[i].animate=false
						end
					end)
				end

				local a=SCOREBOARD.alpha > 100 and 100 or SCOREBOARD.alpha
				dxDrawRectangle(sw/2-w/2/zoom+1, SCOREBOARD.posY+80/zoom+24/zoom+sY+49/zoom-1, w/zoom-2, 1, tocolor(85, 85, 85, a), false)
				dxDrawRectangle(sw/2-w/2/zoom+1, SCOREBOARD.posY+80/zoom+24/zoom+sY+49/zoom-1, w/zoom-2, 1, tocolor(67, 178, 127, SCOREBOARD.alpha > SCOREBOARD.hovers[i].hoverAlpha and SCOREBOARD.hovers[i].hoverAlpha or SCOREBOARD.alpha), false)

				for _,v in pairs(SCOREBOARD.table) do
					if(SCOREBOARD.players[i] and SCOREBOARD.players[i][v[4]])then
						local w,h=v[3] and dxGetMaterialSize(v[3]) or 0,0
						local hex=""

						if(v[1] == "#")then
							dxDrawImage(sw/2-883/2/zoom-w/2/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, 49/zoom, 49/zoom-1, SCOREBOARD.imgs[14], 0, 0, 0, tocolor(255, 255, 255, SCOREBOARD.alpha), false)
							dxDrawTextShadow(hex..SCOREBOARD.players[i][v[4]], sw/2-883/2/zoom-w/2/zoom-1, SCOREBOARD.posY+80/zoom+24/zoom+sY, 49/zoom+sw/2-883/2/zoom-w/2/zoom, 49/zoom+SCOREBOARD.posY+80/zoom+24/zoom+sY-1, tocolor(200, 200, 200, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[3], "center", "center", false, false, false, true)
						elseif(v[1] == "Nick")then
							hex=SCOREBOARD.players[i].hex

							dxDrawImage(floor(sw/2-883/2/zoom+v[2]-20/zoom), floor(SCOREBOARD.posY+80/zoom+24/zoom+sY+(49-32)/2/zoom), floor(32/zoom), floor(32/zoom), SCOREBOARD.players[i].avatar, 0, 0, 0, tocolor(255, 255, 255, SCOREBOARD.alpha), false)
							dxDrawTextShadow(hex..SCOREBOARD.players[i][v[4]], sw/2-883/2/zoom+v[2]-w/zoom+35/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, 883/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY+49/zoom, tocolor(200, 200, 200, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[3], "left", "center", false, false, false, true)
						elseif(v[1] == "Służba")then
							local rgb=SCOREBOARD.players[i].dutyColor
							dxDrawTextShadow(rgb..SCOREBOARD.players[i][v[4]], sw/2-883/2/zoom+v[2]-w/zoom-5/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, 883/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY+49/zoom, tocolor(200, 200, 200, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[3], "left", "center", false, false, false, true)
						else
							dxDrawTextShadow(hex..SCOREBOARD.players[i][v[4]], sw/2-883/2/zoom+v[2]-w/zoom-5/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, 883/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY+49/zoom, tocolor(200, 200, 200, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[3], "left", "center", false, false, false, true)
						end
					end
				end

				if(SCOREBOARD.players[i].element ~= localPlayer)then
					dxDrawImage(sw/2-883/2/zoom+840/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY+(49-24)/2/zoom, 26/zoom, 24/zoom, SCOREBOARD.imgs[10], 0, 0, 0, tocolor(255, 255, 255, SCOREBOARD.alpha > SCOREBOARD.hovers[i].hoverAlpha and SCOREBOARD.hovers[i].hoverAlpha or SCOREBOARD.alpha), false)
					if(isMouseInPosition(sw/2-w/2/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY, w/zoom, 49/zoom) or (SCOREBOARD.settings.element and SCOREBOARD.settings.element == SCOREBOARD.players[i].element))then
						onClick(sw/2-883/2/zoom+840/zoom, SCOREBOARD.posY+80/zoom+24/zoom+sY+(49-24)/2/zoom, 26/zoom, 24/zoom, function()
							if(SCOREBOARD.settings.element and SCOREBOARD.settings.element == SCOREBOARD.players[i].element)then
								SCOREBOARD.settings={}
							else
								local sX,sY=getCursorPosition()
								sX,sY=sX*sw,sY*sh
								sX=sX+30/zoom
								sY=sY-30/zoom

								SCOREBOARD.settings={}
								SCOREBOARD.settings.element=SCOREBOARD.players[i].element
								SCOREBOARD.settings.pos={sX,sY}
							end
						end)
					end
				end
			end
		end
    end

	-- settings
	if(SCOREBOARD.settings.element and isElement(SCOREBOARD.settings.element) and SCOREBOARD.settings.pos and SCOREBOARD.settings.pos[1] and SCOREBOARD.settings.pos[2])then
		blur:dxDrawBlur(SCOREBOARD.settings.pos[1]+(228-222)/2/zoom, SCOREBOARD.settings.pos[2]+4/zoom, 222/zoom, 88/zoom, tocolor(255, 255, 255, 255), true)
		dxDrawImage(SCOREBOARD.settings.pos[1], SCOREBOARD.settings.pos[2], 228/zoom, 92/zoom, SCOREBOARD.imgs[11], 0, 0, 0, tocolor(255, 255, 255, 255), true)
		for i,v in pairs(SCOREBOARD.options) do
			local x,y,w,h=SCOREBOARD.settings.pos[1]+4/zoom,SCOREBOARD.settings.pos[2]+4/zoom, 219/zoom, 42/zoom
			y=y+(42/zoom)*(i-1)

			dxDrawRectangle(x,y,w,h, tocolor(15, 15, 15, v.alpha), true)
			dxDrawImage(x+(42-13)/2/zoom,y+(42-13)/2/zoom,13/zoom,13/zoom, SCOREBOARD.imgs[11+i], 0, 0, 0, tocolor(255, 255, 255, 255), true)
			dxDrawRectangle(x+(42-13)/2/zoom+16/zoom+8/zoom,y+(42-16)/2/zoom,1,16/zoom, tocolor(200,200,200), true)
			dxDrawText(v.name, x+(42-13)/2/zoom+16/zoom+8/zoom+10/zoom,y,w+x,h+y, tocolor(200, 200, 200, SCOREBOARD.alpha), 1, SCOREBOARD.fonts[3], "left", "center", false, false, true)

			if(v.name == "Zablokuj gracza" or v.name == "Odblokuj gracza")then
				local block=exports.px_interaction:isPlayerBlocked(SCOREBOARD.settings.element)
				if(block)then
					v.name="Odblokuj gracza"
				else
					v.name="Zablokuj gracza"
				end
			else
				local inx=exports.px_interaction:isPlayerInFriends(SCOREBOARD.settings.element)
				if(inx)then
					v.name="Usuń ze znajomych"
				else
					v.name="Dodaj do znajomych"
				end
			end

			onClick(x,y,w,h,function()
				if(SPAM.getSpam())then return end

				if(v.name == "Dodaj do znajomych")then
					if(exports.px_dashboard:getSettingState("friends_invites", SCOREBOARD.settings.element))then
						noti:noti("Ten gracz ma zablokowane wysyłanie zaproszeń do znajomych.")
						SCOREBOARD.settings={}
					else
						exports.px_interaction:addFriend(SCOREBOARD.settings.element)
						SCOREBOARD.settings={}
					end
				elseif(v.name == "Usuń ze znajomych")then
					exports.px_interaction:removeFriend(SCOREBOARD.settings.element)
					SCOREBOARD.settings={}
				elseif(v.name == "Zablokuj gracza")then
					local success=exports.px_interaction:blockPlayer(SCOREBOARD.settings.element)
					if(success)then
						noti:noti("Pomyślnie zablokowano gracza "..getPlayerMaskName(SCOREBOARD.settings.element)..".")
						SCOREBOARD.settings={}
					end
				elseif(v.name == "Odblokuj gracza")then
					local success=exports.px_interaction:unblockPlayer(SCOREBOARD.settings.element)
					if(success)then
						noti:noti("Pomyślnie odblokowano gracza "..getPlayerMaskName(SCOREBOARD.settings.element)..".")
						SCOREBOARD.settings={}
					end
				end
			end)

			if(isMouseInPosition(x,y,w,h) and not v.animate)then
				v.animate = true

				animate(v.alpha, 100, "Linear", 200, function(a)
					if(v.animate)then
						v.alpha = a
					end
				end)
			elseif(not isMouseInPosition(x,y,w,h) and v.animate)then
				v.animate = false

				animate(v.alpha, 0, "Linear", 200, function(a)
					if(not buttonAnimate)then
						v.alpha = a
					end
				end)
			end
		end
	else
		SCOREBOARD.settings={}
	end
end

SCOREBOARD.toggle = function(type)
	local w,h=890,757
	if(type == "show-true" and SCOREBOARD.alpha == 0)then
		noti=exports.px_noti
		blur=exports.blur
		alogo=exports.px_alogos
		avatars=exports.px_avatars
		edit = exports.px_editbox
		scroll = exports.px_scroll
		admin = exports.px_admin
		ranks = admin:getRanks()

		SCOREBOARD.showed = true
		SCOREBOARD.row = 1
		SCOREBOARD.hovers = {}

		SCOREBOARD.loadPlayers()

		addEventHandler("onClientRender", root, SCOREBOARD.onRender)

		SCOREBOARD.edit = edit:dxCreateEdit("Wyszukaj poprzez nick / ID gracza", sw/2-w/2/zoom+220/zoom, SCOREBOARD.posY+(80-25)/2/zoom, 350/zoom, 25/zoom, false, 10/zoom, 0, false, false, ":px_scoreboard/assets/images/icon.png", true)
		SCOREBOARD.scroll = scroll:dxCreateScroll(sw/2-w/2/zoom+w/zoom-3, SCOREBOARD.posY+80/zoom, 4, 4, 0, SCOREBOARD.visibled+1, SCOREBOARD.players, (h-96)/zoom, 0, 10)

		animate(SCOREBOARD.alpha, 255, "Linear", 300, function(a)
			if(SCOREBOARD.showed)then
				SCOREBOARD.alpha = a

				edit:dxSetEditAlpha(SCOREBOARD.edit, a)
				scroll:dxScrollSetAlpha(SCOREBOARD.scroll, a)
			end
		end)

		animate(0, sh/2-h/2/zoom, "OutQuad", 300, function(a)
			if(SCOREBOARD.showed)then
				SCOREBOARD.posY=a
				edit:dxSetEditPosition(SCOREBOARD.edit, {sw/2-w/2/zoom+220/zoom, SCOREBOARD.posY+(80-25)/2/zoom})
				scroll:dxScrollSetPosition(SCOREBOARD.scroll, {sw/2-w/2/zoom+w/zoom-4, SCOREBOARD.posY+80/zoom})
			end
		end)

		setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
	elseif(type == "show-false" and SCOREBOARD.alpha == 255)then
		SCOREBOARD.settings={}
		SCOREBOARD.showed = false
		SCOREBOARD.cursor = false
		showCursor(false)

		setElementData(localPlayer, "user:gui_showed", false, false)

		animate(SCOREBOARD.posY, sh-h, "Linear", 300, function(a)
			if(not SCOREBOARD.showed)then
				SCOREBOARD.posY=a
				edit:dxSetEditPosition(SCOREBOARD.edit, {sw/2-w/2/zoom+220/zoom, SCOREBOARD.posY+(80-25)/2/zoom})
				scroll:dxScrollSetPosition(SCOREBOARD.scroll, {sw/2-w/2/zoom+w/zoom-4, SCOREBOARD.posY+80/zoom})
			end
		end)

		animate(SCOREBOARD.alpha, 0, "InQuad", 300, function(a)
			if(not SCOREBOARD.showed)then
				SCOREBOARD.alpha = a

				edit:dxSetEditAlpha(SCOREBOARD.edit, a)
				scroll:dxScrollSetAlpha(SCOREBOARD.scroll, a)
			end
		end, function()
			SCOREBOARD.players = {}
			SCOREBOARD.row = 1

			removeEventHandler("onClientRender", root, SCOREBOARD.onRender)

			if(SCOREBOARD.edit)then
				edit:dxDestroyEdit(SCOREBOARD.edit)
				SCOREBOARD.edit = false
			end

			if(SCOREBOARD.scroll)then
				scroll:dxDestroyScroll(SCOREBOARD.scroll)
				SCOREBOARD.scroll = false
			end

			SCOREBOARD.hovers={}

			SCOREBOARD.sortFunction=false
		end)
	end
end

bindKey("TAB", "both", function(_, state)
	if(not getElementData(localPlayer, "user:logged") or getElementData(localPlayer, "user:hud_disabled"))then return end

	if(state == "up" and not SCOREBOARD.cursor)then
		SCOREBOARD.toggle("show-false")
	elseif(state == "down")then
		if(SCOREBOARD.cursor)then
			SCOREBOARD.toggle("show-false")
		else
			if(getElementData(localPlayer, "user:gui_showed"))then return end
			SCOREBOARD.toggle("show-true")
		end
	end
end)

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

-- on stop

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)

function dxDrawTextShadow( text, x, y, w, h, color, fontSize, fontType, alignX, alignY, a1, a2, a3, a4 )
 	dxDrawText( text:gsub("#%x%x%x%x%x%x", ""), x+1, y+1, w+1, h+1, tocolor(0, 0, 0, SCOREBOARD.alpha), fontSize, fontType, alignX, alignY, a1, a2, a3, a4 )
 	dxDrawText( text, x, y, w, h, color, fontSize, fontType, alignX, alignY, a1, a2, a3, a4 )
end

-- by asper

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

function isMouseInCircle(x, y, r)
    if(not isCursorShowing())then return false end

    x,y,r=getCirclePosition(x,y,r)

    local mouse = {getCursorPosition()}
    local myX, myY = (mouse[1] * sw), (mouse[2] * sh)
    if((x-myX)^2+(y-myY)^2 <= r^2)then
        return true
    end

    return false
end

-- names

function getPlayerMaskName(player)
	return getElementData(player, "user:nameMask") or getPlayerName(player)
end