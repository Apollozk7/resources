--
-- c_bloom.lua
--

local scx, scy = guiGetScreenSize()

-----------------------------------------------------------------------------------
-- Le settings
-----------------------------------------------------------------------------------
Settings = {}
Settings.var = {}
Settings.var.cutoff = 0.08
Settings.var.power = 1.88
Settings.var.bloom = 2.0
Settings.var.blendR = 204
Settings.var.blendG = 153
Settings.var.blendB = 130
Settings.var.blendA = 140

myScreenSource = dxCreateScreenSource( scx/2, scy/2 )
blurHShader,tecName = dxCreateShader( "blurH.fx" )
blurVShader,tecName = dxCreateShader( "blurV.fx" )
brightPassShader,tecName = dxCreateShader( "brightPass.fx" )
addBlendShader,tecName = dxCreateShader( "addBlend.fx" )

addEventHandler('onClientElementDataChange', root, function(data)
	if data == 'user:dash_settings' and source == localPlayer then
		local state=exports.px_dashboard:getSettingState("bloom")
		bloom(state)
	end
end)

local b = false

function bloom(state)
	if state and not b then
		addEventHandler('onClientHUDRender', root, render)
		b = true
	elseif not state and b then
		b = false
		removeEventHandler('onClientHUDRender', root, render)
	end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
	local state=exports.px_dashboard:getSettingState("bloom")
	bloom(state)
end)


-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
function render()
	RTPool.frameStart()

	dxUpdateScreenSource( myScreenSource )

	local current = myScreenSource
	current = applyBrightPass( current, Settings.var.cutoff, Settings.var.power )
	current = applyDownsample( current )
	current = applyDownsample( current )
	current = applyGBlurH( current, Settings.var.bloom )
	current = applyGBlurV( current, Settings.var.bloom )

	dxSetRenderTarget()

	if current then
		dxSetShaderValue( addBlendShader, "TEX0", current )
		local col = tocolor(Settings.var.blendR, Settings.var.blendG, Settings.var.blendB, Settings.var.blendA)
		dxDrawImage( 0, 0, scx, scy, addBlendShader, 0,0,0, col )
	end
end


function applyDownsample( Src, amount )
	if not Src then return nil end
	amount = amount or 2
	local mx,my = dxGetMaterialSize( Src )
	mx = mx / amount
	my = my / amount
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, Src )
	return newRT
end

function applyGBlurH( Src, bloom )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( blurHShader, "TEX0", Src )
	dxSetShaderValue( blurHShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurHShader, "BLOOM", bloom )
	dxDrawImage( 0, 0, mx, my, blurHShader )
	return newRT
end

function applyGBlurV( Src, bloom )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( blurVShader, "TEX0", Src )
	dxSetShaderValue( blurVShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurVShader, "BLOOM", bloom )
	dxDrawImage( 0, 0, mx,my, blurVShader )
	return newRT
end

function applyBrightPass( Src, cutoff, power )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( brightPassShader, "TEX0", Src )
	dxSetShaderValue( brightPassShader, "CUTOFF", cutoff )
	dxSetShaderValue( brightPassShader, "POWER", power )
	dxDrawImage( 0, 0, mx,my, brightPassShader )
	return newRT
end

RTPool = {}
RTPool.list = {}

function RTPool.frameStart()
	for rt,info in pairs(RTPool.list) do
		info.bInUse = false
	end
end

function RTPool.GetUnused( mx, my )
	-- Find unused existing
	for rt,info in pairs(RTPool.list) do
		if not info.bInUse and info.mx == mx and info.my == my then
			info.bInUse = true
			return rt
		end
	end
	-- Add new
	local rt = dxCreateRenderTarget( mx, my )
	if rt then
		outputDebugString( "creating new RT " .. tostring(mx) .. " x " .. tostring(mx) )
		RTPool.list[rt] = { bInUse = true, mx = mx, my = my }
	end
	return rt
end
