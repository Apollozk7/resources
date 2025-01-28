--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local ui={}

ui.musicPlaces={
    {pos={464.000, 1102.000, 18.000, 0.000, 0.000, 121.000},name="Rolnik",distance=200},
}

addEventHandler("onClientElementDataChange", root, function(data,last,new)
	if data == "user:dash_settings" and source == localPlayer then
		local state=exports.px_dashboard:getSettingState("3dmusic")
        if(state)then
            for i,v in pairs(ui.musicPlaces) do
                if(v.music)then
                    destroyElement(v.music)
                    v.music=nil
                end
            end
        else
            for i,v in pairs(ui.musicPlaces) do
                if(not v.music)then
                    v.music=playSound3D("https://radioparty.pl/kanalglowny", v.pos[1], v.pos[2], v.pos[3])
                    setSoundMaxDistance(v.music, v.distance)
                end
            end
        end
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    local state=exports.px_dashboard:getSettingState("3dmusic")
    if(not state)then
        for i,v in pairs(ui.musicPlaces) do
            v.music=playSound3D("https://radioparty.pl/kanalglowny", v.pos[1], v.pos[2], v.pos[3])
            setSoundMaxDistance(v.music, v.distance)
        end
    end
end)
