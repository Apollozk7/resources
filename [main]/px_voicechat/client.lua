--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local voicePlayers = {}

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

local range = 30

local blur=exports.blur
local avatars=exports.px_avatars
local dashboard=exports.px_dashboard

local font = dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 11/zoom)
local voice=dxCreateTexture("images/speaker.png", "argb", false, "clamp")

local timers={}

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function onRender()
	if(not getElementData(localPlayer, "user:logged"))then return end
	if(getElementData(localPlayer, "user:hud_disabled"))then return end
	if(not dashboard:getSettingState("voice_chat"))then cancelEvent() return end

	local index = 0
	local sX, sY, sZ = getElementPosition(localPlayer)
	local radar=exports.px_dashboard:getSettingState("radar_type")

	for player in pairs(voicePlayers) do
		local rX, rY, rZ = getElementPosition(player)
		local distance = getDistanceBetweenPoints3D(sX, sY, sZ, rX, rY, rZ)
		setSoundVolume(player, (range/2)-distance)

		local color = tocolor(255, 255, 255, 255)
		if(distance <= range)then
			local name=getPlayerMaskName ( player ):gsub("#%x%x%x%x%x%x","")
			local textWidth=dxGetTextWidth(name, 1, font)
			local recWidth=textWidth+40/zoom
			local av=avatars:getPlayerAvatar(player)
			local sY=(45/zoom)*index
		
			local y=radar == true and 100/zoom or 30/zoom
		
			blur:dxDrawBlur(485/zoom-y, sh-40/zoom-27/zoom-sY, recWidth, 27/zoom, tocolor(200, 200, 200))
			dxDrawImage(460/zoom-(35-27)/2/zoom-y, sh-40/zoom-27/zoom-(35-27)/2/zoom-sY, 35/zoom, 35/zoom, av)
			dxDrawText(name, 460/zoom+40/zoom-y, sh-40/zoom-27/zoom-sY, recWidth, 27/zoom+sh-40/zoom-27/zoom-sY, tocolor(194, 194, 194, 255), 1, font, "left", "center", false)
			dxDrawImage(460/zoom+recWidth+5/zoom-y, sh-40/zoom-27/zoom+(27-13)/2/zoom-sY, 13/zoom, 13/zoom, voice, 0, 0, 0, tocolor(200, 200, 200, 255), false)

			if(not isVoiceEnabled(player))then
				voicePlayers[player]=nil
			end
		end

		index = index + 1
	end
end

addEventHandler("onClientPlayerVoiceStart", root, function()
	blur=exports.blur
	avatars=exports.px_avatars
	dashboard=exports.px_dashboard

	if(getElementData(source, "voice:to"))then 
		setElementData(source, "voice:to_say", true)
		return 
	end

	if(getElementData(localPlayer, "voice:to"))then 
		setElementData(localPlayer, "voice:to_say", true)
		return 
	end

	local level=getElementData(source, "user:level") or 1
	if(level < 20)then
		cancelEvent()
		return
	end

	if(not getElementData(source, "user:logged"))then cancelEvent() return end
	if(not getElementData(localPlayer, "user:logged"))then cancelEvent() return end
	if(not dashboard:getSettingState("voice_chat", source))then cancelEvent() return end
	if(not dashboard:getSettingState("voice_chat"))then cancelEvent() return end
	if(getElementData(source, "user:voice_mute"))then cancelEvent() return end
	if(getElementData(localPlayer, "user:voice_mute"))then cancelEvent() return end

	local localDimension = getElementDimension(localPlayer)
	local localInterior = getElementInterior(localPlayer)
	if(source == localPlayer)then
		if(table.size(voicePlayers) == 0)then
			addEventHandler("onClientRender", root, onRender)
		end

		voicePlayers[source] = true
		setElementData(localPlayer, "voice:say", true)
	else
		local sourceDimension = getElementDimension(source)
		local sourceInterior = getElementInterior(source)
		if(tonumber(localDimension) ~= tonumber(sourceDimension) or tonumber(localInterior) ~= tonumber(sourceInterior))then
			cancelEvent()
			return
		end

		local sX, sY, sZ = getElementPosition(localPlayer)
		local rX, rY, rZ = getElementPosition(source)
		local distance = getDistanceBetweenPoints3D(sX, sY, sZ, rX, rY, rZ)
		if(distance <= range)then
			local block=exports.px_interaction:isPlayerBlocked(source)
			if(block)then
				cancelEvent()
			else
				if(table.size(voicePlayers) == 0)then
					addEventHandler("onClientRender", root, onRender)
				end

				voicePlayers[source] = true
				setElementData(source, "voice:say", true)
			end
		else
			cancelEvent()
		end
	end
end)

addEventHandler("onClientPlayerVoiceStop", root, function()
	voicePlayers[source] = nil
	setElementData(source, "voice:say", false)
	setElementData(source, "voice:to_say", false)

	if(table.size(voicePlayers) == 0)then
		removeEventHandler("onClientRender", root, onRender)
	end
end)

addEventHandler("onClientPlayerQuit", root,function()
	voicePlayers[source] = nil

	if(table.size(voicePlayers) == 0)then
		removeEventHandler("onClientRender", root, onRender)
	end
end)

setElementData(localPlayer, "voice:to", false)

-- names

function getPlayerMaskName(player)
	return getElementData(player, "user:nameMask") or getPlayerName(player)
end