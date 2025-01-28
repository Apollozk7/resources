--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local nazwaCzesci = {
	[1000]="Pro",
	[1001]="Win",
	[1002]="Drag",
	[1003]="Alpha",
	[1004]="Champ Scoop",
	[1005]="Fury Scoop",
	[1006]="Roof Scoop",
	[1007]="Right Sideskirt",
	[1008]="Pakiet NOS x5",
	[1009]="Pakiet NOS x2",
	[1010]="Pakiet NOS x10",
	[1011]="Race Scoop",
	[1012]="orx Scoop",
	[1013]="Round Fog",
	[1014]="Champ",
	[1015]="Race",
	[1016]="Worx",
	[1017]="Left Sideskirt",
	[1018]="Upswept",
	[1019]="Twin",
	[1020]="Duży",
	[1021]="Średni",
	[1022]="Mały",
	[1023]="Fury",
	[1024]="Square Fog",
	[1025]="Offroad",
	[1026]="Right Alien Sideskirt",
	[1027]="Left Alien Sideskirt",
	[1028]="Alien",
	[1029]="X-Flow",
	[1030]="Left X-Flow Sideskirt",
	[1031]="Right X-Flow Sideskirt",
	[1032]="Alien Roof Vent",
	[1033]="X-Flow Roof Vent",
	[1034]="Alien",
	[1035]="X-Flow Roof Vent",
	[1036]="Right Alien Sideskirt",
	[1037]="X-Flow",
	[1038]="Alien Roof Vent",
	[1039]="Left X-Flow Sideskirt",
	[1040]="Left Alien Sideskirt",
	[1041]="Right X-Flow Sideskirt",
	[1042]="Right Chrome Sideskirt",
	[1043]="Slamin",
	[1044]="Chrome",
	[1045]="X-Flow",
	[1046]="Alien",
	[1047]="Right Alien Sideskirt",
	[1048]="Right X-Flow Sideskirt",
	[1049]="Alien",
	[1050]="X-Flow",
	[1051]="Left Alien Sideskirt",
	[1052]="Left X-Flow Sideskirt",
	[1053]="X-Flow",
	[1054]="Alien",
	[1055]="Alien",
	[1056]="Right Alien Sideskirt",
	[1057]="Right X-Flow Sideskirt",
	[1058]="Alien",
	[1059]="X-Flow",
	[1060]="X-Flow",
	[1061]="X-Flow",
	[1062]="Left Alien Sideskirt",
	[1063]="Left X-Flow Sideskirt",
	[1064]="Alien",
	[1065]="Alien",
	[1066]="X-Flow",
	[1067]="Alien",
	[1068]="X-Flow",
	[1069]="Right Alien Sideskirt",
	[1070]="Right X-Flow Sideskirt",
	[1071]="Left Alien Sideskirt",
	[1072]="Left X-Flow Sideskirt",
	[1073]="Shadow",
	[1074]="Mega",
	[1075]="Rimshine",
	[1076]="Wires",
	[1077]="Classic",
	[1078]="Twist",
	[1079]="Cutter",
	[1080]="Switch",
	[1081]="Grove",
	[1082]="Import",
	[1083]="Dollar",
	[1084]="Trance",
	[1085]="Atomic",
	[1086]="Stereo",
	[1087]="Hydraulics",
	[1088]="Alien",
	[1089]="X-Flow",
	[1090]="Right Alien Sideskirt",
	[1091]="X-Flow",
	[1092]="Alien",
	[1093]="Right X-Flow Sideskirt",
	[1094]="Left Alien Sideskirt",
	[1095]="Right X-Flow Sideskirt",
	[1096]="Ahab",
	[1097]="Virtual",
	[1098]="Access",
	[1099]="Left Chrome Sideskirt",
	[1100]="Chrome Grill",
	[1101]="Left `Chrome Flames` Sideskirt",
	[1102]="Left `Chrome Strip` Sideskirt",
	[1103]="Covertible",
	[1104]="Chrome",
	[1105]="Slamin",
	[1106]="Right `Chrome Arches`",
	[1107]="Left `Chrome Strip` Sideskirt",
	[1108]="Right `Chrome Strip` Sideskirt",
	[1109]="Chrome",
	[1110]="Slamin",
	[1111]="Front Sign? Little Sign?",
	[1112]="Front Sign? Little Sign?",
	[1113]="Chrome",
	[1114]="Slamin",
	[1115]="Front Bullbars Chrome",
	[1116]="Front Bullbars Slamin",
	[1117]="Przedni zderzak Chrome",
	[1118]="Right `Chrome Trim` Sideskirt",
	[1119]="Right `Wheelcovers` Sideskirt",
	[1120]="Left `Chrome Trim` Sideskirt",
	[1121]="Left `Wheelcovers` Sideskirt",
	[1122]="Right `Chrome Flames` Sideskirt",
	[1123]="Bullbar Chrome Bars",
	[1124]="Left `Chrome Arches` Sideskirt",
	[1125]="Bullbar Chrome Lights",
	[1126]="Chrome Exhaust",
	[1127]="Slamin Exhaust",
	[1128]="Vinyl Hardtop",
	[1129]="Chrome",
	[1130]="Hardtop",
	[1131]="Softtop",
	[1132]="Slamin",
	[1133]="Right `Chrome Strip` Sideskirt",
	[1134]="Right `Chrome Strip` Sideskirt",
	[1135]="Slamin",
	[1136]="Chrome",
	[1137]="Left `Chrome Strip` Sideskirt",
	[1138]="Alien",
	[1139]="X-Flow",
	[1140]="Tylny zderzak X-Flow",
	[1141]="Tylny zderzak Alien",
	[1142]="Left Oval Vents",
	[1143]="Right Oval Vents",
	[1144]="Left Square Vents",
	[1145]="Right Square Vents",
	[1146]="X-Flow",
	[1147]="Alien",
	[1148]="Tylny zderzak X-Flow",
	[1149]="Tylny zderzak Alien",
	[1150]="Tylny zderzak Alien",
	[1151]="Tylny zderzak X-Flow",
	[1152]="Przedni zderzak X-Flow",
	[1153]="Przedni zderzak Alien",
	[1154]="Tylny zderzak Alien",
	[1155]="Przedni zderzak Alien",
	[1156]="Tylny zderzak X-Flow",
	[1157]="Przedni zderzak X-Flow",
	[1158]="X-Flow",
	[1159]="Tylny zderzak Alien",
	[1160]="Przedni zderzak Alien",
	[1161]="Tylny zderzak X-Flow",
	[1162]="Alien",
	[1163]="X-Flow",
	[1164]="Alien",
	[1165]="Przedni zderzak X-Flow",
	[1166]="Przedni zderzak Alien",
	[1167]="Tylny zderzak X-Flow",
	[1168]="Tylny zderzak Alien",
	[1169]="Przedni zderzak Alien",
	[1170]="Przedni zderzak X-Flow",
	[1171]="Przedni zderzak Alien",
	[1172]="Przedni zderzak X-Flow",
	[1173]="Przedni zderzak X-Flow",
	[1174]="Przedni zderzak Chrome",
	[1175]="Tylny zderzak Slamin",
	[1176]="Przedni zderzak Chrome",
	[1177]="Tylny zderzak Slamin",
	[1178]="Tylny zderzak Slamin",
	[1179]="Przedni zderzak Chrome",
	[1180]="Tylny zderzak Chrome",
	[1181]="Przedni zderzak Slamin",
	[1182]="Przedni zderzak Chrome",
	[1183]="Tylny zderzak Slamin",
	[1184]="Tylny zderzak Chrome",
	[1185]="Przedni zderzak Slamin",
	[1186]="Tylny zderzak Slamin",
	[1187]="Tylny zderzak Chrome",
	[1188]="Przedni zderzak Slamin",
	[1189]="Przedni zderzak Chrome",
	[1190]="Przedni zderzak Slamin",
	[1191]="Przedni zderzak Chrome",
	[1192]="Tylny zderzak Chrome",
	[1193]="Tylny zderzak Slamin",
}

