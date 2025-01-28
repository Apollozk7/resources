--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchDynamicSky", root, true )
--
--	To switch off:
--			triggerEvent( "switchDynamicSky", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart
-- Auto switch on at start
--------------------------------



addEventHandler('onClientElementDataChange', root, function(data)
	if data == 'user:dash_settings' and source == localPlayer then
		local state=exports.px_dashboard:getSettingState("sky")
		bloom(state)
	end
end)

local b = false

function bloom(state)
	if state and not b then
		startDynamicSky()

		b = true

		addEventHandler( "onClientPreRender", root, preRender)
	elseif not state and b then
		stopDynamicSky()

		b = false

		removeEventHandler( "onClientPreRender", root, preRender)
	end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
	local state=exports.px_dashboard:getSettingState("sky")
	bloom(state)
end)
