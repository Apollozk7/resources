--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local UI={}

UI.images={}
UI.fonts={}

UI.textures={}
UI.text_textures={}

UI.markers={}

UI.rot=0

UI.tick=getTickCount()

-- create

UI.getDistanceOfMarker=function(marker)
	local myPos={getElementPosition(localPlayer)}
	local mPos={getElementPosition(marker)}
	local distance=getDistanceBetweenPoints3D(myPos[1], myPos[2], myPos[3], mPos[1], mPos[2], mPos[3])
	return distance
end

UI.createTexture=function(marker, icon)
	UI.textures[marker]=dxCreateTexture(icon, "argb", false, "clamp")
end

UI.createTextTexture=function(marker, text, desc, w, h, color)
	local fontSize=1
	local tw=dxGetTextWidth(desc, fontSize, UI.fonts.font2)
	while(tw > w)do
		fontSize=fontSize-0.1
		tw=dxGetTextWidth(desc, fontSize, UI.fonts.font2)
	end

	local fontSize2=1
	local tw2=dxGetTextWidth(text, fontSize2, UI.fonts.font1)
	while(tw2 > w)do
		fontSize2=fontSize2-0.1
		tw2=dxGetTextWidth(text, fontSize2, UI.fonts.font1)
	end

	local target=dxCreateRenderTarget(w, h, true)
	dxSetRenderTarget(target, true)
		dxDrawTextShadow(text, 0, h/2-15, w, h, tocolor(255, 255, 255), fontSize2, UI.fonts.font1, "center", "top")
		dxDrawTextShadow(desc, 0, 150, w, h, tocolor(color[1], color[2], color[3]), fontSize, UI.fonts.font2, "center", "center")
	dxSetRenderTarget()

	UI.text_textures[marker]=target
end

-- destroy

UI.destroyTexture=function(marker)
	if(UI.textures[marker])then
		if(isElement(UI.textures[marker]))then
			destroyElement(UI.textures[marker])
		end
		UI.textures[marker]=nil
	end
end

UI.destroyTextTexture=function(marker)
	if(UI.text_textures[marker])then
		if(isElement(UI.text_textures[marker]))then
			destroyElement(UI.text_textures[marker])
		end
		UI.text_textures[marker]=nil
	end
end

-- load

UI.loadMarker=function(marker)
	if(table.size(UI.markers) == 0)then
		addEventHandler("onClientRender", root, UI.onRender)

		UI.images={
			["holder"]=dxCreateTexture("assets/images/holder.png", "argb", false, "clamp"),
			["shadow"]=dxCreateTexture("assets/images/shadow.png", "argb", false, "clamp"),
			["place"]=dxCreateTexture("assets/images/place.png", "argb", false, "clamp")
		}

		UI.fonts={
			font1=dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 40),
			font2=dxCreateFont(":px_assets/fonts/Font-ExtraBold.ttf", 30)
		}
	end

	UI.markers[marker]=marker

	local icon=getElementData(marker, "icon")
	if(icon and fileExists(icon) and not UI.textures[marker])then
		UI.createTexture(marker, icon)
	end

	local data=getElementData(marker, "text")
	if(data and data.text and data.desc)then
		UI.createTextTexture(marker, data.text, data.desc, 500, 250, {getMarkerColor(marker)})
	end

	setElementAlpha(marker, 0)
end

UI.unloadMarker=function(marker)
	if(UI.markers[marker])then
		UI.markers[marker]=nil
	end

	UI.destroyTexture(marker)
	UI.destroyTextTexture(marker)

	if(table.size(UI.markers) < 1)then
		removeEventHandler("onClientRender", root, UI.onRender)

		for i,v in pairs(UI.images) do
			if(v and isElement(v))then
				destroyElement(v)
			end
		end

		for i,v in pairs(UI.fonts) do
			if(v and isElement(v))then
				destroyElement(v)
			end
		end

		UI.images={}
		UI.fonts={}
	end
end

-- render