local cenaCzesci = {
	-- felgi
	[1025]=4000,
	[1073]=7600,
	[1074]=10900,
	[1075]=6300,
	[1076]=10900,
	[1077]=7600,
	[1078]=6050,
	[1079]=5500,
	[1081]=8500,
	[1082]=9350,
	[1096]=9700,
	[1097]=6600,
	[1098]=8900,
	[1080]=9200,
	[1083]=10300,
	[1084]=11400,
	[1085]=7800,

	-- stereo
	[1086]=1000,
	
	-- reszta
	[1000]=9100,
	[1001]=8990,
	[1002]=9100,
	[1003]=8800,
	[1014]=9550,
	[1015]=9490,
	[1016]=9150,
	[1023]=9600,
	[1049]=13490,
	[1050]=9050,
	[1058]=9700,
	[1060]=10200,
	[1138]=15200,
	[1139]=10250,
	[1146]=13100,
	[1147]=12950,
	[1158]=16150,
	[1162]=10900,
	[1163]=8250,
	[1164]=8500,
	[1036]=11500,
	[1039]=13900,
	[1040]=12600,
	[1041]=13900,
	[1007]=5250,
	[1017]=6400,
	[1026]=11250,
	[1027]=10900,
	[1030]=12500,
	[1031]=11600,
	[1042]=7700,
	[1047]=11900,
	[1048]=10790,
	[1051]=13500,
	[1052]=9800,
	[1056]=9890,
	[1057]=9660,
	[1062]=8900,
	[1063]=10200,
	[1069]=10700,
	[1070]=10200,
	[1071]=12000,
	[1072]=11600,
	[1090]=9400,
	[1093]=10500,
	[1094]=10200,
	[1095]=11100,
	[1099]=7700,
	[1101]=8500,
	[1102]=7900,
	[1106]=7900,
	[1107]=6500,
	[1108]=8100,
	[1118]=9250,
	[1119]=8950,
	[1120]=9420,
	[1121]=8950,
	[1122]=7250,
	[1124]=7900,
	[1133]=8150,
	[1134]=9150,
	[1137]=8550,
	[1100]=11500,
	[1115]=12500,
	[1116]=11950,
	[1123]=12300,
	[1125]=9520,
	[1109]=14500,
	[1110]=8550,
	[1111]=8300,
	[1112]=8450,
	[1087]=34900,
	[1034]=12500,
	[1037]=10900,
	[1044]=9240,
	[1046]=8240,
	[1018]=10500,
	[1019]=10250,
	[1020]=11500,
	[1021]=10250,
	[1022]=10400,
	[1028]=13900,
	[1029]=12490,
	[1043]=8250,
	[1044]=8650,
	[1045]=10700,
	[1059]=11400,
	[1064]=11890,
	[1065]=10800,
	[1066]=11050,
	[1089]=11890,
	[1092]=11290,
	[1104]=9140,
	[1105]=9440,
	[1113]=10700,
	[1114]=11090,
	[1126]=10900,
	[1127]=11300,
	[1129]=9100,
	[1132]=9700,
	[1135]=8800,
	[1136]=9100,
	[1149]=17900,
	[1148]=18850,
	[1150]=14700,
	[1151]=16890,
	[1154]=13800,
	[1156]=16890,
	[1159]=14900,
	[1161]=16890,
	[1167]=15590,
	[1168]=13800,
	[1175]=8900,
	[1177]=9250,
	[1178]=8900,
	[1180]=9250,
	[1183]=8890,
	[1184]=8350,
	[1186]=9100,
	[1187]=8950,
	[1192]=6500,
	[1193]=6890,
	[1171]=17800,
	[1172]=12900,
	[1140]=16700,
	[1141]=14300,
	[1117]=9800,
	[1152]=13890,
	[1155]=16890,
	[1153]=16890,
	[1157]=13800,
	[1160]=16890,
	[1165]=13200,
	[1166]=16890,
	[1169]=16890,
	[1170]=13200,
	[1173]=13890,
	[1174]=8250,
	[1176]=7900,
	[1179]=8550,
	[1181]=8690,
	[1182]=7900,
	[1185]=9050,
	[1188]=8200,
	[1189]=9000,
	[1190]=8200,
	[1191]=7990,
	[1035]=13900,
	[1038]=12900,
	[1006]=9050,
	[1032]=12900,
	[1033]=13900,
	[1053]=12900,
	[1054]=13900,
	[1055]=12900,
	[1061]=13900,
	[1068]=12900,
	[1067]=13900,
	[1088]=12900,
	[1091]=13900,
	[1103]=9590,
	[1128]=9900,
	[1130]=8800,
	[1131]=9090,
	[1004]=8890,
	[1005]=9150,
	[1011]=8890,
	[1012]=7550,
	[1142]=8550,
	[1143]=8900,
	[1144]=7900,
	[1145]=8490,
	[1013]=9500,
	[1024]=15000,

	-- nitro
	[1009]=50000, -- x2
	[1008]=60000, -- x5
	[1010]=70000, -- x10
}

