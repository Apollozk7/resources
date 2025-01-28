--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "onClientSwitchDetail", root, true )
--
--	To switch off:
--			triggerEvent( "onClientSwitchDetail", root, false )
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
function handleOnClientSwitchDetail( bOn )
	outputDebugString( "switchDetail: " .. tostring(bOn) )
	if bOn then
		enableDetail()
	else
		disableDetail()
	end
end

addEvent( "onClientSwitchDetail", true )
addEventHandler( "onClientSwitchDetail", resourceRoot, handleOnClientSwitchDetail )

addEventHandler('onClientElementDataChange', root, function(data)
	if data == 'user:dash_settings' and source == localPlayer then
		local state=exports.px_dashboard:getSettingState("detals")
		bloom(state)
	end
end)

local b = false

function bloom(state)
	if state and not b then
		enableDetail()

		b = true
	elseif not state and b then
		disableDetail()

		b = false
	end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
	local state=exports.px_dashboard:getSettingState("detals")
	bloom(state)
end)
