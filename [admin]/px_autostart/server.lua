--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

for i,v in pairs(getResources()) do
    local name=getResourceName(v)
    if((getResourceState(v) == "loaded" or getResourceState(v) == "stopping"))then
        startResource(v,true)
    end
end