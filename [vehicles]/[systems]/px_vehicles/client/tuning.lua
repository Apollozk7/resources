--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addCommandHandler ( "gvc",
    function ( )
        local theVehicle = getPedOccupiedVehicle ( localPlayer )
        if ( theVehicle ) then
            for k in pairs ( getVehicleComponents ( theVehicle ) ) do
                outputChatBox ( k )
            end
        end
    end
)

NAMES={}

NAMES.tuningSlots={
    ["Hood"]="Maska",
    ["Vent"]="Wlot na masce",
    ["Spoiler"]="Spoiler",
    ["Sideskirt"]="Boczny zderzak",
    ["Front Bullbars"]="Przedni dodatek",
    ["Rear Bullbars"]="Tylni dodatek",
    ["Headlights"]="Reflektory",
    ["Roof"]="Wlot na dach",
    ["Nitro"]="Nitro",
    ["Hydraulics"]="Hydraulika",
    ["Stereo"]="Stereo",
    ["Unknown"]="?",
    ["Wheels"]="Felgi",
    ["Exhaust"]="Wydechy",
    ["Front Bumper"]="Przedni zderzak",
    ["Rear Bumper"]="Tylni zderzak",
    ["Misc"]="Inne",
}

NAMES.tuningNames={
	[1025]="Offroad",
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
	[1083]="Dolar",
	[1084]="Trance",
	[1085]="Atomic",
	[1096]="Ahab",
	[1097]="Virtual",
	[1098]="Access",
--  Stereo
	[1086]="Stero",
--  Spoilery
	[1000]="Pro",
	[1001]="Win",
	[1002]="Drag",
	[1003]="Alpha",
	[1014]="Champ",
	[1015]="Race",
	[1016]="Worix",
	[1023]="Furry",
	[1049]="Alien",
	[1050]="X-Flow",
	[1058]="Alien",
	[1060]="X-Flow",
	[1138]="Alien Wentyl",
	[1139]="X-Flow Prog",
	[1146]="Alien wydech",
	[1147]="Alien Prog",
	[1158]="X-Flow",
	[1162]="Alien",
	[1163]="X-Flow",
	[1164]="Alien",
--	Progi
	[1036]="Alien",
	[1039]="X-Flow",
	[1040]="Alien",
	[1041]="X-Flow",
	[1007]="Czysty",
	[1017]="Czysty",
	[1026]="Alien",
	[1027]="Alien",
	[1030]="X-Flow",
	[1031]="X-Flow",
	[1042]="Chrome",
	[1047]="Alien",
	[1048]="X-Flow",
	[1051]="Alien",
	[1052]="X-Flow",
	[1056]="Alien",
	[1057]="X-Flow",
	[1062]="Alien",
	[1063]="X-Flow",
	[1069]="Alien",
	[1070]="X-Flow",
	[1071]="Alien",
	[1072]="X-Flow",
	[1090]="Alien",
	[1093]="X-Flow",
	[1094]="Alien",
	[1095]="X-Flow",
	[1099]="Chrome",
	[1101]="Chrome Flames",
	[1102]="Chrome Strip",
	[1106]="Chrome Arches",
	[1107]="Chrome Strip",
	[1108]="Chrome Strip",
	[1118]="Chrome Trim",
	[1119]="Wheel Covers",
	[1120]="Chrome Trim",
	[1121]="Wheelcovers",
	[1122]="Chrome Flames",
	[1124]="Chrome Arches",
	[1133]="Chrome Strip",
	[1134]="Chrome Strip",
	[1137]="Chrome Strip",

--  Bullbar . . ? [przod]
	[1100]="Chrome Grill",
	[1115]="Chrome",
	[1116]="Slamin",
	[1123]="Chrome",
	[1125]="Chrome Lights",
--  Bullbar . . ? [tył]
	[1109]="Chrome",
	[1110]="Slamin",
--	Front Sign [figurka itd z przodu]
	[1111]="Figurka",
	[1112]="Figurka",
--	Hydraulika
	[1087]="Hydraulika",
--  Wydechy
	[1034]="Alien",
	[1037]="X-Flow",
	[1044]="Chrome",
	[1046]="Alien",
	[1018]="Upswept",
	[1019]="Twin",
	[1020]="Large",
	[1021]="Medium",
	[1022]="Small",
	[1028]="Alien",
	[1029]="X-Flow",
	[1043]="Slamin",
	[1044]="Chrome",
	[1045]="X-Flow",
	[1059]="X-Flow",
	[1064]="Alien",
	[1065]="Alien",
	[1066]="X-Flow",
	[1089]="X-Flow",
	[1092]="Alien",
	[1104]="Chrome",
	[1105]="Slamin",
	[1113]="Chrome",
	[1114]="Slamin",
	[1126]="Chrome",
	[1127]="Slamin",
	[1129]="Chrome",
	[1132]="Slamin",
	[1135]="Slamin",
	[1136]="Chrome",

--  Zderzaki [tylni]
	[1149]="Alien",
	[1148]="X-Flow",
	[1150]="Alien",
	[1151]="X-Flow",
	[1154]="Alien",
	[1156]="X-Flow",
	[1159]="Alien",
	[1161]="X-Flow",
	[1167]="X-Flow",
	[1168]="Alien",
	[1175]="Slamin",
	[1177]="Slamin",
	[1178]="Slamin",
	[1180]="Chrome",
	[1183]="Slamin",
	[1184]="Chrome",
	[1186]="Slamin",
	[1187]="Chrome",
	[1192]="Chrome",
	[1193]="Slamin",
--  Zderzaki [pzrzód]
	[1171]="Alien",
	[1172]="X-Flow",
	[1140]="X-Flow",
	[1141]="Alien",
	[1117]="Chrome",
	[1152]="X-Flow",
	[1153]="Alien",
	[1155]="Alien",
	[1157]="X-Flow",
	[1160]="Alien",
--  Wloty [góra]
	[1128]="Dach", -- DACH DO BLADE
	[1130]="Dach", -- DACH DO SAVANNA
	[1131]="Dach", -- DACH DO SAVANNA
--  Wloty [przód]
--	Dodatkowe lampy
	[1013]="Lampa",
	[1024]="Lampa",
}

function getTuningList()
    return NAMES
end