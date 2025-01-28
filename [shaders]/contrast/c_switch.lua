--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart
--		Auto switch on at start
--------------------------------


--------------------------------
-- Switch effect on or off
--------------------------------
function switchContrast( bOn )
	if bOn then
		enableContrast()
	else
		disableContrast()
	end
end
addEvent( "switchContrast", true )
addEventHandler( "switchContrast", resourceRoot, switchContrast )

addEventHandler('onClientElementDataChange', root, function(data)
	if data == 'user:dash_settings' and source == localPlayer then
		local state=exports.px_dashboard:getSettingState("detals_contrast")
		bloom(state)
	end
end)

local b = false

function bloom(state)
	if state and not b then
		switchContrast(true)

		b = true

		addEventHandler( "onClientHUDRender", root, hudRender)
	elseif not state and b then
		switchContrast(false)

		b = false

		removeEventHandler( "onClientHUDRender", root, hudRender)
	end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
	local state=exports.px_dashboard:getSettingState("detals_contrast")
	bloom(state)
end)
