--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local peds = {
	-- urzad lv
	{171, 930.5802,1711.0312,8.8516,352.8541,0,0, {name="Urzędnik", desc=""}},
	{172, 928.1727,1711.2042,8.8516,353.2867,0,0, {name="Urzędnik", desc=""}},
	{120, 930.5778,1721.2960,8.8516,182.6377,0,0, {name="Urzędnik", desc=""}},
	{171, 928.2538,1721.2096,8.8516,182.7102,0,0, {name="Urzędnik", desc=""}},

	{147, 926.8454,1734.1951,8.8516,272.8061,0,0, {name="Urzędnik", desc=""}},
	{59, 926.9538,1732.1586,8.8516,268.4194,0,0, {name="Urzędnik", desc=""}},

	{171, 930.3441,1745.2507,8.8516,359.9616,0,0, {name="Urzędnik", desc=""}},

	{258, 928.2438,1755.2572,8.8516,178.4194,0,0, {name="Urzędnik", desc=""}},
	{187, 930.3525,1755.2581,8.8516,178.4194,0,0, {name="Urzędnik", desc=""}},

	-- osk lv
	{127, 1167.2052,1354.6533,10.8906,335.1998,0,0, {name="Egzaminator", desc="Zapraszam na egzamin!"}, {"GANGS", "prtial_gngtlkG", -1, true, false}},
	{169, 1174.1158,1353.9816,10.8906,59.3167,0,0, {name="Sekretarka Małgorzatka", desc="Na kiedy mogę umówić panu termin?"}},

	-- gielda lv
	{236, 2808.8401,1230.7576,10.8279,355.8108,0,0, {name="Właściciel giełdy", desc="Witam, w czym mogę pomóc?"}, {"RAPPING", "RAP_A_Loop", -1, true, false, false}},
	{112, 2806.7524,1244.7356,10.8279,256.6274,0,0, {name="Mirek", desc="Podpiszcie tu i gotowe!"}, {"COP_AMBIENT", "Coplook_loop", -1, true, false, false}},

	-- sapd lv
	{280, 2339.9866,2470.8325,14.9844,170.0204,0,0, {name="Funkcjonariusz", desc="W czym mogę pomóc?"}, {"GANGS", "prtial_gngtlkG", -1, true, false}},
	{281, 2337.8557,2470.8320,14.9844,187.6073,0,0, {name="Funkcjonariusz", desc="Faktycznie z Marcela jest dobry glina"}, {"GANGS", "prtial_gngtlkG", -1, true, false}},
	{280, 2338.5142,2477.9333,21.0850,81.8295,0,0, {name="Funkcjonariusz", desc="Pilnuję tu porządku"}, {"COP_AMBIENT", "Coplook_loop", -1, true, false, false}},

	-- przebieralnia lv
	{141, 2094.7236,2264.7649,11.0234,267.6660,0,0, {name="Pracownik", desc=""}},
	--

	-- mechanik lv
	{147, 2649.1997,1232.2583,10.8500,4.0376,0,0, {name="Kierownik", desc="Coś do wyklepania?"}},
	--
}

for i,v in pairs(peds) do
	local ped = createPed(v[1], v[2], v[3], v[4], v[5])
	setElementFrozen(ped, true)
	setElementDimension(ped, v[6])
	setElementInterior(ped, v[7])
	setElementData(ped, "ped:desc", v[8])
	setElementData(ped, "ghost", "all")

	if(v[9])then
		setTimer(function()
			setPedAnimation(ped, unpack(v[9]))
		end, 50, 1)
	end

	if(v[10])then
		setElementData(ped, "respawn", {v[2],v[3],v[4],v[5]}, false)
		setElementFrozen(ped, false)
		for _,k in pairs(v[10])do
			setTimer(function()
				setPedControlState(ped, k, true)
			end, 500, 1)
		end
		addEventHandler("onClientColShapeHit", v.col, function(hit, dim)
			if(getElementType(hit) == "ped" and dim)then
				local data=getElementData(hit, "respawn")
				if(data)then
					setElementPosition(hit, data[1],data[2],data[3])
					setElementRotation(hit, 0,0,data[4])
				end
			end
		end)
	end
end