local mechanic={
	["Opona 14'"]={cost=2000, data="vehicle:wheelsSettings", index="tire", kategoria="Tires", id=1},
	["Opona 16'"]={cost=4000, data="vehicle:wheelsSettings", index="tire", kategoria="Tires", id=2},
	["Opona 18'"]={cost=8000, data="vehicle:wheelsSettings", index="tire", kategoria="Tires", id=3},
	["Opona 20'"]={cost=11500, data="vehicle:wheelsSettings", index="tire", kategoria="Tires", id=4},

	["Opona terenowa"]={cost=35000, data="vehicle:wheelsSettings", index="tire", kategoria="Tires", id=5},
}

local nazwySlotow={
	["Hood"]="Wlot na maske",
	["Vent"]="Wlot na maske",
	["Sideskirt"]="Progi",
	["Front Bullbars"]="Przedni zderzak",
	["Rear Bullbars"]="Tylni zderzak",
	["Headlights"]="Swiatła",
	["Roof"]="Wlot na dach",
	["Wheels"]="Felgi",
	["Exhaust"]="Wydech",
	["Spoiler"]="Spoiler",
	["Tires"]="Opony",
	["Chain"]="Łancuchy",
}

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end

function getVehicleUpgradeInfo(id)
	local slot=getVehicleUpgradeSlotName(id)
	slot=nazwySlotow[slot] or slot

	local name=nazwaCzesci[id] or id

	return name.." ("..slot..")"
