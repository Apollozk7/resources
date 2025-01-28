local scx, scy = guiGetScreenSize()

Settings = {}
Settings.var = {}
Settings.var.blur = 1
Settings.var.optim = 5
Settings.screenRectangle = {}

local current=false

local last_tick = getTickCount()
local disabled_rt = false

function createShader()
    myScreenSource = dxCreateScreenSource( scx/Settings.var.optim, scy/Settings.var.optim )
    blurHShader,tecName = dxCreateShader( "shaders/blurH.fx" )
    blurVShader,tecName = dxCreateShader( "shaders/blurV.fx" )
	bAllValid = myScreenSource and blurHShader and blurVShader 
end

function destroyShader()
	destroyElement(myScreenSource)
	destroyElement(blurHShader)
	destroyElement(blurVShader)
end

function dxDrawBlur(pos_x, pos_y, size_x, size_y, color)
    if current and not off then
		last_tick = getTickCount()
		
    	if disabled_rt then
    		disabled_rt = false
    		addEventHandler ("onClientHUDRender", root, preRender)
    	end

		dxDrawImageSection  ( pos_x, pos_y, size_x, size_y, pos_x/Settings.var.optim, pos_y/Settings.var.optim, size_x/Settings.var.optim, size_y/Settings.var.optim, current, 0,0,0, color)
    end
end

function preRender ()
	if ((getTickCount()-last_tick) > 100 and current and not disabled_rt) or off then
		removeEventHandler ("onClientHUDRender", root, preRender)
		disabled_rt=true
		return
	end

	RTPool.frameStart()
	dxUpdateScreenSource( myScreenSource )
	current = myScreenSource
	current = applyGBlurH( current, Settings.var.blur )
	current = applyGBlurV( current, Settings.var.blur )
	current = applyGBlurH( current, Settings.var.blur )
	current = applyGBlurV( current, Settings.var.blur )
	dxSetRenderTarget()
end

function applyGBlurH( Src, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurHShader, "TEX0", Src )
	dxSetShaderValue( blurHShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurHShader, "BLUR", blur )
	dxDrawImage( 0, 0, mx, my, blurHShader )
	return newRT
end

function applyGBlurV( Src, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurVShader, "TEX0", Src )
	dxSetShaderValue( blurVShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurVShader, "BLUR", blur )
	dxDrawImage( 0, 0, mx,my, blurVShader )
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
		RTPool.list[rt] = { bInUse = true, mx = mx, my = my }
	end
	return rt
end

-- on start
createShader()
addEventHandler("onClientHUDRender", root, preRender)