UI.onRender=function()
	UI.rot=UI.rot+1

	for i,v in pairs(UI.markers) do
		if(UI.getDistanceOfMarker(v) < 50)then
			local settings=getElementData(v, "settings") or {}
			local size=getMarkerSize(v)
			local pos={getElementPosition(v)}
			local color={getMarkerColor(v)}
			local holder=UI.textures[v] and UI.textures[v] or false

			-- assign
			if(getElementData(v, "out:place"))then
				settings.offPlace=true
			end
			if(getElementData(v, "out:icon"))then
				settings.offIcon=true
			end
			if(getElementData(v, "off:outline"))then
				settings.offOutline=true
			end
			--

			local pos_z=getElementData(v, "pos:z") 
			local z=pos[3]
			if(not pos_z)then
				pos[3]=getGroundPosition(pos[1], pos[2], pos[3])+0.01
				setElementData(v, "pos:z", pos[3], true)
			else
				if(not tonumber(pos_z))then
					pos[3]=getGroundPosition(pos[1], pos[2], pos[3])+0.01
					setElementData(v, "pos:z", pos[3], true)
				else
					pos[3]=pos_z or pos[3]
				end
			end
			if(getElementData(v, "block:z"))then
				pos[3]=z
			end

			size=interpolateBetween(size-0.5, 0, 0, size-0.55, 0, 0, (getTickCount()-UI.tick)/3500, "SineCurve")

			local sizex=interpolateBetween((size*3)-0.5, 0, 0, (size*3)-0.55, 0, 0, (getTickCount()-UI.tick)/3500, "SineCurve")
			if(not settings or (settings and not settings.offPlace))then
				local s={pos[1], pos[2]-1*sizex, pos[3]}
				local s2={pos[1], pos[2]+1*sizex, pos[3]}
				dxDrawMaterialLine3D(s[1], s[2], s[3], s2[1], s2[2], s2[3], UI.images.place, 2*sizex, tocolor(color[1], color[2], color[3], 50), pos[1], pos[2], pos[3]+1)
			end

			if(not settings.offIcon)then
				local size=0.8
				local x,y = getPointFromDistanceRotation(pos[1], pos[2], UI.rot)
				pos[3]=pos[3]+1

				if(not settings.offOutline)then
					dxDrawMaterialLine3D(pos[1],pos[2],pos[3]+size,pos[1],pos[2],pos[3], UI.images.holder, size, tocolor(color[1],color[2],color[3]), x, y, pos[3])
				end

				if(holder)then
					dxDrawMaterialLine3D(pos[1],pos[2],pos[3]+size,pos[1],pos[2],pos[3], holder, size, tocolor(255,255,255), x, y, pos[3])
				end

				if(settings.holderAvatar)then
					local z=pos[3]-0.52
					dxDrawMaterialLine3D(pos[1],pos[2],z+size/3.4,pos[1],pos[2],z, UI.images.shadow, size/3.4, tocolor(255,255,255,255))

					local z=pos[3]-0.5
					dxDrawMaterialLine3D(pos[1],pos[2],z+size/4,pos[1],pos[2],z, exports.px_avatars:getPlayerAvatar(settings.holderAvatar), size/4, tocolor(255,255,255,255))
				end

				if(UI.text_textures[v] and isElement(UI.text_textures[v]))then
					pos[3]=pos[3]-0.3
					dxDrawMaterialLine3D(pos[1],pos[2],pos[3]+0.5,pos[1],pos[2],pos[3], UI.text_textures[v], 1, tocolor(255, 255, 255))
				end
			end
		end
	end
end

-- events

addEventHandler("onClientPlayerSpawn", localPlayer, function()
	for i,v in pairs(getElementsByType("marker", root, true)) do
		if(getMarkerType(v) == "cylinder")then
			UI.loadMarker(v)
		end
	end
end)

addEventHandler("onClientElementDestroy", root, function()
	if(source and isElement(source) and getElementType(source) == "marker" and getMarkerType(source) == "cylinder")then
		UI.unloadMarker(source)
	end
end)

addEventHandler("onClientElementStreamIn", root, function()
	if(source and isElement(source) and getElementType(source) == "marker" and getMarkerType(source) == "cylinder")then
		UI.loadMarker(source)
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if(source and isElement(source) and getElementType(source) == "marker" and getMarkerType(source) == "cylinder")then
		UI.unloadMarker(source)
	end
end)

addEventHandler("onClientElementDataChange", root, function(key, old, new)
	if(getElementType(source) == "marker" and key == "text")then
		UI.unloadMarker(source)
		UI.loadMarker(source)
	end
end)

addEventHandler("onClientRestore", root, function(clear)
	for i,v in pairs(UI.markers) do
		if(UI.getDistanceOfMarker(v) < 50)then
			if(getElementData(v, "text"))then
				if(UI.text_textures[v] and isElement(UI.text_textures[v]))then
					destroyElement(UI.text_textures[v])
					UI.text_textures[v]=nil
				end
				
				local data=getElementData(v, "text")
				if(data and data.text and data.desc)then
					UI.createTextTexture(v, data.text, data.desc, 500, 250, {getMarkerColor(v)})
				end
			end
		end
	end
end)


-- useful by Asper

local shadow = tocolor(0, 0, 0, 20)

function dxDrawTextShadow( text, x, y, w, h, color, fontSize, fontType, alignX, alignY )
	local sx=5
	dxDrawText( text, x+sx, y+sx, w, h, shadow, fontSize, fontType, alignX, alignY, false)
	dxDrawText( text, x-sx, y+sx, w, h, shadow, fontSize, fontType, alignX, alignY, false)
	dxDrawText( text, x-sx, y-sx, w, h, shadow, fontSize, fontType, alignX, alignY, false)
	dxDrawText( text, x+sx, y-sx, w, h, shadow, fontSize, fontType, alignX, alignY, false)
	dxDrawText(text, x+1, y+1, w+1, h+1, tocolor(0,0,0), fontSize, fontType, alignX, alignY, false)
	dxDrawText(text, x, y, w, h, color, fontSize, fontType, alignX, alignY, false)
end

-- useful

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

-- on start

for i,v in pairs(getElementsByType("marker", root, true)) do
	if(getMarkerType(v) == "cylinder")then
		UI.loadMarker(v)
	end
end

--

function getPointFromDistanceRotation(x, y, angler)
    local a = math.rad(270 - angler)
    local dx = math.cos(a)
    local dy = math.sin(a)
    return x+dx, y+dy
end