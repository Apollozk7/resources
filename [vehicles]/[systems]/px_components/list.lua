--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui={}

ui.componentsList={
	["Banshee"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"1a", "a2", "c4", "b2"},hide={"c1", "b1", "a1", "c2", "c3"}},
		},

		["Dachy"]={
			["Targa"]={visibled={"c3", "1a", "a2", "b2"},hide={"c1", "b1", "a1", "c2", "c4"},cost=40500},
			["Dach"]={visibled={"c1", "1a", "a2", "b2"},hide={"b1", "a1", "c2", "c3", "c4"},cost=40850},
			["Cabrio"]={visibled={"1a", "a2", "b2"},hide={"c1", "b1", "a1", "c2", "c3", "c4"},cost=41250},
		},

		["Światła przednie"]={
			["Eyes of speed"]={visibled={"a1"},hide={"a2"},cost=29500},
			["Podstawowe"]={visibled={"a2"},hide={"a1"}},
		},

		["Tył pojazdu"]={
			["Podstawowy"]={visibled={"b1"},hide={"b2"}},
			["Darkness"]={visibled={"b2"},hide={"b1"},cost=19900},
		},
	},

    ["Buffalo"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1", "a1", "z", "b1"},hide={"a2", "c2", "s1", "b2"}},
		},

		["Niedostępne"]={
			["Supercharged"]={visibled={"c1", "s1"},hide={"a2", "a1", "c2", "b2", "b1"},cost=51500},
		},

		["Dachy"]={
			["Panorama"]={visibled={"c2"},hide={"c1"},cost=18500},
			["Podstawowy"]={visibled={"c1"},hide={"c2"}},
		},
    
		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["State"]={visibled={"a2"},hide={"a1"},cost=19900},
		},

		["Tył pojazdu"]={
			["Idaho"]={visibled={"b1"},hide={"b2"},cost=15500},
			["Standardowy"]={visibled={"b2"},hide={"b1"}},
		},
    },

	["Sabre"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1", "a1"},hide={"a2", "c2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"},cost=15500},
			["Unitra"]={visibled={"a2"},hide={"a1"},cost=19900},
		},

		["Przód pojazdu"]={
			["Standardowy"]={visibled={"c1"},hide={"c2"},cost=8950},
			["Niestandardowy"]={visibled={"c2"},hide={"c1"},cost=9150},
		},
	},

	["Admiral"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a2", "c1"},hide={"a3", "s1", "c1", "a1"}},
		},

		["Światła przednie"]={
			["Kuliste"]={visibled={"a1"},hide={"a2","a3"},cost=12500},
			["Standardowe"]={visibled={"a2"},hide={"a1","a3"}},
			["Benefactor Lume"]={visibled={"a3"},hide={"a2","a1"},cost=13500},
		},

		["Specjalne"]={
			["V8 Sport Technik"]={visibled={"s1"},hide={"c1"},cost=34900},
		},
	},

	["Tampa"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1", "a1"},hide={"a3", "b3", "c1", "s1", "c2", "a2", "b2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","s1"}},
			["Rock'n Roll"]={visibled={"a2"},hide={"a1","a3","s1"},cost=9500},
			["Heavy Metal"]={visibled={"a3"},hide={"a2","a1","s1"},cost=11450},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2","b3","s1"}},
			["Blues"]={visibled={"b2"},hide={"b1","b3","s1"},cost=9650},
			["Jazz"]={visibled={"b3"},hide={"b2","b1","s1"},cost=11500},
		},

		["Przód pojazdu"]={
			["Dokładka Malowana"]={visibled={"c1"},hide={"c2"},cost=11500},
			["Dokładka Plastikowa"]={visibled={"c2"},hide={"c1"},cost=11950},
		},

		["Specjalne Przód i Tył"]={
			["GT Legends"]={visibled={"s1"},hide={"a1","a2","a3","b1","b2","b3"},cost=34990},
		},
	},

	["Alpha"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1", "a1", "c3", "b1"},hide={"a2", "c2", "b2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Thunder"]={visibled={"a2"},hide={"a1"},cost=12500},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2"}},
			["Cubra"]={visibled={"b2"},hide={"b1"},cost=9500},
		},

		["Dachy"]={
			["Cabrio"]={visibled={},hide={"c1", "c2", "c3"},cost=14490},
			["Panorama"]={visibled={"c2", "c3"},hide={"c1"},cost=12490},
		},
	},

	["Vincent"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a3", "b1", "a1", "sedan", "c3", "b3", "c1"},hide={"s1", "s2", "b2", "a2", "kombi", "a4", "a5", "a6", "b3", "b4", "b5", "b6", "c2", 'c4'}},
		},

        ["Światła Przednie"]={
			["Standardowe"]={visibled={"a3"},hide={"a4", "a5", "a6"}},
			["Rekinek"]={visibled={"a4"},hide={"a3", "a5", "a6"},cost=13450},
			["Arbeit LED"]={visibled={"a5"},hide={"a3", "a4", "a6"},cost=15490},
            ["Vag LED"]={visibled={"a6"},hide={"a3", "a4", "a5"},cost=15490},
		},

        ["Światła Tylne"]={
			["Standardowe światła"]={visibled={"b3"},hide={"b4", "b5", "b6"}},
			["Slide"]={visibled={"b4"},hide={"b3", "b5", "b6"},cost=10450},
			["Fake BMK"]={visibled={"b5"},hide={"b4", "b3", "b6"},cost=10490},
            ["Eyebrow"]={visibled={"b6"},hide={"b3", "b5", "b4"},cost=12490},
		},

		["Grill"]={
			["Standardowy grill"]={visibled={"a1"},hide={"a2"}},
			["Malowany Grill"]={visibled={"a2"},hide={"a1"},cost=7490},
		},

    	["Przód"]={
			["Standardowy"]={visibled={"c1"},hide={"c2"}},
			["BMK"]={visibled={"c2"},hide={"c1"},cost=9590},
		},

		["Tylna Listwa"]={
			["Standardowa listwa"]={visibled={"b1"},hide={"b2"}},
			["Czarna Sepia"]={visibled={"b2"},hide={"b1"},cost=7990},
		},

		["Specjalne"]={
			["Sentinel Tuning Division"]={visibled={"s1", "s2"},hide={"c3"},cost=24490},
		},
	},

	["Vincent Combi"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a3", "b1", "a1", "kombi", "c3", "b3", "c1"},hide={"s1", "s2", "b2", "a2", "sedan", "a4", "a5", "a6", "b3", "b4", "b5", "b6", "c2", 'c4'}},
		},

        ["Światła Przednie"]={
			["Standardowe"]={visibled={"a3"},hide={"a4", "a5", "a6"}},
			["Rekinek"]={visibled={"a4"},hide={"a3", "a5", "a6"},cost=13450},
			["Arbeit LED"]={visibled={"a5"},hide={"a3", "a4", "a6"},cost=15490},
            ["Vag LED"]={visibled={"a6"},hide={"a3", "a4", "a5"},cost=15490},
		},

        ["Światła Tylne"]={
			["Standardowe światła"]={visibled={"b3"},hide={"b4", "b5", "b6"}},
			["Slide"]={visibled={"b4"},hide={"b3", "b5", "b6"},cost=10450},
			["Fake BMK"]={visibled={"b5"},hide={"b4", "b3", "b6"},cost=10490},
            ["Eyebrow"]={visibled={"b6"},hide={"b3", "b5", "b4"},cost=12490},
		},

		["Grill"]={
			["Standardowy grill"]={visibled={"a1"},hide={"a2"}},
			["Malowany Grill"]={visibled={"a2"},hide={"a1"},cost=7490},
		},

        ["Przód"]={
			["Standardowy"]={visibled={"c1"},hide={"c2"}},
			["BMK"]={visibled={"c2"},hide={"c1"},cost=9590},
		},

		["Tylna Listwa"]={
			["Standardowa listwa"]={visibled={"b1"},hide={"b2"}},
			["Czarna Sepia"]={visibled={"b2"},hide={"b1"},cost=7990},
		},

		["Specjalne"]={
			["Sentinel Tuning Division"]={visibled={"s1", "s2"},hide={"c3"},cost=24490},
		},
	},

	["Huntley"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1"},hide={"a2", "s1"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["UTX LED Technology"]={visibled={"a2"},hide={"a1"},cost=39900},
		},

		["Specjalne"]={
			["Vapid Individual"]={visibled={"s1"},hide={},cost=44950},
		},
	},

	["Moonbeam"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1", "c3", "b1"},hide={"c1", "a2", "c2", "s1", "c4", "b2"}},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2"}},
			["Clock"]={visibled={"b2"},hide={"b1"},cost=8500},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Medival"]={visibled={"a2"},hide={"a1"},cost=9500},
            ["Super Streamline"]={visibled={"s1"},hide={"a1","a2"},cost=12500},
		},

		["Szyby"]={
			["Niestandardowa"]={visibled={"c1"},hide={"c2","c3"},cost=10950},
			["Brak"]={visibled={"c2"},hide={"c1","c3"},cost=10550},
			["Standardowa"]={visibled={"c3"},hide={"c2","c1"}},
		},

		["Dachy"]={
			["Dach Streamline"]={visibled={"c4"},hide={},cost=11500},
		},

	},

	["Perennial"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c2","c4"},hide={"c1","c3","c5"}},
		},

		["Dokładki"]={
			["Brak"]={visibled={},hide={"c5"}},
			["Dokładka"]={visibled={"c5"},hide={},cost=800},
		},

		["Dachy"]={
			["Dach"]={visibled={"c1"},hide={},cost=400},
		},
	},

	["Sentinel"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1", "a1", 'sedan'},hide={"a4", "a5", "a6", "a7", "a3", "b3", "s1", "b2", "a2", "b4", 'kombi', 'b5', 'a8', 'c1'}},
		},

        ["Światła przednie"]={
            ["Normal"]={visibled={},hide={'a7','a8'}},
            ["STD LED"]={visibled={"a7"},hide={'a8'},cost=24900},
            ["Haustier"]={visibled={"a8"},hide={'a7'},cost=15900},
        },
        
        ["Grill"]={
            ["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5","a6"}},
            ["STD Matte"]={visibled={"a2"},hide={"a1","a3","a4","a5","a6"},cost=25850},
            ["STD Matte 2"]={visibled={"a3"},hide={"a2","a1","a4","a5","a6"},cost=26550},
            ["Chrome Individual 1"]={visibled={"a4"},hide={"a2","a3","a1","a5","a6"},cost=25900},
            ["STD Matte 3"]={visibled={"a5"},hide={"a2","a3","a4","a1","a6"},cost=26390},
            ["STD Colorized"]={visibled={"a6"},hide={"a2","a3","a4","a5","a1"},cost=27500},
        },
        
        ["Tył pojazdu"]={
            ["Standardowy"]={visibled={"b1"},hide={"b2","b3","b4"}},
            ["Über"]={visibled={"b2"},hide={"b1","b3","b4"},cost=14500},
            ["Abenteuer"]={visibled={"b3"},hide={"b2","b1","b4"},cost=18500},
            ["Krach"]={visibled={"b4"},hide={"b2","b3","b1"},cost=14900},
        },

		["Specjalne"]={
			["Sentinel Tuning Division"]={visibled={"s1"},hide={},cost=34900},
		},

		['Interakcja']={
			['Combi']={visibled={'kombi'},hide={'sedan'}},
		},
	},

    ['Sentinel Combi']={
        ["Podstawowe"]={
			["Podstawowy"]={visibled={"b1", "a1", 'kombi'},hide={"a4", "a5", "a6", "a7", "a3", "b3", "s1", "b2", "a2", "b4", 'b5', 'a8', 'sedan', 'c1'}},
		},

        ["Światła przednie"]={
            ["Normal"]={visibled={},hide={'a7','a8'}},
            ["STD LED"]={visibled={"a7"},hide={'a8'},cost=24900},
            ["Haustier"]={visibled={"a8"},hide={'a7'},cost=15900},
        },

        ["Światła tył"]={
            ["Standard"]={visibled={},hide={"b5"}},
            ["Flügger"]={visibled={"b5"},hide={},cost=4900},
        },
        
        ["Grill"]={
            ["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5","a6"}},
            ["STD Matte"]={visibled={"a2"},hide={"a1","a3","a4","a5","a6"},cost=25850},
            ["STD Matte 2"]={visibled={"a3"},hide={"a2","a1","a4","a5","a6"},cost=26550},
            ["Chrome Individual 1"]={visibled={"a4"},hide={"a2","a3","a1","a5","a6"},cost=25900},
            ["STD Matte 3"]={visibled={"a5"},hide={"a2","a3","a4","a1","a6"},cost=26390},
            ["STD Colorized"]={visibled={"a6"},hide={"a2","a3","a4","a5","a1"},cost=27500},
        },

        ["Specjalne"]={
			["Sentinel Tuning Division"]={visibled={"s1"},hide={},cost=34900},
		},
    },

	["Sunrise"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a3", "a2", "a0"},hide={"a4", "a1"}},
		},

		["Grill"]={
			["Maibatsu JDM"]={visibled={"a1"},hide={"a2"},cost=10900},
			["Standardowy"]={visibled={"a2"},hide={"a1"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a3"},hide={"a4"}},
			["LED Projector"]={visibled={"a4"},hide={"a3"},cost=13500},
		},
	},

	["Stallion"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1", "b1", "b7", "b6"},hide={"a4", "b8", "b5", "a3", "a2", "b3", "b9", "b2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4"}},
			["Double View"]={visibled={"a2"},hide={"a1","a3","a4"},cost=15500},
			["Great View"]={visibled={"a3"},hide={"a1","a2","a4"},cost=15900},
			["Holy Moly"]={visibled={"a4"},hide={"a1","a2","a3"},cost=17250},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2","b3"}},
			["Mustang Horse"]={visibled={"b2"},hide={"b1","b3"},cost=14950},
			["El Camino"]={visibled={"b3"},hide={"b2","b1"},cost=13590},
		},

		["Tylne Listwy"]={
			["Carbon Black"]={visibled={"b5"},hide={"b6"},cost=8500},
			["Malowane"]={visibled={"b6"},hide={"b5"}},
		},

		["Emblemat"]={
			["Standardowy"]={visibled={"b7"},hide={"b8","b9"}},
			["Don't Refuel Here"]={visibled={"b8"},hide={"b7","b9"},cost=6900},
			["Imponte Flex"]={visibled={"b9"},hide={"b7","b8"},cost=7900},
			["Brak Znaczka"]={visibled={},hide={"b7","b8","b9"},cost=3900},
		},
	},

	["Manana"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a9", "c1", "a1"},hide={"a2"}},
		},

		["Dachy"]={
			["Cabrio"]={visibled={},hide={"c1"},cost=7900},
		},

		["Grill"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Racer"]={visibled={"a2"},hide={"a1"},cost=8590},
		},
	},

	["Intruder"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1", "a0"},hide={"s1"}},
		},

		["Specjalne"]={
			["VX V8"]={visibled={"s1"},hide={"a1"},cost=14900},
		},
	},

	["Sultan"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1", "z0", "c6", "c4", "a1", 'sedan'},hide={"a4", "a2", "b2", "c2", "c5", "s1", "a5", "a3", "c3", "b3", "c1", "a6", 'kombi', 'c7'}},
		},

		["Tylna Listwa"]={
			["Carbon"]={visibled={"c3"},hide={"c4"},cost=17500},
			["Standardowy"]={visibled={"c4"},hide={"c3"}},
		},

		["Grill"]={
			["Otwarty Grill"]={visibled={"c5"},hide={"c6"},cost=13500},
			["Standardowy"]={visibled={"c6"},hide={"c5"},cost=0},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["RS LED"]={visibled={"b2"},hide={"b1","b3"},cost=25900},
			["Ultax LED"]={visibled={"b3"},hide={"b2","b1"},cost=23500},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5","a6"}},
			["Tomas LED"]={visibled={"a2"},hide={"a1","a3","a4","a5","a6"},cost=24500},
			["EP LED"]={visibled={"a3"},hide={"a2","a1","a4","a5","a6"},cost=25090},
			["AMA LED"]={visibled={"a4"},hide={"a2","a3","a1","a5","a6"},cost=24900},
			["Niagara LED"]={visibled={"a5"},hide={"a2","a3","a4","a1","a6"},cost=25900},
			["NMD LED"]={visibled={"a6"},hide={"a2","a3","a4","a5","a1"},cost=26500},
		},
		
		["Specjalne"]={
			["RS Mode"]={visibled={"s1"},hide={},cost=32500},
		},

		["Przednie dodatkowe lampy"]={
			["Subaru Racer"]={visibled={"c1"},hide={"c2","c6"},cost=14590},
			["Subaru Rally"]={visibled={"c2"},hide={"c1","c6"},cost=15990},
		},
	},

	["Sultan Combi"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1", "z0", "c6", "c4", "a1", 'kombi'},hide={"a4", "a2", "b2", "c2", "c5", "s1", "a5", "a3", "c3", "b3", "c1", "a6", 'sedan', 'c7'}},
		},

		["Tylna Listwa"]={
			["Carbon"]={visibled={"c3"},hide={"c4"},cost=17500},
			["Standardowy"]={visibled={"c4"},hide={"c3"}},
		},

		["Grill"]={
			["Otwarty Grill"]={visibled={"c5"},hide={"c6"},cost=13500},
			["Standardowy"]={visibled={"c6"},hide={"c5"},cost=0},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["RS LED"]={visibled={"b2"},hide={"b1","b3"},cost=25900},
			["Ultax LED"]={visibled={"b3"},hide={"b2","b1"},cost=23500},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5","a6"}},
			["Tomas LED"]={visibled={"a2"},hide={"a1","a3","a4","a5","a6"},cost=24500},
			["EP LED"]={visibled={"a3"},hide={"a2","a1","a4","a5","a6"},cost=25090},
			["AMA LED"]={visibled={"a4"},hide={"a2","a3","a1","a5","a6"},cost=24900},
			["Niagara LED"]={visibled={"a5"},hide={"a2","a3","a4","a1","a6"},cost=25900},
			["NMD LED"]={visibled={"a6"},hide={"a2","a3","a4","a5","a1"},cost=26500},
		},
		
		["Specjalne"]={
			["RS Mode"]={visibled={"s1"},hide={},cost=32500},
		},

		['Dach']={
			["Bagażnik Dachowy"]={visibled={"c7"},hide={"c7"},cost=17500},
		},

		["Przednie dodatkowe lampy"]={
			["Subaru Racer"]={visibled={"c1"},hide={"c2","c6"},cost=14590},
			["Subaru Rally"]={visibled={"c2"},hide={"c1","c6"},cost=15990},
		},
	},

	["Premier"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b2", "a1"},hide={"b4", "c1", "b3", "s1", "a2", "c2", "b1"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Passato"]={visibled={"a2"},hide={"a1"},cost=19500},
		},

		["Tył pojazdu"]={
			["Coral"]={visibled={"b1"},hide={"b2","b3","b4"},cost=14900},
			["Standardowe"]={visibled={"b2"},hide={"b1","b3","b4"}},
			["Malaga"]={visibled={"b3"},hide={"b2","b1","b4"},cost=16250},
			["Faux LED"]={visibled={"b4"},hide={"b2","b3","b1"},cost=17500},
		},

		["Wycieraczki"]={
			["Wycieraczki 1"]={visibled={"c1"},hide={"c2"},cost=5500},
			["Wycieraczki 2"]={visibled={"c2"},hide={"c1"},cost=5500},
		},

		["Specjalne"]={
			["PRM Initialle"]={visibled={"s1"},hide={},cost=26500},
		},
	},

	["Turismo"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1", "c6", "c4", "z0", "a1"},hide={"a4", "b4", "b6", "a2", "b2", "c5", "b5", "a5", "b7", "a3", "c3", "b3", "c1", "c8", "c2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5"}},
			["Sunglasses"]={visibled={"a2"},hide={"a1","a3","a4","a5"},cost=65000},	
			["Cuboid"]={visibled={"a3"},hide={"a2","a1","a4","a5"},cost=75000},
			["Squared"]={visibled={"a4"},hide={"a2","a3","a1","a5"},cost=75500},	
			["Projector LED"]={visibled={"a5"},hide={"a2","a3","a4","a1"},cost=82500},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3","b4","b5","b6","b7"}},
			["Classic"]={visibled={"b2"},hide={"b1","b3","b4","b5","b6","b7"},cost=75000},
			["Adrenaline 1"]={visibled={"b3"},hide={"b2","b1","b4","b5","b6","b7"},cost=79900},
			["Adrenaline 2"]={visibled={"b4"},hide={"b2","b3","b1","b5","b6","b7"},cost=79900},	
			["Ferrari Eyes"]={visibled={"b5"},hide={"b2","b3","b4","b1","b6","b7"},cost=81500},
			["Enzo"]={visibled={"b6"},hide={"b2","b3","b4","b5","b1","b7"},cost=83770},
			["California LED"]={visibled={"b7"},hide={"b2","b3","b4","b5","b1"},cost=82500},
		},

		["Spoilery"]={
			["Ali di uccello"]={visibled={"c1"},hide={"c2"},cost=58000},
			["Falco volante"]={visibled={"c2"},hide={"c1"},cost=58900},
		},

		["Wydechy"]={
			["Ruggito"]={visibled={"c3"},hide={"c4"},cost=53900},
			["Standardowy"]={visibled={"c4"},hide={"c3"}},
		},
		
		["Tylne Dokładki"]={
			["Grotti Veloce"]={visibled={"c5"},hide={"c6"},cost=62900},
			["Standardowy"]={visibled={"c6"},hide={"c5"}},
		},

		["Wloty"]={
			["Aria"]={visibled={"c8"},hide={},cost=43200},
			["Brak"]={visibled={},hide={"c8"}},
		},
	},

	["Comet"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1", "a1"},hide={"c1", "b3", "c4", "c3", "c2", "a2", "b2", "c5"}},
		},

		["Światła tylne"]={
			["Standardowy"]={visibled={"b1"},hide={"b2","b3"}},
			["Flug"]={visibled={"b2"},hide={"b1","b3"},cost=35900},
			["UDX LED"]={visibled={"b3"},hide={"b2","b1"},cost=49500},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Porsche View"]={visibled={"a2"},hide={"a1"},cost=35500},
		},

		["Dachy"]={
			["Szyberdach"]={visibled={"c1"},hide={"c2","c3","c4","c5"},cost=42500},
			["Dach"]={visibled={"c2"},hide={"c1","c3","c4","c5"},cost=41900},
			["Targa Panoramic"]={visibled={"c3"},hide={"c2","c1","c4","c5"},cost=35900},
			["Materiałowy Dach"]={visibled={"c4"},hide={"c2","c3","c1","c5"},cost=35950},
			["Targa"]={visibled={"c5"},hide={"c2","c3","c4","c1"},cost=39900},
			["Standardowy"]={visibled={},hide={"c1","c2","c3","c4","c5"}},
		},
	},

	["Infernus"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1", "a1", "c1"},hide={"b5", "b4", "b6", "a3", "b3", "c2", "b2", "a2","c3"}},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2","b3","b5","b6","b4"}},
			["Ralph"]={visibled={"b2"},hide={"b1","b3","b5","b6","b4"},cost=65400},
			["Cringe"]={visibled={"b3"},hide={"b2","b1","b5","b6","b4"},cost=60900},
			["Lumia LED"]={visibled={"b4"},hide={"b1","b3","b5","b6","b2"},cost=120930},
			["Equinox LED"]={visibled={"b5"},hide={"b2","b1","b4","b6","b4"},cost=109370},
			["Energa LED"]={visibled={"b6"},hide={"b1","b3","b5","b4","b2"},cost=114900},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3"}},
			["Hydra LED"]={visibled={"a2"},hide={"a1","a2"},cost=124900},
			["Xtrax LED"]={visibled={"a3"},hide={"a2","a1"},cost=110110},
		},

		["Wydechy"]={
			["Standardowe"]={visibled={"c1"},hide={"c2","c3"}},
			["ShutUP"]={visibled={"c2"},hide={"c1","c3"},cost=64430},
			["Decybel"]={visibled={"c3"},hide={"c1","c2"},cost=71770},
		},
	},

	["Elegy"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1", "b1", "c3", "z0", "a1"},hide={"a4", "b4", "a2", "b2", "c2", "b3", "c4", "a3"}},
		},

		["Dachy"]={
			["Standardowy"]={visibled={"c3"},hide={"c4"}},
			["Szyberdach"]={visibled={"c4"},hide={"c3"},cost=25500},
		},

		["Przód pojazdu"]={
			["Standardowy"]={visibled={"c1"},hide={"c2"}},
			["GTR"]={visibled={"c2"},hide={"c1"},cost=27500},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3","b4"}},
			["Zinger"]={visibled={"b2"},hide={"b1","b3","b4"},cost=32500},
			["Xonix LED"]={visibled={"b3"},hide={"b2","b1","b4"},cost=42500},
			["Xonix LED Kolor"]={visibled={"b4"},hide={"b2","b1","b3"},cost=45500},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4"}},
			["Chroma LED"]={visibled={"a2"},hide={"a1","a3","a4"},cost=53700},
			["Eroma LED"]={visibled={"a3"},hide={"a1","a2","a4"},cost=50000},
			["TRD LED"]={visibled={"a4"},hide={"a1","a2","a3"},cost=52220},
		},
	},

    ["Police LS"]={
        ["Podstawowe"]={
            ["Podstawowy"]={visibled={"b2", "c9", "c6", "c3", "c8", "a1", "c9", "c11"},hide={'supervisor1', 'supervisor2', "b4", "a2", "c2", "c7", "c5", "s1", "c1", "b1", "b3", "c4", "c10", "c12"}},
        },

        ["Specjalne"]={
            ["siren_on"]={visibled={"c10","c12"},hide={"c9","c11"}},
            ['supervisor']={visibled={'supervisor2'},hide={'supervisor1'}},
        },

        ["Przody"]={
            ["przod_1"]={visibled={"c1"},hide={"c2","c3","c4","c5","c6","c7","c8","c9","c10"},cost=10000},
            ["przod_2"]={visibled={"c2"},hide={"c1","c3","c4","c5","c6","c7","c8","c9","c10"},cost=10000},
            ["przod_3"]={visibled={"c3"},hide={"c2","c1","c4","c5","c6","c7","c8","c9","c10"},cost=10000},
            ["przod_4"]={visibled={"c4"},hide={"c2","c1","c3","c5","c6","c7","c8","c9","c10"},cost=10000},
            ["przod_5"]={visibled={"c5"},hide={"c2","c1","c3","c4","c6","c7","c8","c9","c10"},cost=10000},
            ["przod_6"]={visibled={"c6"},hide={"c2","c1","c3","c4","c5","c7","c8","c9","c10"},cost=10000},
            ["przod_7"]={visibled={"c7"},hide={"c2","c1","c3","c4","c5","c6","c8","c9","c10"},cost=10000},
            ["przod_8"]={visibled={"c8"},hide={"c2","c1","c3","c4","c5","c6","c7","c9","c10"},cost=10000},
            ["przod_9"]={visibled={"c9"},hide={"c2","c1","c3","c4","c5","c6","c7","c8","c10"},cost=10000},
            ["przod_10"]={visibled={"c10"},hide={"c2","c1","c2","c3","c4","c5","c6","c7","c8"},cost=10000},
        },
    },

	["Bullet"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1"},hide={"a4", "a5", "a3", "a2","b2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5"}},
			["Ford Classic"]={visibled={"a2"},hide={"a1","a3","a4","a5"},cost=71300},
			["GT Classic"]={visibled={"a3"},hide={"a1","a2","a4","a5"},cost=75000},	
			["Double Cube"]={visibled={"a4"},hide={"a1","a2","a3","a5"},cost=73500},
			["Vector"]={visibled={"a5"},hide={"a1","a2","a3","a4"},cost=91600},	
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2"}},
			["Falcon LED"]={visibled={"b2"},hide={"b1"},cost=115900},
		}
	},

	["Blista Compact"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c5", "c1", "b1", "z0", "a1"},hide={"a4", "b4", "a2", "b2", "c2", "b5", "a5", "b3", "c4", "a3", "c3"}},
		},

		["Przód pojazdu"]={
			["Niestandardowy 1"]={visibled={"c1"},hide={"c2","c3","c4","c5"},cost=9500},
			["Niestandardowy 2"]={visibled={"c2"},hide={"c1","c3","c4","c5"},cost=9600},
			["Niestandardowy 3"]={visibled={"c3"},hide={"c1","c2","c4","c5"},cost=9550},
			["Niestandardowy 4"]={visibled={"c4"},hide={"c1","c2","c3","c5"},cost=9520},
			["Standardowy"]={visibled={"c5"},hide={"c1","c2","c3","c4"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5"}},
			["2x Circle View"]={visibled={"a2"},hide={"a1","a3","a4","a5"},cost=9900},
			["2x Square View"]={visibled={"a3"},hide={"a1","a2","a4","a5"},cost=10200},
			["Circle LED"]={visibled={"a4"},hide={"a1","a2","a3","a5"},cost=12450},
			["Lockdown LED"]={visibled={"a5"},hide={"a1","a2","a3","a4"},cost=13450},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2","b3","b4","b5"}},
			["Dinka Black"]={visibled={"b2"},hide={"b1","b3","b4","b5"},cost=10490},
			["Dinka Colour"]={visibled={"b3"},hide={"b2","b1","b4","b5"},cost=10950},
			["Ty to jest Civic?"]={visibled={"b4"},hide={"b2","b3","b1","b5"},cost=13200},
			["Cyberpunk LED"]={visibled={"b5"},hide={"b2","b3","b1","b4"},cost=13900},
		},
	},

	["DFT-30"]={
		["Podstawowe"]={
			["Rafineria"]={visibled={"c5","c2"},hide={"c1", "c2", "c3", "c4", "c6",'c7'}}, -- rafineria
			["Podstawowy"]={visibled={'c7'},hide={"c5","c2","c4",'c6'}}, -- PSP
		},
	},

	["Dune"]={
		["Podstawowe"]={
			["Rafineria"]={visibled={"c2","c4"},hide={"c1", "c3", "s1"}},
			["Śmieciarka"]={visibled={"c3"},hide={"c1","c2","s1","c4"}},
		},
	},

	["Barracks"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1"},hide={"c7","c5","c6","c4","c3","c2"}}, -- PSP
			["Rafineria"]={visibled={"c7"},hide={"c1", "c2", "c3", "c4", "c5", "c6",'c8','c9'}}, -- rafineria
		},
	},

	["Stratum"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a1", "a2", "a3", "a4", "b1", "b2", "b3", "c1", "c2", "c3", "c4","c5"}},
		},

		["Specjalne"]={
			["Bagażnik Dachowy"]={visibled={"c5"},hide={"c5"},cost=17500},
		},

		["Grill"]={
			["Standardowy"]={visibled={"c1"},hide={"c2","c3","c4"}},
			["Lada"]={visibled={"c2"},hide={"c1","c3","c4"},cost=9500},
			["Passeratii"]={visibled={"c3"},hide={"c1","c2","c4"},cost=10900},
			["Golf"]={visibled={"c4"},hide={"c1","c2","c3"},cost=10900},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4"}},
			["Quirk LED"]={visibled={"a2"},hide={"a1","a3","a4"},cost=23900},	
			["Qomb LED"]={visibled={"a3"},hide={"a1","a2","a4"},cost=23950},	
			["Notine LED"]={visibled={"a4"},hide={"a1","a2","a3"},cost=23500},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2","b3"}},
			["Wagen LED"]={visibled={"b2"},hide={"b1","b3"},cost=23500},
			["Corden LED"]={visibled={"b3"},hide={"b2","b1"},cost=21900},
		},
	},

	["Pony"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a2","b2","b3","c2","c3","c4",'c5','c6','c7','c8'}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["I.D LED"]={visibled={"a2"},hide={"a1"},cost=27900},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["Quixen LED"]={visibled={"b2"},hide={"b1","b3"},cost=17900},
			["D.I LED"]={visibled={"b3"},hide={"b1","b2"},cost=18900},
		},

		['Spoilery']={
			["Spoiler"]={visibled={"c5"},hide={},cost=15900},
		},

		['Lampy dachowe']={
			["Lampy Dachowe"]={visibled={"c6"},hide={},cost=9560},
		},

		['Przednie Orurowanie']={
			["Przednie Orurowanie"]={visibled={"c7"},hide={},cost=20590},
		},

		["Specjalne"]={
			["Sunvisor"]={visibled={"c8"},hide={},cost=6750},
		},

		["Interakcja"]={
			["Drzwi otworzone"]={visibled={"c2"},hide={"c1"}},
			["Drzwi zamknięte"]={visibled={"c1"},hide={"c2"}},
			
			["GOPostal"]={visibled={"c3"},hide={}},
			["GOPostal_2"]={visibled={},hide={"c3"}},
		},

		["System Audio"]={
			["Głośniki JGL"]={visibled={"c4"},hide={},cost=24900},
		},
	},

	["Rumpo"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1","b1","a0"},hide={"b2", "a0", "b3", "c3", "c2", "a2", 'c4','c5','c6','c7'}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["TarraEP LED"]={visibled={"a2"},hide={"a1"},cost=22900},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["Niestandardowe 1"]={visibled={"b2"},hide={"b1","b3"},cost=17500},
			["Niestandardowe 2"]={visibled={"b3"},hide={"b1","b2"},cost=18500},
		},

		['Spoilery']={
			["Spoiler"]={visibled={"c4"},hide={},cost=15900},
		},

		['Lampy dachowe']={
			["Lampy Dachowe"]={visibled={"c5"},hide={},cost=9560},
		},

		['Przednie Orurowanie']={
			["Przednie Orurowanie"]={visibled={"c6"},hide={},cost=20590},
		},

		["Specjalne"]={
			["Sunvisor"]={visibled={"c7"},hide={},cost=6750},
		},

		["Interakcja"]={
			["Drzwi otworzone"]={visibled={"c2"},hide={"c1"}},
			["Drzwi zamknięte"]={visibled={"c1"},hide={"c2"}},
			
			["GOPostal"]={visibled={"c3"},hide={}},
			["GOPostal_2"]={visibled={},hide={"c3"}},
		},
	},

	["Boxville"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","c1","a0", "b1"},hide={"a2", "c3", "c2", "c5", "c4", "sara", 'stop', 'lewo', 'prawo', "c6", "c7", "c8", "c9", "b2", "b3", "b4"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Niestandardowe"]={visibled={"a2"},hide={"a1"},cost=22500},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2", "b3", "b4"}},
			["Niestandardowe 1"]={visibled={"b2"},hide={"b1", "b3", "b4"},cost=15500},
			["Niestandardowe 2"]={visibled={"b3"},hide={"b1", "b2", "b4"},cost=16500},
			["Niestandardowe 3"]={visibled={"b4"},hide={"b1", "b2", "b3"},cost=17500},
		},

		['Spoilery']={
			["Spoiler"]={visibled={"c6"},hide={},cost=15900},
		},

		['Lampy dachowe']={
			["Lampy Dachowe"]={visibled={"c7"},hide={},cost=9560},
		},

		['Przednie Orurowanie']={
			["Przednie Orurowanie"]={visibled={"c8"},hide={},cost=20590},
		},

		["Specjalne"]={
			["Sunvisor"]={visibled={"c9"},hide={},cost=6750},
		},

		["Interakcja"]={
			["Drzwi otworzone"]={visibled={"c2"},hide={"c1"}},
			["Drzwi zamknięte"]={visibled={"c1"},hide={"c2"}},
			
			["GOPostal"]={visibled={"c3"},hide={}},
			["GOPostal_2"]={visibled={},hide={"c3"}},

			-- sara
			['sara']={visibled={'sara','c5'},hide={'c4'}},
			['sara_up']={visibled={'sara','c4'},hide={'c5'}},
			['stop']={visibled={'stop'},hide={'lewo','prawo'}},
			['lewo']={visibled={'lewo'},hide={'stop','prawo'}},
			['prawo']={visibled={'prawo'},hide={'stop','lewo'}},
		},
	},

	["Cabbie"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1"},hide={"b2"}},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2"}},
			["Niestandardowe"]={visibled={"b2"},hide={"b1"},cost=8900},
		},
	},

	["Club"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1",'c3'},hide={"a2","a3","a4","a5","b2","b3","c2","s1"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5"}},
			["Double Eyed"]={visibled={"a2"},hide={"a1","a3","a4","a5"},cost=11250},	
			["Fairy LED"]={visibled={"a3"},hide={"a1","a2","a4","a5"},cost=18500},	
			["Glory LED"]={visibled={"a4"},hide={"a1","a2","a3","a5"},cost=18900},
			["Stance"]={visibled={"a5"},hide={"a1","a2","a3","a4"},cost=11900},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["Diary LED"]={visibled={"b2"},hide={"b1","b3"},cost=16500},
			["Og LED"]={visibled={"b3"},hide={"b1","b2"},cost=16950},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"c1"},hide={"c2"}},
			["Niestandardowy"]={visibled={"c2"},hide={"c1"},cost=7490},
		},
		
		["Specjalne"]={
			["GTI"]={visibled={"s1"},hide={'c3'},cost=27900},
		},
	},

	["Elegant"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1"},hide={"a2","a3","a4","b2","c1"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4"}},
			["Full Vision"]={visibled={"a2"},hide={"a1","a2","a4"},cost=11900},
			["Elegance LED"]={visibled={"a3"},hide={"a2","a1","a4"},cost=14900},
			["Ultimax LED"]={visibled={"a4"},hide={"a2","a1","a3"},cost=15500},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2"}},
			["Elegance LED"]={visibled={"b2"},hide={"b1"},cost=17900},
		},

		["Wycieraczki"]={
			["Wycieraczki"]={visibled={"c1"},hide={},cost=5900},
		},
	},

	["Euros"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a21","a22","b2","b3","b4","b5","c2"}},
		},

		["Interakcja"]={
			["lights_turnoff"]={visibled={"a21"},hide={"a22"}},
			["lights_turnon"]={visibled={"a22"},hide={"a21"}},
		},

		["Światła przednie"]={
			["Open Your Eyes"]={visibled={"a21"},hide={"a1","a22"},cost=24900},
			["Standardowe"]={visibled={"a1"},hide={"a22","a21"}},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2","b3","b4","b5"}},
			["Classic"]={visibled={"b2"},hide={"b1","b3","b4","b5"},cost=13500},
			["Lambo LED"]={visibled={"b3"},hide={"b2","b1","b4","b5"},cost=21900},
			["Fade LED"]={visibled={"b4"},hide={"b2","b3","b1","b5"},cost=22390},
			["Ox LED"]={visibled={"b5"},hide={"b2","b3","b1","b4"},cost=22390},
		},

		["Dachy"]={
			["Panorama"]={visibled={"c2"},hide={"c1"},cost=12490},
			["Standardowe"]={visibled={"c1"},hide={"c2"}},
		}
	},

	["Flash"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a2","a3","a4","b2","b3","c2","c3","s1","s2","s3"}},
		},

		["Specjalne"]={
			["GTI 1"]={visibled={"s1"},hide={"s2","s3","c1","c2","c3"},cost=34900},
			["GTI 2"]={visibled={"s2"},hide={"s1","s3","c1","c2","c3"},cost=34900},
			["GTI 3"]={visibled={"s3"},hide={"s1","s2","c1","c2","c3"},cost=34990},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4"}},
			["Classic"]={visibled={"a2"},hide={"a1","a2","a4"},cost=21500},
			["Jetix LED"]={visibled={"a3"},hide={"a2","a1","a4"},cost=28900},
			["Maxx LED"]={visibled={"a4"},hide={"a2","a1","a3"},cost=29500},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["Jetix LED"]={visibled={"b2"},hide={"b1","b3"},cost=30500},
			["Maxx LED"]={visibled={"b3"},hide={"b1","b2"},cost=31200},
		},

		["Grill"]={
			["Standardowy"]={visibled={"c1"},hide={"c2","c3"}},
			["Niestandardowy 1"]={visibled={"c2"},hide={"c1","c3"},cost=12500},
			["Niestandardowy 2"]={visibled={"c3"},hide={"c1","c2"},cost=12500},
		},
	},

	["Fortune"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a2","b2","b3","b4","c2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Fukisaga"]={visibled={"a2"},hide={"a1"},cost=15900},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3","b4"}},
			["Akimashi"]={visibled={"b2"},hide={"b1","b3","b4"},cost=9900},
			["Sakura"]={visibled={"b3"},hide={"b2","b1","b4"},cost=13900},
			["Kabutaro"]={visibled={"b4"},hide={"b2","b3","b1"},cost=13900},
		},

		["Grill"]={
			["Standardowy"]={visibled={"c1"},hide={"c2"}},
			["Harakiri"]={visibled={"c2"},hide={"c1"},cost=8900},
		},
	},

	["Jester"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a2","a3","a4","a5","a6","b2","b3","b4","c2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5","a6"}},
			["Toyoda Light"]={visibled={"a2"},hide={"a1","a3","a4","a5","a6"},cost=23900},
			["Supra System"]={visibled={"a3"},hide={"a2","a1","a4","a5","a6"},cost=24500},
			["StellarX LED"]={visibled={"a4"},hide={"a2","a3","a1","a5","a6"},cost=29900},
			["PolarIO LED"]={visibled={"a5"},hide={"a2","a3","a4","a1","a6"},cost=29900},
			["DeXeD LED"]={visibled={"a6"},hide={"a2","a3","a4","a5","a1"},cost=28590},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3","b4"}},
			["Matrix LED"]={visibled={"b2"},hide={"b1","b3","b4"},cost=29500},
			["VeVis LED"]={visibled={"b3"},hide={"b2","b1","b4"},cost=31500},
			["ArkaNio LED"]={visibled={"b4"},hide={"b2","b3","b1"},cost=30900},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"c1"},hide={"c2"}},
			["Black Lume"]={visibled={"c2"},hide={"c1"},cost=14900},
		},
	},

	["Linerunner"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","c3"},hide={"a2","a3","c1","c2","c3","c4"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3"}},
			["Niestandardowe 1"]={visibled={"a2"},hide={"a1","a3"}},
			["Niestandardowe 2"]={visibled={"a3"},hide={"a1","a2"}},
		},

		["Zbiorniki"]={
			["Standardowe"]={visibled={"c1"},hide={}},
			["Niestandardowe"]={visibled={"c2"},hide={}},
		},

		["Chlapacze"]={
			["Standardowe"]={visibled={"c3"},hide={"c4"}},
			["Niestandardowe"]={visibled={"c4"},hide={"c3"}},
		},
	},

	["Newsvan"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","c1"},hide={"a2","c1","c2","c3"}},
		},

		["Interakcja"]={
			["Drzwi otworzone"]={visibled={"c2"},hide={"c1"}},
			["Drzwi zamknięte"]={visibled={"c1"},hide={"c2"}},
			
			["GOPostal"]={visibled={"c3"},hide={}},
			["GOPostal_2"]={visibled={},hide={"c3"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["IntellLuxx LED"]={visibled={"a2"},hide={"a1"},cost=30500},
		},
	},

	["Tanker"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1"},hide={"a2","a3","a4","b2","c1","c2","c3"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4"}},
			["Niestandardowe 1"]={visibled={"a2"},hide={"a1","a3","a4"}},
			["Niestandardowe 2"]={visibled={"a3"},hide={"a1","a2","a4"}},
			["Niestandardowe 3"]={visibled={"a4"},hide={"a1","a2","a3"}},
		},

		["Nadkola"]={
			["Standardowe"]={visibled={"b1"},hide={"b2"}},
			["Niestandardowe"]={visibled={"b2"},hide={"b1"}},
		},

		["Zbiorniki"]={
			["Standardowe"]={visibled={"c2"},hide={}},
			["Niestandardowe"]={visibled={"c3"},hide={}},
		},

		["Spoiler"]={
			["Spoiler"]={visibled={"c2"},hide={}},
		},
	},

	["Picador"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","c1","c3"},hide={"a2","a3","c2","c4","c5","c6","c7","s1"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3"}},
			["Niestandardowe 1"]={visibled={"a2"},hide={"a1","a3"},cost=8760},
			["Niestandardowe 2"]={visibled={"a3"},hide={"a1","a2"},cost=8760},
		},

		["Silniki"]={
			["Super Charged"]={visibled={"c7"},hide={},cost=17320},
		},

		["Zderzak"]={
			["Dokładka"]={visibled={"c6"},hide={},cost=12980},
		},

		["Kratki"]={
			["Kratka"]={visibled={"c2"},hide={},cost=7530},
		},

		["Specjalne"]={
			["Specjalne"]={visibled={"s1"},hide={"c1"},cost=11900},
		},

		["Grill"]={
			["Standardowy"]={visibled={"c3"},hide={"c4","c5"}},
			["Eruption"]={visibled={"c4"},hide={"c3","c5"},cost=7900},
			["Disorted"]={visibled={"c5"},hide={"c3","c4"},cost=6190},
		},
	},

	["Willard"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1"},hide={"a1","a2","a3","a4","a5","a6","b2","b3","c1","c2","c3","c4","c5","s1"}},
		},

		["Przód pojazdu"]={
			["Standardowy"]={visibled={"a1"},hide={"a2","a3"}},
			["Niestandardowy 1"]={visibled={"a2"},hide={"a1","a3"},cost=7340},
			["Niestandardowy 2"]={visibled={"a3"},hide={"a1","a2"},cost=7340},
		},

		["Listwy"]={
			["Listwa 1"]={visibled={"a4"},hide={"a5"},cost=7610},
			["Listwa 2"]={visibled={"a5"},hide={"a4"},cost=7610},
			["Listwa tylna 1"]={visibled={"c1"},hide={"c2"},cost=7610},
			["Listwa tylna 2"]={visibled={"c2"},hide={"c1"},cost=7610},
		},

		["Wycieraczki"]={
			["Wycieraczki Vulcar"]={visibled={"a6"},hide={},cost=5880},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["Niestandardowe 1"]={visibled={"b2"},hide={"b1","b3"},cost=8450},
			["Niestandardowe 2"]={visibled={"b3"},hide={"b1","b2"},cost=8450},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"c3"},hide={"c4","c5"},cost=4360},
			["Niestandardowy 1"]={visibled={"c4"},hide={"c3","c5"},cost=7620},
			["Niestandardowy 2"]={visibled={"c5"},hide={"c3","c4"},cost=7620},
		},

		["Specjalne"]={
			["Specjalne"]={visibled={"s1"},hide={},cost=24400},
		},
	},

	["Sadler"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1"},hide={"a2","c1"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Grandad Glasses"]={visibled={"a2"},hide={"a1"},cost=9500},
		},

		["Zabudowa"]={
			["Zabudowa"]={visibled={"c1"},hide={},cost=9900},
		},
	},

	["ZR-350"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b1"},hide={"b2","b3","b4","c1","c2"}},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3","b4"}},
			["Ring LED"]={visibled={"b2"},hide={"b1","b3","b4"},cost=29430},
			["Klasyczny Drifter"]={visibled={"b3"},hide={"b2","b1","b4"},cost=21900},
			["Handbrake LED"]={visibled={"b4"},hide={"b2","b3","b1"},cost=24900},
		},

		["Specjalne"]={
			["Standardowe"]={visibled={},hide={"c1","c2"}},
			["Spoiler"]={visibled={"c1"},hide={"c2"},cost=27900},
			["Dokładka przednia"]={visibled={"c2"},hide={"c1"},cost=18900},
		},
	},

	["Roadtrain"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c9","c11"},hide={"a2","a3","a4","a5","b2","b3","b4","c1","c2","c3","c4","c5","c6","c7","c8","c10","c12"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5"}},
			["Niestandardowe 1"]={visibled={"a2"},hide={"a1","a3","a4","a5"}},
			["Niestandardowe 2"]={visibled={"a3"},hide={"a1","a2","a4","a5"}},
			["Niestandardowe 3"]={visibled={"a4"},hide={"a1","a2","a3","a5"}},
			["Niestandardowe 4"]={visibled={"a5"},hide={"a1","a2","a3","a4"}},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3","b4"}},
			["Niestandardowe 1"]={visibled={"b2"},hide={"b1","b3","b4"}},
			["Niestandardowe 2"]={visibled={"b3"},hide={"b2","b1","b4"}},
			["Niestandardowe 3"]={visibled={"b4"},hide={"b2","b3","b1"}},
		},

		["Specjalne"]={
			["Bumper"]={visibled={"c1"},hide={}},
			["Żuraw"]={visibled={"c2"},hide={"c1","c10"}},
			["Progi"]={visibled={"c3"},hide={}},
			["Specjalne"]={visibled={"c6"},hide={}},
			["Wloty 1"]={visibled={"c7"},hide={}},
			["Wloty 2"]={visibled={"c8"},hide={}},
		},

		["Przód pojazdu"]={
			["Standardowy"]={visibled={"c4"},hide={"c5"}},
			["Niestandardowy"]={visibled={"c5"},hide={"c4"}},
		},

		["Kurniki"]={
			["Kurnik 1"]={visibled={"c9"},hide={"c10"}},
			["Kurnik 2"]={visibled={"c10"},hide={"c9","c2"}},
		},

		["Nadkola"]={
			["Standardowe"]={visibled={"c11"},hide={"c12"}},
			["Niestandardowe"]={visibled={"c12"},hide={"c11"}},
		},
	},

	["Towtruck"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1"},hide={"a2","a3"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3"},cost=21900},
			["Niestandardowe 1"]={visibled={"a2"},hide={"a1","a3"},cost=21900},
			["Niestandardowe 2"]={visibled={"a3"},hide={"a1","a2"},cost=21900},
		},
	},

    ["Yosemite"]={
        ["Podstawowe"]={
            ["Podstawowy"]={visibled={"a3","b2","c1","c2","c3","c4","c5","c6","c11","c12"},hide={"a1","a2","a4","b1","c11","c12","c13","c14"}},
        },

        ["Światła przednie"]={
            ["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4"}},
            ["Niestandardowe 1"]={visibled={"a2"},hide={"a1","a3","a4"},cost=19500},
            ["Niestandardowe 2"]={visibled={"a3"},hide={"a1","a2","a4"},cost=21500},
            ["Niestandardowe 3"]={visibled={"a4"},hide={"a1","a2","a3"},cost=22900},
        },

        ["Światła tylne"]={
            ["Standardowe"]={visibled={"b1"},hide={"b2"}},
            ["Niestandardowe"]={visibled={"b2"},hide={"b1"},cost=18500},
        },

        ["Interakcja"]={
            ["siren_on"]={visibled={"c13","c14"},hide={"c11","c12"}},
            ["siren_off"]={visibled={"c11","c12"},hide={"c13","c14"}},
        },
    },

	["Police SF"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1", "b1", "s1", "c11", "c13", "c3", "c5", "c7", "c8", "c9"},hide={"c1","c10","c12","c2","c4","c6"}},
		},
	},


	["Cheetah"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a21","a22","a23","a3","b2","b3","b4","c2","c3","c4"}},
		},

		["Interakcja"]={
			["lights_turnoff"]={visibled={"a21"},hide={"a23"}},
			["lights_turnon"]={visibled={"a23"},hide={"a21"}},
		},

		["Światła przednie"]={
			["Otwierane Lampy"]={visibled={"a21"},hide={"a1","a23","a3"},cost=37390},
			["LED"]={visibled={"a3"},hide={"a21","a23","a1"},cost=35320},
			["Standardowe"]={visibled={"a1"},hide={"a3","a23","a21"}},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3","b4"}},
			["Klasyczne"]={visibled={"b2"},hide={"b1","b3","b4"},cost=37430},
			["LED 1"]={visibled={"b3"},hide={"b2","b1","b4"},cost=45930},
			["LED 2"]={visibled={"b4"},hide={"b2","b3","b1"},cost=41090},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"c1"},hide={"c2"}},
			["Niestandardowy"]={visibled={"c2"},hide={"c1"},cost=25950},
		},

		["Spoilery"]={
			["Spoiler"]={visibled={"c3"},hide={},cost=31520},
		},

		["Kratka"]={
			["Kratka tylna"]={visibled={"c4"},hide={},cost=14150},
		},
	},

	["Walton"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1"},hide={"c2","c3","c4","c5","c6"}},
		},

        ["Specjalne"]={
            ["Standardowa paka"]={visibled={"c1"},hide={"c2","c3","c4","c5","c6","c7","c8"}},
			["Van"]={visibled={"c2"},hide={"c1","c3","c4","c5","c6","c7","c8"},cost=11000},
            ["Paka"]={visibled={"c3"},hide={"c1","c2","c4","c5","c6","c7","c8"},cost=9030},
            ["Paka z kołami"]={visibled={"c4"},hide={"c1","c3","c2","c5","c6","c7","c8"},cost=9850},
            ["Paka z oświetleniem"]={visibled={"c5"},hide={"c1","c3","c4","c2","c6","c7","c8"},cost=10500},
         	["Paka z oświetleniem i kołami"]={visibled={"c6"},hide={"c1","c3","c4","c2","c5","c7","c8"},cost=11900},
		},
	},

	["Mesa"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a2","b2","b3","c5","c2","c3","c4"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["LED"]={visibled={"a2"},hide={"a1"},cost=14900},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2"}},
			["LED"]={visibled={"b2"},hide={"b1"},cost=15900},
		},

		["Listwy"]={
			["Boczna Listwa Malowana"]={visibled={"c1"},hide={"c2"}},
            ["Boczna Listwa Plastikowa"]={visibled={"c2"},hide={"c1"},cost=8500},
		},


		["Dachy i orurowanie"]={
			["Bez dachu"]={visibled={},hide={"c3","c4","c5"}},
            ["Orurowanie bez dachu"]={visibled={"c3"},hide={"c4","c5"},cost=10920},
            ["Dach"]={visibled={"c4"},hide={"c5"},cost=13100},
            ["Dach z oświetleniem"]={visibled={"c5"},hide={"c4"},cost=14900},
		},
	},

	["Solair"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1","c2"},hide={"a2","a3","b2","b3","c3","c4","c5","s1"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3"}},
			["LED 1"]={visibled={"a2"},hide={"a1","a3"},cost=17500},
			["LED 2"]={visibled={"a3"},hide={"a1","a2"},cost=18500},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["LED 1"]={visibled={"b3"},hide={"b1","b2"},cost=19500},
			["LED 2"]={visibled={"b2"},hide={"b1","b3"},cost=20900},
		},

		["Tylna Listwa"]={
			["Malowana"]={visibled={"c2"},hide={"c3"}},
			["Plastikowa"]={visibled={"c3"},hide={"c2"},cost=7600},
		},

		["Listwy Okienne"]={
			["Brak"]={visibled={""},hide={"c5","c4"}},
			["Listwa 1"]={visibled={"c4"},hide={"c5"},cost=10900},
			["Listwa 2"]={visibled={"c5"},hide={"c4"},cost=11250},
		},

		["Specjalne"]={
			["Standard"]={visibled={"c1"},hide={"s1"}},
            ["Sentinel Tuning Division"]={visibled={"s1"},hide={"c1"},cost=25900},
		},
	},

	["Bravura"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","z0"},hide={"a2","b2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["LED"]={visibled={"a2"},hide={"a1"},cost=12900},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2"}},
			["LED"]={visibled={"b2"},hide={"b1"},cost=17900},
		},
	},

	["Previon"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a2","b2","c2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Bad Eye"]={visibled={"a2"},hide={"a1"},cost=8500},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2"}},
			["Traffic Jam"]={visibled={"b2"},hide={"b1"},cost=8090},
		},

		["Tylna Listwa"]={
			["Standardowa"]={visibled={"c1"},hide={"c2"}},
			["Black"]={visibled={"c2"},hide={"c1"},cost=6900},
		},
	},

	["Phoenix"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c6","c2"},hide={"a2","b2","b3","c1","c3","c4","c5","c7","c8","s1","s2","s3","s4","s5"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Good Old Times"]={visibled={"a2"},hide={"a1"},cost=13250},
		},

		["Światła tylne"]={
			["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["Heart Break"]={visibled={"b3"},hide={"b1","b2"},cost=13900},
			["Pull Up"]={visibled={"b2"},hide={"b1","b3"},cost=15200},
		},
		
		["Grill"]={
			["Standardowy"]={visibled={"c6"},hide={"c7","s4","s5"}},
			["Moustache"]={visibled={"c7"},hide={"c6","s4","s5"},cost=12900},
		},

		["Tylna Listwa"]={
			["Malowana Standardowa"]={visibled={"c2"},hide={"c1","c3","c4","c5","s1","s2"}},
			["Czarna Classic"]={visibled={"c1"},hide={"c2","c3","c4","c5","s1","s2"},cost=9430},
			["Malowana Turbo"]={visibled={"c4"},hide={"c2","c3","c1","c5","s1","s2"},cost=11530},
			["Czarna Turbo"]={visibled={"c3"},hide={"c2","c4","c1","c5","s1","s2"},cost=11550},
		},

		["Scoop"]={
			["Scoop"]={visibled={"c8"},hide={},cost=17490},
			["Brak Scoopa"]={visibled={},hide={"c8"}},
		},

		["Specjalne Przód"]={
			["Moustache Imponte Racing Turbo"]={visibled={"s4"},hide={"s5"},cost=22900},
			["Kiss Imponte Racing Turbo"]={visibled={"s5"},hide={"s4"},cost=24900},
		},

		["Specjalne Tył"]={
            ["Malowana Imponte Racing Turbo"]={visibled={"s2"},hide={"c1","c2","c3","c4","c5","s1"},cost=24900},
			["Czarna Imponte Racing Turbo"]={visibled={"s1"},hide={"c1","c2","c3","c4","c5","s2"},cost=24900},
		},
	},

	["Clover"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1"},hide={"a2","c1"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["Voodoo"]={visibled={"a2"},hide={"a1"},cost=11900},
		},

		["Zderzak Przedni"]={
            ["Brak Dokładki"]={visibled={},hide={"c1"}},
			["Dokładka"]={visibled={"c1"},hide={},cost=12900},
		},
	},

	["Uranus"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","c1","c3","b1"},hide={"a2","a3","b2","b3","c2","c4","s1","s2"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["CDX LED"]={visibled={"a2"},hide={"a1","a3"},cost=18900},
			["Uran LED"]={visibled={"a3"},hide={"a1","a2"},cost=22500},
		},

		["Światła Tylne"]={
            ["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["I.D LED"]={visibled={"b2"},hide={"b1","b3"},cost=24900},
			["Umi-Low LED"]={visibled={"b3"},hide={"b1","b2"},cost=29500},
		},
		
		["Grill"]={
            ["Standardowy"]={visibled={"c1"},hide={"c2","s1","s2"}},
			["Niestandardowy"]={visibled={"c2"},hide={"c1","s1","s2"},cost=11900},
		},
		
		["Tylna Listwa"]={
            ["Standardowa"]={visibled={"c3"},hide={"c4","s1","s2"}},
			["Malowana"]={visibled={"c4"},hide={"c3","s1","s2"},cost=8900},
		},
		
		["Specjalne Przód i Tył"]={
            ["RH8 Black"]={visibled={"s2"},hide={"c1","c2","c4","c3","s1"},cost=49500},
			["RH8 Colour"]={visibled={"s1"},hide={"c1","c2","c4","c3","s2"},cost=51900},
		},
	},
		
	["Landstalker"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","c1","c3","b1"},hide={"a2","a3","b2","c4","c2","c5"}},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2"}},
			["AllVision LED"]={visibled={"a2"},hide={"a1","a3"},cost=25900},
			["OptiX LED"]={visibled={"a3"},hide={"a1","a2"},cost=26900},
		},

		["Światła Tylne"]={
            ["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["I.D LED"]={visibled={"b2"},hide={"b1","b3"},cost=27900},
		},
		
		["Grill"]={
            ["Standardowy"]={visibled={"c1"},hide={"c2"}},
			["Niestandardowy"]={visibled={"c2"},hide={"c1"},cost=13900},
		},
		
		["Listwy Boczne"]={
            ["Standardowa"]={visibled={"c3"},hide={"c4"}},
			["Black Fusion"]={visibled={"c4"},hide={"c3"},cost=8900},
		},
	},
		
	["Super GT"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","c2","b1"},hide={"b2","b3","c1"}},
		},

		["Światła Tylne"]={
            ["Standardowe"]={visibled={"b1"},hide={"b2","b3"}},
			["Xeen LED"]={visibled={"b2"},hide={"b1","b3"},cost=47500},
			["ExE LED"]={visibled={"b3"},hide={"b1","b2"},cost=48900},
		},
		
		["Dach"]={
            ["Standardowy"]={visibled={"c2"},hide={}},
			["Cabrio"]={visibled={},hide={"c2"},cost=29500},
		},
		
		["Spoiler"]={
            ["Brak"]={visibled={},hide={"c1"}},
			["WindeX"]={visibled={"c1"},hide={},cost=34900},
		},
	},

	["Windsor"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1"},hide={}},
		},

		["Dach"]={
            ["Kabriolet"]={visibled={},hide={"c1"}},
			["Materiałowy Dach"]={visibled={"c1"},hide={},cost=18900},

		},
	},

	["Feltzer"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1","a2","b1","c3"},hide={"a1","c2","s2"}},
		},

		["Światła przednie"]={
            ["Standardowe"]={visibled={"a2"},hide={"a1"}},
			["Quadric"]={visibled={"a1"},hide={"a2"},cost=12900},
		},
		
		["Dach"]={
            ["Karbiolet"]={visibled={"c1"},hide={"c2"}},
			["Dach"]={visibled={"c2"},hide={"c1"},cost=13900},
		},
		
		["Specjalne"]={
            ["Standardowe"]={visibled={"c3"},hide={"s1"}},
			["V8 Sport Technik"]={visibled={"s1"},hide={"c3"},cost=24900},
		},
	},
		
	["Cadrona"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"c2","b2"}},
		},

		["Grill"]={
            ["Standardowy"]={visibled={"c1"},hide={"c2"}},
			["Niestandardowy"]={visibled={"c2"},hide={"c1"},cost=7800},
		},
		
		["Tylne Lampy"]={
            ["Standardowe"]={visibled={"b1"},hide={"b2"}},
			["I.D LED"]={visibled={"b2"},hide={"b1"},cost=14900},
		},
	},

    ["Bobcat"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"c2","c3","c5","c6","a2","a3","a4","a5","c1","b2","b3","c4","c5","c7","c8","c10","s1","s2","s3","s4","s5"}},
		},
	},

	["Yankee"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1"},hide={"c2"}},
		},

		["Interakcja"]={
			["Laweta"]={visibled={"c2"},hide={"c1"}},
		},
	},

	["Tractor"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={},hide={"c1","c2"}},
		},

		["Interakcja"]={
			["Job_1"]={visibled={"c1"},hide={"c2"}},
			["Job_2"]={visibled={"c2"},hide={"c1"}},
		},
	},

	["Police SF"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a6","b2","c3","c5","c7","c8","c9","c12","c9"},hide={"a1","a2","a3","b1","b3","a4","a5","c1","c2","c4","c6","c11","c10","s1","c10"}},
		},

		["Specjalne"]={
			["siren_on"]={visibled={"c10"},hide={"c9"}},
		},
	},

	["Police Ranger"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a2","c2","c4"},hide={"a1","c5","c3"}},
		},

		["Specjalne"]={
			["siren_on"]={visibled={"c3","c5"},hide={"c4","c2"}},
		},
	},

	[443]={ -- laweta SARA
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c8","c1"},hide={"c9","c3","c2"}},
		},

		["Specjalne"]={
			["Najazdy"]={visibled={"c9"},hide={"c8"}},
			["siren_on"]={visibled={"c2"},hide={"c1"}},
		},
	},

	[459]={ -- SARA 2
		["Podstawowe"]={
			["Podstawowy"]={visibled={},hide={"c4"}},
		},
	},

	[407]={ -- Firetruck
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1"},hide={"c2","c3","c4","c5"}},
		},
	},

	[544]={ -- Firetruck LA
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c2"},hide={"c3","c5"}},
		},
	},

	[416]={ -- Karetka
		["Podstawowe"]={
			["Podstawowy"]={visibled={},hide={"c2","sygnaly14","sygnaly13","sygnaly12","sygnaly22","sygnaly23","sygnaly24"}},
		},
	},
	
	["Flatbed"]={ -- PSP
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c3"},hide={"c2","c4","c5"}},
		},
	},

	[598]={ -- Stratum PSP
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a2","b2","c1"},hide={"a1", "a3", "a4", "b1", "b3", "c1", "c2", "c3", "c4","c5"}},
		},

		["Grill"]={
			["Standardowy"]={visibled={"c1"},hide={"c2","c3","c4"}},
			["Lada"]={visibled={"c2"},hide={"c1","c3","c4"},cost=9500},
			["Passeratii"]={visibled={"c3"},hide={"c1","c2","c4"},cost=10900},
			["Golf"]={visibled={"c4"},hide={"c1","c2","c3"},cost=10900},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4"}},
			["Quirk LED"]={visibled={"a2"},hide={"a1","a3","a4"},cost=23900},	
			["Qomb LED"]={visibled={"a3"},hide={"a1","a2","a4"},cost=23950},	
			["Notine LED"]={visibled={"a4"},hide={"a1","a2","a3"},cost=23500},
		},

		["Tył pojazdu"]={
			["Standardowy"]={visibled={"b1"},hide={"b2","b3"}},
			["Wagen LED"]={visibled={"b2"},hide={"b1","b3"},cost=23500},
			["Corden LED"]={visibled={"b3"},hide={"b2","b1"},cost=21900},
		},
	},

	["Coach"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={},hide={"c1","c2","c3"}},
			["PSP"]={visibled={"c1"},hide={"c2","c3"}},
			["SARA"]={visibled={"c2"},hide={"c1","c3"}},
			["SAPD"]={visibled={"c3"},hide={"c2","c1"}},
		},
	},

	[609]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c1","c3","b2"},hide={"b1","b3","c2","c4","c5","c6"}},
		},
	},

	["Savanna"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={'a1','b1','c1'},hide={'b2','b3','b4','c2','a1','a3'}},
		},

		['Listwy tył']={
			["Standardowa listwa"]={visibled={"c1"},hide={"c2"}},
			["Listwa tylna 2"]={visibled={"c2"},hide={"c1"},cost=7610},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={'a2','a3'}},
			["State"]={visibled={"a2"},hide={'a1','a3'},cost=24500},
			["Unitra"]={visibled={"a3"},hide={'a1','a2'},cost=25090},
		},

		["Światła tylne"]={
			["Standardowe światła"]={visibled={"b1"},hide={"b2","b3"}},
			["Blues"]={visibled={"b2"},hide={"b1","b3"},cost=9650},
			["Jazz"]={visibled={"b3"},hide={"b2","b1"},cost=11500},
		},
	},

	["Remington"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={'a1','b1','c1'},hide={'b2','b3','b4','c2','a1','a3'}},
		},

		['Dach']={
			["Dach"]={visibled={'c1'},hide={}},
			["Cabrio"]={visibled={},hide={'c1'},cost=41250},
		},

		["Światła przednie"]={
			["Standardowe"]={visibled={"a1"},hide={'a2'}},
			["State"]={visibled={"a2"},hide={'a1'},cost=24500},
		},

		["Światła tylne"]={
			["Standardowe światła"]={visibled={"b1"},hide={"b2"}},
			["Blues"]={visibled={"b2"},hide={"b1"},cost=9650},
		},
	},

	["Voodoo"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={'a1', 'b1', 'c1', 'c2', 'c3'},hide={'a2','a3','a4','a5','a6','a7','b2','b3','b4','s1','s2','s3'}},
		},

		['Dach']={
			["Dach"]={visibled={'c1'},hide={}},
			["Cabrio"]={visibled={},hide={'c1'},cost=41250},
		},

		['Specjalne']={
			["Standardowy"]={visibled={'c2','c3'},hide={'s1','s2','s3'}},
			["Sport"]={visibled={'s1','s2','s3'},hide={'c2','c3'},cost=12500},
		},

		["Światła przednie"]={
            ["Standardowe"]={visibled={"a1"},hide={"a2","a3","a4","a5","a6"}},
            ["State"]={visibled={"a2"},hide={"a1","a3","a4","a5","a6"},cost=25850},
            ["Unitra"]={visibled={"a3"},hide={"a2","a1","a4","a5","a6"},cost=26550},
            ["Corden"]={visibled={"a4"},hide={"a2","a3","a1","a5","a6"},cost=25900},
            ["Wagen"]={visibled={"a5"},hide={"a2","a3","a4","a1","a6"},cost=26390},
            ["Quirk"]={visibled={"a6"},hide={"a2","a3","a4","a5","a1"},cost=27500},
        },

		["Światła tylne"]={
			["Standardowe światła"]={visibled={"b1"},hide={"b2","b3",'b4'}},
			["Blues"]={visibled={"b2"},hide={"b1","b3",'b4'},cost=9650},
			["Jazz"]={visibled={"b3"},hide={"b2","b1",'b4'},cost=11500},
			["Quadric"]={visibled={"b4"},hide={"b2","b1",'b3'},cost=10300},
		},
	},

	-- do ustawienia
	["Tahoma"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"b2", "a4", "c5", "c2"},hide={"b1", "a1", "a2", "a3", "c1", "c3", "c4", "c6"}}
		},
	},

	["Greenwood"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"c2", "b2", "a4"},hide={"c1", "a1", "a2", "a3", "b1"}}
		},
	},

	["Blade"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","b1","c1"},hide={"a2","c2","h1","b2"}}
		},
	},

	["Slamvan"]={
		["Podstawowe"]={
			["Podstawowy"]={visibled={"a1","c1","b1","c3","c4"},hide={"b2","b3","b4","c2","b2","a2"}},
		},
	},
}