end

function setCost(cost, discount, type, veh)
	local org=getElementData(veh, "vehicle:group_owner")
	if(org)then
		cost=cost*3
	end

	if(not type)then
		discount=10*((100-discount)/100)
		discount=math.percent(discount,cost)
		cost=cost+discount
		return math.floor(cost), math.floor(discount)
	else
		discount=10*((100-discount)/100)
		discount=math.percent(discount,cost)
		cost=cost-discount
		return math.floor(cost), math.floor(discount)
	end
end

function fillVehicleData(veh, discount)
	veh=veh or getPedOccupiedVehicle(localPlayer)
	local items = {}
	for i=0,16 do
		for i2,v2 in pairs(getVehicleCompatibleUpgrades(veh, i)) do
			local nazwa=nazwaCzesci[v2] or "(?)"
			if((nazwa == "Stereo" and getVehicleName(veh) == "Pony") or nazwa ~= "Stereo")then
				local cena=cenaCzesci[v2] or 0
				local kategoria=getVehicleUpgradeSlotName(v2)
				local slot=nazwySlotow[kategoria] or ""
				local demontaz=false

				if(kategoria == "Nitro")then
					nazwa="Atrapa "..nazwa
				end

				local cost,rabat=setCost(cena, discount, false, veh)
				if isVehicleHaveUpgrade(v2,veh) then
					demontaz=true
					cena=math.percent(35,cena)
					cost,rabat=setCost(cena, discount, true, veh)
				end

				items[#items+1] = {id=#items+1, name=slot.." "..nazwa, cost=cost, discount=rabat, kategoria=kategoria, demontaz=demontaz, id_czesci=v2}
			end
		end
	end

	for i,v in pairs(mechanic) do
		local cost=v.cost or 0
		local cost,discount=setCost(cost, discount, false, veh)
		local data=getElementData(veh, v.data)
		if(v.index == "tire")then
			items[#items+1]={id=v.id, name=i, cost=cost, discount=discount, kategoria=v.kategoria, id_czesci=i, data_name=v.data, data_index=v.index, demontaz=data and data.tire and data.tire == v.id}
		else
			items[#items+1]={id=v.id, name=i, cost=cost, discount=discount, kategoria=v.kategoria, id_czesci=i, data_name=v.data, data_index=v.index, demontaz=data and data.chain}
		end
	end

	return items
end

function isVehicleHaveUpgrade(id,veh)
	local have=false
	for i,v in pairs(getVehicleUpgrades(veh)) do
		if(id == v)then
			have=true
			break
		end
	end
	return have
end