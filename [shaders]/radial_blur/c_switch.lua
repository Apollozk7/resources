--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchRadialBlur", root, true )
--
--	To switch off:
--			triggerEvent( "switchRadialBlur", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart
--		Auto switch on at start
--------------------------------

--------------------------------
-- Switch effect on or off
--------------------------------
function switchRadialBlur( bOn )
	outputDebugString( "switchRadialBlur: " .. tostring(bOn) )
	if bOn then
		enableRadialBlur()
	else
		disableRadialBlur()
	end
end

addEvent( "switchRadialBlur", true )
addEventHandler( "switchRadialBlur", resourceRoot, switchRadialBlur )

addEventHandler('onClientElementDataChange', root, function(data)
	if data == 'user:dash_settings' and source == localPlayer then
		local state=exports.px_dashboard:getSettingState("blur")
		bloom(state)
	end
end)

local b = false

function bloom(state)
	if state and not b then
		enableRadialBlur()

		b = true

		addEventHandler( "onClientHUDRender", root, hudRender, true ,"low" .. orderPriority )
	elseif not state and b then
		disableRadialBlur()

		b = false

		removeEventHandler( "onClientHUDRender", root, hudRender, true ,"low" .. orderPriority )
	end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
	local state=exports.px_dashboard:getSettingState("blur")
	bloom(state)
end)

setBlurLevel(0)